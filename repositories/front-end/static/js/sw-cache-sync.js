/* eslint-disable no-redeclare */
/* eslint-disable no-unused-vars */
self.ressourcesToCache = {api: [], asset: []}
self.queueApiProcessing = false
self.queueAssetProcessing = false
self.firstPass = null

/**
 * Check cache
 */
function checkCache () {
  if (self.kioskConfig.SW_LOG === true) {
    console.log('Start checking cache...')
  }

  if (self.firstPass === null) {
    self.firstPass = true
  } else if (self.firstPass === true) {
    self.firstPass = false
  }

  // checkArticles()
  // checkBrands()
  // checkCategories()
  // checkProducts()
  // checkRfids()
  // checkSettings()
}

/**
 * Check articles cache
 */
function checkArticles () {
  var articlesURL = ressourceURL('articles', { minimal: true })
  // var tagsURL = ressourceURL('tags', {'featured_tags': 'true'})

  fetch(articlesURL)
    .then(
      function (response) {
        if (response.status !== 200) {
          if (self.kioskConfig.SW_LOG === true) {
            console.log('Looks like there was a problem. Status Code: ' +
              response.status)
          }
          return
        }

        if (self.kioskConfig.SW_LOG === true) {
          console.log('Updating articles...')
        }

        cacheRessource(articlesURL, response, 'api')

        /* fetch(tagsURL)
          .then(
            function (response) {
              if (response.status !== 200) {
                if (self.kioskConfig.SW_LOG === true) {
                  console.log('Looks like there was a problem. Status Code: ' +
                    response.status)
                }
                return
              }

              if (self.kioskConfig.SW_LOG === true) {
                console.log('Updating tags...')
              }

              cacheRessource(tagsURL, response, 'api')

              processQueue()
            }
          )
          .catch(function (err) {
            if (self.kioskConfig.SW_LOG === true) {
              console.log('Fetch Error :-S', err)
            }
          }) */

        processQueue()
      }
    )
    .catch(function (err) {
      if (self.kioskConfig.SW_LOG === true) {
        console.log('Fetch Error :-S', err)
      }
    })
}

/**
 * Check brands cache
 */
function checkBrands () {
  var brandsURL = ressourceURL('brands', {'per_page': 9999})

  fetch(brandsURL)
    .then(
      function (response) {
        if (response.status !== 200) {
          if (self.kioskConfig.SW_LOG === true) {
            console.log('Looks like there was a problem. Status Code: ' +
              response.status)
          }
          return
        }

        if (self.kioskConfig.SW_LOG === true) {
          console.log('Updating brands...')
        }

        response.json().then(function (data) {
          var onlineBrands = data.brands

          caches.open('kiosk-api-cache').then(function (cache) {
            cache.match(brandsURL).then(function (response) {
              if (response !== undefined) {
                var cacheBrands = data.brands

                compareAndCacheRessourcesAssets(onlineBrands, cacheBrands)
              } else {
                compareAndCacheRessourcesAssets(onlineBrands, null)
              }

              queueRessource(brandsURL)

              processQueue()
            })
          })
        })
      }
    )
    .catch(function (err) {
      if (self.kioskConfig.SW_LOG === true) {
        console.log('Fetch Error :-S', err)
      }
    })
}

/**
 * Check categories cache
 */
function checkCategories () {
  var categoriesURL = ressourceURL('categories')

  fetch(categoriesURL)
    .then(
      function (response) {
        if (response.status !== 200) {
          if (self.kioskConfig.SW_LOG === true) {
            console.log('Looks like there was a problem. Status Code: ' +
              response.status)
          }
          return
        }

        if (self.kioskConfig.SW_LOG === true) {
          console.log('Updating categories...')
        }

        cacheRessource(categoriesURL, response.clone(), 'api')

        // Loop through ressources
        response.json().then(function (data) {
          var categories = data.categories

          categories.forEach(function (category) {
            cacheRessourceAssets(category)
          })
        })

        processQueue()
      }
    )
    .catch(function (err) {
      if (self.kioskConfig.SW_LOG === true) {
        console.log('Fetch Error :-S', err)
      }
    })
}

/**
 * Check products cache
 */
function checkProducts () {
  var productsURL = ressourceURL('products/minimal')

  fetch(productsURL)
    .then(
      function (response) {
        if (response.status !== 200) {
          if (self.kioskConfig.SW_LOG === true) {
            console.log('Looks like there was a problem. Status Code: ' +
              response.status)
          }
          return
        }

        if (self.kioskConfig.SW_LOG === true) {
          console.log('Fetching products')
        }

        cacheRessource(productsURL, response.clone(), 'api')

        response.clone().json().then(function (data) {
          parseProducts(data.products)
        })
      }
    )
    .catch(function (err) {
      if (self.kioskConfig.SW_LOG === true) {
        console.log('Fetch Error :-S', err)
      }
    })
}

