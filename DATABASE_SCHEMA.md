# CRM Mobiliaria — Database Schema

Stack: Supabase (PostgreSQL 15) con Row Level Security (RLS).  
Multi-tenancy: single schema + `organization_id` en cada tabla de negocio.

---

## Entity Relationship Overview

```
organizations
    │
    ├── profiles ──────────────────────────── (espeja auth.users)
    │
    ├── contacts ──────────────────────────── (leads, compradores, propietarios)
    │       └── [assigned_agent_id → profiles]
    │
    ├── properties ────────────────────────── (propiedades en cartera)
    │       ├── property_images
    │       └── property_features
    │
    ├── opportunities ─────────────────────── (pipeline Kanban)
    │       ├── [contact_id → contacts]
    │       ├── [property_id → properties]
    │       └── opportunity_activities
    │
    └── sales ─────────────────────────────── (ventas cerradas)
            ├── [contact_id → contacts]       (comprador)
            ├── [property_id → properties]
            ├── amortization_schedules
            │       └── amortization_lines ── (trigger → crea cuotas)
            └── cuotas ─────────────────────── (THE differentiator)
                    └── payments ────────────── (pagos recibidos)
                            └── documents ───── (PDFs en Storage)

activities    → Audit log inmutable (append-only)
notifications → Alertas por rol
integrations  → Configs ZonaProp, FB Ads, n8n
```

---

## Enums

| Enum | Valores |
|------|---------|
| `user_role` | `admin`, `manager`, `agent`, `buyer` |
| `property_status` | `available`, `reserved`, `sold`, `rented`, `inactive` |
| `property_type` | `apartment`, `house`, `land`, `commercial`, `office`, `warehouse`, `ph`, `duplex` |
| `operation_type` | `sale`, `rent`, `temporary_rent` |
| `pipeline_stage` | `prospecto`, `interesado`, `negociando`, `cierre`, `vendido`, `perdido` |
| `contact_type` | `lead`, `prospect`, `buyer`, `tenant`, `owner` |
| `lead_source` | `zonaprop`, `argenprop`, `mercadolibre`, `facebook_ads`, `instagram`, `whatsapp`, `referral`, `direct`, `website`, `other` |
| `quota_status` | `pending`, `paid`, `partial`, `overdue`, `forgiven`, `rescheduled` |
| `payment_method` | `cash`, `bank_transfer`, `check`, `credit_card`, `debit_card`, `crypto`, `other` |
| `currency_code` | `ARS`, `USD`, `UYU`, `CLP`, `COP`, `BRL`, `MXN`, `PEN` |
| `amortization_type` | `french`, `german`, `american`, `fixed`, `custom` |
| `activity_entity_type` | `contact`, `property`, `opportunity`, `sale`, `cuota`, `payment`, `document` |
| `activity_type` | `created`, `updated`, `deleted`, `stage_changed`, `payment_received`, `payment_overdue`, `document_generated`, `note_added`, `call_logged`, `email_sent`, `whatsapp_sent`, `visit_scheduled`, `visit_completed` |
| `notification_type` | `payment_overdue`, `payment_due_soon`, `stage_changed`, `new_lead`, `document_ready`, `system` |
| `notification_channel` | `in_app`, `email`, `whatsapp`, `push` |
| `document_type` | `receipt`, `amortization_table`, `sale_contract`, `reservation_form`, `id_document`, `property_title`, `other` |
| `integration_provider` | `zonaprop`, `argenprop`, `mercadolibre`, `facebook_ads`, `whatsapp_business`, `n8n` |

---

## Tables

### `organizations` — Tenants (inmobiliarias)

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | `uuid_generate_v4()` |
| `name` | `TEXT NOT NULL` | "Inmobiliaria San Martín" |
| `slug` | `TEXT UNIQUE NOT NULL` | URL-friendly, ej: "inmo-san-martin" |
| `legal_name` | `TEXT` | Razón social |
| `tax_id` | `TEXT` | CUIT / RUT / RUC |
| `country_code` | `CHAR(2)` | ISO 3166-1, default `'AR'` |
| `timezone` | `TEXT` | default `'America/Argentina/Buenos_Aires'` |
| `currency` | `currency_code` | Moneda base de la org |
| `logo_url` | `TEXT` | |
| `primary_color` | `CHAR(7)` | HEX para white-labeling |
| `phone`, `email`, `address`, `website` | `TEXT` | |
| `plan` | `TEXT` | `'trial'`, `'starter'`, `'pro'`, `'enterprise'` |
| `plan_expires_at` | `TIMESTAMPTZ` | |
| `max_users` | `INT` | default 5 |
| `max_properties` | `INT` | default 50 |
| `settings` | `JSONB` | Config flexible (overdue_alert_days, etc.) |
| `created_at`, `updated_at` | `TIMESTAMPTZ` | |
| `deleted_at` | `TIMESTAMPTZ` | Soft delete |

