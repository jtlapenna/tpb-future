<template>
  <div id="screen-debug-cache" class="screen screen--debug screen--debug--cache">
    <h1 class="title">
      Debug console
    </h1>

    <h2>Info</h2>
    <ul>
      <li>Secure context: {{ secureContext }}</li>
      <li>Cache available: {{ cacheAvailable }}</li>
      <li>SW available: {{ swAvailable }} / {{ swState }}</li>
      <li>Store config in cache: {{ cacheStore !== null }}</li>
    </ul>

    <h2>Products in cache</h2>
    <ul>
      <li
        v-for="(product, index) in cacheProducts"
        v-bind:key="'url' + index">
        #{{ product.id }} {{ product.name }}
      </li>
    </ul>
    <p v-if="!cacheProducts || cacheProducts.length == 0">
      No product in cache
    </p>
  </div>
</template>

<script>
export default {
  name: 'ScreenDebugCache',
  data () {
    return {
      cacheProducts: [],
      cacheStore: null,
      cacheURLs: []
    }
  },
  computed: {
    cacheAvailable: function () {
      return ('caches' in window)
    },
    secureContext: function () {
      return window.isSecureContext
    },
    swAvailable: function () {
      return ('serviceWorker' in navigator)
    },
    swState: function () {
      return window.serviceWorkerState
    }
  },
  created () {
    var self = this

    caches.open('kiosk-api-cache').then(function (cache) {
      cache.keys().then(function (response) {
        response.forEach(function (element, index, array) {
          self.cacheURLs.push(element.url)

          cache.match(element.url).then(function (response) {
            response.json().then(function (data) {
              if (data.product) {
                self.cacheProducts.push(data.product)
              } else if (data.store) {
                self.cacheStore = data.store
              }
            })
          })
        })
      })
    })
  }
}
</script>

<style scoped lang="scss">
  .screen--debug {
    padding: 110px 50px;
    position: fixed;
    top: 0;
    left: 320px;
    width: 100%;
    height: 100%;

    background: rgba($bluecharcoal, 0.95);
    overflow: scroll;
  }

  .title {
    margin: 0 0 25px;

    font: 58px/1.2 var(--font-extralight);
    text-indent: -0.05em;
  }
</style>