/**
 * Parse fetched products
 * @param  {Array} fetchedProducts Fetched products
 */
function parseProducts (fetchedProducts) {
  if (self.kioskConfig.SW_LOG === true) {
    console.log('Parsing products...')
  }

  // Loop through ressources
  fetchedProducts.forEach(function (onlineProduct) {
    if (onlineProduct.stock <= 0) {
      return
    }

    var productURL = ressourceURL('products/' + onlineProduct.id)
    var similarProductsURL = ressourceURL('products/' + onlineProduct.id + '/similars', {'per_page': 50, 'minimal': true})

    // console.log('In queue ' + productURL + ' ? ' + self.ressourcesToCache.api.indexOf(productURL))
    if (self.ressourcesToCache.api.indexOf(productURL) !== -1) {
      return
    }

    caches.open('kiosk-api-cache').then(function (cache) {
      cache.match(productURL).then(function (response) {
        if (response !== undefined) {
          var onlineUpdateDate = new Date(onlineProduct.updated_at)
          response.json().then(function (data) {
            var cacheProduct = data.product
            var cacheUpdateDate = new Date(cacheProduct.updated_at)

            if (onlineUpdateDate > cacheUpdateDate) {
              // Live product is newer than cache
              if (self.kioskConfig.SW_LOG === true) {
                console.log('Product ' + onlineProduct.id + ' update: ' + onlineUpdateDate.toUTCString() + ' > ' + cacheUpdateDate.toUTCString())
              }

              queueRessource(productURL)
              queueRessource(similarProductsURL)
            } else {
              // Live product is older than cache
              if (self.kioskConfig.SW_LOG === true) {
                console.log('Product ' + onlineProduct.id + ' ignore: ' + onlineUpdateDate.toUTCString() + ' <= ' + cacheUpdateDate.toUTCString())
              }

              // Check if similar products URL is cached
              cache.match(similarProductsURL).then(function (response) {
                if (response === undefined) {
                  // Similar products url not in cache
                  if (self.kioskConfig.SW_LOG === true) {
                    console.log('Similar products ' + onlineProduct.id + ' add')
                  }

                  queueRessource(similarProductsURL)
                }
              })

              if (self.firstPass) {
                cacheRessourceAssets(cacheProduct)
              }
            }
          })
        } else {
          // Live product not in cache
          if (self.kioskConfig.SW_LOG === true) {
            console.log('Product ' + onlineProduct.id + ' add')
          }
          queueRessource(productURL)
          queueRessource(similarProductsURL)
        }

        processQueue()
      })
    })
  })
}

/**
 * Check rfids cache
 */
function checkRfids () {
  var rfidsURL = ressourceURL('rfids')

  fetch(rfidsURL)
    .then(
      function (response) {
        if (response.status !== 200) {
          if (self.kioskConfig.SW_LOG === true) {
            console.log('Looks like there was a problem. Status Code: ' +
              response.status)
          }
          return
        }

        if (self.kioskConfig.SW_LOG === true) {
          console.log('Updating rfids...')
        }

        cacheRessource(rfidsURL, response, 'api')

        processQueue()
      }
    )
    .catch(function (err) {
      if (self.kioskConfig.SW_LOG === true) {
        console.log('Fetch Error :-S', err)
      }
    })
}

/**
 * Check settings cache
 */
function checkSettings () {
  var settingsURL = ressourceURL('settings')

  fetch(settingsURL)
    .then(
      function (response) {
        if (response.status !== 200) {
          if (self.kioskConfig.SW_LOG === true) {
            console.log('Looks like there was a problem. Status Code: ' +
              response.status)
          }
          return
        }

        if (self.kioskConfig.SW_LOG === true) {
          console.log('Updating settings...')
        }

        response.json().then(function (data) {
          var onlineSettings = data

          caches.open('kiosk-api-cache').then(function (cache) {
            cache.match(settingsURL).then(function (response) {
              if (response !== undefined) {
                var cacheSettings = data

                compareAndCacheRessourcesAssets(onlineSettings, cacheSettings)
              } else {
                compareAndCacheRessourcesAssets(onlineSettings, null)
              }

              queueRessource(settingsURL)

              processQueue()
            })
          })
        })
      }
    )
    .catch(function (err) {
      if (self.kioskConfig.SW_LOG === true) {
        console.log('Fetch Error :-S', err)
      }
    })
}

/**
 * Create ressource URL
 * @param  {string} endpoint API endpoint
 * @param  {object} params   Query params
 * @return {string}          Ressource URL
 */
