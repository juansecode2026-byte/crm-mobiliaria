-- ============================================================
-- MIGRATION 006: Payments and Documents
-- Payments are registered against an operation (señas, anticipos, pagos totales).
-- The full installment/cuota module is planned for a future migration.
-- ============================================================

-- ============================================================
-- PAYMENTS
-- ============================================================
CREATE TABLE public.payments (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id         UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    operation_id            UUID NOT NULL REFERENCES public.operations(id) ON DELETE RESTRICT,
    contact_id              UUID NOT NULL REFERENCES public.contacts(id) ON DELETE RESTRICT,
    received_by             UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    concept                 TEXT NOT NULL,
    amount                  NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    currency                public.currency_code NOT NULL,
    payment_date            DATE NOT NULL,
    payment_method          public.payment_method NOT NULL DEFAULT 'cash',
    reference_number        TEXT,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_org ON public.payments (organization_id);
CREATE INDEX idx_payments_operation ON public.payments (operation_id);
CREATE INDEX idx_payments_contact ON public.payments (contact_id);
CREATE INDEX idx_payments_date ON public.payments (organization_id, payment_date DESC);

-- ============================================================
-- DOCUMENTS (metadata de PDFs — archivos en Supabase Storage)
-- ============================================================
CREATE TABLE public.documents (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id         UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    document_type           public.document_type NOT NULL,
    entity_type             public.activity_entity_type NOT NULL,
    entity_id               UUID NOT NULL,
    storage_path            TEXT NOT NULL,
    filename                TEXT NOT NULL,
    file_size_bytes         INT,
    mime_type               TEXT NOT NULL DEFAULT 'application/pdf',
    is_public               BOOLEAN NOT NULL DEFAULT FALSE,
    generated_by            UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes                   TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_documents_org ON public.documents (organization_id);
CREATE INDEX idx_documents_entity ON public.documents (entity_type, entity_id);
CREATE INDEX idx_documents_type ON public.documents (organization_id, document_type);
