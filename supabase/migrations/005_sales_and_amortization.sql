-- ============================================================
-- MIGRATION 005: Sales, Amortization, and Cuotas (THE differentiator)
-- ============================================================

-- ============================================================
-- SALES
-- ============================================================
CREATE TABLE public.sales (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id         UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    opportunity_id          UUID UNIQUE REFERENCES public.opportunities(id) ON DELETE RESTRICT,
    contact_id              UUID NOT NULL REFERENCES public.contacts(id) ON DELETE RESTRICT,
    property_id             UUID NOT NULL REFERENCES public.properties(id) ON DELETE RESTRICT,
    agent_id                UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    sale_price              NUMERIC(15,2) NOT NULL,
    sale_currency           public.currency_code NOT NULL,
    commission_rate         NUMERIC(5,2),
    commission_amount       NUMERIC(15,2),
    commission_currency     public.currency_code,
    sale_date               DATE NOT NULL,
    escritura_date          DATE,
    possession_date         DATE,
    has_financing           BOOLEAN NOT NULL DEFAULT FALSE,
    down_payment            NUMERIC(15,2),
    down_payment_currency   public.currency_code,
    financed_amount         NUMERIC(15,2),
    is_cancelled            BOOLEAN NOT NULL DEFAULT FALSE,
    cancelled_at            TIMESTAMPTZ,
    cancellation_reason     TEXT,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sales_org ON public.sales (organization_id);
CREATE INDEX idx_sales_contact ON public.sales (contact_id);
CREATE INDEX idx_sales_property ON public.sales (property_id);
CREATE INDEX idx_sales_agent ON public.sales (organization_id, agent_id);
CREATE INDEX idx_sales_date ON public.sales (organization_id, sale_date DESC);

-- ============================================================
-- AMORTIZATION SCHEDULES (header)
-- ============================================================
CREATE TABLE public.amortization_schedules (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    sale_id             UUID NOT NULL REFERENCES public.sales(id) ON DELETE RESTRICT,
    amortization_type   public.amortization_type NOT NULL DEFAULT 'french',
    principal           NUMERIC(15,2) NOT NULL,
    interest_rate       NUMERIC(8,5) NOT NULL DEFAULT 0,
    total_installments  SMALLINT NOT NULL,
    currency            public.currency_code NOT NULL,
    start_date          DATE NOT NULL,
    adjustment_index    TEXT,
    total_principal     NUMERIC(15,2) NOT NULL,
    total_interest      NUMERIC(15,2) NOT NULL DEFAULT 0,
    total_amount        NUMERIC(15,2) NOT NULL,
    version             SMALLINT NOT NULL DEFAULT 1,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by          UUID REFERENCES public.profiles(id) ON DELETE SET NULL
);

CREATE INDEX idx_amort_sale ON public.amortization_schedules (sale_id) WHERE is_active = TRUE;
CREATE INDEX idx_amort_org ON public.amortization_schedules (organization_id);

-- ============================================================
-- AMORTIZATION LINES (detail rows)
-- ============================================================
CREATE TABLE public.amortization_lines (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    schedule_id         UUID NOT NULL REFERENCES public.amortization_schedules(id) ON DELETE CASCADE,
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    installment_number  SMALLINT NOT NULL,
    due_date            DATE NOT NULL,
    principal_amount    NUMERIC(15,2) NOT NULL DEFAULT 0,
    interest_amount     NUMERIC(15,2) NOT NULL DEFAULT 0,
    adjustment_amount   NUMERIC(15,2) NOT NULL DEFAULT 0,
    total_amount        NUMERIC(15,2) NOT NULL,
    outstanding_balance NUMERIC(15,2) NOT NULL,
    currency            public.currency_code NOT NULL,
    CONSTRAINT uq_schedule_installment UNIQUE (schedule_id, installment_number)
);

CREATE INDEX idx_amort_lines_schedule ON public.amortization_lines (schedule_id, installment_number);
CREATE INDEX idx_amort_lines_due_date ON public.amortization_lines (organization_id, due_date);

-- ============================================================
-- CUOTAS (operational quota instances — THE differentiator)
-- Created automatically by trigger when amortization_lines are inserted
-- ============================================================
CREATE TABLE public.cuotas (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id         UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    sale_id                 UUID NOT NULL REFERENCES public.sales(id) ON DELETE RESTRICT,
    amortization_line_id    UUID REFERENCES public.amortization_lines(id) ON DELETE SET NULL,
    contact_id              UUID NOT NULL REFERENCES public.contacts(id) ON DELETE RESTRICT,
    installment_number      SMALLINT NOT NULL,
    due_date                DATE NOT NULL,
    amount_due              NUMERIC(15,2) NOT NULL,
    currency                public.currency_code NOT NULL,
    status                  public.quota_status NOT NULL DEFAULT 'pending',
    amount_paid             NUMERIC(15,2) NOT NULL DEFAULT 0,
    amount_outstanding      NUMERIC(15,2) GENERATED ALWAYS AS (amount_due - amount_paid) STORED,
    last_payment_date       DATE,
    days_overdue            SMALLINT GENERATED ALWAYS AS (
                                CASE
                                    WHEN status IN ('pending', 'partial') AND due_date < CURRENT_DATE
                                    THEN GREATEST(0, (CURRENT_DATE - due_date)::INT)
                                    ELSE 0
                                END
                            ) STORED,
    late_fee_rate           NUMERIC(5,4) DEFAULT 0,
    late_fee_amount         NUMERIC(15,2) NOT NULL DEFAULT 0,
    rescheduled_from_id     UUID REFERENCES public.cuotas(id) ON DELETE SET NULL,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_cuota_sale_installment UNIQUE (sale_id, installment_number)
);

CREATE INDEX idx_cuotas_org ON public.cuotas (organization_id);
CREATE INDEX idx_cuotas_sale ON public.cuotas (sale_id);
CREATE INDEX idx_cuotas_contact ON public.cuotas (contact_id, status);
CREATE INDEX idx_cuotas_status ON public.cuotas (organization_id, status, due_date);
CREATE INDEX idx_cuotas_due_date ON public.cuotas (organization_id, due_date) WHERE status IN ('pending', 'partial');
