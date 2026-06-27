-- ============================================================
-- MIGRATION 003: Properties
-- ============================================================

CREATE TABLE public.properties (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    internal_code       TEXT,
    title               TEXT NOT NULL,
    description         TEXT,
    property_type       public.property_type NOT NULL,
    operation_type      public.operation_type NOT NULL,
    status              public.property_status NOT NULL DEFAULT 'available',
    price               NUMERIC(15,2) NOT NULL,
    currency            public.currency_code NOT NULL,
    price_usd           NUMERIC(15,2),
    expenses            NUMERIC(10,2),
    expenses_currency   public.currency_code,
    address             TEXT NOT NULL,
    address_number      TEXT,
    floor               TEXT,
    apartment           TEXT,
    city                TEXT NOT NULL,
    province            TEXT NOT NULL,
    country_code        CHAR(2) NOT NULL DEFAULT 'AR',
    postal_code         TEXT,
    latitude            NUMERIC(10,7),
    longitude           NUMERIC(10,7),
    neighborhood        TEXT,
    total_area_m2       NUMERIC(10,2),
    covered_area_m2     NUMERIC(10,2),
    rooms               SMALLINT,
    bedrooms            SMALLINT,
    bathrooms           SMALLINT,
    garages             SMALLINT,
    floor_number        SMALLINT,
    total_floors        SMALLINT,
    year_built          SMALLINT,
    owner_contact_id    UUID REFERENCES public.contacts(id) ON DELETE SET NULL,
    assigned_agent_id   UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    commission_rate     NUMERIC(5,2),
    commission_currency public.currency_code,
    external_ids        JSONB DEFAULT '{}',
    portal_published    JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ,
    CONSTRAINT uq_property_internal_code UNIQUE (organization_id, internal_code)
);

CREATE INDEX idx_properties_org ON public.properties (organization_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_properties_status ON public.properties (organization_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_properties_type ON public.properties (organization_id, property_type, operation_type) WHERE deleted_at IS NULL;
CREATE INDEX idx_properties_agent ON public.properties (organization_id, assigned_agent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_properties_location ON public.properties (organization_id, city, province) WHERE deleted_at IS NULL;
CREATE INDEX idx_properties_price ON public.properties (organization_id, price, currency) WHERE deleted_at IS NULL AND status = 'available';
CREATE INDEX idx_properties_geo ON public.properties (latitude, longitude) WHERE deleted_at IS NULL AND latitude IS NOT NULL;
CREATE INDEX idx_properties_title_trgm ON public.properties
    USING GIN (unaccent(title) gin_trgm_ops) WHERE deleted_at IS NULL;

-- ============================================================
-- PROPERTY IMAGES
-- ============================================================
CREATE TABLE public.property_images (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id         UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    storage_path        TEXT NOT NULL,
    url                 TEXT NOT NULL,
    alt_text            TEXT,
    sort_order          SMALLINT NOT NULL DEFAULT 0,
    is_cover            BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_property_images_property ON public.property_images (property_id, sort_order);
CREATE INDEX idx_property_images_org ON public.property_images (organization_id);

-- ============================================================
-- PROPERTY FEATURES
-- ============================================================
CREATE TABLE public.property_features (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id         UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    feature_key         TEXT NOT NULL,
    feature_value       TEXT NOT NULL DEFAULT 'true',
    CONSTRAINT uq_property_feature UNIQUE (property_id, feature_key)
);

CREATE INDEX idx_property_features_property ON public.property_features (property_id);
CREATE INDEX idx_property_features_org_key ON public.property_features (organization_id, feature_key);
