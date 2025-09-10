import { createSlice, Reducer } from '@reduxjs/toolkit'

import { reducers, extraReducers } from './cart.reducers'
import { IProduct } from 'types'
import { getLocalStorage } from 'utils/local-storage.utility'

export interface ICartItem {
  product: IProduct
  count: number
}

export interface ICartState {
  [storeId: string]: {
    items: ICartItem[]
    totalPrice: number
  }
}

export const initialState: ICartState = getLocalStorage('cartStore')
  ? JSON.parse(getLocalStorage('cartStore')!)
  : {}

const cartSlice = createSlice({
  name: 'cart',
  initialState,
  reducers,
  extraReducers: (builder) => {},
})

// Action Creators

export const actions = {
  addCart: cartSlice.actions.addCart,
  removeCart: cartSlice.actions.removeCart,
  resetCart: cartSlice.actions.resetCart,
  setCart: cartSlice.actions.setCart,
}

export default cartSlice.reducer as Reducer<ICartState>
