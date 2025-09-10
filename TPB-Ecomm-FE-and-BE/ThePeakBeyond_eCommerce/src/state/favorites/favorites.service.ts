import { httpGet, httpPost } from '../../services/http-client.service'

export const loadFavorites = async (storeId: string) => {
  return await httpGet(`/favorite/all/${storeId}/id/1/100`)
}

export const addFavorite = async (params) => {
  return await httpPost('/favorite/add', {
    storeId: +params.storeId,
    productId: +params.product.id,
  })
}



export const removeFavorite = async (productId: string) => {
  return await httpPost(`/favorite/delete/${productId}`, {}, 'DELETE')
}
