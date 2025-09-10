/* eslint-disable no-undef */
import Vue from 'vue'
import axios from 'axios'
import io from 'socket.io-client'
import Vue2TouchEvents from 'vue2-touch-events'
import VueFilter from 'vue-filter'
import vuexStore from './store/store.js'
// Use jQuery for easier DOM manipulation and animations

import $ from 'jquery'
import VueGlobalVariable from 'vue-global-var'
import App from './App'
import router from './router'
import Analytics from './analytics/analytics'
import * as Sentry from '@sentry/vue'
// import {SETTINGS_TIME} from './const/globals'
import configPlugin, { getConfigFromData } from './plugins/config'
import { mapMutations } from 'vuex'
import cart from './store/modules/cart'
var retries = 0
// var loadConfigEvent = new CustomEvent('load-config-data', {config: null})

// Set jQuery globally for fancybox
window.jQuery = $

console.log(process.env)
console.log(
  process.env.TPB_API_URL,
  process.env.TPB_CATALOG_ID,
  process.env.TPB_STORE_TOKEN
)
console.log(
  self.kioskConfig.API.URL,
  self.kioskConfig.API.CATALOG_ID,
  self.kioskConfig.API.TOKEN
)

const ENVIRONMENT = process.env.SENTRY_ENVIRONMENT
  ? process.env.SENTRY_ENVIRONMENT
  : self.kioskConfig.SENTRY_ENVIRONMENT
const TPB_API_URL = process.env.TPB_API_URL
  ? process.env.TPB_API_URL
  : self.kioskConfig.API.URL
const TPB_CATALOG_ID = process.env.TPB_CATALOG_ID
  ? process.env.TPB_CATALOG_ID
  : self.kioskConfig.API.CATALOG_ID
const TPB_STORE_TOKEN = process.env.TPB_STORE_TOKEN
  ? process.env.TPB_STORE_TOKEN
  : self.kioskConfig.API.TOKEN
const SENTRY_DSN = process.env.SENTRY_DSN
  ? process.env.SENTRY_DSN
  : self.kioskConfig.SENTRY_DSN

Sentry.init({
  Vue: Vue,
  dsn: SENTRY_DSN,
  environment: ENVIRONMENT
})

const PRINTER_API_URL = self.kioskConfig.PRINTER_API_URL

console.log(TPB_API_URL, TPB_CATALOG_ID, TPB_STORE_TOKEN)

require('@fancyapps/fancybox')
require('../static/js/jquery.onScreenKeyboard.js')
require('../static/js/jquery.onScreenKeynumber.js')

Vue.config.productionTip = false

// Set axios base config
Vue.http = Vue.prototype.$http = axios.create({
  baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID,
  params: {
    token: TPB_STORE_TOKEN
  }
})

// Set axios base config without token
Vue.httpEmpty = Vue.prototype.$httpEmpty = axios.create({
  baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID
})

// Set axios base config without token
Vue.httpEmpty = Vue.prototype.$httpEmpty = axios.create({
  baseURL: TPB_API_URL + '/' + TPB_CATALOG_ID
})

Vue.httpPrinter = Vue.prototype.$httpPrinter = axios.create({
  baseURL: PRINTER_API_URL
})

// Auto restart logic
var appRestartTimer = 10
window.appRestartInterval = setInterval(appRestart, 1000)

function appRestart() {
  if (appRestartTimer <= 0) {
    console.log("App didn't start, auto restart")
    location.reload(true)

    clearInterval(window.appRestartInterval)
  } else {
    let restartTimer = document.getElementById('restart-timer')
    if (restartTimer) {
      restartTimer.innerHTML =
        'The app will restart automatically in ' + appRestartTimer + 's.'
      appRestartTimer--
    }
  }
}

