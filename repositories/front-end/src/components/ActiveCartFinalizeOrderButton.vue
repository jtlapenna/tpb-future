<template>
  <div class="container">
    <div class="icon" :class="{ loading: isLoading }" @click="handleClick">
    <svg width="auto" height="auto" viewBox="0 0 123 96" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M14.8522 4C-13.5512 4.00001 12.7894 4 21.0603 4C22.4221 4 23.5964 4.91715 23.9442 6.2337L29.0509 25.5625M29.0509 25.5625L40.9938 70.7663C41.3417 72.0829 42.5326 73 43.8943 73H90.7111C92.0891 73 93.2899 72.0612 93.6224 70.7239L103.926 29.2865C104.397 27.3939 102.965 25.5625 101.015 25.5625H29.0509Z" stroke="white" stroke-width="8"/>
        <circle cx="49.3522" cy="89.5" r="6.5" fill="white"/>
        <circle cx="89.3522" cy="89.5" r="6.5" fill="white"/>
        <circle cx="98.3522" cy="28.5" r="24.5" fill="white"/>
        <path class="tick" d="M107.858 17.9629C109.343 16.3272 111.875 16.2074 113.508 17.6955C115.14 19.1821 115.258 21.7103 113.771 23.3423L97.681 41.0064C96.1673 42.6682 93.5788 42.7478 91.9658 41.1822C90.4251 39.6867 90.3481 37.2388 91.7918 35.6495L107.858 17.9629Z"/>
        <path class="tick" d="M107.855 17.9571C109.343 16.3239 111.873 16.206 113.506 17.6936C115.139 19.1813 115.257 21.7112 113.77 23.3443L97.6078 41.0868C96.1201 42.72 93.5902 42.838 91.957 41.3503C90.5171 40.0386 87.3739 36.4918 83.9086 32.5865C83.118 31.6955 83.1577 30.3423 84 29.5L85.371 28.129C85.4569 28.0431 85.5488 27.9634 85.6459 27.8906C86.6991 27.1007 88.1791 27.2356 89.072 28.203L92.9631 32.4184C93.2874 32.7697 93.7929 32.8883 94.2396 32.718C94.4108 32.6527 94.5643 32.5481 94.6877 32.4127L107.855 17.9571Z" />
      </svg>

    </div>
    <div class="finalize-order-button" :class="{ loading: isLoading }" @click="handleClick">
      <div class="text">
        FINALIZE ORDER
      </div>
    </div>
  </div>

</template>

<script>
import { mapGetters, mapMutations } from 'vuex'

export default {
  name: 'ActiveCartFinalizeOrderButton',
  components: {},
  props: [
    'size',
    'onClick',
  ],
  data () {
    return {}
  },
  computed: {
    ...mapGetters('cart', ['isLoading']),
  },
  watch: {},
  filters: {},
  created: function () {},
  mounted: function () {},
  destroyed() {
    this.setIsLoading(false)
  },
  methods: {
    ...mapMutations('cart', ['setIsLoading']),
    handleClick: function () {
      this.setIsLoading(true)
      this.$emit('click')
    }
  }
}
</script>

<style scoped lang="scss">
.container {
  display: flex;
  flex-direction: row;
  position: relative;
}

.finalize-order-button {
  display: flex;
  align-items: center;
  background-color: #3a3a3a;
  color: white;
  border-radius: 30px;
  padding: 1rem 4.375rem 1rem 1.25rem;
  transition: all 0.3s ease;
  z-index: 999;
  opacity: 0.6;

  &.loading {
    background-color: var(--main-color) !important;
    cursor: not-allowed !important;
    opacity: 0.9 !important;
    pointer-events: none !important;
  }
}

.icon {
  background-color: var(--main-color);
  padding: 10px;
  border-radius: 10px 25px 25px 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 10px;
  height: 5rem;
  width: 6.5rem;
  left: 150px;
  position: absolute;
  transition: all 0.3s ease;
  z-index: 1000;

  &.loading {
    border: 3px solid white !important;
    pointer-events: none !important;
  }
}

.icon .tick {
  fill: var(--main-color);

  .loading & {
    fill: #3a3a3a;
  }
}

.icon svg {
  width: 4.5rem;
  height: 4.5rem;
}

.text {
  font: 0.7em/1 var(--font-extrabold);
}

@keyframes pulse {
  0% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
  100% {
    opacity: 1;
  }
}

.loading .text {
  animation: pulse 1.5s infinite !important;
}
</style>