function ressourceURL (endpoint, params = {}) {
  // Add token to params
  params.token = self.kioskConfig.API.TOKEN

  if (endpoint !== 'stores') {
    // Add catalog ID
    endpoint = self.kioskConfig.API.CATALOG_ID + '/' + endpoint
  }

  // Create query params
  var queryParams = []
  for (var param in params) { queryParams.push(encodeURIComponent(param) + '=' + encodeURIComponent(params[param])) }
  queryParams = queryParams.join('&')

  return self.kioskConfig.API.URL + '/' + endpoint + '?' + queryParams
}

/**
 * Queue ressource to fetch
 * @param  {string} ressourceURL Ressource URL
 * @param  {string} type         Ressource type
 */
function queueRessource (ressourceURL, type = 'api') {
  if (self.ressourcesToCache[type].indexOf(ressourceURL) === -1) {
    self.ressourcesToCache[type].push(ressourceURL)
  }
}

/**
 * Delete ressource from cache
 * @param  {string} ressourceURL Ressource URL
 * @param  {string} type         Ressource type
 */
function deleteRessource (ressourceURL, type = 'api') {
  var key = 'kiosk-asset-cache'

  if (type === 'api') {
    key = 'kiosk-api-cache'
  }

  caches.open(key).then(function (cache) {
    cache.delete(ressourceURL).then(function (response) {
      if (self.kioskConfig.SW_LOG === true) {
        console.log('Ressource deleted from cache: ' + ressourceURL)
      }
    })
  })
}

/**
 * Fetch and add ressource to cache
 * @param  {string} ressourceURL URL to fetch
 * @param  {string} type         Ressource type
 */
function fetchAndCache (ressourceURL, type = 'api') {
  var fetchHeaders = new Headers()
  fetchHeaders.append('Access-Control-Allow-Origin', '*')

  var fetchInit = {
    method: 'GET',
    headers: fetchHeaders,
    mode: 'cors'
  }

  fetch(ressourceURL, fetchInit).then(function (response) {
    cacheRessource(ressourceURL, response, type)
  })
}

/**
 * Cache ressource
 * @param  {string} ressourceURL Ressource's URL
 * @param  {string} response    Fetch response
 */
function cacheRessource (ressourceURL, response, type = 'api') {
  var key = 'kiosk-asset-cache'
  if (type === 'api') {
    key = 'kiosk-api-cache'
  }

  caches.open(key).then(function (cache) {
    if (self.kioskConfig.SW_LOG === true) {
      console.log('Ressource added to cache: ' + ressourceURL)
    }
    cache.put(ressourceURL, response.clone())

    if (self.ressourcesToCache[type].includes(ressourceURL)) {
      var index = self.ressourcesToCache[type].indexOf(ressourceURL)
      self.ressourcesToCache[type].splice(index, 1)
    }
  })
}

/**
 * Compare assets date and cache them
 * @param  {object} onlineAsset Online asset
 * @param  {object} cacheAsset  Cache asset
 */
function compareAndCacheAssets (onlineAsset, cacheAsset) {
  if (onlineAsset !== null) {
    if (cacheAsset === null) {
      if (self.kioskConfig.SW_LOG === true) {
        console.log('Add asset', onlineAsset.url)
      }

      queueRessource(onlineAsset.url, 'asset')
    } else {
      var onlineAssetUpdateDate = new Date(onlineAsset.updated_at)
      var cacheAssetUpdateDate = new Date(cacheAsset.updated_at)

      if (onlineAssetUpdateDate > cacheAssetUpdateDate) {
        // Live image is newer than cache
        if (self.kioskConfig.SW_LOG === true) {
          console.log('Update asset: ' + onlineAssetUpdateDate.toUTCString() + ' > ' + cacheAssetUpdateDate.toUTCString())
        }

        // Add new asset to cache
        queueRessource(onlineAsset.url, 'asset')

        // Delete old asset from cache
        deleteRessource(cacheAsset.url, 'asset')
      }
    }
  }
}

/**
 * Loop through an object and cache assets by comparing to the object in cache
 * @param {Object} object Object to loop through
 */
function compareAndCacheRessourcesAssets (onlineRessource, cacheRessource) {
  // Get online assets
  var onlineRessourceAssets = {}
  recursivelyFindAssets(onlineRessource, onlineRessourceAssets)

  if (cacheRessource) {
    // Get cache assets
    var cacheRessourceAssets = {}
    recursivelyFindAssets(cacheRessource, cacheRessourceAssets)

    for (var onlineAssetId in onlineRessourceAssets) {
      var onlineAsset = onlineRessourceAssets[onlineAssetId]

      if (cacheRessourceAssets[onlineAssetId]) {
        // Asset exists in cache, compare
        var cacheAsset = cacheRessourceAssets[onlineAssetId]

        compareAndCacheAssets(onlineAsset, cacheAsset)

        // Delete this asset from cache object
        delete cacheRessourceAssets[onlineAssetId]
      } else {
        // Asset doesn't exist in cache, cache it
        compareAndCacheAssets(onlineAsset, null)
      }
    }

    // Delete assets that are in cache but not online
    for (var cacheAssetId in cacheRessourceAssets) {
      var cacheAsset = cacheRessourceAssets[cacheAssetId]

      // Delete old asset from cache
      deleteRessource(cacheAsset.url, 'asset')
    }
  } else {
    // Assets dont exist in cache, cache them
    for (var onlineAssetId in onlineRessourceAssets) {
      var onlineAsset = onlineRessourceAssets[onlineAssetId]
      compareAndCacheAssets(onlineAsset, null)
    }
  }
}

