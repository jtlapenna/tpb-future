<template>
  <transition
    appear
    v-on:enter="onTransitionEnter"
    v-on:leave="onTransitionLeave"
    v-bind:css="false"
    mode="out-in">
    <div
    id="the-brand-slideshow"
    v-touch:swipe="onSwipe"
    v-bind:class="{ 'the-brand-slideshow--is-active' : $route.name === 'blank' }"
    class="the-brand-slideshow">
      <div class="slideshow">
        <transition-group
          name="slides"
          class="slides"
          tag="div"
          v-bind:css="false"
          v-on:enter="onTransitionSlideEnter"
          v-on:leave="onTransitionSlideLeave">

          <div
            v-for="(slide, index) in slides"
            v-show="currentPage === index+1"
            v-bind:key="index"
            v-bind:class="'slide--' + slide.layout"
            class="slide">
            <div v-if="slide.background" class="slide__background">
              <video
                v-if="slide.background.indexOf('.mp4') !== -1"
                v-bind:src="slide.background"
                class="slide__background__media"
                muted
                loop></video>

              <img
                v-if="slide.background.indexOf('.mp4') === -1"
                v-bind:src="slide.background"
                class="slide__background__media" />
            </div><!-- slide__background -->

            <div class="slide__inner">
              <div class="slide__texts">
                <div
                  v-for="(text, textIndex) in slide.texts"
                  v-bind:key="textIndex"
                  v-bind:class="[slide.layout === 'images' ? 'slide__text--large' : '', 'slide__text--' + text.position]"
                  class="slide__text">
                  <h2 class="slide__text__title">
                    {{ text.title }}
                  </h2>

                  <div v-if="text.body" class="slide__text__body" v-html="text.body.replace(/\n/g, '<br />')">
                  </div><!-- .slide__text__body -->
                </div><!-- .slide__text -->
              </div><!-- .slide__texts -->

              <div class="slide__images">
                <div
                  v-for="(image, imageIndex) in slide.images"
                  v-if="image.asset"
                  v-bind:key="imageIndex"
                  v-bind:style="(slide.layout === 'images' ? 'left: ' + image.coord_x + '%; top: ' + image.coord_y + '%;' : '')"
                  v-bind:class="slide.texts[imageIndex] ? 'slide__image--' + slide.texts[imageIndex].position : ''"
                  class="slide__image">
                  <video
                    v-if="image.asset.url && image.asset.url.indexOf('.mp4') !== -1 "
                    v-bind:src="image.asset.url"
                    class="slide__image__media"
                    muted
                    loop></video>

                  <img
                    v-if="image.asset.url.indexOf('.mp4') === -1"
                    v-bind:src="image.asset.url"
                    class="slide__image__media" />
                </div><!-- .slide__image -->
              </div><!-- .slide__images -->

              <div class="slide__dots">
                <div
                  v-for="(dot, dotIndex) in slide.dots"
                  v-bind:key="dotIndex"
                  v-bind:style="'left: ' + dot.coord_x + '%; top: ' + dot.coord_y + '%;'"
                  class="slide__dot">
                  <router-link :to="{ path: dot.link }">
                    <div class="slide__dot__background"></div>

                    <div class="slide__dot__icon"></div>

                    <div class="slide__dot__waves">
                      <div class="slide__dot__wave"></div>
                      <div class="slide__dot__wave"></div>
                      <div class="slide__dot__wave"></div>
                    </div><!-- .slide__dot__waves -->
                  </router-link>
                </div><!-- .slide__dot -->
              </div><!-- .slide__dots -->

              <div class="slide__shares">
                <div
                  v-for="(share, shareIndex) in slide.shares"
                  v-bind:key="shareIndex"
                  v-bind:style="'left: ' + share.coord_x + '%; top: ' + share.coord_y + '%;'"
                  class="slide__share">
                  <share-button v-bind:productId="share.productId"></share-button>
                </div><!-- .slide__dot -->
              </div><!-- .slide__shares -->
            </div><!-- .slide__inner -->
          </div><!-- .slide -->
        </transition-group><!-- .slides -->

        <div class="pagination">
          <ul class="pages">
            <li
              v-for="n in slidesCount"
              v-bind:key="n"
              v-on:click="switchSlides(n, false);"
              v-bind:class="{ 'page--is-active': n === currentPage }"
              class="page">
              <div class="page__inner">
                {{ n }}
              </div>
            </li>
          </ul>
        </div><!-- .pagination -->
      </div><!-- .slideshow -->
    </div>
  </transition>
