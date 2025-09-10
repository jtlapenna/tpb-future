import { getBearerToken } from '../utils/local-storage.utility'
import { logout } from './authentication.service'

const header = {
  Accept: 'application/json',
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': '*',
}

const baseUrl = process.env.REACT_APP_EXTERNAL_API_URL

export const httpPost = async (url: string, body: any, httpMethod = 'POST') => {
  try {
    const post = await fetch(`${baseUrl}${url}`, {
      method: httpMethod,
      headers: {
        ...header,
        Authorization: `Bearer ${getBearerToken()}`,
      },
      body: JSON.stringify(body),
    })

    if (+post.status === 401) {
      logout()
      document.location.href = '/login'
      return null
    }

    if (post.ok) {
      return post.json()
    } else {
      throw new Error('Something went wrong')
    }
  } catch (err) {
    console.log('err - ', err)
    return Promise.reject(err)
  }
}

export const httpPostFormData = async (
  url: string,
  body: any,
  httpMethod = 'POST'
) => {
  try {
    const post = await fetch(`${baseUrl}${url}`, {
      method: httpMethod,
      headers: {
        Authorization: `Bearer ${getBearerToken()}`,
      },
      body,
    })

    if (+post.status === 401) {
      logout()
      document.location.href = '/login'
      return null
    }

    if (post.ok) {
      return post.json()
    } else {
      throw new Error('Something went wrong')
    }
  } catch (err) {
    console.log('err - ', err)
  }
}

export const httpGet = async (url: string) => {
  try {
    const get = await fetch(`${baseUrl}${url}`, {
      method: 'GET',
      headers: {
        ...header,
        Authorization: `Bearer ${getBearerToken()}`,
      },
    })

    if (get.ok) {
      return get.json()
    } else {
      throw new Error('Something went wrong')
    }
  } catch (err) {
    console.log('err - ', err)
  }
}