**RLS:** Todo usuario autenticado ve solo su propia organización. Solo admin puede modificar.

---

### `profiles` — Usuarios CRM (espeja auth.users)

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | = `auth.users.id` (FK CASCADE) |
| `organization_id` | `UUID NOT NULL` | FK → organizations |
| `role` | `user_role` | default `'agent'` |
| `first_name`, `last_name` | `TEXT NOT NULL` | |
| `email` | `TEXT NOT NULL` | Denormalizado de auth.users |
| `phone` | `TEXT` | |
| `avatar_url` | `TEXT` | |
| `commission_rate` | `NUMERIC(5,2)` | % comisión default del agente |
| `is_active` | `BOOLEAN` | default TRUE |
| `contact_id` | `UUID` | FK → contacts (para buyer portal) |
| `last_sign_in_at` | `TIMESTAMPTZ` | |
| `created_at`, `updated_at` | `TIMESTAMPTZ` | |

**Índices:** `(organization_id, email)` UNIQUE, `(organization_id, role)` WHERE is_active  
**Trigger:** `fn_handle_new_auth_user` — crea perfil automáticamente al registrar en auth  
**RLS:** CRM users ven todos en su org. Buyers solo se ven a sí mismos.

---

### `contacts` — Leads, compradores, propietarios, inquilinos

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `first_name`, `last_name` | `TEXT NOT NULL` | |
| `email`, `phone`, `phone_alt` | `TEXT` | |
| `national_id` | `TEXT` | DNI, CI, RUN, CPF |
| `national_id_type` | `TEXT` | Tipo de documento |
| `contact_type` | `contact_type` | default `'lead'` |
| `lead_source` | `lead_source` | |
| `assigned_agent_id` | `UUID` | FK → profiles |
| `address`, `city`, `province`, `country_code` | `TEXT/CHAR` | |
| `tags` | `TEXT[]` | `['inversor', 'urgente']` |
| `notes` | `TEXT` | |
| `external_ids` | `JSONB` | `{zonaprop_id, facebook_lead_id}` |
| `gdpr_consent` | `BOOLEAN` | default FALSE |
| `gdpr_consent_at` | `TIMESTAMPTZ` | |
| `created_at`, `updated_at`, `deleted_at` | `TIMESTAMPTZ` | |

**Índices:** org, org+agent, org+type, email, phone, name (GIN trgm), tags (GIN)  
**RLS:** Admin/Gerente: todos en org. Agente: solo asignados. Comprador: bloqueado.

---

### `properties` — Propiedades en cartera

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `internal_code` | `TEXT` | UNIQUE por org, ej: "APT-0042" |
| `title` | `TEXT NOT NULL` | "Departamento 3 amb. en Palermo" |
| `description` | `TEXT` | |
| `property_type` | `property_type` | |
| `operation_type` | `operation_type` | |
| `status` | `property_status` | default `'available'` |
| `price`, `currency` | `NUMERIC(15,2)`, `currency_code` | |
| `price_usd` | `NUMERIC(15,2)` | Denormalizado (actualizado por cron) |
| `expenses`, `expenses_currency` | `NUMERIC`, `currency_code` | Expensas |
| `address`, `city`, `province`, `country_code`, `postal_code` | `TEXT` | |
| `neighborhood` | `TEXT` | Barrio |
| `latitude`, `longitude` | `NUMERIC(10,7)` | |
| `total_area_m2`, `covered_area_m2` | `NUMERIC(10,2)` | |
| `rooms`, `bedrooms`, `bathrooms`, `garages` | `SMALLINT` | |
| `floor_number`, `total_floors`, `year_built` | `SMALLINT` | |
| `owner_contact_id` | `UUID` | FK → contacts (propietario) |
| `assigned_agent_id` | `UUID` | FK → profiles |
| `commission_rate`, `commission_currency` | `NUMERIC`, `currency_code` | |
| `external_ids`, `portal_published` | `JSONB` | IDs y estado en portales |
| `created_at`, `updated_at`, `deleted_at` | `TIMESTAMPTZ` | |

**Índices:** org+status, org+type+operation, org+agent, org+city+province, price, geo (lat/lon), title (GIN trgm)  
**Trigger:** `fn_opportunity_stage_change` actualiza status a `'sold'` al cerrar venta  
**RLS:** Admin/Gerente: todos en org. Agente: solo asignadas. Comprador: bloqueado.

