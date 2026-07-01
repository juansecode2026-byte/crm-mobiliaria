-- ============================================================
-- MIGRATION 001: Extensions and Enums
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "btree_gin";

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE public.user_role AS ENUM (
    'admin',
    'manager',
    'agent',
    'buyer'
);

CREATE TYPE public.property_status AS ENUM (
    'available',
    'reserved',
    'sold',
    'rented',
    'inactive'
);

CREATE TYPE public.property_type AS ENUM (
    'apartment',
    'house',
    'land',
    'commercial',
    'office',
    'warehouse',
    'ph',
    'duplex'
);

CREATE TYPE public.operation_type AS ENUM (
    'sale',
    'rent',
    'temporary_rent'
);

CREATE TYPE public.pipeline_stage AS ENUM (
    'prospecto',
    'interesado',
    'negociando',
    'cierre',
    'vendido',
    'perdido'
);

CREATE TYPE public.contact_type AS ENUM (
    'lead',
    'prospect',
    'buyer',
    'tenant',
    'owner'
);

CREATE TYPE public.lead_source AS ENUM (
    'zonaprop',
    'argenprop',
    'mercadolibre',
    'facebook_ads',
    'instagram',
    'whatsapp',
    'referral',
    'direct',
    'website',
    'other'
);

CREATE TYPE public.quota_status AS ENUM (
    'pending',
    'paid',
    'partial',
    'overdue',
    'forgiven',
    'rescheduled'
);

CREATE TYPE public.payment_method AS ENUM (
    'cash',
    'bank_transfer',
    'check',
    'credit_card',
    'debit_card',
    'crypto',
    'other'
);

CREATE TYPE public.currency_code AS ENUM (
    'ARS',
    'USD',
    'UYU',
    'CLP',
    'COP',
    'BRL',
    'MXN',
    'PEN'
);

CREATE TYPE public.amortization_type AS ENUM (
    'french',
    'german',
    'american',
    'fixed',
    'custom'
);

CREATE TYPE public.activity_entity_type AS ENUM (
    'contact',
    'property',
    'operation',
    'payment',
    'document'
);

CREATE TYPE public.activity_type AS ENUM (
    'created',
    'updated',
    'deleted',
    'stage_changed',
    'payment_received',
    'payment_overdue',
    'document_generated',
    'note_added',
    'call_logged',
    'email_sent',
    'whatsapp_sent',
    'visit_scheduled',
    'visit_completed'
);

CREATE TYPE public.notification_type AS ENUM (
    'payment_overdue',
    'payment_due_soon',
    'stage_changed',
    'new_lead',
    'document_ready',
    'system'
);

CREATE TYPE public.notification_channel AS ENUM (
    'in_app',
    'email',
    'whatsapp',
    'push'
);

CREATE TYPE public.document_type AS ENUM (
    'receipt',
    'amortization_table',
    'sale_contract',
    'reservation_form',
    'id_document',
    'property_title',
    'other'
);

CREATE TYPE public.integration_provider AS ENUM (
    'zonaprop',
    'argenprop',
    'mercadolibre',
    'facebook_ads',
    'whatsapp_business',
    'n8n'
);
