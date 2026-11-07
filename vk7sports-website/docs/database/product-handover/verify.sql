-- VK7 database handover: PostgreSQL READ-ONLY verification.
-- Intended for an authorised existing UAT/staging connection.
-- Run with psql ON_ERROR_STOP=1. Contains no DDL/DML or fixture inserts.
BEGIN TRANSACTION READ ONLY;

-- Exact connected engine/version. Provider must also be confirmed by deployment metadata.
SELECT version() AS engine_version,
       current_setting('server_version') AS server_version,
       current_database() AS database_name,
       current_schema() AS schema_name;

-- Compare these with the import report; total tables can change after later migrations.
SELECT count(*) AS public_base_tables
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

SELECT 'styles' AS measure, count(*) AS records FROM products
WHERE type = 'configurable' AND parent_id IS NULL
UNION ALL
SELECT 'variants', count(*) FROM products WHERE parent_id IS NOT NULL
UNION ALL
SELECT 'inventory_rows', count(*) FROM product_inventories
UNION ALL
SELECT 'product_images', count(*) FROM product_images
UNION ALL
SELECT 'group_prices', count(*) FROM product_customer_group_prices;

-- Reference codes must exist before importing: unknown sources can be silently skipped,
-- and unknown customer groups can become NULL (all groups) in the native importer.
SELECT id, code, status FROM inventory_sources ORDER BY id;
SELECT id, code FROM customer_groups ORDER BY id;
SELECT id, code FROM attribute_families ORDER BY id;
SELECT id, code FROM channels ORDER BY id;
SELECT id, code FROM locales ORDER BY id;
SELECT id, code FROM currencies ORDER BY id;
SELECT code, value, channel_code FROM core_config
WHERE code LIKE 'vk7.moq.settings.%'
   OR code IN ('general.general.locale_options.weight_unit', 'sales.taxes.calculation.product_prices')
ORDER BY channel_code, code;

SELECT a.code, o.id AS option_id, o.admin_name, o.sort_order
FROM attributes a JOIN attribute_options o ON o.attribute_id = a.id
WHERE a.code IN ('color', 'size')
ORDER BY a.code, o.sort_order, o.id;

-- Expected zero rows for these integrity checks.
SELECT lower(trim(sku)) AS normalised_sku, count(*) AS duplicates
FROM products GROUP BY lower(trim(sku)) HAVING count(*) > 1;

SELECT child.id, child.sku, child.parent_id
FROM products child LEFT JOIN products parent ON parent.id = child.parent_id
WHERE child.parent_id IS NOT NULL
  AND (parent.id IS NULL OR parent.type <> 'configurable' OR child.type <> 'simple');

WITH options AS (
    SELECT p.id, p.sku, p.parent_id,
           count(DISTINCT v.integer_value) FILTER (WHERE a.code = 'color') AS colour_count,
           count(DISTINCT v.integer_value) FILTER (WHERE a.code = 'size') AS size_count,
           max(v.integer_value) FILTER (WHERE a.code = 'color') AS colour_id,
           max(v.integer_value) FILTER (WHERE a.code = 'size') AS size_id
    FROM products p
    LEFT JOIN product_attribute_values v ON v.product_id = p.id
    LEFT JOIN attributes a ON a.id = v.attribute_id AND a.code IN ('color', 'size')
    WHERE p.parent_id IS NOT NULL
    GROUP BY p.id, p.sku, p.parent_id
)
SELECT * FROM options WHERE colour_count <> 1 OR size_count <> 1;

WITH variants AS (
    SELECT p.id, p.parent_id,
           max(v.integer_value) FILTER (WHERE a.code = 'color') AS colour_id,
           max(v.integer_value) FILTER (WHERE a.code = 'size') AS size_id
    FROM products p
    LEFT JOIN product_attribute_values v ON v.product_id = p.id
    LEFT JOIN attributes a ON a.id = v.attribute_id
    WHERE p.parent_id IS NOT NULL
    GROUP BY p.id, p.parent_id
)
SELECT parent_id, colour_id, size_id, count(*) AS duplicate_combinations
FROM variants GROUP BY parent_id, colour_id, size_id HAVING count(*) > 1;

