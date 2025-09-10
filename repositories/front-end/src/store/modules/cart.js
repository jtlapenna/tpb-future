import Vue from 'vue'

export default  {
  namespaced: true,
  state: () => ({
    isFromActiveCartActivation: false,
    // TODO: Get this from he CMS settings
    cart: null,
    // TODO: this is just a workaround to be able to grab this.cart that's in App.vue.
    globalCart: null,
    phoneNumber: null,
    isActiveCartNotFound: false,
    isCartActivated: false,
    isLoading: false,
    wasCartCreated: false,
    isFromSaveCart: false,
    isFromCheckout: false,
    isAddingItemsFromRetrievedCart: false,
  }),
  getters: {
    isFromActiveCartActivation: (state) => state.isFromActiveCartActivation,
    getCart: (state) => state.cart,
    phoneNumber: (state) => state.phoneNumber,
    isActiveCartNotFound: (state) => state.isActiveCartNotFound,
    isCartActivated: (state) => state.isCartActivated,
    isLoading: (state) => state.isLoading,
    getGlobalCart: (state) => state.globalCart,
    wasCartCreated: (state) => state.wasCartCreated,
    isFromSaveCart: (state) => state.isFromSaveCart,
    isFromCheckout: (state) => state.isFromCheckout,
    isAddingItemsFromRetrievedCart: (state) => state.isAddingItemsFromRetrievedCart,
  },
  mutations: {
    resetActiveCartSession(state) {
      state.isCartActivated = false
      state.cart = null
      state.phoneNumber = null
      state.isFromActiveCartActivation = false
      state.isActiveCartNotFound = false
      state.isLoading = false
      state.wasCartCreated = false
      state.isFromSaveCart = false
      state.isFromCheckout = false
    },

    setWasCartCreated(state, value) {
      state.wasCartCreated = value
    },

    setIsFromActiveCartActivation(state, value) {
      state.isFromActiveCartActivation = value;
    },

    setCart(state, value) {
      state.cart = value
    },

    setPhoneNumber(state, value) {
      state.phoneNumber = value;
    },

    setIsActiveCartNotFound(state, value) {
      state.isActiveCartNotFound = value;
    },

    setIsCartActivated(state, value) {
      state.isCartActivated = value;
    },

    setIsLoading(state, value) {
      state.isLoading = value
    },

    setGlobalCart(state, value) {
      state.globalCart = value
    },

    setIsFromSaveCart(state, value) {
      state.isFromSaveCart = value
    },

    setIsFromCheckout(state, value) {
      state.isFromCheckout = value
    },

    setIsAddingItemsFromRetrievedCart(state, value) {
      state.isAddingItemsFromRetrievedCart = value
    }

  },
  actions: {
    fetchActiveCart({ commit }, phoneNumber) {
      commit('setIsLoading', true)
      return Vue.http.get(`/carts`, {
        params: {
          phone_number: phoneNumber
        }
      }).then((response) => {
        commit('setCart', response.data)
        commit('setIsCartActivated', true)
        commit('setIsAddingItemsFromRetrievedCart', true)
        commit('setPhoneNumber', phoneNumber)
        commit('setIsLoading', false)
        return response.data
      }).catch((error) => {
        console.error('Error fetching cart:', error)
        commit('setIsActiveCartNotFound', true)
        commit('setIsLoading', false)
        throw error;
      })
    },
    createOrMergeActiveCart({ commit }, data) {
      commit('setIsLoading', true)
      let items = []
       data.cart.forEach((item, index) => {
        items.push({
          "name": item.product.name,
          "brand":item.product.brand.name,
          "price": item.price,
          "product_id": item.product.id,
          "quantity": item.qty
        })
      })
      return Vue.http.post(`/carts/create_or_merge`, {
        phone_number: data.phoneNumber,
        cart: {
          items
        }
      }).then((response) => {
        commit('setWasCartCreated', response.data.is_new || false)
        commit('setCart', response.data)
        commit('setIsCartActivated', true)
        commit('setIsAddingItemsFromRetrievedCart', true)
        commit('setPhoneNumber', data.phoneNumber)
        commit('setIsLoading', false)
        return response.data
      }).catch((error) => {
        console.error('Error fetching cart:', error)
        commit('setIsActiveCartNotFound', true)
        commit('setIsLoading', false)
      })
    },
    addProductToActiveCart({ commit, rootState }, data) {
      if (!rootState.cart.isCartActivated) {
        console.log('addProductToActiveCart was called without isCartActivated being true')
        return
      }

      if (rootState.cart.isAddingItemsFromRetrievedCart) {
        console.log('addProductToActiveCart was called while isAddingItemsFromRetrievedCart is true, could happen while items are being added from the cart that comes from the backend.')
        return
      }
      // {cart: {items: [{name: '', brand: '', category: '', price: '', base_price: '', product_id: 0, product_value_id: 0}]}}
      commit('setIsLoading', true)
      return Vue.http.post(`/carts/add_items`, {
        phone_number: rootState.cart.phoneNumber,
        cart: {
          items: [{
            "name": data.product.name,
            "brand":data.product.brand.name,
            "price": data.price,
            "product_id":data.product.id,
            "quantity": data.qty
          }]
        }
      }).then((response) => {
        commit('setIsLoading', false)
        return response.data
      }).catch((error) => {
        console.error('Error fetching cart:', error)
        commit('setIsActiveCartNotFound', true)
        commit('setIsLoading', false)
      })
    },

    updateProductInActiveCart({ commit, rootState }, data) {
      if (!rootState.cart.isCartActivated) {
        console.log('updateProductInActiveCart was called without isCartActivated being true')
        return
      }
      // {cart: {items: [{name: '', brand: '', category: '', price: '', base_price: '', product_id: 0, product_value_id: 0}]}}
      commit('setIsLoading', true)
      return Vue.http.post(`/carts/update_item`, {
        phone_number: rootState.cart.phoneNumber,
        product_id: data.productId,
        quantity: data.quantity,
      }).then((response) => {
        commit('setIsLoading', false)
        commit('setCart', response.data)
        return response.data
      }).catch((error) => {
        console.error('Error fetching cart:', error)
        commit('setIsActiveCartNotFound', true)
        commit('setIsLoading', false)
      })
    },

    cartExists({commit}, phoneNumber) {
      commit('setIsLoading', true)
      return Vue.http.get(`/carts/exists`, {
         params: {
           phone_number: phoneNumber
         }
      }).then((response) => {
        commit('setIsLoading', false)
        return response.data.exists
      }).catch((error) => {
        console.error('Error fetching cart:', error)
        commit('setIsLoading', false)
      })
    }
  }
}
