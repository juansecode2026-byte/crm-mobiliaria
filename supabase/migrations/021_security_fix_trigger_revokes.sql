-- ============================================================
-- MIGRATION 021: Security Fix — REVOKE en funciones trigger
--
-- En migración 019 se hizo REVOKE en las getter functions
-- (fn_current_organization_id, fn_current_role, etc.) pero
-- las funciones RETURNS TRIGGER quedaron con EXECUTE público.
--
-- Técnica: PostgreSQL verifica EXECUTE del dueño del trigger
-- (postgres/supabase_admin) al dispararlo, NO del session user.
-- Revocar de authenticated NO rompe los triggers.
-- Solo el dueño de la función (implicit) sigue teniendo acceso.
-- ============================================================

-- fn_set_updated_at — trigger genérico updated_at
REVOKE ALL ON FUNCTION public.fn_set_updated_at() FROM PUBLIC;

-- fn_handle_new_auth_user — trigger en auth.users (auth system only)
REVOKE ALL ON FUNCTION public.fn_handle_new_auth_user() FROM PUBLIC;

-- fn_operation_stage_change — trigger en operations UPDATE
REVOKE ALL ON FUNCTION public.fn_operation_stage_change() FROM PUBLIC;

-- fn_log_payment — trigger en payments INSERT
REVOKE ALL ON FUNCTION public.fn_log_payment() FROM PUBLIC;
