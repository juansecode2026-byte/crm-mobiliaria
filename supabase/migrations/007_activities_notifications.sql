-- ============================================================
-- MIGRATION 007: Activities, Notifications, Integrations
-- ============================================================

-- ============================================================
-- ACTIVITIES (immutable audit log — append only)
-- ============================================================
CREATE TABLE public.activities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    performed_by    UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    activity_type   public.activity_type NOT NULL,
    entity_type     public.activity_entity_type NOT NULL,
    entity_id       UUID NOT NULL,
    old_values      JSONB,
    new_values      JSONB,
    metadata        JSONB DEFAULT '{}',
    description     TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
    -- No updated_at: this table is append-only
);

CREATE INDEX idx_activities_org ON public.activities (organization_id, created_at DESC);
CREATE INDEX idx_activities_entity ON public.activities (entity_type, entity_id, created_at DESC);
CREATE INDEX idx_activities_user ON public.activities (performed_by, created_at DESC);
CREATE INDEX idx_activities_type ON public.activities (organization_id, activity_type, created_at DESC);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE public.notifications (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id         UUID NOT NULL REFERENCES public.organizations(id) ON DELETE RESTRICT,
    recipient_profile_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    notification_type       public.notification_type NOT NULL,
    channel                 public.notification_channel NOT NULL DEFAULT 'in_app',
    title                   TEXT NOT NULL,
    body                    TEXT NOT NULL,
    entity_type             public.activity_entity_type,
    entity_id               UUID,
    action_url              TEXT,
    is_read                 BOOLEAN NOT NULL DEFAULT FALSE,
    read_at                 TIMESTAMPTZ,
    is_sent                 BOOLEAN NOT NULL DEFAULT FALSE,
    sent_at                 TIMESTAMPTZ,
    send_error              TEXT,
    scheduled_for           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_recipient ON public.notifications (recipient_profile_id, is_read, created_at DESC);
CREATE INDEX idx_notifications_org ON public.notifications (organization_id, created_at DESC);
CREATE INDEX idx_notifications_pending ON public.notifications (scheduled_for) WHERE is_sent = FALSE;
CREATE INDEX idx_notifications_entity ON public.notifications (entity_type, entity_id);

-- ============================================================
-- INTEGRATIONS (webhook/API configs per organization)
-- ============================================================
CREATE TABLE public.integrations (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id     UUID NOT NULL REFERENCES public.organizations(id) ON DELETE CASCADE,
    provider            public.integration_provider NOT NULL,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    config              JSONB NOT NULL DEFAULT '{}',
    last_sync_at        TIMESTAMPTZ,
    last_sync_status    TEXT,
    last_sync_error     TEXT,
    sync_cursor         JSONB DEFAULT '{}',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_org_provider UNIQUE (organization_id, provider)
);

CREATE INDEX idx_integrations_org ON public.integrations (organization_id) WHERE is_active = TRUE;
