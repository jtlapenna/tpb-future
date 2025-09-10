<template>
  <div class="container">
    <div class="inner-container">
       <span class="text">
      You now have an
    </span>
      <div class="button-container">
        <active-cart-button v-bind:size="activeButtonSize" v-bind:info-mode="true"></active-cart-button>
      </div>
    </div>
    <span class="small-text">
      Keep shopping on any device.
    </span>
    <span class="medium-text">
      Once finished, close your cart <br>
      to submit your order.
    </span>
  </div>

</template>

<script>
import ActiveCartButton from './ActiveCartButton.vue'
import $ from 'jquery'
import { Power3, TimelineLite } from 'gsap/all'
import { mapMutations } from 'vuex'

export default {
  name: 'ActiveCartKeepShopping',
  components: { ActiveCartButton },
  data () {
    return {
      timeouts: [],
      activeButtonSize: 'small'
    }
  },
  computed: {},
  watch: {},
  filters: {},
  created: function () {
    this.$nextTick(this.transitionEnter)

    // Events
    this.$on('transition-leave', this.onTransitionLeave)
  },
  mounted: function () {
    this.$root.$emit('reset-session')
    this.resetActiveCartSession()
    this.timeouts.push(setTimeout(() => {
      this.$router.push({name: 'home'});
    }, 15000))

    this.timeouts.push(setTimeout(() => {
      $('.inner-container .text').addClass('animate')
      $('.button-container').addClass('animate')
      this.activeButtonSize = 'tiny'
    }, 2000))

    this.timeouts.push(setTimeout(() => {
      $('.small-text').addClass('animate')
    }, 2000))

    this.timeouts.push(setTimeout(() => {
      $('.small-text').addClass('second-animate')
    }, 4000))

    this.timeouts.push(setTimeout(() => {
      $('.medium-text').addClass('animate')
    }, 4000))
  },
  destroyed: function() {
    this.$off('transition-leave', this.onTransitionLeave)
    this.timeouts.forEach((timeout) => {
      clearTimeout(timeout)
    })
  },
  methods: {
    ...mapMutations('cart', ['resetActiveCartSession']),
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
          y: 60,
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
    }
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
}

.text {
  font: 3.5em/1 var(--font-extralight);
  position: relative; /* Required for 'top' to take effect */
  transition: all 1s ease-in-out;;
  transform: translateY(0);

  &.animate {
    font: 1.5em/1 var(--font-extralight);
    transform: translateY(-15rem);
  }
}

.small-text {
  opacity: 0; /* Start fully transparent */
  transform: translateY(20px); /* Start slightly below */
  transition: all 1s ease-in-out, transform 1s ease-in-out;

  &.animate {
    font: 2.5em/1 var(--font-extralight);
    opacity: 1; /* Fully visible */
    transform: translateY(0); /* Move to the final position */
  }

  &.second-animate {
    font: 1.5em/1 var(--font-extralight);
    opacity: 1; /* Fully visible */
    transform: translateY(-14rem); /* Move to the final position */
  }
}

.medium-text {
  font: 2em/1 var(--font-extralight);
  opacity: 0; /* Start fully transparent */
  transform: translateY(20px); /* Start slightly below */
  transition: all 1s ease-in-out, transform 1s ease-in-out;
  text-align: center;

  &.animate {
    font: 2.5em/1 var(--font-extralight);
    opacity: 1; /* Fully visible */
    transform: translateY(0); /* Move to the final position */
  }
}
.button-container {
  transition: all 1s ease-in-out;;
  transform: translateY(0);
  margin-left: 3rem;
  margin-top: 0.3rem;

  &.animate {
    transform: translateY(-15rem);
    margin-left: 1rem;
  }
}
</style>
