-- QA-only: turn a copy of the dev DB into a clean, fictional baseline. Never run against the dev DB.
SET FOREIGN_KEY_CHECKS=0;
TRUNCATE orders; TRUNCATE order_items; TRUNCATE order_payment; TRUNCATE order_comments; TRUNCATE order_transactions;
TRUNCATE invoices; TRUNCATE invoice_items; TRUNCATE shipments; TRUNCATE shipment_items; TRUNCATE refunds; TRUNCATE refund_items;
TRUNCATE cart; TRUNCATE cart_items; TRUNCATE cart_item_inventories; TRUNCATE cart_payment; TRUNCATE cart_shipping_rates; TRUNCATE cart_rule_coupon_usage; TRUNCATE cart_rule_customers;
TRUNCATE b2b_customer_quotes; TRUNCATE b2b_customer_quote_items; TRUNCATE b2b_customer_quote_messages; TRUNCATE b2b_customer_quote_attachments; TRUNCATE b2b_customer_quote_quotations;
TRUNCATE b2b_customer_requisition_lists; TRUNCATE b2b_customer_requisition_list_products;
TRUNCATE b2b_company_credits; TRUNCATE b2b_company_credit_transactions; TRUNCATE b2b_company_flat; TRUNCATE b2b_company_roles; TRUNCATE b2b_company_invitations;
TRUNCATE b2b_customer_companies; TRUNCATE b2b_company_attribute_values;
TRUNCATE b2b_company_catalogs; TRUNCATE b2b_company_catalog_products; TRUNCATE b2b_company_catalog_categories; TRUNCATE product_customer_group_prices;
DELETE FROM customer_groups WHERE code NOT IN ('guest','general','wholesale');
TRUNCATE customers; TRUNCATE customer_notes; TRUNCATE customer_password_resets; TRUNCATE customer_social_accounts; TRUNCATE addresses;
TRUNCATE product_ordered_inventories; TRUNCATE notifications; TRUNCATE sessions; TRUNCATE cache; TRUNCATE cache_locks; TRUNCATE jobs; TRUNCATE failed_jobs;
TRUNCATE wishlist; TRUNCATE wishlist_items; TRUNCATE compare_items; TRUNCATE product_reviews; TRUNCATE product_review_attachments; TRUNCATE subscribers_list;
TRUNCATE downloadable_link_purchased; TRUNCATE eu_withdrawals; TRUNCATE gdpr_data_request; TRUNCATE rma; TRUNCATE rma_items; TRUNCATE rma_messages; TRUNCATE rma_images; TRUNCATE rma_additional_fields;
-- admins: one owner-level QA admin (credentials set later), 2FA cleared (dev secret was encrypted with the dev APP_KEY)
DELETE FROM admins WHERE id <> 1;
UPDATE admins SET email='qa.admin@example.test', name='QA Admin', two_factor_enabled=0, two_factor_secret=NULL, two_factor_backup_codes=NULL,
  two_factor_verified_at=NULL, two_factor_last_used_window=NULL, remember_token=NULL WHERE id=1;
UPDATE roles SET name='QA Order Desk (view orders only)', description='Fictional QA role' WHERE id=2;
-- order numbers restart at 1
UPDATE vk7_sequences SET value=0 WHERE name='order';
-- QA defaults: MOQ on (24 per style), store-wide admin 2FA off (automation-friendly), personal sign-up needs approval
UPDATE core_config SET value='1' WHERE code='vk7.moq.settings.enabled';
UPDATE core_config SET value='24' WHERE code='vk7.moq.settings.min_qty';
UPDATE core_config SET value='per_style' WHERE code='vk7.moq.settings.mode';
UPDATE core_config SET value='1' WHERE code='vk7.moq.settings.apply_to_admin_orders';
UPDATE core_config SET value='0' WHERE code='vk7.security.admin.require_two_factor';
UPDATE core_config SET value='1' WHERE code='vk7.security.storefront.personal_account_approval';
SET FOREIGN_KEY_CHECKS=1;
