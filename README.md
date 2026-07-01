# CRM Mobiliaria

CRM B2B SaaS para agencias inmobiliarias de Latinoamérica.

## Stack

| Capa | Tecnología |
|------|-----------|
| Frontend | Next.js 14 + TypeScript + Tailwind CSS + shadcn/ui |
| Base de datos | Supabase (PostgreSQL) con RLS |
| Hosting | Vercel |
| Automatización | n8n (interno) + Zapier (externo) |
| Documentos | React-PDF / Puppeteer |
| Real-time | Supabase Realtime |

## Roles de usuario

- **Admin** — Superadmin de la organización
- **Gerente** — Visibilidad total de la empresa
- **Agente** — Solo sus contactos y propiedades asignadas
- **Comprador** — Portal propio: solo sus cuotas y pagos

## Estructura del proyecto

```
supabase/migrations/    → Schema PostgreSQL + RLS policies
src/app/                → Next.js App Router
  (auth)/login/         → Login CRM interno
  (auth)/portal/        → Login portal compradores
  (crm)/                → Módulos de agentes/gerentes/admin
  (portal)/             → Portal del comprador
src/components/ui/      → shadcn/ui components
src/lib/supabase/       → Supabase client (browser + server)
DATABASE_SCHEMA.md      → Documentación completa del schema
Documentación/          → Planificación del proyecto (Fases 1-3)
```

## Setup local

```bash
# 1. Instalar dependencias
npm install

# 2. Copiar variables de entorno
cp .env.example .env.local
# Completar con tus credenciales de Supabase

# 3. Inicializar Supabase local (opcional)
npx supabase start

# 4. Ejecutar migraciones
npx supabase db push

# 5. Iniciar servidor de desarrollo
npm run dev
```

## Variables de entorno requeridas

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
# Solo en server/Edge Functions — NUNCA en el frontend:
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## Base de datos

Ver [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) para el schema completo con todas las tablas, enums, índices, triggers y políticas RLS.

Las migraciones se ejecutan en orden: `supabase/migrations/001_*.sql` → `010_*.sql`.

## Seguridad

- Row Level Security (RLS) habilitado en todas las tablas
- Seguridad en la base de datos, no solo en el backend (a diferencia de Tokko Broker)
- JWT con `organization_id` y `role` via Custom Access Token Hook
- `service_role` key NUNCA en el frontend — solo en variables de entorno del servidor
