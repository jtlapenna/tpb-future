import { API_ENVIROMENTS } from '../const/globals'

export const getConfigFromData = ({store, catalog, config, paymentGateway}) => {
  return {
    KIOSK_MODE: store.layout.template ? store.layout.template : 'shopping',
    HOME_LAYOUT: store.layout.home_layout
      ? store.layout.home_layout
      : 'default',
    HOME_SCREEN_TITLE: store.layout.home_screen_title
      ? store.layout.home_screen_title
      : "Today's Deals",
    PAGINATION_TIME: store.layout.pagination_time
      ? store.layout.pagination_time
      : 0,
    ON_SALE_TEXT:
      store.layout.checkout_text && store.layout.checkout_text !== ''
        ? store.layout.checkout_text
        : 'Discounts and promotions will be applied at the register.',
    ON_SALE_CATEGORY_ID: store.layout.store_category_id
      ? store.layout.store_category_id
      : null,
    MENU_BOARDS_CATEGORY_ID: store.layout.store_categories
      ? store.layout.store_categories
      : null,
    ON_SALE_CATEGORY: store.layout.store_category
      ? store.layout.store_category
      : null,
    PRODUCT_UI: store.layout.nav_ui ? store.layout.nav_ui : 'regular',
    ON_SALE_BADGES_ENABLED: store.layout.on_sale_badges
      ? store.layout.on_sale_badges
      : false,
    STAND_SIDE: store.layout.stand_side ? store.layout.stand_side : 'left',
    SCREEN_TYPE: store.layout.screen_type
      ? store.layout.screen_type
      : 'big_screen',
    RFID_ENABLED: store.layout.rfid_disabled
      ? !store.layout.rfid_disabled
      : true,
    SHOPPING_ENABLED: store.layout.shopping_disabled
      ? !store.layout.shopping_disabled
      : true,
    POS_TYPE: catalog.api_type ? catalog.api_type : 'none',
    STORE_CHECKOUT_TYPE: store.checkout_type,
    STORE_CUSTOMER_ID: store.customer_id,
    DIRECT_CHECKOUT: store.direct_checkout,
    SENSOR_THRESHOLD: catalog.sensor_threshold
      ? catalog.sensor_threshold
      : 9999,
    SEARCH_SENSIBILITY: store.settings.search_sensibility
      ? store.settings.search_sensibility
      : 0.5,
    ORDER_NOTIFICATION: catalog.notify_by_email
      ? catalog.notify_by_email
      : false,
    CUSTOMER_NOTIFICATION: catalog.notify_to_customer
      ? catalog.notify_to_customer
      : false,
    MAIN_COLOR: store.settings.main_color
      ? store.settings.main_color
      : '#00C796',
    SECONDARY_COLOR: store.settings.secondary_color
      ? store.settings.secondary_color
      : '#E12291',
    BACKGROUND: getBackground(store),
    STORE_LOGO: store.logo
      ? store.logo.url
      : '/static/img/default-store-logo.png',
    LICENSE_NUMBER: store.settings.dispensary_license_number
      ? store.settings.dispensary_license_number
      : false,
    USE_TOTAL_THC: store.use_total_thc ? store.use_total_thc : false,
    DISABLE_TAX_MESSAGE: store.settings.disable_tax_message
      ? store.settings.disable_tax_message
      : false,
    PICK_PRODUCT_ANIMATION: store.settings.show_pick_product_message
      ? store.settings.show_pick_product_message
      : false,
    SW_LOG: store.settings.service_worker_log
      ? store.settings.service_worker_log
      : false,
    TEXT: {
      PRODUCT_DESCRIPTION: store.settings.default_product_description
        ? store.settings.default_product_description
        : 'Please ask your budtender for more info.',
      WELCOME_MESSAGE: store.layout.welcome_message
        ? store.layout.welcome_message
        : null,
      PICK_PRODUCT: store.settings.pick_product_message
        ? store.settings.pick_product_message
        : 'The products below are featured near this display. Pick one, up check it out, and place it on the block to learn more.'
    },
    IDLE_DELAY: store.settings.idle_delay ? store.settings.idle_delay : 120,
    BLOCK_SIMULTANEUS_NFC: store.block_simultaneous_nfc
      ? store.block_simultaneous_nfc
      : false,
    RESTART_DELAY: store.settings.restart_delay
      ? store.settings.restart_delay
      : 30,
    REFRESH_DELAY: store.settings.refresh_delay
      ? store.settings.refresh_delay
      : 300,
    SORT_FEATURED: {
      BRANDS: store.settings.featured_products_on_top_for_brands_page
        ? store.settings.featured_products_on_top_for_brands_page
        : false,
      PRODUCTS: store.settings.featured_products_on_top_for_products_page
        ? store.settings.featured_products_on_top_for_products_page
        : false,
      USES: store.settings.featured_products_on_top_for_effects_and_uses_page
        ? store.settings.featured_products_on_top_for_effects_and_uses_page
        : false
    },
    HEAP_ID: store.settings.heap_id ? store.settings.heap_id : false,

    SLIDES: store.layout.store_assets,
    RFID_POP_UP_BEHAVIOR: store.settings.rfid_popup_setting
      ? store.settings.rfid_popup_setting
      : 0,
    LEFT_TO_RIGHT: store.settings.left_to_right
      ? store.settings.left_to_right
      : false,
    PRINTER_MAC_ADDRESS: store.settings.printer_mac_address ? store.settings.printer_mac_address : null,
    // Ads config
    USE_BRAND_SPOTLIGHT:
      config && config.use_brand_spotlight
        ? config.use_brand_spotlight
        : false,
    PRODUCT_ID:
      config && config.store_product && config.store_product.id
        ? config.store_product.id
        : null,
    BRAND_ID: config && config.brand_id ? config.brand_id : null,
    URL_BRAND_IMAGE:
      config && config.url_brand_image ? config.url_brand_image : null,
    URL_BRAND_VIDEO:
      config && config.url_brand_video ? config.url_brand_video : null,
    SHOW_PRODUCT_ATTRIBUTES: store.settings.show_thc_cbd_values != null ? store.settings.show_thc_cbd_values : false,
    ATTRIBUTE_COLORS: store.settings.main_color
      ? store.settings.main_color
      : '#00C796',
    USE_VARIANTS: !!store.settings.show_variants,
    STORE_URL: store.shop_url,
    ENABLE_REQUEST_TAXES: store.settings.enable_request_tax != null ? store.settings.enable_request_tax : false,
    ENABLE_TOGGLE_TAXES: store.settings.enable_toggle_tax != null ? store.settings.enable_toggle_tax : false,
    CUSTOMER_TYPE_RECREATIONAL: store.settings.default_toggle_customer_type != null ? store.settings.default_toggle_customer_type === 'recreational' : false,
    DISABLE_OVERLAY: store.layout.disable_overlay_mask != null ? store.layout.disable_overlay_mask : false,
    FAST_ANIMATION: store.layout.fast_animation != null ? store.layout.fast_animation : false,
    PAYMENT_GATEWAY: {
      NAME: paymentGateway && paymentGateway.payment_gateway_provider && paymentGateway.payment_gateway_provider.name ? paymentGateway.payment_gateway_provider.name : null,
      PAYMENT_PROVIDER_FIELDS: paymentGateway && paymentGateway.payment_gateway_provider && paymentGateway.payment_gateway_provider.name === 'Aeropay'
        ? {
          MERCHANT_LOCATION_UU_ID: paymentGateway.api_settings.merchantLocationUUID ? paymentGateway.api_settings.merchantLocationUUID : null,
          AEROPAY_URL: paymentGateway.api_settings.aeropayUrl ? paymentGateway.api_settings.aeropayUrl : null
        } : {}
    },
    SHOW_ALTERNATIVE_FLOWER_ICON: store.settings.show_alternative_flower_icon != null ? store.settings.show_alternative_flower_icon : false,
    CHECKOUT_MESSAGE: store.settings.checkout_message != null ? store.settings.checkout_message : null,
    ENABLED_CONTINUOUS_CART: store.enabled_continuous_cart,
    BACKGROUND_VIDEO_OR_IMAGE: store.layout.video_image_background_asset && store.layout.video_image_background_asset.asset ? store.layout.video_image_background_asset.asset.url : null
  }
}

