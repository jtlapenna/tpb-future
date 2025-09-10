self.kioskConfig = {
  DISABLE_SOCKET: true,

  /**
   * Kiosk mode
   * @type {String} brand|shopping
   */
  // KIOSK_MODE: 'shopping',
  /**
   * Home layout
   * @type {String} default|swipe|rfidswipe|rfidnav
   */
  // HOME_LAYOUT: 'spotlight',
  // HOME_LAYOUT: 'split_screen',
  /**
   * Enable RFID functionality
   * @type {Boolean}
   */
  RFID_ENABLED: true,
  /**
   * Enable shopping functionality
   * @type {Boolean}
   */
  // SHOPPING_ENABLED: true,
  /**
   * UI colors
   * @type {String} Hex color
   */
  // MAIN_COLOR: '#00C796',
  // SECONDARY_COLOR: '#E12291',
  /**
   * Main background
   * @type {String} Media URL, can be an image or a video
   */
  // BACKGROUND: '/static/img/default-background.jpg',
  /**
   * Store logo
   * @type {String} Image URL, transparent PNG
   */
  // STORE_LOGO: '/static/img/default-store-logo.png',
  /**
   * API configuration
   * @param {String} URL
   * @param {String} CATALOG_ID
   * @param {String} TOKEN
   */
  API: {
    URL: 'https://api-prod.thepeakbeyond.com/api/v1',
    CATALOG_ID: 507,
    TOKEN:
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjQ3ODkxNDc5MjMsInN1YiI6MTc3LCJhdWQiOlsiYXBpIl0sImp0aSI6IjE2MTBlN2UyNGMzMjEyZWNiZjc0YmRmNzJlOGViOTc4In0.1Ix9m_EErhmCMRrxkDcnaC9X7AzsRSOtqDzFHZ5kZ04'
  },
  /**
   * Enable service worker log in console
   * @type {Boolean}
   */
  SW_LOG: true,
  /**
   * Default UI texts
   * @param {String} PRODUCT_DESCRIPTION
   */
  // TEXT: {
  //   PRODUCT_DESCRIPTION: 'Please ask your budtender for more info.'
  // },
  /**
   * Idle delay, time before the inactivity modal appears
   * @type {Number}
   */
  // IDLE_DELAY: 60,
  /**
   * Restart delay, time before the session is refreshed when the inactivty modal is on
   * @type {Number}
   */
  // RESTART_DELAY: 30,
  /**
   * Put featured products on top on pages
   * @param {Boolean} BRANDS
   * @param {Boolean} PRODUCTS
   * @param {Boolean} USES
   */
  // SORT_FEATURED: {
  //   BRANDS: true,
  //   PRODUCTS: true,
  //   USES: true
  // },
  /**
   * GS ACCOUNT ID and KEY
   * @param {String} GS_ACCOUNT_ID
   * @param {String} GS_LICENSE_KEY
   */
  GS_ACCOUNT_ID: 1,
  GS_LICENSE_KEY: '28b858e7-dff9-483d-8c57-0478013b894d',
  /**
   * HEAP account ID
   * @type {Number}
   */
  HEAP_ID: 123456789,
  /**
   * HEAP account USER
   * @type {String} HEAP_USER
   */
  // HEAP_USER: customername-kioskname,
  HEAP_USER: 'Localkiosk',
  /**
   * UI main navigation
   * @type {Array}
   */
  /*
  NAV: [
      // { label: 'Peanut Butter', path: '/product/167' },
    // { label: 'Cnuoncentrates', path: '/products/3' },
    // { label: 'Edibles', path: '/products/9' },
    // { label: 'Flowers', path: '/products/10' },
    // { label: 'Products', path: '/products' }
    { label: 'Products', path: '/products' },
    { label: 'Brands', path: '/brands' },
    { label: 'Effects + Uses', path: '/effects-uses' },
    { label: 'Featured products', path: '/featured-products' }
  ]
  */
  /**
   * Config added to allow Offline feature on kiosks */
  // USE_BRAND_SPOTLIGHT: true,
  // PRODUCT_ID: 66698,
  // BRAND_ID: 1106,
  // URL_BRAND_IMAGE: 'https://peak-beyond-assets.s3-us-west-1.amazonaws.com/adssale/west+coast+cure+brand+asset.jpg',
  // URL_BRAND_VIDEO: null,
  //   USE_BRAND_SPOTLIGHT: false,
  //   PRODUCT_ID: 77226,
  // BRAND_ID: 382,
  //   URL_BRAND_IMAGE: 'https://peak-beyond-assets.s3-us-west-1.amazonaws.com/adssale/poppy+flower.png',
  //   URL_BRAND_VIDEO: null,
  // BUTTONS_COLOR: '#124734',
  // NAVS_COLOR: '#FDDA1A',
  // BACKGROUND_IMAGE_TOP: true,
  // CHECKOUT_MESSAGE: 'We will follow up about your order.',
  // ANALYTICS_API_URL: 'http://127.0.0.1:8000/api/analytics',
  // ANALITYC_TOKEN: '2|xHs8jABhyf5jVXq5IVgiY66LpIrPCDMPWaTYQ0RC',git
  // ANALITYC_TOKEN: '1|Tnxz8fNHGCSCJ9KloDnlf5XyhRGBlNWcoMCzP71D',
  ANALITYC_TOKEN: '6|4kkdnsOqo3fZzcgqdatCnteTaJSjCkvZNWAanfHp',
  ANALYTICS_API_URL: 'https://vulpecula.aimservices.tech/api/analytics',

  // ANALITYC_TOKEN: '1|Tnxz8fNHGCSCJ9KloDnlf5XyhRGBlNWcoMCzP71D',
  // CHECKOUT_MESSAGE: 'We will follow up about your order.',
  // ANALITYC_API_URL: 'http://localhost:8000/api/analytics',
  // ANALITYC_TOKEN: '1|RoieFNajln8HtpmzuKpMovKay5S8C1RW9CZTOUz4',
  // STORE_URL: 'https://aim-services-store-test.myshopify.com/',
  // AD_CONFIG: 7,
  STORE_LOCALLY: 1,
  // DIRECT_CHECKOUT: true
  USE_VARIANTS: true,
  SPLIT_FLOWER_SCREEN: true,
  SHOW_PRODUCT_ATTRIBUTES: true,
  // ENABLE_REQUEST_TAX_TREEZ: true
  PRINTER_API_URL: 'https://api-printer.thepeakbeyond.com/api/v1/receipt',
  SENTRY_DSN:
    'https://11ec2c96e3ea4a8c0535cfbf00adb0da@o4505478124208128.ingest.sentry.io/4506044769894400',
  SENTRY_ENVIRONMENT: 'Production'
}
