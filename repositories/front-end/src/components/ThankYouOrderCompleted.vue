<template>
  <transition v-on:enter="transitionEnter" v-on:leave="onTransitionLeave" v-bind:css="false"
              mode="out-in">
    <div key="result" class="result">
      <strong>Thank you</strong>
      <div>Please pick up your order at the designated register.</div>

      <button v-on:click="restartSession" type="button" class="result__button">
          <span class="result__button__text">
            Start a new session
          </span><!-- .result__button__text -->
        <span class="result__button__background"></span>
      </button>
    </div><!-- .result -->
  </transition>
</template>

<script>
import $ from 'jquery'
import { Power3, TimelineLite } from 'gsap/all'
import { mapMutations } from 'vuex'

export default {
  name: 'ThankYouOrderCompleted',
  components: {},
  data () {
    return {}
  },
  computed: {},
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
    transitionEnter: function (el, done) {
      // Selectors
      var container = $('.result')

      // Before animation

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerFrom(
        container.find('> *'),
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
      var container = $('.result')

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
    restartSession: function () {
      if (this.$gsClient) {
        this.$gsClient.track('Session ended', {
          reason: 'Checkout completed. Start a new session'
        })
      }
      this.$root.$emit('restart-session')
    }
  }
}
</script>

<style scoped lang="scss">
.result {
  display: flex;
  padding: 150px 110px;
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;

  align-items: center;
  flex-direction: column;
  justify-content: center;

  font: 1.5em/1.2 var(--font-extralight);
  text-align: center;

  strong {
    display: block;
    margin: 0 0 0.2em;

    font: normal 3.33em var(--font-extralight);
  }

  &__button {
    display: block;
    margin: 5em 0 0;
    position: relative;
    width: 16.5em;
    height: 4em;

    background: none;
    border: none;

    color: $white;
    font: 0.67em/4em var(--font-extrabold);
    letter-spacing: 0.05em;
    text-align: center;
    text-transform: uppercase;
    white-space: nowrap;

    &__text {
      display: block;
      position: relative;

      z-index: 2;
    }

    &__background {
      position: absolute;
      top: 0;
      left: 50%;
      width: 100%;
      height: 100%;

      background: var(--main-color);
      border-radius: 2em;
      transform: translate3d(-50%, 0, 0);
      z-index: 1;
    }
  }
}
</style>