SELECT v.product_id, a.code, v.integer_value AS invalid_option_id
FROM product_attribute_values v
JOIN attributes a ON a.id = v.attribute_id
LEFT JOIN attribute_options o ON o.id = v.integer_value AND o.attribute_id = a.id
WHERE a.code IN ('color', 'size') AND v.integer_value IS NOT NULL AND o.id IS NULL;

SELECT id, product_id, inventory_source_id, qty
FROM product_inventories WHERE qty < 0;

SELECT product_id, inventory_source_id, vendor_id, count(*) AS duplicates
FROM product_inventories
GROUP BY product_id, inventory_source_id, vendor_id HAVING count(*) > 1;

-- Compare these per-SKU values with the approved stock file, not only grand totals.
-- Aggregating before joining prevents multiplication across sources/channels.
WITH on_hand AS (
    SELECT product_id, sum(qty) AS qty FROM product_inventories GROUP BY product_id
), held AS (
    SELECT product_id, sum(qty) AS qty FROM product_ordered_inventories GROUP BY product_id
)
SELECT p.sku, coalesce(i.qty, 0) AS on_hand, coalesce(h.qty, 0) AS reserved,
       coalesce(i.qty, 0) - coalesce(h.qty, 0) AS available,
       coalesce(i.qty, 0) < coalesce(h.qty, 0) AS oversubscribed
FROM products p LEFT JOIN on_hand i ON i.product_id = p.id
LEFT JOIN held h ON h.product_id = p.id
WHERE p.parent_id IS NOT NULL ORDER BY p.sku;

-- EAV price values and imported fixed tiers, for reconciliation.
SELECT p.sku, v.channel, v.locale, v.float_value AS price
FROM products p JOIN product_attribute_values v ON v.product_id = p.id
JOIN attributes a ON a.id = v.attribute_id
WHERE a.code = 'price' ORDER BY p.sku, v.channel, v.locale;

SELECT p.sku, g.code AS customer_group, t.qty AS min_qty, t.value_type, t.value
FROM product_customer_group_prices t JOIN products p ON p.id = t.product_id
LEFT JOIN customer_groups g ON g.id = t.customer_group_id
ORDER BY p.sku, g.code, t.qty;

WITH tiers AS (
    SELECT product_id, customer_group_id, qty, value,
           lag(value) OVER (PARTITION BY product_id, customer_group_id ORDER BY qty) AS previous_price
    FROM product_customer_group_prices WHERE value_type = 'fixed'
)
SELECT * FROM tiers WHERE qty <= 0 OR value <= 0 OR value > previous_price;

-- These must be zero in a business-only handover target.
SELECT count(*) AS synthetic_products
FROM products WHERE sku LIKE 'SYNTHETIC-%' OR sku LIKE 'TEST-%';

-- Readability indexes: missing rows need the existing Bagisto indexing workflow.
SELECT p.sku FROM products p
WHERE NOT EXISTS (SELECT 1 FROM product_flat f WHERE f.product_id = p.id);

-- Family membership and required-attribute preflight.
SELECT f.code AS family_code, a.code, a.type, a.is_required, a.is_configurable
FROM attribute_families f
JOIN attribute_groups g ON g.attribute_family_id = f.id
JOIN attribute_group_mappings m ON m.attribute_group_id = g.id
JOIN attributes a ON a.id = m.attribute_id
ORDER BY f.code, a.code;

-- Verify category names in every supplied path: importer resolves names independently.
SELECT name, count(DISTINCT category_id) AS matching_categories
FROM category_translations GROUP BY name ORDER BY name;

SELECT c.code AS channel_code, s.code AS source_code, s.status
FROM channel_inventory_sources x
JOIN channels c ON c.id = x.channel_id
JOIN inventory_sources s ON s.id = x.inventory_source_id
ORDER BY c.code, s.code;

-- Source-level reconciliation is essential; grand totals alone can hide misallocations.
SELECT p.sku, s.code AS source_code, i.vendor_id, i.qty
FROM product_inventories i
JOIN products p ON p.id = i.product_id
JOIN inventory_sources s ON s.id = i.inventory_source_id
ORDER BY p.sku, s.code, i.vendor_id;

SELECT p.sku, count(i.id) AS image_rows
FROM products p LEFT JOIN product_images i ON i.product_id = p.id
GROUP BY p.id, p.sku ORDER BY p.sku;

ROLLBACK;
