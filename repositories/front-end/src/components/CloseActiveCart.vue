<template>
  <div class="container">
  Close an
    <div class="button-container">
      <active-cart-button v-bind:size="'large'"></active-cart-button>
    </div>
  </div>

</template>

<script>
import ActiveCartButton from './ActiveCartButton.vue'
import { mapMutations } from 'vuex'

export default {
  name: 'CloseActiveCart',
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
  margin: 0;
  display: flex;
  font: 3em/1 var(--font-extralight);
  z-index: 100000;
}

.button-container {
  margin-left: 1.5rem;
  position: relative;
  bottom: 0.8rem;
}
</style>