---

### `property_images` — Fotos de propiedades

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `property_id` | `UUID NOT NULL` | FK → properties CASCADE |
| `organization_id` | `UUID NOT NULL` | |
| `storage_path` | `TEXT NOT NULL` | Path en Supabase Storage |
| `url` | `TEXT NOT NULL` | URL pública o firmada |
| `alt_text` | `TEXT` | |
| `sort_order` | `SMALLINT` | default 0 |
| `is_cover` | `BOOLEAN` | default FALSE |
| `created_at` | `TIMESTAMPTZ` | |

---

### `property_features` — Amenities (pool, gym, seguridad, etc.)

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `property_id` | `UUID NOT NULL` | FK → properties CASCADE |
| `organization_id` | `UUID NOT NULL` | |
| `feature_key` | `TEXT NOT NULL` | `'pool'`, `'gym'`, `'natural_gas'` |
| `feature_value` | `TEXT` | default `'true'` o valor específico |
| UNIQUE | `(property_id, feature_key)` | |

---

### `opportunities` — Pipeline Kanban

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `contact_id` | `UUID NOT NULL` | FK → contacts |
| `property_id` | `UUID` | FK → properties (puede ser null) |
| `assigned_agent_id` | `UUID` | FK → profiles |
| `stage` | `pipeline_stage` | default `'prospecto'` |
| `stage_changed_at` | `TIMESTAMPTZ` | Actualizado por trigger |
| `offered_price`, `offered_currency` | `NUMERIC`, `currency_code` | Precio negociado |
| `expected_close_date` | `DATE` | |
| `title` | `TEXT` | "Juan García - Depto Palermo" |
| `notes`, `lost_reason` | `TEXT` | |
| `created_at`, `updated_at`, `deleted_at` | `TIMESTAMPTZ` | |

**Índices:** org+stage, org+agent, contact, property, Kanban (org+stage+stage_changed_at DESC)  
**Trigger:** `fn_opportunity_stage_change` — loguea cambios en activities, actualiza property status al cerrar  
**RLS:** Admin/Gerente: todos en org. Agente: solo asignadas.

---

### `opportunity_activities` — Notas, llamadas, visitas

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `opportunity_id` | `UUID NOT NULL` | FK → opportunities CASCADE |
| `performed_by` | `UUID` | FK → profiles |
| `activity_type` | `activity_type` | |
| `description` | `TEXT NOT NULL` | |
| `activity_date` | `TIMESTAMPTZ` | |
| `metadata` | `JSONB` | `{call_duration, whatsapp_message_id}` |
| `created_at` | `TIMESTAMPTZ` | |

---

### `sales` — Ventas cerradas

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `opportunity_id` | `UUID UNIQUE` | FK → opportunities |
| `contact_id` | `UUID NOT NULL` | FK → contacts (comprador) |
| `property_id` | `UUID NOT NULL` | FK → properties |
| `agent_id` | `UUID` | FK → profiles |
| `sale_price`, `sale_currency` | `NUMERIC(15,2)`, `currency_code` | |
| `commission_rate`, `commission_amount`, `commission_currency` | `NUMERIC` | |
| `sale_date` | `DATE NOT NULL` | |
| `escritura_date`, `possession_date` | `DATE` | Escritura / entrega de llaves |
| `has_financing` | `BOOLEAN` | default FALSE |
| `down_payment`, `down_payment_currency` | `NUMERIC`, `currency_code` | Seña/enganche |
| `financed_amount` | `NUMERIC(15,2)` | Monto a financiar en cuotas |
| `is_cancelled` | `BOOLEAN` | default FALSE |
| `cancelled_at`, `cancellation_reason` | `TIMESTAMPTZ`, `TEXT` | |
| `notes` | `TEXT` | |
| `created_at`, `updated_at` | `TIMESTAMPTZ` | |

**RLS:** Admin/Gerente: todos en org. Agente: solo sus ventas (R). Comprador: bloqueado.

---

### `amortization_schedules` — Header de tabla de amortización

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `sale_id` | `UUID NOT NULL` | FK → sales |
| `amortization_type` | `amortization_type` | default `'french'` |
| `principal` | `NUMERIC(15,2) NOT NULL` | Capital a financiar |
| `interest_rate` | `NUMERIC(8,5)` | Tasa mensual (ej: 0.03 = 3%) |
| `total_installments` | `SMALLINT NOT NULL` | Total de cuotas |
| `currency` | `currency_code NOT NULL` | |
| `start_date` | `DATE NOT NULL` | Fecha primera cuota |
| `adjustment_index` | `TEXT` | NULL, `'UVA'`, `'CER'`, `'IPC'` |
| `total_principal`, `total_interest`, `total_amount` | `NUMERIC(15,2)` | Totales denormalizados |
| `version` | `SMALLINT` | default 1 (incrementar si se renegocia) |
| `is_active` | `BOOLEAN` | Solo una activa por venta |
| `created_at`, `created_by` | `TIMESTAMPTZ`, `UUID` | |