</template>

<script>
import ShareButton from '@/components/ShareButton'
import {TimelineLite, TweenMax, Power2, Power3} from 'gsap/all'
import $ from 'jquery'
import {GSAP_ANIMATION} from '@/const/globals.js'

export default {
  name: 'the-brand-slideshow',
  components: {
    ShareButton
  },
  data () {
    return {
      slides: [],
      swipeDirection: null,
      switchWait: false,
      currentPage: -1,
      cycleInterval: null
    }
  },
  computed: {
    slidesCount: function () {
      return this.slides.length
    }
  },
  created: function () {
    var tempSlides = []

    // Create slides
    this.$config.SLIDES.forEach(function (asset) {
      var dots = []
      var shares = []

      asset.dots.forEach(function (dot) {
        if (dot.link.indexOf('share') > -1) {
          dot.productId = dot.link.match(/\/share\/(\d+)/i)[1]
          shares.push(dot)
        } else {
          dots.push(dot)
        }
      })

      var slide = {
        layout: 'images',
        code: Number(asset.code),
        background: asset.asset ? asset.asset.url : null,
        texts: [
          {
            title: asset.text,
            body: asset.secondary_text,
            position: (asset.text_position ? asset.text_position.replace('rigth', 'right') : asset.text_position)
          }
        ],
        images: asset.pictures_in_pictures,
        dots: dots,
        shares: shares
      }

      if (asset.secondary_text !== null && asset.asset === null) {
        slide.layout = 'columns'
      } else if (asset.secondary_text !== null && asset.asset !== null) {
        slide.layout = 'float'
      }

      tempSlides.push(slide)
    })

    // Order slides
    tempSlides = tempSlides.sort(function (a, b) {
      if (a.code < b.code) {
        return -1
      } else if (a.code > b.code) {
        return 1
      }

      return 0
    })

    // Merge slides with same code
    var mergedSlides = []
    var previousSlide = null
    tempSlides.forEach(function (slide) {
      if (previousSlide === null) {
        // First pass, set previous slide
        previousSlide = slide
      } else if (previousSlide.code === slide.code) {
        // Code matches, merge slides
        previousSlide.texts = previousSlide.texts.concat(slide.texts)
        previousSlide.images = previousSlide.images.concat(slide.images)
        previousSlide.dots = previousSlide.dots.concat(slide.dots)
        previousSlide.shares = previousSlide.shares.concat(slide.shares)
      } else {
        // Save previous slide and continue
        mergedSlides.push(previousSlide)
        previousSlide = slide
      }
    })
    // Add last slide
    mergedSlides.push(previousSlide)

    this.slides = mergedSlides

    // this.$root.$on('app-swipe', this.onSwipe)
  },
  destroyed: function () {
    // Events
    this.$root.$off('app-swipe', this.onSwipe)
  },
  mounted: function () {
    var self = this

    // Auto rotate slideshow when active on blank screen
    // if (this.$route.name === 'blank') {
    //   clearInterval(this.cycleInterval)
    //   this.cycleInterval = setInterval(this.cycleSlides, 4000)
    // }

    // Launch slide enter animation after 1s
    setTimeout(function () {
      self.currentPage = 1
    }, 1000)
  },
  watch: {
    '$route': function () {
      var self = this

      // If route changes (slideshow goes in background) stop auto rotate
      this.stopCycle()

      // Pause/play video
      if (this.$route.name !== 'blank') {
        $(this.$el).find('.slide:visible video').each(function () {
          this.pause()
          self.$root.$emit('video-pause')
        })
      } else if (this.$route.name === 'blank') {
        $(this.$el).find('.slide:visible video').each(async function () {
          await this.play()
          self.$root.$emit('video-play')
        })
      }
    }
  },
  methods: {
    /**
     * Slideshow transition enter
     */
    onTransitionEnter: function (el, done) {
      // Selectors
      var self = this
      var container = $(el)

      this.$root.$emit('block-pointer', true)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerFrom(
        container.find('.page'),
        GSAP_ANIMATION.duration,
        {
          scaleY: 0,
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.call(function () {
        self.$root.$emit('block-pointer', false)

        tl.kill()

        tl = null
        container = null

        done()
      })

      tl.play()
    },

    /**
     * Slideshow transition leave
     */
    onTransitionLeave: function (el, done) {
      // Selectors
      var container = $(el)

      // Before animation
      container.find('.slideshow').css({width: container.find('.slideshow').width()})

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container,
        GSAP_ANIMATION.duration,
        {
          width: 0,
          ease: Power3.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.call(function () {
        tl.kill()

        tl = null
        container = null

        done()
      }, null, null, '+=0.25')

      tl.play()
    },

    /**
     * Slide transition enter
     */
    onTransitionSlideEnter: function (el, done) {
      // Selectors
      var self = this
      var container = $(el)
      var slides = $('.slide:visible')
      var forward = (container.index() < slides.not(container).index())
      if (self.swipeDirection !== null) {
        forward = self.swipeDirection === 'swiperight'
      }

      // Before animation
      container.css({zIndex: 2})
      container.find('.slide__background').css({width: container.find('.slide__background').width()})
      container.find('.slide__inner').css({width: container.find('.slide__inner').width()})

      this.$root.$emit('block-pointer', true)

      if (forward) {
        container.css({right: 'auto', left: 0})
      } else {
        container.css({right: '', left: ''})
      }

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.from(
        container,
        GSAP_ANIMATION.duration,
        {
          width: 0,
          clearProps: 'width',
          ease: Power3.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.from(
        container.find('.slide__background'),
        GSAP_ANIMATION.duration,
        {
          x: 300,
          clearProps: 'transform',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.call(function () {
        if (container) {
          container.find('.slide__background video').each(async function () {
            this.currentTime = 0
            await this.play()
            self.$root.$emit('video-play')
          })
        }
      }, null, null, 0)

      if (container.hasClass('slide--images')) {
        tl.staggerFrom(
          container.find('.slide__image'),
          GSAP_ANIMATION.duration,
          {
            alpha: 0,
            y: 30,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          GSAP_ANIMATION.tween,
          GSAP_ANIMATION.append
        )
      } else {
        tl.staggerFrom(
          container.find('.slide__image__media'),
          GSAP_ANIMATION.duration,
          {
            scale: 1.2,
            clearProps: 'transform',
            ease: Power3.easeOut
          },
          GSAP_ANIMATION.tween,
          GSAP_ANIMATION.append
        )
      }

      tl.call(function () {
        if (container) {
          container.find('.slide__image video').each(async function () {
            this.currentTime = 0
            await this.play()
            self.$root.$emit('video-play')
          })
        }
      }, null, null, 0.7)

      tl.from(
        container.find('.slide__text--large'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 100,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.staggerFrom(
        container.find('.slide__text__title'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.slide__text__body'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 30,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.staggerFrom(
        container.find('.slide__dot'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          scale: 0.75,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween,
        GSAP_ANIMATION.append
      )

      tl.from(
        container.find('.share-button__background'),
        GSAP_ANIMATION.duration,
        {
          width: 0,
          clearProps: 'width',
          ease: Power2.easeInOut
        },
        GSAP_ANIMATION.tween
      )

      tl.fromTo(
        container.find('.share-button__text'),
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          y: 20
        },
        {
          alpha: 1,
          y: 0,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        GSAP_ANIMATION.tween
      )

      tl.call(function () {
        self.$root.$emit('block-pointer', false)

        if (container) {
          container.css({zIndex: ''})
          container.find('.slide__background, .slide__inner').css({width: ''})
        }

        self.swipeDirection = null

        tl.kill()

        tl = null
        container = null
        slides = null

        done()
      })

      tl.play()
    },

    /**
     * Slide transition leave
     */
    onTransitionSlideLeave: function (el, done) {
      // Selectors
      var self = this
      var container = $(el)
      var slides = $('.slide:visible')
      var forward = (slides.length > 1)
      if (self.swipeDirection !== null) {
        forward = self.swipeDirection === 'swiperight'
      }

      container.css({zIndex: ''})

      if (forward) {
        var toX = 150
      } else {
        toX = -150
      }

      TweenMax.to(
        container,
        GSAP_ANIMATION.duration,
        {
          x: toX,
          clearProps: 'transform',
          ease: Power3.easeInOut,
          onComplete: function () {
            container.find('video').each(function () {
              this.pause()
              self.$root.$emit('video-pause')
            })

            container = null
            slides = null

            done()
          }
        }
      )
    },

    /**
     * Swipe handler
     */
    onSwipe: function (e) {
      if (this.$route.name === 'blank' && (e === 'left' || e === 'right')) {
        // User takes control, stop auto rotate
        this.stopCycle()

        this.swipeDirection = e

        if (e === 'right') {
          this.cycleSlides(false)
        } else {
          this.cycleSlides(true)
        }
      }
    },

    /**
     * Switch to next slide
     * @param  {Boolean} next
     */
    cycleSlides: function (next = true) {
      var newPage = this.currentPage

      if (next) {
        newPage++
      } else {
        newPage--
      }

      if (newPage > this.slidesCount) {
        newPage = 1
      } else if (newPage < 1) {
        newPage = this.slidesCount
      }

      this.currentPage = newPage
    },

    /**
     * Stop auto rotate
     */
    stopCycle: function () {
      // clearInterval(this.cycleInterval)
    },

    /**
     * Switch to given slide
     * @param  {Integer} index New slide index
     */
    switchSlides: function (index) {
      this.currentPage = index
      this.stopCycle()
    }
  }
}
</script>

<style scoped lang="scss">
  .the-brand-slideshow {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;

    // background: $bluecharcoal;
    overflow: hidden;
    z-index: 2;

    &:after {
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      background: rgba($bluecharcoal, 0.85);
      content: '';
      opacity: 1;
      pointer-events: auto;
      transition: opacity 0.4s ease 0s;
    }

    &--is-active {
      &:after {
        opacity: 0;
        pointer-events: none;
        transition-delay: 0.7s;
      }

      .slideshow {
        opacity: 1;
        transition-delay: 0.7s;
      }
    }
  }

  .slideshow {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    opacity: 0;
    transition-delay: 0s;
    transition-duration: 0.4s;
    transition-property: opacity;
    transition-timing-function: ease;
  }

  .slides {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    z-index: 1;
  }

  .slide {
    position: absolute;
    top: 0;
    right: 0;
    width: 100%;
    height: 100%;

    background: $white;
    overflow: hidden;
    z-index: 1;

    &__background {
      position: absolute;
      top: 0;
      right: 0;
      width: 100%;
      height: 100%;

      z-index: 1;

      &__media {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;

        object-fit: cover;
      }
    }

    &__inner {
      position: absolute;
      top: 0;
      right: 0;
      width: calc( 100% - 320px);
      height: 100%;

      z-index: 2;
    }

    &__text {
      position: relative;

      z-index: 1;

      &__title {
        margin: 0;
      }
    }

    &__dot {
      margin: -28px 0 0 -28px;
      position: absolute;
      width: 56px;
      height: 56px;

      border-radius: 50%;

      z-index: 3;

      &__background {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;

        background: var(--buttons-color);
        border-radius: 50%;
        box-shadow: 0 0 20px 5px rgba($black, 0.4);
        z-index: 2;
      }

      &__icon {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;

        z-index: 3;

        &:before,
        &:after {
          display: block;
          margin: -1px 0 0 -6px;
          position: absolute;
          top: 50%;
          left: 50%;
          width: 12px;
          height: 2px;

          background: $white;
          content: '';
        }

        &:after {
          transform: rotateZ(90deg);
        }
      }

      &__waves {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 300%;
        height: 300%;

        transform: translate3d(-50%, -50%, 0);
        z-index: 1;
      }

      &__wave {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;

        border-radius: 50%;
        animation: wave-pulse 5s linear 0s infinite normal none;
        transform: scale(0);

        &:before {
          display: block;
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;

          border-radius: 50%;
          background: var(--buttons-color);
          content: '';
          opacity: 0.4;
        }

        &:nth-child(1) {
          animation-delay: 2s;
        }
        &:nth-child(2) {
          animation-delay: 2.8s;
        }
        &:nth-child(3) {
          animation-delay: 3.6s;
        }
      }
    }

    &__share {
      position: absolute;

      transform: translate3d(-50%, -50%, 0);
    }

    &--columns {
      .slide__text {
        display: flex;
        padding: 50px 100px;
        position: absolute;
        width: 50%;
        height: 50%;

        align-items: flex-start;
        background: $white;
        flex-direction: column;
        justify-content: center;

        &__title {
          color: var(--secondary-color) !important;
          font: 70px/1.1 var(--font-extrabold);

          &:after {
            display: block;
            margin: 30px 0 50px;
            width: 50px;
            height: 11px;

            background: rgba($black, 0.08);
            content: '';
          }
        }

        &__body {
          color: rgba($black, 0.4);
          font-size: 22px;
          line-height: 1.5;
        }

        &[class*="left"] {
          left: 0;
        }

        &[class*="right"] {
          right: 0;
        }

        &[class*="top"] {
          top: 0;
        }

        &[class*="bottom"] {
          bottom: 0;
        }

        &[class*="center"] {
          top: 0;
          height: 100%;

          .slide__text__title {
            font-size: 100px;
          }
          .slide__text__body {
            font-size: 28px;
          }
        }
      }

      .slide__image {
        position: absolute;
        width: 50%;
        height: 50%;

        overflow: hidden;

        &__media {
          display: block;
          width: 100%;
          height: 100%;

          object-fit: cover;
        }

        &[class*="left"] {
          right: 0;
        }

        &[class*="right"] {
          left: 0;
        }

        &[class*="top"] {
          top: 0;
        }

        &[class*="bottom"] {
          bottom: 0;
        }

        &[class*="center"] {
          top: 0;
          height: 100%;
        }
      }
    }

    &--images {
      .slide__text {
        position: absolute;
        right: 130px;
        left: 130px;

        color: $white;
        font: 160px/1.125 var(--font-extrabold);
        text-align: center;

        &.slide__text--top-left,
        &.slide__text--top-center,
        &.slide__text--top-right {
          top: 100px;
        }

        &.slide__text--left-center,
        &.slide__text--center,
        &.slide__text--right-center {
          top: 50%;

          transform: translate3d(0, -50%, 0);
        }

        &.slide__text--bottom-left,
        &.slide__text--bottom-center,
        &.slide__text--bottom-right {
          bottom: 100px;
        }

        &.slide__text--top-left,
        &.slide__text--left-center,
        &.slide__text--bottom-left {
          text-align: left;
        }

        &.slide__text--top-center,
        &.slide__text--center,
        &.slide__text--bottom-center {
          text-align: center;
        }

        &.slide__text--top-right,
        &.slide__text--right-center,
        &.slide__text--bottom-right {
          text-align: right;
        }
      }

      .slide__image {
        position: absolute;
        width: 30%;

        box-shadow: -30px 60px 90px 0 rgba($black, 0.6);

        &__media {
          display: block;
          width: 100%;
          height: auto;
        }
      }
    }

    &--float {
      .slide__text {
        display: flex;
        position: absolute;
        width: 600px;
        height: 430px;

        align-items: flex-start;
        flex-direction: column;
        justify-content: center;

        &__title {
          margin: 0 0 20px;

          font: 70px/1.1 var(--font-extrabold);
        }

        &__body {
          font-size: 22px;
          line-height: 1.5;
        }

        &[class*="left"] {
          left: 200px;

          align-items: flex-end;

          text-align: right;
        }

        &[class*="right"] {
          right: 200px;
        }

        &[class*="top"] {
          top: 100px;
        }

        &[class*="bottom"] {
          bottom: 100px;
        }

        &[class*="center"] {
          margin-top: -215px;
          top: 50%;
        }
      }

      .slide__image {
        position: absolute;
        width: 500px;
        height: 430px;

        overflow: hidden;

        &__media {
          display: block;
          width: 100%;
          height: 100%;

          object-fit: contain;
        }

        &[class*="left"] {
          right: 200px;
        }

        &[class*="right"] {
          left: 200px;
        }

        &[class*="top"] {
          top: 100px;
        }

        &[class*="bottom"] {
          bottom: 100px;
        }

        &[class*="center"] {
          margin-top: -215px;
          top: 50%;
        }
      }
    }
  }

  .pagination {
    position: absolute;
    bottom: 50px;
    left: 320px;
    right: 0;

    z-index: 2;
  }

  .pages {
    display: flex;
    margin: 0;
    padding: 0;

    flex-direction: row;
    list-style: none;
    justify-content: center;
  }

  .page {
    display: block;
    margin: 0 5px;
    padding: 0;
    position: relative;
    width: 50px;
    height: 5px;

    background: rgba($black, 0.3);

    color: transparent;

    &:before {
      display: block;
      position: absolute;
      top: -25px;
      right: -5px;
      bottom: -25px;
      left: -5px;

      background: transparent;
      content: '';
      z-index: 2;
    }

    &__inner {
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      z-index: 1;

      &:before,
      &:after {
        display: block;
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;

        content: '';
      }
      &:before {
        background: rgba($white, 0.3);
      }
      &:after {
        background: var(--main-color);
        transform: scaleX(0);
        transform-origin: 0 0;
        transition: transform 0.3s cubic-bezier(1, 0, 0, 1);
      }
    }

    &--is-active .page__inner:after {
      transform: scaleX(1);
    }
  }

  /deep/ .share-button .share-button__waves {
    display: block;
  }
</style>
