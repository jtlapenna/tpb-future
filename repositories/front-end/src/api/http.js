import axios from 'axios'

const TPB_API_URL = process.env.TPB_API_URL ? process.env.TPB_API_URL : self.kioskConfig.API.URL
const TPB_CATALOG_ID = process.env.TPB_CATALOG_ID ? process.env.TPB_CATALOG_ID : self.kioskConfig.API.CATALOG_ID
const TPB_STORE_TOKEN = process.env.TPB_STORE_TOKEN ? process.env.TPB_STORE_TOKEN : self.kioskConfig.API.TOKEN

export const HTTP = axios.create({
  baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID,
  params: {
    token: TPB_STORE_TOKEN
  }
})

export default HTTP
