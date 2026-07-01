-- ============================================================
-- MIGRATION 016: Portal Publications (Publicaciones en Portales)
-- Tracks the publication status of each property on each external portal
-- ============================================================

CREATE TYPE public.publication_plan AS ENUM (
    'free',
    'premium',
    'featured',
    'super_featured'
);

CREATE TYPE public.publication_status AS ENUM (
    'pending',
    'active',
    'inactive',
    'paused',
    'error'
);

-- ============================================================
-- PORTAL PUBLICATIONS
-- ============================================================
CREATE TABLE public.portal_publications (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    property_id         UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    provider            public.integration_provider NOT NULL,
    external_id         TEXT,
    plan                public.publication_plan NOT NULL DEFAULT 'free',
    status              public.publication_status NOT NULL DEFAULT 'pending',
    url                 TEXT,
    last_sync_at        TIMESTAMPTZ,
    error_message       TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_publication_property_provider UNIQUE (property_id, provider)
);

CREATE INDEX idx_portal_pub_org ON public.portal_publications (organization_id);
CREATE INDEX idx_portal_pub_property ON public.portal_publications (property_id);
CREATE INDEX idx_portal_pub_status ON public.portal_publications (organization_id, status);
CREATE INDEX idx_portal_pub_provider ON public.portal_publications (organization_id, provider);

-- Trigger updated_at
CREATE TRIGGER trg_set_updated_at_portal_publications
    BEFORE UPDATE ON public.portal_publications
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- RLS
ALTER TABLE public.portal_publications ENABLE ROW LEVEL SECURITY;

CREATE POLICY pol_portal_pub_select ON public.portal_publications
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() != 'buyer'
    );

CREATE POLICY pol_portal_pub_insert ON public.portal_publications
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager')
    );

CREATE POLICY pol_portal_pub_update ON public.portal_publications
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() IN ('admin', 'manager')
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());
