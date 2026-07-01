-- ============================================================
-- MIGRATION 018: Message Templates (Plantillas de Mensajes)
-- Reusable WhatsApp/email templates with dynamic variables
-- ============================================================

CREATE TYPE public.message_channel AS ENUM (
    'whatsapp',
    'email',
    'sms',
    'in_app'
);

-- ============================================================
-- MESSAGE TEMPLATES
-- ============================================================
CREATE TABLE public.message_templates (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    name                TEXT NOT NULL,
    channel             public.message_channel NOT NULL,
    subject             TEXT,
    body                TEXT NOT NULL,
    variables           TEXT[] DEFAULT '{}',
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_by          UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_template_name_channel UNIQUE (organization_id, name, channel)
);

CREATE INDEX idx_message_templates_org ON public.message_templates (organization_id) WHERE is_active = TRUE;
CREATE INDEX idx_message_templates_channel ON public.message_templates (organization_id, channel) WHERE is_active = TRUE;

-- Trigger updated_at
CREATE TRIGGER trg_set_updated_at_message_templates
    BEFORE UPDATE ON public.message_templates
    FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();

-- RLS
ALTER TABLE public.message_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY pol_templates_select ON public.message_templates
    FOR SELECT TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_current_role() != 'buyer'
        AND is_active = TRUE
    );

CREATE POLICY pol_templates_insert ON public.message_templates
    FOR INSERT TO authenticated
    WITH CHECK (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    );

CREATE POLICY pol_templates_update ON public.message_templates
    FOR UPDATE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    )
    WITH CHECK (organization_id = public.fn_current_organization_id());

CREATE POLICY pol_templates_delete ON public.message_templates
    FOR DELETE TO authenticated
    USING (
        organization_id = public.fn_current_organization_id()
        AND public.fn_is_admin_or_manager()
    );
