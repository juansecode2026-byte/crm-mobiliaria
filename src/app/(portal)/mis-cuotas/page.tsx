import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export default async function MisCuotasPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/portal/login')

  const role = user.app_metadata?.user_role
  if (role !== 'buyer') redirect('/crm/dashboard')

  return (
    <div className="min-h-screen bg-amber-50 flex items-center justify-center">
      <div className="text-center">
        <div className="w-16 h-16 bg-amber-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
          <span className="text-2xl">🏠</span>
        </div>
        <div className="inline-flex items-center gap-1.5 bg-amber-100 text-amber-800 text-xs font-semibold px-3 py-1 rounded-full mb-4">
          Portal del Comprador
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Mis cuotas</h1>
        <p className="text-gray-500 mb-6">{user.email}</p>
        <p className="text-sm text-gray-400">Módulo de cuotas en construcción — Etapa 4 →</p>
      </div>
    </div>
  )
}
