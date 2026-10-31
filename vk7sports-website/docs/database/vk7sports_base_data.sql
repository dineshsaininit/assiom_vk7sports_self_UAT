--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: customer_groups; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.customer_groups (id, code, name, is_user_defined, created_at, updated_at) VALUES
	(1, 'guest', 'Guest', false, NULL, NULL),
	(2, 'general', 'General', false, NULL, NULL),
	(3, 'wholesale', 'Wholesale', false, NULL, NULL);


--
-- Data for Name: b2b_company_catalogs; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.categories (id, "position", status, display_mode, _lft, _rgt, parent_id, additional, created_at, updated_at, logo_path, banner_path) VALUES
	(1, 1, true, 'products_and_description', 1, 82, NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL);


--
-- Data for Name: currencies; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.currencies (id, code, name, symbol, "decimal", created_at, updated_at, group_separator, decimal_separator, currency_position) VALUES
	(1, 'INR', 'Indian Rupee', '₹', 2, NULL, NULL, ',', '.', NULL);


--
-- Data for Name: locales; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.locales (id, code, name, direction, created_at, updated_at, logo_path) VALUES
	(1, 'en', 'English', 'ltr', NULL, NULL, 'locales/biPbAnLzjbIrIgnndcwGlhD1D0bw0RzbLOpYLKtK.png');


--
-- Data for Name: channels; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.channels (id, code, timezone, theme, hostname, logo, favicon, home_seo, is_maintenance_on, allowed_ips, root_category_id, default_locale_id, base_currency_id, created_at, updated_at) VALUES
	(1, 'default', NULL, 'default', 'http://127.0.0.1:8000', NULL, NULL, NULL, false, NULL, 1, 1, 1, '2026-10-31 22:53:05', '2026-10-31 22:53:05');


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: admin_password_resets; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: agent_conversation_messages; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: agent_conversations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: attribute_families; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.attribute_families (id, code, name, status, is_user_defined) VALUES
	(1, 'default', 'Default', false, true);


--
-- Data for Name: attribute_groups; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.attribute_groups (id, attribute_family_id, name, "position", is_user_defined, "column", code) VALUES
	(1, 1, 'General', 1, false, 1, 'general'),
	(2, 1, 'Description', 2, false, 1, 'description'),
	(3, 1, 'Meta Description', 3, false, 1, 'meta_description'),
	(4, 1, 'Price', 1, false, 2, 'price'),
	(5, 1, 'Shipping', 2, false, 2, 'shipping'),
	(6, 1, 'Settings', 3, false, 2, 'settings'),
	(7, 1, 'Inventories', 4, false, 2, 'inventories'),
	(8, 1, 'RMA', 5, false, 2, 'rma');


