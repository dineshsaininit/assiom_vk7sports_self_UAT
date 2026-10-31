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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id integer NOT NULL,
    address_type character varying(255) NOT NULL,
    customer_id integer,
    cart_id integer,
    order_id integer,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    gender character varying(255),
    company_name character varying(255),
    address character varying(255) NOT NULL,
    city character varying(255) NOT NULL,
    state character varying(255),
    country character varying(255),
    postcode character varying(255),
    email character varying(255),
    phone character varying(255),
    vat_id character varying(255),
    default_address boolean DEFAULT false NOT NULL,
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    parent_address_id integer,
    use_for_shipping boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN addresses.customer_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.addresses.customer_id IS 'null if guest checkout';


--
-- Name: COLUMN addresses.cart_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.addresses.cart_id IS 'only for cart_addresses';


--
-- Name: COLUMN addresses.order_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.addresses.order_id IS 'only for order_addresses';


--
-- Name: COLUMN addresses.default_address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.addresses.default_address IS 'only for customer_addresses';


--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addresses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addresses_id_seq OWNED BY public.addresses.id;


--
-- Name: admin_password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_password_resets (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255),
    api_token character varying(80),
    status boolean DEFAULT false NOT NULL,
    role_id integer NOT NULL,
    image character varying(255),
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    two_factor_secret text,
    two_factor_enabled boolean DEFAULT false NOT NULL,
    two_factor_backup_codes jsonb,
    two_factor_verified_at timestamp(0) without time zone,
    two_factor_last_used_window bigint
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: agent_conversation_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_conversation_messages (
    id character varying(36) NOT NULL,
    conversation_id character varying(36) NOT NULL,
    user_id bigint,
    agent character varying(255) NOT NULL,
    role character varying(25) NOT NULL,
    content text NOT NULL,
    attachments text NOT NULL,
    tool_calls text NOT NULL,
    tool_results text NOT NULL,
    usage text NOT NULL,
    meta text NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: agent_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_conversations (
    id character varying(36) NOT NULL,
    user_id bigint,
    title character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: attribute_families; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_families (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    status boolean DEFAULT false NOT NULL,
    is_user_defined boolean DEFAULT true NOT NULL
);


--
-- Name: attribute_families_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_families_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_families_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_families_id_seq OWNED BY public.attribute_families.id;


--
-- Name: attribute_group_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_group_mappings (
    attribute_id integer NOT NULL,
    attribute_group_id integer NOT NULL,
    "position" integer
);


--
-- Name: attribute_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_groups (
    id integer NOT NULL,
    attribute_family_id integer NOT NULL,
    name character varying(255) NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    is_user_defined boolean DEFAULT true NOT NULL,
    "column" integer DEFAULT 1 NOT NULL,
    code character varying(255)
);


--
-- Name: attribute_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_groups_id_seq OWNED BY public.attribute_groups.id;


--
-- Name: attribute_option_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_option_translations (
    id integer NOT NULL,
    attribute_option_id integer NOT NULL,
    locale character varying(255) NOT NULL,
    label text,
    swatch_alt text
);


--
-- Name: attribute_option_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_option_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_option_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_option_translations_id_seq OWNED BY public.attribute_option_translations.id;


--
-- Name: attribute_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_options (
    id integer NOT NULL,
    attribute_id integer NOT NULL,
    admin_name character varying(255),
    sort_order integer,
    swatch_value character varying(255)
);


--
-- Name: attribute_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_options_id_seq OWNED BY public.attribute_options.id;


--
-- Name: attribute_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attribute_translations (
    id integer NOT NULL,
    attribute_id integer NOT NULL,
    locale character varying(255) NOT NULL,
    name text
);


--
-- Name: attribute_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attribute_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attribute_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attribute_translations_id_seq OWNED BY public.attribute_translations.id;


--
-- Name: attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attributes (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    admin_name character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    swatch_type character varying(255),
    validation character varying(255),
    "position" integer,
    is_required boolean DEFAULT false NOT NULL,
    is_unique boolean DEFAULT false NOT NULL,
    is_filterable boolean DEFAULT false NOT NULL,
    is_comparable boolean DEFAULT false NOT NULL,
    is_configurable boolean DEFAULT false NOT NULL,
    is_user_defined boolean DEFAULT true NOT NULL,
    is_visible_on_front boolean DEFAULT false NOT NULL,
    value_per_locale boolean DEFAULT false NOT NULL,
    value_per_channel boolean DEFAULT false NOT NULL,
    enable_wysiwyg boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    regex character varying(255),
    default_value integer
);


--
-- Name: attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attributes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attributes_id_seq OWNED BY public.attributes.id;


--
-- Name: b2b_company_attribute_group_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_attribute_group_mappings (
    id bigint NOT NULL,
    company_attribute_id bigint NOT NULL,
    company_attribute_group_id bigint NOT NULL,
    "position" integer
);


--
-- Name: b2b_company_attribute_group_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_attribute_group_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_attribute_group_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_attribute_group_mappings_id_seq OWNED BY public.b2b_company_attribute_group_mappings.id;


--
-- Name: b2b_company_attribute_group_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_attribute_group_translations (
    id bigint NOT NULL,
    company_attribute_group_id bigint NOT NULL,
    locale character varying(255) NOT NULL,
    name text
);


--
-- Name: b2b_company_attribute_group_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_attribute_group_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_attribute_group_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_attribute_group_translations_id_seq OWNED BY public.b2b_company_attribute_group_translations.id;


--
-- Name: b2b_company_attribute_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_attribute_groups (
    id bigint NOT NULL,
    code character varying(255) NOT NULL,
    admin_name character varying(255) NOT NULL,
    "column" integer DEFAULT 1 NOT NULL,
    "position" integer NOT NULL,
    is_user_defined boolean DEFAULT true NOT NULL
);


--
-- Name: b2b_company_attribute_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_attribute_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_attribute_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_attribute_groups_id_seq OWNED BY public.b2b_company_attribute_groups.id;


--
-- Name: b2b_company_attribute_option_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_attribute_option_translations (
    id bigint NOT NULL,
    company_attribute_option_id bigint NOT NULL,
    locale character varying(255) NOT NULL,
    label text
);


--
-- Name: b2b_company_attribute_option_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_attribute_option_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_attribute_option_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_attribute_option_translations_id_seq OWNED BY public.b2b_company_attribute_option_translations.id;


--
-- Name: b2b_company_attribute_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_attribute_options (
    id bigint NOT NULL,
    company_attribute_id bigint NOT NULL,
    admin_name character varying(255),
    sort_order integer
);


--
-- Name: b2b_company_attribute_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_attribute_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_attribute_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_attribute_options_id_seq OWNED BY public.b2b_company_attribute_options.id;


--
-- Name: b2b_company_attribute_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_attribute_translations (
    id bigint NOT NULL,
    company_attribute_id bigint NOT NULL,
    locale character varying(255) NOT NULL,
    name text
);


--
-- Name: b2b_company_attribute_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_attribute_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_attribute_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_attribute_translations_id_seq OWNED BY public.b2b_company_attribute_translations.id;


--
-- Name: b2b_company_attribute_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_attribute_values (
    id bigint NOT NULL,
    locale character varying(255),
    channel character varying(255),
    text_value text,
    boolean_value boolean,
    integer_value integer,
    float_value numeric(12,4),
    datetime_value timestamp(0) without time zone,
    date_value date,
    "json_value" json,
    customer_id integer NOT NULL,
    company_attribute_id bigint NOT NULL,
    unique_id character varying(255)
);


--
-- Name: b2b_company_attribute_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_attribute_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_attribute_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_attribute_values_id_seq OWNED BY public.b2b_company_attribute_values.id;


--
-- Name: b2b_company_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_attributes (
    id bigint NOT NULL,
    code character varying(255) NOT NULL,
    admin_name character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    validation character varying(255),
    regex character varying(255),
    "position" integer,
    is_required boolean DEFAULT false NOT NULL,
    is_unique boolean DEFAULT false NOT NULL,
    is_user_defined boolean DEFAULT true NOT NULL,
    is_visible_on_sign_up boolean DEFAULT false NOT NULL,
    default_value boolean,
    value_per_locale boolean DEFAULT false NOT NULL,
    value_per_channel boolean DEFAULT false NOT NULL,
    enable_editor boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_company_attributes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_attributes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_attributes_id_seq OWNED BY public.b2b_company_attributes.id;


--
-- Name: b2b_company_catalog_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_catalog_categories (
    id integer NOT NULL,
    company_catalog_id integer NOT NULL,
    category_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_company_catalog_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_catalog_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_catalog_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_catalog_categories_id_seq OWNED BY public.b2b_company_catalog_categories.id;


--
-- Name: b2b_company_catalog_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_catalog_products (
    id integer NOT NULL,
    company_catalog_id integer NOT NULL,
    product_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_company_catalog_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_catalog_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_catalog_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_catalog_products_id_seq OWNED BY public.b2b_company_catalog_products.id;


--
-- Name: b2b_company_catalogs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_catalogs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    status boolean DEFAULT true NOT NULL,
    customer_group_id integer,
    created_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_company_catalogs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_catalogs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_catalogs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_catalogs_id_seq OWNED BY public.b2b_company_catalogs.id;


--
-- Name: b2b_company_credit_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_credit_transactions (
    id integer NOT NULL,
    company_credit_id integer NOT NULL,
    operation character varying(255) NOT NULL,
    amount numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    outstanding_balance_after numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    available_credit_after numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    credit_limit_after numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    order_id integer,
    reference character varying(255),
    comment text,
    actor_type character varying(255),
    actor_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT b2b_company_credit_transactions_operation_check CHECK (((operation)::text = ANY ((ARRAY['allocated'::character varying, 'updated'::character varying, 'purchased'::character varying, 'reimbursed'::character varying, 'refunded'::character varying, 'reverted'::character varying])::text[])))
);


--
-- Name: b2b_company_credit_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_credit_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_credit_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_credit_transactions_id_seq OWNED BY public.b2b_company_credit_transactions.id;


--
-- Name: b2b_company_credits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_credits (
    id integer NOT NULL,
    company_id integer NOT NULL,
    credit_currency_code character varying(255),
    credit_limit numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    outstanding_balance numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    allow_exceed_limit boolean DEFAULT false NOT NULL,
    status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_company_credits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_credits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_credits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_credits_id_seq OWNED BY public.b2b_company_credits.id;


--
-- Name: b2b_company_flat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_flat (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    locale character varying(255),
    channel character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    email character varying(255),
    phone character varying(255),
    business_name character varying(255),
    website_url character varying(255),
    vat_tax_id character varying(255),
    address text,
    city character varying(255),
    country character varying(255),
    state character varying(255),
    postcode character varying(255),
    meta_title text,
    meta_keywords text,
    meta_description text,
    return_policy text,
    shipping_policy text,
    privacy_policy text,
    facebook character varying(255),
    instagram character varying(255),
    youtube character varying(255),
    twitter character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_company_flat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_flat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_flat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_flat_id_seq OWNED BY public.b2b_company_flat.id;


--
-- Name: b2b_company_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_invitations (
    id bigint NOT NULL,
    company_id integer NOT NULL,
    email character varying(255) NOT NULL,
    company_role_id integer,
    invited_by integer,
    token character varying(64) NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_company_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_invitations_id_seq OWNED BY public.b2b_company_invitations.id;


--
-- Name: b2b_company_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_company_roles (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    permission_type character varying(255) DEFAULT 'custom'::character varying NOT NULL,
    permissions json,
    customer_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT b2b_company_roles_permission_type_check CHECK (((permission_type)::text = ANY ((ARRAY['all'::character varying, 'custom'::character varying])::text[])))
);


--
-- Name: b2b_company_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_company_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_company_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_company_roles_id_seq OWNED BY public.b2b_company_roles.id;


--
-- Name: b2b_customer_companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_customer_companies (
    customer_id integer NOT NULL,
    company_id integer NOT NULL
);


--
-- Name: b2b_customer_quote_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_customer_quote_attachments (
    id bigint NOT NULL,
    customer_quote_id integer NOT NULL,
    name character varying(255) NOT NULL,
    path character varying(255) NOT NULL,
    mime_type character varying(255),
    size bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_customer_quote_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_customer_quote_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_customer_quote_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_customer_quote_attachments_id_seq OWNED BY public.b2b_customer_quote_attachments.id;


--
-- Name: b2b_customer_quote_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_customer_quote_items (
    id integer NOT NULL,
    customer_quote_id integer NOT NULL,
    product_id integer,
    type character varying(255) NOT NULL,
    sku character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    qty integer DEFAULT 1 NOT NULL,
    price numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_price numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    negotiated_qty integer DEFAULT 1 NOT NULL,
    negotiated_price numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_negotiated_price numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    negotiated_total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_negotiated_total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    discount_type character varying(255),
    discount_value numeric(18,4),
    note text,
    status character varying(255) DEFAULT 'draft'::character varying NOT NULL,
    additional json,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT b2b_customer_quote_items_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'open'::character varying, 'negotiation'::character varying, 'accepted'::character varying, 'ordered'::character varying, 'expired'::character varying, 'rejected'::character varying, 'completed'::character varying])::text[])))
);


--
-- Name: b2b_customer_quote_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_customer_quote_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_customer_quote_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_customer_quote_items_id_seq OWNED BY public.b2b_customer_quote_items.id;


--
-- Name: b2b_customer_quote_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_customer_quote_messages (
    id integer NOT NULL,
    quote_id integer NOT NULL,
    user_id integer NOT NULL,
    user_type character varying(255) NOT NULL,
    message text NOT NULL,
    status character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_customer_quote_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_customer_quote_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_customer_quote_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_customer_quote_messages_id_seq OWNED BY public.b2b_customer_quote_messages.id;


--
-- Name: b2b_customer_quote_quotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_customer_quote_quotations (
    id integer NOT NULL,
    message_id integer NOT NULL,
    quote_id integer NOT NULL,
    quote_item_id integer NOT NULL,
    sku character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    qty integer DEFAULT 1 NOT NULL,
    discount_type character varying(255),
    discount_value numeric(12,4),
    price numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_price numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    is_accepted boolean DEFAULT false NOT NULL,
    accepted_by character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: b2b_customer_quote_quotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_customer_quote_quotations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_customer_quote_quotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_customer_quote_quotations_id_seq OWNED BY public.b2b_customer_quote_quotations.id;


--
-- Name: b2b_customer_quotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_customer_quotes (
    id integer NOT NULL,
    quotation_number character varying(255),
    po_number character varying(255),
    shipping_number character varying(255),
    name character varying(255) NOT NULL,
    description text,
    company_id integer NOT NULL,
    customer_id integer,
    customer_name character varying(255),
    customer_email character varying(255),
    agent_id integer,
    total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    negotiated_total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_negotiated_total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    discount_type character varying(255),
    discount_value numeric(18,4),
    order_date date,
    expected_arrival_date date,
    expiration_date date,
    soft_deleted boolean DEFAULT false NOT NULL,
    state character varying(255) DEFAULT 'quotation'::character varying NOT NULL,
    status character varying(255) DEFAULT 'draft'::character varying NOT NULL,
    order_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT b2b_customer_quotes_state_check CHECK (((state)::text = ANY ((ARRAY['quotation'::character varying, 'purchase_order'::character varying])::text[]))),
    CONSTRAINT b2b_customer_quotes_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'open'::character varying, 'negotiation'::character varying, 'accepted'::character varying, 'ordered'::character varying, 'expired'::character varying, 'rejected'::character varying, 'completed'::character varying])::text[])))
);


--
-- Name: b2b_customer_quotes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_customer_quotes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_customer_quotes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_customer_quotes_id_seq OWNED BY public.b2b_customer_quotes.id;


--
-- Name: b2b_customer_requisition_list_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_customer_requisition_list_products (
    id integer NOT NULL,
    requisition_list_id integer NOT NULL,
    product_id integer NOT NULL,
    variant_id integer,
    type character varying(255) NOT NULL,
    sku character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    qty integer DEFAULT 1 NOT NULL,
    price numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_price numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    base_total numeric(18,4) DEFAULT '0'::numeric NOT NULL,
    additional json
);


--
-- Name: b2b_customer_requisition_list_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_customer_requisition_list_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_customer_requisition_list_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_customer_requisition_list_products_id_seq OWNED BY public.b2b_customer_requisition_list_products.id;


--
-- Name: b2b_customer_requisition_lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_customer_requisition_lists (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    company_id integer NOT NULL,
    customer_id integer NOT NULL,
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT b2b_customer_requisition_lists_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'inactive'::character varying])::text[])))
);


--
-- Name: b2b_customer_requisition_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.b2b_customer_requisition_lists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: b2b_customer_requisition_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.b2b_customer_requisition_lists_id_seq OWNED BY public.b2b_customer_requisition_lists.id;


--
-- Name: booking_product_appointment_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_product_appointment_slots (
    id bigint NOT NULL,
    booking_product_id integer NOT NULL,
    duration integer,
    break_time integer,
    same_slot_all_days boolean,
    slots jsonb,
    allow_slot_overlap boolean DEFAULT false NOT NULL
);


--
-- Name: booking_product_appointment_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.booking_product_appointment_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: booking_product_appointment_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.booking_product_appointment_slots_id_seq OWNED BY public.booking_product_appointment_slots.id;


--
-- Name: booking_product_default_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_product_default_slots (
    id bigint NOT NULL,
    booking_product_id integer NOT NULL,
    booking_type character varying(255) NOT NULL,
    duration integer,
    break_time integer,
    slots jsonb,
    allow_slot_overlap boolean DEFAULT false NOT NULL
);


--
-- Name: booking_product_default_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.booking_product_default_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: booking_product_default_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.booking_product_default_slots_id_seq OWNED BY public.booking_product_default_slots.id;


--
-- Name: booking_product_event_ticket_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_product_event_ticket_translations (
    id bigint NOT NULL,
    booking_product_event_ticket_id bigint NOT NULL,
    locale character varying(255) NOT NULL,
    name text,
    description text
);


--
-- Name: booking_product_event_ticket_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.booking_product_event_ticket_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: booking_product_event_ticket_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.booking_product_event_ticket_translations_id_seq OWNED BY public.booking_product_event_ticket_translations.id;


--
-- Name: booking_product_event_tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_product_event_tickets (
    id bigint NOT NULL,
    booking_product_id integer NOT NULL,
    price numeric(12,4) DEFAULT '0'::numeric,
    qty integer DEFAULT 0,
    special_price numeric(12,4),
    special_price_from timestamp(0) without time zone,
    special_price_to timestamp(0) without time zone
);


--
-- Name: booking_product_event_tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.booking_product_event_tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: booking_product_event_tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.booking_product_event_tickets_id_seq OWNED BY public.booking_product_event_tickets.id;


--
-- Name: booking_product_rental_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_product_rental_slots (
    id bigint NOT NULL,
    booking_product_id integer NOT NULL,
    renting_type character varying(255) NOT NULL,
    daily_price numeric(12,4) DEFAULT '0'::numeric,
    hourly_price numeric(12,4) DEFAULT '0'::numeric,
    same_slot_all_days boolean,
    slots jsonb
);


--
-- Name: booking_product_rental_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.booking_product_rental_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: booking_product_rental_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.booking_product_rental_slots_id_seq OWNED BY public.booking_product_rental_slots.id;


--
-- Name: booking_product_table_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_product_table_slots (
    id bigint NOT NULL,
    booking_product_id integer NOT NULL,
    price_type character varying(255) NOT NULL,
    guest_limit integer DEFAULT 0 NOT NULL,
    duration integer NOT NULL,
    break_time integer NOT NULL,
    prevent_scheduling_before integer NOT NULL,
    same_slot_all_days boolean,
    slots jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    allow_slot_overlap boolean DEFAULT false NOT NULL
);


--
-- Name: booking_product_table_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.booking_product_table_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: booking_product_table_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.booking_product_table_slots_id_seq OWNED BY public.booking_product_table_slots.id;


--
-- Name: booking_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.booking_products (
    id integer NOT NULL,
    product_id integer NOT NULL,
    type character varying(255) NOT NULL,
    qty integer DEFAULT 0,
    location character varying(255),
    show_location boolean DEFAULT false NOT NULL,
    available_every_week boolean,
    available_from timestamp(0) without time zone,
    available_to timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    allow_cancellation boolean DEFAULT true NOT NULL
);


--
-- Name: booking_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.booking_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: booking_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.booking_products_id_seq OWNED BY public.booking_products.id;


--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id bigint NOT NULL,
    product_id integer,
    order_item_id integer,
    order_id integer,
    qty integer DEFAULT 0,
    "from" integer,
    "to" integer,
    booking_product_event_ticket_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    allow_cancellation boolean DEFAULT true NOT NULL
);


--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bookings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;


--
-- Name: cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL
);


--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration integer NOT NULL
);


