-- ============================================================
-- MIGRATION 004: Pipeline — Operaciones
-- "Operación" es el término estándar en el mercado inmobiliario colombiano.
-- Cubre el ciclo completo: lead → negociación → cierre de la venta.
-- ============================================================

CREATE TABLE public.operations (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id         UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    contact_id              UUID NOT NULL REFERENCES public.contacts(id) ON DELETE RESTRICT,
    property_id             UUID NOT NULL REFERENCES public.properties(id) ON DELETE RESTRICT,
    assigned_agent_id       UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    title                   TEXT NOT NULL,
    stage                   public.pipeline_stage NOT NULL DEFAULT 'prospecto',
    stage_changed_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Precio ofrecido por el comprador
    offered_price           NUMERIC(15,2),
    offered_currency        public.currency_code,

    -- Datos del cierre (se llenan cuando stage = 'vendido')
    closed_price            NUMERIC(15,2),
    closed_currency         public.currency_code,
    closed_date             DATE,
    commission_rate         NUMERIC(5,2),
    commission_amount       NUMERIC(15,2),
    commission_currency     public.currency_code,

    lost_reason             TEXT,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMPTZ
);

CREATE INDEX idx_operations_org ON public.operations (organization_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_operations_stage ON public.operations (organization_id, stage) WHERE deleted_at IS NULL;
CREATE INDEX idx_operations_agent ON public.operations (organization_id, assigned_agent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_operations_contact ON public.operations (contact_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_operations_property ON public.operations (property_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_operations_kanban ON public.operations (organization_id, stage, stage_changed_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_operations_closed ON public.operations (organization_id, closed_date DESC) WHERE closed_date IS NOT NULL;

-- ============================================================
-- OPERATION ACTIVITIES (log de interacciones por operación)
-- ============================================================
CREATE TABLE public.operation_activities (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    operation_id        UUID NOT NULL REFERENCES public.operations(id) ON DELETE CASCADE,
    performed_by        UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    activity_type       public.activity_type NOT NULL,
    description         TEXT NOT NULL,
    activity_date       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata            JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_op_activities_operation ON public.operation_activities (operation_id, activity_date DESC);
CREATE INDEX idx_op_activities_org ON public.operation_activities (organization_id, activity_date DESC);
