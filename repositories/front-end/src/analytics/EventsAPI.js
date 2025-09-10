import Axios from 'axios'

const API_URL = self.kioskConfig.ANALYTICS_API_URL

export class EventsAPI {
  baseurl = API_URL

  uploadEvents (data, token) {
    console.log('sending request')
    return Axios.post(this.baseurl, data, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': `Bearer ${token}`
      }
    })
  }
}

export default new EventsAPI()
