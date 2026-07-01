-- ============================================================
-- MIGRATION 011: Developments (Emprendimientos / Proyectos)
-- ============================================================

CREATE TYPE public.development_status AS ENUM (
    'active',
    'paused',
    'sold_out',
    'finished'
);

-- ============================================================
-- DEVELOPMENTS (header del proyecto)
-- ============================================================
CREATE TABLE public.developments (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id         UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    name                    TEXT NOT NULL,
    description             TEXT,
    developer_name          TEXT,
    developer_contact_id    UUID REFERENCES public.contacts(id) ON DELETE SET NULL,
    property_type           public.property_type NOT NULL DEFAULT 'apartment',
    address                 TEXT,
    city                    TEXT,
    province                TEXT,
    country_code            CHAR(2) DEFAULT 'AR',
    neighborhood            TEXT,
    total_units             SMALLINT NOT NULL DEFAULT 0,
    available_units         SMALLINT NOT NULL DEFAULT 0,
    status                  public.development_status NOT NULL DEFAULT 'active',
    start_date              DATE,
    estimated_completion    DATE,
    cover_image_url         TEXT,
    brochure_url            TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

CREATE INDEX idx_developments_org ON public.developments (organization_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_developments_status ON public.developments (organization_id, status) WHERE deleted_at IS NULL;

-- Vincular propiedades individuales a un desarrollo
ALTER TABLE public.properties ADD COLUMN development_id UUID REFERENCES public.developments(id) ON DELETE SET NULL;
ALTER TABLE public.properties ADD COLUMN unit_number TEXT;

CREATE INDEX idx_properties_development ON public.properties (development_id) WHERE development_id IS NOT NULL;

-- Trigger updated_at
CREATE TRIGGER trg_set_updated_at_developments
    BEFORE UPDATE ON public.developments
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- RLS
ALTER TABLE public.developments ENABLE ROW LEVEL SECURITY;

CREATE POLICY pol_developments_select ON public.developments
    FOR SELECT TO authenticated
    USING (organization_id = public.fn_current_organization_id() AND deleted_at IS NULL);

CREATE POLICY pol_developments_insert ON public.developments
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager', 'agent')
    );

CREATE POLICY pol_developments_update ON public.developments
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND deleted_at IS NULL
        AND public.fn_is_admin_or_manager()
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());