--
-- Name: cart; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart (
    id integer NOT NULL,
    customer_email character varying(255),
    customer_first_name character varying(255),
    customer_last_name character varying(255),
    shipping_method character varying(255),
    coupon_code character varying(255),
    is_gift boolean DEFAULT false NOT NULL,
    items_count integer,
    items_qty numeric(12,4),
    exchange_rate numeric(12,4),
    global_currency_code character varying(255),
    base_currency_code character varying(255),
    channel_currency_code character varying(255),
    cart_currency_code character varying(255),
    grand_total numeric(12,4) DEFAULT '0'::numeric,
    base_grand_total numeric(12,4) DEFAULT '0'::numeric,
    sub_total numeric(12,4) DEFAULT '0'::numeric,
    base_sub_total numeric(12,4) DEFAULT '0'::numeric,
    tax_total numeric(12,4) DEFAULT '0'::numeric,
    base_tax_total numeric(12,4) DEFAULT '0'::numeric,
    discount_amount numeric(12,4) DEFAULT '0'::numeric,
    base_discount_amount numeric(12,4) DEFAULT '0'::numeric,
    checkout_method character varying(255),
    is_guest boolean,
    is_active boolean DEFAULT true,
    applied_cart_rule_ids character varying(255),
    customer_id integer,
    channel_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    shipping_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_shipping_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    shipping_amount_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_shipping_amount_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    sub_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_sub_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    company_id integer
);


--
-- Name: cart_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_id_seq OWNED BY public.cart.id;


