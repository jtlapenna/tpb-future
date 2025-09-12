import { useEffect, useState, useCallback, useRef } from 'react'
import { useHistory } from 'react-router-dom'
import { makeStyles, useTheme } from '@material-ui/core/styles'
import {
  Typography,
  Box,
  useMediaQuery,
  ClickAwayListener,
} from '@material-ui/core'
import MenuIcon from '@material-ui/icons/Menu'
import MenuOpenIcon from '@material-ui/icons/MenuOpen'
import clsx from 'clsx'
import { FixedSizeGrid as ReactWindowGrid } from 'react-window'
import KeyboardArrowDownIcon from '@material-ui/icons/KeyboardArrowDown';
import KeyboardArrowUpIcon from '@material-ui/icons/KeyboardArrowUp';
import { useUserFacade } from 'state/user'
import { useFavoritesFacade } from 'state/favorites'
import { httpGet, httpPost } from '../../services/http-client.service'
import { useQuery } from 'utils'
import { IProduct } from 'types'
import { IsUserLoggedIn } from '../../services/authentication.service'
import { MobileSidebar } from 'components'
import { TextWidget, ProductCard, BackButton, HomeButton } from 'components/_ui'

const useStyles = makeStyles((theme) => ({
  categoriesContainer: {
    background: 'rgba(0, 0, 0, 0.3)',
    overflowY: 'scroll',
    maxWidth: '220px',
    flexShrink: 0,
    boxSizing: 'border-box',
    paddingLeft: 20,
    animation: 'slideInWithTransationFromLeft 0.5s ease',

    '& ul': {
      listStyle: 'none',
      color: 'white',
      textAlign: 'center',
      padding: '0 !important',
    },

    [theme.breakpoints.down('sm')]: {
      position: 'absolute',
      top: 0,
      bottom: 0,
      left: '-100%',
      transition: 'all 0.3s ease',
      padding: '0px',

     '&.show': {
        left: 0,
        zIndex: 10,
        background: 'black',
      },
    },

    '&::-webkit-scrollbar': {
      width: '15px !important',
    },

    '&::-webkit-scrollbar-thumb': {
      background: 'rgba(255, 255, 255, 0.05)',
      backgroundClip: 'padding-box',
      borderRadius: 20,
      width: 10,
    },
  },
  sortContainer: {
    position: 'absolute',
    top: '50vh',
    left: 10,
    transform: 'translateY(-50%)',
    animation: 'slideInWithTransationFromLeft 1s ease',

    [theme.breakpoints.down('sm')]: {
      position: 'fixed',
      maxHeight: '65vh',
      overflowY: 'auto',
    },
  },
  sortItem: {
    margin: '10px 0 0',
    width: '40px',
    height: '40px',
    lineHeight: '40px',
    background: 'rgba(255, 255, 255, 0.1)',
    borderRadius: '5px',
    color: 'rgba(255, 255, 255, 0.35)',
    textAlign: 'center',
    cursor: 'pointer',
    letterSpacing:'.1em',
    fontSize:'11pt',
    fontFamily:'mulibold',

    [theme.breakpoints.down('xs')]: {
      width: '30px',
      height: '30px',
      fontSize: 14,
      lineHeight: '30px',
    },

    '&.active': {
      color: 'white',
    },

    '&:first-child': {
      marginTop: 0,
    },

    '& .sort-arrow': {
      display: 'inline-block',
      position: 'relative',
      width: 1,
      height: 12,
      background: '#ffffff',
      opacity: '0.35',
      marginLeft: 2,

      '&::before, &::after': {
        display: 'block',
        position: 'absolute',
        bottom: 0,
        left: 0,
        width: 1,
        height: 5,
        background: '#ffffff',
        content: '""',
        transformOrigin: '50% 100%',
      },

      '&::before': {
        transform: 'rotateZ(-35deg)',
      },

      '&::after': {
        transform: 'rotateZ(35deg)',
      },

      '&.arrow-up': {
        transform: 'rotateZ(180deg)',
      },
    },
  },
  filterItem: {
    transition: 'all 0.3s linear',
    cursor: 'pointer',
    width: 'calc(100% - 20px)',
    marginLeft: 'auto',
    marginRight: 'auto',
    marginTop: 20,
    padding: '20px 5px 20px',
    borderRadius: 25,
    color: 'rgba(255, 255, 255, 0.5)',
    position: 'relative',
    
    '& p': {
      fontFamily:'muliextrabold !important',
      letterSpacing:'.1em',
      fontSize:'14px',
    },

    '& .close': {
      display: 'none',
    },

    '&.active': {
      background: 'rgba(255, 255, 255, 0.1)',
      color: 'white',

      '& .close': {
        opacity: 0.35,
        display: 'inline-block',
      },
    },
  },
  productsContainer: {
    overflowY: 'scroll',
    paddingLeft: '1rem',
    paddingRight: '1rem',
    boxSizing: 'border-box',
    animation: 'slideInWithTransationFromLeft 1.5s ease',

    [theme.breakpoints.down('xs')]: {
      paddingLeft: '0',
      paddingRight: '0',
    },
  },
  categoryHeader: {
    paddingTop: 8,
    marginTop: 0,
    textAlign: 'left',
    fontFamily: 'mulibold !important',
  },
  tagsHeader: {
    paddingTop: 8,
    marginTop: 0,
    textAlign: 'left',
  },
  tagsContainer: {
    marginTop: 4,
  },
  tagItem: {
    display: 'flex',
    alignItems: 'center',
  },
  tagTypography: {
    paddingRight: 0,
  },
  productGridItem: {
    // Base styles for grid items - positioning handled by React Window
  },
}))

