<template>
  <div id="the-nav" class="the-nav">
    <transition
      v-on:enter="onLinkTransitionEnter"
      v-on:leave="onLinkTransitionLeave"
      v-bind:css="false"
      mode="out-in">
      <router-link
        :to="{ name: 'home' }"
        v-if="(this.$route.name !== 'home' && $config.KIOSK_MODE !== 'brand')
          || (this.$route.name === 'blank' && $config.KIOSK_MODE === 'brand')"
        class="link-home">
        <div class="link-home__inner">
          Home
        </div><!-- .link-home__inner -->
      </router-link>
    </transition>

    <transition
      v-on:enter="onLinkTransitionEnter"
      v-on:leave="onLinkTransitionLeave"
      v-bind:css="false"
      mode="out-in">
      <router-link
        :to="{ name: backToHome==true? 'on_sale':  'blank' }"
        v-if="$config.KIOSK_MODE === 'brand' && this.$route.name !== 'home' && this.$route.name !== 'blank'"
        class="link-home link-home--close">
        <div class="link-home__inner link-home--close__inner">
          Close
        </div><!-- .link-home__inner -->
      </router-link>
    </transition>

    <ul>
      <li
        v-for="(link, index) in $config.NAV"
        v-if="isVisual && $route.name === 'home' && link.order < 0"
        v-bind:key="index"
        class="element element--large"  v-bind:class="{'has-image':isVisual && link.image}">
        <router-link
          :to="{ name: 'blank' }"
          class="link">
          <div
            v-bind:style="isVisual && link.image ? 'background-image: url(\'' + link.image + '\');' : ''"
            class="inner">
            <div class="title">
              {{ link.title }}
            </div><!-- .title -->

            <div class="text">
              {{ link.description }}
            </div><!-- .title -->

            <div
              v-if="link.label"
              class="button">
              <span class="button__text">
                {{ link.label }}
              </span>
              <span class="button__background"></span>
            </div><!-- .button -->
          </div><!-- .inner -->
        </router-link>
      </li>
      <li
        v-for="(link, index) in $config.NAV"
        v-if="!link.order || link.order > 0"
        v-bind:key="link.path"
        class="element"
         :class="{
           'has-image ': isVisual && link.image
         }"
        >
        <div
          @click="navigateTo(link)"
          v-bind:class="{ 'router-link-exact-active': isPathSelected(link.path, $route.fullPath, $route.path) }"
          class="link">
          <div

            class="inner"
            v-bind:style="isVisual && link.image ? 'background-image: url(\'' + link.image + '\');' :  (isVisual?'background-color: var(--main-color);':'')"

            >
            <div class="number">
              <div class="number__text">
                {{ String(index + 1).padStart(2, '0') }}
              </div><!-- .number__text -->

              <div class="number__line"></div>
            </div><!-- .number -->

            <div class="label">
              {{ $route.name !== 'home' ? link.label:link.title }}
            </div><!-- .label -->

            <div class="arrow">
              <div class="arrow__line"></div>
            </div><!-- .arrow -->
          </div><!-- .inner -->

               <lottie-container
            v-if="!isVisual || $route.name !== 'home'"
            v-bind:path="'block-default-intro'"
            v-bind:autoplay="false"
            v-bind:loop="false"
            ref="lottieBlockIntro"
            class="background-off"></lottie-container>

          <lottie-container
            v-if="!isVisual && $route.name === 'home'"
            v-bind:path="'block-default-outro'"
            v-bind:autoplay="false"
            v-bind:loop="false"
            ref="lottieBlockOutro"
            style="opacity: 0;"
            class="background-off"></lottie-container>

          <transition
            v-on:enter="onBackgroundTransitionEnter"
            v-on:leave="onBackgroundTransitionLeave"
            v-bind:css="false"
            mode="out-in">
            <lottie-container
              v-if="isPathSelected(link.path, $route.fullPath, $route.path)"
              v-bind:path="'block-default-intro'"
              v-bind:autoplay="false"
              v-bind:loop="false"
              ref="lottieBlockOn"
              class="background-on"></lottie-container>
          </transition>

          <!-- <lottie-container
            style="opacity: 0; transform: rotateY(180deg)"
            v-bind:path="'block-default-intro'"
            v-bind:autoplay="false"
            v-bind:loop="false"
            ref="lottieBlockOutro"></lottie-container> -->

        </div>
      </li>
    </ul>
  </div>
</template>

<script>
import LottieContainer from '@/components/LottieContainer'
import { TimelineLite, Power3 } from 'gsap/all'
import $ from 'jquery'
import {GSAP_ANIMATION} from '@/const/globals.js'

