<template>
  <div id="screen-home-background-image" :class="{'home screen--home--with-background-visible': isBackGroundvisible}" class="screen screen--home"  style="opacity: 0;">
    <div>
      <screen-product-video v-if="isVideo()(videoOrImage)" v-bind:video-src="videoOrImage">
      </screen-product-video>

      <screen-product-image v-if="isImage()(videoOrImage)" v-bind:image-src="videoOrImage">
      </screen-product-image>
    </div>
  </div>
</template>

<script>
import {TimelineLite, Power3} from 'gsap/all'
import $ from 'jquery'
import {GSAP_ANIMATION} from '@/const/globals.js'
import ScreenProductImage from './ScreenProductImage.vue'
import ScreenProductVideo from './ScreenProductVideo.vue'
import { mapGetters, mapMutations } from 'vuex'

export default {
  name: 'ScreenHomeVideoImageBackground',
  components: { ScreenProductVideo, ScreenProductImage },
  data () {
    return {
      videoOrImage: null,
    }
  },
  computed: {

    isBackGroundvisible() {
      return this.$config.BACKGROUND_IMAGE_TOP;
    }
  },
  created: function () {
    this.videoOrImage = this.$config.BACKGROUND_VIDEO_OR_IMAGE
    // Set store logo
    this.storeLogo = this.$config.STORE_LOGO

    // Call transition enter on next tick
    this.$nextTick(this.transitionEnter)

    // Events
    this.$parent.$on('transition-leave', this.onTransitionLeave)
  },
  destroyed: function () {
    // Events
    this.$parent.$off('transition-leave', this.onTransitionLeave)
  },
  mounted: function () {
    // Remove buggy sidebar on transitionleave event
    let sidebar = document.querySelector('#the-sidebar')

    if (sidebar) {
      sidebar.remove()
    }
  },
  methods: {
    ...mapGetters('products', [ 'isImage', 'isVideo']),
    /**
     * Screen transition enter
     */
    transitionEnter: function () {
      // Selectors
      var self = this
      var container = $(this.$el)

      // Before animation
      container.css({opacity: ''})

      this.$root.$emit('block-pointer', true)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(
        container.find('.store-logo'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0
        },
        GSAP_ANIMATION.tween
      )

      tl.call(function () {
        self.$root.$emit('block-pointer', false)
      })

      tl.call(function () {
        tl.kill()

        tl = null
        container = null
      })

      tl.play()
    },

    /**
     * Screen transition leave
     */
    onTransitionLeave: function (el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container.find('.store-logo'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        GSAP_ANIMATION.tween
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
     * Calculate logo ratio
     */
    setStoreLogoRatio: function () {
      var img = this.$refs.storeLogoImg
      if (img) {
        var ratio = img.naturalHeight / img.naturalWidth

        if (ratio < 0.33) {
          this.storeLogoRatio = 'horizontal'
        } else if (ratio < 0.66) {
          this.storeLogoRatio = 'rectangle'
        } else if (ratio < 1.33) {
          this.storeLogoRatio = 'square'
        } else {
          this.storeLogoRatio = 'vertical'
        }
      }

      img = null
    },

    /**
     * Hold logo
     */
    logoHold: function () {
      this.$root.$emit('start-hard-refresh')
    },

    /**
     * Release logo
     */
    logoRelease: function () {
      this.$root.$emit('stop-hard-refresh')
    },
  }
}
</script>

<style scoped lang="scss">
.screen--home {
  left: 0;

  background: transparent !important;
  &--with-background-visible{
    .catcher{
      display: none;
    }
    .swipe-animation{
      top: 775px;
    }
  }
}

.store-logo {
  position: absolute;
  bottom: 510px;
  left: 50%;

  object-fit: contain;
  object-position: center bottom;
  transform: translate3d(-50%, 0, 0);

  &--horizontal {
    width: 1000px;
    height: 160px;
  }

  &--rectangle {
    width: 600px;
    height: 160px;
  }

  &--square {
    width: 320px;
    height: 320px;
  }

  &--vertical {
    width: 300px;
    height: 400px;
  }
}


</style>
