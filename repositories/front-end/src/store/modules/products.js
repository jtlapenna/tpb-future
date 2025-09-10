export default {
  namespaced: true,
  state: () => ({
    currentPage: 1,
    products: null,
    isFullScreenProduct: false,
  }),
  getters: {
    getFrozenPrices: (state) => (product) => {
      if (!product || !product.product_values || product.product_values.length === 0) {
        return null;
      }

      // Sort prices from product values
      const sortedPrices = product.product_values.slice().sort((a, b) => {
        return parseFloat(a.value) - parseFloat(b.value);
      });

      // Select the lowest price as the default selected price
      const selectedPrice = sortedPrices[0];

      // Clone the selected price to avoid modifying the original
      const frozenPrice = { ...selectedPrice };

      // Set the base price
      frozenPrice.basePrice = frozenPrice.value;

      // Calculate tax
      let tax = 0;
      if (product.category_taxes && product.category_taxes.length > 0) {
        tax = Math.min(...product.category_taxes.map(t => t.value));
      } else if (product.store_taxes && product.store_taxes.length > 0) {
        tax = Math.min(...product.store_taxes.map(t => t.value));
      }

      // Apply tax to the price
      if (tax > 0) {
        const numPrice = parseFloat(frozenPrice.basePrice);
        frozenPrice.value = parseFloat(numPrice + numPrice * (tax / 100)).toFixed(2);
      }

      // Calculate discount price if applicable
      const discountPrice =
        product.store_product_promotions && product.store_product_promotions.length > 0
          ? parseFloat(product.store_product_promotions[0].discount_price)
          : null;

      const isPriceWithDiscount =
        discountPrice &&
        discountPrice > 0 &&
        parseFloat(frozenPrice.value) === parseFloat(discountPrice);

      // Include the discount price if applicable
      frozenPrice.priceDiscount = isPriceWithDiscount ? discountPrice.toFixed(2) : null;

      // Return the frozen price, tax, discount, and sorted prices for reference
      return {
        frozenPrice,
        tax,
        discountPrice,
        sortedPrices,
      };
    },

    getIsFullScreenProduct: (state) => state.isFullScreenProduct,
    products: (state) => state.products,

    isImage: (state) => (url) => {
      if (url === null || url === undefined || !url) {
        return false
      }
      const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'svg', 'webp', 'tiff', 'ico'];

      const chunks = (url || '').split('.');
      if (chunks.length < 2) {
        return false;
      }

      const extension = chunks[chunks.length - 1].toLowerCase();
      return imageExtensions.includes(extension);
    },

    isVideo: (state) => (url) => {
      if (url === null || url === undefined || !url) {
        return false
      }
      const videoExtensions = ['mp4', 'avi', 'wmv', 'mpg', 'mts', 'flv', '3gp', 'vob', 'm4v', 'mpeg', 'm2ts', 'mov'];

      const chunks = (url || '').split('.');
      if (chunks.length < 2) {
        return false;
      }

      const extension = chunks[chunks.length - 1].toLowerCase();
      return videoExtensions.includes(extension);
    },
  },
  mutations: {
    SET_CURRENT_PAGE (state, page) {
      state.currentPage = page
    },

    setProducts(state, value) {
      state.products = value
    },

    setIsFullScreenProduct(state, isFullScreenProduct) {
      state.isFullScreenProduct = isFullScreenProduct
    }
  }
}
