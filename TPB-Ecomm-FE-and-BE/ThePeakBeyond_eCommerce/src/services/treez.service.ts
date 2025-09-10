import { ICartItem } from 'state/cart/cart.slice'
import { IUserState } from 'state/user'
import {
  ITreezFindUserResponse,
  ITreezCreateUserRequest,
  ITreezDocumentType,
  ITreezCreateUserResponse,
  ITreezCreateOrderRequest,
  ITreezCreateOrderResponse,
  ITreezGetOrdersResponse,
} from 'types'
import { httpPost, httpGet, httpPostFormData } from './http-client.service'

export const findUserByEmail = async (storeId: string, email: string) => {
  return (await httpPost(`/treez/findUser/${storeId}`, {
    email,
  })) as ITreezFindUserResponse
}

export const findUserInTreez = async (storeId: string, email: string, firstName?: string, lastName?: string, birthday?: string) => {
  return (await httpPost(`/treez/findUser/${storeId}`, {
    email,
    firstName,
    lastName,
    birthday,
  })) as ITreezFindUserResponse
}


export const createUser = async (
  storeId: string,
  params: ITreezCreateUserRequest
) => {
  return (await httpPost(
    `/treez/createUser/${storeId}`,
    params
  )) as ITreezCreateUserResponse
}

export const uploadDocument = async (
  storeId: string,
  type: ITreezDocumentType,
  body: FormData
) => {
  return await httpPostFormData(
    `/treez/uploadDocument/${storeId}/${type}`,
    body
  )
}

export const createOrder = async (
  storeId: string,
  body: ITreezCreateOrderRequest
) => {
  return (await httpPost(
    `/treez/createOrder/${storeId}`,
    body
  )) as ITreezCreateOrderResponse
}

export const getOrders = async (storeId: string, userState: IUserState) => {
  return (await httpPost(
    `/treez/getOrders/${storeId}/1/25`, {
        email: userState.email,
        firstName: userState.given_name,
        lastName: userState.family_name,
  }
  )) as ITreezGetOrdersResponse
}


export const compileOrderStatus = (resultReason: string, resultDetail: string, products: ICartItem[]) => {

  switch (resultReason) {
    case "INSUFFICIENT_SELLABLE_QUANTITY": {
      const messages = resultDetail.split('size_id');
      const productId = messages[1].trim().split(' ')[0];
      const product = products.find(p => p.product.sku === productId);
      return `${messages[0]}[${product?.product?.name}] ${messages[1].trim().replace(productId, "").trim()}`;
    }

    case "PRODUCT_NOT_FOUND": {
      const messages = resultDetail.split(' ');
      const productId = messages[1].trim();
      const product = products.find(p => p.product.sku === productId);
      return `${resultDetail.replace(productId, '[' + product?.product?.name + ']' || '')}`;
    }

    default:
      return resultReason;
  }
}