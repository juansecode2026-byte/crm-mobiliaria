import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) redirect('/login')

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="text-center">
        <div className="w-16 h-16 bg-blue-700 rounded-2xl flex items-center justify-center mx-auto mb-4">
          <span className="text-white font-bold text-2xl">CR</span>
        </div>
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Dashboard CRM</h1>
        <p className="text-gray-500 mb-6">Bienvenido, {user.email}</p>
        <p className="text-sm text-gray-400">Módulos en construcción — Etapa 2 →</p>
      </div>
    </div>
  )
}
