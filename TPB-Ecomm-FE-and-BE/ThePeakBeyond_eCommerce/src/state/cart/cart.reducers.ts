import { AnyAction, PayloadAction } from '@reduxjs/toolkit'
import { toast } from 'react-toastify'

import { ICartItem, ICartState, initialState } from './cart.slice'
import { calculateTotalPrice } from './cart.utils'
import { setlocalStorage } from 'utils/local-storage.utility'

// Reducers
export const reducers = {
  addCart(
    state: ICartState,
    action: PayloadAction<ICartItem & { storeId: string }>
  ) {
    if (state && state[action.payload.storeId]) {
      const itemExist = state[action.payload.storeId].items.findIndex(
        (item) => item.product.id === action.payload.product.id
      )
      if (itemExist >= 0) {
        state[action.payload.storeId].items[itemExist].count +=
          action.payload.count
      } else {
        state[action.payload.storeId].items.push({
          count: action.payload.count,
          product: action.payload.product,
        })
      }
      state[action.payload.storeId].totalPrice = calculateTotalPrice(
        state[action.payload.storeId].items
      )

      setlocalStorage('cartStore', state)

      if (itemExist >= 0) {
        toast.success('Cart updated')
      } else {
        toast.success('Product added to cart')
      }

      return state
    } else {
      const newState = {
        ...state,
        [action.payload.storeId]: {
          items: [action.payload],
          totalPrice: calculateTotalPrice([action.payload]),
        },
      }

      setlocalStorage('cartStore', newState)
      toast.success('Product added to cart')
      return newState
    }
  },

  removeCart(
    state: ICartState,
    action: PayloadAction<ICartItem & { storeId: string }>
  ) {
    console.log('removeCart', action.payload)
    state[action.payload.storeId].items = state[
      action.payload.storeId
    ].items.filter((item) => item.product.id !== action.payload.product.id)
    state[action.payload.storeId].totalPrice = calculateTotalPrice(
      state[action.payload.storeId].items
    )

    setlocalStorage('cartStore', state)

    return state
  },

  resetCart(state: ICartState, action: PayloadAction<string>) {
    const newState = {
      ...state,
      [action.payload]: {
        items: [],
        totalPrice: 0,
      },
    }
    setlocalStorage('cartStore', newState)

    return newState
  },

  setCart(state: ICartState, action: PayloadAction<ICartState>) {
    state = action.payload

    setlocalStorage('cartStore', state)

    return state
  },
}

export const extraReducers = {}