// Get store information before mounting the app
if (window.isSecureContext) {
  console.log('Secure context, use cache config')
  document.getElementById('output').innerHTML =
    'Secure context, use cache config'
  useCacheConfig()
  // window.settingInterval = setInterval(() => {
  //   console.log('timeout executing')
  //   window.reload() // useOnlineConfig(true)
  // }, SETTINGS_TIME)
} else {
  console.log('Not secure context, use online config')
  document.getElementById('output').innerHTML =
    'Not secure context, use online config'
  useOnlineConfig()
  // Each WAIT_TIME call again useOnlineConfig to update UI
  // window.settingInterval = setInterval(() => {
  //   console.log('timeout executing')
  //   window.reload()
  // }, SETTINGS_TIME)
}

/**
 * Use cache config
//  */
function useCacheConfig() {
  caches.open('kiosk-api-cache').then(function(cache) {
    var configURL =
      TPB_API_URL + '/' + TPB_CATALOG_ID + '/settings?token=' + TPB_STORE_TOKEN

    cache.match(configURL).then(function(response) {
      if (response !== undefined) {
        response.json().then(function(data) {
          console.log('Init app with cache config.')
          document.getElementById('output').innerHTML =
            'Init app with cache config.'

          // Init APP with cache config
          initApp(data)
        })
      } else {
        console.log('No config in cache, use online config.')
        useOnlineConfig()
      }
    })
  })
}

/**
 * Use online config
 * @param disableMessages by default this parameter disabled messages in the ui of the app
 */
function useOnlineConfig(disableMessages = false) {
  console.log('use online config trigger')
  // Try fetching the config online
  if (!disableMessages) {
    document.getElementById('output').innerHTML = 'Fetching online config.'
  }

  Vue.http.get('settings' + '?date=' + Date.now()).then(
    function(response) {
      if (!disableMessages) {
        document.getElementById('output').innerHTML =
          'Init app with online config.'
      }

      // let previusConfig = localStorage.getItem('config_data')
      // let isConfigTheSameAsBefore = _.isEqual(response.data, JSON.parse(previusConfig))
      // console.log('Is config the same as before?', isConfigTheSameAsBefore)
      // Init APP with remote config

      initApp(response.data)

      // if (!disableMessages) {
      //   initApp(response.data)
      // } else if (disableMessages && isConfigTheSameAsBefore) {
      //   console.log('use online config FROM SERVER')
      //   initApp(response.data, true)
      // }

      localStorage.setItem('config_data', JSON.stringify(response.data))
    },
    function(error) {
      console.log(error)
      // if and error happend check local config
      if (localStorage.getItem('config_data')) {
        // fetch local config and init app
        const cachedConfig = JSON.parse(localStorage.getItem('config_data'))
        initApp(cachedConfig)
      } else {
        // if no local config show error
        console.log(
          'Error while retreiving config from the API, waiting for the app to restart.',
          error.request
        )
        if (!disableMessages) {
          document.getElementById('output').innerHTML =
            'Error while retreiving config from the API, waiting for the app to restart.'
        }
      }
    }
  )
}

/**
 * Initiate app with store config
 * @param  {json} store API response
 */