--
-- Name: cart_item_inventories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_item_inventories (
    id integer NOT NULL,
    qty integer DEFAULT 0 NOT NULL,
    inventory_source_id integer,
    cart_item_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: cart_item_inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_item_inventories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_item_inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_item_inventories_id_seq OWNED BY public.cart_item_inventories.id;


--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_items (
    id integer NOT NULL,
    quantity integer DEFAULT 0 NOT NULL,
    sku character varying(255),
    type character varying(255),
    name character varying(255),
    coupon_code character varying(255),
    weight numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    total_weight numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total_weight numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    price numeric(12,4) DEFAULT '1'::numeric NOT NULL,
    base_price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    custom_price numeric(12,4),
    total numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    tax_percent numeric(12,4) DEFAULT '0'::numeric,
    tax_amount numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount numeric(12,4) DEFAULT '0'::numeric,
    discount_percent numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    discount_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_discount_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    parent_id integer,
    product_id integer NOT NULL,
    cart_id integer NOT NULL,
    tax_category_id integer,
    applied_cart_rule_ids character varying(255),
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    applied_tax_rate character varying(255)
);


--
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- Name: cart_payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_payment (
    id integer NOT NULL,
    method character varying(255) NOT NULL,
    method_title character varying(255),
    cart_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: cart_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_payment_id_seq OWNED BY public.cart_payment.id;


--
-- Name: cart_rule_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_rule_channels (
    cart_rule_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: cart_rule_coupon_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_rule_coupon_usage (
    id integer NOT NULL,
    times_used integer DEFAULT 0 NOT NULL,
    cart_rule_coupon_id integer NOT NULL,
    customer_id integer NOT NULL
);


--
-- Name: cart_rule_coupon_usage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_rule_coupon_usage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_rule_coupon_usage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_rule_coupon_usage_id_seq OWNED BY public.cart_rule_coupon_usage.id;


--
-- Name: cart_rule_coupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_rule_coupons (
    id integer NOT NULL,
    code character varying(255),
    usage_limit integer DEFAULT 0 NOT NULL,
    usage_per_customer integer DEFAULT 0 NOT NULL,
    times_used integer DEFAULT 0 NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    expired_at date,
    cart_rule_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: cart_rule_coupons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_rule_coupons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_rule_coupons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_rule_coupons_id_seq OWNED BY public.cart_rule_coupons.id;


--
-- Name: cart_rule_customer_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_rule_customer_groups (
    cart_rule_id integer NOT NULL,
    customer_group_id integer NOT NULL
);


--
-- Name: cart_rule_customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_rule_customers (
    id integer NOT NULL,
    times_used bigint DEFAULT '0'::bigint NOT NULL,
    customer_id integer NOT NULL,
    cart_rule_id integer NOT NULL
);


--
-- Name: cart_rule_customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_rule_customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_rule_customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_rule_customers_id_seq OWNED BY public.cart_rule_customers.id;


--
-- Name: cart_rule_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_rule_translations (
    id integer NOT NULL,
    locale character varying(255) NOT NULL,
    label text,
    cart_rule_id integer NOT NULL
);


--
-- Name: cart_rule_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_rule_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_rule_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_rule_translations_id_seq OWNED BY public.cart_rule_translations.id;


--
-- Name: cart_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_rules (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    starts_from timestamp(0) without time zone,
    ends_till timestamp(0) without time zone,
    status boolean DEFAULT false NOT NULL,
    coupon_type integer DEFAULT 1 NOT NULL,
    use_auto_generation boolean DEFAULT false NOT NULL,
    usage_per_customer integer DEFAULT 0 NOT NULL,
    uses_per_coupon integer DEFAULT 0 NOT NULL,
    times_used integer DEFAULT 0 NOT NULL,
    condition_type smallint DEFAULT '1'::smallint NOT NULL,
    conditions jsonb,
    end_other_rules boolean DEFAULT false NOT NULL,
    uses_attribute_conditions boolean DEFAULT false NOT NULL,
    action_type character varying(255),
    discount_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    discount_quantity integer DEFAULT 1 NOT NULL,
    discount_step character varying(255) DEFAULT '1'::character varying NOT NULL,
    apply_to_shipping boolean DEFAULT false NOT NULL,
    free_shipping boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: cart_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_rules_id_seq OWNED BY public.cart_rules.id;


--
-- Name: cart_shipping_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cart_shipping_rates (
    id integer NOT NULL,
    carrier character varying(255) NOT NULL,
    carrier_title character varying(255) NOT NULL,
    method character varying(255) NOT NULL,
    method_title character varying(255) NOT NULL,
    method_description character varying(255),
    price double precision DEFAULT '0'::double precision,
    base_price double precision DEFAULT '0'::double precision,
    discount_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_discount_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    is_calculate_tax boolean DEFAULT true NOT NULL,
    cart_address_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    cart_id integer,
    tax_percent numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    tax_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_tax_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    applied_tax_rate character varying(255)
);


--
-- Name: cart_shipping_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_shipping_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_shipping_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_shipping_rates_id_seq OWNED BY public.cart_shipping_rates.id;


--
-- Name: catalog_rule_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.catalog_rule_channels (
    catalog_rule_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: catalog_rule_customer_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.catalog_rule_customer_groups (
    catalog_rule_id integer NOT NULL,
    customer_group_id integer NOT NULL
);


--
-- Name: catalog_rule_product_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.catalog_rule_product_prices (
    id integer NOT NULL,
    price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    rule_date date NOT NULL,
    starts_from timestamp(0) without time zone,
    ends_till timestamp(0) without time zone,
    product_id integer NOT NULL,
    customer_group_id integer NOT NULL,
    catalog_rule_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: catalog_rule_product_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.catalog_rule_product_prices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalog_rule_product_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.catalog_rule_product_prices_id_seq OWNED BY public.catalog_rule_product_prices.id;


--
-- Name: catalog_rule_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.catalog_rule_products (
    id integer NOT NULL,
    starts_from timestamp(0) without time zone,
    ends_till timestamp(0) without time zone,
    end_other_rules boolean DEFAULT false NOT NULL,
    action_type character varying(255),
    discount_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    product_id integer NOT NULL,
    customer_group_id integer NOT NULL,
    catalog_rule_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: catalog_rule_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.catalog_rule_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalog_rule_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.catalog_rule_products_id_seq OWNED BY public.catalog_rule_products.id;


--
-- Name: catalog_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.catalog_rules (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    starts_from date,
    ends_till date,
    status boolean DEFAULT false NOT NULL,
    condition_type smallint DEFAULT '1'::smallint NOT NULL,
    conditions jsonb,
    end_other_rules boolean DEFAULT false NOT NULL,
    action_type character varying(255),
    discount_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: catalog_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.catalog_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalog_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.catalog_rules_id_seq OWNED BY public.catalog_rules.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    status boolean DEFAULT false NOT NULL,
    display_mode character varying(255) DEFAULT 'products_and_description'::character varying,
    _lft integer DEFAULT 0 NOT NULL,
    _rgt integer DEFAULT 0 NOT NULL,
    parent_id integer,
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    logo_path text,
    banner_path text
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: category_filterable_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_filterable_attributes (
    category_id integer NOT NULL,
    attribute_id integer NOT NULL
);


--
-- Name: category_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_translations (
    id integer NOT NULL,
    category_id integer NOT NULL,
    name text NOT NULL,
    slug character varying(255) NOT NULL,
    url_path character varying(2048),
    description text,
    meta_title text,
    meta_description text,
    meta_keywords text,
    locale_id integer,
    locale character varying(255) NOT NULL,
    logo_alt text,
    banner_alt text
);


--
-- Name: category_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.category_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: category_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.category_translations_id_seq OWNED BY public.category_translations.id;


--
-- Name: channel_currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channel_currencies (
    channel_id integer NOT NULL,
    currency_id integer NOT NULL
);


--
-- Name: channel_inventory_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channel_inventory_sources (
    channel_id integer NOT NULL,
    inventory_source_id integer NOT NULL
);


--
-- Name: channel_locales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channel_locales (
    channel_id integer NOT NULL,
    locale_id integer NOT NULL
);


--
-- Name: channel_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channel_translations (
    id bigint NOT NULL,
    channel_id integer NOT NULL,
    locale character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    maintenance_mode_text text,
    home_seo jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    logo_alt text
);


--
-- Name: channel_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.channel_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channel_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.channel_translations_id_seq OWNED BY public.channel_translations.id;


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channels (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    timezone character varying(255),
    theme character varying(255),
    hostname character varying(255),
    logo character varying(255),
    favicon character varying(255),
    home_seo jsonb,
    is_maintenance_on boolean DEFAULT false NOT NULL,
    allowed_ips text,
    root_category_id integer,
    default_locale_id integer NOT NULL,
    base_currency_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.channels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.channels_id_seq OWNED BY public.channels.id;


--
-- Name: cms_page_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cms_page_channels (
    cms_page_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: cms_page_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cms_page_translations (
    id integer NOT NULL,
    page_title character varying(255) NOT NULL,
    url_key character varying(255) NOT NULL,
    html_content text,
    meta_title text,
    meta_description text,
    meta_keywords text,
    locale character varying(255) NOT NULL,
    cms_page_id integer NOT NULL
);


--
-- Name: cms_page_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cms_page_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cms_page_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cms_page_translations_id_seq OWNED BY public.cms_page_translations.id;


--
-- Name: cms_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cms_pages (
    id integer NOT NULL,
    layout character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: cms_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cms_pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cms_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cms_pages_id_seq OWNED BY public.cms_pages.id;


--
-- Name: compare_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.compare_items (
    id integer NOT NULL,
    product_id integer NOT NULL,
    customer_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: compare_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.compare_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: compare_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.compare_items_id_seq OWNED BY public.compare_items.id;


--
-- Name: core_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.core_config (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    value text NOT NULL,
    channel_code character varying(255),
    locale_code character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: core_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.core_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: core_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.core_config_id_seq OWNED BY public.core_config.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.countries (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.countries_id_seq OWNED BY public.countries.id;


--
-- Name: country_state_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_state_translations (
    id integer NOT NULL,
    country_state_id integer NOT NULL,
    locale character varying(255) NOT NULL,
    default_name text
);


--
-- Name: country_state_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_state_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_state_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_state_translations_id_seq OWNED BY public.country_state_translations.id;


--
-- Name: country_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_states (
    id integer NOT NULL,
    country_id integer,
    country_code character varying(255),
    code character varying(255),
    default_name character varying(255)
);


--
-- Name: country_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_states_id_seq OWNED BY public.country_states.id;


--
-- Name: country_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country_translations (
    id integer NOT NULL,
    country_id integer NOT NULL,
    locale character varying(255) NOT NULL,
    name text
);


--
-- Name: country_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.country_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: country_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.country_translations_id_seq OWNED BY public.country_translations.id;


--
-- Name: currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currencies (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    symbol character varying(255),
    "decimal" integer DEFAULT 2 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    group_separator character varying(255) DEFAULT ','::character varying NOT NULL,
    decimal_separator character varying(255) DEFAULT '.'::character varying NOT NULL,
    currency_position character varying(255)
);


--
-- Name: currencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.currencies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: currencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.currencies_id_seq OWNED BY public.currencies.id;


--
-- Name: currency_exchange_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currency_exchange_rates (
    id integer NOT NULL,
    rate numeric(24,12) NOT NULL,
    target_currency integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: currency_exchange_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.currency_exchange_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: currency_exchange_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.currency_exchange_rates_id_seq OWNED BY public.currency_exchange_rates.id;


--
-- Name: customer_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_groups (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    is_user_defined boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: customer_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_groups_id_seq OWNED BY public.customer_groups.id;


--
-- Name: customer_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_notes (
    id bigint NOT NULL,
    customer_id integer,
    note text NOT NULL,
    customer_notified boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: customer_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_notes_id_seq OWNED BY public.customer_notes.id;


--
-- Name: customer_password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_password_resets (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: customer_social_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customer_social_accounts (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    provider_name character varying(255),
    provider_id character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: customer_social_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customer_social_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_social_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customer_social_accounts_id_seq OWNED BY public.customer_social_accounts.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    gender character varying(50),
    date_of_birth date,
    email character varying(255),
    phone character varying(255),
    image character varying(255),
    status smallint DEFAULT '1'::smallint NOT NULL,
    password character varying(255),
    api_token character varying(80),
    customer_group_id integer,
    subscribed_to_news_letter boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    is_suspended smallint DEFAULT '0'::smallint NOT NULL,
    token character varying(255),
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    channel_id integer,
    type character varying(255) DEFAULT 'user'::character varying NOT NULL,
    company_role_id integer,
    company_catalog_id integer,
    sales_rep_id integer,
    CONSTRAINT customers_type_check CHECK (((type)::text = ANY ((ARRAY['user'::character varying, 'company'::character varying])::text[])))
);


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: datagrid_saved_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.datagrid_saved_filters (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    name character varying(255) NOT NULL,
    src character varying(255) NOT NULL,
    applied jsonb NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: datagrid_saved_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.datagrid_saved_filters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datagrid_saved_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.datagrid_saved_filters_id_seq OWNED BY public.datagrid_saved_filters.id;


--
-- Name: downloadable_link_purchased; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.downloadable_link_purchased (
    id integer NOT NULL,
    product_name character varying(255),
    name character varying(255),
    url character varying(255),
    file character varying(255),
    file_name character varying(255),
    type character varying(255) NOT NULL,
    download_bought integer DEFAULT 0 NOT NULL,
    download_used integer DEFAULT 0 NOT NULL,
    status character varying(255),
    customer_id integer NOT NULL,
    order_id integer NOT NULL,
    order_item_id integer NOT NULL,
    download_canceled integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: downloadable_link_purchased_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.downloadable_link_purchased_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: downloadable_link_purchased_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.downloadable_link_purchased_id_seq OWNED BY public.downloadable_link_purchased.id;


--
-- Name: eu_withdrawals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eu_withdrawals (
    id bigint NOT NULL,
    uuid uuid NOT NULL,
    order_id integer NOT NULL,
    customer_id integer,
    is_guest boolean DEFAULT false NOT NULL,
    customer_email character varying(255) NOT NULL,
    channel_id integer NOT NULL,
    locale character varying(10) NOT NULL,
    reason_text text,
    received_at timestamp(0) without time zone NOT NULL,
    confirmation_sent_at timestamp(0) without time zone,
    final_confirmation_sent_at timestamp(0) without time zone,
    confirmation_error character varying(500),
    status character varying(30) DEFAULT 'received'::character varying NOT NULL,
    declined_at timestamp(0) without time zone,
    declined_reason character varying(500),
    declined_by_user_id integer,
    refunded_at timestamp(0) without time zone,
    refunded_by_user_id integer,
    refund_note character varying(500),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: eu_withdrawals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.eu_withdrawals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eu_withdrawals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.eu_withdrawals_id_seq OWNED BY public.eu_withdrawals.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: gdpr_data_request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gdpr_data_request (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    email character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    message character varying(500) NOT NULL,
    revoked_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: gdpr_data_request_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gdpr_data_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gdpr_data_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gdpr_data_request_id_seq OWNED BY public.gdpr_data_request.id;


--
-- Name: import_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_batches (
    id integer NOT NULL,
    state character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    data jsonb NOT NULL,
    summary jsonb,
    import_id integer NOT NULL
);


--
-- Name: import_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.import_batches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.import_batches_id_seq OWNED BY public.import_batches.id;


--
-- Name: imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imports (
    id integer NOT NULL,
    state character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    process_in_queue boolean DEFAULT true NOT NULL,
    type character varying(255) NOT NULL,
    action character varying(255) NOT NULL,
    validation_strategy character varying(255) NOT NULL,
    allowed_errors integer DEFAULT 0 NOT NULL,
    processed_rows_count integer DEFAULT 0 NOT NULL,
    invalid_rows_count integer DEFAULT 0 NOT NULL,
    errors_count integer DEFAULT 0 NOT NULL,
    errors jsonb,
    field_separator character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL,
    images_directory_path character varying(255),
    error_file_path character varying(255),
    summary jsonb,
    started_at timestamp(0) without time zone,
    completed_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    image_source character varying(255) DEFAULT 'directory'::character varying NOT NULL,
    images_archive_name character varying(255)
);


--
-- Name: imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.imports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.imports_id_seq OWNED BY public.imports.id;


--
-- Name: inventory_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_sources (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    contact_name character varying(255) NOT NULL,
    contact_email character varying(255) NOT NULL,
    contact_number character varying(255) NOT NULL,
    contact_fax character varying(255),
    country character varying(255) NOT NULL,
    state character varying(255) NOT NULL,
    city character varying(255) NOT NULL,
    street character varying(255) NOT NULL,
    postcode character varying(255) NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    latitude numeric(10,5),
    longitude numeric(10,5),
    status boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: inventory_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_sources_id_seq OWNED BY public.inventory_sources.id;


--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoice_items (
    id integer NOT NULL,
    parent_id integer,
    name character varying(255),
    description character varying(255),
    sku character varying(255),
    qty integer,
    price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    total numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    tax_amount numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount numeric(12,4) DEFAULT '0'::numeric,
    discount_percent numeric(12,4) DEFAULT '0'::numeric,
    discount_amount numeric(12,4) DEFAULT '0'::numeric,
    base_discount_amount numeric(12,4) DEFAULT '0'::numeric,
    product_id integer,
    product_type character varying(255),
    order_item_id integer,
    invoice_id integer,
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL
);


--
-- Name: invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoice_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoice_items_id_seq OWNED BY public.invoice_items.id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    increment_id character varying(255),
    state character varying(255),
    email_sent boolean DEFAULT false NOT NULL,
    total_qty integer,
    base_currency_code character varying(255),
    channel_currency_code character varying(255),
    order_currency_code character varying(255),
    sub_total numeric(12,4) DEFAULT '0'::numeric,
    base_sub_total numeric(12,4) DEFAULT '0'::numeric,
    grand_total numeric(12,4) DEFAULT '0'::numeric,
    base_grand_total numeric(12,4) DEFAULT '0'::numeric,
    shipping_amount numeric(12,4) DEFAULT '0'::numeric,
    base_shipping_amount numeric(12,4) DEFAULT '0'::numeric,
    tax_amount numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount numeric(12,4) DEFAULT '0'::numeric,
    discount_amount numeric(12,4) DEFAULT '0'::numeric,
    base_discount_amount numeric(12,4) DEFAULT '0'::numeric,
    order_id integer,
    transaction_id character varying(255),
    reminders integer DEFAULT 0 NOT NULL,
    next_reminder_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    shipping_tax_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_shipping_tax_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    sub_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_sub_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    shipping_amount_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_shipping_amount_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL
);


--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: locales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locales (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    direction character varying(255) DEFAULT 'ltr'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    logo_path character varying(255),
    CONSTRAINT locales_direction_check CHECK (((direction)::text = ANY ((ARRAY['ltr'::character varying, 'rtl'::character varying])::text[])))
);


--
-- Name: locales_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locales_id_seq OWNED BY public.locales.id;


--
-- Name: marketing_campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketing_campaigns (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    status boolean DEFAULT false NOT NULL,
    spooling character varying(255),
    channel_id integer,
    customer_group_id integer,
    marketing_template_id integer,
    marketing_event_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: marketing_campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marketing_campaigns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marketing_campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marketing_campaigns_id_seq OWNED BY public.marketing_campaigns.id;


--
-- Name: marketing_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketing_events (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    date date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: marketing_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marketing_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marketing_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marketing_events_id_seq OWNED BY public.marketing_events.id;


--
-- Name: marketing_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marketing_templates (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    content text NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: marketing_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marketing_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marketing_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marketing_templates_id_seq OWNED BY public.marketing_templates.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    read boolean DEFAULT false NOT NULL,
    order_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: order_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_comments (
    id integer NOT NULL,
    order_id integer,
    comment text NOT NULL,
    customer_notified boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: order_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_comments_id_seq OWNED BY public.order_comments.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    sku character varying(255),
    type character varying(255),
    name character varying(255),
    coupon_code character varying(255),
    weight numeric(12,4) DEFAULT '0'::numeric,
    total_weight numeric(12,4) DEFAULT '0'::numeric,
    qty_ordered integer DEFAULT 0,
    qty_shipped integer DEFAULT 0,
    qty_invoiced integer DEFAULT 0,
    qty_canceled integer DEFAULT 0,
    qty_refunded integer DEFAULT 0,
    price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    total numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    total_invoiced numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total_invoiced numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    amount_refunded numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_amount_refunded numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    discount_percent numeric(12,4) DEFAULT '0'::numeric,
    discount_amount numeric(12,4) DEFAULT '0'::numeric,
    base_discount_amount numeric(12,4) DEFAULT '0'::numeric,
    discount_invoiced numeric(12,4) DEFAULT '0'::numeric,
    base_discount_invoiced numeric(12,4) DEFAULT '0'::numeric,
    discount_refunded numeric(12,4) DEFAULT '0'::numeric,
    base_discount_refunded numeric(12,4) DEFAULT '0'::numeric,
    tax_percent numeric(12,4) DEFAULT '0'::numeric,
    tax_amount numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount numeric(12,4) DEFAULT '0'::numeric,
    tax_amount_invoiced numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount_invoiced numeric(12,4) DEFAULT '0'::numeric,
    tax_amount_refunded numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount_refunded numeric(12,4) DEFAULT '0'::numeric,
    product_id integer,
    product_type character varying(255),
    order_id integer,
    parent_id integer,
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    tax_category_id integer,
    price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    rma_return_period integer
);


--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: order_payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_payment (
    id integer NOT NULL,
    order_id integer,
    method character varying(255) NOT NULL,
    method_title character varying(255),
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: order_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_payment_id_seq OWNED BY public.order_payment.id;


--
-- Name: order_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.order_transactions (
    id integer NOT NULL,
    transaction_id character varying(255) NOT NULL,
    status character varying(255),
    type character varying(255),
    amount numeric(12,4) DEFAULT '0'::numeric,
    payment_method character varying(255),
    data jsonb,
    invoice_id integer NOT NULL,
    order_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: order_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_transactions_id_seq OWNED BY public.order_transactions.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    increment_id character varying(255) NOT NULL,
    status character varying(255),
    channel_name character varying(255),
    is_guest boolean,
    customer_email character varying(255),
    customer_first_name character varying(255),
    customer_last_name character varying(255),
    shipping_method character varying(255),
    shipping_title character varying(255),
    shipping_description character varying(255),
    coupon_code character varying(255),
    is_gift boolean DEFAULT false NOT NULL,
    total_item_count integer,
    total_qty_ordered integer,
    base_currency_code character varying(255),
    channel_currency_code character varying(255),
    order_currency_code character varying(255),
    grand_total numeric(12,4) DEFAULT '0'::numeric,
    base_grand_total numeric(12,4) DEFAULT '0'::numeric,
    grand_total_invoiced numeric(12,4) DEFAULT '0'::numeric,
    base_grand_total_invoiced numeric(12,4) DEFAULT '0'::numeric,
    grand_total_refunded numeric(12,4) DEFAULT '0'::numeric,
    base_grand_total_refunded numeric(12,4) DEFAULT '0'::numeric,
    sub_total numeric(12,4) DEFAULT '0'::numeric,
    base_sub_total numeric(12,4) DEFAULT '0'::numeric,
    sub_total_invoiced numeric(12,4) DEFAULT '0'::numeric,
    base_sub_total_invoiced numeric(12,4) DEFAULT '0'::numeric,
    sub_total_refunded numeric(12,4) DEFAULT '0'::numeric,
    base_sub_total_refunded numeric(12,4) DEFAULT '0'::numeric,
    discount_percent numeric(12,4) DEFAULT '0'::numeric,
    discount_amount numeric(12,4) DEFAULT '0'::numeric,
    base_discount_amount numeric(12,4) DEFAULT '0'::numeric,
    discount_invoiced numeric(12,4) DEFAULT '0'::numeric,
    base_discount_invoiced numeric(12,4) DEFAULT '0'::numeric,
    discount_refunded numeric(12,4) DEFAULT '0'::numeric,
    base_discount_refunded numeric(12,4) DEFAULT '0'::numeric,
    tax_amount numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount numeric(12,4) DEFAULT '0'::numeric,
    tax_amount_invoiced numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount_invoiced numeric(12,4) DEFAULT '0'::numeric,
    tax_amount_refunded numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount_refunded numeric(12,4) DEFAULT '0'::numeric,
    shipping_amount numeric(12,4) DEFAULT '0'::numeric,
    base_shipping_amount numeric(12,4) DEFAULT '0'::numeric,
    shipping_invoiced numeric(12,4) DEFAULT '0'::numeric,
    base_shipping_invoiced numeric(12,4) DEFAULT '0'::numeric,
    shipping_refunded numeric(12,4) DEFAULT '0'::numeric,
    base_shipping_refunded numeric(12,4) DEFAULT '0'::numeric,
    shipping_discount_amount numeric(12,4) DEFAULT '0'::numeric,
    base_shipping_discount_amount numeric(12,4) DEFAULT '0'::numeric,
    customer_id integer,
    customer_type character varying(255),
    channel_id integer,
    channel_type character varying(255),
    cart_id integer,
    applied_cart_rule_ids character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    shipping_tax_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_shipping_tax_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    shipping_tax_refunded numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_shipping_tax_refunded numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    sub_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_sub_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    shipping_amount_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_shipping_amount_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_resets (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: product_attribute_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_attribute_values (
    id integer NOT NULL,
    locale character varying(255),
    channel character varying(255),
    text_value text,
    boolean_value boolean,
    integer_value integer,
    float_value numeric(12,4),
    datetime_value timestamp(0) without time zone,
    date_value date,
    "json_value" jsonb,
    product_id integer NOT NULL,
    attribute_id integer NOT NULL,
    unique_id character varying(255)
);


--
-- Name: product_attribute_values_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_attribute_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_attribute_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_attribute_values_id_seq OWNED BY public.product_attribute_values.id;


--
-- Name: product_bundle_option_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_bundle_option_products (
    id integer NOT NULL,
    product_id integer NOT NULL,
    product_bundle_option_id integer NOT NULL,
    qty integer DEFAULT 0 NOT NULL,
    is_user_defined boolean DEFAULT true NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL
);


--
-- Name: product_bundle_option_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_bundle_option_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_bundle_option_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_bundle_option_products_id_seq OWNED BY public.product_bundle_option_products.id;


--
-- Name: product_bundle_option_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_bundle_option_translations (
    id integer NOT NULL,
    locale character varying(255) NOT NULL,
    label character varying(255),
    product_bundle_option_id integer NOT NULL
);


--
-- Name: product_bundle_option_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_bundle_option_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_bundle_option_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_bundle_option_translations_id_seq OWNED BY public.product_bundle_option_translations.id;


--
-- Name: product_bundle_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_bundle_options (
    id integer NOT NULL,
    product_id integer NOT NULL,
    type character varying(255) NOT NULL,
    is_required boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL
);


--
-- Name: product_bundle_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_bundle_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_bundle_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_bundle_options_id_seq OWNED BY public.product_bundle_options.id;


--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_categories (
    product_id integer NOT NULL,
    category_id integer NOT NULL
);


--
-- Name: product_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_channels (
    product_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: product_cross_sells; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_cross_sells (
    parent_id integer NOT NULL,
    child_id integer NOT NULL
);


--
-- Name: product_customer_group_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_customer_group_prices (
    id bigint NOT NULL,
    qty integer DEFAULT 0 NOT NULL,
    value_type character varying(255) NOT NULL,
    value numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    product_id integer NOT NULL,
    customer_group_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    unique_id character varying(255)
);


--
-- Name: product_customer_group_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_customer_group_prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_customer_group_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_customer_group_prices_id_seq OWNED BY public.product_customer_group_prices.id;


--
-- Name: product_customizable_option_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_customizable_option_prices (
    id integer NOT NULL,
    label text,
    price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    product_customizable_option_id integer NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL
);


--
-- Name: product_customizable_option_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_customizable_option_prices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_customizable_option_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_customizable_option_prices_id_seq OWNED BY public.product_customizable_option_prices.id;


--
-- Name: product_customizable_option_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_customizable_option_translations (
    id integer NOT NULL,
    locale character varying(255) NOT NULL,
    label text,
    product_customizable_option_id integer NOT NULL
);


--
-- Name: product_customizable_option_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_customizable_option_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_customizable_option_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_customizable_option_translations_id_seq OWNED BY public.product_customizable_option_translations.id;


--
-- Name: product_customizable_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_customizable_options (
    id integer NOT NULL,
    product_id integer NOT NULL,
    type character varying(255) NOT NULL,
    is_required boolean DEFAULT true NOT NULL,
    max_characters text,
    supported_file_extensions text,
    sort_order integer DEFAULT 0 NOT NULL
);


--
-- Name: product_customizable_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_customizable_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_customizable_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_customizable_options_id_seq OWNED BY public.product_customizable_options.id;


--
-- Name: product_downloadable_link_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_downloadable_link_translations (
    id integer NOT NULL,
    product_downloadable_link_id integer NOT NULL,
    locale character varying(255) NOT NULL,
    title text
);


--
-- Name: product_downloadable_link_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_downloadable_link_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_downloadable_link_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_downloadable_link_translations_id_seq OWNED BY public.product_downloadable_link_translations.id;


--
-- Name: product_downloadable_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_downloadable_links (
    id integer NOT NULL,
    product_id integer NOT NULL,
    url character varying(255),
    file character varying(255),
    file_name character varying(255),
    type character varying(255) NOT NULL,
    price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    sample_url character varying(255),
    sample_file character varying(255),
    sample_file_name character varying(255),
    sample_type character varying(255),
    downloads integer DEFAULT 0 NOT NULL,
    sort_order integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: product_downloadable_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_downloadable_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_downloadable_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_downloadable_links_id_seq OWNED BY public.product_downloadable_links.id;


--
-- Name: product_downloadable_sample_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_downloadable_sample_translations (
    id integer NOT NULL,
    product_downloadable_sample_id integer NOT NULL,
    locale character varying(255) NOT NULL,
    title text
);


--
-- Name: product_downloadable_sample_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_downloadable_sample_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_downloadable_sample_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_downloadable_sample_translations_id_seq OWNED BY public.product_downloadable_sample_translations.id;


--
-- Name: product_downloadable_samples; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_downloadable_samples (
    id integer NOT NULL,
    product_id integer NOT NULL,
    url character varying(255),
    file character varying(255),
    file_name character varying(255),
    type character varying(255) NOT NULL,
    sort_order integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: product_downloadable_samples_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_downloadable_samples_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_downloadable_samples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_downloadable_samples_id_seq OWNED BY public.product_downloadable_samples.id;


--
-- Name: product_flat; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_flat (
    id integer NOT NULL,
    sku character varying(255) NOT NULL,
    type character varying(255),
    product_number character varying(255),
    name character varying(255),
    short_description text,
    description text,
    url_key character varying(255),
    new boolean,
    featured boolean,
    status boolean,
    meta_title text,
    meta_keywords text,
    meta_description text,
    price numeric(12,4),
    special_price numeric(12,4),
    special_price_from date,
    special_price_to date,
    weight numeric(12,4),
    created_at timestamp(0) without time zone,
    locale character varying(255),
    channel character varying(255),
    attribute_family_id integer,
    product_id integer NOT NULL,
    updated_at timestamp(0) without time zone,
    parent_id integer,
    visible_individually boolean,
    quantity integer,
    images_count integer DEFAULT 0,
    manage_stock boolean,
    base_image character varying(255),
    category_name text,
    attribute_family_name character varying(255)
);


--
-- Name: product_flat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_flat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_flat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_flat_id_seq OWNED BY public.product_flat.id;


--
-- Name: product_grouped_products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_grouped_products (
    id integer NOT NULL,
    product_id integer NOT NULL,
    associated_product_id integer NOT NULL,
    qty integer DEFAULT 0 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL
);


--
-- Name: product_grouped_products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_grouped_products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_grouped_products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_grouped_products_id_seq OWNED BY public.product_grouped_products.id;


--
-- Name: product_image_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_image_translations (
    id integer NOT NULL,
    product_image_id integer NOT NULL,
    locale character varying(255) NOT NULL,
    alt_text text
);


--
-- Name: product_image_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_image_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_image_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_image_translations_id_seq OWNED BY public.product_image_translations.id;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_images (
    id integer NOT NULL,
    type character varying(255),
    path character varying(255) NOT NULL,
    product_id integer NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
);


--
-- Name: product_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_images_id_seq OWNED BY public.product_images.id;


--
-- Name: product_inventories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_inventories (
    id integer NOT NULL,
    qty integer DEFAULT 0 NOT NULL,
    product_id integer NOT NULL,
    vendor_id integer DEFAULT 0 NOT NULL,
    inventory_source_id integer NOT NULL
);


--
-- Name: product_inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_inventories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_inventories_id_seq OWNED BY public.product_inventories.id;


--
-- Name: product_inventory_indices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_inventory_indices (
    id integer NOT NULL,
    qty integer DEFAULT 0 NOT NULL,
    product_id integer NOT NULL,
    channel_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: product_inventory_indices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_inventory_indices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_inventory_indices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_inventory_indices_id_seq OWNED BY public.product_inventory_indices.id;


--
-- Name: product_omnibus_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_omnibus_prices (
    id bigint NOT NULL,
    product_id integer NOT NULL,
    channel_id integer NOT NULL,
    currency_code character varying(3) NOT NULL,
    price numeric(12,4) NOT NULL,
    recorded_at timestamp(0) without time zone NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: product_omnibus_prices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_omnibus_prices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_omnibus_prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_omnibus_prices_id_seq OWNED BY public.product_omnibus_prices.id;


--
-- Name: product_ordered_inventories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_ordered_inventories (
    id integer NOT NULL,
    qty integer DEFAULT 0 NOT NULL,
    product_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: product_ordered_inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_ordered_inventories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_ordered_inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_ordered_inventories_id_seq OWNED BY public.product_ordered_inventories.id;


--
-- Name: product_price_indices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_price_indices (
    id integer NOT NULL,
    product_id integer NOT NULL,
    customer_group_id integer,
    min_price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    regular_min_price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    max_price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    regular_max_price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    channel_id integer DEFAULT 1 NOT NULL
);


--
-- Name: product_price_indices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_price_indices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_price_indices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_price_indices_id_seq OWNED BY public.product_price_indices.id;


--
-- Name: product_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_relations (
    parent_id integer NOT NULL,
    child_id integer NOT NULL
);


--
-- Name: product_review_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_review_attachments (
    id integer NOT NULL,
    review_id integer NOT NULL,
    type character varying(255) DEFAULT 'image'::character varying NOT NULL,
    path character varying(255) NOT NULL,
    mime_type character varying(255)
);


--
-- Name: product_review_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_review_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_review_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_review_images_id_seq OWNED BY public.product_review_attachments.id;


--
-- Name: product_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_reviews (
    id integer NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    title character varying(255) NOT NULL,
    rating integer NOT NULL,
    comment text,
    status character varying(255) NOT NULL,
    product_id integer NOT NULL,
    customer_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: product_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_reviews_id_seq OWNED BY public.product_reviews.id;


--
-- Name: product_super_attributes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_super_attributes (
    product_id integer NOT NULL,
    attribute_id integer NOT NULL
);


--
-- Name: product_up_sells; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_up_sells (
    parent_id integer NOT NULL,
    child_id integer NOT NULL
);


--
-- Name: product_videos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_videos (
    id integer NOT NULL,
    product_id integer NOT NULL,
    type character varying(255),
    path character varying(255) NOT NULL,
    "position" integer DEFAULT 0 NOT NULL
);


--
-- Name: product_videos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_videos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_videos_id_seq OWNED BY public.product_videos.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    id integer NOT NULL,
    sku character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    parent_id integer,
    attribute_family_id integer,
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: refund_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refund_items (
    id integer NOT NULL,
    parent_id integer,
    name character varying(255),
    description character varying(255),
    sku character varying(255),
    qty integer,
    price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_price numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    total numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    tax_amount numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount numeric(12,4) DEFAULT '0'::numeric,
    discount_percent numeric(12,4) DEFAULT '0'::numeric,
    discount_amount numeric(12,4) DEFAULT '0'::numeric,
    base_discount_amount numeric(12,4) DEFAULT '0'::numeric,
    product_id integer,
    product_type character varying(255),
    order_item_id integer,
    refund_id integer,
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL
);


--
-- Name: refund_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refund_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refund_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refund_items_id_seq OWNED BY public.refund_items.id;


--
-- Name: refunds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refunds (
    id integer NOT NULL,
    increment_id character varying(255),
    state character varying(255),
    email_sent boolean DEFAULT false NOT NULL,
    total_qty integer,
    base_currency_code character varying(255),
    channel_currency_code character varying(255),
    order_currency_code character varying(255),
    adjustment_refund numeric(12,4) DEFAULT '0'::numeric,
    base_adjustment_refund numeric(12,4) DEFAULT '0'::numeric,
    adjustment_fee numeric(12,4) DEFAULT '0'::numeric,
    base_adjustment_fee numeric(12,4) DEFAULT '0'::numeric,
    sub_total numeric(12,4) DEFAULT '0'::numeric,
    base_sub_total numeric(12,4) DEFAULT '0'::numeric,
    grand_total numeric(12,4) DEFAULT '0'::numeric,
    base_grand_total numeric(12,4) DEFAULT '0'::numeric,
    shipping_amount numeric(12,4) DEFAULT '0'::numeric,
    base_shipping_amount numeric(12,4) DEFAULT '0'::numeric,
    tax_amount numeric(12,4) DEFAULT '0'::numeric,
    base_tax_amount numeric(12,4) DEFAULT '0'::numeric,
    discount_percent numeric(12,4) DEFAULT '0'::numeric,
    discount_amount numeric(12,4) DEFAULT '0'::numeric,
    base_discount_amount numeric(12,4) DEFAULT '0'::numeric,
    order_id integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    shipping_tax_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_shipping_tax_amount numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    sub_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_sub_total_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    shipping_amount_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_shipping_amount_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL
);


--
-- Name: refunds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.refunds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refunds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.refunds_id_seq OWNED BY public.refunds.id;


--
-- Name: rma; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma (
    id integer NOT NULL,
    order_id integer NOT NULL,
    rma_status_id integer,
    package_condition character varying(255),
    information text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_additional_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_additional_fields (
    id integer NOT NULL,
    rma_id integer,
    rma_custom_field_id integer,
    value character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_additional_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_additional_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_additional_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_additional_fields_id_seq OWNED BY public.rma_additional_fields.id;


--
-- Name: rma_custom_field_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_custom_field_options (
    id integer NOT NULL,
    rma_custom_field_id integer NOT NULL,
    name character varying(255),
    value character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_custom_field_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_custom_field_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_custom_field_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_custom_field_options_id_seq OWNED BY public.rma_custom_field_options.id;


--
-- Name: rma_custom_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_custom_fields (
    id integer NOT NULL,
    status boolean DEFAULT false,
    code character varying(255) NOT NULL,
    label character varying(255),
    type character varying(255),
    is_required boolean DEFAULT false,
    "position" integer DEFAULT 0,
    input_validation character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_custom_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_custom_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_custom_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_custom_fields_id_seq OWNED BY public.rma_custom_fields.id;


--
-- Name: rma_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_id_seq OWNED BY public.rma.id;


--
-- Name: rma_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_images (
    id integer NOT NULL,
    rma_id integer NOT NULL,
    path character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_images_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_images_id_seq OWNED BY public.rma_images.id;


--
-- Name: rma_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_items (
    id integer NOT NULL,
    rma_id integer,
    rma_reason_id integer,
    order_item_id integer,
    variant_id integer,
    quantity integer NOT NULL,
    resolution character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_items_id_seq OWNED BY public.rma_items.id;


--
-- Name: rma_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_messages (
    id integer NOT NULL,
    rma_id integer NOT NULL,
    message text NOT NULL,
    attachment_path text,
    attachment text,
    is_admin boolean,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_messages_id_seq OWNED BY public.rma_messages.id;


--
-- Name: rma_reason_resolutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_reason_resolutions (
    id integer NOT NULL,
    rma_reason_id integer NOT NULL,
    resolution_type character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_reason_resolutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_reason_resolutions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_reason_resolutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_reason_resolutions_id_seq OWNED BY public.rma_reason_resolutions.id;


--
-- Name: rma_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_reasons (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    status boolean,
    "position" integer DEFAULT 0 NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_reasons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_reasons_id_seq OWNED BY public.rma_reasons.id;


--
-- Name: rma_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_rules (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    status boolean,
    return_period integer,
    "default" boolean,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_rules_id_seq OWNED BY public.rma_rules.id;


--
-- Name: rma_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rma_statuses (
    id integer NOT NULL,
    title character varying(255),
    status boolean,
    color character varying(255),
    "default" integer DEFAULT 0,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: rma_statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rma_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rma_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rma_statuses_id_seq OWNED BY public.rma_statuses.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    permission_type character varying(255) NOT NULL,
    permissions jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: search_synonyms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.search_synonyms (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    terms text NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: search_synonyms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.search_synonyms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_synonyms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.search_synonyms_id_seq OWNED BY public.search_synonyms.id;


--
-- Name: search_terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.search_terms (
    id integer NOT NULL,
    term character varying(255) NOT NULL,
    results integer DEFAULT 0 NOT NULL,
    uses integer DEFAULT 0 NOT NULL,
    redirect_url character varying(255),
    display_in_suggested_terms boolean DEFAULT false NOT NULL,
    locale character varying(255) NOT NULL,
    channel_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: search_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.search_terms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.search_terms_id_seq OWNED BY public.search_terms.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


--
-- Name: shipment_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipment_items (
    id integer NOT NULL,
    name character varying(255),
    description character varying(255),
    sku character varying(255),
    qty integer,
    weight numeric(12,4),
    price numeric(12,4) DEFAULT '0'::numeric,
    base_price numeric(12,4) DEFAULT '0'::numeric,
    total numeric(12,4) DEFAULT '0'::numeric,
    base_total numeric(12,4) DEFAULT '0'::numeric,
    product_id integer,
    product_type character varying(255),
    order_item_id integer,
    shipment_id integer NOT NULL,
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL,
    base_price_incl_tax numeric(12,4) DEFAULT '0'::numeric NOT NULL
);


--
-- Name: shipment_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shipment_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shipment_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shipment_items_id_seq OWNED BY public.shipment_items.id;


--
-- Name: shipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shipments (
    id integer NOT NULL,
    status character varying(255),
    total_qty integer,
    total_weight numeric(12,4),
    carrier_code character varying(255),
    carrier_title character varying(255),
    track_number text,
    email_sent boolean DEFAULT false NOT NULL,
    customer_id integer,
    customer_type character varying(255),
    order_id integer NOT NULL,
    order_address_id integer,
    inventory_source_id integer,
    inventory_source_name character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shipments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shipments_id_seq OWNED BY public.shipments.id;


--
-- Name: sitemap_channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sitemap_channels (
    sitemap_id integer NOT NULL,
    channel_id integer NOT NULL
);


--
-- Name: sitemaps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sitemaps (
    id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    path character varying(255) NOT NULL,
    generated_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    additional jsonb
);


--
-- Name: sitemaps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sitemaps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sitemaps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sitemaps_id_seq OWNED BY public.sitemaps.id;


--
-- Name: subscribers_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscribers_list (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    is_subscribed boolean DEFAULT false NOT NULL,
    token character varying(255),
    customer_id integer,
    channel_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: subscribers_list_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subscribers_list_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscribers_list_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subscribers_list_id_seq OWNED BY public.subscribers_list.id;


--
-- Name: tax_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_categories (
    id integer NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description text NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: tax_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tax_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tax_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tax_categories_id_seq OWNED BY public.tax_categories.id;


--
-- Name: tax_categories_tax_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_categories_tax_rates (
    id integer NOT NULL,
    tax_category_id integer NOT NULL,
    tax_rate_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: tax_categories_tax_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tax_categories_tax_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tax_categories_tax_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tax_categories_tax_rates_id_seq OWNED BY public.tax_categories_tax_rates.id;


--
-- Name: tax_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tax_rates (
    id integer NOT NULL,
    identifier character varying(255) NOT NULL,
    is_zip boolean DEFAULT false NOT NULL,
    zip_code character varying(255),
    zip_from character varying(255),
    zip_to character varying(255),
    state character varying(255) NOT NULL,
    country character varying(255) NOT NULL,
    tax_rate numeric(12,4) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: tax_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tax_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tax_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tax_rates_id_seq OWNED BY public.tax_rates.id;


--
-- Name: theme_section_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.theme_section_translations (
    id integer NOT NULL,
    section_id integer NOT NULL,
    locale character varying(255) NOT NULL,
    options jsonb,
    draft_options json
);


--
-- Name: theme_customization_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.theme_customization_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: theme_customization_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.theme_customization_translations_id_seq OWNED BY public.theme_section_translations.id;


--
-- Name: theme_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.theme_sections (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    sort_order integer NOT NULL,
    status boolean DEFAULT false NOT NULL,
    channel_id integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    theme_code character varying(255) DEFAULT 'default'::character varying,
    draft_status boolean,
    draft_sort_order integer
);


--
-- Name: theme_customizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.theme_customizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: theme_customizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.theme_customizations_id_seq OWNED BY public.theme_sections.id;


--
-- Name: url_rewrites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.url_rewrites (
    id integer NOT NULL,
    entity_type character varying(255) NOT NULL,
    request_path character varying(255) NOT NULL,
    target_path character varying(255) NOT NULL,
    redirect_type character varying(255),
    locale character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: url_rewrites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.url_rewrites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: url_rewrites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.url_rewrites_id_seq OWNED BY public.url_rewrites.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vk7_activity_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vk7_activity_log (
    id bigint NOT NULL,
    actor character varying(255) NOT NULL,
    action character varying(255) NOT NULL,
    target character varying(255) NOT NULL,
    detail character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: vk7_activity_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vk7_activity_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vk7_activity_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vk7_activity_log_id_seq OWNED BY public.vk7_activity_log.id;


--
-- Name: vk7_enquiries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vk7_enquiries (
    id bigint NOT NULL,
    type character varying(255) DEFAULT 'general'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    business_name character varying(255),
    email character varying(255) NOT NULL,
    phone character varying(255),
    city character varying(255),
    quantity integer,
    product_id integer,
    message text NOT NULL,
    status character varying(255) DEFAULT 'new'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    notes json,
    follow_up_on date
);


--
-- Name: vk7_enquiries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vk7_enquiries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vk7_enquiries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vk7_enquiries_id_seq OWNED BY public.vk7_enquiries.id;


--
-- Name: vk7_order_terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vk7_order_terms (
    id bigint NOT NULL,
    order_id integer NOT NULL,
    stage character varying(255) DEFAULT 'Awaiting advance'::character varying NOT NULL,
    previous_stage character varying(255),
    advance_percent numeric(5,2) NOT NULL,
    advance_due numeric(12,2) NOT NULL,
    total numeric(12,2) NOT NULL,
    hold_until timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    invoice_number character varying(255),
    invoiced_at timestamp(0) without time zone
);


--
-- Name: vk7_order_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vk7_order_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vk7_order_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vk7_order_terms_id_seq OWNED BY public.vk7_order_terms.id;


--
-- Name: vk7_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vk7_payments (
    id bigint NOT NULL,
    order_id integer NOT NULL,
    kind character varying(255) NOT NULL,
    amount numeric(12,2) NOT NULL,
    method character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'created'::character varying NOT NULL,
    gateway character varying(255),
    gateway_order_id character varying(255),
    gateway_payment_id character varying(255),
    reference character varying(255),
    reviewed_by character varying(255),
    reject_reason character varying(255),
    paid_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: vk7_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vk7_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vk7_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vk7_payments_id_seq OWNED BY public.vk7_payments.id;


--
-- Name: vk7_sequences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vk7_sequences (
    name character varying(255) NOT NULL,
    value bigint NOT NULL
);


--
-- Name: vk7_shipment_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vk7_shipment_events (
    id bigint NOT NULL,
    shipment_id bigint NOT NULL,
    status character varying(255) NOT NULL,
    location character varying(255),
    lat numeric(9,6),
    lng numeric(9,6),
    description character varying(255),
    occurred_at timestamp(0) without time zone NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: vk7_shipment_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vk7_shipment_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vk7_shipment_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vk7_shipment_events_id_seq OWNED BY public.vk7_shipment_events.id;


--
-- Name: vk7_shipments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vk7_shipments (
    id bigint NOT NULL,
    order_id integer NOT NULL,
    provider character varying(255) NOT NULL,
    courier character varying(255) NOT NULL,
    waybill character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    tracking_url character varying(255),
    expected_on date,
    route json,
    delivered_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: vk7_shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vk7_shipments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vk7_shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vk7_shipments_id_seq OWNED BY public.vk7_shipments.id;


--
-- Name: vk7_stock_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vk7_stock_log (
    id bigint NOT NULL,
    product_id integer NOT NULL,
    product character varying(255) NOT NULL,
    variant character varying(255) NOT NULL,
    change integer NOT NULL,
    on_hand integer NOT NULL,
    reason character varying(255) NOT NULL,
    note character varying(255),
    actor character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: vk7_stock_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vk7_stock_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vk7_stock_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vk7_stock_log_id_seq OWNED BY public.vk7_stock_log.id;


--
-- Name: wishlist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wishlist (
    id integer NOT NULL,
    channel_id integer NOT NULL,
    product_id integer NOT NULL,
    customer_id integer NOT NULL,
    item_options jsonb,
    moved_to_cart date,
    shared boolean,
    time_of_moving date,
    additional jsonb,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: wishlist_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wishlist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wishlist_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wishlist_id_seq OWNED BY public.wishlist.id;


--
-- Name: wishlist_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wishlist_items (
    id integer NOT NULL,
    channel_id integer NOT NULL,
    product_id integer NOT NULL,
    customer_id integer NOT NULL,
    additional jsonb,
    moved_to_cart date,
    shared boolean,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


--
-- Name: wishlist_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wishlist_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wishlist_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wishlist_items_id_seq OWNED BY public.wishlist_items.id;


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses ALTER COLUMN id SET DEFAULT nextval('public.addresses_id_seq'::regclass);


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: attribute_families id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_families ALTER COLUMN id SET DEFAULT nextval('public.attribute_families_id_seq'::regclass);


--
-- Name: attribute_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_groups ALTER COLUMN id SET DEFAULT nextval('public.attribute_groups_id_seq'::regclass);


--
-- Name: attribute_option_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_option_translations ALTER COLUMN id SET DEFAULT nextval('public.attribute_option_translations_id_seq'::regclass);


--
-- Name: attribute_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_options ALTER COLUMN id SET DEFAULT nextval('public.attribute_options_id_seq'::regclass);


--
-- Name: attribute_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_translations ALTER COLUMN id SET DEFAULT nextval('public.attribute_translations_id_seq'::regclass);


--
-- Name: attributes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attributes ALTER COLUMN id SET DEFAULT nextval('public.attributes_id_seq'::regclass);


--
-- Name: b2b_company_attribute_group_mappings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_group_mappings ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_attribute_group_mappings_id_seq'::regclass);


--
-- Name: b2b_company_attribute_group_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_group_translations ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_attribute_group_translations_id_seq'::regclass);


--
-- Name: b2b_company_attribute_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_groups ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_attribute_groups_id_seq'::regclass);


--
-- Name: b2b_company_attribute_option_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_option_translations ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_attribute_option_translations_id_seq'::regclass);


--
-- Name: b2b_company_attribute_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_options ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_attribute_options_id_seq'::regclass);


--
-- Name: b2b_company_attribute_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_translations ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_attribute_translations_id_seq'::regclass);


--
-- Name: b2b_company_attribute_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_values ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_attribute_values_id_seq'::regclass);


--
-- Name: b2b_company_attributes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attributes ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_attributes_id_seq'::regclass);


--
-- Name: b2b_company_catalog_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_categories ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_catalog_categories_id_seq'::regclass);


--
-- Name: b2b_company_catalog_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_products ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_catalog_products_id_seq'::regclass);


--
-- Name: b2b_company_catalogs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalogs ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_catalogs_id_seq'::regclass);


--
-- Name: b2b_company_credit_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_credit_transactions ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_credit_transactions_id_seq'::regclass);


--
-- Name: b2b_company_credits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_credits ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_credits_id_seq'::regclass);


--
-- Name: b2b_company_flat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_flat ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_flat_id_seq'::regclass);


--
-- Name: b2b_company_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_invitations ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_invitations_id_seq'::regclass);


--
-- Name: b2b_company_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_roles ALTER COLUMN id SET DEFAULT nextval('public.b2b_company_roles_id_seq'::regclass);


--
-- Name: b2b_customer_quote_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_attachments ALTER COLUMN id SET DEFAULT nextval('public.b2b_customer_quote_attachments_id_seq'::regclass);


--
-- Name: b2b_customer_quote_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_items ALTER COLUMN id SET DEFAULT nextval('public.b2b_customer_quote_items_id_seq'::regclass);


--
-- Name: b2b_customer_quote_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_messages ALTER COLUMN id SET DEFAULT nextval('public.b2b_customer_quote_messages_id_seq'::regclass);


--
-- Name: b2b_customer_quote_quotations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_quotations ALTER COLUMN id SET DEFAULT nextval('public.b2b_customer_quote_quotations_id_seq'::regclass);


--
-- Name: b2b_customer_quotes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quotes ALTER COLUMN id SET DEFAULT nextval('public.b2b_customer_quotes_id_seq'::regclass);


--
-- Name: b2b_customer_requisition_list_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_requisition_list_products ALTER COLUMN id SET DEFAULT nextval('public.b2b_customer_requisition_list_products_id_seq'::regclass);


--
-- Name: b2b_customer_requisition_lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_requisition_lists ALTER COLUMN id SET DEFAULT nextval('public.b2b_customer_requisition_lists_id_seq'::regclass);


--
-- Name: booking_product_appointment_slots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_appointment_slots ALTER COLUMN id SET DEFAULT nextval('public.booking_product_appointment_slots_id_seq'::regclass);


--
-- Name: booking_product_default_slots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_default_slots ALTER COLUMN id SET DEFAULT nextval('public.booking_product_default_slots_id_seq'::regclass);


--
-- Name: booking_product_event_ticket_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_event_ticket_translations ALTER COLUMN id SET DEFAULT nextval('public.booking_product_event_ticket_translations_id_seq'::regclass);


--
-- Name: booking_product_event_tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_event_tickets ALTER COLUMN id SET DEFAULT nextval('public.booking_product_event_tickets_id_seq'::regclass);


--
-- Name: booking_product_rental_slots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_rental_slots ALTER COLUMN id SET DEFAULT nextval('public.booking_product_rental_slots_id_seq'::regclass);


--
-- Name: booking_product_table_slots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_table_slots ALTER COLUMN id SET DEFAULT nextval('public.booking_product_table_slots_id_seq'::regclass);


--
-- Name: booking_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_products ALTER COLUMN id SET DEFAULT nextval('public.booking_products_id_seq'::regclass);


--
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);


--
-- Name: cart id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart ALTER COLUMN id SET DEFAULT nextval('public.cart_id_seq'::regclass);


--
-- Name: cart_item_inventories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_item_inventories ALTER COLUMN id SET DEFAULT nextval('public.cart_item_inventories_id_seq'::regclass);


--
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- Name: cart_payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_payment ALTER COLUMN id SET DEFAULT nextval('public.cart_payment_id_seq'::regclass);


--
-- Name: cart_rule_coupon_usage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_coupon_usage ALTER COLUMN id SET DEFAULT nextval('public.cart_rule_coupon_usage_id_seq'::regclass);


--
-- Name: cart_rule_coupons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_coupons ALTER COLUMN id SET DEFAULT nextval('public.cart_rule_coupons_id_seq'::regclass);


--
-- Name: cart_rule_customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_customers ALTER COLUMN id SET DEFAULT nextval('public.cart_rule_customers_id_seq'::regclass);


--
-- Name: cart_rule_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_translations ALTER COLUMN id SET DEFAULT nextval('public.cart_rule_translations_id_seq'::regclass);


--
-- Name: cart_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rules ALTER COLUMN id SET DEFAULT nextval('public.cart_rules_id_seq'::regclass);


--
-- Name: cart_shipping_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_rates ALTER COLUMN id SET DEFAULT nextval('public.cart_shipping_rates_id_seq'::regclass);


--
-- Name: catalog_rule_product_prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_product_prices ALTER COLUMN id SET DEFAULT nextval('public.catalog_rule_product_prices_id_seq'::regclass);


--
-- Name: catalog_rule_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_products ALTER COLUMN id SET DEFAULT nextval('public.catalog_rule_products_id_seq'::regclass);


--
-- Name: catalog_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rules ALTER COLUMN id SET DEFAULT nextval('public.catalog_rules_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: category_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_translations ALTER COLUMN id SET DEFAULT nextval('public.category_translations_id_seq'::regclass);


--
-- Name: channel_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_translations ALTER COLUMN id SET DEFAULT nextval('public.channel_translations_id_seq'::regclass);


--
-- Name: channels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels ALTER COLUMN id SET DEFAULT nextval('public.channels_id_seq'::regclass);


--
-- Name: cms_page_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_translations ALTER COLUMN id SET DEFAULT nextval('public.cms_page_translations_id_seq'::regclass);


--
-- Name: cms_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_pages ALTER COLUMN id SET DEFAULT nextval('public.cms_pages_id_seq'::regclass);


--
-- Name: compare_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compare_items ALTER COLUMN id SET DEFAULT nextval('public.compare_items_id_seq'::regclass);


--
-- Name: core_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_config ALTER COLUMN id SET DEFAULT nextval('public.core_config_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries ALTER COLUMN id SET DEFAULT nextval('public.countries_id_seq'::regclass);


--
-- Name: country_state_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_state_translations ALTER COLUMN id SET DEFAULT nextval('public.country_state_translations_id_seq'::regclass);


--
-- Name: country_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_states ALTER COLUMN id SET DEFAULT nextval('public.country_states_id_seq'::regclass);


--
-- Name: country_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_translations ALTER COLUMN id SET DEFAULT nextval('public.country_translations_id_seq'::regclass);


--
-- Name: currencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies ALTER COLUMN id SET DEFAULT nextval('public.currencies_id_seq'::regclass);


--
-- Name: currency_exchange_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates ALTER COLUMN id SET DEFAULT nextval('public.currency_exchange_rates_id_seq'::regclass);


--
-- Name: customer_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_groups ALTER COLUMN id SET DEFAULT nextval('public.customer_groups_id_seq'::regclass);


--
-- Name: customer_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_notes ALTER COLUMN id SET DEFAULT nextval('public.customer_notes_id_seq'::regclass);


--
-- Name: customer_social_accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_social_accounts ALTER COLUMN id SET DEFAULT nextval('public.customer_social_accounts_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: datagrid_saved_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datagrid_saved_filters ALTER COLUMN id SET DEFAULT nextval('public.datagrid_saved_filters_id_seq'::regclass);


--
-- Name: downloadable_link_purchased id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_link_purchased ALTER COLUMN id SET DEFAULT nextval('public.downloadable_link_purchased_id_seq'::regclass);


--
-- Name: eu_withdrawals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eu_withdrawals ALTER COLUMN id SET DEFAULT nextval('public.eu_withdrawals_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: gdpr_data_request id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdpr_data_request ALTER COLUMN id SET DEFAULT nextval('public.gdpr_data_request_id_seq'::regclass);


--
-- Name: import_batches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_batches ALTER COLUMN id SET DEFAULT nextval('public.import_batches_id_seq'::regclass);


--
-- Name: imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports ALTER COLUMN id SET DEFAULT nextval('public.imports_id_seq'::regclass);


--
-- Name: inventory_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_sources ALTER COLUMN id SET DEFAULT nextval('public.inventory_sources_id_seq'::regclass);


--
-- Name: invoice_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items ALTER COLUMN id SET DEFAULT nextval('public.invoice_items_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: locales id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locales ALTER COLUMN id SET DEFAULT nextval('public.locales_id_seq'::regclass);


--
-- Name: marketing_campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_campaigns ALTER COLUMN id SET DEFAULT nextval('public.marketing_campaigns_id_seq'::regclass);


--
-- Name: marketing_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_events ALTER COLUMN id SET DEFAULT nextval('public.marketing_events_id_seq'::regclass);


--
-- Name: marketing_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_templates ALTER COLUMN id SET DEFAULT nextval('public.marketing_templates_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: order_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_comments ALTER COLUMN id SET DEFAULT nextval('public.order_comments_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: order_payment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_payment ALTER COLUMN id SET DEFAULT nextval('public.order_payment_id_seq'::regclass);


--
-- Name: order_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_transactions ALTER COLUMN id SET DEFAULT nextval('public.order_transactions_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: product_attribute_values id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_attribute_values ALTER COLUMN id SET DEFAULT nextval('public.product_attribute_values_id_seq'::regclass);


--
-- Name: product_bundle_option_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_products ALTER COLUMN id SET DEFAULT nextval('public.product_bundle_option_products_id_seq'::regclass);


--
-- Name: product_bundle_option_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_translations ALTER COLUMN id SET DEFAULT nextval('public.product_bundle_option_translations_id_seq'::regclass);


--
-- Name: product_bundle_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_options ALTER COLUMN id SET DEFAULT nextval('public.product_bundle_options_id_seq'::regclass);


--
-- Name: product_customer_group_prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customer_group_prices ALTER COLUMN id SET DEFAULT nextval('public.product_customer_group_prices_id_seq'::regclass);


--
-- Name: product_customizable_option_prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_option_prices ALTER COLUMN id SET DEFAULT nextval('public.product_customizable_option_prices_id_seq'::regclass);


--
-- Name: product_customizable_option_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_option_translations ALTER COLUMN id SET DEFAULT nextval('public.product_customizable_option_translations_id_seq'::regclass);


--
-- Name: product_customizable_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_options ALTER COLUMN id SET DEFAULT nextval('public.product_customizable_options_id_seq'::regclass);


--
-- Name: product_downloadable_link_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_link_translations ALTER COLUMN id SET DEFAULT nextval('public.product_downloadable_link_translations_id_seq'::regclass);


--
-- Name: product_downloadable_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_links ALTER COLUMN id SET DEFAULT nextval('public.product_downloadable_links_id_seq'::regclass);


--
-- Name: product_downloadable_sample_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_sample_translations ALTER COLUMN id SET DEFAULT nextval('public.product_downloadable_sample_translations_id_seq'::regclass);


--
-- Name: product_downloadable_samples id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_samples ALTER COLUMN id SET DEFAULT nextval('public.product_downloadable_samples_id_seq'::regclass);


--
-- Name: product_flat id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_flat ALTER COLUMN id SET DEFAULT nextval('public.product_flat_id_seq'::regclass);


--
-- Name: product_grouped_products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_grouped_products ALTER COLUMN id SET DEFAULT nextval('public.product_grouped_products_id_seq'::regclass);


--
-- Name: product_image_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_image_translations ALTER COLUMN id SET DEFAULT nextval('public.product_image_translations_id_seq'::regclass);


--
-- Name: product_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images ALTER COLUMN id SET DEFAULT nextval('public.product_images_id_seq'::regclass);


--
-- Name: product_inventories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventories ALTER COLUMN id SET DEFAULT nextval('public.product_inventories_id_seq'::regclass);


--
-- Name: product_inventory_indices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventory_indices ALTER COLUMN id SET DEFAULT nextval('public.product_inventory_indices_id_seq'::regclass);


--
-- Name: product_omnibus_prices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_omnibus_prices ALTER COLUMN id SET DEFAULT nextval('public.product_omnibus_prices_id_seq'::regclass);


--
-- Name: product_ordered_inventories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_ordered_inventories ALTER COLUMN id SET DEFAULT nextval('public.product_ordered_inventories_id_seq'::regclass);


--
-- Name: product_price_indices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_price_indices ALTER COLUMN id SET DEFAULT nextval('public.product_price_indices_id_seq'::regclass);


--
-- Name: product_review_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_attachments ALTER COLUMN id SET DEFAULT nextval('public.product_review_images_id_seq'::regclass);


--
-- Name: product_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_reviews ALTER COLUMN id SET DEFAULT nextval('public.product_reviews_id_seq'::regclass);


--
-- Name: product_videos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_videos ALTER COLUMN id SET DEFAULT nextval('public.product_videos_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: refund_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_items ALTER COLUMN id SET DEFAULT nextval('public.refund_items_id_seq'::regclass);


--
-- Name: refunds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refunds ALTER COLUMN id SET DEFAULT nextval('public.refunds_id_seq'::regclass);


--
-- Name: rma id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma ALTER COLUMN id SET DEFAULT nextval('public.rma_id_seq'::regclass);


--
-- Name: rma_additional_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_additional_fields ALTER COLUMN id SET DEFAULT nextval('public.rma_additional_fields_id_seq'::regclass);


--
-- Name: rma_custom_field_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_custom_field_options ALTER COLUMN id SET DEFAULT nextval('public.rma_custom_field_options_id_seq'::regclass);


--
-- Name: rma_custom_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_custom_fields ALTER COLUMN id SET DEFAULT nextval('public.rma_custom_fields_id_seq'::regclass);


--
-- Name: rma_images id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_images ALTER COLUMN id SET DEFAULT nextval('public.rma_images_id_seq'::regclass);


--
-- Name: rma_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_items ALTER COLUMN id SET DEFAULT nextval('public.rma_items_id_seq'::regclass);


--
-- Name: rma_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_messages ALTER COLUMN id SET DEFAULT nextval('public.rma_messages_id_seq'::regclass);


--
-- Name: rma_reason_resolutions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_reason_resolutions ALTER COLUMN id SET DEFAULT nextval('public.rma_reason_resolutions_id_seq'::regclass);


--
-- Name: rma_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_reasons ALTER COLUMN id SET DEFAULT nextval('public.rma_reasons_id_seq'::regclass);


--
-- Name: rma_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_rules ALTER COLUMN id SET DEFAULT nextval('public.rma_rules_id_seq'::regclass);


--
-- Name: rma_statuses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_statuses ALTER COLUMN id SET DEFAULT nextval('public.rma_statuses_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: search_synonyms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_synonyms ALTER COLUMN id SET DEFAULT nextval('public.search_synonyms_id_seq'::regclass);


--
-- Name: search_terms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_terms ALTER COLUMN id SET DEFAULT nextval('public.search_terms_id_seq'::regclass);


--
-- Name: shipment_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipment_items ALTER COLUMN id SET DEFAULT nextval('public.shipment_items_id_seq'::regclass);


--
-- Name: shipments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments ALTER COLUMN id SET DEFAULT nextval('public.shipments_id_seq'::regclass);


--
-- Name: sitemaps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sitemaps ALTER COLUMN id SET DEFAULT nextval('public.sitemaps_id_seq'::regclass);


--
-- Name: subscribers_list id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscribers_list ALTER COLUMN id SET DEFAULT nextval('public.subscribers_list_id_seq'::regclass);


--
-- Name: tax_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_categories ALTER COLUMN id SET DEFAULT nextval('public.tax_categories_id_seq'::regclass);


--
-- Name: tax_categories_tax_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_categories_tax_rates ALTER COLUMN id SET DEFAULT nextval('public.tax_categories_tax_rates_id_seq'::regclass);


--
-- Name: tax_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rates ALTER COLUMN id SET DEFAULT nextval('public.tax_rates_id_seq'::regclass);


--
-- Name: theme_section_translations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_section_translations ALTER COLUMN id SET DEFAULT nextval('public.theme_customization_translations_id_seq'::regclass);


--
-- Name: theme_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_sections ALTER COLUMN id SET DEFAULT nextval('public.theme_customizations_id_seq'::regclass);


--
-- Name: url_rewrites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.url_rewrites ALTER COLUMN id SET DEFAULT nextval('public.url_rewrites_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vk7_activity_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_activity_log ALTER COLUMN id SET DEFAULT nextval('public.vk7_activity_log_id_seq'::regclass);


--
-- Name: vk7_enquiries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_enquiries ALTER COLUMN id SET DEFAULT nextval('public.vk7_enquiries_id_seq'::regclass);


--
-- Name: vk7_order_terms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_order_terms ALTER COLUMN id SET DEFAULT nextval('public.vk7_order_terms_id_seq'::regclass);


--
-- Name: vk7_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_payments ALTER COLUMN id SET DEFAULT nextval('public.vk7_payments_id_seq'::regclass);


--
-- Name: vk7_shipment_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_shipment_events ALTER COLUMN id SET DEFAULT nextval('public.vk7_shipment_events_id_seq'::regclass);


--
-- Name: vk7_shipments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_shipments ALTER COLUMN id SET DEFAULT nextval('public.vk7_shipments_id_seq'::regclass);


--
-- Name: vk7_stock_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_stock_log ALTER COLUMN id SET DEFAULT nextval('public.vk7_stock_log_id_seq'::regclass);


--
-- Name: wishlist id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist ALTER COLUMN id SET DEFAULT nextval('public.wishlist_id_seq'::regclass);


--
-- Name: wishlist_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist_items ALTER COLUMN id SET DEFAULT nextval('public.wishlist_items_id_seq'::regclass);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: admins admins_api_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_api_token_unique UNIQUE (api_token);


--
-- Name: admins admins_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_email_unique UNIQUE (email);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: agent_conversation_messages agent_conversation_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_conversation_messages
    ADD CONSTRAINT agent_conversation_messages_pkey PRIMARY KEY (id);


--
-- Name: agent_conversations agent_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_conversations
    ADD CONSTRAINT agent_conversations_pkey PRIMARY KEY (id);


--
-- Name: attribute_families attribute_families_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_families
    ADD CONSTRAINT attribute_families_pkey PRIMARY KEY (id);


--
-- Name: attribute_group_mappings attribute_group_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_group_mappings
    ADD CONSTRAINT attribute_group_mappings_pkey PRIMARY KEY (attribute_id, attribute_group_id);


--
-- Name: attribute_groups attribute_groups_attribute_family_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_groups
    ADD CONSTRAINT attribute_groups_attribute_family_id_name_unique UNIQUE (attribute_family_id, name);


--
-- Name: attribute_groups attribute_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_groups
    ADD CONSTRAINT attribute_groups_pkey PRIMARY KEY (id);


--
-- Name: attribute_option_translations attribute_option_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_option_translations
    ADD CONSTRAINT attribute_option_locale_unique UNIQUE (attribute_option_id, locale);


--
-- Name: attribute_option_translations attribute_option_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_option_translations
    ADD CONSTRAINT attribute_option_translations_pkey PRIMARY KEY (id);


--
-- Name: attribute_options attribute_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_options
    ADD CONSTRAINT attribute_options_pkey PRIMARY KEY (id);


--
-- Name: attribute_translations attribute_translations_attribute_id_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_translations
    ADD CONSTRAINT attribute_translations_attribute_id_locale_unique UNIQUE (attribute_id, locale);


--
-- Name: attribute_translations attribute_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_translations
    ADD CONSTRAINT attribute_translations_pkey PRIMARY KEY (id);


--
-- Name: attributes attributes_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_code_unique UNIQUE (code);


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_attribute_group_mappings b2b_company_attribute_group_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_group_mappings
    ADD CONSTRAINT b2b_company_attribute_group_mappings_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_attribute_group_translations b2b_company_attribute_group_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_group_translations
    ADD CONSTRAINT b2b_company_attribute_group_translations_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_attribute_groups b2b_company_attribute_groups_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_groups
    ADD CONSTRAINT b2b_company_attribute_groups_code_unique UNIQUE (code);


--
-- Name: b2b_company_attribute_groups b2b_company_attribute_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_groups
    ADD CONSTRAINT b2b_company_attribute_groups_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_attribute_option_translations b2b_company_attribute_option_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_option_translations
    ADD CONSTRAINT b2b_company_attribute_option_translations_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_attribute_options b2b_company_attribute_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_options
    ADD CONSTRAINT b2b_company_attribute_options_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_attribute_translations b2b_company_attribute_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_translations
    ADD CONSTRAINT b2b_company_attribute_translations_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_attribute_values b2b_company_attribute_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_values
    ADD CONSTRAINT b2b_company_attribute_values_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_attributes b2b_company_attributes_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attributes
    ADD CONSTRAINT b2b_company_attributes_code_unique UNIQUE (code);


--
-- Name: b2b_company_attributes b2b_company_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attributes
    ADD CONSTRAINT b2b_company_attributes_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_catalog_categories b2b_company_catalog_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_categories
    ADD CONSTRAINT b2b_company_catalog_categories_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_catalog_products b2b_company_catalog_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_products
    ADD CONSTRAINT b2b_company_catalog_products_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_catalogs b2b_company_catalogs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalogs
    ADD CONSTRAINT b2b_company_catalogs_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_credit_transactions b2b_company_credit_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_credit_transactions
    ADD CONSTRAINT b2b_company_credit_transactions_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_credits b2b_company_credits_company_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_credits
    ADD CONSTRAINT b2b_company_credits_company_id_unique UNIQUE (company_id);


--
-- Name: b2b_company_credits b2b_company_credits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_credits
    ADD CONSTRAINT b2b_company_credits_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_flat b2b_company_flat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_flat
    ADD CONSTRAINT b2b_company_flat_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_invitations b2b_company_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_invitations
    ADD CONSTRAINT b2b_company_invitations_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_invitations b2b_company_invitations_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_invitations
    ADD CONSTRAINT b2b_company_invitations_token_unique UNIQUE (token);


--
-- Name: b2b_company_roles b2b_company_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_roles
    ADD CONSTRAINT b2b_company_roles_pkey PRIMARY KEY (id);


--
-- Name: b2b_customer_quote_attachments b2b_customer_quote_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_attachments
    ADD CONSTRAINT b2b_customer_quote_attachments_pkey PRIMARY KEY (id);


--
-- Name: b2b_customer_quote_items b2b_customer_quote_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_items
    ADD CONSTRAINT b2b_customer_quote_items_pkey PRIMARY KEY (id);


--
-- Name: b2b_customer_quote_messages b2b_customer_quote_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_messages
    ADD CONSTRAINT b2b_customer_quote_messages_pkey PRIMARY KEY (id);


--
-- Name: b2b_customer_quote_quotations b2b_customer_quote_quotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_quotations
    ADD CONSTRAINT b2b_customer_quote_quotations_pkey PRIMARY KEY (id);


--
-- Name: b2b_customer_quotes b2b_customer_quotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quotes
    ADD CONSTRAINT b2b_customer_quotes_pkey PRIMARY KEY (id);


--
-- Name: b2b_customer_requisition_list_products b2b_customer_requisition_list_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_requisition_list_products
    ADD CONSTRAINT b2b_customer_requisition_list_products_pkey PRIMARY KEY (id);


--
-- Name: b2b_customer_requisition_lists b2b_customer_requisition_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_requisition_lists
    ADD CONSTRAINT b2b_customer_requisition_lists_pkey PRIMARY KEY (id);


--
-- Name: booking_product_appointment_slots booking_product_appointment_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_appointment_slots
    ADD CONSTRAINT booking_product_appointment_slots_pkey PRIMARY KEY (id);


--
-- Name: booking_product_default_slots booking_product_default_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_default_slots
    ADD CONSTRAINT booking_product_default_slots_pkey PRIMARY KEY (id);


--
-- Name: booking_product_event_ticket_translations booking_product_event_ticket_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_event_ticket_translations
    ADD CONSTRAINT booking_product_event_ticket_translations_pkey PRIMARY KEY (id);


--
-- Name: booking_product_event_tickets booking_product_event_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_event_tickets
    ADD CONSTRAINT booking_product_event_tickets_pkey PRIMARY KEY (id);


--
-- Name: booking_product_rental_slots booking_product_rental_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_rental_slots
    ADD CONSTRAINT booking_product_rental_slots_pkey PRIMARY KEY (id);


--
-- Name: booking_product_table_slots booking_product_table_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_table_slots
    ADD CONSTRAINT booking_product_table_slots_pkey PRIMARY KEY (id);


--
-- Name: booking_products booking_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_products
    ADD CONSTRAINT booking_products_pkey PRIMARY KEY (id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: booking_product_event_ticket_translations bpet_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_event_ticket_translations
    ADD CONSTRAINT bpet_locale_unique UNIQUE (booking_product_event_ticket_id, locale);


--
-- Name: product_bundle_option_products bundle_option_products_product_id_bundle_option_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_products
    ADD CONSTRAINT bundle_option_products_product_id_bundle_option_id_unique UNIQUE (product_id, product_bundle_option_id);


--
-- Name: product_bundle_option_translations bundle_option_translations_locale_label_bundle_option_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_translations
    ADD CONSTRAINT bundle_option_translations_locale_label_bundle_option_id_unique UNIQUE (locale, label, product_bundle_option_id);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: cart_item_inventories cart_item_inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_item_inventories
    ADD CONSTRAINT cart_item_inventories_pkey PRIMARY KEY (id);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- Name: cart_payment cart_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_payment
    ADD CONSTRAINT cart_payment_pkey PRIMARY KEY (id);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- Name: cart_rule_channels cart_rule_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_channels
    ADD CONSTRAINT cart_rule_channels_pkey PRIMARY KEY (cart_rule_id, channel_id);


--
-- Name: cart_rule_coupon_usage cart_rule_coupon_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_coupon_usage
    ADD CONSTRAINT cart_rule_coupon_usage_pkey PRIMARY KEY (id);


--
-- Name: cart_rule_coupons cart_rule_coupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_coupons
    ADD CONSTRAINT cart_rule_coupons_pkey PRIMARY KEY (id);


--
-- Name: cart_rule_customer_groups cart_rule_customer_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_customer_groups
    ADD CONSTRAINT cart_rule_customer_groups_pkey PRIMARY KEY (cart_rule_id, customer_group_id);


--
-- Name: cart_rule_customers cart_rule_customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_customers
    ADD CONSTRAINT cart_rule_customers_pkey PRIMARY KEY (id);


--
-- Name: cart_rule_translations cart_rule_translations_cart_rule_id_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_translations
    ADD CONSTRAINT cart_rule_translations_cart_rule_id_locale_unique UNIQUE (cart_rule_id, locale);


--
-- Name: cart_rule_translations cart_rule_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_translations
    ADD CONSTRAINT cart_rule_translations_pkey PRIMARY KEY (id);


--
-- Name: cart_rules cart_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rules
    ADD CONSTRAINT cart_rules_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_rates cart_shipping_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_rates
    ADD CONSTRAINT cart_shipping_rates_pkey PRIMARY KEY (id);


--
-- Name: catalog_rule_channels catalog_rule_channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_channels
    ADD CONSTRAINT catalog_rule_channels_pkey PRIMARY KEY (catalog_rule_id, channel_id);


--
-- Name: catalog_rule_customer_groups catalog_rule_customer_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_customer_groups
    ADD CONSTRAINT catalog_rule_customer_groups_pkey PRIMARY KEY (catalog_rule_id, customer_group_id);


--
-- Name: catalog_rule_product_prices catalog_rule_product_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_product_prices
    ADD CONSTRAINT catalog_rule_product_prices_pkey PRIMARY KEY (id);


--
-- Name: catalog_rule_products catalog_rule_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_products
    ADD CONSTRAINT catalog_rule_products_pkey PRIMARY KEY (id);


--
-- Name: catalog_rules catalog_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rules
    ADD CONSTRAINT catalog_rules_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: category_translations category_translations_category_id_slug_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_translations
    ADD CONSTRAINT category_translations_category_id_slug_locale_unique UNIQUE (category_id, slug, locale);


--
-- Name: category_translations category_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_translations
    ADD CONSTRAINT category_translations_pkey PRIMARY KEY (id);


--
-- Name: product_attribute_values chanel_locale_attribute_value_index_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_attribute_values
    ADD CONSTRAINT chanel_locale_attribute_value_index_unique UNIQUE (channel, locale, attribute_id, product_id);


--
-- Name: channel_currencies channel_currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_currencies
    ADD CONSTRAINT channel_currencies_pkey PRIMARY KEY (channel_id, currency_id);


--
-- Name: channel_inventory_sources channel_inventory_source_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_inventory_sources
    ADD CONSTRAINT channel_inventory_source_unique UNIQUE (channel_id, inventory_source_id);


--
-- Name: b2b_company_attribute_values channel_locale_attribute_value_index_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_values
    ADD CONSTRAINT channel_locale_attribute_value_index_unique UNIQUE (channel, locale, company_attribute_id, customer_id);


--
-- Name: channel_locales channel_locales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_locales
    ADD CONSTRAINT channel_locales_pkey PRIMARY KEY (channel_id, locale_id);


--
-- Name: channel_translations channel_translations_channel_id_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_translations
    ADD CONSTRAINT channel_translations_channel_id_locale_unique UNIQUE (channel_id, locale);


--
-- Name: channel_translations channel_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_translations
    ADD CONSTRAINT channel_translations_pkey PRIMARY KEY (id);


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: cms_page_channels cms_page_channels_cms_page_id_channel_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_channels
    ADD CONSTRAINT cms_page_channels_cms_page_id_channel_id_unique UNIQUE (cms_page_id, channel_id);


--
-- Name: cms_page_translations cms_page_translations_cms_page_id_url_key_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_translations
    ADD CONSTRAINT cms_page_translations_cms_page_id_url_key_locale_unique UNIQUE (cms_page_id, url_key, locale);


--
-- Name: cms_page_translations cms_page_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_translations
    ADD CONSTRAINT cms_page_translations_pkey PRIMARY KEY (id);


--
-- Name: cms_pages cms_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_pages
    ADD CONSTRAINT cms_pages_pkey PRIMARY KEY (id);


--
-- Name: b2b_company_attribute_group_translations company_attr_group_local_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_group_translations
    ADD CONSTRAINT company_attr_group_local_unique UNIQUE (company_attribute_group_id, locale);


--
-- Name: b2b_company_attribute_translations company_attr_local_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_translations
    ADD CONSTRAINT company_attr_local_unique UNIQUE (company_attribute_id, locale);


--
-- Name: b2b_company_attribute_option_translations company_attr_option_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_option_translations
    ADD CONSTRAINT company_attr_option_locale_unique UNIQUE (company_attribute_option_id, locale);


--
-- Name: b2b_company_catalog_categories company_catalog_categories_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_categories
    ADD CONSTRAINT company_catalog_categories_unique UNIQUE (company_catalog_id, category_id);


--
-- Name: b2b_company_catalog_products company_catalog_products_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_products
    ADD CONSTRAINT company_catalog_products_unique UNIQUE (company_catalog_id, product_id);


--
-- Name: b2b_company_flat company_flat_unique_index; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_flat
    ADD CONSTRAINT company_flat_unique_index UNIQUE (customer_id, channel, locale);


--
-- Name: compare_items compare_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compare_items
    ADD CONSTRAINT compare_items_pkey PRIMARY KEY (id);


--
-- Name: core_config core_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.core_config
    ADD CONSTRAINT core_config_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: country_state_translations country_state_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_state_translations
    ADD CONSTRAINT country_state_translations_pkey PRIMARY KEY (id);


--
-- Name: country_states country_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_states
    ADD CONSTRAINT country_states_pkey PRIMARY KEY (id);


--
-- Name: country_translations country_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_translations
    ADD CONSTRAINT country_translations_pkey PRIMARY KEY (id);


--
-- Name: currencies currencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_pkey PRIMARY KEY (id);


--
-- Name: currency_exchange_rates currency_exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates
    ADD CONSTRAINT currency_exchange_rates_pkey PRIMARY KEY (id);


--
-- Name: currency_exchange_rates currency_exchange_rates_target_currency_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates
    ADD CONSTRAINT currency_exchange_rates_target_currency_unique UNIQUE (target_currency);


--
-- Name: customer_groups customer_groups_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_groups
    ADD CONSTRAINT customer_groups_code_unique UNIQUE (code);


--
-- Name: customer_groups customer_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_groups
    ADD CONSTRAINT customer_groups_pkey PRIMARY KEY (id);


--
-- Name: customer_notes customer_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_notes
    ADD CONSTRAINT customer_notes_pkey PRIMARY KEY (id);


--
-- Name: customer_social_accounts customer_social_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_social_accounts
    ADD CONSTRAINT customer_social_accounts_pkey PRIMARY KEY (id);


--
-- Name: customer_social_accounts customer_social_accounts_provider_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_social_accounts
    ADD CONSTRAINT customer_social_accounts_provider_id_unique UNIQUE (provider_id);


--
-- Name: customers customers_api_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_api_token_unique UNIQUE (api_token);


--
-- Name: customers customers_email_channel_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_channel_unique UNIQUE (email, channel_id);


--
-- Name: customers customers_phone_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_phone_unique UNIQUE (phone);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: datagrid_saved_filters datagrid_saved_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datagrid_saved_filters
    ADD CONSTRAINT datagrid_saved_filters_pkey PRIMARY KEY (id);


--
-- Name: datagrid_saved_filters datagrid_saved_filters_user_id_name_src_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.datagrid_saved_filters
    ADD CONSTRAINT datagrid_saved_filters_user_id_name_src_unique UNIQUE (user_id, name, src);


--
-- Name: downloadable_link_purchased downloadable_link_purchased_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_link_purchased
    ADD CONSTRAINT downloadable_link_purchased_pkey PRIMARY KEY (id);


--
-- Name: eu_withdrawals eu_withdrawals_order_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eu_withdrawals
    ADD CONSTRAINT eu_withdrawals_order_id_unique UNIQUE (order_id);


--
-- Name: eu_withdrawals eu_withdrawals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eu_withdrawals
    ADD CONSTRAINT eu_withdrawals_pkey PRIMARY KEY (id);


--
-- Name: eu_withdrawals eu_withdrawals_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eu_withdrawals
    ADD CONSTRAINT eu_withdrawals_uuid_unique UNIQUE (uuid);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: gdpr_data_request gdpr_data_request_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdpr_data_request
    ADD CONSTRAINT gdpr_data_request_pkey PRIMARY KEY (id);


--
-- Name: product_grouped_products grouped_products_product_id_associated_product_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_grouped_products
    ADD CONSTRAINT grouped_products_product_id_associated_product_id_unique UNIQUE (product_id, associated_product_id);


--
-- Name: product_image_translations image_translations_image_id_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_image_translations
    ADD CONSTRAINT image_translations_image_id_locale_unique UNIQUE (product_image_id, locale);


--
-- Name: import_batches import_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_batches
    ADD CONSTRAINT import_batches_pkey PRIMARY KEY (id);


--
-- Name: imports imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: inventory_sources inventory_sources_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_sources
    ADD CONSTRAINT inventory_sources_code_unique UNIQUE (code);


--
-- Name: inventory_sources inventory_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_sources
    ADD CONSTRAINT inventory_sources_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: locales locales_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locales
    ADD CONSTRAINT locales_code_unique UNIQUE (code);


--
-- Name: locales locales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locales
    ADD CONSTRAINT locales_pkey PRIMARY KEY (id);


--
-- Name: marketing_campaigns marketing_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_campaigns
    ADD CONSTRAINT marketing_campaigns_pkey PRIMARY KEY (id);


--
-- Name: marketing_events marketing_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_events
    ADD CONSTRAINT marketing_events_pkey PRIMARY KEY (id);


--
-- Name: marketing_templates marketing_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_templates
    ADD CONSTRAINT marketing_templates_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: order_comments order_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_comments
    ADD CONSTRAINT order_comments_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: order_payment order_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_payment
    ADD CONSTRAINT order_payment_pkey PRIMARY KEY (id);


--
-- Name: order_transactions order_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_transactions
    ADD CONSTRAINT order_transactions_pkey PRIMARY KEY (id);


--
-- Name: orders orders_increment_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_increment_id_unique UNIQUE (increment_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: product_price_indices price_indices_product_id_customer_group_id_channel_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_price_indices
    ADD CONSTRAINT price_indices_product_id_customer_group_id_channel_id_unique UNIQUE (product_id, customer_group_id, channel_id);


--
-- Name: product_attribute_values product_attribute_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_attribute_values
    ADD CONSTRAINT product_attribute_values_pkey PRIMARY KEY (id);


--
-- Name: product_attribute_values product_attribute_values_unique_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_attribute_values
    ADD CONSTRAINT product_attribute_values_unique_id_unique UNIQUE (unique_id);


--
-- Name: product_bundle_option_products product_bundle_option_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_products
    ADD CONSTRAINT product_bundle_option_products_pkey PRIMARY KEY (id);


--
-- Name: product_bundle_option_translations product_bundle_option_translations_option_id_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_translations
    ADD CONSTRAINT product_bundle_option_translations_option_id_locale_unique UNIQUE (product_bundle_option_id, locale);


--
-- Name: product_bundle_option_translations product_bundle_option_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_translations
    ADD CONSTRAINT product_bundle_option_translations_pkey PRIMARY KEY (id);


--
-- Name: product_bundle_options product_bundle_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_options
    ADD CONSTRAINT product_bundle_options_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_product_id_category_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_product_id_category_id_unique UNIQUE (product_id, category_id);


--
-- Name: product_channels product_channels_product_id_channel_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_channels
    ADD CONSTRAINT product_channels_product_id_channel_id_unique UNIQUE (product_id, channel_id);


--
-- Name: product_cross_sells product_cross_sells_parent_id_child_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_cross_sells
    ADD CONSTRAINT product_cross_sells_parent_id_child_id_unique UNIQUE (parent_id, child_id);


--
-- Name: product_customer_group_prices product_customer_group_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customer_group_prices
    ADD CONSTRAINT product_customer_group_prices_pkey PRIMARY KEY (id);


--
-- Name: product_customer_group_prices product_customer_group_prices_unique_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customer_group_prices
    ADD CONSTRAINT product_customer_group_prices_unique_id_unique UNIQUE (unique_id);


--
-- Name: product_customizable_option_translations product_customizable_option_id_locale_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_option_translations
    ADD CONSTRAINT product_customizable_option_id_locale_unique UNIQUE (product_customizable_option_id, locale);


--
-- Name: product_customizable_option_prices product_customizable_option_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_option_prices
    ADD CONSTRAINT product_customizable_option_prices_pkey PRIMARY KEY (id);


--
-- Name: product_customizable_option_translations product_customizable_option_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_option_translations
    ADD CONSTRAINT product_customizable_option_translations_pkey PRIMARY KEY (id);


--
-- Name: product_customizable_options product_customizable_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_options
    ADD CONSTRAINT product_customizable_options_pkey PRIMARY KEY (id);


--
-- Name: product_downloadable_link_translations product_downloadable_link_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_link_translations
    ADD CONSTRAINT product_downloadable_link_translations_pkey PRIMARY KEY (id);


--
-- Name: product_downloadable_links product_downloadable_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_links
    ADD CONSTRAINT product_downloadable_links_pkey PRIMARY KEY (id);


--
-- Name: product_downloadable_sample_translations product_downloadable_sample_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_sample_translations
    ADD CONSTRAINT product_downloadable_sample_translations_pkey PRIMARY KEY (id);


--
-- Name: product_downloadable_samples product_downloadable_samples_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_samples
    ADD CONSTRAINT product_downloadable_samples_pkey PRIMARY KEY (id);


--
-- Name: product_flat product_flat_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_flat
    ADD CONSTRAINT product_flat_pkey PRIMARY KEY (id);


--
-- Name: product_flat product_flat_unique_index; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_flat
    ADD CONSTRAINT product_flat_unique_index UNIQUE (product_id, channel, locale);


--
-- Name: product_grouped_products product_grouped_products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_grouped_products
    ADD CONSTRAINT product_grouped_products_pkey PRIMARY KEY (id);


--
-- Name: product_image_translations product_image_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_image_translations
    ADD CONSTRAINT product_image_translations_pkey PRIMARY KEY (id);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (id);


--
-- Name: product_inventories product_inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventories
    ADD CONSTRAINT product_inventories_pkey PRIMARY KEY (id);


--
-- Name: product_inventory_indices product_inventory_indices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventory_indices
    ADD CONSTRAINT product_inventory_indices_pkey PRIMARY KEY (id);


--
-- Name: product_inventory_indices product_inventory_indices_product_id_channel_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventory_indices
    ADD CONSTRAINT product_inventory_indices_product_id_channel_id_unique UNIQUE (product_id, channel_id);


--
-- Name: product_omnibus_prices product_omnibus_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_omnibus_prices
    ADD CONSTRAINT product_omnibus_prices_pkey PRIMARY KEY (id);


--
-- Name: product_ordered_inventories product_ordered_inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_ordered_inventories
    ADD CONSTRAINT product_ordered_inventories_pkey PRIMARY KEY (id);


--
-- Name: product_ordered_inventories product_ordered_inventories_product_id_channel_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_ordered_inventories
    ADD CONSTRAINT product_ordered_inventories_product_id_channel_id_unique UNIQUE (product_id, channel_id);


--
-- Name: product_price_indices product_price_indices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_price_indices
    ADD CONSTRAINT product_price_indices_pkey PRIMARY KEY (id);


--
-- Name: product_relations product_relations_parent_id_child_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_relations
    ADD CONSTRAINT product_relations_parent_id_child_id_unique UNIQUE (parent_id, child_id);


--
-- Name: product_review_attachments product_review_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_attachments
    ADD CONSTRAINT product_review_images_pkey PRIMARY KEY (id);


--
-- Name: product_reviews product_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_pkey PRIMARY KEY (id);


--
-- Name: product_inventories product_source_vendor_index_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventories
    ADD CONSTRAINT product_source_vendor_index_unique UNIQUE (product_id, inventory_source_id, vendor_id);


--
-- Name: product_super_attributes product_super_attributes_product_id_attribute_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_super_attributes
    ADD CONSTRAINT product_super_attributes_product_id_attribute_id_unique UNIQUE (product_id, attribute_id);


--
-- Name: product_up_sells product_up_sells_parent_id_child_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_up_sells
    ADD CONSTRAINT product_up_sells_parent_id_child_id_unique UNIQUE (parent_id, child_id);


--
-- Name: product_videos product_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_videos
    ADD CONSTRAINT product_videos_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_sku_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_unique UNIQUE (sku);


--
-- Name: refund_items refund_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_items
    ADD CONSTRAINT refund_items_pkey PRIMARY KEY (id);


--
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- Name: rma_additional_fields rma_additional_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_additional_fields
    ADD CONSTRAINT rma_additional_fields_pkey PRIMARY KEY (id);


--
-- Name: rma_custom_field_options rma_custom_field_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_custom_field_options
    ADD CONSTRAINT rma_custom_field_options_pkey PRIMARY KEY (id);


--
-- Name: rma_custom_fields rma_custom_fields_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_custom_fields
    ADD CONSTRAINT rma_custom_fields_code_unique UNIQUE (code);


--
-- Name: rma_custom_fields rma_custom_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_custom_fields
    ADD CONSTRAINT rma_custom_fields_pkey PRIMARY KEY (id);


--
-- Name: rma_images rma_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_images
    ADD CONSTRAINT rma_images_pkey PRIMARY KEY (id);


--
-- Name: rma_items rma_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_items
    ADD CONSTRAINT rma_items_pkey PRIMARY KEY (id);


--
-- Name: rma_messages rma_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_messages
    ADD CONSTRAINT rma_messages_pkey PRIMARY KEY (id);


--
-- Name: rma rma_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma
    ADD CONSTRAINT rma_pkey PRIMARY KEY (id);


--
-- Name: rma_reason_resolutions rma_reason_resolutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_reason_resolutions
    ADD CONSTRAINT rma_reason_resolutions_pkey PRIMARY KEY (id);


--
-- Name: rma_reasons rma_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_reasons
    ADD CONSTRAINT rma_reasons_pkey PRIMARY KEY (id);


--
-- Name: rma_rules rma_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_rules
    ADD CONSTRAINT rma_rules_pkey PRIMARY KEY (id);


--
-- Name: rma_statuses rma_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_statuses
    ADD CONSTRAINT rma_statuses_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: search_synonyms search_synonyms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_synonyms
    ADD CONSTRAINT search_synonyms_pkey PRIMARY KEY (id);


--
-- Name: search_terms search_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_terms
    ADD CONSTRAINT search_terms_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: shipment_items shipment_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipment_items
    ADD CONSTRAINT shipment_items_pkey PRIMARY KEY (id);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);


--
-- Name: sitemap_channels sitemap_channels_sitemap_id_channel_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sitemap_channels
    ADD CONSTRAINT sitemap_channels_sitemap_id_channel_id_unique UNIQUE (sitemap_id, channel_id);


--
-- Name: sitemaps sitemaps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sitemaps
    ADD CONSTRAINT sitemaps_pkey PRIMARY KEY (id);


--
-- Name: subscribers_list subscribers_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscribers_list
    ADD CONSTRAINT subscribers_list_pkey PRIMARY KEY (id);


--
-- Name: tax_categories tax_categories_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_categories
    ADD CONSTRAINT tax_categories_code_unique UNIQUE (code);


--
-- Name: tax_categories tax_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_categories
    ADD CONSTRAINT tax_categories_pkey PRIMARY KEY (id);


--
-- Name: tax_categories_tax_rates tax_categories_tax_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_categories_tax_rates
    ADD CONSTRAINT tax_categories_tax_rates_pkey PRIMARY KEY (id);


--
-- Name: tax_categories_tax_rates tax_map_index_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_categories_tax_rates
    ADD CONSTRAINT tax_map_index_unique UNIQUE (tax_category_id, tax_rate_id);


--
-- Name: tax_rates tax_rates_identifier_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rates
    ADD CONSTRAINT tax_rates_identifier_unique UNIQUE (identifier);


--
-- Name: tax_rates tax_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_rates
    ADD CONSTRAINT tax_rates_pkey PRIMARY KEY (id);


--
-- Name: theme_section_translations theme_customization_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_section_translations
    ADD CONSTRAINT theme_customization_translations_pkey PRIMARY KEY (id);


--
-- Name: theme_sections theme_customizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_sections
    ADD CONSTRAINT theme_customizations_pkey PRIMARY KEY (id);


--
-- Name: url_rewrites url_rewrites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.url_rewrites
    ADD CONSTRAINT url_rewrites_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vk7_activity_log vk7_activity_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_activity_log
    ADD CONSTRAINT vk7_activity_log_pkey PRIMARY KEY (id);


--
-- Name: b2b_customer_quotes vk7_b2b_customer_quotes_po_number_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quotes
    ADD CONSTRAINT vk7_b2b_customer_quotes_po_number_unique UNIQUE (po_number);


--
-- Name: b2b_customer_quotes vk7_b2b_customer_quotes_quotation_number_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quotes
    ADD CONSTRAINT vk7_b2b_customer_quotes_quotation_number_unique UNIQUE (quotation_number);


--
-- Name: vk7_enquiries vk7_enquiries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_enquiries
    ADD CONSTRAINT vk7_enquiries_pkey PRIMARY KEY (id);


--
-- Name: vk7_order_terms vk7_order_terms_invoice_number_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_order_terms
    ADD CONSTRAINT vk7_order_terms_invoice_number_unique UNIQUE (invoice_number);


--
-- Name: vk7_order_terms vk7_order_terms_order_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_order_terms
    ADD CONSTRAINT vk7_order_terms_order_id_unique UNIQUE (order_id);


--
-- Name: vk7_order_terms vk7_order_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_order_terms
    ADD CONSTRAINT vk7_order_terms_pkey PRIMARY KEY (id);


--
-- Name: vk7_payments vk7_payments_gateway_gateway_payment_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_payments
    ADD CONSTRAINT vk7_payments_gateway_gateway_payment_id_unique UNIQUE (gateway, gateway_payment_id);


--
-- Name: vk7_payments vk7_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_payments
    ADD CONSTRAINT vk7_payments_pkey PRIMARY KEY (id);


--
-- Name: vk7_sequences vk7_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_sequences
    ADD CONSTRAINT vk7_sequences_pkey PRIMARY KEY (name);


--
-- Name: vk7_shipment_events vk7_shipment_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_shipment_events
    ADD CONSTRAINT vk7_shipment_events_pkey PRIMARY KEY (id);


--
-- Name: vk7_shipment_events vk7_shipment_events_shipment_id_status_location_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_shipment_events
    ADD CONSTRAINT vk7_shipment_events_shipment_id_status_location_unique UNIQUE (shipment_id, status, location);


--
-- Name: vk7_shipments vk7_shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_shipments
    ADD CONSTRAINT vk7_shipments_pkey PRIMARY KEY (id);


--
-- Name: vk7_shipments vk7_shipments_waybill_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_shipments
    ADD CONSTRAINT vk7_shipments_waybill_unique UNIQUE (waybill);


--
-- Name: vk7_stock_log vk7_stock_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_stock_log
    ADD CONSTRAINT vk7_stock_log_pkey PRIMARY KEY (id);


--
-- Name: wishlist_items wishlist_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_pkey PRIMARY KEY (id);


--
-- Name: wishlist wishlist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_pkey PRIMARY KEY (id);


--
-- Name: admin_password_resets_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX admin_password_resets_email_index ON public.admin_password_resets USING btree (email);


--
-- Name: agent_conversation_messages_conversation_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX agent_conversation_messages_conversation_id_index ON public.agent_conversation_messages USING btree (conversation_id);


--
-- Name: agent_conversation_messages_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX agent_conversation_messages_user_id_index ON public.agent_conversation_messages USING btree (user_id);


--
-- Name: agent_conversations_user_id_updated_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX agent_conversations_user_id_updated_at_index ON public.agent_conversations USING btree (user_id, updated_at);


--
-- Name: b2b_company_catalogs_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX b2b_company_catalogs_status_index ON public.b2b_company_catalogs USING btree (status);


--
-- Name: b2b_company_flat_channel_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX b2b_company_flat_channel_index ON public.b2b_company_flat USING btree (channel);


--
-- Name: b2b_company_flat_customer_id_channel_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX b2b_company_flat_customer_id_channel_index ON public.b2b_company_flat USING btree (customer_id, channel);


--
-- Name: b2b_company_flat_customer_id_locale_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX b2b_company_flat_customer_id_locale_index ON public.b2b_company_flat USING btree (customer_id, locale);


--
-- Name: b2b_company_flat_locale_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX b2b_company_flat_locale_index ON public.b2b_company_flat USING btree (locale);


--
-- Name: b2b_customer_requisition_lists_company_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX b2b_customer_requisition_lists_company_id_status_index ON public.b2b_customer_requisition_lists USING btree (company_id, status);


--
-- Name: b2b_customer_requisition_lists_customer_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX b2b_customer_requisition_lists_customer_id_status_index ON public.b2b_customer_requisition_lists USING btree (customer_id, status);


--
-- Name: b2b_customer_requisition_lists_is_default_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX b2b_customer_requisition_lists_is_default_index ON public.b2b_customer_requisition_lists USING btree (is_default);


--
-- Name: categories__lft__rgt_parent_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX categories__lft__rgt_parent_id_index ON public.categories USING btree (_lft, _rgt, parent_id);


--
-- Name: channel_translations_locale_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX channel_translations_locale_index ON public.channel_translations USING btree (locale);


--
-- Name: channels_hostname_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX channels_hostname_idx ON public.channels USING btree (hostname);


--
-- Name: conversation_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX conversation_index ON public.agent_conversation_messages USING btree (conversation_id, user_id, updated_at);


--
-- Name: customer_password_resets_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customer_password_resets_email_index ON public.customer_password_resets USING btree (email);


--
-- Name: customers_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX customers_type_index ON public.customers USING btree (type);


--
-- Name: eu_withdrawals_channel_id_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eu_withdrawals_channel_id_status_index ON public.eu_withdrawals USING btree (channel_id, status);


--
-- Name: eu_withdrawals_customer_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eu_withdrawals_customer_id_index ON public.eu_withdrawals USING btree (customer_id);


--
-- Name: eu_withdrawals_received_at_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX eu_withdrawals_received_at_index ON public.eu_withdrawals USING btree (received_at);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: omnibus_lookup_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX omnibus_lookup_index ON public.product_omnibus_prices USING btree (product_id, channel_id, currency_code, recorded_at);


--
-- Name: password_resets_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX password_resets_email_index ON public.password_resets USING btree (email);


--
-- Name: pbop_option_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pbop_option_id_idx ON public.product_bundle_option_products USING btree (product_bundle_option_id);


--
-- Name: pc_product_id_channel_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pc_product_id_channel_id_idx ON public.product_channels USING btree (product_id, channel_id);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: pgp_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pgp_product_id_idx ON public.product_grouped_products USING btree (product_id);


--
-- Name: ppi_product_id_customer_group_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ppi_product_id_customer_group_id_idx ON public.product_price_indices USING btree (product_id, customer_group_id);


--
-- Name: prod_attr_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prod_attr_product_id_idx ON public.product_attribute_values USING btree (product_id);


--
-- Name: prod_img_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prod_img_product_id_idx ON public.product_images USING btree (product_id);


--
-- Name: prod_inv_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prod_inv_product_id_idx ON public.product_inventory_indices USING btree (product_id);


--
-- Name: prod_rev_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prod_rev_product_id_idx ON public.product_reviews USING btree (product_id);


--
-- Name: prod_vid_product_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX prod_vid_product_id_idx ON public.product_videos USING btree (product_id);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: url_rewrites_et_rp_lc_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX url_rewrites_et_rp_lc_idx ON public.url_rewrites USING btree (entity_type, request_path, locale);


--
-- Name: vk7_order_terms_stage_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vk7_order_terms_stage_index ON public.vk7_order_terms USING btree (stage);


--
-- Name: vk7_payments_gateway_order_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vk7_payments_gateway_order_id_index ON public.vk7_payments USING btree (gateway_order_id);


--
-- Name: vk7_payments_status_order_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX vk7_payments_status_order_id_index ON public.vk7_payments USING btree (status, order_id);


--
-- Name: addresses addresses_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON DELETE CASCADE;


--
-- Name: addresses addresses_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: addresses addresses_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: addresses addresses_parent_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_parent_address_id_foreign FOREIGN KEY (parent_address_id) REFERENCES public.addresses(id) ON DELETE SET NULL;


--
-- Name: attribute_group_mappings attribute_group_mappings_attribute_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_group_mappings
    ADD CONSTRAINT attribute_group_mappings_attribute_group_id_foreign FOREIGN KEY (attribute_group_id) REFERENCES public.attribute_groups(id) ON DELETE CASCADE;


--
-- Name: attribute_group_mappings attribute_group_mappings_attribute_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_group_mappings
    ADD CONSTRAINT attribute_group_mappings_attribute_id_foreign FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: attribute_groups attribute_groups_attribute_family_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_groups
    ADD CONSTRAINT attribute_groups_attribute_family_id_foreign FOREIGN KEY (attribute_family_id) REFERENCES public.attribute_families(id) ON DELETE CASCADE;


--
-- Name: attribute_option_translations attribute_option_translations_attribute_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_option_translations
    ADD CONSTRAINT attribute_option_translations_attribute_option_id_foreign FOREIGN KEY (attribute_option_id) REFERENCES public.attribute_options(id) ON DELETE CASCADE;


--
-- Name: attribute_options attribute_options_attribute_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_options
    ADD CONSTRAINT attribute_options_attribute_id_foreign FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: attribute_translations attribute_translations_attribute_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attribute_translations
    ADD CONSTRAINT attribute_translations_attribute_id_foreign FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: b2b_company_attribute_options b2b_comp_attr_opt_attr_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_options
    ADD CONSTRAINT b2b_comp_attr_opt_attr_fk FOREIGN KEY (company_attribute_id) REFERENCES public.b2b_company_attributes(id) ON DELETE CASCADE;


--
-- Name: b2b_company_attribute_translations b2b_comp_attr_trans_attr_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_translations
    ADD CONSTRAINT b2b_comp_attr_trans_attr_fk FOREIGN KEY (company_attribute_id) REFERENCES public.b2b_company_attributes(id) ON DELETE CASCADE;


--
-- Name: b2b_company_attribute_values b2b_comp_attr_val_attr_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_values
    ADD CONSTRAINT b2b_comp_attr_val_attr_fk FOREIGN KEY (company_attribute_id) REFERENCES public.b2b_company_attributes(id) ON DELETE CASCADE;


--
-- Name: b2b_company_attribute_values b2b_company_attribute_values_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_values
    ADD CONSTRAINT b2b_company_attribute_values_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_company_catalog_categories b2b_company_catalog_categories_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_categories
    ADD CONSTRAINT b2b_company_catalog_categories_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: b2b_company_catalog_categories b2b_company_catalog_categories_company_catalog_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_categories
    ADD CONSTRAINT b2b_company_catalog_categories_company_catalog_id_foreign FOREIGN KEY (company_catalog_id) REFERENCES public.b2b_company_catalogs(id) ON DELETE CASCADE;


--
-- Name: b2b_company_catalog_products b2b_company_catalog_products_company_catalog_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_products
    ADD CONSTRAINT b2b_company_catalog_products_company_catalog_id_foreign FOREIGN KEY (company_catalog_id) REFERENCES public.b2b_company_catalogs(id) ON DELETE CASCADE;


--
-- Name: b2b_company_catalog_products b2b_company_catalog_products_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalog_products
    ADD CONSTRAINT b2b_company_catalog_products_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: b2b_company_catalogs b2b_company_catalogs_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalogs
    ADD CONSTRAINT b2b_company_catalogs_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.admins(id) ON DELETE SET NULL;


--
-- Name: b2b_company_catalogs b2b_company_catalogs_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_catalogs
    ADD CONSTRAINT b2b_company_catalogs_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE SET NULL;


--
-- Name: b2b_company_credit_transactions b2b_company_credit_transactions_company_credit_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_credit_transactions
    ADD CONSTRAINT b2b_company_credit_transactions_company_credit_id_foreign FOREIGN KEY (company_credit_id) REFERENCES public.b2b_company_credits(id) ON DELETE CASCADE;


--
-- Name: b2b_company_credit_transactions b2b_company_credit_transactions_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_credit_transactions
    ADD CONSTRAINT b2b_company_credit_transactions_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL;


--
-- Name: b2b_company_credits b2b_company_credits_company_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_credits
    ADD CONSTRAINT b2b_company_credits_company_id_foreign FOREIGN KEY (company_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_company_flat b2b_company_flat_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_flat
    ADD CONSTRAINT b2b_company_flat_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_company_invitations b2b_company_invitations_company_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_invitations
    ADD CONSTRAINT b2b_company_invitations_company_id_foreign FOREIGN KEY (company_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_company_invitations b2b_company_invitations_company_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_invitations
    ADD CONSTRAINT b2b_company_invitations_company_role_id_foreign FOREIGN KEY (company_role_id) REFERENCES public.b2b_company_roles(id) ON DELETE SET NULL;


--
-- Name: b2b_company_roles b2b_company_roles_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_roles
    ADD CONSTRAINT b2b_company_roles_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_companies b2b_customer_companies_company_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_companies
    ADD CONSTRAINT b2b_customer_companies_company_id_foreign FOREIGN KEY (company_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_companies b2b_customer_companies_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_companies
    ADD CONSTRAINT b2b_customer_companies_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_quote_attachments b2b_customer_quote_attachments_customer_quote_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_attachments
    ADD CONSTRAINT b2b_customer_quote_attachments_customer_quote_id_foreign FOREIGN KEY (customer_quote_id) REFERENCES public.b2b_customer_quotes(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_quote_items b2b_customer_quote_items_customer_quote_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_items
    ADD CONSTRAINT b2b_customer_quote_items_customer_quote_id_foreign FOREIGN KEY (customer_quote_id) REFERENCES public.b2b_customer_quotes(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_quote_items b2b_customer_quote_items_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_items
    ADD CONSTRAINT b2b_customer_quote_items_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: b2b_customer_quote_messages b2b_customer_quote_messages_quote_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_messages
    ADD CONSTRAINT b2b_customer_quote_messages_quote_id_foreign FOREIGN KEY (quote_id) REFERENCES public.b2b_customer_quotes(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_quote_quotations b2b_customer_quote_quotations_message_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_quotations
    ADD CONSTRAINT b2b_customer_quote_quotations_message_id_foreign FOREIGN KEY (message_id) REFERENCES public.b2b_customer_quote_messages(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_quote_quotations b2b_customer_quote_quotations_quote_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_quotations
    ADD CONSTRAINT b2b_customer_quote_quotations_quote_id_foreign FOREIGN KEY (quote_id) REFERENCES public.b2b_customer_quotes(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_quote_quotations b2b_customer_quote_quotations_quote_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quote_quotations
    ADD CONSTRAINT b2b_customer_quote_quotations_quote_item_id_foreign FOREIGN KEY (quote_item_id) REFERENCES public.b2b_customer_quote_items(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_quotes b2b_customer_quotes_agent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quotes
    ADD CONSTRAINT b2b_customer_quotes_agent_id_foreign FOREIGN KEY (agent_id) REFERENCES public.admins(id) ON DELETE SET NULL;


--
-- Name: b2b_customer_quotes b2b_customer_quotes_company_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quotes
    ADD CONSTRAINT b2b_customer_quotes_company_id_foreign FOREIGN KEY (company_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_quotes b2b_customer_quotes_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quotes
    ADD CONSTRAINT b2b_customer_quotes_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;


--
-- Name: b2b_customer_quotes b2b_customer_quotes_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_quotes
    ADD CONSTRAINT b2b_customer_quotes_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL;


--
-- Name: b2b_customer_requisition_lists b2b_customer_requisition_lists_company_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_requisition_lists
    ADD CONSTRAINT b2b_customer_requisition_lists_company_id_foreign FOREIGN KEY (company_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_requisition_lists b2b_customer_requisition_lists_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_requisition_lists
    ADD CONSTRAINT b2b_customer_requisition_lists_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_requisition_list_products b2b_req_list_prod_list_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_requisition_list_products
    ADD CONSTRAINT b2b_req_list_prod_list_fk FOREIGN KEY (requisition_list_id) REFERENCES public.b2b_customer_requisition_lists(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_requisition_list_products b2b_req_list_prod_product_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_requisition_list_products
    ADD CONSTRAINT b2b_req_list_prod_product_fk FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: b2b_customer_requisition_list_products b2b_req_list_prod_variant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_customer_requisition_list_products
    ADD CONSTRAINT b2b_req_list_prod_variant_fk FOREIGN KEY (variant_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: booking_product_appointment_slots booking_product_appointment_slots_booking_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_appointment_slots
    ADD CONSTRAINT booking_product_appointment_slots_booking_product_id_foreign FOREIGN KEY (booking_product_id) REFERENCES public.booking_products(id) ON DELETE CASCADE;


--
-- Name: booking_product_default_slots booking_product_default_slots_booking_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_default_slots
    ADD CONSTRAINT booking_product_default_slots_booking_product_id_foreign FOREIGN KEY (booking_product_id) REFERENCES public.booking_products(id) ON DELETE CASCADE;


--
-- Name: booking_product_event_tickets booking_product_event_tickets_booking_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_event_tickets
    ADD CONSTRAINT booking_product_event_tickets_booking_product_id_foreign FOREIGN KEY (booking_product_id) REFERENCES public.booking_products(id) ON DELETE CASCADE;


--
-- Name: booking_product_rental_slots booking_product_rental_slots_booking_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_rental_slots
    ADD CONSTRAINT booking_product_rental_slots_booking_product_id_foreign FOREIGN KEY (booking_product_id) REFERENCES public.booking_products(id) ON DELETE CASCADE;


--
-- Name: booking_product_table_slots booking_product_table_slots_booking_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_table_slots
    ADD CONSTRAINT booking_product_table_slots_booking_product_id_foreign FOREIGN KEY (booking_product_id) REFERENCES public.booking_products(id) ON DELETE CASCADE;


--
-- Name: booking_products booking_products_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_products
    ADD CONSTRAINT booking_products_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: bookings bookings_booking_product_event_ticket_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_booking_product_event_ticket_id_foreign FOREIGN KEY (booking_product_event_ticket_id) REFERENCES public.booking_product_event_tickets(id) ON DELETE SET NULL;


--
-- Name: bookings bookings_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL;


--
-- Name: bookings bookings_order_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_order_item_id_foreign FOREIGN KEY (order_item_id) REFERENCES public.order_items(id) ON DELETE SET NULL;


--
-- Name: bookings bookings_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: booking_product_event_ticket_translations bpet_translations_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.booking_product_event_ticket_translations
    ADD CONSTRAINT bpet_translations_fk FOREIGN KEY (booking_product_event_ticket_id) REFERENCES public.booking_product_event_tickets(id) ON DELETE CASCADE;


--
-- Name: cart cart_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: cart cart_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.cart_items(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_tax_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_tax_category_id_foreign FOREIGN KEY (tax_category_id) REFERENCES public.tax_categories(id) ON DELETE SET NULL;


--
-- Name: cart_payment cart_payment_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_payment
    ADD CONSTRAINT cart_payment_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON DELETE CASCADE;


--
-- Name: cart_rule_channels cart_rule_channels_cart_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_channels
    ADD CONSTRAINT cart_rule_channels_cart_rule_id_foreign FOREIGN KEY (cart_rule_id) REFERENCES public.cart_rules(id) ON DELETE CASCADE;


--
-- Name: cart_rule_channels cart_rule_channels_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_channels
    ADD CONSTRAINT cart_rule_channels_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: cart_rule_coupon_usage cart_rule_coupon_usage_cart_rule_coupon_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_coupon_usage
    ADD CONSTRAINT cart_rule_coupon_usage_cart_rule_coupon_id_foreign FOREIGN KEY (cart_rule_coupon_id) REFERENCES public.cart_rule_coupons(id) ON DELETE CASCADE;


--
-- Name: cart_rule_coupon_usage cart_rule_coupon_usage_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_coupon_usage
    ADD CONSTRAINT cart_rule_coupon_usage_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: cart_rule_coupons cart_rule_coupons_cart_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_coupons
    ADD CONSTRAINT cart_rule_coupons_cart_rule_id_foreign FOREIGN KEY (cart_rule_id) REFERENCES public.cart_rules(id) ON DELETE CASCADE;


--
-- Name: cart_rule_customer_groups cart_rule_customer_groups_cart_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_customer_groups
    ADD CONSTRAINT cart_rule_customer_groups_cart_rule_id_foreign FOREIGN KEY (cart_rule_id) REFERENCES public.cart_rules(id) ON DELETE CASCADE;


--
-- Name: cart_rule_customer_groups cart_rule_customer_groups_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_customer_groups
    ADD CONSTRAINT cart_rule_customer_groups_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE CASCADE;


--
-- Name: cart_rule_customers cart_rule_customers_cart_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_customers
    ADD CONSTRAINT cart_rule_customers_cart_rule_id_foreign FOREIGN KEY (cart_rule_id) REFERENCES public.cart_rules(id) ON DELETE CASCADE;


--
-- Name: cart_rule_customers cart_rule_customers_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_customers
    ADD CONSTRAINT cart_rule_customers_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: cart_rule_translations cart_rule_translations_cart_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_rule_translations
    ADD CONSTRAINT cart_rule_translations_cart_rule_id_foreign FOREIGN KEY (cart_rule_id) REFERENCES public.cart_rules(id) ON DELETE CASCADE;


--
-- Name: cart_shipping_rates cart_shipping_rates_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_shipping_rates
    ADD CONSTRAINT cart_shipping_rates_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_channels catalog_rule_channels_catalog_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_channels
    ADD CONSTRAINT catalog_rule_channels_catalog_rule_id_foreign FOREIGN KEY (catalog_rule_id) REFERENCES public.catalog_rules(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_channels catalog_rule_channels_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_channels
    ADD CONSTRAINT catalog_rule_channels_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_customer_groups catalog_rule_customer_groups_catalog_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_customer_groups
    ADD CONSTRAINT catalog_rule_customer_groups_catalog_rule_id_foreign FOREIGN KEY (catalog_rule_id) REFERENCES public.catalog_rules(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_customer_groups catalog_rule_customer_groups_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_customer_groups
    ADD CONSTRAINT catalog_rule_customer_groups_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_product_prices catalog_rule_product_prices_catalog_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_product_prices
    ADD CONSTRAINT catalog_rule_product_prices_catalog_rule_id_foreign FOREIGN KEY (catalog_rule_id) REFERENCES public.catalog_rules(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_product_prices catalog_rule_product_prices_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_product_prices
    ADD CONSTRAINT catalog_rule_product_prices_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_product_prices catalog_rule_product_prices_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_product_prices
    ADD CONSTRAINT catalog_rule_product_prices_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_product_prices catalog_rule_product_prices_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_product_prices
    ADD CONSTRAINT catalog_rule_product_prices_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_products catalog_rule_products_catalog_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_products
    ADD CONSTRAINT catalog_rule_products_catalog_rule_id_foreign FOREIGN KEY (catalog_rule_id) REFERENCES public.catalog_rules(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_products catalog_rule_products_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_products
    ADD CONSTRAINT catalog_rule_products_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_products catalog_rule_products_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_products
    ADD CONSTRAINT catalog_rule_products_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE CASCADE;


--
-- Name: catalog_rule_products catalog_rule_products_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalog_rule_products
    ADD CONSTRAINT catalog_rule_products_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: category_filterable_attributes category_filterable_attributes_attribute_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_filterable_attributes
    ADD CONSTRAINT category_filterable_attributes_attribute_id_foreign FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: category_filterable_attributes category_filterable_attributes_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_filterable_attributes
    ADD CONSTRAINT category_filterable_attributes_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: category_translations category_translations_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_translations
    ADD CONSTRAINT category_translations_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: category_translations category_translations_locale_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_translations
    ADD CONSTRAINT category_translations_locale_id_foreign FOREIGN KEY (locale_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: channel_currencies channel_currencies_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_currencies
    ADD CONSTRAINT channel_currencies_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: channel_currencies channel_currencies_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_currencies
    ADD CONSTRAINT channel_currencies_currency_id_foreign FOREIGN KEY (currency_id) REFERENCES public.currencies(id) ON DELETE CASCADE;


--
-- Name: channel_inventory_sources channel_inventory_sources_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_inventory_sources
    ADD CONSTRAINT channel_inventory_sources_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: channel_inventory_sources channel_inventory_sources_inventory_source_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_inventory_sources
    ADD CONSTRAINT channel_inventory_sources_inventory_source_id_foreign FOREIGN KEY (inventory_source_id) REFERENCES public.inventory_sources(id) ON DELETE CASCADE;


--
-- Name: channel_locales channel_locales_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_locales
    ADD CONSTRAINT channel_locales_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: channel_locales channel_locales_locale_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_locales
    ADD CONSTRAINT channel_locales_locale_id_foreign FOREIGN KEY (locale_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: channel_translations channel_translations_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channel_translations
    ADD CONSTRAINT channel_translations_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: channels channels_base_currency_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_base_currency_id_foreign FOREIGN KEY (base_currency_id) REFERENCES public.currencies(id);


--
-- Name: channels channels_default_locale_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_default_locale_id_foreign FOREIGN KEY (default_locale_id) REFERENCES public.locales(id);


--
-- Name: channels channels_root_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_root_category_id_foreign FOREIGN KEY (root_category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: cms_page_channels cms_page_channels_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_channels
    ADD CONSTRAINT cms_page_channels_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: cms_page_channels cms_page_channels_cms_page_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_channels
    ADD CONSTRAINT cms_page_channels_cms_page_id_foreign FOREIGN KEY (cms_page_id) REFERENCES public.cms_pages(id) ON DELETE CASCADE;


--
-- Name: cms_page_translations cms_page_translations_cms_page_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cms_page_translations
    ADD CONSTRAINT cms_page_translations_cms_page_id_foreign FOREIGN KEY (cms_page_id) REFERENCES public.cms_pages(id) ON DELETE CASCADE;


--
-- Name: b2b_company_attribute_group_mappings company_attr_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_group_mappings
    ADD CONSTRAINT company_attr_group_id_foreign FOREIGN KEY (company_attribute_group_id) REFERENCES public.b2b_company_attribute_groups(id) ON DELETE CASCADE;


--
-- Name: b2b_company_attribute_group_mappings company_attr_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_group_mappings
    ADD CONSTRAINT company_attr_id_foreign FOREIGN KEY (company_attribute_id) REFERENCES public.b2b_company_attributes(id) ON DELETE CASCADE;


--
-- Name: b2b_company_attribute_group_translations company_attribute_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_group_translations
    ADD CONSTRAINT company_attribute_group_id_foreign FOREIGN KEY (company_attribute_group_id) REFERENCES public.b2b_company_attribute_groups(id) ON DELETE CASCADE;


--
-- Name: b2b_company_attribute_option_translations company_attribute_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_company_attribute_option_translations
    ADD CONSTRAINT company_attribute_option_id_foreign FOREIGN KEY (company_attribute_option_id) REFERENCES public.b2b_company_attribute_options(id) ON DELETE CASCADE;


--
-- Name: compare_items compare_items_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compare_items
    ADD CONSTRAINT compare_items_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: compare_items compare_items_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compare_items
    ADD CONSTRAINT compare_items_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: country_state_translations country_state_translations_country_state_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_state_translations
    ADD CONSTRAINT country_state_translations_country_state_id_foreign FOREIGN KEY (country_state_id) REFERENCES public.country_states(id) ON DELETE CASCADE;


--
-- Name: country_states country_states_country_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_states
    ADD CONSTRAINT country_states_country_id_foreign FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE;


--
-- Name: country_translations country_translations_country_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country_translations
    ADD CONSTRAINT country_translations_country_id_foreign FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE;


--
-- Name: currency_exchange_rates currency_exchange_rates_target_currency_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_exchange_rates
    ADD CONSTRAINT currency_exchange_rates_target_currency_foreign FOREIGN KEY (target_currency) REFERENCES public.currencies(id) ON DELETE CASCADE;


--
-- Name: customer_notes customer_notes_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_notes
    ADD CONSTRAINT customer_notes_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: customer_social_accounts customer_social_accounts_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customer_social_accounts
    ADD CONSTRAINT customer_social_accounts_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: customers customers_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE SET NULL;


--
-- Name: customers customers_company_catalog_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_company_catalog_id_foreign FOREIGN KEY (company_catalog_id) REFERENCES public.b2b_company_catalogs(id) ON DELETE SET NULL;


--
-- Name: customers customers_company_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_company_role_id_foreign FOREIGN KEY (company_role_id) REFERENCES public.b2b_company_roles(id) ON DELETE SET NULL;


--
-- Name: customers customers_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE SET NULL;


--
-- Name: customers customers_sales_rep_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_sales_rep_id_foreign FOREIGN KEY (sales_rep_id) REFERENCES public.admins(id) ON DELETE SET NULL;


--
-- Name: downloadable_link_purchased downloadable_link_purchased_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_link_purchased
    ADD CONSTRAINT downloadable_link_purchased_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: downloadable_link_purchased downloadable_link_purchased_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_link_purchased
    ADD CONSTRAINT downloadable_link_purchased_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: downloadable_link_purchased downloadable_link_purchased_order_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.downloadable_link_purchased
    ADD CONSTRAINT downloadable_link_purchased_order_item_id_foreign FOREIGN KEY (order_item_id) REFERENCES public.order_items(id) ON DELETE CASCADE;


--
-- Name: eu_withdrawals eu_withdrawals_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eu_withdrawals
    ADD CONSTRAINT eu_withdrawals_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE RESTRICT;


--
-- Name: eu_withdrawals eu_withdrawals_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eu_withdrawals
    ADD CONSTRAINT eu_withdrawals_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;


--
-- Name: eu_withdrawals eu_withdrawals_declined_by_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eu_withdrawals
    ADD CONSTRAINT eu_withdrawals_declined_by_user_id_foreign FOREIGN KEY (declined_by_user_id) REFERENCES public.admins(id) ON DELETE SET NULL;


--
-- Name: eu_withdrawals eu_withdrawals_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eu_withdrawals
    ADD CONSTRAINT eu_withdrawals_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: eu_withdrawals eu_withdrawals_refunded_by_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eu_withdrawals
    ADD CONSTRAINT eu_withdrawals_refunded_by_user_id_foreign FOREIGN KEY (refunded_by_user_id) REFERENCES public.admins(id) ON DELETE SET NULL;


--
-- Name: gdpr_data_request gdpr_data_request_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gdpr_data_request
    ADD CONSTRAINT gdpr_data_request_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: product_image_translations image_translations_image_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_image_translations
    ADD CONSTRAINT image_translations_image_id_foreign FOREIGN KEY (product_image_id) REFERENCES public.product_images(id) ON DELETE CASCADE;


--
-- Name: import_batches import_batches_import_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_batches
    ADD CONSTRAINT import_batches_import_id_foreign FOREIGN KEY (import_id) REFERENCES public.imports(id) ON DELETE CASCADE;


--
-- Name: invoice_items invoice_items_invoice_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_foreign FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoice_items invoice_items_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.invoice_items(id) ON DELETE CASCADE;


--
-- Name: invoices invoices_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: product_downloadable_link_translations link_translations_link_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_link_translations
    ADD CONSTRAINT link_translations_link_id_foreign FOREIGN KEY (product_downloadable_link_id) REFERENCES public.product_downloadable_links(id) ON DELETE CASCADE;


--
-- Name: marketing_campaigns marketing_campaigns_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_campaigns
    ADD CONSTRAINT marketing_campaigns_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE SET NULL;


--
-- Name: marketing_campaigns marketing_campaigns_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_campaigns
    ADD CONSTRAINT marketing_campaigns_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE SET NULL;


--
-- Name: marketing_campaigns marketing_campaigns_marketing_event_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_campaigns
    ADD CONSTRAINT marketing_campaigns_marketing_event_id_foreign FOREIGN KEY (marketing_event_id) REFERENCES public.marketing_events(id) ON DELETE SET NULL;


--
-- Name: marketing_campaigns marketing_campaigns_marketing_template_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marketing_campaigns
    ADD CONSTRAINT marketing_campaigns_marketing_template_id_foreign FOREIGN KEY (marketing_template_id) REFERENCES public.marketing_templates(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_comments order_comments_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_comments
    ADD CONSTRAINT order_comments_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.order_items(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_tax_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_tax_category_id_foreign FOREIGN KEY (tax_category_id) REFERENCES public.tax_categories(id) ON DELETE SET NULL;


--
-- Name: order_payment order_payment_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_payment
    ADD CONSTRAINT order_payment_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_transactions order_transactions_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_transactions
    ADD CONSTRAINT order_transactions_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: orders orders_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE SET NULL;


--
-- Name: orders orders_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;


--
-- Name: product_customizable_option_prices pcop_product_customizable_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_option_prices
    ADD CONSTRAINT pcop_product_customizable_option_id_foreign FOREIGN KEY (product_customizable_option_id) REFERENCES public.product_customizable_options(id) ON DELETE CASCADE;


--
-- Name: product_customizable_option_translations pcot_product_customizable_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_option_translations
    ADD CONSTRAINT pcot_product_customizable_option_id_foreign FOREIGN KEY (product_customizable_option_id) REFERENCES public.product_customizable_options(id) ON DELETE CASCADE;


--
-- Name: product_attribute_values product_attribute_values_attribute_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_attribute_values
    ADD CONSTRAINT product_attribute_values_attribute_id_foreign FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE CASCADE;


--
-- Name: product_attribute_values product_attribute_values_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_attribute_values
    ADD CONSTRAINT product_attribute_values_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_bundle_option_products product_bundle_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_products
    ADD CONSTRAINT product_bundle_option_id_foreign FOREIGN KEY (product_bundle_option_id) REFERENCES public.product_bundle_options(id) ON DELETE CASCADE;


--
-- Name: product_bundle_option_products product_bundle_option_products_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_products
    ADD CONSTRAINT product_bundle_option_products_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_bundle_option_translations product_bundle_option_translations_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_option_translations
    ADD CONSTRAINT product_bundle_option_translations_option_id_foreign FOREIGN KEY (product_bundle_option_id) REFERENCES public.product_bundle_options(id) ON DELETE CASCADE;


--
-- Name: product_bundle_options product_bundle_options_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_bundle_options
    ADD CONSTRAINT product_bundle_options_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_categories product_categories_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: product_categories product_categories_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_channels product_channels_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_channels
    ADD CONSTRAINT product_channels_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: product_channels product_channels_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_channels
    ADD CONSTRAINT product_channels_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_cross_sells product_cross_sells_child_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_cross_sells
    ADD CONSTRAINT product_cross_sells_child_id_foreign FOREIGN KEY (child_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_cross_sells product_cross_sells_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_cross_sells
    ADD CONSTRAINT product_cross_sells_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_customer_group_prices product_customer_group_prices_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customer_group_prices
    ADD CONSTRAINT product_customer_group_prices_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE CASCADE;


--
-- Name: product_customer_group_prices product_customer_group_prices_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customer_group_prices
    ADD CONSTRAINT product_customer_group_prices_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_customizable_options product_customizable_options_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_customizable_options
    ADD CONSTRAINT product_customizable_options_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_downloadable_links product_downloadable_links_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_links
    ADD CONSTRAINT product_downloadable_links_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_downloadable_samples product_downloadable_samples_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_samples
    ADD CONSTRAINT product_downloadable_samples_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_flat product_flat_attribute_family_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_flat
    ADD CONSTRAINT product_flat_attribute_family_id_foreign FOREIGN KEY (attribute_family_id) REFERENCES public.attribute_families(id) ON DELETE RESTRICT;


--
-- Name: product_flat product_flat_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_flat
    ADD CONSTRAINT product_flat_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.product_flat(id) ON DELETE CASCADE;


--
-- Name: product_flat product_flat_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_flat
    ADD CONSTRAINT product_flat_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_grouped_products product_grouped_products_associated_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_grouped_products
    ADD CONSTRAINT product_grouped_products_associated_product_id_foreign FOREIGN KEY (associated_product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_grouped_products product_grouped_products_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_grouped_products
    ADD CONSTRAINT product_grouped_products_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_images product_images_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_inventories product_inventories_inventory_source_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventories
    ADD CONSTRAINT product_inventories_inventory_source_id_foreign FOREIGN KEY (inventory_source_id) REFERENCES public.inventory_sources(id) ON DELETE CASCADE;


--
-- Name: product_inventories product_inventories_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventories
    ADD CONSTRAINT product_inventories_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_inventory_indices product_inventory_indices_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventory_indices
    ADD CONSTRAINT product_inventory_indices_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: product_inventory_indices product_inventory_indices_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_inventory_indices
    ADD CONSTRAINT product_inventory_indices_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_omnibus_prices product_omnibus_prices_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_omnibus_prices
    ADD CONSTRAINT product_omnibus_prices_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: product_omnibus_prices product_omnibus_prices_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_omnibus_prices
    ADD CONSTRAINT product_omnibus_prices_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_ordered_inventories product_ordered_inventories_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_ordered_inventories
    ADD CONSTRAINT product_ordered_inventories_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: product_ordered_inventories product_ordered_inventories_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_ordered_inventories
    ADD CONSTRAINT product_ordered_inventories_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_price_indices product_price_indices_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_price_indices
    ADD CONSTRAINT product_price_indices_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: product_price_indices product_price_indices_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_price_indices
    ADD CONSTRAINT product_price_indices_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE CASCADE;


--
-- Name: product_price_indices product_price_indices_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_price_indices
    ADD CONSTRAINT product_price_indices_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_relations product_relations_child_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_relations
    ADD CONSTRAINT product_relations_child_id_foreign FOREIGN KEY (child_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_relations product_relations_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_relations
    ADD CONSTRAINT product_relations_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_review_attachments product_review_images_review_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_review_attachments
    ADD CONSTRAINT product_review_images_review_id_foreign FOREIGN KEY (review_id) REFERENCES public.product_reviews(id) ON DELETE CASCADE;


--
-- Name: product_reviews product_reviews_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_super_attributes product_super_attributes_attribute_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_super_attributes
    ADD CONSTRAINT product_super_attributes_attribute_id_foreign FOREIGN KEY (attribute_id) REFERENCES public.attributes(id) ON DELETE RESTRICT;


--
-- Name: product_super_attributes product_super_attributes_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_super_attributes
    ADD CONSTRAINT product_super_attributes_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_up_sells product_up_sells_child_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_up_sells
    ADD CONSTRAINT product_up_sells_child_id_foreign FOREIGN KEY (child_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_up_sells product_up_sells_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_up_sells
    ADD CONSTRAINT product_up_sells_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: product_videos product_videos_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_videos
    ADD CONSTRAINT product_videos_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: products products_attribute_family_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_attribute_family_id_foreign FOREIGN KEY (attribute_family_id) REFERENCES public.attribute_families(id) ON DELETE RESTRICT;


--
-- Name: products products_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: refund_items refund_items_order_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_items
    ADD CONSTRAINT refund_items_order_item_id_foreign FOREIGN KEY (order_item_id) REFERENCES public.order_items(id) ON DELETE CASCADE;


--
-- Name: refund_items refund_items_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_items
    ADD CONSTRAINT refund_items_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.refund_items(id) ON DELETE CASCADE;


--
-- Name: refund_items refund_items_refund_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund_items
    ADD CONSTRAINT refund_items_refund_id_foreign FOREIGN KEY (refund_id) REFERENCES public.refunds(id) ON DELETE CASCADE;


--
-- Name: refunds refunds_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refunds
    ADD CONSTRAINT refunds_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: rma_additional_fields rma_additional_fields_rma_custom_field_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_additional_fields
    ADD CONSTRAINT rma_additional_fields_rma_custom_field_id_foreign FOREIGN KEY (rma_custom_field_id) REFERENCES public.rma_custom_fields(id) ON DELETE CASCADE;


--
-- Name: rma_additional_fields rma_additional_fields_rma_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_additional_fields
    ADD CONSTRAINT rma_additional_fields_rma_id_foreign FOREIGN KEY (rma_id) REFERENCES public.rma(id) ON DELETE CASCADE;


--
-- Name: rma_custom_field_options rma_custom_field_options_rma_custom_field_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_custom_field_options
    ADD CONSTRAINT rma_custom_field_options_rma_custom_field_id_foreign FOREIGN KEY (rma_custom_field_id) REFERENCES public.rma_custom_fields(id) ON DELETE CASCADE;


--
-- Name: rma_images rma_images_rma_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_images
    ADD CONSTRAINT rma_images_rma_id_foreign FOREIGN KEY (rma_id) REFERENCES public.rma(id) ON DELETE CASCADE;


--
-- Name: rma_items rma_items_order_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_items
    ADD CONSTRAINT rma_items_order_item_id_foreign FOREIGN KEY (order_item_id) REFERENCES public.order_items(id) ON DELETE CASCADE;


--
-- Name: rma_items rma_items_rma_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_items
    ADD CONSTRAINT rma_items_rma_id_foreign FOREIGN KEY (rma_id) REFERENCES public.rma(id) ON DELETE CASCADE;


--
-- Name: rma_items rma_items_rma_reason_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_items
    ADD CONSTRAINT rma_items_rma_reason_id_foreign FOREIGN KEY (rma_reason_id) REFERENCES public.rma_reasons(id) ON DELETE SET NULL;


--
-- Name: rma_items rma_items_variant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_items
    ADD CONSTRAINT rma_items_variant_id_foreign FOREIGN KEY (variant_id) REFERENCES public.products(id) ON DELETE RESTRICT;


--
-- Name: rma_messages rma_messages_rma_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_messages
    ADD CONSTRAINT rma_messages_rma_id_foreign FOREIGN KEY (rma_id) REFERENCES public.rma(id) ON DELETE CASCADE;


--
-- Name: rma rma_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma
    ADD CONSTRAINT rma_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: rma_reason_resolutions rma_reason_resolutions_rma_reason_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma_reason_resolutions
    ADD CONSTRAINT rma_reason_resolutions_rma_reason_id_foreign FOREIGN KEY (rma_reason_id) REFERENCES public.rma_reasons(id) ON DELETE CASCADE;


--
-- Name: rma rma_rma_status_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rma
    ADD CONSTRAINT rma_rma_status_id_foreign FOREIGN KEY (rma_status_id) REFERENCES public.rma_statuses(id) ON DELETE SET NULL;


--
-- Name: product_downloadable_sample_translations sample_translations_sample_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_downloadable_sample_translations
    ADD CONSTRAINT sample_translations_sample_id_foreign FOREIGN KEY (product_downloadable_sample_id) REFERENCES public.product_downloadable_samples(id) ON DELETE CASCADE;


--
-- Name: search_terms search_terms_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.search_terms
    ADD CONSTRAINT search_terms_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: shipment_items shipment_items_shipment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipment_items
    ADD CONSTRAINT shipment_items_shipment_id_foreign FOREIGN KEY (shipment_id) REFERENCES public.shipments(id) ON DELETE CASCADE;


--
-- Name: shipments shipments_inventory_source_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_inventory_source_id_foreign FOREIGN KEY (inventory_source_id) REFERENCES public.inventory_sources(id) ON DELETE SET NULL;


--
-- Name: shipments shipments_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: sitemap_channels sitemap_channels_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sitemap_channels
    ADD CONSTRAINT sitemap_channels_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: sitemap_channels sitemap_channels_sitemap_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sitemap_channels
    ADD CONSTRAINT sitemap_channels_sitemap_id_foreign FOREIGN KEY (sitemap_id) REFERENCES public.sitemaps(id) ON DELETE CASCADE;


--
-- Name: subscribers_list subscribers_list_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscribers_list
    ADD CONSTRAINT subscribers_list_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: subscribers_list subscribers_list_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscribers_list
    ADD CONSTRAINT subscribers_list_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;


--
-- Name: tax_categories_tax_rates tax_categories_tax_rates_tax_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_categories_tax_rates
    ADD CONSTRAINT tax_categories_tax_rates_tax_category_id_foreign FOREIGN KEY (tax_category_id) REFERENCES public.tax_categories(id) ON DELETE CASCADE;


--
-- Name: tax_categories_tax_rates tax_categories_tax_rates_tax_rate_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tax_categories_tax_rates
    ADD CONSTRAINT tax_categories_tax_rates_tax_rate_id_foreign FOREIGN KEY (tax_rate_id) REFERENCES public.tax_rates(id) ON DELETE CASCADE;


--
-- Name: theme_section_translations theme_customization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_section_translations
    ADD CONSTRAINT theme_customization_id_foreign FOREIGN KEY (section_id) REFERENCES public.theme_sections(id) ON DELETE CASCADE;


--
-- Name: theme_sections theme_customizations_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.theme_sections
    ADD CONSTRAINT theme_customizations_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: vk7_enquiries vk7_enquiries_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_enquiries
    ADD CONSTRAINT vk7_enquiries_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE SET NULL;


--
-- Name: vk7_order_terms vk7_order_terms_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_order_terms
    ADD CONSTRAINT vk7_order_terms_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: vk7_payments vk7_payments_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_payments
    ADD CONSTRAINT vk7_payments_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: vk7_shipment_events vk7_shipment_events_shipment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_shipment_events
    ADD CONSTRAINT vk7_shipment_events_shipment_id_foreign FOREIGN KEY (shipment_id) REFERENCES public.vk7_shipments(id) ON DELETE CASCADE;


--
-- Name: vk7_shipments vk7_shipments_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_shipments
    ADD CONSTRAINT vk7_shipments_order_id_foreign FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: vk7_stock_log vk7_stock_log_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vk7_stock_log
    ADD CONSTRAINT vk7_stock_log_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: wishlist wishlist_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: wishlist wishlist_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: wishlist_items wishlist_items_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- Name: wishlist_items wishlist_items_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;


--
-- Name: wishlist_items wishlist_items_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist_items
    ADD CONSTRAINT wishlist_items_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- Name: wishlist wishlist_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wishlist
    ADD CONSTRAINT wishlist_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

