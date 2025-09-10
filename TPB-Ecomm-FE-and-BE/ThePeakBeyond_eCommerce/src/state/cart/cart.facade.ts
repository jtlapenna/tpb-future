import { useCallback } from 'react'
import { useAppDispatch, useAppSelector } from 'state'
import * as CartSlice from './cart.slice'

export const useCartFacade = () => {
  const dispatch = useAppDispatch()

  const cartState = useAppSelector((state) => state.cartState)
  const totalPrice = useAppSelector((state) => state.cartState.totalPrice)

  
  const addCart = useCallback(
    (payload) => dispatch(CartSlice.actions.addCart(payload)),
    [dispatch]
  )

  const removeCart = useCallback(
    (payload) => dispatch(CartSlice.actions.removeCart(payload)),
    [dispatch]
  )

  const resetCart = useCallback(
    (payload) => dispatch(CartSlice.actions.resetCart(payload)),
    [dispatch]
  )

  const setCart = useCallback(
    (payload) => dispatch(CartSlice.actions.setCart(payload)),
    [dispatch]
  )

  return {
    cartState,
    totalPrice,
    addCart,
    removeCart,
    resetCart,
    setCart,
  }
}