function initApp(data, triggerReload = false) {
  var mergedConfig = self.kioskConfig
  if (data !== false) {
    var store = data.store
    var catalog = data.catalog
    var paymentGateway = data.payment_gateway
    var config = null
    if (catalog.ad_configs) {
      config = defineAdConfig(catalog.ad_configs)
    }
    // Map remote config
    localStorage.setItem('config_data', JSON.stringify(data))
    console.log(store)
    var remoteConfig = getConfigFromData({
      store,
      catalog,
      config,
      paymentGateway
    })

    console.log('config', JSON.stringify(remoteConfig))

    // Map navigation
    if (
      store.layout.navigation &&
      store.layout.navigation.items &&
      store.layout.navigation.items.length > 0
    ) {
      var nav = []

      store.layout.navigation.items.forEach(function(item) {
        var element = {
          label: item.label,
          path: item.link,
          order: item.order,
          title: item.title,
          description: item.description,
          image: false
        }

        if (item.asset) {
          element.image = item.asset.url
        }

        nav.push(element)
      })

      remoteConfig.NAV = nav
    } else {
      // Default nav
      remoteConfig.NAV = [
        { label: 'Products', path: '/products' },
        { label: 'Brands', path: '/brands' },
        { label: 'Effects + Uses', path: '/effects-uses' },
        { label: 'Featured products', path: '/featured-products' }
      ]
    }
    // Merge remote and local config
    mergedConfig = Object.assign(remoteConfig, self.kioskConfig)
    localStorage.setItem('kiosk_config', JSON.stringify(mergedConfig))
    console.log('Merged config', mergedConfig, config)
  }
  console.log('%c UPDATING VUE CONFIG', 'background-color:blue;color:white;')
  // Set plugins
  Vue.use(configPlugin, mergedConfig)
  Vue.use(Vue2TouchEvents, {
    swipeTolerance: 100
  })
  Vue.use(VueFilter)

  // Global format price

  Vue.filter('formatPrice', function(value) {
    let numPrice = Number(value).toFixed(2)
    numPrice = numPrice.includes('.00')
      ? numPrice.slice(0, numPrice.indexOf('.00'))
      : numPrice
    return '$' + numPrice
  })

  Vue.filter('formatPercentage', function(value) {
    if (!value) value = 0
    value = '%' + Number(value).toFixed(2)
    return value
  })

  Vue.filter('formatPercentage', function(value) {
    if (!value) value = 0
    value = Number(value).toFixed(2) + '%'
    return value
  })

  // Heap
  if (mergedConfig.HEAP_ID) {
    /* eslint-disable */
    // (window.heap = window.heap || []),
    //   (heap.load = function(e, t) {
    //     (window.heap.appid = e), (window.heap.config = t = t || {});
    //     var r = t.forceSSL || "https:" === document.location.protocol,
    //       a = document.createElement("script");
    //     (a.type = "text/javascript"),
    //       (a.async = !0),
    //       (a.src =
    //         (r ? "https:" : "http:") +
    //         "//cdn.heapanalytics.com/js/heap-" +
    //         e +
    //         ".js");
    //     var n = document.getElementsByTagName("script")[0];
    //     n.parentNode.insertBefore(a, n);
    //     for (
    //       var o = function(e) {
    //           return function() {
    //             heap.push([e].concat(Array.prototype.slice.call(arguments, 0)));
    //           };
    //         },
    //         p = [
    //           "addEventProperties",
    //           "addUserProperties",
    //           "clearEventProperties",
    //           "identify",
    //           "resetIdentity",
    //           "removeEventProperty",
    //           "setEventProperties",
    //           "track",
    //           "unsetEventProperty"
    //         ],
    //         c = 0;
    //       c < p.length;
    //       c++
    //     )
    //       heap[p[c]] = o(p[c]);
    //   });
    // heap.load(mergedConfig.HEAP_ID);

    // if (mergedConfig.HEAP_USER) {
    //   heap.identify(mergedConfig.HEAP_USER);
    // }
    if (mergedConfig.HEAP_ID && mergedConfig.HEAP_USER) {
      /* Vue.use(VueGtag, {
        config: { id: mergedConfig.HEAP_ID, params:{'user_id': mergedConfig.HEAP_USER,'userId': mergedConfig.HEAP_USER} },
        bootstrap: true
      }, router);*/
    }
  }
  // IF   GS LICENSE added and heap user added boot up GS LIBRARY
  if (mergedConfig.HEAP_USER) {
    // Boot-up the GS library and send information about the kiosk.
    initGsClient(data)
  }

  /* eslint-disable no-new */
  var vm = new Vue({
    store: vuexStore,
    components: { App },
    router,
    template: '<App/>',
    created() {
      window.addEventListener('offline', () => {
        vuexStore.dispatch('setConnected', false)
      })
      window.addEventListener('online', () => {
        vuexStore.dispatch('setConnected', true)
      })
    }
  }).$mount('#app')

  // Socket initialisation for RFID reader
  console.log('%c connecting to sockket', 'background-color:#000; color:#fff')
  if (
    mergedConfig.RFID_ENABLED // &&
    //  window.location.href.indexOf(':8080') === -1
  ) {
    const socket = io('http://localhost:3000')
    var activeRfid = null

    socket.on('connect', function() {
      console.log('Connect ' + socket.id)
    })

    // Detect type
    socket.on('type', function(type) {
      if (type === 'us') {
        socket.emit('set_threshold', mergedConfig.SENSOR_THRESHOLD)
      }
    })

    // US sensor
    socket.on('sensor_uncovered', function(comName) {
      var portNumber = Number(comName.slice(-1))
      console.log('Sensor uncovered:' + portNumber)
      vm.$emit('sensor-uncovered', portNumber)
    })

    socket.on('sensor_covered', function(comName) {
      var portNumber = Number(comName.slice(-1))
      console.log('Sensor covered:' + portNumber)
      vm.$emit('sensor-covered', portNumber)
    })

    // RFID sensor
    const blockNFCmethod = data => {
      console.log(
        activeRfid ? `rfid event blocked ${data}` : `rfid trigged ${data}`
      )
      if (activeRfid === null) {
        activeRfid = data
        console.log('Tag:' + data)
        console.log('Tag put and block' + data)

        vm.$emit('tag-put', data)
        setTimeout(() => {
          console.log('NFC/RFID reader unblocked')
          activeRfid = null
        }, 15000)
      }
    }
    const doNotBlock = data => {
      if (activeRfid !== data) {
        activeRfid = data
        console.log('Tag:' + data)
        console.log('Tag put but does not block' + data)
        vm.$emit('tag-put', data)
      }
    }
    socket.on(
      'tag_put',
      mergedConfig.BLOCK_SIMULTANEUS_NFC ? blockNFCmethod : doNotBlock
    )

    console.log('function event', data => {
      doNotBlock(data)
    })

    socket.on('tag_remove', function(data) {
      let condition = mergedConfig.BLOCK_SIMULTANEUS_NFC
        ? activeRfid === data
        : activeRfid !== null
      if (condition) {
        activeRfid = null
        console.log('Tag removed')
      }
    })
  }

  if ('serviceWorker' in navigator) {
    if (
      document.readyState === 'complete' ||
      document.readyState === 'interactive'
    ) {
      startSW(vm)
    } else {
      window.addEventListener('load', () => startSW(vm))
    }
  }


  // //Emit event to reload App
  // if (triggerReload) {
  //   loadConfigEvent.data = {config: mergedConfig}
  //   let event = window.dispatchEvent(loadConfigEvent)
  // }
}

