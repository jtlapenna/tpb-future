<template>
  <transition
    appear
    v-on:leave="onTransitionLeave"
    v-bind:css="false"
    mode="out-in">
    <div v-if="!getIsFullScreenProduct()" id="the-sidebar" class="the-sidebar" v-bind:class="{ 'the-sidebar--license': $config.LICENSE_NUMBER }">
      <transition
        appear
        v-on:enter="onTransitionEnterNav"
        v-on:leave="onTransitionLeaveNav"
        v-bind:css="false"
        mode="out-in">
        <div v-if="navShow">
          <the-nav
            v-bind:class="{ 'the-nav--sidebar--fullheight': !$config.SHOPPING_ENABLED }"
            class="the-nav--sidebar"
            ref="theNav"></the-nav>

          <div v-if="$config.KIOSK_MODE === 'brand'" class="the-sidebar__background"></div>
        </div>
      </transition>

      <transition
        appear
        v-on:enter="onTransitionEnterCart"
        v-on:leave="onTransitionLeaveCart"
        v-bind:css="false"
        mode="out-in">
        <router-link v-if="$config.SHOPPING_ENABLED" :to="{ name: 'cart'}">
          <div
            v-bind:class="{ 'cart--has-products': Number(cartTotal) > 0 }"
            class="cart">
            <div class="cart__inner">
              <div class="cart__title">
                <div class="cart__title__text">
                  My cart
                </div>
                <div class="cart__title__line"></div>
              </div><!-- .cart__title -->

              <div class="cart__total">
                <div class="cart__total__icon"></div>
                <div class="cart__total__price">
                  {{ cartTotal | formatPrice }}
                </div>
              </div><!-- .cart__total -->
            </div><!-- .cart__inner -->

            <lottie-container
              v-bind:path="'block-default-intro'"
              v-bind:autoplay="false"
              v-bind:loop="false"
              ref="lottieCartIntro"></lottie-container>

            <transition
              v-on:enter="onCartTransitionEnter"
              v-on:leave="onCartTransitionLeave"
              v-bind:css="false">
              <lottie-container
                v-if="$route.name === 'cart'"
                v-bind:path="'cart-on'"
                v-bind:autoplay="true"
                v-bind:loop="false"
                ref="lottieCartOn"></lottie-container>
            </transition>
          </div>
        </router-link>
      </transition>
    </div>
  </transition>
</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import TheNav from '@/components/TheNav'
import {TweenLite, TimelineLite, Power3} from 'gsap/all'
import $ from 'jquery'
import {GSAP_ANIMATION} from '@/const/globals.js'
import { mapGetters, mapMutations } from 'vuex'

