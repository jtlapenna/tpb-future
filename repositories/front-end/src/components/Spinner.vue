<template >
  <div class="spinner"
    v-bind="$attrs"
    :style="{
      width: width+'px',
      borderWidth: thiccness+'px' }">

  </div>
</template>
<script>
export default {
  name: 'TpbSpinner',
  props: {
    width: {
      type: String | Number,
      default: '48'
    },
    thiccness: {
      type: String | Number,
      default: '4'
    }
  }

}
</script>
<style lang="">

  .spinner{
    border-radius: 50%;
    border: 4px solid rgba(255, 255, 255, 0.3);
    border-right-color:  var(--main-color);
    display: inline-block;
    width: 48px;
    height: 48px;
    animation: spin 0.75s linear infinite;
  }
  @keyframes spin {
    0% {
      transform: rotate(0deg);
    }
      50% {
      transform: rotate(180deg);
    }
     100% {
      transform: rotate(360deg);
    }
}

</style>
