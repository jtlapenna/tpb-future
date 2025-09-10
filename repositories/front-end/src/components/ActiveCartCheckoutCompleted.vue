<template>
  <div class="container">
    <div class="inner-container">

      <span class="text">
        These items have been added
      </span>

      <span v-if="isFirstCheckout" class="text"> to your cart. </span>
      <div v-if="isNotFirstCheckout" class="active-cart-container">
        <span v-if="isNotFirstCheckout" class="text" >to your</span>
        <div class="active-cart-button">
          <active-cart-button v-bind:size="'small'" v-bind:info-mode="true"></active-cart-button>
        </div>
      </div>

      <div class="keep-shopping-finalize-order">
        <active-cart-keep-shopping-finalize-order-footer v-bind:keep-shopping="keepShopping" ></active-cart-keep-shopping-finalize-order-footer>
      </div>
    </div>
  </div>

</template>

<script>


import ActiveCartKeepShoppingButton from './ActiveCartKeepShoppingButton.vue'
import ActiveCartFinalizeOrderButton from './ActiveCartFinalizeOrderButton.vue'
import ActiveCartButton from './ActiveCartButton.vue'
import ActiveCartKeepShoppingFinalizeOrderFooter from './ActiveCartKeepShoppingFinalizeOrderFooter.vue'
import $ from 'jquery'
import { Power3, TimelineLite } from 'gsap/all'
import { mapMutations } from 'vuex'

export default {
  name: 'ActiveCartCheckoutCompleted',
  components: { ActiveCartButton, ActiveCartFinalizeOrderButton, ActiveCartKeepShoppingButton, ActiveCartKeepShoppingFinalizeOrderFooter },
  // props: [
  //   'isFirstCheckout'
  // ],
  data () {
    return {
      isFirstCheckout: false,
      timeout: null
    }
  },
  computed: {
    isNotFirstCheckout() {
      return !this.isFirstCheckout
    }
  },
  watch: {},
  filters: {},
  created: function () {
    // Call transition enter on next tick
    this.$nextTick(this.transitionEnter)

    // Events
    this.$on('transition-leave', this.onTransitionLeave)
  },
  mounted: function () {},
  destroyed: function() {
    this.$off('transition-leave', this.onTransitionLeave)
  },
  methods: {
    ...mapMutations('cart', ['resetActiveCartSession']),
    keepShopping() {
      this.$root.$emit('reset-session')
      this.resetActiveCartSession()
      this.timeout = setTimeout(() => {
        this.$router.push({ name: 'keep-shopping' })
      },100)
    },
    destroyed() {
      if (this.timeout) {
        clearTimeout(this.timeout)
      }
    },
    transitionEnter: function (el, done) {
      // Selectors
      var container = $('.container')

      // Before animation

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerFrom(container,
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeOut
        },
        0.1,
        0.5
      )

      tl.call(function () {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Content transition leave
     */
    onTransitionLeave: function (el, done) {
      // Selectors
      var container = $('.container')

      // Before animation

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container,
        0.5,
        {
          alpha: 0,
          y: 50,
          clearProps: 'opacity, transform',
          ease: Power3.easeIn
        },
        0
      )

      tl.call(function () {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },
  }
}
</script>

<style scoped lang="scss">
.container {
  width: 100%;
  height: 100%;
  margin: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.inner-container {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
}

.inner-container .text {
  font: 2.5em/1 var(--font-extralight);
}

.active-cart-container {
  margin-top: 0.5rem;
  display:flex;
  align-items: center;
  justify-content: center;
}

.active-cart-button {
  margin-left: 1.5rem;
}

.keep-shopping-finalize-order {
  margin-top: 5rem;
}


</style>
