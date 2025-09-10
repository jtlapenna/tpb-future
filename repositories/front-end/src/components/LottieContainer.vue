<template>
  <div
    v-bind:class="'lottie-container--' + path"
    class="lottie-container"></div>
</template>

<script>
import addRemovedHook from 'vue-removed-hook-mixin'
import lottie from 'lottie-web'
import $ from 'jquery'

export default {
  name: 'LottieContainer',
  props: {
    path: {
      type: String,
      required: true
    },
    autoplay: {
      type: Boolean,
      default: false
    },
    loop: {
      type: Boolean,
      default: false
    },
    frame: {
      type: String,
      default: 'firstFrame'
    }
  },
  mixins: [addRemovedHook],
  data () {
    return {
      animation: null
    }
  },
  removed: function () {
    this.animation.destroy()
    this.animation = null

    $(this.$el).data('lottieAnimation', 0)
  },
  mounted: function () {
    var self = this

    // Load lottie animation
    this.animation = lottie.loadAnimation({
      container: this.$el,
      renderer: 'svg',
      loop: this.loop,
      autoplay: this.autoplay,
      path: '/static/anim/' + this.path + '.json',
      rendererSettings: {
        progressiveLoad: true,
        preserveAspectRatio: 'none'
      }
    })

    if (this.$config.FAST_ANIMATION) {
      this.animation.setSpeed(2)
    }

    // Trigger an event when animation is loaded
    this.animation.addEventListener('DOMLoaded', function () {
      if (self.frame === 'lastFrame') {
        self.animation.goToAndStop(self.animation.lastFrame, true)
      }

      self.$emit('lottie-ready')
    })

    $(this.$el).data('lottieAnimation', this.animation)
  }
}
</script>

<style scoped lang="scss">
</style>