function defineAdConfig(ad_configs) {
  let configs = [...ad_configs]
  if (configs) {
    if (configs.length === 0) {
      return null
    }
    if (configs.length === 1) {
      if (configs[0].asset && configs[0].asset.url) {
        let assetExtension = configs[0].asset.url.split('.')[
          configs[0].asset.url.split('.').length - 1
        ]
        if (assetExtension === 'mp4' || assetExtension === 'MP4') {
          configs[0].url_brand_video = configs[0].asset.url
        } else if (
          assetExtension === 'jpg' ||
          assetExtension === 'jpeg' ||
          assetExtension === 'png' ||
          assetExtension === 'JPG' ||
          assetExtension === 'JPEG' ||
          assetExtension === 'PNG'
        ) {
          configs[0].url_brand_image = configs[0].asset.url
        }
      }
      return configs[0]
    }
    if (configs.length > 1) {
      let index = configs.findIndex(ac => ac.id === self.kioskConfig.AD_CONFIG)
      if (index >= 0) {
        if (configs[index].asset && configs[index].asset.url) {
          let assetExtension = configs[index].asset.url.split('.')[
            configs[index].asset.url.split('.').length - 1
          ]
          if (assetExtension === 'mp4' || assetExtension === 'MP4') {
            configs[index].url_brand_video = configs[index].asset.url
          } else if (
            assetExtension === 'jpg' ||
            assetExtension === 'jpeg' ||
            assetExtension === 'png' ||
            assetExtension === 'JPG' ||
            assetExtension === 'JPEG' ||
            assetExtension === 'PNG'
          ) {
            configs[index].url_brand_image = configs[index].asset.url
          }
        }
        return configs[index]
      } else {
        if (configs[0].asset && configs[0].asset.url) {
          let assetExtension = configs[0].asset.url.split('.')[
            configs[0].asset.url.split('.').length - 1
          ]
          if (assetExtension === 'mp4' || assetExtension === 'MP4') {
            configs[0].url_brand_video = configs[0].asset.url
          } else if (
            assetExtension === 'jpg' ||
            assetExtension === 'jpeg' ||
            assetExtension === 'png' ||
            assetExtension === 'JPG' ||
            assetExtension === 'JPEG' ||
            assetExtension === 'PNG'
          ) {
            configs[0].url_brand_image = configs[0].asset.url
          }
        }
        return configs[0]
      }
    }
  } else {
    return null
  }
}

