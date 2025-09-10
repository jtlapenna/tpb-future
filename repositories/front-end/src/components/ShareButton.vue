<template>
  <div>
    <button
      v-on:click="toggleShareModal(true)"
      type="button"
      class="share-button">
      <span class="share-button__text">
        Share
      </span>
      <span class="share-button__background"></span>

      <span class="share-button__waves">
        <span class="share-button__wave"></span>
        <span class="share-button__wave"></span>
        <span class="share-button__wave"></span>
      </span><!-- .share-button__waves -->
    </button>

    <portal to="modal-container" v-if="showModal">
      <modal-template class="modal modal--small" key="share">
        <div class="share-modal">
          <h2 class="share-modal__title">
            Share
          </h2>

          <div class="share-modal__text">
            Enter your email address to receive information about this product.
          </div>

          <form v-if="shareSuccess === ''" class="share-modal__form">
            <input
              v-model="shareEmail"
              data-osk-options="disableReturn"
              placeholder="Email"
              class="input-osk" />

            <button
              v-on:click="proceedShare"
              type="button"
              class="share-modal__button">
              <span class="share-modal__button__text">
                Send
              </span><!-- .share-modal__button__text -->
              <span class="share-modal__button__background"></span>
            </button>
          </form>

          <div v-if="shareSuccess !== ''" class="share-modal__success">
            {{ shareSuccess }}
          </div><!-- .share-modal__success -->

          <div
            v-bind:class="{ 'share-modal__message--is-visible': shareMessage }"
            class="share-modal__message">
            {{ shareMessage }}
          </div><!-- .share-modal__message -->

          <button
            v-on:click="toggleShareModal(false)"
            type="button"
            class="modal__close-text">
            <span class="modal__close-text__icon"></span>
            <span class="modal__close-text__text">
              Close
            </span>
            <span class="modal__close-text__background"></span>
          </button>
        </div><!-- .share-modal -->
      </modal-template>
    </portal>
  </div>
</template>

<script>
import ModalTemplate from '@/components/ModalTemplate'
import { Portal, PortalTarget } from 'portal-vue'

export default {
  name: 'ShareButton',
  components: {
    ModalTemplate,
    Portal,
    PortalTarget
  },
  props: [
    'productId'
  ],
  data () {
    return {
      shareEmail: '',
      shareMessage: '',
      shareSuccess: '',
      showModal: false
    }
  },
  methods: {
    /**
     * Proceed share
     */
    proceedShare: function () {
      var self = this

      this.shareMessage = ''

      if (!this.shareEmail || !this.validEmail(this.shareEmail)) {
        this.shareMessage = 'Please use a valid email address.'
        return
      }

      // Share product
      console.log('Sharing product')

      self.$http.post('/products/' + self.productId + '/share', {
        share: {
          email: self.shareEmail
        }
      })
        .then(function (response) {
          console.log(response.data)

          self.shareSuccess = 'Product sent to ' + self.shareEmail
          self.shareMessage = ''
          self.shareEmail = ''

          setTimeout(function () {
            self.showModal = false

            setTimeout(function () {
              self.shareSuccess = ''
            }, 300)
          }, 1500)
        })
        .catch(function (error) {
          self.shareSuccess = ''
          self.shareMessage = 'An error occured, please try again.'
          console.log(error.responsee)
        })
    },

    /**
     * Toggle share modal
     */
    toggleShareModal: function (show) {
      this.showModal = show
      this.shareEmail = ''
      this.shareMessage = ''
      this.shareSuccess = ''
    },

    /**
     * Validate email
     * @param {String} email
     */
    validEmail: function (email) {
      // eslint-disable-next-line
      var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      return re.test(email)
    }
  }
}
</script>

<style scoped lang="scss">
  .share-button {
    position: relative;
    width: 240px;
    height: 80px;

    background: transparent;
    border: none;
    opacity: 1;
    transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1), opacity 0.2s linear;

    color: $white;
    font: 20px/80px var(--font-extrabold);
    letter-spacing: 0.05em;
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
      border-radius: 40px;
      transform: translate3d(-50%, 0, 0);
      z-index: 1;
    }

    &__waves {
      display: none;
      position: absolute;
      top: 50%;
      left: 50%;
      width: calc( 100% + 80px );
      height: calc( 100% + 40px );

      transform: translate3d(-50%, -50%, 0);
      z-index: 1;
    }

    &__wave {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      // background: red;
      border-radius: 60px;
      animation: wave-pulse 5s linear 0s infinite normal none;
      transform: scale(0);

      &:before {
        display: block;
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;

        border-radius: 60px;
        background: var(--main-color);
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

  .share-modal {
    text-align: center;

    &__title {
      margin: 0;

      font: 50px/1 var(--font-extralight);
    }

    &__text {
      margin: 20px 0;
    }

    &__form {
      display: flex;

      align-items: center;
      flex-direction: row;
      justify-content: center;
    }

    input {
      display: block;
      padding: 0 20px;
      width: calc( 100% - 124px );

      background: none;
      border: 3px solid rgba($white, 0.1);
      border-radius: 10px;

      color: $white;
      font: 25px/64px var(--font-light);

      &:focus {
        border-color: $white;
      }

      &::placeholder {
        opacity: 0.2;

        color: $white;
        font: 25px/64px var(--font-light);
      }
    }

    &__button {
      margin: 0 0 0 -16px;
      position: relative;
      width: 140px;
      height: 70px;

      background: none;
      border: none;
      opacity: 1;
      transition: transform 0.2s cubic-bezier(0.645, 0.045, 0.355, 1), opacity 0.2s linear;

      color: $white;
      font: 16px/70px var(--font-extrabold);
      letter-spacing: 0.15em;
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
        border-radius: 10px;
        transform: translate3d(-50%, 0, 0);
      }
    }

    &__success {
      font-size: 24px;
    }

    &__message {
      margin: 15px 0 0;

      text-align: left;
    }
  }
</style>
