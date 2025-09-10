import { IUserAddress } from 'types'

export interface ITreezUser {
  status: 'ACTIVE' | 'PENDING'
  verification_status: 'VERIFIED' | 'VERIFICATION_PENDING'
  verification_reasons: [
    {
      verification_reason: 'NEW' | 'OLD'
      verification_reason_description:
        | 'NEW_INTAKE_CUSTOMER'
        | 'OLD_INTAKE_CUSTOMER'
    }
  ]
  customer_id: string
  first_name: string
  middle_name: string
  nickname: string
  last_name: string
  birthday: string
  drivers_license: string
  drivers_license_expiration: string
  state_medical_id: string
  permit_expiration: string
  email: string
  phone: string
  notes: string
  physician_first_name: string
  physician_last_name: string
  physician_license: string
  physician_address: string
  physician_phone: string
  is_caregiver: boolean
  caregiver_license_number: string
  caregiver_name_1: string
  caregiver_name_2: string
  caregiver_details: []
  rewards_balance: number
  rewards_type: string
  gender: string
  signup_date: Date
  last_visit_date: Date
  last_update: Date
  opt_out: string
  referral_source: string
  banned: boolean
  warning_1: boolean
  warning_2: boolean
  addresses: []
  merged_customer_ids: []
  merged_into_customer_id: string
  patient_type: 'ADULT' | 'CHILD'
  customer_groups: []
}

export type ITreezFindUserResponse = {
  resultCode: 'SUCCESS' | 'FAILED'
  resultReason: string
  resultDetail: string
  data: ITreezUser[]
}

export type ITreezCreateUserRequest = Partial<ITreezUser>

export type ITreezCreateUserResponse = {
  resultCode: 'SUCCESS' | 'FAILED'
  resultReason: string
  resultDetail: string
  data: ITreezUser
}

export type ITreezUploadDocumentRequest = {
  drivers_license: string
  drivers_license_expiration: string
}

export type ITreezDocumentType = 'MEMBERSHIP_AGREEMENT' | 'DRIVERS_LICENSE'

export type ITreezCreateOrderItem = {
  size_id: string
  quantity: string
}

export type ITreezOrderType = 'POS' | 'DELIVERY' | 'PICKUP' | 'EXPRESS'

export type ITreezCreateOrderRequest = {
  type: ITreezOrderType
  customer_id: string
  ticket_note?: string
  delivery_address?: IUserAddress
  external_order_number?: string
  items: ITreezCreateOrderItem[]
  order_status?: string
}

export type ITreezCreateOrderResponse = {
  resultCode: 'SUCCESS' | 'FAILED'
  resultReason: string
  resultDetail: string
  data: any
}

export type ITreezOrder = {
  type: ITreezOrderType
  ticket_id: string
  order_number: string
  external_order_number: string
  order_source: 'KIOSK' | 'ECOMMERCE' | 'IN_STORE' | 'VENDING_MACHINE'
  created_by_employee: {
    employee_id: string
    name: string
    role: string
  }
  customer_id: string
  ticket_patient_type: 'ADULT'
  cash_register_id: string
  order_status:
    | 'COMPLETED'
    | 'VERIFICATION_PENDING'
    | 'AWAITING_PROCESSING'
    | 'IN_PROCESS'
    | 'PACKED_READY'
    | 'OUT_FOR_DELIVERY'
    | 'CANCELED'
  payment_status: 'PAID' | 'UNPAID' | 'REFUNDED'
  date_created: Date
  last_updated_at: Date
  date_closed: Date
  post_tax_pricing: boolean
  sub_total: number
  tax_total: number
  discount_total: number
  total: number
  ticket_note: string
  refund_reason: string
  original_ticket_id: string
  delivery_address: {
    id: number
    street: string
    street2: string
    city: string
    county: string
    state: string
    zip: string
  }
  scheduled_date: string
  items: any[]
  reward_eligible: boolean
  reward_points_earned: number
  reward_points_used: number
  purchase_limit: string
  employee_id: string
  cash_drawer_name: string
  delivery_route: any
  payment_authorization: boolean
}

export type ITreezGetOrdersResponse = {
  resultCode: 'SUCCESS' | 'FAILED'
  resultReason: string
  resultDetail: string
  ticketList: ITreezOrder[]
}