function loadGsScript(data) {
  try {
    /* var head = document.getElementsByTagName('head')[0]
    var gsScript = document.createElement('script')
    gsScript.type = 'text/javascript'
    gsScript.src = 'http://18.219.239.103:8000/static/js/gs_client.min.js'
    gsScript.id = 'gsclient'
    head.appendChild(gsScript)
    return new Promise((resolve, reject) => {
      gsScript.onload = function () {
        console.log('gsScript is loaded.')
        initGsClient(data)
      }
      gsScript.onerror = function () {
        head.removeChild(gsScript)
        setTimeout(loadGsScript, 5 * 60 * 1000, data)
      }
    }) */
  } catch (e) {
    console.error(e)
    /* head.removeChild(gsScript)
    setTimeout(loadGsScript, 5 * 60 * 1000, data) */
  }
}

function initGsClient(data) {
  console.log('DATA TO INIT', data)
  try {
    if (self.kioskConfig.ANALITYC_TOKEN) {
      if (localStorage.getItem('upload_in_progress') === 'true') {
        localStorage.setItem('upload_in_progress', false)
      }

      Vue.use(VueGlobalVariable, {
        globals: {
          // eslint-disable-next-line no-undef
          $gsClient: new Analytics({
            accountId: 1,
            uploadFrequency: 5,
            token: self.kioskConfig.ANALITYC_TOKEN,
            source: {
              store: data.store.name,
              section: data.catalog.location,
              kiosk: self.kioskConfig.HEAP_USER,
              layout: data.store.layout.home_layout
                ? data.store.layout.home_layout
                : data.store.layout.template
            }
          })
        }
      })
    } else {
      console.error('NO HAY TOKEN')
    }

    console.log('$gsClient is up.')
  } catch (e) {
    Sentry.captureException(e)
    console.error(e)
  }
}

/**
 * Start Service Worker
 */
function startSW(vm) {
  // Register service worker
  navigator.serviceWorker
    .register('/service-worker.js', { scope: '/' })
    .then(registration => {
      console.log('SW registered: ', registration)

      // Get service worker state
      var serviceWorker
      if (registration.installing) {
        serviceWorker = registration.installing
      } else if (registration.waiting) {
        serviceWorker = registration.waiting
      } else if (registration.active) {
        // Fetch data on active
        vm.$emit('fetch-data')
        window.serviceWorkerState = registration.active.state
      }

      if (serviceWorker) {
        serviceWorker.addEventListener('statechange', function(e) {
          window.serviceWorkerState = e.target.state
          if (e.target.state === 'activated') {
            // Fetch data on active
            vm.$emit('fetch-data')
          }
        })
      }
    })
    .catch(registrationError => {
      window.serviceWorkerState = 'registration error'
      console.log('SW registration failed: ', registrationError)
      retries = retries + 1
      if (retries < 4) {
        startSW(vm)
        console.log('Retrying SW Registration (' + retries + ')')
      }
    })

  navigator.serviceWorker
    .register('/static/js/firebase-messaging-sw.js', { scope: '/static/js/' })
    .then(registration => {
      console.log('FIREBASE SW registered: ', registration)
    })
    .catch(error => {
      console.error('firebase sw not resiteresd', error)
    })

  // Check cache controller, ask SW to check cache regularly
  setInterval(function() {
    if (navigator.serviceWorker.controller) {
      navigator.serviceWorker.controller.postMessage('check cache')
    }
  }, 5 * 60 * 1000)
}