/**
 * Loop through an object and cache assets by comparing to asset cache
 * @param {Object} object Object to loop through
 */
function cacheRessourceAssets (onlineRessource) {
  if (self.kioskConfig.SW_LOG === true) {
    console.log('Check ressource assets: ' + onlineRessource.id)
  }

  // Get online assets
  var onlineRessourceAssets = {}
  recursivelyFindAssets(onlineRessource, onlineRessourceAssets)

  // Check if assets are cached
  caches.open('kiosk-asset-cache').then(async function (assetCache) {
    // Loop through assets and cache them
    for (var onlineAssetId in onlineRessourceAssets) {
      var onlineAsset = onlineRessourceAssets[onlineAssetId]

      await assetCache.match(onlineAsset.url).then(function (response) {
        if (response === undefined) {
          queueRessource(onlineAsset.url, 'asset')
        }
      })
    }
  })
}

/**
 * Loop through an object and return assets
 * @param  {object} ressource Object to loop through
 * @param  {array} assets    Assets found
 */
function recursivelyFindAssets (ressource, assets) {
  var propertyNames = ['asset', 'logo', 'background_media', 'primary_image', 'thumb_image', 'images', 'banner']

  for (var property in ressource) {
    if (propertyNames.includes(property) && ressource[property]) {
      assets[ressource[property].id] = ressource[property]
    } else {
      if (typeof ressource[property] === 'object') {
        recursivelyFindAssets(ressource[property], assets)
      }
    }
  }

  return assets
}

/**
 * Process queue
 */
function processQueue () {
  // Process api queue
  if (self.queueApiProcessing === false && self.ressourcesToCache.api.length > 0) {
    if (self.kioskConfig.SW_LOG === true) {
      console.log('Process API queue: ' + JSON.stringify(self.ressourcesToCache.api))
    }

    fetchNextRessource('api')
  }

  // Process asset queue
  if (self.queueAssetProcessing === false && self.ressourcesToCache.asset.length > 0) {
    if (self.kioskConfig.SW_LOG === true) {
      console.log('Process asset queue: ' + JSON.stringify(self.ressourcesToCache.asset))
    }

    fetchNextRessource('asset')
  }
}

/**
 * Fetch next ressource in queue
 * @param  {String} type Ressource type
 */
function fetchNextRessource (type = 'api') {
  if (type === 'api') {
    self.queueApiProcessing = true
  } else {
    self.queueAssetProcessing = true
  }

  if (self.ressourcesToCache[type].length === 0) {
    if (type === 'api') {
      self.queueApiProcessing = false
    } else {
      self.queueAssetProcessing = false
    }

    return false
  } else {
    var ressourceURL = self.ressourcesToCache[type].shift()

    if (self.kioskConfig.SW_LOG === true) {
      console.log('Fetching ' + type + ' ressource', ressourceURL)
    }

    var fetchHeaders = new Headers()
    fetchHeaders.append('Access-Control-Allow-Origin', '*')

    var fetchInit = {
      method: 'GET',
      headers: fetchHeaders,
      mode: 'cors',
      referrerPolicy: 'origin',
      cache: 'no-store'
    }

    fetch(ressourceURL, fetchInit)
      .then(function (response) {
        if (response.status !== 200) {
          if (self.kioskConfig.SW_LOG === true) {
            console.log('Looks like there was a problem. Status Code: ' +
              response.status)
          }
          return
        }

        // Cache products assets
        if (ressourceURL.search(/\/products\/(\d+)\?/gm) > -1) {
          response.clone().json().then(function (data) {
            var onlineProduct = data.product

            cacheRessourceAssets(onlineProduct)
          })
        }

        cacheRessource(ressourceURL, response.clone(), type)

        fetchNextRessource(type)
      })
      .catch(function (err) {
        if (self.kioskConfig.SW_LOG === true) {
          console.log('Fetch Error :-S', err)
        }

        fetchNextRessource(type)
      })
  }
}

// Catch check cache message
self.addEventListener('message', function (event) {
  if (event.data === 'check cache') {
    checkCache()
  }
})