const fetchProducts = async ({
  category,
  tag,
  storeId,
  sortBy,
  sortDirection,
  page,
  count,
  name,
}) => {
  const requestBody = {
    storeId,
    sortColumn: sortBy,
    sortDirection,
    page,
    count,
    name,
  }

  if (category) {
    requestBody['category'] = +category
  }
  if (tag) {
    requestBody['tag'] = tag
  }

  const products: IProduct[] = await httpPost('/products/all', requestBody)
  return products
}

export const Products: React.FC = () => {
  const classes = useStyles()
  const history = useHistory()
  const theme = useTheme()
  const matchesMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const query = useQuery()
  const { userState } = useUserFacade()
  const { store: userStore } = userState
  const { favorites, addFavorite, removeFavorite, loadFavorites } =
    useFavoritesFacade()

  useEffect(() => {
    if (IsUserLoggedIn() && userStore) loadFavorites(userStore)
  }, [loadFavorites, userStore])

  const [products, setProducts] = useState<IProduct[]>([])
  const [categories, setCategories] = useState<any>([])
  const [tags, setTags] = useState([])
  const [showTags, setShowTags] = useState<boolean>(false);
  const [showSearchBox, setShowSearchBox] = useState<boolean>(false);
  const [searchProductName, setSearchProductName] = useState<string>('');

  // States for filtering
  const [filterCategory, setFilterCategory] = useState<string>(
    query.get('category') || ''
  )
  const [filterTag, setFilterTag] = useState(query.get('tag') || '')
  const [sortBy, setSortBy] = useState(query.get('sortBy') || '')
  const [sortDirection, setSortDirection] = useState('asc')
  const [page, setPage] = useState(1)

  // States for UI
  const [showCategories, setShowCategories] = useState(false)
  const [width, setWidth] = useState(0)
  const [rowHeight, setRowHeight] = useState(390)
  const [columnCount, setColumnCount] = useState(4)

  const productsRef = useRef(null)
  const productsInnerRef = useRef(null)

  const getCategoryIcon = useCallback((category: string) => {
    let fileName = category.toLowerCase().replace(/s$|[ -]*/gi, '')

    if (fileName === 'extract') {
      fileName = 'concentrate'
    } else if (fileName === 'cartridge') {
      fileName = 'vape'
    } else if (fileName === 'accessorie') {
      fileName = 'accessories'
    }

    try {
      const file = require(`assets/icons/category-${fileName}.svg`).default
      return file
    } catch (e) {
      return null
    }
  }, [])

  const loadTags = async (storeId: string, categoryId =-1)=>{
    const tags = await httpGet(`/tags/all/${storeId}/1/0/${categoryId}`)
    setTags(tags)
  }

  useEffect(() => {
    const fetchCategoriesTags = async (storeId: string) => {
      const categories = await httpGet(`/category/all/${storeId}/name/1/0`)
      setCategories(categories)

      await loadTags(storeId);
    }
    if (userStore) fetchCategoriesTags(userStore)
  }, [userStore])

  useEffect(() => {
    if (page >= 2) setPage(1)
  }, [filterCategory, filterTag, sortBy])

  useEffect(() => {
    
    if (userStore) {
      fetchProductsData(userStore, searchProductName)
    }
  }, [
    filterCategory,
    filterTag,
    sortBy,
    page,
    sortDirection,
    history,
    userStore,
  ])

  const fetchProductsData = async (storeId: string,name?:string) => {
    const query = {}
    if (filterCategory) {
      query['category'] = filterCategory
    }

    if (filterTag) {
      query['tag'] = filterTag
    }

    if (sortBy) {
      query['sortBy'] = sortBy
    }

    history.push({
      pathname: '/products',
      search: new URLSearchParams(query).toString(),
    })

    const newProducts: IProduct[] = await fetchProducts({
      category: filterCategory,
      tag: filterTag,
      sortBy,
      sortDirection,
      storeId,
      page,
      count: 50,
      name:name || '',
    })
    if (page === 1) setProducts(newProducts)
    else setProducts([...products, ...newProducts])
  };

  useEffect(() => {
    if (productsRef && productsRef.current) {
      setWidth(
        (productsRef?.current as any).offsetWidth - (matchesMobile ? 8 : 64)
      )
    }
  }, [productsRef, matchesMobile])

  useEffect(() => {
    if (window.screen.width >= 1900) {
      setRowHeight(450)
      setColumnCount(4)
    } else if (width >= 799) {
      setRowHeight(420)
      setColumnCount(4)
    } else if (width >= 600) {
      setRowHeight(400)
      setColumnCount(3)
    } else if (width >= 400) {
      setRowHeight(410)
      setColumnCount(2)
    } else if (width >= 300) {
      setColumnCount(2)
      setRowHeight(370)
    } else if (width >= 100) {
      setColumnCount(2)
      setRowHeight(340)
    }
  }, [width])

  window.addEventListener('resize', () => {
    if (productsRef && productsRef.current) {
      setWidth(
        (productsRef?.current as any).offsetWidth - (matchesMobile ? 8 : 64)
      )
    }
  })

  const handleKeyPress = async (event) => {
    if(event.key === 'Enter'){
      setShowSearchBox(false);
      setSearchProductName(event.target.value);
      await fetchProductsData(userStore, event.target.value );
    }
  }

  const onScroll = useCallback(() => {
    if (productsInnerRef && productsInnerRef.current) {
      const outerRef = (productsInnerRef.current as any)._outerRef

      const { scrollTop, scrollHeight, clientHeight } = outerRef as any

      if (Math.ceil(scrollTop + clientHeight) === scrollHeight) {
        setPage((page) => page + 1)
      }
    }
  }, [productsInnerRef])

  return (
    <Box display="flex" maxHeight="100vh">
      <ClickAwayListener
        onClickAway={(e) => {
          if (matchesMobile && showCategories) {
            e.preventDefault()
            setShowCategories(false)
          }
        }}
      >
        <Box
          className={clsx(
            classes.categoriesContainer,
            showCategories && 'show'
          )}
        >
         

          {showSearchBox ? (
            <div className="product-search-by-name">
              <div className="flex flex-start">
                <div className="search-bar-category">
                </div>
                <div className='flex flex-center'>
                  <input autoFocus placeholder="Brand or product name…" onChange={e=> setSearchProductName(e.target.value)} value={searchProductName} onKeyPress={handleKeyPress}  type="text" className='input-search' />
                </div>
              </div>
            </div>
          ):(
            <div onClick={()=>setShowSearchBox(true)} className="flex flex-center mt-16">
              <div className="search-bar-category">
              </div>
            </div>
          )}
         
          <ul className={"category h-100vh center "+(showSearchBox ? "mt-64":"")}>
            <li className={classes.categoryHeader}>
              <TextWidget text="CATEGORIES" size={16}   />
            </li>
            {categories &&
              categories.map((category: any) => {
                return (
                  <li
                    className={clsx(
                      classes.filterItem,
                      filterCategory === category.id ? 'active' : ''
                    )}
                    key={category.id}
                    onClick={ async () => {
                      setFilterCategory(category.id)
                      loadTags(userStore,category.id)
                      setFilterTag('')
                    }}
                  >
                    <img
                      alt=""
                      width="65"
                      src={getCategoryIcon(category.name)}
                    />
                    <Typography variant="body1" className="capital">
                      {category.name}
                    </Typography>
                    <Typography
                      component="span"
                      className="close"
                      onClick={async (e) => {
                        e.stopPropagation()
                        setFilterCategory('')
                        loadTags(userStore,-1)
                        setFilterTag('')
                      }}
                    >
                      x
                    </Typography>
                  </li>
                )
              })}
            <li className={classes.tagsHeader}>
              <TextWidget text="TAGS" size={15} />
            </li>
            {tags &&
              tags.map((tag: any, index) => {
                return (
                  <li
                    className={clsx(
                      classes.filterItem,
                      filterTag === tag.name ? 'active' : ''
                    )}
                    key={index}
                    onClick={() => {
                      setFilterTag(tag.name)
                    }}
                  >
                    <Typography variant="body1" className="capital">
                      {tag.name}
                    </Typography>
                    <Typography
                      component="span"
                      className="close"
                      onClick={(e) => {
                        e.stopPropagation()
                        setFilterTag('')
                      }}
                    >
                      x
                    </Typography>
                  </li>
                )
              })}
          </ul>
        </Box>
      </ClickAwayListener>

      {!matchesMobile && (
        <Box position="relative" height="100vh" width="50px">
          <Box className={classes.sortContainer}>
            <Box
              className={classes.sortItem}
              onClick={() => {
                setSortBy('name')
                setSortDirection('asc')
              }}
            >
              A-Z
            </Box>
            <Box
              className={classes.sortItem}
              onClick={() => {
                setSortBy('min_price')
                setSortDirection('desc')
              }}
            >
              $ <span className="sort-arrow" />
            </Box>
            <Box
              className={classes.sortItem}
              onClick={() => {
                setSortBy('min_price')
                setSortDirection('asc')
              }}
            >
              $ <span className="sort-arrow arrow-up" />
            </Box>
          </Box>
        </Box>
      )}
      <Box overflow="scroll" flexGrow={1}>
        <Box
          display={{
            xs: 'block',
            sm: 'block',
            md: 'none',
            lg: 'none',
            xl: 'none',
          }}
          padding={{
            sm: '0px',
            xs: '0px',
          }}
        >
          <MobileSidebar activeMenu={2} />
        </Box>

        {matchesMobile && (
          <div className="category-border top-sticky">
            <TextWidget text="CATEGORIES" size={12} indent={10}/>
            <div className="product-categories-mobile">
              {categories &&
                categories.map((category: any) => {
                  return (
                    <div
                      className={clsx(
                        classes.filterItem,
                        filterCategory === category.id ? 'active' : ''
                      )}
                      key={category.id}
                      onClick={() => {
                        setFilterCategory(category.id)
                      }}
                    >
                      <img
                        alt=""
                        className="img-category-scale"
                        src={getCategoryIcon(category.name)}
                      />
                      <Typography variant="body1" className="capital mobile-category-name">
                        {category.name}
                      </Typography>
                    </div>
                  )
                })}
            </div>

            {showTags && (
              <div className={classes.tagsContainer}>
                <TextWidget text="TAGS" size={12}  indent={10}/>
                <div className="product-tags-mobile">
                {tags &&
                  tags.map((tag: any, index) => {
                    return (
                      <div
                        className={clsx(
                          classes.filterItem,
                          classes.tagItem,
                          filterTag === tag.name ? 'active' : ''
                        )}
                        key={index}
                        onClick={() => {
                          setFilterTag(tag.name)
                        }}
                      >
                        <Typography variant="body1" className={`capital mobile-category-name ${classes.tagTypography}`}>
                          {tag.name}
                        </Typography>
                      
                      </div>
                    )
                  })}
                </div>
              </div>
            )}
            <div onClick={()=>setShowTags(!showTags)} className="mobile-filter">
              Filters {showTags ? (<KeyboardArrowUpIcon />):(<KeyboardArrowDownIcon />)}
            </div>
          </div>
        )}
        <div ref={productsRef} className={classes.productsContainer}>
          {
            <ReactWindowGrid
              columnCount={columnCount}
              columnWidth={width / columnCount}
              height={1050}
              rowCount={
                products.length % columnCount
                  ? products.length / columnCount + 1
                  : products.length / columnCount
              }
              rowHeight={rowHeight}
              width={width}
              itemData={products}
              ref={productsInnerRef}
              onScroll={() => onScroll()}
            >
              {({ columnIndex, rowIndex, style, data }) => {
                const item: IProduct =
                  data[rowIndex * columnCount + columnIndex]
                return item ? (
                  <div 
                    style={style} 
                    className={classes.productGridItem} 
                    key={item.id}
                  >
                    <ProductCard
                      product={item}
                      width={+(style?.width || -1)}
                      isFavorite={
                        (favorites || []).findIndex(
                          (favorite) => favorite.id === item.id
                        ) >= 0
                      }
                      addFavorite={(product: IProduct) =>
                        addFavorite({ storeId: userStore, product })
                      }
                      removeFavorite={(product: IProduct) =>
                        removeFavorite(product.id)
                      }
                    />
                  </div>
                ) : null
              }}
            </ReactWindowGrid>
          }
        </div>
      </Box>
    </Box>
  )
}
