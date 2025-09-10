<template>
  <div id="screen-blank" class="screen screen--blank" style="opacity: 0;">
  </div>
</template>

<script>
export default {
  name: 'ScreenBlank',
  data () {
    return {}
  },
  created () {

  }
}
</script>

<style scoped lang="scss">
  .screen--blank {
    pointer-events: none;
  }
</style>
