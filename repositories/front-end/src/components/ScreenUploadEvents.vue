<template>
  <div id="screen analytics" class="screen">
    analytics

    <div class="analytics_ ">
      <button  @click="uploadEvents">
        Upload Events
      </button>
       <button  @click="getEvents">
       Refresh
      </button>
      <div class="events data">
        Total events {{events.length}}
         <button @click="copyToClipboard()">Copy Events to clipboard</button>
      </div>
    </div>
    <div style="height:50vh; overflow:auto;">
    <pre>
      {{eventsFormated}}
    </pre>
    </div>
    <div style="padding: 1rem;">
      <textarea name="" id="" cols="30" rows="10" v-model="eventsToUpload" ></textarea>
      <button @click="setToDB()">Add events</button>
    </div>

  </div>
</template>

<script>
import Events from '@/analytics/events'
export default {
  name: 'ScreenUploadEvents',
  mounted () {
    // this.uploadEvents()
  },
  data: () => ({
    events: [],
    eventsToUpload: ''
  }),
  methods: {
    async uploadEvents () {
      console.log('GSCLIENT IS', this.$gsClient)
      try {
        await this.$gsClient.uploadEvents()
      } catch (e) {
        console.error(e)
        alert('Error, events could not be uploaded')
      }
    },
    async setToDB () {
      try {
        const newEvents = JSON.parse(this.eventsToUpload)
        console.log(newEvents)
        var r = confirm('Are you sure to add this events to the local db?')
        if (r === true) {
          await Promise.all(newEvents.map((event) => {
            return Events.save(event)
          }))
          this.eventsToUpload = ''
        } else {
          console.log('Events did not upload to local db')
        }
      } catch (error) {
        console.error(error)
        alert('Error, events could not be saved locally')
      }
    },
    copyToClipboard () {
      navigator.clipboard.writeText(JSON.stringify(this.events))
      alert('events copied to clipboard, ctrl/command + V to paste')
    },
    async getEvents () {
      try {
        this.events = await Events.index()
        console.log(this.events)
      } catch (e) {
        console.error(e)
        alert('Error, events could not be fetch from indexed db')
      }
    }
  },
  async created () {
    this.events = await Events.index()
    console.log(this.events)
  },
  computed: {
    eventsFormated () {
      return JSON.stringify(this.events)
    }
  }
}
</script>

<style lang="scss" scoped>
.events{
  padding: 1rem;
}

 pre {
            overflow-x: auto;
            white-space: pre-wrap;
            white-space: -moz-pre-wrap;
            white-space: -pre-wrap;
            white-space: -o-pre-wrap;
            word-wrap: break-word;
         }
</style>
