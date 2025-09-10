
// TODO: Not a good name but doing the refactor is risky, I prefer to leave it like this.
export const addPercentage = (string) => {
  if (!doesIncludeMG(string) && !doesIncludePercentage(string)) {
    return `${string}mg`
  }

  if (doesIncludeMG(string) && doesIncludePercentage(string)) {
    return `${string.replace('%', '')}`
  }

  // TODO: doesn't handle the case where for some reason we have 10mg mg or 10% %, I don't think we will see those cases
  // either way it would be an issue in the product data and should be fix at the CMS level.
  return string
}

const doesIncludeMG = (string) => {
  return string.toLowerCase().includes('mg')
}

const doesIncludePercentage = (string) => {
  return string.includes('%')
}

export default {
  computed: {
    groupedAttributeValues () {
      return this.product.attribute_values.ungrouped
    },
    showAttributesInCard () {
      return this.$config.SHOW_PRODUCT_ATTRIBUTES
    },
    thc () {
      return this.groupedAttributeValues ? this.groupedAttributeValues.find(x => x.name === 'THC') : null
    },
    thcValue () {
      return addPercentage(this.thc.value)
    },
    cbdValue () {
      return addPercentage(this.cbd.value)
    },
    cbd () {
      return this.groupedAttributeValues ? this.groupedAttributeValues.find(x => x.name === 'CBD') : null
    },
    attributesColor () {
      return this.$config.ATTRIBUTE_COLORS
    },
    showAttributes () {
      return this.$config.SHOW_ATTRIBUTES
    }

  },
  methods: {
    redirectToProduct () {
      this.$router.push({
        name: 'product',
        params: { id: this.product.id, source: this.source }
      })
    },

    isZeroValue (valueString) {
      return valueString[0] === '0'
    }

  }

}
