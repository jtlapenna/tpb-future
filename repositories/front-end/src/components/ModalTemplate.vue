<template>
    <div class="modal">
      <div class="modal__container">
        <div class="modal__inner">
          <slot></slot>
        </div><!-- .modal__inner -->
      </div><!-- .modal__container -->
      <div class="modal__background"></div>
    </div><!-- .modal -->
</template>

<script>
import $ from 'jquery'

export default {
  name: 'ModalTemplate',
  mounted: function () {
    // Keyboard
    // $('.input-osk').onScreenKeyboard({
    //   'rewireReturn': false
    // })
    $('.input-osk').on('keyup', function (e) {
      this.dispatchEvent(new Event('input'))
    })

    // Hide keyboard
    $('#osk-container:visible .osk-hide').click()
    $('#osk-container-number').fadeOut('fast')

    // Place keyboard on top when in a modal
    if ($('.modal .input-osk').length > 0) {
      $('#osk-container').css({zIndex: 1000})
    } else {
      $('#osk-container').css({zIndex: ''})
    }
  },
  beforeDestroy: function () {
    // Hide keyboard
    $('#osk-container:visible .osk-hide').click()
    $('#osk-container-number').fadeOut('fast')

    // Reset keyboard z index
    $('#osk-container').css({zIndex: ''})
  },
  data () {
    return {}
  }
}
</script>

<style scoped lang="scss">
  .modal {
    display: flex;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;

    align-items: center;
    flex-direction: column;
    justify-content: center;
    z-index: 999;

    &__background {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      background: rgba($black, 0.6);
      z-index: 1;
    }

    &__container {
      overflow: hidden;
      position: relative;
      width: 62em;

      background: $shark;
      border-radius: 30px;
      box-shadow: 0 25px 125px 20px rgba($black, 0.95);
      z-index: 2;
    }

    &__inner {
      position: relative;
      padding: 2em;
    }

    &__close {
      overflow: hidden;
      position: absolute;
      top: 0;
      right: 0;
      width: 3.5em;
      height: 3.5em;

      background: none;
      border: none;
      z-index: 2;

      color: transparent;
      text-indent: -999em;

      &:before,
      &:after {
        display: block;
        position: absolute;
        top: 50%;
        left: 50%;
        width: 1.2em;
        height: 0.1em;

        background: $white;
        content: '';
      }
      &:before {
        transform: translate3d(-50%, -50%, 0) rotateZ(45deg);
      }
      &:after {
        transform: translate3d(-50%, -50%, 0) rotateZ(-45deg);
      }
    }

    &__close-text {
      position: absolute;
      padding: 0 0 0 1.09em;
      top: 30px;
      right: 30px;
      width: 9.09em;
      height: 3.64em;

      background: none;
      border: none;
      z-index: 2;

      color: $white;
      font: 0.55em/3.55em var(--font-bold);
      letter-spacing: 0.1em;
      text-align: center;
      text-transform: uppercase;

      &__icon {
        display: block;
        position: absolute;
        top: 50%;
        left: 2em;
        width: 0.91em;
        height: 0.91em;

        transform: translate3d(0, -50%, 0);
        z-index: 2;

        &:before,
        &:after {
          display: block;
          position: absolute;
          top: 50%;
          left: 50%;
          width: 0.91em;
          height: 1px;

          background: $white;
          content: '';
        }
        &:before {
          transform: translate3d(-50%, -50%, 0) rotateZ(45deg);
        }
        &:after {
          transform: translate3d(-50%, -50%, 0) rotateZ(-45deg);
        }
      }

      &__text {
        display: inline-block;
        position: relative;
        z-index: 2;
      }

      &__background {
        display: block;
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;

        background: rgba($white, 0.1);
        border-radius: 1.82em;
        z-index: 1;
      }

      // &__inner {
      //   display: inline-block;
      //   padding: 0 0 0 12px;
      //   position: relative;
      // }
    }

    &--large {
      .modal__container {
        width: 68.3em;
      }
    }

    &--small {
      .modal__container {
        width: 40em;
      }
    }

    &--hide-close {
      .modal__close {
        display: none;
      }
    }
  }

</style>
