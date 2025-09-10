<template>
  <div class="screen" style="padding-right: 300px;">
      Test for inframe

      <button @click="showInframe()">
      Show</button>
      <iframe src="" id="myFrame" frameborder="0" v-html="shoppifyHtml"></iframe>
  </div>
</template>
<script>
export default {
  data () {
    return {
      shoppifyHtml: null
    }
  },
  created () {
    // @ts-ignorethis.fetchHtml()
  },
  methods: {

    showInframe () {
      const child = window.open('https://partakefoods.com/1222967353/checkouts/59f02fe271e5ccb9fe0e44048add81c9', '', 'width = 600, height = 720')
      const checkChild = () => {
        if (child.closed) {
          alert('Child window closed')
          clearInterval(timer)
        }
      }
      var timer = setInterval(checkChild, 500)
    }
  }
}
</script>
