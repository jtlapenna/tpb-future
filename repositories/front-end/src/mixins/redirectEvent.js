export const RedirectEvent = {
  methods: {
    /**
     * Method to redirect to a link and triking the event
     */
    redirect: function (name, patch) {
      if (this.$gsClient) {
        this.$gsClient.track(name, {
          name: name,
          path: patch
        })
      }
      this.$router.push(patch)
    }
  }
}

export default RedirectEvent
