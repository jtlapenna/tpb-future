import Cookies from 'js-cookie'
import { IStore } from 'types';

export const getLocalStorage = (key: string) => Cookies.get(key)
export const setlocalStorage = (key: string, value: any) => {
  Cookies.remove(key);
  Cookies.set(key, JSON.stringify(value))

}

export const getBearerToken = () => Cookies.get('site-bearer-token') || ''
export const setBearerToken = (token: string) =>
  Cookies.set('site-bearer-token', token)

export const setUserInfo = (user: any) => {
  if (user) {
    const {
      'custom:birthday': birthday,
      'custom:company': company,
      'custom:purpose': purpose,
      'custom:store': store,
      ...attributes
    } = user?.attributes

    setlocalStorage('user-info', {
      id: user?.id,
      username: user?.username,
      birthday,
      company,
      purpose,
      store,
      ...attributes,
    })
  } else {
    // setlocalStorage('user-info', user)
  }
}
export const getUserInfo = () => {
  const user = getLocalStorage('user-info') || ''

  if (user && user.length) {
    return JSON.parse(user)
  }

  return null
}


export const getStoreImages = (storeId: string) => {

  const storeString = localStorage.getItem("USER_STORES");

  if (storeString) {
    const stores: IStore[] = JSON.parse(storeString);
    const storeData = stores.find(c => c.id === storeId);

    if (storeData && storeData.images && storeData.images.length) {
      return storeData.images;
    }
  }

  return [];
}