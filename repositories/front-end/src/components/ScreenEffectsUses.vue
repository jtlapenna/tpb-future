<template>
  <div id="screen-effects-uses" class="screen screen--effects-uses" style="opacity: 0;">
    <section v-if="topics.length > 0" class="section section--education">
      <h2 class="section--education__title">
        <div class="section--education__title__text">
          Education
        </div><!-- .section--education__title__text -->
        <div class="section--education__title__line"></div>
      </h2>

      <div class="topics">
        <div v-for="(topic, index) in topics" v-bind:key="topic.id" v-on:click="toggleTopicModal(index, topic)"
          class="topic">
          <div class="topic__card">
            <div class="topic__icon">
              <div class="topic__icon__background"></div>
              <div v-bind:class="'topic__icon__shape--icon-' + topic.icon" class="topic__icon__shape"></div>
            </div><!-- topic__icon -->

            <div class="topic__info">
              <h3 class="topic__title">
                {{ topic.title }}
              </h3>

              <div class="topic__intro">
                {{ topic.excerpt }}
              </div><!-- .topic__intro -->

              <div class="topic__more">
                <div class="topic__more__icon"></div>
                <div class="topic__more__text">
                  More
                </div><!-- .topic__more__text -->
              </div><!-- .topic__more -->
            </div><!-- .topic__info -->
          </div><!-- .topic__card -->

          <portal to="modal-container" v-if="showModal === index">
            <modal-template v-bind:class="{ 'modal--large': topic.products.length > 0 }" key="{ 'topic-' + index }">
              <div class="topic-modal" v-bind:class="{ 'topic-modal--has-products': topic.products.length > 0 }">
                <div class="topic-modal__content">
                  <header class="topic-modal__header">
                    <div v-bind:class="'topic-modal__icon--icon-' + topic.icon" class="topic-modal__icon"></div>

                    <h2 class="topic-modal__title">
                      {{ topic.title }}
                    </h2>
                  </header>

                  <div class="topic-modal__body">
                    <p v-for="(paragraph, index) in topic.text.split(/\r\n|\r|\n/gi)" v-bind:key="index">
                      {{ paragraph }}
                    </p>
                  </div><!-- .topic-modal__body -->
                </div><!-- .topic-modal__content -->

                <aside v-if="topic.products.length > 0" class="topic-modal__aside">
                  <div class="topic-modal__aside__inner">
                    <h3 class="topic-modal__aside__title">
                      <div class="topic-modal__aside__title__text">
                        Related products
                      </div>
                      <div class="topic-modal__aside__title__line"></div>
                    </h3>

                    <div class="topic-modal__aside__products">
                      <product-card
                        v-for="product in topic.products.slice(0, 4)"
                        v-bind:key="product.id"
                        v-bind:product="product"
                        v-bind:layout="'small'"
                        v-bind:source="'Effects + Uses'"
                        v-bind:quickCart="false"
                        :isFromModalOpen="true"
                      />
                    </div><!-- .topic-modal__aside__products -->

                    <router-link v-if="topic.products.length > 4"
                      :to="topic.category ? routeCategory(topic.products[0].catalog_category.id) : middlewareTopic.category ? routeCategory(topic.products[0].catalog_category.id) : middlewareTagRoute(topic.tag, topic.products[0].tag_list, topic.products[0].tag_list)"
                      class="topic-modal__aside__button">
                      <div class="topic-modal__aside__button__text">
                        View more
                      </div>
                      <div class="topic-modal__aside__button__background"></div>
                    </router-link>
                  </div><!-- .topic-modal__aside__inner -->

                  <div class="topic-modal__aside__background"></div>
                </aside><!-- .topic-modal__aside -->

                <button v-on:click="toggleTopicModal(index)" type="button" class="modal__close-text">
                  <span class="modal__close-text__icon"></span>
                  <span class="modal__close-text__text">
                    Close
                  </span>
                  <span class="modal__close-text__background"></span>
                </button>
              </div>
            </modal-template>
          </portal>
        </div><!-- .topic -->
      </div><!-- .topics -->

      <div v-if="featuredTags.length > 0" class="section__separator"></div>
    </section><!-- .section--education -->
    <section v-if="featuredTags.length > 0" class="section--uses">
      <h2 class="section--uses__title">
        Products by use
      </h2>

      <div class="uses">
        <div class="uses__tabs">
          <ul>
            <li v-for="(tag, index) in featuredTags" v-bind:key="index"
              v-bind:class="{ 'uses__tab--is-active': activeTab === tag }" v-on:click="selectTab(tag)"
              class="uses__tab uses__tab">
              {{ tag }}
              <div class="uses__tab__line"></div>
            </li>
          </ul>
        </div><!-- .uses__tabs -->

        <div class="uses__blocks">
          <section v-for="(tag, index) in usesTags" v-bind:key="index" v-if="activeTab === tag.name"
            class="uses__block use" style="opacity: 0;">
            <div class="use__products">
              <product-card v-for="product in tag.products.slice(0, 5)" v-bind:key="product.id" v-bind:product="product"
                v-bind:source="'Effects + Uses'" v-bind:layout="'small'">
              </product-card>

              <router-link :to="tagRoute(tag.name)" v-if="tag.products.length > 5" class="use__button">
                <div class="use__button__text">
                  View all products
                </div><!-- .use__button__text -->
                <div class="use__button__background"></div>
              </router-link>
            </div><!-- .use__products -->
          </section><!-- .use -->
        </div><!-- .uses__blocks -->
      </div><!-- .uses -->
    </section>
  </div>