---

### `amortization_lines` — Detalle de cuotas del plan

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `schedule_id` | `UUID NOT NULL` | FK → amortization_schedules CASCADE |
| `organization_id` | `UUID NOT NULL` | |
| `installment_number` | `SMALLINT NOT NULL` | Cuota #1, #2, ... |
| `due_date` | `DATE NOT NULL` | |
| `principal_amount` | `NUMERIC(15,2)` | Capital |
| `interest_amount` | `NUMERIC(15,2)` | Interés |
| `adjustment_amount` | `NUMERIC(15,2)` | Ajuste UVA/CER |
| `total_amount` | `NUMERIC(15,2) NOT NULL` | Total de la cuota |
| `outstanding_balance` | `NUMERIC(15,2) NOT NULL` | Saldo restante |
| `currency` | `currency_code NOT NULL` | |
| UNIQUE | `(schedule_id, installment_number)` | |

**Trigger:** `fn_create_cuota_from_amortization_line` — crea una `cuota` por cada línea insertada

---

### `cuotas` — Instancias operativas de cuotas (THE differentiator)

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `sale_id` | `UUID NOT NULL` | FK → sales |
| `amortization_line_id` | `UUID` | FK → amortization_lines |
| `contact_id` | `UUID NOT NULL` | FK → contacts (comprador — para RLS) |
| `installment_number` | `SMALLINT NOT NULL` | |
| `due_date` | `DATE NOT NULL` | |
| `amount_due` | `NUMERIC(15,2) NOT NULL` | |
| `currency` | `currency_code NOT NULL` | |
| `status` | `quota_status` | default `'pending'` |
| `amount_paid` | `NUMERIC(15,2)` | default 0 |
| `amount_outstanding` | `NUMERIC GENERATED ALWAYS AS (amount_due - amount_paid) STORED` | |
| `last_payment_date` | `DATE` | |
| `days_overdue` | `SMALLINT GENERATED ALWAYS AS (...)  STORED` | |
| `late_fee_rate` | `NUMERIC(5,4)` | Tasa de mora diaria |
| `late_fee_amount` | `NUMERIC(15,2)` | default 0 |
| `rescheduled_from_id` | `UUID` | FK → cuotas (si fue reprogramada) |
| `notes` | `TEXT` | |
| `created_at`, `updated_at` | `TIMESTAMPTZ` | |
| UNIQUE | `(sale_id, installment_number)` | |

**Índices:** org, sale, contact+status, org+status+due_date, org+due_date WHERE pending/partial  
**Trigger:** `fn_update_cuota_on_payment` — actualiza status y amount_paid al registrar pago  
**RLS:** Admin/Gerente: todos en org. Agente: cuotas de sus ventas. **Comprador: solo las propias** (`contact_id = fn_current_contact_id()`).

---

### `payments` — Pagos recibidos

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `cuota_id` | `UUID NOT NULL` | FK → cuotas |
| `sale_id` | `UUID NOT NULL` | Denormalizado |
| `contact_id` | `UUID NOT NULL` | Denormalizado (para RLS buyer) |
| `received_by` | `UUID` | FK → profiles (agente que registró) |
| `amount` | `NUMERIC(15,2) NOT NULL CHECK (> 0)` | |
| `currency` | `currency_code NOT NULL` | |
| `payment_date` | `DATE NOT NULL` | |
| `payment_method` | `payment_method` | default `'cash'` |
| `reference_number` | `TEXT` | Nro. transferencia, cheque |
| `exchange_rate` | `NUMERIC(12,6)` | Tasa de cambio |
| `amount_in_base_currency` | `NUMERIC(15,2)` | |
| `notes` | `TEXT` | |
| `created_at`, `updated_at` | `TIMESTAMPTZ` | |

**RLS:** Admin/Gerente: todos. Agente: pagos recibidos por él. **Comprador: solo sus propios.**

---

