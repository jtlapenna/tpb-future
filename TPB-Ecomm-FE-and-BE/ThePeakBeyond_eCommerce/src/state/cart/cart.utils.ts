import { ICartItem } from './cart.slice'

export const calculateTotalPrice = (items: ICartItem[]) => {
  const totalPrice = items.reduce(
    (totalPrice, item, index) =>
      (totalPrice += +item.product.min_price * item.count),
    0
  )
  return totalPrice
}
