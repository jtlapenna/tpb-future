<template>
  <div>
    <video  class="myVideo" autoplay muted loop playsinline preload="auto">
      <source :src="videoSrc" type="video/mp4">
      Your browser does not support the video tag.
    </video>
  </div>

</template>

<script>
export default {
  name: 'ScreenProductVideo',
  components: {},
  props: {
    videoSrc: {
      type: String,
      required: true
    }
  },
  data () {
    return {}
  },
  computed: {},
  beforeDestroy() {
     this.$root.$off('animate-full-screen-background', this.startAnimatingOut)
  },
  watch: {},
  filters: {},
  created: function () {
    this.$root.$on('animate-full-screen-background', this.startAnimatingOut)
  },
  mounted: function () {},
  methods: {
    startAnimatingOut() {
      const video = document.getElementsByClassName('myVideo')[0];
      video.classList.add('fade-out');
    }
  }
}
</script>

<style scoped lang="scss">
.myVideo {
  width: 100%;
  max-height: 100vh;
  animation: fadeIn 2s ease-in-out; /* Add fade-in animation */
  position: fixed; /* Keeps the video in place */
  top: 0;          /* Aligns to the top */
  left: 0;         /* Aligns to the left */
  height: 100%;    /* Full height */
  object-fit: cover; /* Ensures the video covers the entire screen */
  z-index: -1;     /* Pushes it behind other content */
  pointer-events: none; /* Disables interaction with the video */
  transition: opacity 1s ease-in-out;
}

.myVideo.fade-out {
  opacity: 0; /* Fully transparent */
}

/* Keyframes for fade-in effect */
@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}
</style>