--
-- Data for Name: attributes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.attributes (id, code, admin_name, type, swatch_type, validation, "position", is_required, is_unique, is_filterable, is_comparable, is_configurable, is_user_defined, is_visible_on_front, value_per_locale, value_per_channel, enable_wysiwyg, created_at, updated_at, regex, default_value) VALUES
	(1, 'sku', 'SKU', 'text', NULL, NULL, 1, true, true, false, false, false, false, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(2, 'name', 'Name', 'text', NULL, NULL, 3, true, false, false, true, false, false, false, true, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(3, 'url_key', 'URL Key', 'text', NULL, NULL, 4, true, true, false, false, false, false, false, true, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(4, 'tax_category_id', 'Tax Category', 'select', NULL, NULL, 5, false, false, false, false, false, false, false, false, true, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(5, 'new', 'New', 'boolean', NULL, NULL, 6, false, false, false, false, false, false, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, 1),
	(6, 'featured', 'Featured', 'boolean', NULL, NULL, 7, false, false, false, false, false, false, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, 1),
	(7, 'visible_individually', 'Visible Individually', 'boolean', NULL, NULL, 9, true, false, false, false, false, false, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, 1),
	(8, 'status', 'Status', 'boolean', NULL, NULL, 10, true, false, false, false, false, false, false, false, true, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, 1),
	(9, 'short_description', 'Short Description', 'textarea', NULL, NULL, 11, true, false, false, false, false, false, false, true, false, true, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(10, 'description', 'Description', 'textarea', NULL, NULL, 12, true, false, false, true, false, false, false, true, false, true, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(11, 'price', 'Price', 'price', NULL, 'decimal', 13, true, false, true, true, false, false, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(12, 'cost', 'Cost', 'price', NULL, 'decimal', 14, false, false, false, false, false, true, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(13, 'special_price', 'Special Price', 'price', NULL, 'decimal', 15, false, false, false, false, false, false, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(14, 'special_price_from', 'Special Price From', 'date', NULL, NULL, 16, false, false, false, false, false, false, false, false, true, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(15, 'special_price_to', 'Special Price To', 'date', NULL, NULL, 17, false, false, false, false, false, false, false, false, true, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(16, 'meta_title', 'Meta Title', 'textarea', NULL, NULL, 18, false, false, false, false, false, false, false, true, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(17, 'meta_keywords', 'Meta Keywords', 'textarea', NULL, NULL, 20, false, false, false, false, false, false, false, true, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(18, 'meta_description', 'Meta Description', 'textarea', NULL, NULL, 21, false, false, false, false, false, true, false, true, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(19, 'length', 'Length', 'text', NULL, 'decimal', 22, false, false, false, false, false, true, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(20, 'width', 'Width', 'text', NULL, 'decimal', 23, false, false, false, false, false, true, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(21, 'height', 'Height', 'text', NULL, 'decimal', 24, false, false, false, false, false, true, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(22, 'weight', 'Weight', 'text', NULL, 'decimal', 25, true, false, false, false, false, false, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(23, 'color', 'Color', 'select', NULL, NULL, 26, false, false, true, false, true, true, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(24, 'size', 'Size', 'select', NULL, NULL, 27, false, false, true, false, true, true, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(25, 'brand', 'Brand', 'select', NULL, NULL, 28, false, false, true, false, false, true, true, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(26, 'guest_checkout', 'Guest Checkout', 'boolean', NULL, NULL, 8, true, false, false, false, false, false, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, 1),
	(27, 'product_number', 'Product Number', 'text', NULL, NULL, 2, false, true, false, false, false, false, false, false, false, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL),
	(28, 'manage_stock', 'Manage Stock', 'boolean', NULL, NULL, 1, false, false, false, false, false, false, false, false, true, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, 1),
	(29, 'allow_rma', 'Allow RMA', 'boolean', NULL, NULL, 1, false, false, false, false, false, false, false, false, true, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, 0),
	(30, 'rma_rule_id', 'RMA Rules', 'select', NULL, NULL, 5, false, false, false, false, false, false, false, false, true, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05', NULL, NULL);


--
-- Data for Name: attribute_group_mappings; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.attribute_group_mappings (attribute_id, attribute_group_id, "position") VALUES
	(1, 1, 1),
	(27, 1, 2),
	(2, 1, 3),
	(3, 1, 4),
	(4, 1, 5),
	(23, 1, 6),
	(24, 1, 7),
	(25, 1, 8),
	(9, 2, 1),
	(10, 2, 2),
	(11, 4, 1),
	(12, 4, 2),
	(13, 4, 3),
	(14, 4, 4),
	(15, 4, 5),
	(16, 3, 1),
	(17, 3, 2),
	(18, 3, 3),
	(19, 5, 1),
	(20, 5, 2),
	(21, 5, 3),
	(22, 5, 4),
	(5, 6, 1),
	(6, 6, 2),
	(7, 6, 3),
	(8, 6, 4),
	(26, 6, 5),
	(28, 7, 1),
	(29, 8, 1),
	(30, 8, 2);


--
-- Data for Name: attribute_options; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.attribute_options (id, attribute_id, admin_name, sort_order, swatch_value) VALUES
	(1, 23, 'Red', 1, NULL),
	(2, 23, 'Green', 2, NULL),
	(3, 23, 'Yellow', 3, NULL),
	(4, 23, 'Black', 4, NULL),
	(5, 23, 'White', 5, NULL),
	(6, 24, 'S', 1, NULL),
	(7, 24, 'M', 2, NULL),
	(8, 24, 'L', 3, NULL),
	(9, 24, 'XL', 4, NULL);


--
-- Data for Name: attribute_option_translations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.attribute_option_translations (id, attribute_option_id, locale, label, swatch_alt) VALUES
	(1, 1, 'en', 'Red', NULL),
	(2, 2, 'en', 'Green', NULL),
	(3, 3, 'en', 'Yellow', NULL),
	(4, 4, 'en', 'Black', NULL),
	(5, 5, 'en', 'White', NULL),
	(6, 6, 'en', 'S', NULL),
	(7, 7, 'en', 'M', NULL),
	(8, 8, 'en', 'L', NULL),
	(9, 9, 'en', 'XL', NULL);


--
-- Data for Name: attribute_translations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.attribute_translations (id, attribute_id, locale, name) VALUES
	(1, 1, 'en', 'SKU'),
	(2, 2, 'en', 'Name'),
	(3, 3, 'en', 'URL Key'),
	(4, 4, 'en', 'Tax Category'),
	(5, 5, 'en', 'New'),
	(6, 6, 'en', 'Featured'),
	(7, 7, 'en', 'Visible Individually'),
	(8, 8, 'en', 'Status'),
	(9, 9, 'en', 'Short Description'),
	(10, 10, 'en', 'Description'),
	(11, 11, 'en', 'Price'),
	(12, 12, 'en', 'Cost'),
	(13, 13, 'en', 'Special Price'),
	(14, 14, 'en', 'Special Price From'),
	(15, 15, 'en', 'Special Price To'),
	(16, 16, 'en', 'Meta Title'),
	(17, 17, 'en', 'Meta Keywords'),
	(18, 18, 'en', 'Meta Description'),
	(19, 19, 'en', 'Length'),
	(20, 20, 'en', 'Width'),
	(21, 21, 'en', 'Height'),
	(22, 22, 'en', 'Weight'),
	(23, 23, 'en', 'Color'),
	(24, 24, 'en', 'Size'),
	(25, 25, 'en', 'Brand'),
	(26, 26, 'en', 'Guest Checkout'),
	(27, 27, 'en', 'Product Number'),
	(28, 28, 'en', 'Manage Stock'),
	(29, 29, 'en', 'Allow RMA'),
	(30, 30, 'en', 'RMA Rules');


--
-- Data for Name: b2b_company_attribute_groups; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.b2b_company_attribute_groups (id, code, admin_name, "column", "position", is_user_defined) VALUES
	(1, 'general', 'General', 1, 1, false),
	(2, 'address', 'Address', 1, 2, false),
	(3, 'meta_description', 'Meta Description', 2, 1, false),
	(4, 'policies', 'Policies', 1, 3, false),
	(5, 'social_links', 'Social Links', 2, 2, false);


--
-- Data for Name: b2b_company_attributes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.b2b_company_attributes (id, code, admin_name, type, validation, regex, "position", is_required, is_unique, is_user_defined, is_visible_on_sign_up, default_value, value_per_locale, value_per_channel, enable_editor, created_at, updated_at) VALUES
	(1, 'first_name', 'First Name', 'text', NULL, NULL, 1, true, false, false, true, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(2, 'last_name', 'Last Name', 'text', NULL, NULL, 2, true, false, false, true, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(3, 'email', 'Email', 'text', 'email', NULL, 3, true, true, false, true, NULL, false, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(4, 'phone', 'Phone', 'text', 'phone', NULL, 4, true, true, false, true, NULL, false, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(6, 'business_name', 'Business Name', 'text', NULL, NULL, 6, true, true, false, true, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(7, 'website_url', 'Website URL', 'text', NULL, NULL, 7, false, true, false, false, NULL, false, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(8, 'vat_tax_id', 'VAT Tax ID', 'text', NULL, NULL, 8, false, true, false, false, NULL, false, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(9, 'address', 'Address', 'text', NULL, NULL, 9, true, false, false, false, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(10, 'city', 'City', 'text', NULL, NULL, 10, true, false, false, false, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(11, 'country', 'Country', 'text', NULL, NULL, 11, true, false, false, false, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(12, 'state', 'State', 'text', NULL, NULL, 12, true, false, false, false, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(13, 'postcode', 'Postcode', 'text', NULL, NULL, 13, true, false, false, false, NULL, false, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(14, 'meta_title', 'Meta Title', 'text', NULL, NULL, 14, false, false, false, false, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(15, 'meta_keywords', 'Meta Keywords', 'text', NULL, NULL, 15, false, false, false, false, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(16, 'meta_description', 'Meta Description', 'textarea', NULL, NULL, 16, false, false, false, false, NULL, true, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(17, 'return_policy', 'Return Policy', 'textarea', NULL, NULL, 17, false, false, false, false, NULL, true, false, true, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(18, 'shipping_policy', 'Shipping Policy', 'textarea', NULL, NULL, 18, false, false, false, false, NULL, true, false, true, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(19, 'privacy_policy', 'Privacy Policy', 'textarea', NULL, NULL, 19, false, false, false, false, NULL, true, false, true, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(20, 'facebook', 'Facebook', 'text', NULL, NULL, 20, false, false, false, false, NULL, false, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(21, 'instagram', 'Instagram', 'text', NULL, NULL, 21, false, false, false, false, NULL, false, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09'),
	(22, 'youtube', 'YouTube', 'text', NULL, NULL, 22, false, false, false, false, NULL, false, false, false, '2026-10-31 22:53:09', '2026-10-31 22:53:09');


--
-- Data for Name: b2b_company_attribute_group_mappings; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.b2b_company_attribute_group_mappings (id, company_attribute_id, company_attribute_group_id, "position") VALUES
	(1, 1, 1, 1),
	(2, 2, 1, 2),
	(3, 3, 1, 3),
	(4, 4, 1, 4),
	(5, 6, 1, 6),
	(6, 7, 1, 7),
	(7, 8, 1, 8),
	(8, 9, 2, 1),
	(9, 10, 2, 2),
	(10, 11, 2, 3),
	(11, 12, 2, 4),
	(12, 13, 2, 5),
	(13, 14, 3, 1),
	(14, 15, 3, 2),
	(15, 16, 3, 3),
	(16, 17, 4, 1),
	(17, 18, 4, 2),
	(18, 19, 4, 3),
	(19, 20, 5, 1),
	(20, 21, 5, 2),
	(21, 22, 5, 3);


--
-- Data for Name: b2b_company_attribute_group_translations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.b2b_company_attribute_group_translations (id, company_attribute_group_id, locale, name) VALUES
	(1, 1, 'en', 'General'),
	(2, 2, 'en', 'Address'),
	(3, 3, 'en', 'Meta Description'),
	(4, 4, 'en', 'Policies'),
	(5, 5, 'en', 'Social Links');


--
-- Data for Name: b2b_company_attribute_options; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_company_attribute_option_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_company_attribute_translations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.b2b_company_attribute_translations (id, company_attribute_id, locale, name) VALUES
	(1, 1, 'en', 'First Name'),
	(2, 2, 'en', 'Last Name'),
	(3, 3, 'en', 'Email'),
	(4, 4, 'en', 'Phone'),
	(5, 6, 'en', 'Business Name'),
	(6, 7, 'en', 'Website URL'),
	(7, 8, 'en', 'VAT Tax ID'),
	(8, 9, 'en', 'Address'),
	(9, 10, 'en', 'City'),
	(10, 11, 'en', 'Country'),
	(11, 12, 'en', 'State'),
	(12, 13, 'en', 'Postcode'),
	(13, 14, 'en', 'Meta Title'),
	(14, 15, 'en', 'Meta Keywords'),
	(15, 16, 'en', 'Meta Description'),
	(16, 17, 'en', 'Return Policy'),
	(17, 18, 'en', 'Shipping Policy'),
	(18, 19, 'en', 'Privacy Policy'),
	(19, 20, 'en', 'Facebook'),
	(20, 21, 'en', 'Instagram'),
	(21, 22, 'en', 'YouTube');


--
-- Data for Name: b2b_company_attribute_values; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_company_catalog_categories; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_company_catalog_products; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_company_credits; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_company_credit_transactions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_company_flat; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_company_roles; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_company_invitations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_customer_companies; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_customer_quotes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_customer_quote_attachments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_customer_quote_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_customer_quote_messages; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_customer_quote_quotations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_customer_requisition_lists; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: b2b_customer_requisition_list_products; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: booking_products; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: booking_product_appointment_slots; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: booking_product_default_slots; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: booking_product_event_tickets; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: booking_product_event_ticket_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: booking_product_rental_slots; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: booking_product_table_slots; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: tax_categories; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_item_inventories; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_payment; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_rules; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_rule_channels; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_rule_coupons; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_rule_coupon_usage; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_rule_customer_groups; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_rule_customers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_rule_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: cart_shipping_rates; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: catalog_rules; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: catalog_rule_channels; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: catalog_rule_customer_groups; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: catalog_rule_product_prices; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: catalog_rule_products; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: category_filterable_attributes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: category_translations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.category_translations (id, category_id, name, slug, url_path, description, meta_title, meta_description, meta_keywords, locale_id, locale, logo_alt, banner_alt) VALUES
	(1, 1, 'Root', 'root', '', 'Root Category Description', '', '', '', NULL, 'en', NULL, NULL);


--
-- Data for Name: channel_currencies; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.channel_currencies (channel_id, currency_id) VALUES
	(1, 1);


--
-- Data for Name: inventory_sources; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.inventory_sources (id, code, name, description, contact_name, contact_email, contact_number, contact_fax, country, state, city, street, postcode, priority, latitude, longitude, status, created_at, updated_at) VALUES
	(1, 'default', 'Default', NULL, 'Default', 'warehouse@example.com', '1234567899', NULL, 'US', 'MI', 'Detroit', '12th Street', '48127', 0, NULL, NULL, true, NULL, NULL);


--
-- Data for Name: channel_inventory_sources; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.channel_inventory_sources (channel_id, inventory_source_id) VALUES
	(1, 1);


--
-- Data for Name: channel_locales; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.channel_locales (channel_id, locale_id) VALUES
	(1, 1);


--
-- Data for Name: channel_translations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.channel_translations (id, channel_id, locale, name, description, maintenance_mode_text, home_seo, created_at, updated_at, logo_alt) VALUES
	(1, 1, 'en', 'Default', NULL, NULL, '{"meta_title": "Demo store", "meta_keywords": "Demo store meta keyword", "meta_description": "Demo store meta description"}', NULL, NULL, NULL);


--
-- Data for Name: cms_pages; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cms_pages (id, layout, created_at, updated_at) VALUES
	(1, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(2, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(3, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(4, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(5, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(6, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(7, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(8, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(9, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(10, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05');


--
-- Data for Name: cms_page_channels; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cms_page_channels (cms_page_id, channel_id) VALUES
	(1, 1),
	(2, 1),
	(3, 1),
	(4, 1),
	(5, 1),
	(6, 1),
	(7, 1),
	(8, 1),
	(9, 1),
	(10, 1);


--
-- Data for Name: cms_page_translations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.cms_page_translations (id, page_title, url_key, html_content, meta_title, meta_description, meta_keywords, locale, cms_page_id) VALUES
	(1, 'About Us', 'about-us', '<div class="static-container"><div class="mb-5">About Us Page Content</div></div>', 'about us', '', 'aboutus', 'en', 1),
	(2, 'Return Policy', 'return-policy', '<div class="static-container"><div class="mb-5">Return Policy Page Content</div></div>', 'return policy', '', 'return, policy', 'en', 2),
	(3, 'Refund Policy', 'refund-policy', '<div class="static-container"><div class="mb-5">Refund Policy Page Content</div></div>', 'Refund policy', '', 'refund, policy', 'en', 3),
	(4, 'Terms & Conditions', 'terms-conditions', '<div class="static-container"><div class="mb-5">Terms & Conditions Page Content</div></div>', 'Terms & Conditions', '', 'term, conditions', 'en', 4),
	(5, 'Terms of Use', 'terms-of-use', '<div class="static-container"><div class="mb-5">Terms of Use Page Content</div></div>', 'Terms of use', '', 'term, use', 'en', 5),
	(6, 'Customer Service', 'customer-service', '<div class="static-container"><div class="mb-5">Customer Service Page Content</div></div>', 'Customer Service', '', 'customer, service', 'en', 6),
	(7, 'What''s New', 'whats-new', '<div class="static-container"><div class="mb-5">What''s New page content</div></div>', 'What''s New', '', 'new', 'en', 7),
	(8, 'Payment Policy', 'payment-policy', '<div class="static-container"><div class="mb-5">Payment Policy Page Content</div></div>', 'Payment Policy', '', 'payment, policy', 'en', 8),
	(9, 'Shipping Policy', 'shipping-policy', '<div class="static-container"><div class="mb-5">Shipping Policy Page Content</div></div>', 'Shipping Policy', '', 'shipping, policy', 'en', 9),
	(10, 'Privacy Policy', 'privacy-policy', '<div class="static-container"><div class="mb-5">Privacy Policy Page Content</div></div>', 'Privacy Policy', '', 'privacy, policy', 'en', 10);


--
-- Data for Name: compare_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: core_config; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.core_config (id, code, value, channel_code, locale_code, created_at, updated_at) VALUES
	(1, 'sales.checkout.shopping_cart.allow_guest_checkout', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(2, 'emails.general.notifications.emails.general.notifications.registration', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(3, 'emails.general.notifications.emails.general.notifications.customer_registration_confirmation_mail_to_admin', '0', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(4, 'emails.general.notifications.emails.general.notifications.customer_account_credentials', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(5, 'emails.general.notifications.emails.general.notifications.new_order', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(6, 'emails.general.notifications.emails.general.notifications.new_order_mail_to_admin', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(7, 'emails.general.notifications.emails.general.notifications.new_invoice', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(8, 'emails.general.notifications.emails.general.notifications.new_invoice_mail_to_admin', '0', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(9, 'emails.general.notifications.emails.general.notifications.new_refund', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(10, 'emails.general.notifications.emails.general.notifications.new_refund_mail_to_admin', '0', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(11, 'emails.general.notifications.emails.general.notifications.new_shipment', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(12, 'emails.general.notifications.emails.general.notifications.new_shipment_mail_to_admin', '0', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(13, 'emails.general.notifications.emails.general.notifications.new_inventory_source', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(14, 'emails.general.notifications.emails.general.notifications.cancel_order', '1', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(15, 'emails.general.notifications.emails.general.notifications.cancel_order_mail_to_admin', '0', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(16, 'general.design.categories.category_view', 'sidebar', NULL, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(17, 'customer.settings.social_login.enable_facebook', '1', 'default', NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(18, 'customer.settings.social_login.enable_twitter', '1', 'default', NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(19, 'customer.settings.social_login.enable_google', '1', 'default', NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(20, 'customer.settings.social_login.enable_linkedin', '1', 'default', NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(21, 'customer.settings.social_login.enable_github', '1', 'default', NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(23, 'vk7.moq.settings.enabled', '1', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(24, 'vk7.moq.settings.min_qty', '24', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(25, 'vk7.moq.settings.mode', 'per_style', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(26, 'vk7.moq.settings.apply_to_admin_orders', '1', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(27, 'vk7.pricing.visibility.hide_from_guests', '1', NULL, NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(28, 'vk7.payments.terms.advance_percent', '10', NULL, NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(29, 'vk7.payments.terms.hold_hours', '48', NULL, NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(30, 'b2b.general.settings.active', '1', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(31, 'b2b.general.settings.require_company_approval', '1', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(32, 'b2b.quotes.settings.default_expiration_period', '7', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(33, 'b2b.quotes.settings.expiration_period_unit', 'days', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(34, 'customer.settings.create_new_account_options.default_group', 'general', NULL, NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(35, 'sales.order_settings.order_number.order_number_prefix', 'VK7-', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(36, 'sales.order_settings.order_number.order_number_length', '6', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(37, 'sales.payment_methods.cashondelivery.active', '1', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(38, 'sales.payment_methods.moneytransfer.active', '1', 'default', NULL, '2026-10-31 22:53:12', '2026-10-31 22:53:12');


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.countries (id, code, name) VALUES
	(1, 'AF', 'Afghanistan'),
	(2, 'AX', 'Åland Islands'),
	(3, 'AL', 'Albania'),
	(4, 'DZ', 'Algeria'),
	(5, 'AS', 'American Samoa'),
	(6, 'AD', 'Andorra'),
	(7, 'AO', 'Angola'),
	(8, 'AI', 'Anguilla'),
	(9, 'AQ', 'Antarctica'),
	(10, 'AG', 'Antigua & Barbuda'),
	(11, 'AR', 'Argentina'),
	(12, 'AM', 'Armenia'),
	(13, 'AW', 'Aruba'),
	(14, 'AC', 'Ascension Island'),
	(15, 'AU', 'Australia'),
	(16, 'AT', 'Austria'),
	(17, 'AZ', 'Azerbaijan'),
	(18, 'BS', 'Bahamas'),
	(19, 'BH', 'Bahrain'),
	(20, 'BD', 'Bangladesh'),
	(21, 'BB', 'Barbados'),
	(22, 'BY', 'Belarus'),
	(23, 'BE', 'Belgium'),
	(24, 'BZ', 'Belize'),
	(25, 'BJ', 'Benin'),
	(26, 'BM', 'Bermuda'),
	(27, 'BT', 'Bhutan'),
	(28, 'BO', 'Bolivia'),
	(29, 'BA', 'Bosnia & Herzegovina'),
	(30, 'BW', 'Botswana'),
	(31, 'BR', 'Brazil'),
	(32, 'IO', 'British Indian Ocean Territory'),
	(33, 'VG', 'British Virgin Islands'),
	(34, 'BN', 'Brunei'),
	(35, 'BG', 'Bulgaria'),
	(36, 'BF', 'Burkina Faso'),
	(37, 'BI', 'Burundi'),
	(38, 'KH', 'Cambodia'),
	(39, 'CM', 'Cameroon'),
	(40, 'CA', 'Canada'),
	(41, 'IC', 'Canary Islands'),
	(42, 'CV', 'Cape Verde'),
	(43, 'BQ', 'Caribbean Netherlands'),
	(44, 'KY', 'Cayman Islands'),
	(45, 'CF', 'Central African Republic'),
	(46, 'EA', 'Ceuta & Melilla'),
	(47, 'TD', 'Chad'),
	(48, 'CL', 'Chile'),
	(49, 'CN', 'China'),
	(50, 'CX', 'Christmas Island'),
	(51, 'CC', 'Cocos (Keeling) Islands'),
	(52, 'CO', 'Colombia'),
	(53, 'KM', 'Comoros'),
	(54, 'CG', 'Congo - Brazzaville'),
	(55, 'CD', 'Congo - Kinshasa'),
	(56, 'CK', 'Cook Islands'),
	(57, 'CR', 'Costa Rica'),
	(58, 'CI', 'Côte d’Ivoire'),
	(59, 'HR', 'Croatia'),
	(60, 'CU', 'Cuba'),
	(61, 'CW', 'Curaçao'),
	(62, 'CY', 'Cyprus'),
	(63, 'CZ', 'Czechia'),
	(64, 'DK', 'Denmark'),
	(65, 'DG', 'Diego Garcia'),
	(66, 'DJ', 'Djibouti'),
	(67, 'DM', 'Dominica'),
	(68, 'DO', 'Dominican Republic'),
	(69, 'EC', 'Ecuador'),
	(70, 'EG', 'Egypt'),
	(71, 'SV', 'El Salvador'),
	(72, 'GQ', 'Equatorial Guinea'),
	(73, 'ER', 'Eritrea'),
	(74, 'EE', 'Estonia'),
	(75, 'ET', 'Ethiopia'),
	(76, 'EZ', 'Eurozone'),
	(77, 'FK', 'Falkland Islands'),
	(78, 'FO', 'Faroe Islands'),
	(79, 'FJ', 'Fiji'),
	(80, 'FI', 'Finland'),
	(81, 'FR', 'France'),
	(82, 'GF', 'French Guiana'),
	(83, 'PF', 'French Polynesia'),
	(84, 'TF', 'French Southern Territories'),
	(85, 'GA', 'Gabon'),
	(86, 'GM', 'Gambia'),
	(87, 'GE', 'Georgia'),
	(88, 'DE', 'Germany'),
	(89, 'GH', 'Ghana'),
	(90, 'GI', 'Gibraltar'),
	(91, 'GR', 'Greece'),
	(92, 'GL', 'Greenland'),
	(93, 'GD', 'Grenada'),
	(94, 'GP', 'Guadeloupe'),
	(95, 'GU', 'Guam'),
	(96, 'GT', 'Guatemala'),
	(97, 'GG', 'Guernsey'),
	(98, 'GN', 'Guinea'),
	(99, 'GW', 'Guinea-Bissau'),
	(100, 'GY', 'Guyana'),
	(101, 'HT', 'Haiti'),
	(102, 'HN', 'Honduras'),
	(103, 'HK', 'Hong Kong SAR China'),
	(104, 'HU', 'Hungary'),
	(105, 'IS', 'Iceland'),
	(106, 'IN', 'India'),
	(107, 'ID', 'Indonesia'),
	(108, 'IR', 'Iran'),
	(109, 'IQ', 'Iraq'),
	(110, 'IE', 'Ireland'),
	(111, 'IM', 'Isle of Man'),
	(112, 'IL', 'Israel'),
	(113, 'IT', 'Italy'),
	(114, 'JM', 'Jamaica'),
	(115, 'JP', 'Japan'),
	(116, 'JE', 'Jersey'),
	(117, 'JO', 'Jordan'),
	(118, 'KZ', 'Kazakhstan'),
	(119, 'KE', 'Kenya'),
	(120, 'KI', 'Kiribati'),
	(121, 'XK', 'Kosovo'),
	(122, 'KW', 'Kuwait'),
	(123, 'KG', 'Kyrgyzstan'),
	(124, 'LA', 'Laos'),
	(125, 'LV', 'Latvia'),
	(126, 'LB', 'Lebanon'),
	(127, 'LS', 'Lesotho'),
	(128, 'LR', 'Liberia'),
	(129, 'LY', 'Libya'),
	(130, 'LI', 'Liechtenstein'),
	(131, 'LT', 'Lithuania'),
	(132, 'LU', 'Luxembourg'),
	(133, 'MO', 'Macau SAR China'),
	(134, 'MK', 'Macedonia'),
	(135, 'MG', 'Madagascar'),
	(136, 'MW', 'Malawi'),
	(137, 'MY', 'Malaysia'),
	(138, 'MV', 'Maldives'),
	(139, 'ML', 'Mali'),
	(140, 'MT', 'Malta'),
	(141, 'MH', 'Marshall Islands'),
	(142, 'MQ', 'Martinique'),
	(143, 'MR', 'Mauritania'),
	(144, 'MU', 'Mauritius'),
	(145, 'YT', 'Mayotte'),
	(146, 'MX', 'Mexico'),
	(147, 'FM', 'Micronesia'),
	(148, 'MD', 'Moldova'),
	(149, 'MC', 'Monaco'),
	(150, 'MN', 'Mongolia'),
	(151, 'ME', 'Montenegro'),
	(152, 'MS', 'Montserrat'),
	(153, 'MA', 'Morocco'),
	(154, 'MZ', 'Mozambique'),
	(155, 'MM', 'Myanmar (Burma)'),
	(156, 'NA', 'Namibia'),
	(157, 'NR', 'Nauru'),
	(158, 'NP', 'Nepal'),
	(159, 'NL', 'Netherlands'),
	(160, 'NC', 'New Caledonia'),
	(161, 'NZ', 'New Zealand'),
	(162, 'NI', 'Nicaragua'),
	(163, 'NE', 'Niger'),
	(164, 'NG', 'Nigeria'),
	(165, 'NU', 'Niue'),
	(166, 'NF', 'Norfolk Island'),
	(167, 'KP', 'North Korea'),
	(168, 'MP', 'Northern Mariana Islands'),
	(169, 'NO', 'Norway'),
	(170, 'OM', 'Oman'),
	(171, 'PK', 'Pakistan'),
	(172, 'PW', 'Palau'),
	(173, 'PS', 'Palestinian Territories'),
	(174, 'PA', 'Panama'),
	(175, 'PG', 'Papua New Guinea'),
	(176, 'PY', 'Paraguay'),
	(177, 'PE', 'Peru'),
	(178, 'PH', 'Philippines'),
	(179, 'PN', 'Pitcairn Islands'),
	(180, 'PL', 'Poland'),
	(181, 'PT', 'Portugal'),
	(182, 'PR', 'Puerto Rico'),
	(183, 'QA', 'Qatar'),
	(184, 'RE', 'Réunion'),
	(185, 'RO', 'Romania'),
	(186, 'RU', 'Russia'),
	(187, 'RW', 'Rwanda'),
	(188, 'WS', 'Samoa'),
	(189, 'SM', 'San Marino'),
	(190, 'ST', 'São Tomé & Príncipe'),
	(191, 'SA', 'Saudi Arabia'),
	(192, 'SN', 'Senegal'),
	(193, 'RS', 'Serbia'),
	(194, 'SC', 'Seychelles'),
	(195, 'SL', 'Sierra Leone'),
	(196, 'SG', 'Singapore'),
	(197, 'SX', 'Sint Maarten'),
	(198, 'SK', 'Slovakia'),
	(199, 'SI', 'Slovenia'),
	(200, 'SB', 'Solomon Islands');
INSERT INTO public.countries (id, code, name) VALUES
	(201, 'SO', 'Somalia'),
	(202, 'ZA', 'South Africa'),
	(203, 'GS', 'South Georgia & South Sandwich Islands'),
	(204, 'KR', 'South Korea'),
	(205, 'SS', 'South Sudan'),
	(206, 'ES', 'Spain'),
	(207, 'LK', 'Sri Lanka'),
	(208, 'BL', 'St. Barthélemy'),
	(209, 'SH', 'St. Helena'),
	(210, 'KN', 'St. Kitts & Nevis'),
	(211, 'LC', 'St. Lucia'),
	(212, 'MF', 'St. Martin'),
	(213, 'PM', 'St. Pierre & Miquelon'),
	(214, 'VC', 'St. Vincent & Grenadines'),
	(215, 'SD', 'Sudan'),
	(216, 'SR', 'Suriname'),
	(217, 'SJ', 'Svalbard & Jan Mayen'),
	(218, 'SZ', 'Swaziland'),
	(219, 'SE', 'Sweden'),
	(220, 'CH', 'Switzerland'),
	(221, 'SY', 'Syria'),
	(222, 'TW', 'Taiwan'),
	(223, 'TJ', 'Tajikistan'),
	(224, 'TZ', 'Tanzania'),
	(225, 'TH', 'Thailand'),
	(226, 'TL', 'Timor-Leste'),
	(227, 'TG', 'Togo'),
	(228, 'TK', 'Tokelau'),
	(229, 'TO', 'Tonga'),
	(230, 'TT', 'Trinidad & Tobago'),
	(231, 'TA', 'Tristan da Cunha'),
	(232, 'TN', 'Tunisia'),
	(233, 'TR', 'Turkey'),
	(234, 'TM', 'Turkmenistan'),
	(235, 'TC', 'Turks & Caicos Islands'),
	(236, 'TV', 'Tuvalu'),
	(237, 'UM', 'U.S. Outlying Islands'),
	(238, 'VI', 'U.S. Virgin Islands'),
	(239, 'UG', 'Uganda'),
	(240, 'UA', 'Ukraine'),
	(241, 'AE', 'United Arab Emirates'),
	(242, 'GB', 'United Kingdom'),
	(244, 'US', 'United States'),
	(245, 'UY', 'Uruguay'),
	(246, 'UZ', 'Uzbekistan'),
	(247, 'VU', 'Vanuatu'),
	(248, 'VA', 'Vatican City'),
	(249, 'VE', 'Venezuela'),
	(250, 'VN', 'Vietnam'),
	(251, 'WF', 'Wallis & Futuna'),
	(252, 'EH', 'Western Sahara'),
	(253, 'YE', 'Yemen'),
	(254, 'ZM', 'Zambia'),
	(255, 'ZW', 'Zimbabwe');


--
-- Data for Name: country_states; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.country_states (id, country_id, country_code, code, default_name) VALUES
	(1, 244, 'US', 'AL', 'Alabama'),
	(2, 244, 'US', 'AK', 'Alaska'),
	(3, 244, 'US', 'AS', 'American Samoa'),
	(4, 244, 'US', 'AZ', 'Arizona'),
	(5, 244, 'US', 'AR', 'Arkansas'),
	(6, 244, 'US', 'AE', 'Armed Forces Africa'),
	(7, 244, 'US', 'AA', 'Armed Forces Americas'),
	(8, 244, 'US', 'AE', 'Armed Forces Canada'),
	(9, 244, 'US', 'AE', 'Armed Forces Europe'),
	(10, 244, 'US', 'AE', 'Armed Forces Middle East'),
	(11, 244, 'US', 'AP', 'Armed Forces Pacific'),
	(12, 244, 'US', 'CA', 'California'),
	(13, 244, 'US', 'CO', 'Colorado'),
	(14, 244, 'US', 'CT', 'Connecticut'),
	(15, 244, 'US', 'DE', 'Delaware'),
	(16, 244, 'US', 'DC', 'District of Columbia'),
	(17, 244, 'US', 'FM', 'Federated States Of Micronesia'),
	(18, 244, 'US', 'FL', 'Florida'),
	(19, 244, 'US', 'GA', 'Georgia'),
	(20, 244, 'US', 'GU', 'Guam'),
	(21, 244, 'US', 'HI', 'Hawaii'),
	(22, 244, 'US', 'ID', 'Idaho'),
	(23, 244, 'US', 'IL', 'Illinois'),
	(24, 244, 'US', 'IN', 'Indiana'),
	(25, 244, 'US', 'IA', 'Iowa'),
	(26, 244, 'US', 'KS', 'Kansas'),
	(27, 244, 'US', 'KY', 'Kentucky'),
	(28, 244, 'US', 'LA', 'Louisiana'),
	(29, 244, 'US', 'ME', 'Maine'),
	(30, 244, 'US', 'MH', 'Marshall Islands'),
	(31, 244, 'US', 'MD', 'Maryland'),
	(32, 244, 'US', 'MA', 'Massachusetts'),
	(33, 244, 'US', 'MI', 'Michigan'),
	(34, 244, 'US', 'MN', 'Minnesota'),
	(35, 244, 'US', 'MS', 'Mississippi'),
	(36, 244, 'US', 'MO', 'Missouri'),
	(37, 244, 'US', 'MT', 'Montana'),
	(38, 244, 'US', 'NE', 'Nebraska'),
	(39, 244, 'US', 'NV', 'Nevada'),
	(40, 244, 'US', 'NH', 'New Hampshire'),
	(41, 244, 'US', 'NJ', 'New Jersey'),
	(42, 244, 'US', 'NM', 'New Mexico'),
	(43, 244, 'US', 'NY', 'New York'),
	(44, 244, 'US', 'NC', 'North Carolina'),
	(45, 244, 'US', 'ND', 'North Dakota'),
	(46, 244, 'US', 'MP', 'Northern Mariana Islands'),
	(47, 244, 'US', 'OH', 'Ohio'),
	(48, 244, 'US', 'OK', 'Oklahoma'),
	(49, 244, 'US', 'OR', 'Oregon'),
	(50, 244, 'US', 'PW', 'Palau'),
	(51, 244, 'US', 'PA', 'Pennsylvania'),
	(52, 244, 'US', 'PR', 'Puerto Rico'),
	(53, 244, 'US', 'RI', 'Rhode Island'),
	(54, 244, 'US', 'SC', 'South Carolina'),
	(55, 244, 'US', 'SD', 'South Dakota'),
	(56, 244, 'US', 'TN', 'Tennessee'),
	(57, 244, 'US', 'TX', 'Texas'),
	(58, 244, 'US', 'UT', 'Utah'),
	(59, 244, 'US', 'VT', 'Vermont'),
	(60, 244, 'US', 'VI', 'Virgin Islands'),
	(61, 244, 'US', 'VA', 'Virginia'),
	(62, 244, 'US', 'WA', 'Washington'),
	(63, 244, 'US', 'WV', 'West Virginia'),
	(64, 244, 'US', 'WI', 'Wisconsin'),
	(65, 244, 'US', 'WY', 'Wyoming'),
	(66, 40, 'CA', 'AB', 'Alberta'),
	(67, 40, 'CA', 'BC', 'British Columbia'),
	(68, 40, 'CA', 'MB', 'Manitoba'),
	(69, 40, 'CA', 'NL', 'Newfoundland and Labrador'),
	(70, 40, 'CA', 'NB', 'New Brunswick'),
	(71, 40, 'CA', 'NS', 'Nova Scotia'),
	(72, 40, 'CA', 'NT', 'Northwest Territories'),
	(73, 40, 'CA', 'NU', 'Nunavut'),
	(74, 40, 'CA', 'ON', 'Ontario'),
	(75, 40, 'CA', 'PE', 'Prince Edward Island'),
	(76, 40, 'CA', 'QC', 'Quebec'),
	(77, 40, 'CA', 'SK', 'Saskatchewan'),
	(78, 40, 'CA', 'YT', 'Yukon Territory'),
	(79, 88, 'DE', 'NDS', 'Niedersachsen'),
	(80, 88, 'DE', 'BAW', 'Baden-Württemberg'),
	(81, 88, 'DE', 'BAY', 'Bayern'),
	(82, 88, 'DE', 'BER', 'Berlin'),
	(83, 88, 'DE', 'BRG', 'Brandenburg'),
	(84, 88, 'DE', 'BRE', 'Bremen'),
	(85, 88, 'DE', 'HAM', 'Hamburg'),
	(86, 88, 'DE', 'HES', 'Hessen'),
	(87, 88, 'DE', 'MEC', 'Mecklenburg-Vorpommern'),
	(88, 88, 'DE', 'NRW', 'Nordrhein-Westfalen'),
	(89, 88, 'DE', 'RHE', 'Rheinland-Pfalz'),
	(90, 88, 'DE', 'SAR', 'Saarland'),
	(91, 88, 'DE', 'SAS', 'Sachsen'),
	(92, 88, 'DE', 'SAC', 'Sachsen-Anhalt'),
	(93, 88, 'DE', 'SCN', 'Schleswig-Holstein'),
	(94, 88, 'DE', 'THE', 'Thüringen'),
	(95, 16, 'AT', 'WI', 'Wien'),
	(96, 16, 'AT', 'NO', 'Niederösterreich'),
	(97, 16, 'AT', 'OO', 'Oberösterreich'),
	(98, 16, 'AT', 'SB', 'Salzburg'),
	(99, 16, 'AT', 'KN', 'Kärnten'),
	(100, 16, 'AT', 'ST', 'Steiermark'),
	(101, 16, 'AT', 'TI', 'Tirol'),
	(102, 16, 'AT', 'BL', 'Burgenland'),
	(103, 16, 'AT', 'VB', 'Vorarlberg'),
	(104, 220, 'CH', 'AG', 'Aargau'),
	(105, 220, 'CH', 'AI', 'Appenzell Innerrhoden'),
	(106, 220, 'CH', 'AR', 'Appenzell Ausserrhoden'),
	(107, 220, 'CH', 'BE', 'Bern'),
	(108, 220, 'CH', 'BL', 'Basel-Landschaft'),
	(109, 220, 'CH', 'BS', 'Basel-Stadt'),
	(110, 220, 'CH', 'FR', 'Freiburg'),
	(111, 220, 'CH', 'GE', 'Genf'),
	(112, 220, 'CH', 'GL', 'Glarus'),
	(113, 220, 'CH', 'GR', 'Graubünden'),
	(114, 220, 'CH', 'JU', 'Jura'),
	(115, 220, 'CH', 'LU', 'Luzern'),
	(116, 220, 'CH', 'NE', 'Neuenburg'),
	(117, 220, 'CH', 'NW', 'Nidwalden'),
	(118, 220, 'CH', 'OW', 'Obwalden'),
	(119, 220, 'CH', 'SG', 'St. Gallen'),
	(120, 220, 'CH', 'SH', 'Schaffhausen'),
	(121, 220, 'CH', 'SO', 'Solothurn'),
	(122, 220, 'CH', 'SZ', 'Schwyz'),
	(123, 220, 'CH', 'TG', 'Thurgau'),
	(124, 220, 'CH', 'TI', 'Tessin'),
	(125, 220, 'CH', 'UR', 'Uri'),
	(126, 220, 'CH', 'VD', 'Waadt'),
	(127, 220, 'CH', 'VS', 'Wallis'),
	(128, 220, 'CH', 'ZG', 'Zug'),
	(129, 220, 'CH', 'ZH', 'Zürich'),
	(130, 206, 'ES', 'A Coruсa', 'A Coruña'),
	(131, 206, 'ES', 'Alava', 'Alava'),
	(132, 206, 'ES', 'Albacete', 'Albacete'),
	(133, 206, 'ES', 'Alicante', 'Alicante'),
	(134, 206, 'ES', 'Almeria', 'Almeria'),
	(135, 206, 'ES', 'Asturias', 'Asturias'),
	(136, 206, 'ES', 'Avila', 'Avila'),
	(137, 206, 'ES', 'Badajoz', 'Badajoz'),
	(138, 206, 'ES', 'Baleares', 'Baleares'),
	(139, 206, 'ES', 'Barcelona', 'Barcelona'),
	(140, 206, 'ES', 'Burgos', 'Burgos'),
	(141, 206, 'ES', 'Caceres', 'Caceres'),
	(142, 206, 'ES', 'Cadiz', 'Cadiz'),
	(143, 206, 'ES', 'Cantabria', 'Cantabria'),
	(144, 206, 'ES', 'Castellon', 'Castellon'),
	(145, 206, 'ES', 'Ceuta', 'Ceuta'),
	(146, 206, 'ES', 'Ciudad Real', 'Ciudad Real'),
	(147, 206, 'ES', 'Cordoba', 'Cordoba'),
	(148, 206, 'ES', 'Cuenca', 'Cuenca'),
	(149, 206, 'ES', 'Girona', 'Girona'),
	(150, 206, 'ES', 'Granada', 'Granada'),
	(151, 206, 'ES', 'Guadalajara', 'Guadalajara'),
	(152, 206, 'ES', 'Guipuzcoa', 'Guipuzcoa'),
	(153, 206, 'ES', 'Huelva', 'Huelva'),
	(154, 206, 'ES', 'Huesca', 'Huesca'),
	(155, 206, 'ES', 'Jaen', 'Jaen'),
	(156, 206, 'ES', 'La Rioja', 'La Rioja'),
	(157, 206, 'ES', 'Las Palmas', 'Las Palmas'),
	(158, 206, 'ES', 'Leon', 'Leon'),
	(159, 206, 'ES', 'Lleida', 'Lleida'),
	(160, 206, 'ES', 'Lugo', 'Lugo'),
	(161, 206, 'ES', 'Madrid', 'Madrid'),
	(162, 206, 'ES', 'Malaga', 'Malaga'),
	(163, 206, 'ES', 'Melilla', 'Melilla'),
	(164, 206, 'ES', 'Murcia', 'Murcia'),
	(165, 206, 'ES', 'Navarra', 'Navarra'),
	(166, 206, 'ES', 'Ourense', 'Ourense'),
	(167, 206, 'ES', 'Palencia', 'Palencia'),
	(168, 206, 'ES', 'Pontevedra', 'Pontevedra'),
	(169, 206, 'ES', 'Salamanca', 'Salamanca'),
	(170, 206, 'ES', 'Santa Cruz de Tenerife', 'Santa Cruz de Tenerife'),
	(171, 206, 'ES', 'Segovia', 'Segovia'),
	(172, 206, 'ES', 'Sevilla', 'Sevilla'),
	(173, 206, 'ES', 'Soria', 'Soria'),
	(174, 206, 'ES', 'Tarragona', 'Tarragona'),
	(175, 206, 'ES', 'Teruel', 'Teruel'),
	(176, 206, 'ES', 'Toledo', 'Toledo'),
	(177, 206, 'ES', 'Valencia', 'Valencia'),
	(178, 206, 'ES', 'Valladolid', 'Valladolid'),
	(179, 206, 'ES', 'Vizcaya', 'Vizcaya'),
	(180, 206, 'ES', 'Zamora', 'Zamora'),
	(181, 206, 'ES', 'Zaragoza', 'Zaragoza'),
	(182, 81, 'FR', '1', 'Ain'),
	(183, 81, 'FR', '2', 'Aisne'),
	(184, 81, 'FR', '3', 'Allier'),
	(185, 81, 'FR', '4', 'Alpes-de-Haute-Provence'),
	(186, 81, 'FR', '5', 'Hautes-Alpes'),
	(187, 81, 'FR', '6', 'Alpes-Maritimes'),
	(188, 81, 'FR', '7', 'Ardèche'),
	(189, 81, 'FR', '8', 'Ardennes'),
	(190, 81, 'FR', '9', 'Ariège'),
	(191, 81, 'FR', '10', 'Aube'),
	(192, 81, 'FR', '11', 'Aude'),
	(193, 81, 'FR', '12', 'Aveyron'),
	(194, 81, 'FR', '13', 'Bouches-du-Rhône'),
	(195, 81, 'FR', '14', 'Calvados'),
	(196, 81, 'FR', '15', 'Cantal'),
	(197, 81, 'FR', '16', 'Charente'),
	(198, 81, 'FR', '17', 'Charente-Maritime'),
	(199, 81, 'FR', '18', 'Cher'),
	(200, 81, 'FR', '19', 'Corrèze');
INSERT INTO public.country_states (id, country_id, country_code, code, default_name) VALUES
	(201, 81, 'FR', '2A', 'Corse-du-Sud'),
	(202, 81, 'FR', '2B', 'Haute-Corse'),
	(203, 81, 'FR', '21', 'Côte-d''Or'),
	(204, 81, 'FR', '22', 'Côtes-d''Armor'),
	(205, 81, 'FR', '23', 'Creuse'),
	(206, 81, 'FR', '24', 'Dordogne'),
	(207, 81, 'FR', '25', 'Doubs'),
	(208, 81, 'FR', '26', 'Drôme'),
	(209, 81, 'FR', '27', 'Eure'),
	(210, 81, 'FR', '28', 'Eure-et-Loir'),
	(211, 81, 'FR', '29', 'Finistère'),
	(212, 81, 'FR', '30', 'Gard'),
	(213, 81, 'FR', '31', 'Haute-Garonne'),
	(214, 81, 'FR', '32', 'Gers'),
	(215, 81, 'FR', '33', 'Gironde'),
	(216, 81, 'FR', '34', 'Hérault'),
	(217, 81, 'FR', '35', 'Ille-et-Vilaine'),
	(218, 81, 'FR', '36', 'Indre'),
	(219, 81, 'FR', '37', 'Indre-et-Loire'),
	(220, 81, 'FR', '38', 'Isère'),
	(221, 81, 'FR', '39', 'Jura'),
	(222, 81, 'FR', '40', 'Landes'),
	(223, 81, 'FR', '41', 'Loir-et-Cher'),
	(224, 81, 'FR', '42', 'Loire'),
	(225, 81, 'FR', '43', 'Haute-Loire'),
	(226, 81, 'FR', '44', 'Loire-Atlantique'),
	(227, 81, 'FR', '45', 'Loiret'),
	(228, 81, 'FR', '46', 'Lot'),
	(229, 81, 'FR', '47', 'Lot-et-Garonne'),
	(230, 81, 'FR', '48', 'Lozère'),
	(231, 81, 'FR', '49', 'Maine-et-Loire'),
	(232, 81, 'FR', '50', 'Manche'),
	(233, 81, 'FR', '51', 'Marne'),
	(234, 81, 'FR', '52', 'Haute-Marne'),
	(235, 81, 'FR', '53', 'Mayenne'),
	(236, 81, 'FR', '54', 'Meurthe-et-Moselle'),
	(237, 81, 'FR', '55', 'Meuse'),
	(238, 81, 'FR', '56', 'Morbihan'),
	(239, 81, 'FR', '57', 'Moselle'),
	(240, 81, 'FR', '58', 'Nièvre'),
	(241, 81, 'FR', '59', 'Nord'),
	(242, 81, 'FR', '60', 'Oise'),
	(243, 81, 'FR', '61', 'Orne'),
	(244, 81, 'FR', '62', 'Pas-de-Calais'),
	(245, 81, 'FR', '63', 'Puy-de-Dôme'),
	(246, 81, 'FR', '64', 'Pyrénées-Atlantiques'),
	(247, 81, 'FR', '65', 'Hautes-Pyrénées'),
	(248, 81, 'FR', '66', 'Pyrénées-Orientales'),
	(249, 81, 'FR', '67', 'Bas-Rhin'),
	(250, 81, 'FR', '68', 'Haut-Rhin'),
	(251, 81, 'FR', '69', 'Rhône'),
	(252, 81, 'FR', '70', 'Haute-Saône'),
	(253, 81, 'FR', '71', 'Saône-et-Loire'),
	(254, 81, 'FR', '72', 'Sarthe'),
	(255, 81, 'FR', '73', 'Savoie'),
	(256, 81, 'FR', '74', 'Haute-Savoie'),
	(257, 81, 'FR', '75', 'Paris'),
	(258, 81, 'FR', '76', 'Seine-Maritime'),
	(259, 81, 'FR', '77', 'Seine-et-Marne'),
	(260, 81, 'FR', '78', 'Yvelines'),
	(261, 81, 'FR', '79', 'Deux-Sèvres'),
	(262, 81, 'FR', '80', 'Somme'),
	(263, 81, 'FR', '81', 'Tarn'),
	(264, 81, 'FR', '82', 'Tarn-et-Garonne'),
	(265, 81, 'FR', '83', 'Var'),
	(266, 81, 'FR', '84', 'Vaucluse'),
	(267, 81, 'FR', '85', 'Vendée'),
	(268, 81, 'FR', '86', 'Vienne'),
	(269, 81, 'FR', '87', 'Haute-Vienne'),
	(270, 81, 'FR', '88', 'Vosges'),
	(271, 81, 'FR', '89', 'Yonne'),
	(272, 81, 'FR', '90', 'Territoire-de-Belfort'),
	(273, 81, 'FR', '91', 'Essonne'),
	(274, 81, 'FR', '92', 'Hauts-de-Seine'),
	(275, 81, 'FR', '93', 'Seine-Saint-Denis'),
	(276, 81, 'FR', '94', 'Val-de-Marne'),
	(277, 81, 'FR', '95', 'Val-d''Oise'),
	(278, 185, 'RO', 'AB', 'Alba'),
	(279, 185, 'RO', 'AR', 'Arad'),
	(280, 185, 'RO', 'AG', 'Argeş'),
	(281, 185, 'RO', 'BC', 'Bacău'),
	(282, 185, 'RO', 'BH', 'Bihor'),
	(283, 185, 'RO', 'BN', 'Bistriţa-Năsăud'),
	(284, 185, 'RO', 'BT', 'Botoşani'),
	(285, 185, 'RO', 'BV', 'Braşov'),
	(286, 185, 'RO', 'BR', 'Brăila'),
	(287, 185, 'RO', 'B', 'Bucureşti'),
	(288, 185, 'RO', 'BZ', 'Buzău'),
	(289, 185, 'RO', 'CS', 'Caraş-Severin'),
	(290, 185, 'RO', 'CL', 'Călăraşi'),
	(291, 185, 'RO', 'CJ', 'Cluj'),
	(292, 185, 'RO', 'CT', 'Constanţa'),
	(293, 185, 'RO', 'CV', 'Covasna'),
	(294, 185, 'RO', 'DB', 'Dâmboviţa'),
	(295, 185, 'RO', 'DJ', 'Dolj'),
	(296, 185, 'RO', 'GL', 'Galaţi'),
	(297, 185, 'RO', 'GR', 'Giurgiu'),
	(298, 185, 'RO', 'GJ', 'Gorj'),
	(299, 185, 'RO', 'HR', 'Harghita'),
	(300, 185, 'RO', 'HD', 'Hunedoara'),
	(301, 185, 'RO', 'IL', 'Ialomiţa'),
	(302, 185, 'RO', 'IS', 'Iaşi'),
	(303, 185, 'RO', 'IF', 'Ilfov'),
	(304, 185, 'RO', 'MM', 'Maramureş'),
	(305, 185, 'RO', 'MH', 'Mehedinţi'),
	(306, 185, 'RO', 'MS', 'Mureş'),
	(307, 185, 'RO', 'NT', 'Neamţ'),
	(308, 185, 'RO', 'OT', 'Olt'),
	(309, 185, 'RO', 'PH', 'Prahova'),
	(310, 185, 'RO', 'SM', 'Satu-Mare'),
	(311, 185, 'RO', 'SJ', 'Sălaj'),
	(312, 185, 'RO', 'SB', 'Sibiu'),
	(313, 185, 'RO', 'SV', 'Suceava'),
	(314, 185, 'RO', 'TR', 'Teleorman'),
	(315, 185, 'RO', 'TM', 'Timiş'),
	(316, 185, 'RO', 'TL', 'Tulcea'),
	(317, 185, 'RO', 'VS', 'Vaslui'),
	(318, 185, 'RO', 'VL', 'Vâlcea'),
	(319, 185, 'RO', 'VN', 'Vrancea'),
	(320, 80, 'FI', 'Lappi', 'Lappi'),
	(321, 80, 'FI', 'Pohjois-Pohjanmaa', 'Pohjois-Pohjanmaa'),
	(322, 80, 'FI', 'Kainuu', 'Kainuu'),
	(323, 80, 'FI', 'Pohjois-Karjala', 'Pohjois-Karjala'),
	(324, 80, 'FI', 'Pohjois-Savo', 'Pohjois-Savo'),
	(325, 80, 'FI', 'Etelä-Savo', 'Etelä-Savo'),
	(326, 80, 'FI', 'Etelä-Pohjanmaa', 'Etelä-Pohjanmaa'),
	(327, 80, 'FI', 'Pohjanmaa', 'Pohjanmaa'),
	(328, 80, 'FI', 'Pirkanmaa', 'Pirkanmaa'),
	(329, 80, 'FI', 'Satakunta', 'Satakunta'),
	(330, 80, 'FI', 'Keski-Pohjanmaa', 'Keski-Pohjanmaa'),
	(331, 80, 'FI', 'Keski-Suomi', 'Keski-Suomi'),
	(332, 80, 'FI', 'Varsinais-Suomi', 'Varsinais-Suomi'),
	(333, 80, 'FI', 'Etelä-Karjala', 'Etelä-Karjala'),
	(334, 80, 'FI', 'Päijät-Häme', 'Päijät-Häme'),
	(335, 80, 'FI', 'Kanta-Häme', 'Kanta-Häme'),
	(336, 80, 'FI', 'Uusimaa', 'Uusimaa'),
	(337, 80, 'FI', 'Itä-Uusimaa', 'Itä-Uusimaa'),
	(338, 80, 'FI', 'Kymenlaakso', 'Kymenlaakso'),
	(339, 80, 'FI', 'Ahvenanmaa', 'Ahvenanmaa'),
	(340, 74, 'EE', 'EE-37', 'Harjumaa'),
	(341, 74, 'EE', 'EE-39', 'Hiiumaa'),
	(342, 74, 'EE', 'EE-44', 'Ida-Virumaa'),
	(343, 74, 'EE', 'EE-49', 'Jõgevamaa'),
	(344, 74, 'EE', 'EE-51', 'Järvamaa'),
	(345, 74, 'EE', 'EE-57', 'Läänemaa'),
	(346, 74, 'EE', 'EE-59', 'Lääne-Virumaa'),
	(347, 74, 'EE', 'EE-65', 'Põlvamaa'),
	(348, 74, 'EE', 'EE-67', 'Pärnumaa'),
	(349, 74, 'EE', 'EE-70', 'Raplamaa'),
	(350, 74, 'EE', 'EE-74', 'Saaremaa'),
	(351, 74, 'EE', 'EE-78', 'Tartumaa'),
	(352, 74, 'EE', 'EE-82', 'Valgamaa'),
	(353, 74, 'EE', 'EE-84', 'Viljandimaa'),
	(354, 74, 'EE', 'EE-86', 'Võrumaa'),
	(355, 125, 'LV', 'LV-DGV', 'Daugavpils'),
	(356, 125, 'LV', 'LV-JEL', 'Jelgava'),
	(357, 125, 'LV', 'Jēkabpils', 'Jēkabpils'),
	(358, 125, 'LV', 'LV-JUR', 'Jūrmala'),
	(359, 125, 'LV', 'LV-LPX', 'Liepāja'),
	(360, 125, 'LV', 'LV-LE', 'Liepājas novads'),
	(361, 125, 'LV', 'LV-REZ', 'Rēzekne'),
	(362, 125, 'LV', 'LV-RIX', 'Rīga'),
	(363, 125, 'LV', 'LV-RI', 'Rīgas novads'),
	(364, 125, 'LV', 'Valmiera', 'Valmiera'),
	(365, 125, 'LV', 'LV-VEN', 'Ventspils'),
	(366, 125, 'LV', 'Aglonas novads', 'Aglonas novads'),
	(367, 125, 'LV', 'LV-AI', 'Aizkraukles novads'),
	(368, 125, 'LV', 'Aizputes novads', 'Aizputes novads'),
	(369, 125, 'LV', 'Aknīstes novads', 'Aknīstes novads'),
	(370, 125, 'LV', 'Alojas novads', 'Alojas novads'),
	(371, 125, 'LV', 'Alsungas novads', 'Alsungas novads'),
	(372, 125, 'LV', 'LV-AL', 'Alūksnes novads'),
	(373, 125, 'LV', 'Amatas novads', 'Amatas novads'),
	(374, 125, 'LV', 'Apes novads', 'Apes novads'),
	(375, 125, 'LV', 'Auces novads', 'Auces novads'),
	(376, 125, 'LV', 'Babītes novads', 'Babītes novads'),
	(377, 125, 'LV', 'Baldones novads', 'Baldones novads'),
	(378, 125, 'LV', 'Baltinavas novads', 'Baltinavas novads'),
	(379, 125, 'LV', 'LV-BL', 'Balvu novads'),
	(380, 125, 'LV', 'LV-BU', 'Bauskas novads'),
	(381, 125, 'LV', 'Beverīnas novads', 'Beverīnas novads'),
	(382, 125, 'LV', 'Brocēnu novads', 'Brocēnu novads'),
	(383, 125, 'LV', 'Burtnieku novads', 'Burtnieku novads'),
	(384, 125, 'LV', 'Carnikavas novads', 'Carnikavas novads'),
	(385, 125, 'LV', 'Cesvaines novads', 'Cesvaines novads'),
	(386, 125, 'LV', 'Ciblas novads', 'Ciblas novads'),
	(387, 125, 'LV', 'LV-CE', 'Cēsu novads'),
	(388, 125, 'LV', 'Dagdas novads', 'Dagdas novads'),
	(389, 125, 'LV', 'LV-DA', 'Daugavpils novads'),
	(390, 125, 'LV', 'LV-DO', 'Dobeles novads'),
	(391, 125, 'LV', 'Dundagas novads', 'Dundagas novads'),
	(392, 125, 'LV', 'Durbes novads', 'Durbes novads'),
	(393, 125, 'LV', 'Engures novads', 'Engures novads'),
	(394, 125, 'LV', 'Garkalnes novads', 'Garkalnes novads'),
	(395, 125, 'LV', 'Grobiņas novads', 'Grobiņas novads'),
	(396, 125, 'LV', 'LV-GU', 'Gulbenes novads'),
	(397, 125, 'LV', 'Iecavas novads', 'Iecavas novads'),
	(398, 125, 'LV', 'Ikšķiles novads', 'Ikšķiles novads'),
	(399, 125, 'LV', 'Ilūkstes novads', 'Ilūkstes novads'),
	(400, 125, 'LV', 'Inčukalna novads', 'Inčukalna novads');
INSERT INTO public.country_states (id, country_id, country_code, code, default_name) VALUES
	(401, 125, 'LV', 'Jaunjelgavas novads', 'Jaunjelgavas novads'),
	(402, 125, 'LV', 'Jaunpiebalgas novads', 'Jaunpiebalgas novads'),
	(403, 125, 'LV', 'Jaunpils novads', 'Jaunpils novads'),
	(404, 125, 'LV', 'LV-JL', 'Jelgavas novads'),
	(405, 125, 'LV', 'LV-JK', 'Jēkabpils novads'),
	(406, 125, 'LV', 'Kandavas novads', 'Kandavas novads'),
	(407, 125, 'LV', 'Kokneses novads', 'Kokneses novads'),
	(408, 125, 'LV', 'Krimuldas novads', 'Krimuldas novads'),
	(409, 125, 'LV', 'Krustpils novads', 'Krustpils novads'),
	(410, 125, 'LV', 'LV-KR', 'Krāslavas novads'),
	(411, 125, 'LV', 'LV-KU', 'Kuldīgas novads'),
	(412, 125, 'LV', 'Kārsavas novads', 'Kārsavas novads'),
	(413, 125, 'LV', 'Lielvārdes novads', 'Lielvārdes novads'),
	(414, 125, 'LV', 'LV-LM', 'Limbažu novads'),
	(415, 125, 'LV', 'Lubānas novads', 'Lubānas novads'),
	(416, 125, 'LV', 'LV-LU', 'Ludzas novads'),
	(417, 125, 'LV', 'Līgatnes novads', 'Līgatnes novads'),
	(418, 125, 'LV', 'Līvānu novads', 'Līvānu novads'),
	(419, 125, 'LV', 'LV-MA', 'Madonas novads'),
	(420, 125, 'LV', 'Mazsalacas novads', 'Mazsalacas novads'),
	(421, 125, 'LV', 'Mālpils novads', 'Mālpils novads'),
	(422, 125, 'LV', 'Mārupes novads', 'Mārupes novads'),
	(423, 125, 'LV', 'Naukšēnu novads', 'Naukšēnu novads'),
	(424, 125, 'LV', 'Neretas novads', 'Neretas novads'),
	(425, 125, 'LV', 'Nīcas novads', 'Nīcas novads'),
	(426, 125, 'LV', 'LV-OG', 'Ogres novads'),
	(427, 125, 'LV', 'Olaines novads', 'Olaines novads'),
	(428, 125, 'LV', 'Ozolnieku novads', 'Ozolnieku novads'),
	(429, 125, 'LV', 'LV-PR', 'Preiļu novads'),
	(430, 125, 'LV', 'Priekules novads', 'Priekules novads'),
	(431, 125, 'LV', 'Priekuļu novads', 'Priekuļu novads'),
	(432, 125, 'LV', 'Pārgaujas novads', 'Pārgaujas novads'),
	(433, 125, 'LV', 'Pāvilostas novads', 'Pāvilostas novads'),
	(434, 125, 'LV', 'Pļaviņu novads', 'Pļaviņu novads'),
	(435, 125, 'LV', 'Raunas novads', 'Raunas novads'),
	(436, 125, 'LV', 'Riebiņu novads', 'Riebiņu novads'),
	(437, 125, 'LV', 'Rojas novads', 'Rojas novads'),
	(438, 125, 'LV', 'Ropažu novads', 'Ropažu novads'),
	(439, 125, 'LV', 'Rucavas novads', 'Rucavas novads'),
	(440, 125, 'LV', 'Rugāju novads', 'Rugāju novads'),
	(441, 125, 'LV', 'Rundāles novads', 'Rundāles novads'),
	(442, 125, 'LV', 'LV-RE', 'Rēzeknes novads'),
	(443, 125, 'LV', 'Rūjienas novads', 'Rūjienas novads'),
	(444, 125, 'LV', 'Salacgrīvas novads', 'Salacgrīvas novads'),
	(445, 125, 'LV', 'Salas novads', 'Salas novads'),
	(446, 125, 'LV', 'Salaspils novads', 'Salaspils novads'),
	(447, 125, 'LV', 'LV-SA', 'Saldus novads'),
	(448, 125, 'LV', 'Saulkrastu novads', 'Saulkrastu novads'),
	(449, 125, 'LV', 'Siguldas novads', 'Siguldas novads'),
	(450, 125, 'LV', 'Skrundas novads', 'Skrundas novads'),
	(451, 125, 'LV', 'Skrīveru novads', 'Skrīveru novads'),
	(452, 125, 'LV', 'Smiltenes novads', 'Smiltenes novads'),
	(453, 125, 'LV', 'Stopiņu novads', 'Stopiņu novads'),
	(454, 125, 'LV', 'Strenču novads', 'Strenču novads'),
	(455, 125, 'LV', 'Sējas novads', 'Sējas novads'),
	(456, 125, 'LV', 'LV-TA', 'Talsu novads'),
	(457, 125, 'LV', 'LV-TU', 'Tukuma novads'),
	(458, 125, 'LV', 'Tērvetes novads', 'Tērvetes novads'),
	(459, 125, 'LV', 'Vaiņodes novads', 'Vaiņodes novads'),
	(460, 125, 'LV', 'LV-VK', 'Valkas novads'),
	(461, 125, 'LV', 'LV-VM', 'Valmieras novads'),
	(462, 125, 'LV', 'Varakļānu novads', 'Varakļānu novads'),
	(463, 125, 'LV', 'Vecpiebalgas novads', 'Vecpiebalgas novads'),
	(464, 125, 'LV', 'Vecumnieku novads', 'Vecumnieku novads'),
	(465, 125, 'LV', 'LV-VE', 'Ventspils novads'),
	(466, 125, 'LV', 'Viesītes novads', 'Viesītes novads'),
	(467, 125, 'LV', 'Viļakas novads', 'Viļakas novads'),
	(468, 125, 'LV', 'Viļānu novads', 'Viļānu novads'),
	(469, 125, 'LV', 'Vārkavas novads', 'Vārkavas novads'),
	(470, 125, 'LV', 'Zilupes novads', 'Zilupes novads'),
	(471, 125, 'LV', 'Ādažu novads', 'Ādažu novads'),
	(472, 125, 'LV', 'Ērgļu novads', 'Ērgļu novads'),
	(473, 125, 'LV', 'Ķeguma novads', 'Ķeguma novads'),
	(474, 125, 'LV', 'Ķekavas novads', 'Ķekavas novads'),
	(475, 131, 'LT', 'LT-AL', 'Alytaus Apskritis'),
	(476, 131, 'LT', 'LT-KU', 'Kauno Apskritis'),
	(477, 131, 'LT', 'LT-KL', 'Klaipėdos Apskritis'),
	(478, 131, 'LT', 'LT-MR', 'Marijampolės Apskritis'),
	(479, 131, 'LT', 'LT-PN', 'Panevėžio Apskritis'),
	(480, 131, 'LT', 'LT-SA', 'Šiaulių Apskritis'),
	(481, 131, 'LT', 'LT-TA', 'Tauragės Apskritis'),
	(482, 131, 'LT', 'LT-TE', 'Telšių Apskritis'),
	(483, 131, 'LT', 'LT-UT', 'Utenos Apskritis'),
	(484, 131, 'LT', 'LT-VL', 'Vilniaus Apskritis'),
	(485, 31, 'BR', 'AC', 'Acre'),
	(486, 31, 'BR', 'AL', 'Alagoas'),
	(487, 31, 'BR', 'AP', 'Amapá'),
	(488, 31, 'BR', 'AM', 'Amazonas'),
	(489, 31, 'BR', 'BA', 'Bahia'),
	(490, 31, 'BR', 'CE', 'Ceará'),
	(491, 31, 'BR', 'ES', 'Espírito Santo'),
	(492, 31, 'BR', 'GO', 'Goiás'),
	(493, 31, 'BR', 'MA', 'Maranhão'),
	(494, 31, 'BR', 'MT', 'Mato Grosso'),
	(495, 31, 'BR', 'MS', 'Mato Grosso do Sul'),
	(496, 31, 'BR', 'MG', 'Minas Gerais'),
	(497, 31, 'BR', 'PA', 'Pará'),
	(498, 31, 'BR', 'PB', 'Paraíba'),
	(499, 31, 'BR', 'PR', 'Paraná'),
	(500, 31, 'BR', 'PE', 'Pernambuco'),
	(501, 31, 'BR', 'PI', 'Piauí'),
	(502, 31, 'BR', 'RJ', 'Rio de Janeiro'),
	(503, 31, 'BR', 'RN', 'Rio Grande do Norte'),
	(504, 31, 'BR', 'RS', 'Rio Grande do Sul'),
	(505, 31, 'BR', 'RO', 'Rondônia'),
	(506, 31, 'BR', 'RR', 'Roraima'),
	(507, 31, 'BR', 'SC', 'Santa Catarina'),
	(508, 31, 'BR', 'SP', 'São Paulo'),
	(509, 31, 'BR', 'SE', 'Sergipe'),
	(510, 31, 'BR', 'TO', 'Tocantins'),
	(511, 31, 'BR', 'DF', 'Distrito Federal'),
	(512, 59, 'HR', 'HR-01', 'Zagrebačka županija'),
	(513, 59, 'HR', 'HR-02', 'Krapinsko-zagorska županija'),
	(514, 59, 'HR', 'HR-03', 'Sisačko-moslavačka županija'),
	(515, 59, 'HR', 'HR-04', 'Karlovačka županija'),
	(516, 59, 'HR', 'HR-05', 'Varaždinska županija'),
	(517, 59, 'HR', 'HR-06', 'Koprivničko-križevačka županija'),
	(518, 59, 'HR', 'HR-07', 'Bjelovarsko-bilogorska županija'),
	(519, 59, 'HR', 'HR-08', 'Primorsko-goranska županija'),
	(520, 59, 'HR', 'HR-09', 'Ličko-senjska županija'),
	(521, 59, 'HR', 'HR-10', 'Virovitičko-podravska županija'),
	(522, 59, 'HR', 'HR-11', 'Požeško-slavonska županija'),
	(523, 59, 'HR', 'HR-12', 'Brodsko-posavska županija'),
	(524, 59, 'HR', 'HR-13', 'Zadarska županija'),
	(525, 59, 'HR', 'HR-14', 'Osječko-baranjska županija'),
	(526, 59, 'HR', 'HR-15', 'Šibensko-kninska županija'),
	(527, 59, 'HR', 'HR-16', 'Vukovarsko-srijemska županija'),
	(528, 59, 'HR', 'HR-17', 'Splitsko-dalmatinska županija'),
	(529, 59, 'HR', 'HR-18', 'Istarska županija'),
	(530, 59, 'HR', 'HR-19', 'Dubrovačko-neretvanska županija'),
	(531, 59, 'HR', 'HR-20', 'Međimurska županija'),
	(532, 59, 'HR', 'HR-21', 'Grad Zagreb'),
	(533, 106, 'IN', 'AN', 'Andaman and Nicobar Islands'),
	(534, 106, 'IN', 'AP', 'Andhra Pradesh'),
	(535, 106, 'IN', 'AR', 'Arunachal Pradesh'),
	(536, 106, 'IN', 'AS', 'Assam'),
	(537, 106, 'IN', 'BR', 'Bihar'),
	(538, 106, 'IN', 'CH', 'Chandigarh'),
	(539, 106, 'IN', 'CT', 'Chhattisgarh'),
	(540, 106, 'IN', 'DN', 'Dadra and Nagar Haveli'),
	(541, 106, 'IN', 'DD', 'Daman and Diu'),
	(542, 106, 'IN', 'DL', 'Delhi'),
	(543, 106, 'IN', 'GA', 'Goa'),
	(544, 106, 'IN', 'GJ', 'Gujarat'),
	(545, 106, 'IN', 'HR', 'Haryana'),
	(546, 106, 'IN', 'HP', 'Himachal Pradesh'),
	(547, 106, 'IN', 'JK', 'Jammu and Kashmir'),
	(548, 106, 'IN', 'JH', 'Jharkhand'),
	(549, 106, 'IN', 'KA', 'Karnataka'),
	(550, 106, 'IN', 'KL', 'Kerala'),
	(551, 106, 'IN', 'LD', 'Lakshadweep'),
	(552, 106, 'IN', 'MP', 'Madhya Pradesh'),
	(553, 106, 'IN', 'MH', 'Maharashtra'),
	(554, 106, 'IN', 'MN', 'Manipur'),
	(555, 106, 'IN', 'ML', 'Meghalaya'),
	(556, 106, 'IN', 'MZ', 'Mizoram'),
	(557, 106, 'IN', 'NL', 'Nagaland'),
	(558, 106, 'IN', 'OR', 'Odisha'),
	(559, 106, 'IN', 'PY', 'Puducherry'),
	(560, 106, 'IN', 'PB', 'Punjab'),
	(561, 106, 'IN', 'RJ', 'Rajasthan'),
	(562, 106, 'IN', 'SK', 'Sikkim'),
	(563, 106, 'IN', 'TN', 'Tamil Nadu'),
	(564, 106, 'IN', 'TG', 'Telangana'),
	(565, 106, 'IN', 'TR', 'Tripura'),
	(566, 106, 'IN', 'UP', 'Uttar Pradesh'),
	(567, 106, 'IN', 'UT', 'Uttarakhand'),
	(568, 106, 'IN', 'WB', 'West Bengal'),
	(569, 176, 'PY', 'PY-16', 'Alto Paraguay'),
	(570, 176, 'PY', 'PY-10', 'Alto Paraná'),
	(571, 176, 'PY', 'PY-13', 'Amambay'),
	(572, 176, 'PY', 'PY-ASU', 'Asunción'),
	(573, 176, 'PY', 'PY-19', 'Boquerón'),
	(574, 176, 'PY', 'PY-5', 'Caaguazú'),
	(575, 176, 'PY', 'PY-6', 'Caazapá'),
	(576, 176, 'PY', 'PY-14', 'Canindeyú'),
	(577, 176, 'PY', 'PY-11', 'Central'),
	(578, 176, 'PY', 'PY-1', 'Concepción'),
	(579, 176, 'PY', 'PY-3', 'Cordillera'),
	(580, 176, 'PY', 'PY-4', 'Guairá'),
	(581, 176, 'PY', 'PY-7', 'Itapúa'),
	(582, 176, 'PY', 'PY-8', 'Misiones'),
	(583, 176, 'PY', 'PY-9', 'Paraguarí'),
	(584, 176, 'PY', 'PY-15', 'Presidente Hayes'),
	(585, 176, 'PY', 'PY-2', 'San Pedro'),
	(586, 176, 'PY', 'PY-12', 'Ñeembucú');


--
-- Data for Name: country_state_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: country_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: currency_exchange_rates; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: customer_notes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: customer_password_resets; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: customer_social_accounts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: datagrid_saved_filters; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: downloadable_link_purchased; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: eu_withdrawals; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: gdpr_data_request; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: imports; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: import_batches; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: marketing_events; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.marketing_events (id, name, description, date, created_at, updated_at) VALUES
	(1, 'Birthday', 'Birthday', NULL, NULL, NULL);


--
-- Data for Name: marketing_templates; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: marketing_campaigns; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.migrations (id, migration, batch) VALUES
	(1, '2014_10_12_000000_create_users_table', 1),
	(2, '2014_10_12_100000_create_admin_password_resets_table', 1),
	(3, '2014_10_12_100000_create_password_resets_table', 1),
	(4, '2018_06_12_111907_create_admins_table', 1),
	(5, '2018_06_13_055341_create_roles_table', 1),
	(6, '2018_07_05_130148_create_attributes_table', 1),
	(7, '2018_07_05_132854_create_attribute_translations_table', 1),
	(8, '2018_07_05_135150_create_attribute_families_table', 1),
	(9, '2018_07_05_135152_create_attribute_groups_table', 1),
	(10, '2018_07_05_140832_create_attribute_options_table', 1),
	(11, '2018_07_05_140856_create_attribute_option_translations_table', 1),
	(12, '2018_07_05_142820_create_categories_table', 1),
	(13, '2018_07_10_055143_create_locales_table', 1),
	(14, '2018_07_20_054426_create_countries_table', 1),
	(15, '2018_07_20_054502_create_currencies_table', 1),
	(16, '2018_07_20_054542_create_currency_exchange_rates_table', 1),
	(17, '2018_07_20_064849_create_channels_table', 1),
	(18, '2018_07_21_142836_create_category_translations_table', 1),
	(19, '2018_07_23_110040_create_inventory_sources_table', 1),
	(20, '2018_07_24_082635_create_customer_groups_table', 1),
	(21, '2018_07_24_082930_create_customers_table', 1),
	(22, '2018_07_27_065727_create_products_table', 1),
	(23, '2018_07_27_070011_create_product_attribute_values_table', 1),
	(24, '2018_07_27_092623_create_product_reviews_table', 1),
	(25, '2018_07_27_113941_create_product_images_table', 1),
	(26, '2018_07_27_113956_create_product_inventories_table', 1),
	(27, '2018_08_30_064755_create_tax_categories_table', 1),
	(28, '2018_08_30_065042_create_tax_rates_table', 1),
	(29, '2018_08_30_065840_create_tax_mappings_table', 1),
	(30, '2018_09_05_150444_create_cart_table', 1),
	(31, '2018_09_05_150915_create_cart_items_table', 1),
	(32, '2018_09_11_064045_customer_password_resets', 1),
	(33, '2018_09_19_093453_create_cart_payment', 1),
	(34, '2018_09_19_093508_create_cart_shipping_rates_table', 1),
	(35, '2018_09_20_060658_create_core_config_table', 1),
	(36, '2018_09_27_113154_create_orders_table', 1),
	(37, '2018_09_27_113207_create_order_items_table', 1),
	(38, '2018_09_27_115022_create_shipments_table', 1),
	(39, '2018_09_27_115029_create_shipment_items_table', 1),
	(40, '2018_09_27_115135_create_invoices_table', 1),
	(41, '2018_09_27_115144_create_invoice_items_table', 1),
	(42, '2018_10_01_095504_create_order_payment_table', 1),
	(43, '2018_10_03_025230_create_wishlist_table', 1),
	(44, '2018_10_12_101803_create_country_translations_table', 1),
	(45, '2018_10_12_101913_create_country_states_table', 1),
	(46, '2018_10_12_101923_create_country_state_translations_table', 1),
	(47, '2018_11_16_173504_create_subscribers_list_table', 1),
	(48, '2018_11_21_144411_create_cart_item_inventories_table', 1),
	(49, '2018_12_06_185202_create_product_flat_table', 1),
	(50, '2018_12_24_123812_create_channel_inventory_sources_table', 1),
	(51, '2018_12_26_165327_create_product_ordered_inventories_table', 1),
	(52, '2019_05_13_024321_create_cart_rules_table', 1),
	(53, '2019_05_13_024322_create_cart_rule_channels_table', 1),
	(54, '2019_05_13_024323_create_cart_rule_customer_groups_table', 1),
	(55, '2019_05_13_024324_create_cart_rule_translations_table', 1),
	(56, '2019_05_13_024325_create_cart_rule_customers_table', 1),
	(57, '2019_05_13_024326_create_cart_rule_coupons_table', 1),
	(58, '2019_05_13_024327_create_cart_rule_coupon_usage_table', 1),
	(59, '2019_06_17_180258_create_product_downloadable_samples_table', 1),
	(60, '2019_06_17_180314_create_product_downloadable_sample_translations_table', 1),
	(61, '2019_06_17_180325_create_product_downloadable_links_table', 1),
	(62, '2019_06_17_180346_create_product_downloadable_link_translations_table', 1),
	(63, '2019_06_21_202249_create_downloadable_link_purchased_table', 1),
	(64, '2019_07_02_180307_create_booking_products_table', 1),
	(65, '2019_07_05_154415_create_booking_product_default_slots_table', 1),
	(66, '2019_07_05_154429_create_booking_product_appointment_slots_table', 1),
	(67, '2019_07_05_154440_create_booking_product_event_tickets_table', 1),
	(68, '2019_07_05_154451_create_booking_product_rental_slots_table', 1),
	(69, '2019_07_05_154502_create_booking_product_table_slots_table', 1),
	(70, '2019_07_30_153530_create_cms_pages_table', 1),
	(71, '2019_07_31_143339_create_category_filterable_attributes_table', 1),
	(72, '2019_08_02_105320_create_product_grouped_products_table', 1),
	(73, '2019_08_20_170510_create_product_bundle_options_table', 1),
	(74, '2019_08_20_170520_create_product_bundle_option_translations_table', 1),
	(75, '2019_08_20_170528_create_product_bundle_option_products_table', 1),
	(76, '2019_09_11_184511_create_refunds_table', 1),
	(77, '2019_09_11_184519_create_refund_items_table', 1),
	(78, '2019_12_03_184613_create_catalog_rules_table', 1),
	(79, '2019_12_03_184651_create_catalog_rule_channels_table', 1),
	(80, '2019_12_03_184732_create_catalog_rule_customer_groups_table', 1),
	(81, '2019_12_06_101110_create_catalog_rule_products_table', 1),
	(82, '2019_12_06_110507_create_catalog_rule_product_prices_table', 1),
	(83, '2019_12_14_000001_create_personal_access_tokens_table', 1),
	(84, '2020_01_14_191854_create_cms_page_translations_table', 1),
	(85, '2020_01_15_130209_create_cms_page_channels_table', 1),
	(86, '2020_02_18_165639_create_bookings_table', 1),
	(87, '2020_02_21_121201_create_booking_product_event_ticket_translations_table', 1),
	(88, '2020_04_16_185147_add_table_addresses', 1),
	(89, '2020_05_06_171638_create_order_comments_table', 1),
	(90, '2020_05_21_171500_create_product_customer_group_prices_table', 1),
	(91, '2020_06_25_162154_create_customer_social_accounts_table', 1),
	(92, '2020_08_07_174804_create_gdpr_data_request_table', 1),
	(93, '2020_11_19_112228_create_product_videos_table', 1),
	(94, '2020_11_26_141455_create_marketing_templates_table', 1),
	(95, '2020_11_26_150534_create_marketing_events_table', 1),
	(96, '2020_11_26_150644_create_marketing_campaigns_table', 1),
	(97, '2020_12_21_000200_create_channel_translations_table', 1),
	(98, '2020_12_27_121950_create_jobs_table', 1),
	(99, '2021_03_11_212124_create_order_transactions_table', 1),
	(100, '2021_04_07_132010_create_product_review_images_table', 1),
	(101, '2021_12_15_104544_notifications', 1),
	(102, '2022_03_15_160510_create_failed_jobs_table', 1),
	(103, '2022_04_01_094622_create_sitemaps_table', 1),
	(104, '2022_10_03_144232_create_product_price_indices_table', 1),
	(105, '2022_10_04_144444_create_job_batches_table', 1),
	(106, '2022_10_08_134150_create_product_inventory_indices_table', 1),
	(107, '2023_05_26_213105_create_wishlist_items_table', 1),
	(108, '2023_05_26_213120_create_compare_items_table', 1),
	(109, '2023_06_27_163529_rename_product_review_images_to_product_review_attachments', 1),
	(110, '2023_07_06_140013_add_logo_path_column_to_locales', 1),
	(111, '2023_07_10_184256_create_theme_customizations_table', 1),
	(112, '2023_07_12_181722_remove_home_page_and_footer_content_column_from_channel_translations_table', 1),
	(113, '2023_07_20_185324_add_column_column_in_attribute_groups_table', 1),
	(114, '2023_07_25_145943_add_regex_column_in_attributes_table', 1),
	(115, '2023_07_25_165945_drop_notes_column_from_customers_table', 1),
	(116, '2023_07_25_171058_create_customer_notes_table', 1),
	(117, '2023_07_31_125232_rename_image_and_category_banner_columns_from_categories_table', 1),
	(118, '2023_09_15_170053_create_theme_customization_translations_table', 1),
	(119, '2023_09_20_102031_add_default_value_column_in_attributes_table', 1),
	(120, '2023_09_20_102635_add_inventories_group_in_attribute_groups_table', 1),
	(121, '2023_09_26_155709_add_columns_to_currencies', 1),
	(122, '2023_10_12_090446_add_tax_category_id_column_in_order_items_table', 1),
	(123, '2023_11_08_054614_add_code_column_in_attribute_groups_table', 1),
	(124, '2023_11_08_140116_create_search_terms_table', 1),
	(125, '2023_11_09_162805_create_url_rewrites_table', 1),
	(126, '2023_11_17_150401_create_search_synonyms_table', 1),
	(127, '2023_12_11_054614_add_channel_id_column_in_product_price_indices_table', 1),
	(128, '2024_01_11_154640_create_imports_table', 1),
	(129, '2024_01_11_154741_create_import_batches_table', 1),
	(130, '2024_01_19_170350_add_unique_id_column_in_product_attribute_values_table', 1),
	(131, '2024_01_19_170350_add_unique_id_column_in_product_customer_group_prices_table', 1),
	(132, '2024_01_22_170814_add_unique_index_in_mapping_tables', 1),
	(133, '2024_02_26_153000_add_columns_to_addresses_table', 1),
	(134, '2024_03_07_193421_rename_address1_column_in_addresses_table', 1),
	(135, '2024_04_16_144400_add_cart_id_column_in_cart_shipping_rates_table', 1),
	(136, '2024_04_19_102939_add_incl_tax_columns_in_orders_table', 1),
	(137, '2024_04_19_135405_add_incl_tax_columns_in_cart_items_table', 1),
	(138, '2024_04_19_144641_add_incl_tax_columns_in_order_items_table', 1),
	(139, '2024_04_23_133154_add_incl_tax_columns_in_cart_table', 1),
	(140, '2024_04_23_150945_add_incl_tax_columns_in_cart_shipping_rates_table', 1),
	(141, '2024_04_24_102939_add_incl_tax_columns_in_invoices_table', 1),
	(142, '2024_04_24_102939_add_incl_tax_columns_in_refunds_table', 1),
	(143, '2024_04_24_144641_add_incl_tax_columns_in_invoice_items_table', 1),
	(144, '2024_04_24_144641_add_incl_tax_columns_in_refund_items_table', 1),
	(145, '2024_04_24_144641_add_incl_tax_columns_in_shipment_items_table', 1),
	(146, '2024_05_10_152848_create_saved_filters_table', 1),
	(147, '2024_06_03_174128_create_product_channels_table', 1),
	(148, '2024_06_04_130527_add_channel_id_column_in_customers_table', 1),
	(149, '2024_06_04_130600_make_email_unique_per_channel', 1),
	(150, '2024_06_13_184426_add_theme_column_into_theme_customizations_table', 1),
	(151, '2024_07_17_172645_add_additional_column_to_sitemaps_table', 1),
	(152, '2024_10_11_135010_create_product_customizable_options_table', 1),
	(153, '2024_10_11_135110_create_product_customizable_option_translations_table', 1),
	(154, '2024_10_11_135228_create_product_customizable_option_prices_table', 1),
	(155, '2025_05_07_121250_update_total_weight_columns_in_shipments_and_weight_shipment_items_tables', 1),
	(156, '2025_09_05_000100_add_indexes_to_channels_tables', 1),
	(157, '2025_09_05_000200_add_indexes_to_product_relation_tables', 1),
	(158, '2025_09_05_000300_add_indexes_to_product_media_and_attributes', 1),
	(159, '2025_09_05_000400_add_indexes_to_attributes_and_product_types', 1),
	(160, '2025_09_05_000500_add_indexes_to_product_grouped_products_and_product_bundle_option_products', 1),
	(161, '2025_09_05_000500_add_indexes_to_url_rewrites_and_visits', 1),
	(162, '2025_09_11_140301_add_two_factor_to_admins', 1),
	(163, '2025_11_14_173810_create_rma_statuses_table', 1),
	(164, '2025_11_14_173812_create_rma_table', 1),
	(165, '2025_11_14_173906_create_rma_reasons_table', 1),
	(166, '2025_11_14_173959_create_rma_items_table', 1),
	(167, '2025_11_14_174030_create_rma_images_table', 1),
	(168, '2025_11_14_174059_create_rma_messages_table', 1),
	(169, '2025_11_14_174134_create_rma_reason_resolutions_table', 1),
	(170, '2025_11_14_174205_create_rma_rules_table', 1),
	(171, '2025_11_14_174355_create_rma_custom_fields_table', 1),
	(172, '2025_11_14_174426_create_rma_custom_field_options_table', 1),
	(173, '2025_11_14_174509_create_rma_additional_fields_table', 1),
	(174, '2026_02_03_151924_create_sessions_table', 1),
	(175, '2026_02_03_151925_create_cache_table', 1),
	(176, '2026_02_11_095547_add_rma_return_period_to_order_items_table', 1),
	(177, '2026_03_11_113926_create_agent_conversations_table', 1),
	(178, '2026_03_23_104335_create_product_omnibus_prices_table', 1),
	(179, '2026_04_09_120000_change_tax_category_id_fk_on_cart_items_to_null_on_delete', 1),
	(180, '2026_04_09_120100_change_tax_category_id_fk_on_order_items_to_null_on_delete', 1),
	(181, '2026_04_17_000001_add_booking_product_enhancements', 1),
	(182, '2026_04_17_000002_add_allow_cancellation_snapshot_to_bookings', 1),
	(183, '2026_05_27_114230_create_eu_withdrawals_table', 1),
	(184, '2026_06_24_000000_rename_received_package_rma_status', 1),
	(185, '2026_06_24_000001_rename_neutral_rma_statuses', 1),
	(186, '2026_07_03_170000_create_sitemap_channels_table', 1),
	(187, '2026_07_27_000001_add_image_source_to_imports_table', 1),
	(188, '2026_08_10_000001_add_derived_columns_in_product_flat_table', 1),
	(189, '2026_08_13_000001_make_images_count_nullable_in_product_flat_table', 1),
	(190, '2026_08_15_000001_create_product_image_translations_table', 1),
	(191, '2026_08_15_000002_add_alt_text_columns_to_category_translations_table', 1),
	(192, '2026_08_15_000003_add_logo_alt_column_to_channel_translations_table', 1),
	(193, '2026_08_15_000004_add_swatch_alt_column_to_attribute_option_translations_table', 1),
	(194, '2026_08_15_000005_rename_theme_customizations_to_theme_sections', 1),
	(195, '2026_08_15_000006_move_theme_uploads_to_section_directory', 1),
	(196, '2026_08_15_000007_add_draft_options_to_theme_section_translations_table', 1),
	(197, '2026_08_15_000008_make_options_nullable_on_theme_section_translations_table', 1),
	(198, '2026_08_19_000002_add_draft_columns_to_theme_sections_table', 1),
	(199, '2026_08_26_000001_move_relocated_core_config_codes', 1),
	(200, '2026_08_26_000001_rename_linkedin_social_login_config_code', 1);
INSERT INTO public.migrations (id, migration, batch) VALUES
	(201, '2026_08_27_000001_move_search_engine_config_codes', 1),
	(202, '2026_09_04_000001_drop_duplicate_channel_pivot_indexes', 1),
	(203, '2026_09_04_000002_drop_duplicate_attributes_code_index', 1),
	(204, '2026_09_22_000001_replace_retired_magic_ai_models', 1),
	(205, '2026_09_23_120000_add_two_factor_last_used_window_to_admins', 1),
	(206, '2026_09_23_180000_move_storage_into_plural_directories', 1),
	(207, '2026_09_23_190000_drop_product_image_size_settings', 1),
	(208, '2026_10_05_000001_make_copyright_content_channel_based', 1),
	(209, '2026_06_19_100001_create_b2b_company_attributes_table', 2),
	(210, '2026_06_19_100002_create_b2b_company_attribute_translations_table', 2),
	(211, '2026_06_19_100003_create_b2b_company_attribute_options_table', 2),
	(212, '2026_06_19_100004_create_b2b_company_attribute_option_translations_table', 2),
	(213, '2026_06_19_100005_create_b2b_company_attribute_groups_table', 2),
	(214, '2026_06_19_100006_create_b2b_company_attribute_group_translations_table', 2),
	(215, '2026_06_19_100007_create_b2b_company_attribute_group_mappings_table', 2),
	(216, '2026_06_19_100008_create_b2b_company_attribute_values_table', 2),
	(217, '2026_06_19_100009_create_b2b_company_roles_table', 2),
	(218, '2026_06_19_100010_create_b2b_company_flat_table', 2),
	(219, '2026_06_19_100011_create_b2b_company_catalogs_table', 2),
	(220, '2026_06_19_100012_create_b2b_company_catalog_products_table', 2),
	(221, '2026_06_19_100013_create_b2b_company_catalog_categories_table', 2),
	(222, '2026_06_19_100014_create_b2b_company_credit_tables', 2),
	(223, '2026_06_19_100015_create_b2b_company_invitations_table', 2),
	(224, '2026_06_19_100016_create_b2b_customer_companies_table', 2),
	(225, '2026_06_19_100017_create_b2b_customer_quotes_table', 2),
	(226, '2026_06_19_100018_create_b2b_customer_quote_items_table', 2),
	(227, '2026_06_19_100019_create_b2b_customer_quote_messages_table', 2),
	(228, '2026_06_19_100020_create_b2b_customer_quote_quotations_table', 2),
	(229, '2026_06_19_100021_create_b2b_customer_quote_attachments_table', 2),
	(230, '2026_06_19_100022_create_b2b_customer_requisition_lists_table', 2),
	(231, '2026_06_19_100023_create_b2b_customer_requisition_list_products_table', 2),
	(232, '2026_06_19_100024_add_column_to_cart_table', 2),
	(233, '2026_06_19_100025_add_columns_to_customers_table', 2),
	(234, '2026_10_15_000001_create_vk7_sequences_table', 2),
	(235, '2026_10_31_000001_create_vk7_enquiries_table', 2),
	(236, '2026_10_31_000002_add_unique_document_numbers', 2),
	(237, '2026_11_01_000001_create_vk7_business_tables', 2),
	(238, '2026_11_01_000002_add_vk7_admin_columns', 2);


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: order_comments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: order_payment; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: order_transactions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: password_resets; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_attribute_values; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_bundle_options; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_bundle_option_products; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_bundle_option_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_channels; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_cross_sells; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_customer_group_prices; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_customizable_options; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_customizable_option_prices; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_customizable_option_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_downloadable_links; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_downloadable_link_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_downloadable_samples; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_downloadable_sample_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_flat; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_grouped_products; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_image_translations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_inventories; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_inventory_indices; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_omnibus_prices; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_ordered_inventories; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_price_indices; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_relations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_reviews; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_review_attachments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_super_attributes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_up_sells; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: product_videos; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: refunds; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: refund_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: rma_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rma_statuses (id, title, status, color, "default", created_at, updated_at) VALUES
	(1, 'Pending Review', true, '#efb308', 1, NULL, NULL),
	(2, 'Approved', true, '#12af56', 1, NULL, NULL),
	(3, 'Awaiting Return', true, '#f59e0b', 1, NULL, NULL),
	(4, 'Return In Transit', true, '#3b82f6', 1, NULL, NULL),
	(5, 'Refunded', true, '#10b981', 1, NULL, NULL),
	(6, 'Solved', true, '#47b84f', 1, NULL, NULL),
	(7, 'Request Declined', true, '#e11d48', 1, NULL, NULL),
	(8, 'Item Canceled', true, '#dc2626', 1, NULL, NULL),
	(9, 'Request Canceled', true, '#991b1b', 1, NULL, NULL);


--
-- Data for Name: rma; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: rma_custom_fields; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: rma_additional_fields; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: rma_custom_field_options; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: rma_images; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: rma_reasons; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rma_reasons (id, title, status, "position", is_admin, created_at, updated_at) VALUES
	(1, 'Manufacturer Defect', true, 1, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(2, 'Damaged During Shipping', true, 2, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(3, 'Wrong Description Online', true, 3, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(4, 'Dead On Arrival', true, 4, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(5, 'Product Not Received Yet', true, 5, false, '2026-10-31 22:53:05', '2026-10-31 22:53:05');


--
-- Data for Name: rma_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: rma_messages; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: rma_reason_resolutions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rma_reason_resolutions (id, rma_reason_id, resolution_type, created_at, updated_at) VALUES
	(1, 1, 'return', '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(2, 1, 'cancel_items', '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(3, 2, 'return', '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(4, 2, 'cancel_items', '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(5, 3, 'return', '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(6, 3, 'cancel_items', '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(7, 4, 'return', '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(8, 4, 'cancel_items', '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(9, 5, 'return', '2026-10-31 22:53:05', '2026-10-31 22:53:05'),
	(10, 5, 'cancel_items', '2026-10-31 22:53:05', '2026-10-31 22:53:05');


--
-- Data for Name: rma_rules; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rma_rules (id, name, description, status, return_period, "default", created_at, updated_at) VALUES
	(1, 'Basic', '1', true, 10, NULL, '2026-10-31 22:53:05', '2026-10-31 22:53:05');


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.roles (id, name, description, permission_type, permissions, created_at, updated_at) VALUES
	(1, 'Administrator', 'This role users will have all the access', 'all', NULL, NULL, NULL),
	(2, 'Sales', 'Sales staff', 'custom', '["vk7_desk.dashboard", "vk7_desk.retailers", "vk7_desk.enquiries", "vk7_desk.quotes", "vk7_desk.orders"]', '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(3, 'Inventory', 'Inventory staff', 'custom', '["vk7_desk.dashboard", "vk7_desk.products", "vk7_desk.inventory", "vk7_desk.orders"]', '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(4, 'Warehouse', 'Warehouse staff', 'custom', '["vk7_desk.dashboard", "vk7_desk.orders", "vk7_desk.dispatch"]', '2026-10-31 22:53:12', '2026-10-31 22:53:12'),
	(5, 'Finance', 'Finance staff', 'custom', '["vk7_desk.dashboard", "vk7_desk.payments", "vk7_desk.orders", "vk7_desk.retailers", "vk7_desk.reports"]', '2026-10-31 22:53:12', '2026-10-31 22:53:12');


--
-- Data for Name: search_synonyms; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: search_terms; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: shipments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: shipment_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sitemaps; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: sitemap_channels; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: subscribers_list; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: tax_rates; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: tax_categories_tax_rates; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: theme_sections; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.theme_sections (id, type, name, sort_order, status, channel_id, created_at, updated_at, theme_code, draft_status, draft_sort_order) VALUES
	(1, 'image_carousel', 'Image Carousel', 1, true, 1, '2026-10-31 22:53:05', '2026-10-31 22:53:05', 'default', NULL, NULL),
	(2, 'static_content', 'Offer Information', 2, true, 1, '2026-10-31 22:53:05', '2026-10-31 22:53:05', 'default', NULL, NULL),
	(5, 'static_content', 'Top Collections', 5, true, 1, '2026-10-31 22:53:05', '2026-10-31 22:53:05', 'default', NULL, NULL),
	(6, 'static_content', 'Bold Collections', 6, true, 1, '2026-10-31 22:53:05', '2026-10-31 22:53:05', 'default', NULL, NULL),
	(8, 'static_content', 'Game Container', 8, true, 1, '2026-10-31 22:53:05', '2026-10-31 22:53:05', 'default', NULL, NULL),
	(10, 'static_content', 'Bold Collections', 10, true, 1, '2026-10-31 22:53:05', '2026-10-31 22:53:05', 'default', NULL, NULL),
	(12, 'services_content', 'Services Content', 12, true, 1, '2026-10-31 22:53:05', '2026-10-31 22:53:05', 'default', NULL, NULL),
	(13, 'footer_links', 'Footer Links', 13, true, 1, '2026-10-31 22:53:05', '2026-10-31 22:53:05', 'default', NULL, NULL);


--
-- Data for Name: theme_section_translations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.theme_section_translations (id, section_id, locale, options, draft_options) VALUES
	(1, 1, 'en', '{"images": [{"link": "#formal-wear-female", "image": "themes/default/sections/1/yHl2KMKQffVzGDdw0v2dB01WOzAzSYthN5OnxVS2.webp", "title": "Get Ready For New Collection"}, {"link": "#formal-wear-men", "image": "themes/default/sections/1/Pk1VKpqOga1TrkjU7jIZjgzYPfgGTtQM0ehN84Hh.webp", "title": "Get Ready For New Collection"}, {"link": "#active-wear-female", "image": "themes/default/sections/1/pAHh29GFDzpLfeCfJMkWJ4hKrDeeAmnz5MjY4u0Q.webp", "title": "Get Ready For New Collection"}, {"link": "#smart-home-automation", "image": "themes/default/sections/1/wRKXGSx4oFZ1S3qiJATjwRjgd51PGZh7O5aZHACX.webp", "title": "Get Ready For New Collection"}, {"link": "#mobile-phones-accessories", "image": "themes/default/sections/1/w8Z07UbB4PhGGuSyUE2mNbITTTtZusilo8LxQaw6.webp", "title": "Get Ready For New Collection"}, {"link": "#laptops-tablets", "image": "themes/default/sections/1/SYRb1LCpmGYhL5WgfmbXqKSOyVbmGDxQo6eonU5c.webp", "title": "Get Ready For New Collection"}]}', NULL),
	(2, 2, 'en', '{"css": ".home-offer h1 {display: block;font-weight: 500;text-align: center;font-size: 22px;font-family: DM Serif Display;background-color: #E8EDFE;padding-top: 20px;padding-bottom: 20px;}@media (max-width:768px){.home-offer h1 {font-size:18px;padding-top: 10px;padding-bottom: 10px;}@media (max-width:525px) {.home-offer h1 {font-size:14px;padding-top: 6px;padding-bottom: 6px;}}", "html": "<div class=\"home-offer\"><h1>Get UPTO 40% OFF on your 1st order SHOP NOW</h1></div>"}', NULL),
	(3, 5, 'en', '{"css": ".top-collection-container {overflow: hidden;}.top-collection-header {padding-left: 15px;padding-right: 15px;text-align: center;font-size: 70px;line-height: 90px;color: #060C3B;margin-top: 80px;}.top-collection-header h2 {max-width: 595px;margin-left: auto;margin-right: auto;font-family: DM Serif Display;}.top-collection-grid {display: flex;flex-wrap: wrap;gap: 32px;justify-content: center;margin-top: 60px;width: 100%;margin-right: auto;margin-left: auto;padding-right: 90px;padding-left: 90px;}.top-collection-card {position: relative;background: #f9fafb;overflow:hidden;border-radius:20px;}.top-collection-card img {border-radius: 16px;max-width: 100%;text-indent:-9999px;transition: transform 300ms ease;transform: scale(1);}.top-collection-card:hover img {transform: scale(1.05);transition: all 300ms ease;}.top-collection-card h3 {color: #060C3B;font-size: 30px;font-family: DM Serif Display;transform: translateX(-50%);width: max-content;left: 50%;bottom: 30px;position: absolute;margin: 0;font-weight: inherit;}@media not all and (min-width: 525px) {.top-collection-header {margin-top: 28px;font-size: 20px;line-height: 1.5;}.top-collection-grid {gap: 10px}}@media not all and (min-width: 768px) {.top-collection-header {margin-top: 30px;font-size: 28px;line-height: 3;}.top-collection-header h2 {line-height:2; margin-bottom:20px;} .top-collection-grid {gap: 14px}} @media not all and (min-width: 1024px) {.top-collection-grid {padding-left: 30px;padding-right: 30px;}}@media (max-width: 768px) {.top-collection-grid { row-gap:15px; column-gap:0px;justify-content: space-between;margin-top: 0px;} .top-collection-card{width:48%} .top-collection-card img {width:100%;} .top-collection-card h3 {font-size:24px; bottom: 16px;}}@media (max-width:520px) { .top-collection-grid{padding-left: 15px;padding-right: 15px;} .top-collection-card h3 {font-size:18px; bottom: 10px;}}", "html": "<div class=\"top-collection-container\">\n                                <div class=\"top-collection-header\">\n                                    <h2>The game with our new additions!</h2>\n                                </div>\n\n                                <div class=\"top-collection-grid container\">\n                                    <div class=\"top-collection-card\">\n                                        <a href=\"#electronics\" aria-label=\"The game with our new additions!\">\n                                            <img src=\"\" data-src=\"__media__/themes/default/sections/5/8ObXPXjetarp35IeRLtQO4Lo6qLJcazuPAWEHRg4.webp\" class=\"lazy\" width=\"396\" height=\"396\" alt=\"The game with our new additions!\">\n                                        </a>\n                                    </div>\n\n                                    <div class=\"top-collection-card\">\n                                        <a href=\"#mens\" aria-label=\"The game with our new additions!\">\n                                            <img src=\"\" data-src=\"__media__/themes/default/sections/5/u0J5UN11xTCeHDD00lJ9lAZVEIAkYAWvppIQKrdh.webp\" class=\"lazy\" width=\"396\" height=\"396\" alt=\"The game with our new additions!\">\n                                        </a>\n                                    </div>\n\n                                    <div class=\"top-collection-card\">\n                                        <a href=\"#womens\" aria-label=\"The game with our new additions!\">\n                                            <img src=\"\" data-src=\"__media__/themes/default/sections/5/T1IYvgzaqjdBp3UuoN6etma6qRNcDSTPyRE71QS6.webp\" class=\"lazy\" width=\"396\" height=\"396\" alt=\"The game with our new additions!\">\n                                        </a>\n                                    </div>\n\n                                    <div class=\"top-collection-card\">\n                                        <a href=\"#formal-wear-men\" aria-label=\"The game with our new additions!\">\n                                            <img src=\"\" data-src=\"__media__/themes/default/sections/5/YiXDKpVE5fFYsjOmbcp2jn1lHE3k1zphfdOj1s0r.webp\" class=\"lazy\" width=\"396\" height=\"396\" alt=\"The game with our new additions!\">\n                                        </a>\n                                    </div>\n\n                                    <div class=\"top-collection-card\">\n                                        <a href=\"#formal-wear-female\" aria-label=\"The game with our new additions!\">\n                                            <img src=\"\" data-src=\"__media__/themes/default/sections/5/g3e1dZwolP5ToNkW8QBZTQOnWE5K9Rvw7rFlbjdM.webp\" class=\"lazy\" width=\"396\" height=\"396\" alt=\"The game with our new additions!\">\n                                        </a>\n                                    </div>\n\n                                    <div class=\"top-collection-card\">\n                                        <a href=\"#wellness\" aria-label=\"The game with our new additions!\">\n                                            <img src=\"\" data-src=\"__media__/themes/default/sections/5/G5bImpo12UzyZn1lsyOE5mcCC7TVFQ7zEVQKtHnz.webp\" class=\"lazy\" width=\"396\" height=\"396\" alt=\"The game with our new additions!\">\n                                        </a>\n                                    </div>\n                                </div>\n                            </div>"}', NULL),
	(4, 6, 'en', '{"css": ".section-gap{margin-top:80px}.direction-ltr{direction:ltr}.direction-rtl{direction:rtl}.inline-col-wrapper{display:grid;grid-template-columns:auto 1fr;grid-gap:60px;align-items:center}.inline-col-wrapper .inline-col-image-wrapper{overflow:hidden}.inline-col-wrapper .inline-col-image-wrapper img{max-width:100%;height:auto;border-radius:16px;text-indent:-9999px}.inline-col-wrapper .inline-col-content-wrapper{display:flex;flex-wrap:wrap;gap:20px;max-width:464px}.inline-col-wrapper .inline-col-content-wrapper .inline-col-title{max-width:442px;font-size:60px;font-weight:400;color:#060c3b;line-height:70px;font-family:DM Serif Display;margin:0}.inline-col-wrapper .inline-col-content-wrapper .inline-col-description{margin:0;font-size:18px;color:#6e6e6e;font-family:Poppins}@media (max-width:991px){.inline-col-wrapper{grid-template-columns:1fr;grid-gap:16px}.inline-col-wrapper .inline-col-content-wrapper{gap:10px}} @media (max-width:768px){.inline-col-wrapper .inline-col-image-wrapper img {width:100%;} .inline-col-wrapper .inline-col-content-wrapper .inline-col-title{font-size:28px !important;line-height:normal !important}} @media (max-width:525px){.inline-col-wrapper .inline-col-content-wrapper .inline-col-title{font-size:20px !important;} .inline-col-description{font-size:16px} .inline-col-wrapper{grid-gap:10px}}", "html": "<div class=\"section-gap bold-collections container\">\n                                <div class=\"inline-col-wrapper\">\n                                    <div class=\"inline-col-image-wrapper\">\n                                        <img src=\"\" data-src=\"__media__/themes/default/sections/6/M5AwiqcYdJ1e6iJuYsePj8rFY4hJpgcoDWXhmj5A.webp\" class=\"lazy\" width=\"632\" height=\"510\" alt=\"Get Ready for our new Bold Collections!\">\n                                    </div>\n\n                                    <div class=\"inline-col-content-wrapper\">\n                                        <h2 class=\"inline-col-title\"> Get Ready for our new Bold Collections! </h2> \n                                        \n                                        <p class=\"inline-col-description\">Introducing Our New Bold Collections! Elevate your style with daring designs and vibrant statements. Explore striking patterns and bold colors that redefine your wardrobe. Get ready to embrace the extraordinary!</p>\n                                        \n                                        <a href=\"#wellness\">\n                                            <button class=\"primary-button max-md:rounded-lg max-md:px-4 max-md:py-2.5 max-md:text-sm\">View Collections</button>\n                                        </a>\n                                    </div>\n                                </div>\n                            </div>"}', NULL),
	(5, 8, 'en', '{"css": ".section-game {overflow: hidden;}.section-title,.section-title h2{font-weight:400;font-family:DM Serif Display}.section-title{margin-top:80px;padding-left:15px;padding-right:15px;text-align:center;line-height:90px}.section-title h2{font-size:70px;color:#060c3b;max-width:595px;margin:auto}.collection-card-wrapper{display:flex;flex-wrap:wrap;justify-content:center;gap:30px}.collection-card-wrapper .single-collection-card{position:relative}.collection-card-wrapper .single-collection-card img{border-radius:16px;background-color:#f5f5f5;max-width:100%;height:auto;text-indent:-9999px}.collection-card-wrapper .single-collection-card .overlay-text{font-size:50px;font-weight:400;max-width:234px;font-style:italic;color:#060c3b;font-family:DM Serif Display;position:absolute;bottom:30px;left:30px;margin:0}@media (max-width:1024px){.section-title{padding:0 30px}}@media (max-width:991px){.collection-card-wrapper{flex-wrap:wrap}}@media (max-width:768px) {.collection-card-wrapper .single-collection-card .overlay-text{font-size:32px; bottom:20px}.section-title{margin-top:32px}.section-title h2{font-size:28px;line-height:normal}} @media (max-width:525px){.collection-card-wrapper .single-collection-card .overlay-text{font-size:18px; bottom:10px} .section-title{margin-top:28px}.section-title h2{font-size:20px;} .collection-card-wrapper{gap:10px; 15px; row-gap:15px; column-gap:0px;justify-content: space-between;margin-top: 15px;} .collection-card-wrapper .single-collection-card {width:48%;}}", "html": "<div class=\"section-game\">\n                                <div class=\"section-title\">\n                                    <h2>The game with our new additions!</h2> \n                                </div>\n\n                                <div class=\"section-gap container\">\n                                    <div class=\"collection-card-wrapper\">\n                                        <div class=\"single-collection-card\">\n                                            <a href=\"#active-wear\">\n                                                <img src=\"\" data-src=\"__media__/themes/default/sections/8/PMqOEhxV2g6jAJCEgDpBuQiVkmu8Tfoh1SqloQzk.webp\" class=\"lazy\" width=\"615\" height=\"600\" alt=\"The game with our new additions!\">\n                                                \n                                                <h3 class=\"overlay-text\">Our Collections</h3> \n                                            </a>\n                                        </div>\n\n                                        <div class=\"single-collection-card\">\n                                            <a href=\"#active-wear-female\">\n                                                <img src=\"\" data-src=\"__media__/themes/default/sections/8/11mp3x0bhssUsDw3zjzKqy1FLXuFClY0hgZIi0kq.webp\" class=\"lazy\" width=\"615\" height=\"600\" alt=\"The game with our new additions!\">\n                                                \n                                                <h3 class=\"overlay-text\"> Our Collections </h3> \n                                            </a>\n                                        </div>\n                                    </div>\n                                </div>\n                            </div>"}', NULL),
	(6, 10, 'en', '{"css": ".section-gap{margin-top:80px}.direction-ltr{direction:ltr}.direction-rtl{direction:rtl}.inline-col-wrapper{display:grid;grid-template-columns:auto 1fr;grid-gap:60px;align-items:center}.inline-col-wrapper .inline-col-image-wrapper{overflow:hidden}.inline-col-wrapper .inline-col-image-wrapper img{max-width:100%;height:auto;border-radius:16px;text-indent:-9999px}.inline-col-wrapper .inline-col-content-wrapper{display:flex;flex-wrap:wrap;gap:20px;max-width:464px}.inline-col-wrapper .inline-col-content-wrapper .inline-col-title{max-width:442px;font-size:60px;font-weight:400;color:#060c3b;line-height:70px;font-family:DM Serif Display;margin:0}.inline-col-wrapper .inline-col-content-wrapper .inline-col-description{margin:0;font-size:18px;color:#6e6e6e;font-family:Poppins}@media (max-width:991px){.inline-col-wrapper{grid-template-columns:1fr;grid-gap:16px}.inline-col-wrapper .inline-col-content-wrapper{gap:10px}}@media (max-width:768px) {.inline-col-wrapper .inline-col-image-wrapper img {max-width:100%;}.inline-col-wrapper .inline-col-content-wrapper{max-width:100%;justify-content:center; text-align:center} .section-gap{padding:0 30px; gap:20px;margin-top:24px} .bold-collections{margin-top:32px;}} @media (max-width:525px){.inline-col-wrapper .inline-col-content-wrapper{gap:10px} .inline-col-wrapper .inline-col-content-wrapper .inline-col-title{font-size:20px;line-height:normal} .section-gap{padding:0 15px; gap:15px;margin-top:10px} .bold-collections{margin-top:28px;}  .inline-col-description{font-size:16px !important} .inline-col-wrapper{grid-gap:15px}", "html": "<div class=\"section-gap bold-collections container\">\n                                <div class=\"inline-col-wrapper direction-rtl\">\n                                    <div class=\"inline-col-image-wrapper\">\n                                        <img src=\"\" data-src=\"__media__/themes/default/sections/10/cIvZTfxeYrNNy1h5UPWkoZAcfNfMH2Is0dY0poRA.webp\" class=\"lazy\" width=\"632\" height=\"510\" alt=\"Unleash Your Boldness with Our New Collection!\">\n                                    </div>\n\n                                    <div class=\"inline-col-content-wrapper direction-ltr\">\n                                        <h2 class=\"inline-col-title\">Unleash Your Boldness with Our New Collection!</h2> \n                                        \n                                        <p class=\"inline-col-description\">Our Bold Collections are here to redefine your wardrobe with fearless designs and striking, vibrant colors. From daring patterns to powerful hues, this is your chance to break away from the ordinary and step into the extraordinary.</p>\n                                        \n                                        <a href=\"#electronics\">\n                                            <button class=\"primary-button max-md:rounded-lg max-md:px-4 max-md:py-2.5 max-md:text-sm\">View Collections</button>\n                                        </a>\n                                    </div>\n                                </div>\n                            </div>"}', NULL),
	(7, 12, 'en', '{"services": [{"title": "Free Shipping", "description": "Enjoy free shipping on all orders", "service_icon": "icon-truck"}, {"title": "Product Replace", "description": "Easy Product Replacement Available!", "service_icon": "icon-product"}, {"title": "Emi Available", "description": "No cost EMI available on all major credit cards", "service_icon": "icon-dollar-sign"}, {"title": "24/7 Support", "description": "Dedicated 24/7 support via chat and email", "service_icon": "icon-support"}]}', NULL),
	(8, 13, 'en', '{"column_1": [{"url": "page/about-us", "title": "About Us"}, {"url": "contact-us", "title": "Contact Us"}, {"url": "page/customer-service", "title": "Customer Service"}, {"url": "page/whats-new", "title": "What''s New"}, {"url": "page/terms-of-use", "title": "Terms of Use"}, {"url": "page/terms-conditions", "title": "Terms & Conditions"}], "column_2": [{"url": "page/privacy-policy", "title": "Privacy Policy"}, {"url": "page/payment-policy", "title": "Payment Policy"}, {"url": "page/shipping-policy", "title": "Shipping Policy"}, {"url": "page/refund-policy", "title": "Refund Policy"}, {"url": "page/return-policy", "title": "Return Policy"}]}', NULL);


--
-- Data for Name: url_rewrites; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vk7_activity_log; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vk7_enquiries; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vk7_order_terms; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vk7_payments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vk7_sequences; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vk7_sequences (name, value) VALUES
	('order', 0),
	('quote', 0);


--
-- Data for Name: vk7_shipments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vk7_shipment_events; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vk7_stock_log; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: wishlist; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: wishlist_items; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Name: addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.addresses_id_seq', 1, false);


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admins_id_seq', 2, false);


--
-- Name: attribute_families_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attribute_families_id_seq', 2, false);


--
-- Name: attribute_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attribute_groups_id_seq', 9, false);


--
-- Name: attribute_option_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attribute_option_translations_id_seq', 9, true);


--
-- Name: attribute_options_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attribute_options_id_seq', 10, false);


--
-- Name: attribute_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attribute_translations_id_seq', 30, true);


--
-- Name: attributes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.attributes_id_seq', 31, false);


--
-- Name: b2b_company_attribute_group_mappings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_attribute_group_mappings_id_seq', 21, true);


--
-- Name: b2b_company_attribute_group_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_attribute_group_translations_id_seq', 5, true);


--
-- Name: b2b_company_attribute_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_attribute_groups_id_seq', 1, false);


--
-- Name: b2b_company_attribute_option_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_attribute_option_translations_id_seq', 1, false);


--
-- Name: b2b_company_attribute_options_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_attribute_options_id_seq', 1, false);


--
-- Name: b2b_company_attribute_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_attribute_translations_id_seq', 21, true);


--
-- Name: b2b_company_attribute_values_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_attribute_values_id_seq', 1, false);


--
-- Name: b2b_company_attributes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_attributes_id_seq', 1, false);


--
-- Name: b2b_company_catalog_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_catalog_categories_id_seq', 1, false);


--
-- Name: b2b_company_catalog_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_catalog_products_id_seq', 1, false);


--
-- Name: b2b_company_catalogs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_catalogs_id_seq', 1, false);


--
-- Name: b2b_company_credit_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_credit_transactions_id_seq', 1, false);


--
-- Name: b2b_company_credits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_credits_id_seq', 1, false);


--
-- Name: b2b_company_flat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_flat_id_seq', 1, false);


--
-- Name: b2b_company_invitations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_invitations_id_seq', 1, false);


--
-- Name: b2b_company_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_company_roles_id_seq', 1, false);


--
-- Name: b2b_customer_quote_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_customer_quote_attachments_id_seq', 1, false);


--
-- Name: b2b_customer_quote_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_customer_quote_items_id_seq', 1, false);


--
-- Name: b2b_customer_quote_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_customer_quote_messages_id_seq', 1, false);


--
-- Name: b2b_customer_quote_quotations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_customer_quote_quotations_id_seq', 1, false);


--
-- Name: b2b_customer_quotes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_customer_quotes_id_seq', 1, false);


--
-- Name: b2b_customer_requisition_list_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_customer_requisition_list_products_id_seq', 1, false);


--
-- Name: b2b_customer_requisition_lists_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.b2b_customer_requisition_lists_id_seq', 1, false);


--
-- Name: booking_product_appointment_slots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.booking_product_appointment_slots_id_seq', 1, false);


--
-- Name: booking_product_default_slots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.booking_product_default_slots_id_seq', 1, false);


--
-- Name: booking_product_event_ticket_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.booking_product_event_ticket_translations_id_seq', 1, false);


--
-- Name: booking_product_event_tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.booking_product_event_tickets_id_seq', 1, false);


--
-- Name: booking_product_rental_slots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.booking_product_rental_slots_id_seq', 1, false);


--
-- Name: booking_product_table_slots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.booking_product_table_slots_id_seq', 1, false);


--
-- Name: booking_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.booking_products_id_seq', 1, false);


--
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bookings_id_seq', 1, false);


--
-- Name: cart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_id_seq', 1, false);


--
-- Name: cart_item_inventories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_item_inventories_id_seq', 1, false);


--
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 1, false);


--
-- Name: cart_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_payment_id_seq', 1, false);


--
-- Name: cart_rule_coupon_usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_rule_coupon_usage_id_seq', 1, false);


--
-- Name: cart_rule_coupons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_rule_coupons_id_seq', 1, false);


--
-- Name: cart_rule_customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_rule_customers_id_seq', 1, false);


--
-- Name: cart_rule_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_rule_translations_id_seq', 1, false);


--
-- Name: cart_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_rules_id_seq', 1, false);


--
-- Name: cart_shipping_rates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_shipping_rates_id_seq', 1, false);


--
-- Name: catalog_rule_product_prices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.catalog_rule_product_prices_id_seq', 1, false);


--
-- Name: catalog_rule_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.catalog_rule_products_id_seq', 1, false);


--
-- Name: catalog_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.catalog_rules_id_seq', 1, false);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_id_seq', 2, false);


--
-- Name: category_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.category_translations_id_seq', 1, true);


--
-- Name: channel_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.channel_translations_id_seq', 1, true);


--
-- Name: channels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.channels_id_seq', 2, false);


--
-- Name: cms_page_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cms_page_translations_id_seq', 10, true);


--
-- Name: cms_pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cms_pages_id_seq', 11, false);


--
-- Name: compare_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.compare_items_id_seq', 1, false);


--
-- Name: core_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.core_config_id_seq', 38, true);


--
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.countries_id_seq', 1, false);


--
-- Name: country_state_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.country_state_translations_id_seq', 1, false);


--
-- Name: country_states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.country_states_id_seq', 1, false);


--
-- Name: country_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.country_translations_id_seq', 1, false);


--
-- Name: currencies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.currencies_id_seq', 2, false);


--
-- Name: currency_exchange_rates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.currency_exchange_rates_id_seq', 1, false);


--
-- Name: customer_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_groups_id_seq', 4, false);


--
-- Name: customer_notes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_notes_id_seq', 1, false);


--
-- Name: customer_social_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customer_social_accounts_id_seq', 1, false);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.customers_id_seq', 1, false);


--
-- Name: datagrid_saved_filters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.datagrid_saved_filters_id_seq', 1, false);


--
-- Name: downloadable_link_purchased_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.downloadable_link_purchased_id_seq', 1, false);


--
-- Name: eu_withdrawals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.eu_withdrawals_id_seq', 1, false);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: gdpr_data_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.gdpr_data_request_id_seq', 1, false);


--
-- Name: import_batches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.import_batches_id_seq', 1, false);


--
-- Name: imports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.imports_id_seq', 1, false);


--
-- Name: inventory_sources_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inventory_sources_id_seq', 2, false);


--
-- Name: invoice_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoice_items_id_seq', 1, false);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoices_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jobs_id_seq', 1, false);


--
-- Name: locales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.locales_id_seq', 2, false);


--
-- Name: marketing_campaigns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.marketing_campaigns_id_seq', 1, false);


--
-- Name: marketing_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.marketing_events_id_seq', 1, true);


--
-- Name: marketing_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.marketing_templates_id_seq', 1, false);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.migrations_id_seq', 238, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: order_comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_comments_id_seq', 1, false);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_id_seq', 1, false);


--
-- Name: order_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_payment_id_seq', 1, false);


--
-- Name: order_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_transactions_id_seq', 1, false);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_id_seq', 1, false);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 1, false);


--
-- Name: product_attribute_values_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_attribute_values_id_seq', 1, false);


--
-- Name: product_bundle_option_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_bundle_option_products_id_seq', 1, false);


--
-- Name: product_bundle_option_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_bundle_option_translations_id_seq', 1, false);


--
-- Name: product_bundle_options_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_bundle_options_id_seq', 1, false);


--
-- Name: product_customer_group_prices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_customer_group_prices_id_seq', 1, false);


--
-- Name: product_customizable_option_prices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_customizable_option_prices_id_seq', 1, false);


--
-- Name: product_customizable_option_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_customizable_option_translations_id_seq', 1, false);


--
-- Name: product_customizable_options_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_customizable_options_id_seq', 1, false);


--
-- Name: product_downloadable_link_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_downloadable_link_translations_id_seq', 1, false);


--
-- Name: product_downloadable_links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_downloadable_links_id_seq', 1, false);


--
-- Name: product_downloadable_sample_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_downloadable_sample_translations_id_seq', 1, false);


--
-- Name: product_downloadable_samples_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_downloadable_samples_id_seq', 1, false);


--
-- Name: product_flat_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_flat_id_seq', 1, false);


--
-- Name: product_grouped_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_grouped_products_id_seq', 1, false);


--
-- Name: product_image_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_image_translations_id_seq', 1, false);


--
-- Name: product_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_images_id_seq', 1, false);


--
-- Name: product_inventories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_inventories_id_seq', 1, false);


--
-- Name: product_inventory_indices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_inventory_indices_id_seq', 1, false);


--
-- Name: product_omnibus_prices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_omnibus_prices_id_seq', 1, false);


--
-- Name: product_ordered_inventories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_ordered_inventories_id_seq', 1, false);


--
-- Name: product_price_indices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_price_indices_id_seq', 1, false);


--
-- Name: product_review_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_review_images_id_seq', 1, false);


--
-- Name: product_reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_reviews_id_seq', 1, false);


--
-- Name: product_videos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_videos_id_seq', 1, false);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_id_seq', 1, false);


--
-- Name: refund_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.refund_items_id_seq', 1, false);


--
-- Name: refunds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.refunds_id_seq', 1, false);


--
-- Name: rma_additional_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_additional_fields_id_seq', 1, false);


--
-- Name: rma_custom_field_options_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_custom_field_options_id_seq', 1, false);


--
-- Name: rma_custom_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_custom_fields_id_seq', 1, false);


--
-- Name: rma_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_id_seq', 1, false);


--
-- Name: rma_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_images_id_seq', 1, false);


--
-- Name: rma_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_items_id_seq', 1, false);


--
-- Name: rma_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_messages_id_seq', 1, false);


--
-- Name: rma_reason_resolutions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_reason_resolutions_id_seq', 10, true);


--
-- Name: rma_reasons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_reasons_id_seq', 5, true);


--
-- Name: rma_rules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_rules_id_seq', 1, true);


--
-- Name: rma_statuses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rma_statuses_id_seq', 10, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_id_seq', 5, true);


--
-- Name: search_synonyms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.search_synonyms_id_seq', 1, false);


--
-- Name: search_terms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.search_terms_id_seq', 1, false);


--
-- Name: shipment_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.shipment_items_id_seq', 1, false);


--
-- Name: shipments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.shipments_id_seq', 1, false);


--
-- Name: sitemaps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sitemaps_id_seq', 1, false);


--
-- Name: subscribers_list_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subscribers_list_id_seq', 1, false);


--
-- Name: tax_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tax_categories_id_seq', 1, false);


--
-- Name: tax_categories_tax_rates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tax_categories_tax_rates_id_seq', 1, false);


--
-- Name: tax_rates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tax_rates_id_seq', 1, false);


--
-- Name: theme_customization_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.theme_customization_translations_id_seq', 8, true);


--
-- Name: theme_customizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.theme_customizations_id_seq', 14, false);


--
-- Name: url_rewrites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.url_rewrites_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: vk7_activity_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vk7_activity_log_id_seq', 1, false);


--
-- Name: vk7_enquiries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vk7_enquiries_id_seq', 1, false);


--
-- Name: vk7_order_terms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vk7_order_terms_id_seq', 1, false);


--
-- Name: vk7_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vk7_payments_id_seq', 1, false);


--
-- Name: vk7_shipment_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vk7_shipment_events_id_seq', 1, false);


--
-- Name: vk7_shipments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vk7_shipments_id_seq', 1, false);


--
-- Name: vk7_stock_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vk7_stock_log_id_seq', 1, false);


--
-- Name: wishlist_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wishlist_id_seq', 1, false);


--
-- Name: wishlist_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wishlist_items_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

