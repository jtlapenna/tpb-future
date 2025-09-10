/* eslint-disable no-eval */
/* eslint-disable no-sequences */
/* eslint-disable eqeqeq */
/* eslint-disable camelcase */
/* eslint-disable no-undef */
/* eslint-disable no-unused-expressions */
/* eslint-disable one-var */
export function GsClient (options) {
  let defaultOptions = {
    accountId: 0,
    licenceKey: 'dummy-key',
    source: 'dummy-source',
    uploadFrequency: 3
  }
  options = {
    ...defaultOptions,
    ...options
  }
  var serverUrl = 'http://18.219.239.103:8000',
    refreshToken,
    accessToken,
    accountDetail,

    retry = !0,
    db
  const DB_NAME = 'event_collector',
    DB_VERSION = 1,
    DB_STORE_NAME = 'events'
  var openDb = function () {
      console.log('openDb ...')
      var e = indexedDB.open(DB_NAME, DB_VERSION);
      (e.onsuccess = function (e) {
        (db = this.result), console.log('openDb DONE')
      }),
      (e.onerror = function (e) {
        console.error('openDb:', e.target.errorCode)
      }),
      (e.onupgradeneeded = function (e) {
        console.log('openDb.onupgradeneeded')
        e.currentTarget.result.createObjectStore(DB_STORE_NAME, {
          keyPath: 'id',
          autoIncrement: !0
        })
      })
    },
    getObjectStore = function (e, t) {
      return db.transaction(e, t).objectStore(e)
    },
    deleteData = function (e) {
      var t = getObjectStore(DB_STORE_NAME, 'readwrite')
      e.forEach(e => t.delete(e))
    },
    getToken = async function (e, t, o) {
      try {
        var r = {
          account_id: e,
          licence_key: t
        }
        r.source = JSON.stringify(o)
        var a = await fetch(serverUrl + '/api/v1/token/', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(r)
        }).then(e => e.json())
        return (
          !!a.result &&
          ((accessToken = a.access_token),
          (refreshToken = a.refresh),
          setTimeout(getToken, a.refresh_lifetime, e, t, o),
          !0)
        )
      } catch (r) {
        retry && setTimeout(getToken, 4e3, e, t, o), (retry = !1)
      }
    };
  (this.setIdentity = function (e, t, o) {
    var r = getToken(e, t, o);
    ((accountDetail = e), (licenceKeyDetail = t), (sourceDetail = o), r)
      ? (localStorage.setItem('source', JSON.stringify(o)),
      localStorage.setItem('app_client', window.clientInformation.platform),
      localStorage.setItem('env', window.clientInformation.userAgent),
      localStorage.getItem('last_upload_time') == null &&
          localStorage.setItem('last_upload_time', new Date()),
      localStorage.getItem('upload_in_progress') == null &&
          localStorage.setItem('upload_in_progress', !1),
      localStorage.getItem('upload_error') == null &&
          localStorage.setItem('upload_error', ''))
      : console.log('invalid secret_key')
  }),
  (this.track = function (e, t, o, r, a) {
    (t = t || {}),
    (o = o || {}),
    (r = r || ''),
    (a = a || ''),
    (t = JSON.stringify(t)),
    (o = JSON.stringify(o)),
    (data = {
      session_id: a,
      user_id: r,
      event_datetime: new Date(),
      event_name: e,
      event_params: t,
      event_resp: o
    }),
    console.log(data),
    setDataIntoLocalStorage(data)
  })
  var setDataIntoLocalStorage = function (e) {
      var t,
        o = getObjectStore(DB_STORE_NAME, 'readwrite')
      try {
        t = o.add(e)
      } catch (e) {
        console.log(e)
      }
      (t.onsuccess = function (e) {
        console.log('Insertion in DB successful')
      }),
      (t.onerror = function () {
        console.error('error occurred', this.error)
      })
    },
    getGsLocalData = function () {
      return new Promise(function (resolve, reject) {
        var o = [],
          r = [],
          a = getObjectStore(DB_STORE_NAME, 'readwrite');
        (request = a.openCursor()),
        (request.onerror = function (e) {
          t(Error('Network Error'))
        }),
        (request.onsuccess = function (t) {
          let a = t.target.result
          if (a) {
            // eslint-disable-next-line no-sequences
            a.primaryKey, a.value
            o.push(a.value), r.push(a.primaryKey), a.continue()
          } else {
            e({
              gsKey: r,
              gsValues: o
            })
          }
        })
      })
    },
    prepareUpload = function () {
      try {
        getGsLocalData().then(function (e) {
          e.gsValues.length > 0 && uploadEvents(e)
        })
      } catch (e) {
        console.error(e)
      }
    },
    uploadEvents = async function (storedData) {
      if (
        (console.log('upload events'),
        (checkStatus = eval(localStorage.getItem('upload_in_progress'))),
        !checkStatus &&
          ((unique_data = getCommonData()), storedData.gsValues.length > 0))
      ) {
        localStorage.setItem('upload_in_progress', !0)
        try {
          for (i = 0; i < storedData.gsValues.length; i++) {
            (storedData.gsValues[i] = {
              ...storedData.gsValues[i],
              ...unique_data
            }),
            (storedData.gsValues[i].account_id = accountDetail)
          }
          (body_data = {
            events: storedData.gsValues
          }),
          (storeResponse = await fetch(serverUrl + '/api/v1/upload-events/', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: 'Bearer ' + accessToken
            },
            body: JSON.stringify(body_data)
          }).then(e => e.json())),
          storeResponse.result
            ? (localStorage.setItem('last_upload_time', new Date()),
            deleteData(storedData.gsKey))
            : storeResponse.code == 'token_not_valid'
              ? (console.log('Access token expired. Get new one.'),
              refreshAccessToken())
              : localStorage.setItem(
                'upload_error',
                JSON.stringify({
                  error: storeResponse,
                  datetime: new Date()
                })
              )
        } catch (e) {
          console.error(e)
        }
        localStorage.setItem('upload_in_progress', !1)
      }
    },
    refreshAccessToken = async function () {
      try {
        var e = await fetch(serverUrl + '/api/v1/token/refresh/', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            refresh: refreshToken
          })
        }).then(e => e.json())
        e.access
          ? ((accessToken = e.access), setTimeout(uploadEvents, 2e4))
          : (localStorage.setItem(
            'upload_error',
            JSON.stringify({
              error: e,
              datetime: new Date()
            })
          ),
          getToken(options.accountId, options.licenceKey, options.source))
      } catch (e) {
        console.error(e),
        localStorage.setItem(
          'upload_error',
          JSON.stringify({
            error: e,
            datetime: new Date()
          })
        )
      }
    },
    getCommonData = function () {
      return (
        (data = {}),
        ['source', 'env', 'app_client'].forEach(e => {
          data[e] = localStorage.getItem(e)
        }),
        data
      )
    },
    resetUploadInProgressFlag = function (uploadFrequency) {
      console.log('resetUploadInProgressFlag')
      var status = eval(localStorage.getItem('upload_in_progress'))
      if (status) {
        var last_time = localStorage.getItem('last_upload_time');
        (last_time != 'null' && last_time != '') ||
          localStorage.setItem('upload_in_progress', !1)
        var timeDiff = new Date() - new Date(last_time),
          diffInMinutes = Math.round(((timeDiff % 864e5) % 36e5) / 6e4)
        diffInMinutes >= 3 * uploadFrequency + 1 &&
          localStorage.setItem('upload_in_progress', !1)
      }
    }
  openDb(),
  (this.uploadFrequency = options.uploadFrequency),
  setInterval(prepareUpload, 60 * this.uploadFrequency * 1e3),
  this.setIdentity(options.accountId, options.licenceKey, options.source),
  setInterval(resetUploadInProgressFlag, 36e5, this.uploadFrequency)
}
