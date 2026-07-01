import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Public routes — skip Supabase entirely for fast response
  const publicRoutes = ['/', '/login', '/portal/login']
  if (publicRoutes.some(route => pathname === route)) {
    return NextResponse.next({ request })
  }

  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()

  // Not logged in — redirect to login
  if (!user) {
    const url = request.nextUrl.clone()
    url.pathname = '/login'
    return NextResponse.redirect(url)
  }

  // Get user role from JWT claims
  const role = user.app_metadata?.user_role as string | undefined

  // Buyer tries to access CRM routes
  if (role === 'buyer' && pathname.startsWith('/crm')) {
    const url = request.nextUrl.clone()
    url.pathname = '/portal/mis-cuotas'
    return NextResponse.redirect(url)
  }

  // CRM user tries to access buyer portal routes
  if (role && role !== 'buyer' && pathname.startsWith('/portal')) {
    const url = request.nextUrl.clone()
    url.pathname = '/crm/dashboard'
    return NextResponse.redirect(url)
  }

  return supabaseResponse
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
