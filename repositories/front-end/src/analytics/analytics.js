import Events from './events'
import EventsAPI from './EventsAPI'

export default class Analytics {
  options = null
  constructor (options) {
    let defaultOptions = {
      accountId: 0,
      token: 'dummy-key',
      source: 'dummy-source',
      uploadFrequency: 3
    }
    this.options = {
      ...defaultOptions,
      ...options
    }
    console.log('SOURCE IS:', options.source)
    localStorage.setItem('source', JSON.stringify(this.options.source))
    localStorage.setItem('app_client', window.clientInformation.platform)
    localStorage.setItem('env', window.clientInformation.userAgent)

    if (localStorage.getItem('last_upload_time') == null) {
      localStorage.setItem('last_upload_time', new Date())
    }
    if (localStorage.getItem('upload_in_progress') == null) {
      localStorage.setItem('upload_in_progress', !1)
    }
    if (localStorage.getItem('upload_error') == null) {
      localStorage.setItem('upload_error', '')
    }
    // setInterval(() => {
    //   console.log(this.uploadEvents)
    //   this.uploadEvents()
    // }, 60 * this.options.uploadFrequency * 1e3)
  }
  /**
   * Returns a objec with commn data
   * @returns object with common data for events
   */
  getCommonData () {
    return {
      source: localStorage.getItem('source'),
      env: localStorage.getItem('env'),
      app_client: localStorage.getItem('app_client'),
      app_home_layout: self.kioskConfig.HOME_LAYOUT
    }
  }

  /**
   * Sends events to api
   * @returns Promise
   */
  async uploadEvents (interval = null) {
    console.log('upload is progress', localStorage.getItem('upload_in_progress'))
    try {
      let events = await Events.index()
      const commonData = this.getCommonData()
      events = events.map(event => {
        return {
          ...event,
          ...commonData,
          account_id: this.options.accountId }
      })
      if (localStorage.getItem('upload_in_progress') === 'false' && events.length > 0) {
        localStorage.setItem('upload_in_progress', true)
        const response = await EventsAPI.uploadEvents({events}, this.options.token)
        if (response) {
          localStorage.setItem('last_upload_time', new Date())
          console.log(events)
          if (events) {
            events.forEach(event => {
              Events.delete(event)
            })
          }

          localStorage.setItem('upload_in_progress', false)
          if (interval) {
            setTimeout(() => {
              this.uploadEvents(interval)
            }, interval)
          }

          console.log('events uploaded')
        }
      } else if (localStorage.getItem('upload_in_progress') !== 'false') {
        console.log('Previus Upload still in progress')
      } else if (events.length <= 0) {
        console.log('No events to Upload')
      }
    } catch (error) {
      console.error('Error, could not upload error', error)
      localStorage.setItem('upload_in_progress', false)
      localStorage.setItem(
        'upload_error',
        JSON.stringify({
          error: error,
          datetime: new Date()
        }))
    }
  }
  /**
   * Stores events into local storage
   * @param {*} eventName
   * @param {*} eventParams
   * @param {*} eventResponse
   * @returns
   */

  track (eventName, eventParams = {}, eventResponse = {}) {
    let event = {
      event_datetime: new Date(),
      event_name: eventName,
      event_params: JSON.stringify(eventParams),
      event_resp: JSON.stringify(eventResponse),
      session_id: '',
      user_id: ''}

    return Events.save(event)
  }
}
