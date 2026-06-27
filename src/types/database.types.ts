// Auto-generated from Supabase schema.
// Regenerate with: npx supabase gen types typescript --project-id YOUR_PROJECT_ID

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type UserRole = 'admin' | 'manager' | 'agent' | 'buyer'
export type PropertyStatus = 'available' | 'reserved' | 'sold' | 'rented' | 'inactive'
export type PropertyType = 'apartment' | 'house' | 'land' | 'commercial' | 'office' | 'warehouse' | 'ph' | 'duplex'
export type OperationType = 'sale' | 'rent' | 'temporary_rent'
export type PipelineStage = 'prospecto' | 'interesado' | 'negociando' | 'cierre' | 'vendido' | 'perdido'
export type ContactType = 'lead' | 'prospect' | 'buyer' | 'tenant' | 'owner'
export type LeadSource = 'zonaprop' | 'argenprop' | 'mercadolibre' | 'facebook_ads' | 'instagram' | 'whatsapp' | 'referral' | 'direct' | 'website' | 'other'
export type QuotaStatus = 'pending' | 'paid' | 'partial' | 'overdue' | 'forgiven' | 'rescheduled'
export type PaymentMethod = 'cash' | 'bank_transfer' | 'check' | 'credit_card' | 'debit_card' | 'crypto' | 'other'
export type CurrencyCode = 'ARS' | 'USD' | 'UYU' | 'CLP' | 'COP' | 'BRL' | 'MXN' | 'PEN'
export type AmortizationType = 'french' | 'german' | 'american' | 'fixed' | 'custom'

export interface Database {
  public: {
    Tables: {
      organizations: {
        Row: {
          id: string
          name: string
          slug: string
          legal_name: string | null
          tax_id: string | null
          country_code: string
          timezone: string
          currency: CurrencyCode
          logo_url: string | null
          primary_color: string | null
          phone: string | null
          email: string | null
          address: string | null
          website: string | null
          plan: string
          plan_expires_at: string | null
          max_users: number
          max_properties: number
          settings: Json
          created_at: string
          updated_at: string
          deleted_at: string | null
        }
        Insert: Omit<Database['public']['Tables']['organizations']['Row'], 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Database['public']['Tables']['organizations']['Insert']>
      }
      profiles: {
        Row: {
          id: string
          organization_id: string
          role: UserRole
          first_name: string
          last_name: string
          email: string
          phone: string | null
          avatar_url: string | null
          commission_rate: number | null
          is_active: boolean
          last_sign_in_at: string | null
          contact_id: string | null
          created_at: string
          updated_at: string
        }
        Insert: Omit<Database['public']['Tables']['profiles']['Row'], 'created_at' | 'updated_at'>
        Update: Partial<Database['public']['Tables']['profiles']['Insert']>
      }
      contacts: {
        Row: {
          id: string
          organization_id: string
          first_name: string
          last_name: string
          email: string | null
          phone: string | null
          phone_alt: string | null
          national_id: string | null
          national_id_type: string | null
          contact_type: ContactType
          lead_source: LeadSource | null
          assigned_agent_id: string | null
          address: string | null
          city: string | null
          province: string | null
          country_code: string | null
          tags: string[]
          notes: string | null
          external_ids: Json
          gdpr_consent: boolean
          gdpr_consent_at: string | null
          created_at: string
          updated_at: string
          deleted_at: string | null
        }
        Insert: Omit<Database['public']['Tables']['contacts']['Row'], 'id' | 'created_at' | 'updated_at'>
        Update: Partial<Database['public']['Tables']['contacts']['Insert']>
      }
      cuotas: {
        Row: {
          id: string
          organization_id: string
          sale_id: string
          amortization_line_id: string | null
          contact_id: string
          installment_number: number
          due_date: string
          amount_due: number
          currency: CurrencyCode
          status: QuotaStatus
          amount_paid: number
          amount_outstanding: number
          last_payment_date: string | null
          days_overdue: number
          late_fee_rate: number | null
          late_fee_amount: number
          rescheduled_from_id: string | null
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: never
        Update: never
      }
    }
    Views: Record<string, never>
    Functions: {
      fn_current_organization_id: { Returns: string }
      fn_current_role: { Returns: UserRole }
      fn_current_contact_id: { Returns: string }
      fn_is_admin_or_manager: { Returns: boolean }
      fn_mark_overdue_cuotas: { Returns: number }
    }
    Enums: {
      user_role: UserRole
      property_status: PropertyStatus
      property_type: PropertyType
      operation_type: OperationType
      pipeline_stage: PipelineStage
      contact_type: ContactType
      lead_source: LeadSource
      quota_status: QuotaStatus
      payment_method: PaymentMethod
      currency_code: CurrencyCode
      amortization_type: AmortizationType
    }
  }
}
