import HTTP from '../http'

export class RFIDRemote {
  index () {
    return HTTP.get('rfids')
  }
}
