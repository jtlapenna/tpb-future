const path = require('path')

module.exports = {
  clientsClaim: true,
  skipWaiting: true,
  globDirectory: path.resolve(__dirname, '../'),
  globPatterns: ['static/anim/*', 'static/img/*'],

  // Define runtime caching rules.
  runtimeCaching: [
    {
      urlPattern: new RegExp('^(http|https)://cdn.heapanalytics.com.*'),
      handler: 'staleWhileRevalidate',
      options: {
        cacheName: 'kiosk-asset-cache',
        cacheableResponse: {
          statuses: [0, 200]
        }
      },
    },
    {
      urlPattern: new RegExp('^https://peak-beyond-api\.herokuapp\.com/api/v\\d+/\\d+/(?!customers).*'),
      handler: 'cacheFirst',
      options: {
        cacheName: 'kiosk-api-cache',
        cacheableResponse: {
          statuses: [0, 200]
        }
      },
    },
   /* {
      urlPattern: new RegExp('^https://api-prod\.thepeakbeyond\.com/api/v\\d+/\\d+/(?!customers).*'),
      handler: 'cacheFirst',
      options: {
        cacheName: 'kiosk-api-cache',
        cacheableResponse: {
          statuses: [0, 200]
        }
      },
    },*/
    {
      urlPattern: new RegExp('^https://peak-beyond-api-staging\.herokuapp\.com/api/v\\d+/\\d+/(?!customers).*'),
      handler: 'cacheFirst',
      options: {
        cacheName: 'kiosk-api-cache',
        cacheableResponse: {
          statuses: [0, 200]
        }
      },
    },
    {
      urlPattern: new RegExp('^https://peak-beyond-assets.*\\.mp4'),
      handler: 'cacheFirst', // or 'staleWhileRevalidate'
      options: {
        cacheName: 'kiosk-video-cache', // separate cache for videos
        cacheableResponse: {
          statuses: [0, 200]
        },
        expiration: {
          maxEntries: 10, // limit cache size
          maxAgeSeconds: 7 * 24 * 60 * 60 // 1 week
        }
      },
    },
    {
      urlPattern: new RegExp('^https://peak-beyond-assets.*(?!\\.mp4)'),
      handler: 'cacheFirst',
      options: {
        cacheName: 'kiosk-asset-cache',
        cacheableResponse: {
          statuses: [0, 200]
        }
      },
    },
    {
      urlPattern: new RegExp('^https://peak-beyond-staging.*'),
      handler: 'cacheFirst',
      options: {
        cacheName: 'kiosk-asset-cache',
        cacheableResponse: {
          statuses: [0, 200]
        }
      },
    },
  ],
  importScripts: [
    '/static/js/config.js?v=timestamp',
    '/static/js/sw-cache-sync.js'
  ]
}

