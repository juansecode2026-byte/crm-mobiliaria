-- ============================================================
-- MIGRATION 002: Core Tables — organizations, profiles, contacts
-- ============================================================

-- ============================================================
-- ORGANIZATIONS (tenants)
-- ============================================================
CREATE TABLE public.organizations (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                TEXT NOT NULL,
    slug                TEXT NOT NULL UNIQUE,
    legal_name          TEXT,
    tax_id              TEXT,
    country_code        CHAR(2) NOT NULL DEFAULT 'AR',
    timezone            TEXT NOT NULL DEFAULT 'America/Argentina/Buenos_Aires',
    currency            public.currency_code NOT NULL DEFAULT 'ARS',
    logo_url            TEXT,
    primary_color       CHAR(7),
    phone               TEXT,
    email               TEXT,
    address             TEXT,
    website             TEXT,
    plan                TEXT NOT NULL DEFAULT 'trial',
    plan_expires_at     TIMESTAMPTZ,
    max_users           INT NOT NULL DEFAULT 5,
    max_properties      INT NOT NULL DEFAULT 50,
    settings            JSONB NOT NULL DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_organizations_slug ON public.organizations (slug) WHERE deleted_at IS NULL;
CREATE INDEX idx_organizations_country ON public.organizations (country_code) WHERE deleted_at IS NULL;

-- ============================================================
-- PROFILES (CRM users — mirrors auth.users)
-- ============================================================
CREATE TABLE public.profiles (
    id                  UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    role                public.user_role NOT NULL DEFAULT 'agent',
    first_name          TEXT NOT NULL,
    last_name           TEXT NOT NULL,
    email               TEXT NOT NULL,
    phone               TEXT,
    avatar_url          TEXT,
    commission_rate     NUMERIC(5,2),
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    last_sign_in_at     TIMESTAMPTZ,
    contact_id          UUID,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_profiles_org_email ON public.profiles (organization_id, email);
CREATE INDEX idx_profiles_org_role ON public.profiles (organization_id, role) WHERE is_active = TRUE;
CREATE INDEX idx_profiles_contact ON public.profiles (contact_id) WHERE contact_id IS NOT NULL;

-- ============================================================
-- CONTACTS (leads, buyers, owners, tenants)
-- ============================================================
CREATE TABLE public.contacts (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    first_name          TEXT NOT NULL,
    last_name           TEXT NOT NULL,
    email               TEXT,
    phone               TEXT,
    phone_alt           TEXT,
    national_id         TEXT,
    national_id_type    TEXT,
    contact_type        public.contact_type NOT NULL DEFAULT 'lead',
    lead_source         public.lead_source,
    assigned_agent_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    address             TEXT,
    city                TEXT,
    province            TEXT,
    country_code        CHAR(2),
    tags                TEXT[] DEFAULT '{}',
    notes               TEXT,
    external_ids        JSONB DEFAULT '{}',
    gdpr_consent        BOOLEAN NOT NULL DEFAULT FALSE,
    gdpr_consent_at     TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

CREATE INDEX idx_contacts_org ON public.contacts (organization_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_contacts_agent ON public.contacts (organization_id, assigned_agent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_contacts_type ON public.contacts (organization_id, contact_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_contacts_email ON public.contacts (organization_id, email) WHERE deleted_at IS NULL AND email IS NOT NULL;
CREATE INDEX idx_contacts_phone ON public.contacts (organization_id, phone) WHERE deleted_at IS NULL AND phone IS NOT NULL;
CREATE INDEX idx_contacts_name_trgm ON public.contacts
    USING GIN (
        (unaccent(first_name) || ' ' || unaccent(last_name)) gin_trgm_ops
    ) WHERE deleted_at IS NULL;
CREATE INDEX idx_contacts_tags ON public.contacts USING GIN (tags) WHERE deleted_at IS NULL;

-- Back-reference FK from profiles to contacts (buyer portal)
ALTER TABLE public.profiles
    ADD CONSTRAINT fk_profiles_contact
    FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE SET NULL;