const configPlugin = {
  install: (Vue, config) => {
    Vue.mixin({
      computed: {
        $config: () => {
          return JSON.parse(localStorage.getItem('kiosk_config'))
        },
        currentEnv () {
          return API_ENVIROMENTS.find(x => x.url === this.$config.API.URL)
        }
      },
      methods: {
        mergeConfig (data) {
          var mergedConfig = self.kioskConfig
          if (data !== false) {
            var store = data.store
            var catalog = data.catalog
            var paymentGateway = data.payment_gateway
            var config = null
            if (catalog.ad_configs) {
              config = this.defineAdConfig(catalog.ad_configs)
            }
            // Map remote config
            localStorage.setItem('config_data', JSON.stringify(data))
            var remoteConfig = getConfigFromData({store, catalog, config, paymentGateway})
            // Map navigation
            if (
              store.layout.navigation &&
              store.layout.navigation.items &&
              store.layout.navigation.items.length > 0
            ) {
              var nav = []

              store.layout.navigation.items.forEach(function (item) {
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
        },
        defineAdConfig (adConfigs) {
          let configs = [...adConfigs]
          if (configs) {
            if (configs.length === 0) {
              return null
            }
            if (configs.length === 1) {
              if (configs[0].asset && configs[0].asset.url) {
                let assetExtension = configs[0].asset.url.split('.')[configs[0].asset.url.split('.').length - 1]
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
                  let assetExtension = configs[index].asset.url.split('.')[configs[index].asset.url.split('.').length - 1]
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
                  let assetExtension = configs[0].asset.url.split('.')[configs[0].asset.url.split('.').length - 1]
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
      }
    })
  }
}

function getBackground(store) {
  if (store.layout.home_layout === 'video_image_background') {
    return '/static/img/black-background.jpg'
  }

  if (store.settings.background_media) {
    return store.settings.background_media.url
  }

  return '/static/img/default-background.jpg'
}
export default configPlugin
