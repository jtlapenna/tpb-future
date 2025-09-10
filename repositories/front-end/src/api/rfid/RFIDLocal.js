import { LocalRepo } from '../LocalRepo'

export class RFIDLocal extends LocalRepo {
  constructor () {
    super('rfids', 'id')
  }
}
