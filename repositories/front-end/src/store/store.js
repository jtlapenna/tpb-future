import Vue from 'vue'
import Vuex from 'vuex'
import products from './modules/products'
import cart from './modules/cart'
Vue.use(Vuex)
export default new Vuex.Store({
  state: {
    connected: navigator.onLine,
    totalCart: null,
    doesNotCameFromProduct: false,
    selectedNavigationBrand: false
  },
  getters: {
    connected: state => state.connected,
    totalCart: state => state.totalCart
  },
  mutations: {
    SET_CONNECTED (state, payload) {
      state.connected = payload
    },
    SET_TOTAL_CART (state, payload) {
      state.totalCart = payload
    },
    setDoesNotCameFromProduct(state, value) {
      state.doesNotCameFromProduct = value
    },
    setSelectedNavigationBrand(state, value) {
      state.selectedNavigationBrand = value
    }
  },
  actions: {
    setConnected ({ commit }, payload) {
      commit('SET_CONNECTED', payload)
    },
    setTotalCart ({ commit }, payload) {
      commit('SET_TOTAL_CART', payload)
    }
  },
  modules: {
    products,
    cart
  }
})
