<template>
    <button class="active-cart-btn" :class="className" @click="closeActiveCart">
      <span class="text">
        <span class="line">ACTIVE</span>
        <span class="line-bottom">CART</span>
      </span>
      <span class="icon" :class="className"></span>
    </button>
</template>

<script>
import { mapMutations } from 'vuex'

export default {
  name: 'ActiveCartButton',
  components: {},
  props: [
    'size',
    'onClick',
    'infoMode',
  ],
  data () {
    return {}
  },
  computed: {
    className () {
      let c = this.infoMode ? 'info-mode' : ''
      if (this.size) {
        c += ` ${this.size}`
        return c
      }
      c += ' large'
      return c
    }
  },
  watch: {},
  filters: {},
  created: function () {},
  mounted: function () {},
  beforeDestroy() {},
  methods: {
    // This is not correct, this button shouldn't use the state like this but I don't think it matters at this point.
    ...mapMutations('cart', ['setIsFromActiveCartActivation']),
    closeActiveCart() {
      const isButtonMode = !this.infoMode
      if (isButtonMode) {
        this.setIsFromActiveCartActivation(true)
        this.$router.push({name: 'checkout'})
      }
    }
  }
}
</script>

<style scoped lang="scss">

.active-cart-btn {
  background-color: var(--main-color);
  color: #ffffff;
  border: none;
  border-radius: 15px;
  font-size: 1.1rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  font-family: Arial, sans-serif;
  transition: all 1s ease-in-out;;

  &.small {
    font-size: 1.25rem;
    height: 5rem;
    padding: 0.7rem 0.7rem 0.7rem 0.7rem;
  }

  &.tiny {
    font-size: 0.8rem;
    height: 3rem;
    padding: 1rem 0.8rem !important;
  }

  &.large {
    font-size: 1.5rem;
    padding: 1rem 1rem 1rem 1rem;
    height: 6rem;
    border-radius: 25px;
  }

  &.info-mode {
    background-color: transparent;
    border: 2px solid var(--main-color);
    padding: 1.1rem 1.7rem;
  }
}

.active-cart-btn .text {
  display: flex;
  flex-direction: column;
  margin-right: 10px;
  text-align: center;
  letter-spacing: 0.1em;
}

.active-cart-btn .line {
  line-height: 1;
  font: 1em var(--font-bold);
}

.active-cart-btn .line-bottom {
  line-height: 1;
  font: 1em var(--font-bold);
  margin-top: 5px;
}

.icon {
  margin-top: 3px;

  background-repeat: no-repeat;
  background-size: contain;
  background-image: url('~@/assets/img/active-cart-icon.svg');
  transition: all 1s ease-in-out;;

  &.small {
    width: 2.96rem;
    height: 2.96rem;
  }

  &.tiny {
    width: 2.10rem;
    height: 2.10rem;
  }

  &.large {
    width: 3.40rem;
    height: 3.40rem;
  }
}

</style>
