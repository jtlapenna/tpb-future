<template>
  <div class="container">
    <div class="inner-container">
      <span class="text-top"> We could not find an </span>
      <div class="button-container">
        <active-cart-button v-bind:size="'small'" v-bind:info-mode="true"></active-cart-button>
      </div>
    </div>
    <span class="text-bottom">
      with those credentials.
    </span>
    <span class="small-text">
      Build a cart by adding items from the catalog.
    </span>
  </div>

</template>

<script>
import ActiveCartButton from './ActiveCartButton.vue'

export default {
  name: 'ActiveCartNotFound',
  components: { ActiveCartButton },
  data () {
    return {}
  },
  computed: {},
  watch: {},
  filters: {},
  created: function () {},
  mounted: function () {},
  beforeDestroy() {},
  methods: {}
}
</script>

<style scoped lang="scss">
.container {
  margin-top: 3rem;
  display: flex;
  flex-direction: column;
  z-index: 100000;
}

.button-container {
  margin-left: 1.5rem;
  position: relative;
  bottom: 0.5rem;
}

.inner-container {
  display: flex;
}

.text-top {
  font: 3em/1 var(--font-extralight);
}

.text-bottom {
  font: 3em/1 var(--font-extralight);
  margin-top: 1rem;
}

.small-text {
  font: 1.3em/1 var(--font-extralight);
  margin-top: 3.5rem;
}
</style>