### `documents` — Metadata de PDFs (archivos en Supabase Storage)

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `document_type` | `document_type` | |
| `entity_type` | `activity_entity_type` | Polimórfico |
| `entity_id` | `UUID NOT NULL` | ID de la entidad relacionada |
| `storage_path` | `TEXT NOT NULL` | Path en Supabase Storage |
| `filename` | `TEXT NOT NULL` | |
| `file_size_bytes` | `INT` | |
| `mime_type` | `TEXT` | default `'application/pdf'` |
| `is_public` | `BOOLEAN` | default FALSE |
| `signed_url`, `signed_url_expires_at` | `TEXT`, `TIMESTAMPTZ` | URL firmada cacheada |
| `generated_by` | `UUID` | FK → profiles |
| `notes` | `TEXT` | |
| `created_at` | `TIMESTAMPTZ` | |

---

### `activities` — Audit log inmutable

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `performed_by` | `UUID` | FK → profiles |
| `activity_type` | `activity_type` | |
| `entity_type` | `activity_entity_type` | |
| `entity_id` | `UUID NOT NULL` | |
| `old_values`, `new_values` | `JSONB` | Snapshot antes/después |
| `metadata` | `JSONB` | IP, user agent, etc. |
| `description` | `TEXT` | Texto legible |
| `created_at` | `TIMESTAMPTZ` | **Sin updated_at — append-only** |

**Nota:** Candidato a particionado mensual cuando supere 1M filas.  
**RLS:** Admin/Gerente pueden leer. Agentes: bloqueados. Compradores: bloqueados.

---

### `notifications` — Alertas por canal y rol

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `recipient_profile_id` | `UUID NOT NULL` | FK → profiles CASCADE |
| `notification_type` | `notification_type` | |
| `channel` | `notification_channel` | default `'in_app'` |
| `title`, `body` | `TEXT NOT NULL` | |
| `entity_type`, `entity_id` | enum, UUID | Link contextual |
| `action_url` | `TEXT` | Deep link en la app |
| `is_read`, `read_at` | BOOLEAN, TIMESTAMPTZ | |
| `is_sent`, `sent_at`, `send_error` | BOOLEAN, TIMESTAMPTZ, TEXT | Estado de envío |
| `scheduled_for` | `TIMESTAMPTZ` | |
| `created_at` | `TIMESTAMPTZ` | |

**Índices:** recipient+is_read+created_at, pending (WHERE is_sent=FALSE)  
**RLS:** Cada usuario solo ve y modifica sus propias notificaciones.

---

### `integrations` — Configuraciones de conectores externos

| Column | Type | Notes |
|--------|------|-------|
| `id` | `UUID PK` | |
| `organization_id` | `UUID NOT NULL` | |
| `provider` | `integration_provider` | |
| `is_active` | `BOOLEAN` | default TRUE |
| `config` | `JSONB NOT NULL` | API keys, webhook secrets (Supabase Vault en prod) |
| `last_sync_at`, `last_sync_status`, `last_sync_error` | TIMESTAMPTZ, TEXT, TEXT | |
| `sync_cursor` | `JSONB` | Cursores de paginación |
| `created_at`, `updated_at` | `TIMESTAMPTZ` | |
| UNIQUE | `(organization_id, provider)` | |

**RLS:** Solo admin puede ver/modificar.

---

## Helper Functions (RLS)

```sql
fn_current_organization_id() → UUID    -- organization_id del usuario actual
fn_current_role()            → user_role
fn_current_contact_id()      → UUID    -- contact_id del comprador actual (buyer portal)
fn_is_admin_or_manager()     → BOOLEAN
```

## Triggers

| Trigger | Tabla | Función | Acción |
|---------|-------|---------|--------|
| `trg_set_updated_at` | Todas | `fn_set_updated_at` | BEFORE UPDATE |
| `trg_handle_new_auth_user` | auth.users | `fn_handle_new_auth_user` | AFTER INSERT |
| `trg_opportunity_stage_change` | opportunities | `fn_opportunity_stage_change` | BEFORE UPDATE |
| `trg_create_cuota_from_amort_line` | amortization_lines | `fn_create_cuota_from_amortization_line` | AFTER INSERT |
| `trg_update_cuota_on_payment` | payments | `fn_update_cuota_on_payment` | AFTER INSERT |

## Stored Procedures (vía cron n8n)

- `fn_mark_overdue_cuotas()` — Marca cuotas vencidas como `overdue` y crea notificaciones. Llamar diariamente.
- `fn_custom_jwt_claims(event)` — Custom Access Token Hook en Supabase Auth para inyectar `organization_id` y `role` en el JWT.

---

## Migration Files

```
supabase/migrations/
  001_enums_and_extensions.sql
  002_core_tables.sql
  003_properties.sql
  004_pipeline.sql
  005_sales_and_amortization.sql
  006_payments_and_docs.sql
  007_activities_notifications.sql
  008_triggers_and_functions.sql
  009_rls_policies.sql
  010_seed_data.sql
```
