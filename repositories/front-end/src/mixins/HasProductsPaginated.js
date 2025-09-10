import InfiniteLoading from 'vue-infinite-loading'
import {PRODUCTS_PAGE_SIZE} from '@/const/globals'
import TpbSpinner from '@/components/Spinner'
import { mapState, mapMutations } from 'vuex'
export default {
  components: {
    InfiniteLoading,
    TpbSpinner,
    PRODUCTS_PAGE_SIZE
  },
  computed: {
    ...mapState('products', ['currentPage']),
    productsLimit () {
      return PRODUCTS_PAGE_SIZE * this.currentPage
    },
    productPage () {
      let products = this.filteredProducts.slice(0, this.productsLimit)
      return products
    }
  },
  methods: {
    ...mapMutations('products', {setCurrentPage: 'SET_CURRENT_PAGE'}),

    loadMore ($state) {
      console.log('Loading more')
      // this.currentPage = this.currentPage + 1
      this.setCurrentPage(this.currentPage + 1)
      if (this.productPage.length === this.filteredProducts.length) {
        $state.complete()
      } else {
        $state.loaded()
      }
    }
  }

}
