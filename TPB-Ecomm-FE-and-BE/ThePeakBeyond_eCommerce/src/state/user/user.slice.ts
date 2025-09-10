import { createSlice, Reducer } from '@reduxjs/toolkit'

import { reducers, extraReducers } from './user.reducers'
import { IUserAddress } from 'types'

export interface IUserState {
  birthday?: Date
  company: string
  email?: string
  email_verified?: boolean
  family_name?: string
  given_name?: string
  phone_number?: string
  phone_number_verified?: boolean
  purpose?: string
  store: string
  sub?: string
  address?: IUserAddress
}

export const initialState: IUserState = {
  company: '',
  store: '',
}

const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers,
  extraReducers: (builder) => {},
})

// Action Creators

export const actions = {
  updateUserState: userSlice.actions.updateUserState,
}

export default userSlice.reducer as Reducer<IUserState>