</template>

<script>
import ArticlesRepo from '@/api/articles/ArticlesRepo'
import ModalTemplate from '@/components/ModalTemplate'
import ProductCard from '@/components/ProductCard'
import { SYNONYMOUS } from '@/const/globals'
import { Linear, Power2, Power3, TimelineLite } from 'gsap/all'
import $ from 'jquery'
import { Portal, PortalTarget } from 'portal-vue'

export default {
  name: 'ScreenEffectsUses',
  components: {
    ModalTemplate,
    Portal,
    PortalTarget,
    ProductCard
  },
  props: ['products', 'articles', 'isGeneratingIndex'],
  data() {
    return {
      activeTab: null,
      selectedTab: null,
      showModal: null,
      topics: [],
      usesTags: [],
      featuredTags: []
    }
  },
  created: function () {
    // Events
    this.$on('transition-leave', this.onTransitionLeave)
  },
  mounted: function () {
    // Fetch data
    this.fetchData(true)
  },
  destroyed: function () {
    // Events
    this.$off('transition-leave', this.onTransitionLeave)
  },
  computed: {
    getProducts() {
      return this.products
    }
  },
  watch: {
    $route: 'fetchData',
    products(newProducts, oldProducts) {
      if (newProducts.length !== oldProducts.length) {
        this.fetchData()
      }
    }
  },
  methods: {
    /**
     * Screen transition enter
     */
    transitionEnter: function () {
      // Seletors
      var self = this
      var container = $(this.$el)

      // Before animation
      container.css({ opacity: '' })
      container
        .find('.uses__tab--is-active .uses__tab__line')
        .css({ transition: 'none' })

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      container.find('.section--education').each(function () {
        var section = $(this)
        var topics = section.find('.topic').slice(0, 3)

        tl.from(
          section.find('.section--education__title__text'),
          0.5,
          {
            alpha: 0,
            x: -10,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0
        )

        tl.from(
          section.find('.section--education__title__line'),
          0.5,
          {
            scaleX: 0,
            clearProps: 'transform',
            ease: Power3.easeInOut
          },
          0
        )

        tl.staggerFrom(
          topics.find('.topic__icon > *'),
          0.6,
          {
            alpha: 0,
            scale: 0,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.1,
          0.1
        )

        tl.staggerFrom(
          topics.find('.topic__title, .topic__intro'),
          0.5,
          {
            alpha: 0,
            y: 30,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.1,
          0.3
        )

        tl.staggerFrom(
          topics.find('.topic__more__icon'),
          0.6,
          {
            alpha: 0,
            scale: 0,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.1,
          0.5
        )

        tl.staggerFrom(
          topics.find('.topic__more__text'),
          0.5,
          {
            alpha: 0,
            clearProps: 'opacity',
            ease: Linear.easeNone
          },
          0.1,
          0.6
        )

        section = null
        topics = null
      })

      tl.from(
        container.find('.section__separator'),
        0.7,
        {
          scaleX: 0,
          clearProps: 'transform',
          ease: Power2.easeInOut
        },
        0.1
      )

      container.find('.section--uses').each(function () {
        var section = $(this)

        tl.from(
          section.find('.section--uses__title'),
          0.5,
          {
            alpha: 0,
            y: 30,
            clearProps: 'transform, opacity',
            ease: Power3.easeOut
          },
          0.5
        )

        section.find('.uses__tab').each(function (index) {
          var tab = $(this)
          var start = 0.6 + 0.1 * index

          tl.from(
            tab,
            0.5,
            {
              alpha: 0,
              y: 30,
              clearProps: 'transform, opacity',
              ease: Power3.easeOut
            },
            start
          )

          tl.from(
            tab.filter('.uses__tab--is-active').find('.uses__tab__line'),
            0.5,
            {
              scaleX: 0,
              clearProps: 'transform, transition',
              ease: Power3.easeInOut
            },
            start + 0.1
          )

          tab = null
        })

        tl.call(
          function () {
            self.tabTransitionEnter()
          },
          null,
          null,
          0.8
        )

        section = null
      })

      tl.call(function () {
        tl.kill()

        tl = null
        container = null
      })

      tl.play()
    },
    /**
     * Screen transition leave
     */
    onTransitionLeave: function (el, done) {
      // Seletors
      // var self = this
      var container = $(this.$el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      container.find('.section--education').each(function () {
        var section = $(this)
        var topics = section.find('.topics')

        tl.to(
          section.find('.section--education__title__text'),
          0.5,
          {
            alpha: 0,
            x: -10,
            ease: Power3.easeIn
          },
          0
        )

        tl.to(
          section.find('.section--education__title__line'),
          0.5,
          {
            scaleX: 0,
            ease: Power3.easeInOut
          },
          0
        )

        tl.to(
          topics.find('.topic__icon'),
          0.6,
          {
            alpha: 0,
            scale: 0,
            ease: Power3.easeIn
          },
          0.1
        )

        tl.to(
          topics,
          0.5,
          {
            alpha: 0,
            ease: Linear.easeNone
          },
          0.1
        )

        section = null
        topics = null
      })

      tl.to(
        container.find('.section__separator'),
        0.7,
        {
          scaleX: 0,
          ease: Power2.easeInOut
        },
        0.1
      )

      container.find('.section--uses').each(function () {
        var section = $(this)

        tl.staggerTo(
          section
            .find('.section--uses__title, .uses__tab, .uses__blocks')
            .reverse(),
          0.5,
          {
            alpha: 0,
            y: 30,
            ease: Power3.easeIn
          },
          0.05,
          0.1
        )

        section = null
      })

      tl.call(
        function () {
          tl.kill()

          tl = null
          container = null

          done()
        },
        null,
        null,
        Math.max(1, tl.duration())
      )

      tl.play()
    },

    /**
     * Tab transition enter
     */
    tabTransitionEnter: function () {
      // Selectors
      var container = $(this.$el)
      var uses = container.find('.uses__block')
      uses.data('wait', true)

      // Before animation
      uses.css({ opacity: '' })
      uses.find('.use__products').css({ opacity: '', transform: '' })

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.staggerFromTo(
        container.find('.product-image'),
        0.7,
        {
          alpha: 0,
          x: -20
        },
        {
          alpha: 1,
          x: 0,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        0.1,
        0
      )

      tl.staggerFromTo(
        container.find('.product-card__info'),
        0.5,
        {
          alpha: 0
        },
        {
          alpha: 1,
          clearProps: 'opacity',
          ease: Linear.easeNone
        },
        0.1,
        0.05
      )

      tl.from(
        container.find('.use__button__background'),
        0.5,
        {
          width: 0,
          clearProps: 'width',
          ease: Power2.easeInOut
        },
        0.1
      )

      tl.from(
        container.find('.use__button__text'),
        0.5,
        {
          alpha: 0,
          y: 20,
          clearProps: 'transform, opacity',
          ease: Power3.easeOut
        },
        0.4
      )

      tl.call(function () {
        uses.data('wait', false)

        tl.kill()

        tl = null
        container = null
        uses = null
      })

      tl.play()
    },

    /**
     * Tab transition leave
     */
    tabTransitionLeave: function (done) {
      // Selectors
      var container = $(this.$el)

      // Animation
      var tl = new TimelineLite()
      tl.pause()

      tl.to(
        container.find('.use__products'),
        0.5,
        {
          alpha: 0,
          y: 30,
          ease: Power3.easeIn
        },
        0
      )

      tl.call(function () {
        tl.kill()

        tl = null
        container = null

        if (done !== false) {
          done()
        }
      })

      tl.play()
    },

    /**
     * Fetch data
     */
    fetchData: function (doTransition = false) {
      var self = this

      // Fetch articles
      this.articles.forEach(function (article) {
        // Use default products if not set

        if (article.category) {
          article.products = self.filteredProductsByCategory(article.category.name, article.tag)
        } else if (article.tag) {
          article.products = self.filteredProducts(article.tag)
        } else if (article.products.length > 0) {
          article.products = self.products.filter(function (product) {
            let exists = article.products.find(articleProduct => articleProduct.id === product.id)
            if (exists) {
              return true
            } else {
              return false
            }
          })
        }

        if (article.products.length >= 0) {
          var icon = article.icon.toLowerCase().replace(/s$|[ -]*/gi, '')

          // Hard coded edge case
          if (icon === 'extract') {
            icon = 'concentrate'
          } else if (icon === 'cartridge') {
            icon = 'vape'
          }

          article.icon = icon

          return self.topics.push(article)
        }
      })

      // Get tags from local storage
      let kioskConfig = localStorage.getItem('config_data')
      kioskConfig = JSON.parse(kioskConfig)

      let tags = kioskConfig.catalog.tag_list ? kioskConfig.catalog.tag_list : []

      // Map this usesTags
      this.usesTags = tags.map(tag => {
        // Return product that matches provided featured tags
        let arr = this.getProducts.filter(product => {
          return tags.find(tag => {
            return product.tag_list.includes(tag)
          })
        })

        // Map tag name and products with corresponding tag match
        if (arr.length > 0) {
          let o = {}
          o.name = tag
          o.products = arr.filter(item => {
            return item.tag_list.includes(tag)
          })

          // Map tags only if products are found
          if (o.products.length > 0) {
            const duplicateTags = this.featuredTags.includes(tag)
            if (!duplicateTags) {
              this.featuredTags.push(tag)
            }
          }
          return o
        }
      })
      if (this.selectedTab) {
        this.activeTab = this.selectedTab
      } else {
        this.activeTab = this.featuredTags.length > 0 ? this.featuredTags[0] : null
      }

      // Fetch is done, call transition on next tick
      if (doTransition) {
        this.$nextTick(this.transitionEnter)
      }
    },

    /**
     * Fetch store articles
     */
    fetchArticles: async function () {
      let self = this
      return new Promise((resolve, reject) => {
        ArticlesRepo.index().subscribe(articles => {
          self.articles = articles
          resolve(articles)
        }, error => {
          resolve([])
          console.error(error)
        })
      })
    },

    /**
     * Get products for given tag
     * @param  {String} tag
     */
    filteredProducts: function (tag) {
      // Get products that have this tag
      let self = this
      var products = this.getProducts.filter(function (product) {
        let tagList = product.tag_list.map(tagProduct => tagProduct.toLowerCase().trim())
        return tagList.includes(tag.toLowerCase().trim()) || product.tag_list.some(tagProduct => self.synonymousWords(tagProduct.toLowerCase().trim(), tag.toLowerCase().trim()))
      })
      console.log('products by tag', tag, products)
      // If option is enabled, put featured products on top
      if (this.$config.SORT_FEATURED.USES === true) {
        return products.sort(function (a, b) {
          if (a.isFeatured && !b.isFeatured) {
            return -1
          } else if (!a.isFeatured && b.isFeatured) {
            return 1
          }

          return 0
        })
      } else {
        return products
      }
    },

    /**
     * Get products for given category
     * @param  {String} category
     */
    filteredProductsByCategory: function (category, tag) {
      const self = this
      // Get products that have this tag
      var products = this.getProducts.filter(function (product) {
        return product.catalog_category && ((product.catalog_category.name.toLowerCase().trim() === category.toLowerCase().trim()) || self.synonymousWords(product.catalog_category.name.toLowerCase().trim(), category.toLowerCase().trim()))
      })

      if (products.length === 0) {
        products = self.filteredProducts(tag)
      }

      // If option is enabled, put featured products on top
      if (this.$config.SORT_FEATURED.USES === true) {
        return products.sort(function (a, b) {
          if (a.isFeatured && !b.isFeatured) {
            return -1
          } else if (!a.isFeatured && b.isFeatured) {
            return 1
          }

          return 0
        })
      } else {
        return products
      }
    },

    /**
     * Compare if two words are synonymous
     * @param {string} firstWord string to compare
     * @param {string} secondWord string to compare
     */
    synonymousWords(firstWord, secondWord) {
      let wordsAreSynonymous = false
      SYNONYMOUS.find(stringArray => {
        if (stringArray.includes(firstWord) && stringArray.includes(secondWord)) {
          wordsAreSynonymous = true
          return true
        }
      })
      return wordsAreSynonymous
    },

    /**
     * Generate tag route
     * @param  {String} category
     * @return {Object} Route
     */
    routeCategory: function (category) {
      // Default route
      var route = {
        name: 'products',
        query: {
          tags: [category]
        }
      }

      // Find first products link
      var routePath = null
      this.$config.NAV.forEach(function (link) {
        if (routePath === null && link.path.startsWith('/products')) {
          routePath = link.path
        }
      })

      if (routePath) {
        route = {
          path: routePath,
          query: {
            category: [category]
          }
        }
      }

      return route
    },

    /**
     * Select tab for given tag
     * @param  {String} tag
     */
    selectTab: function (tag) {
      var self = this
      // Wait between transitions
      if (
        $(this.$el)
          .find('.uses__block')
          .data('wait') === true
      ) {
        return
      }

      // Call transition leave with a call back
      this.tabTransitionLeave(function () {
        // Select tab then call transition on next tick
        self.activeTab = tag
        self.selectedTab = tag
        self.$nextTick(function () {
          self.tabTransitionEnter()
        })
      })
    },

    /**
     * Generate tag route
     * @param  {String} tag
     * @return {Object} Route
     */
    tagRoute: function (tag) {
      // Default route
      var route = {
        name: 'products',
        query: {
          tags: [tag]
        }
      }

      // Find first products link
      var routePath = null
      this.$config.NAV.forEach(function (link) {
        if (routePath === null && link.path.startsWith('/products')) {
          routePath = link.path
        }
      })

      if (routePath) {
        route = {
          path: routePath,
          query: {
            tags: [tag]
          }
        }
      }

      return route
    },

    /**
     * This middleware tag route was made to search a match when the products on topics are from a
     * similar tags name
     * @param {string} tag
     * @param {string[]} ProductTagList
     */
    middlewareTagRoute: function (tag, productTagList) {
      if (productTagList.includes(tag)) {
        return this.tagRoute(tag)
      } else {
        let rightTag
        productTagList.forEach(tagItem => {
          if (this.synonymousWords(tagItem, tag)) {
            rightTag = this.tagRoute(tagItem)
          }
        })
        if (rightTag) {
          return rightTag
        } else {
          return this.tagRoute(tag)
        }
      }
    },

    /**
     * Toggle topic modal
     * @param  {Integer} index
     */
    toggleTopicModal: function (index, topic = null) {
      if (topic) {
        // GS event tracker
        if (this.$gsClient) {
          this.$gsClient.track('Education Articles', {
            event_category: 'view',
            name: topic.title,
            value: topic.article_id
          })
        }
      }
      if (this.showModal === index) {
        this.showModal = null
      } else {
        this.showModal = index
      }
    }
  }
}
</script>

<style scoped lang="scss">
.screen {
  padding: 85px 90px 0 90px;
}

.hidden {
  display: none;
}

.section {
  position: relative;

  &--education {
    &__title {
      display: block;
      padding: 0 0 0.63em;
      margin: 0 0 2.5em;
      position: relative;

      font: 0.8em/1 var(--font-bold);
      letter-spacing: 0.1em;
      text-transform: uppercase;

      &__line {
        display: block;
        position: absolute;
        bottom: 0;
        left: 0;
        width: 1.25em;
        height: 0.25em;

        background: var(--main-color);
        transform-origin: 0 0;
      }
    }
  }

  &__separator {
    display: block;
    position: absolute;
    bottom: -40px;
    left: 0;
    width: 100%;
    height: 1px;

    background: rgba($white, 0.1);
  }
}

.topics {
  display: flex;
  margin: 0 -90px;
  padding: 0 90px 2.5em;
  position: relative;

  flex-direction: row;
  overflow-x: scroll;
  overflow-y: hidden;
  mask-image: linear-gradient(to right,
      transparent 0%,
      rgba(0, 0, 0, 1) 10%,
      rgba(0, 0, 0, 1) 90%,
      transparent 100%);
}

.topic {
  flex-grow: 0;
  flex-shrink: 0;

  &__card {
    display: flex;
    margin: 0 2.5em 0 0;
    width: 22em;

    align-content: flex-start;
    align-items: flex-start;
    flex-direction: row;
    justify-content: center;
  }

  &__icon {
    margin: 0 35px 0 0;
    position: relative;
    width: 128px;
    height: 128px;

    flex-grow: 0;
    flex-shrink: 0;

    &__shape {
      margin: -45px 0 0 -45px;
      position: absolute;
      top: 50%;
      left: 50%;
      width: 90px;
      height: 90px;

      background-image: url("~@/assets/img/category-default.svg");
      background-position: center;
      background-repeat: no-repeat;
      background-size: contain;
      content: "";
      z-index: 2;

      &--icon-capsule {
        background-image: url("~@/assets/img/category-capsule.svg");
      }

      &--icon-clone {
        background-image: url("~@/assets/img/category-clone.svg");
      }

      &--icon-concentrate,
      &--icon-extract {
        background-image: url("~@/assets/img/category-concentrate.svg");
      }

      &--icon-drink {
        background-image: url("~@/assets/img/category-drink.svg");
      }

      &--icon-edible {
        background-image: url("~@/assets/img/category-edible.svg");
      }

      &--icon-flower {
        background-image: url("~@/assets/img/category-flower.svg");
      }

      &--icon-merch {
        background-image: url("~@/assets/img/category-merch.svg");
      }

      &--icon-other {
        background-image: url("~@/assets/img/category-other.svg");
      }

      &--icon-preroll {
        background-image: url("~@/assets/img/category-preroll.svg");
      }

      &--icon-seed {
        background-image: url("~@/assets/img/category-seed.svg");
      }

      &--icon-tincture {
        background-image: url("~@/assets/img/category-tincture.svg");
      }

      &--icon-topical {
        background-image: url("~@/assets/img/category-topical.svg");
      }

      &--icon-vape,
      &--icon-cartridge {
        background-image: url("~@/assets/img/category-vape.svg");
      }
    }

    &__background {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      background-color: $charade;
      border-radius: 50%;
      z-index: 1;
    }
  }

  &__title {
    margin: 0.75em 0 0.5em;

    font: 1em var(--font-extralight);
  }

  &__intro {
    margin: 0 0 0.31em;

    opacity: 0.6;

    font-size: 0.8em;
    line-height: 1.375;
  }

  &__more {
    display: inline-block;
    padding: 0 0 0 1.13em;
    position: relative;

    color: rgba($white, 0.2);
    font: 0.75em var(--font-extrabold);
    letter-spacing: 0.1em;
    text-transform: uppercase;

    &__icon {
      display: block;
      position: absolute;
      top: 0.33em;
      left: 0;
      width: 0.73em;
      height: 0.73em;

      &:before,
      &:after {
        position: absolute;
        top: 0;
        left: 0;

        width: 0.73em;
        height: 0.2em;

        background: var(--main-color);
        content: "";
      }

      &:after {
        transform: rotateZ(90deg);
      }
    }
  }
}

.topic-modal {
  display: flex;
  height: 36em;

  align-content: flex-start;
  align-items: stretch;
  flex-direction: row;
  justify-content: spawce-between;

  &__content {
    width: 45em;

    color: rgba($white, 0.6);
  }

  &__header {
    margin: 0 0 50px;
    padding: 6px 0 0 100px;
    position: relative;
  }

  &__icon {
    position: absolute;
    top: 0;
    left: 0;
    width: 70px;
    height: 70px;

    background-color: $charade;
    border-radius: 50%;
    flex-grow: 0;
    flex-shrink: 0;

    &:after {
      display: block;
      position: absolute;
      top: 50%;
      left: 50%;
      width: 50px;
      height: 50px;

      background-image: url("~@/assets/img/category-default.svg");
      background-position: center;
      background-repeat: no-repeat;
      background-size: contain;
      content: "";
      transform: translate3d(-50%, -50%, 0);
    }

    &--icon-capsule:after {
      background-image: url("~@/assets/img/category-capsule.svg");
    }

    &--icon-clone:after {
      background-image: url("~@/assets/img/category-clone.svg");
    }

    &--icon-concentrate:after,
    &--icon-extract:after {
      background-image: url("~@/assets/img/category-concentrate.svg");
    }

    &--icon-drink:after {
      background-image: url("~@/assets/img/category-drink.svg");
    }

    &--icon-edible:after {
      background-image: url("~@/assets/img/category-edible.svg");
    }

    &--icon-flower:after {
      background-image: url("~@/assets/img/category-flower.svg");
    }

    &--icon-merch:after {
      background-image: url("~@/assets/img/category-merch.svg");
    }

    &--icon-other:after {
      background-image: url("~@/assets/img/category-other.svg");
    }

    &--icon-preroll:after {
      background-image: url("~@/assets/img/category-preroll.svg");
    }

    &--icon-seed:after {
      background-image: url("~@/assets/img/category-seed.svg");
    }

    &--icon-tincture:after {
      background-image: url("~@/assets/img/category-tincture.svg");
    }

    &--icon-topical:after {
      background-image: url("~@/assets/img/category-topical.svg");
    }

    &--icon-vape:after,
    &--icon-cartridge:after {
      background-image: url("~@/assets/img/category-vape.svg");
    }
  }

  &__title {
    margin: 0;

    color: $white;
    font: 3em var(--font-extralight);
  }

  &__body {
    overflow-x: hidden;
    overflow-y: scroll;
    max-height: 600px;

    mask-image: linear-gradient(to bottom,
        transparent 0%,
        rgba(0, 0, 0, 1) 5%,
        rgba(0, 0, 0, 1) 95%,
        transparent 100%);
    mask-origin: padding-box;
  }

  &__aside {
    margin: -60px -80px -60px 0;
    padding: 4.5em 50px 50px;
    position: relative;
    width: 440px;
    box-sizing: border-box;
    box-sizing: border-box;

    flex-grow: 0;
    flex-shrink: 0;
    z-index: 1;

    &__inner {
      position: relative;
      height: 100%;
      overflow-y: auto;
      z-index: 2;
    }

    &__background {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;

      background: lighten($shark, 2%);
      z-index: 1;
    }

    &__title {
      display: block;
      padding: 0 0 0.63em;
      margin: 0 0 2.5em;
      position: relative;

      font: 0.8em/1 var(--font-bold);
      letter-spacing: 0.1em;
      text-transform: uppercase;

      &__line {
        display: block;
        position: absolute;
        bottom: 0;
        left: 0;
        width: 1.25em;
        height: 0.25em;

        background: var(--main-color);
        transform-origin: 0 0;
      }
    }

    &__products {
      >>>.product-card {
        margin: 30px 0 0;
        width: 100%;

        &:first-child {
          margin-top: 0;
        }
      }

      /deep/ .product-image {
        margin-left: auto !important;
        margin-right: auto !important;
        width: 200px !important;
        height: 200px !important;
      }

      /deep/ .product-card__info {
        text-align: center;
      }

      /deep/ .product-card__add-to-cart {
        margin-left: auto;
        margin-right: auto;
      }

      /deep/ .product-image {
        margin-left: auto !important;
        margin-right: auto !important;
        width: 200px !important;
        height: 200px !important;
      }

      /deep/ .product-card__info {
        text-align: center;
      }

      /deep/ .product-card__add-to-cart {
        margin-left: auto;
        margin-right: auto;
      }

      /deep/ .product-card .product-card__name {
        @at-root .app--tablet & {
          font-size: 1em;
        }
      }
    }

    &__button {
      display: block;
      margin: 3.33em auto 0;
      position: relative;
      width: 10.83em;
      height: 4.17em;

      color: $white;
      font: 0.6em/4.17em var(--font-extrabold);
      letter-spacing: 0.05em;
      text-align: center;
      text-transform: uppercase;

      &__text {
        position: relative;

        z-index: 2;
      }

      &__background {
        position: absolute;
        top: 0;
        left: 50%;
        width: 100%;
        height: 100%;

        background: var(--main-color);
        border-radius: 2.08em;
        transform: translate3d(-50%, 0, 0);
        z-index: 1;
      }
    }
  }

  &--has-products {
    .topic-modal__content {
      width: calc(100% - 360px);
    }
  }
}

.section--uses {
  margin: 20px 0 0;
  padding: 60px 0 0;
  position: relative;

  &__title {
    margin: 0;
    font: 80px var(--font-extralight);
  }
}

.uses {
  &__tabs {
    margin: 30px 0 40px;

    ul {
      margin: 0;
      padding: 0;

      list-style: none;
    }
  }

  &__tab {
    display: inline-block;
    margin: 0 2em 0 0;
    position: relative;

    transition: color 0.1s linear 0.15s;

    color: rgba($white, 0.3);
    font: 0.75em/1 var(--font-extrabold);
    letter-spacing: 0.1em;
    text-transform: uppercase;

    &:last-child {
      margin-right: 0;
    }

    &__line {
      position: absolute;
      left: 0;
      bottom: -0.67em;
      width: 100%;
      height: 0.27em;

      background-color: var(--main-color);
      transform: scaleX(0);
      transition: transform 0.5s cubic-bezier(0.77, 0, 0.175, 1);
    }

    &--is-active {
      transition-delay: 0.1s;

      color: $white;

      .uses__tab__line {
        transform: scaleX(1);
      }
    }
  }
}

.use {
  &__products {
    display: flex;
    margin: 0 -10px;
    padding: 0 10px;
    width: calc(100% + 20px);

    align-content: flex-start;
    align-items: flex-start;
    flex-direction: row;
    flex-grow: 1;
    flex-shrink: 1;
    flex-wrap: wrap;
    justify-content: flex-start;
    // overflow-x: hidden;
    // overflow-y: visible;

    >>>.product-card {
      margin: 30px 45px 0 0;
      width: calc(33% - 30px);

      &:nth-child(-n + 3) {
        margin-top: 0;
      }

      &:nth-child(3n + 3) {
        margin-right: 0;
      }

      &:last-child {
        margin-bottom: 45px;
      }
    }

    /deep/ .product-card__inner {
      display: flex;
      flex-direction: row;
    }

    /deep/ .product-card__info {
      max-width: 250px;
    }

    /deep/ .product-card__name {
      max-height: 28px;
      width: 100%;
      overflow-x: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    /deep/ .promotion {
      min-width: 80px !important;
      min-height: 80px !important;
      max-width: 80px !important;
      max-height: 80px !important;
      width: 80px !important;
      height: 80px !important;
    }

    /deep/ .text {
      font-size: 1rem !important;
    }

    /deep/ .min-text {
      font-size: 0.9rem !important;
    }

    /deep/ .min-sm-text {
      font-size: 0.8rem !important;
    }

    /deep/ .product-image {
      width: 130px !important;
      height: 130px !important;
    }

    /deep/ .product-card__inner {
      display: flex;
      flex-direction: row;
    }

    /deep/ .product-card__info {
      max-width: 250px;
    }

    /deep/ .product-card__name {
      max-height: 28px;
      width: 100%;
      overflow-x: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    /deep/ .promotion {
      min-width: 80px !important;
      min-height: 80px !important;
      max-width: 80px !important;
      max-height: 80px !important;
      width: 80px !important;
      height: 80px !important;
    }

    /deep/ .text {
      font-size: 1rem !important;
    }

    /deep/ .min-text {
      font-size: 0.9rem !important;
    }

    /deep/ .min-sm-text {
      font-size: 0.8rem !important;
    }

    /deep/ .product-image {
      width: 130px !important;
      height: 130px !important;
    }
  }

  &__button {
    display: block;
    margin: 5em 0 0;
    position: relative;
    width: 16.25em;
    height: 4.17em;

    color: $white;
    font: 0.6em/4.17em var(--font-extrabold);
    letter-spacing: 0.05em;
    text-align: center;
    text-transform: uppercase;

    &__text {
      display: block;
      position: relative;

      z-index: 2;
    }

    &__background {
      position: absolute;
      top: 50%;
      left: 50%;
      width: 100%;
      height: 100%;

      background: var(--main-color);
      border-radius: 2.08em;
      transform: translate3d(-50%, -50%, 0);
      z-index: 1;
    }
  }
}
</style>