export default {
  name: 'TheNav',
  components: {
    LottieContainer
  },
  props: {
    isVisual: {
      type: Boolean,
      default: false
    }
  },

  data: function () {
    return {}
  },
  beforeRouteLeave (to, from, next) {
    // called when the route that renders this component is about to
    // be navigated away from.
    // has access to `this` component instance.
    console.log('NAVIGATING', to)
  },
  computed: {
    backToHome () {
      return !!this.$route.query.back_to_home
    },
    allNavConfigPaths () {
      return this.$config.NAV.map(link => link.path.toLowerCase())
    }
  },
  watch: {
    $route (to, from) {}
  },
  methods: {
    /**
     * Navigate to a route of nav
     */
    async navigateTo (route) {
      console.log(route)
      // let self = this
      console.log(this.$gsClient)
      if (this.$gsClient) {
        this.$gsClient.track(route.label, {
          name: route.label,
          path: route.path
        })
      }

      if (this.$route.fullPath === route.path && this.$route.path === '/brands') {
        return
      }

      if (route.path.includes(this.$route.path) && this.$route.path === '/brands') {
        await this.$router.push({
          path: '/blank'
        })
      }

      this.$router.push({path: route.path})
    },
    /**
     * Background transition enter
     */
    onBackgroundTransitionEnter: function (el, done) {
      var animation = $(el).data('lottieAnimation')
      animation.addEventListener('complete', function () {
        animation = null

        done()
      })
      animation.play()
    },

    /**
     * Background transition leave
     */
    onBackgroundTransitionLeave: function (el, done) {
      var animation = $(el).data('lottieAnimation')

      animation.addEventListener(
        'enterFrame',
        function () {
          if (animation.currentFrame === 0) {
            animation = null

            done()
          }
        },
        { once: true }
      )
      animation.setDirection(-1)
      animation.play()
    },

    /**
     * Link transition enter
     */
    onLinkTransitionEnter: function (el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.fromTo(
        container,
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          scale: 0,
          pointerEvents: 'none'
        },
        {
          alpha: 1,
          scale: 1,
          pointerEvents: 'none',
          clearProps: 'transform, opacity, pointerEvents',
          ease: Power3.easeInOut
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
     * Link transition leave
     */
    onLinkTransitionLeave: function (el, done) {
      // Selectors
      var container = $(el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container,
        GSAP_ANIMATION.duration,
        {
          alpha: 0,
          scale: 0,
          ease: Power3.easeInOut
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

    isPathSelected: function (linkPath, routeFullPath, routePath) {
      return (
        routeFullPath.toLowerCase() === linkPath.toLowerCase()
      ) || (
        routePath.toLowerCase() === linkPath.toLowerCase() && !this.allNavConfigPaths.includes(routeFullPath.toLowerCase())
      )
    }
  }
}
</script>

<style scoped lang="scss">
.the-nav {
  ul {
    display: flex;
    margin: 0;
    padding: 0;
    position: relative;
    width: 100%;
    height: 100%;

    align-content: stretch;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-between;
    list-style: none;
  }

  .element {
    display: block;
    overflow: hidden;
    position: relative;
    width: 100%;

    border-radius: 30px;
    flex-grow: 1;
    flex-shrink: 1;

    &--large {
      .inner {
        display: flex;
        padding: 30px;

        align-items: center;
        flex-direction: column;
        justify-content: center;

        text-align: center;
      }
    }
  }

  .link {
    display: block;
    position: relative;
    height: 100%;

    border-radius: 20px;

    color: $white;
  }

  .inner,
  .lottie-container,
  .background {
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
  }

  .inner {
    z-index: 2;

    > * {
      z-index: 2;
    }
  }

  .title {
    margin: 30px 0 0;

    font: 56px/1.3 var(--font-extrabold);
  }

  .text {
    margin: 0 auto;
    max-width: 570px;

    font-size: 22px;
    text-indent: 1.45;
  }

  .button {
    display: inline-block;
    margin: 15px 0 0;
    padding: 0 35px;
    position: relative;
    width: auto;
    height: 55px;

    background: transparent;
    border: none;
    flex-grow: 0;
    flex-shrink: 0;
    opacity: 1;

    color: $white;
    font: 18px/56px var(--font-semibold);
    letter-spacing: 0.1em;
    text-align: center;
    text-transform: uppercase;

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
      border-radius: 28px;
      transform: translate3d(-50%, 0, 0);
      z-index: 1;
    }
  }

  .number {
    position: absolute;
    top: 20px;
    left: 20px;

    transition: opacity 0.1s linear 0s;

    font: 16px/1 var(--font-semibold);

    &__line {
      display: block;
      position: absolute;
      bottom: -6px;
      left: 0;
      width: 100%;
      height: 3px;

      background: $white;
      opacity: 0.5;
      transform-origin: 0 0;
    }
  }

  .label {
    display: flex;
    position: absolute;
    top: 0;
    right: 40px;
    left: 40px;
    height: 100%;

    flex-direction: column;
    justify-content: center;
    transition: opacity 0.1s linear 0s;

    font: 1.4em/1.21 var(--font-extrabold);
  }

  .arrow {
    position: absolute;
    right: 20px;
    bottom: 20px;
    width: 44px;
    height: 44px;

    background: rgba($white, 0.3);
    border-radius: 50%;
    transition: opacity 0.2s ease-in-out, transform 0.2s ease-in-out;

    &__line {
      display: block;
      position: absolute;
      top: 50%;
      left: 50%;
      width: 9px;
      height: 2px;

      transform: translate3d(-50%, -50%, 0);

      &:before,
      &:after {
        display: block;
        position: absolute;
        top: 50%;
        left: 50%;
        width: 100%;
        height: 100%;

        background: $white;
        border-radius: 25%;
        content: "";
        transform-origin: 100% 50%;
      }
      &:before {
        transform: translate3d(-50%, -50%, 0) rotateZ(45deg);
      }
      &:after {
        transform: translate3d(-50%, -50%, 0) rotateZ(-45deg);
      }
    }
  }

  .link-home {
    overflow: hidden;
    position: fixed;
    top: 30px;
    right: 30px;
    width: 3.5em;
    height: 3.5em;

    background-color: rgba($black, 0.1);
    border-radius: 50%;
    z-index: 20;

    text-indent: -999em;

    &__inner {
      position: relative;
      width: 100%;
      height: 100%;

      background-color: rgba($white, 0.1);
      background-image: url("~@/assets/img/icon-home.svg");
      background-position: center;
      background-repeat: no-repeat;
      background-size: 1em;
      border-radius: inherit;
    }

    &--close {
      &__inner {
        background: none;

        &:before,
        &:after {
          display: block;
          position: absolute;
          top: 50%;
          left: 50%;
          width: 60px;
          height: 2px;

          background: $white;
          content: "";
        }
        &:before {
          transform: translate3d(-50%, -50%, 0) rotateZ(45deg);
        }
        &:after {
          transform: translate3d(-50%, -50%, 0) rotateZ(-45deg);
        }
      }
    }
  }

  &--sidebar {
    position: absolute;
    top: 0;
    right: 30px;
    bottom: 200px;
    left: 30px;

    .element {
      margin: 20px 0 0;
    }

    .link {
      // background: rgba($white, 0.05);
    }

    /deep/ .background-off path {
      fill: rgba($white, 0.05);
    }

    /deep/ .background-on path {
      fill: var(--navs-color);
    }

    .number,
    .arrow {
      opacity: 0.2;
    }

    .label {
      opacity: 0.3;
    }

    .router-link-exact-active {
      .background {
        background-color: var(--main-color);
      }
      .number,
      .label {
        opacity: 1;
        transition-delay: 0.15s;
      }

      .arrow {
        opacity: 0;
        transform: translate3d(10px, 0, 0);
      }
    }

    &--fullheight {
      bottom: 20px;
    }
  }

  &--large {
    position: fixed;
    top: 135px;
    right: 70px;
    bottom: 105px;
    left: 980px;

    ul {
      margin: 0 -15px;
      width: auto;
    }

    .element {
      margin: 0 15px 30px;
      width: calc(50% - 30px);

      &--large {
        width: calc(100% - 30px);

        .inner:before {
          display: block;
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;

          background: $black;
          opacity: 0.34;
          content: "";
          z-index: 1;
        }
      }
    }

    .background {
      background-color: var(--main-color);
    }

    .number {
      top: 30px;
      left: 30px;
    }

    .label {
      right: 60px;
      left: 60px;

      font-size: 50px;
      line-height: 1.12;
    }

    .arrow {
      right: 30px;
      bottom: 30px;
    }

    .element.has-image {
      lottie-container {
        display: none;
      }
      .inner {
        background-color: $white;
        background-position: center;
        background-repeat: no-repeat;
        background-size: cover;
      }

      .label {
        display: block;
        top: 10%;
        right: 40px;
        left: 40px;
        height: auto;

        mix-blend-mode: difference;
        opacity: 0.7;

        font: 22px/1.2 var(--font-extrabold);
        letter-spacing: 0.05em;
        text-transform: uppercase;
      }

      .arrow {
        right: 20px;
        bottom: 20px;
        background: rgba($white, 0.2);
        mix-blend-mode: difference;
        &__line {
          &:before,
          &:after {
            background: $black;
          }
        }
      }

      .number {
        display: none;
      }
    }
  }

  &--round {
    .element {
      // margin: 0 30px 30px;

      // &:nth-child(2n+1) {
      //   margin-left: 0;
      // }
      // &:nth-child(2n+2) {
      //   margin-right: 0;
      // }
    }

    // .inner {
    //   top: 50%;
    //   height: auto;

    //   background-position: center 25%;
    //   background-size: 70%;
    //   border-radius: 50%;
    //   transform: translate3d(0, -50%, 0);

    //   &:before {
    //     display: block;
    //     padding-top: 100%;
    //     content: '';
    //   }
    // }

    .label {
      display: none;
      top: auto;
      bottom: 15%;

      text-align: center;
    }

    .number,
    .arrow {
      display: none;
    }
  }
}
</style>