export default {
  name: 'TheSidebar',
  components: {
    LottieContainer,
    TheNav
  },
  props: [
    'cart',
    'cartTotal'
  ],
  data () {
    return {
      cartTotalTweened: this.cartTotal,
      navShow: false
    }
  },
  computed: {
    cartTotalAnimated: function () {
      return this.cartTotalTweened
    }
  },
  watch: {
    '$route' (to, from) {
      let self = this
      if (to.name !== 'home' && !this.navShow) {
        setTimeout(function () {
          self.navShow = true
        }, self.$config.KIOSK_MODE === 'limited' ? 500 : 0)
      } else if (to.name === 'home') {
        self.navShow = false
      }
    },
    cartTotal: function (newValue) {
      TweenLite.to(
        this.$data,
        0.5,
        {
          cartTotalTweened: newValue
        }
      )
    }
  },
  created: function () {
    this.navShow = (this.$route.name !== 'home')
  },
  methods: {
    ...mapMutations('cart', ['setGlobalCart']),
    ...mapGetters('products', [ 'getIsFullScreenProduct']),
    /**
     * Sidebar transition leave
     */
    onTransitionLeave: function (el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container.find('.the-nav .link-home'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          scale: 0,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.append
      )

      tl.staggerTo(
        container.find('.link, .cart').reverse(),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          x: -200,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.append
      )

      if (this.$config.KIOSK_MODE === 'brand') {
        tl.fromTo(
          container.find('.the-sidebar__background'),
          GSAP_ANIMATION.duration,
          {
            x: 0
          },
          {
            x: -container.width(),
            ease: Power3.easeIn
          },
          GSAP_ANIMATION.append
        )
      }

      tl.call(function () {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Sidebar cart transition enter
     */
    onTransitionEnterCart: function (el, done) {
      // Selectors
      var self = this
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.call(function () {
        if (self.$refs.lottieCartIntro) {
          self.$refs.lottieCartIntro.animation.play()
        }
      }, null, null, 1.2)

      tl.staggerFrom(
        container.find('.cart__title__text, .cart__title__line, .cart__total__icon, .cart__total__price'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          clearProps: 'opacity'
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
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
     * Sidebar cart transition leave
     */
    onTransitionLeaveCart: function (el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container.find('.cart'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          x: -200,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.append
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
     * Sidebar nav transition enter
     */
    onTransitionEnterNav: function (el, done) {
      // Selectors
      var self = this
      var container = $(el)

      // Before animation
      container.find('.link .arrow, .link .label').css({transition: 'none'})

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      if (this.$config.KIOSK_MODE === 'brand') {
        tl.fromTo(
          container.find('.the-sidebar__background'),
          GSAP_ANIMATION.duration,
          {
            x: -container.width()
          },
          {
            x: 0,
            clearProps: 'transform',
            ease: Power3.easeInOut
          },
          GSAP_ANIMATION.append
        )
      }

      tl.from(
        container.find('.link-home'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          scale: 0,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.append
      )

      container.find('.link').each(function (index) {
        var link = $(this)
        var animation = self.$refs.theNav.$refs.lottieBlockIntro[index].animation
        var animationOn = false
        if (link.find('.background-on').length === 1) {
          animationOn = self.$refs.theNav.$refs.lottieBlockOn[0].animation
        }
        var start = 0.3 * index

        tl.call(function () {
          if (animation) {
            animation.play()
            if (animationOn !== false) {
              animationOn.play()

              animationOn = null
            }

            animation = null
          }
        }, null, null, start)

        tl.from(
          link,
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            clearProps: 'opacity'
          },
          start
        )

        tl.from(
          link.find('.number__text'),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            x: -10,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          start + 0.1
        )

        tl.from(
          link.find('.number__line'),
          GSAP_ANIMATION.duration,
          {
            scaleX: 0,
            clearProps: 'transform',
            ease: Power3.easeInOut
          },
          start + 0.1
        )

        tl.from(
          link.find('.label'),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            y: 50,
            clearProps: 'transform, opacity, transition',
            ease: Power3.easeOut
          },
          start + 0.1
        )

        tl.from(
          link.find('.arrow'),
          GSAP_ANIMATION.duration,
          {
            scale: 0,
            x: -50,
            clearProps: 'transform, transition',
            ease: Power3.easeOut
          },
          start + 0.4
        )

        tl.from(
          link.find('.arrow__line'),
          GSAP_ANIMATION.duration,
          {
            scale: 0,
            x: -10,
            clearProps: 'transform',
            ease: Power3.easeOut
          },
          start + 0.6
        )

        link = null
      })

      tl.call(function () {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Sidebar nav transition leave
     */
    onTransitionLeaveNav: function (el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container.find('.link-home'),
        0.5,
        {
          alpha: 0,
          scale: 0,
          ease: Power3.easeIn
        },
        0
      )

      tl.staggerTo(
        container.find('.link').reverse(),
        0.5,
        {
          alpha: 0,
          x: -200,
          ease: Power3.easeIn
        },
        0.1,
        0
      )

      if (this.$config.KIOSK_MODE === 'brand') {
        tl.fromTo(
          container.find('.the-sidebar__background'),
          0.7,
          {
            x: 0
          },
          {
            x: -container.width(),
            ease: Power3.easeIn
          },
          0.3
        )
      }

      tl.call(function () {
        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Cart transition enter
     */
    onCartTransitionEnter: function (el, done) {
      this.$refs.lottieCartOn.animation.goToAndPlay(1, true)
      setTimeout(function () {
        done()
      }, 1000)
    },

    /**
     * Cart transition leave
     */
    onCartTransitionLeave: function (el, done) {
      this.$refs.lottieCartOn.animation.setDirection(-1)
      this.$refs.lottieCartOn.animation.goToAndPlay(30, true)
      setTimeout(function () {
        done()
      }, 1000)
    }
  },
  filters: {
    formatPrice: function (price) {
      let numPrice = Number(price).toFixed(2)
      return '$' + numPrice
    }
  }
}
</script>

<style scoped lang="scss">
  .the-sidebar {
    position: fixed;
    top: 0;
    left: 0;
    width: 320px;
    height: 100%;

    pointer-events: none;
    z-index: 3;

    &__background {
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      background: rgba($bluecharcoal, 0.95);
      z-index: 1;
    }

    &--license {
      .cart {
        bottom: 45px;
      }

      .the-nav {
        bottom: 230px;
      }
    }
  }

  .the-nav {
    pointer-events: auto;
    z-index: 2;
  }

  .cart {
    display: flex;
    overflow: hidden;
    padding: 0 0 0 50px;
    position: absolute;
    bottom: 20px;
    left: 0;
    width: 260px;
    height: 160px;

    border-radius: 0 20px 20px 0;
    flex-direction: column;
    justify-content: center;
    pointer-events: auto;
    z-index: 2;

    color: $white;

    &__inner {
      position: relative;

      z-index: 2;
    }

    &__title {
      display: block;
      padding: 0 0 6px;
      margin: 0 0 15px;
      position: relative;

      transition: color 0.1s linear 0.2s;

      font: 14px/1 var(--font-bold);
      letter-spacing: 0.05em;
      text-transform: uppercase;

      @at-root .app--tablet & {
        font-size: 20px;
      }

      &__line {
        display: block;
        position: absolute;
        bottom: 0;
        left: 0;
        width: 20px;
        height: 3px;

        background: var(--main-color);
        transition: background 0.1s linear 0.2s;
      }
    }

    &__total {
      padding: 8px 0 0 46px;
      position: relative;

      opacity: 0.1;
      transition: opacity 0.1s linear 0.2s;

      font: 30px/40px var(--font-light);
      letter-spacing: 0.05em;

      @at-root .app--tablet & {
        opacity: 0.3;
      }

      &__icon {
        display: block;
        position: absolute;
        width: 34px;
        height: 29px;
        top: 50%;
        left: 0;

        background-image: url('~@/assets/img/icon-cart.svg');
        background-repeat: no-repeat;
        background-size: contain;
        transform: translate3d(0, -50%, 0);
      }
    }

    &__background {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      z-index: 1;
    }

    .lottie-container {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      z-index: 1;
    }

    /deep/ .lottie-container {
      path {
        fill: var(--main-color);
      }

      &--block-default-intro {
        path {
          fill: rgba($black, 0.3);
        }
      }
    }

    &--has-products {
      .cart__total {
        opacity: 1;
      }
    }

    @at-root .router-link-exact-active & {
      // background: var(--main-color);

      &__title {
        color: $black;
        transition-delay: 0.1s;

        &__line {
          background: $black;
          transition-delay: 0.1s;
        }
      }

      &__total {
        opacity: 1;
        transition-delay: 0.1s;
      }
    }
  }

</style>
