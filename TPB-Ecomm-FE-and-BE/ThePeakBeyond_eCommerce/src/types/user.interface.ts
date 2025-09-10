export interface IUserAddress {
  street: string
  city?: string
  state?: string
  zip?: string
  country?: string
}

export interface IUser {
  id: string
  username: string
  sub: string
  store: string
  birthday: string
  company: string
  purpose: string
  email: string
  email_verified: boolean
  family_name: string
  given_name: string
  phone_number: string
  phone_number_verified: boolean
  address?: IUserAddress
}
