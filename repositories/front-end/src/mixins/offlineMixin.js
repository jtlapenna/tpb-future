import { mapState } from 'vuex'

export const OFFLINE = {
  computed: {
    ...mapState(['connected'])
  }
}

export default OFFLINE
