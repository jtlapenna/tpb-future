import { useEffect, useState, useCallback, useRef, useMemo } from 'react'
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
import { useFavoritesFacade } from 'state/favorites'
import { useUserFacade } from 'state/user'
import KeyboardArrowDownIcon from '@material-ui/icons/KeyboardArrowDown';
import KeyboardArrowUpIcon from '@material-ui/icons/KeyboardArrowUp';
import { TextWidget, ProductCard, BackButton, HomeButton } from 'components/_ui'
import { MobileSidebar } from 'components'
import { httpGet, httpPost } from '../../services/http-client.service'
import { useQuery } from 'utils'
import { IProduct, IBrand } from 'types'
import {groupBy} from "lodash";


const useStyles = makeStyles((theme) => ({
  
  brandsContainer: {
    background: 'rgba(0, 0, 0, 0.3)',
    overflowY: 'scroll',
    minWidth: '220px',
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
  brandData: {
    color: 'white',
    marginTop: '60px',
    paddingBottom: '45px',
    borderBottom: '1px solid hsla(0,0%,100%, 0.1)',

    [theme.breakpoints.down('xs')]: {
      textAlign: 'center',
      marginTop: '10px',
      paddingBottom: '10px',
      paddingLeft:'15px',
      paddingRight:'15px',
    },
  },
  brandName: {
    fontSize: '60px',
    marginBottom: '30px',

    [theme.breakpoints.down('xs')]: {
      fontSize: 16,
    },
  },
  brandDescription: {
    fontSize: '20px',
    lineHeight: '1.5',
    paddingTop: 32,
    textAlign: "left",

    [theme.breakpoints.down('xs')]: {
      fontSize: 14,
      lineHeight: '1.2',
      paddingTop: 10,
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
    height: '25px',
    lineHeight: '25px',
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
    //position: 'relative',
    display:'flex',
    justifyContent:'center',
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
    paddingLeft: '5rem',
    paddingRight: '5rem',
    boxSizing: 'border-box',
    animation: 'slideInWithTransationFromLeft 1.5s ease',
    
    [theme.breakpoints.down('xs')]: {
      paddingLeft: '0',
      paddingRight: '0',
    },
  }, 

  mainContainer:{
    padding:8,
    
    [theme.breakpoints.down('xs')]: {
     padding: '0 !Important',
    },
  }
}))

const fetchProducts = async ({
  brand,
  tag = '',
  storeId,
  sortBy = '',
  sortDirection = '',
  page,
  count,
}) => {
  const requestBody = {
    storeId,
    sortColumn: sortBy,
    sortDirection,
    page,
    count,
  }

  if (brand) {
    requestBody['brand'] = +brand
  }
  if (tag) {
    requestBody['tag'] = tag
  }

  const products: IProduct[] = await httpPost('/products/all', requestBody)
  return products
}

interface IBrandInitial {
  initial: string
  id: string
}

export const Brands: React.FC = () => {
  const classes = useStyles()
  const history = useHistory()
  const theme = useTheme()
  const matchesMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const query = useQuery()
  const { userState } = useUserFacade()
  const { store: userStore } = userState
  const { favorites, addFavorite, removeFavorite } = useFavoritesFacade()
  const [showTags, setShowTags] = useState<boolean>(false);
  const [products, setProducts] = useState<IProduct[]>([])
  const [brands, setBrands] = useState<IBrand[]>([])
  const isXl = useMediaQuery(theme.breakpoints.down('xl'))
  const featuredBrands = useMemo(
    () => brands.filter((brand) => brand.featured),
    [brands]
  )

  const otherBrands = useMemo(
    () => brands.filter((brand) => !brand.featured),
    [brands]
  )

  // States for filtering
  const [filterBrand, setFilterBrand] = useState<string>(
    query.get('brand') || ''
  )
  const [page, setPage] = useState(1)
  const [filterSelected, setFilterSelected] = useState("")

  // States for UI
  const [showBrands, setShowBrands] = useState(false)
  const [width, setWidth] = useState(0)
  const [rowHeight, setRowHeight] = useState(390)
  const [columnCount, setColumnCount] = useState(4)
  const [brandsInitials, setBrandsInitials] = useState<IBrandInitial[]>([])

  const productsRef = useRef(null)
  const productsInnerRef = useRef(null)

  const filterBrandData = useMemo(
    () => brands.find((brand) => brand.id === filterBrand),
    [filterBrand,brands]
  )


  useEffect(() => {
    const fetchBrands = async (storeId: string) => {
      const brands = await httpGet(`/brands/all/${storeId}/1/50`)
      setBrands(
        brands.sort((a: IBrand, b: IBrand) => a.name.localeCompare(b.name))
      )

      setBrandsInitials(Object.keys(groupBy(brands,'initial') || {}).map(key=>( {initial:key,id:'0' })))
    }
    if (userStore) fetchBrands(userStore)
  }, [userStore])


  useEffect(() => {
    const initial = filterBrandData?.name[0];
    if(initial && document.getElementById(initial)){
      document.getElementById(initial)?.scrollIntoView();
    }
  }, [filterBrandData])

  useEffect(() => {
    if (page >= 2) setPage(1)
  }, [filterBrand])

  useEffect(() => {
    const fetchProductsData = async (storeId: string) => {
      const query = {}
      if (filterBrand) {
        query['brand'] = filterBrand
      }

      history.push({
        pathname: '/brands',
        search: new URLSearchParams(query).toString(),
      })

      const newProducts: IProduct[] = await fetchProducts({
        brand: filterBrand,
        tag: '',
        storeId,
        page,
        count: 50,
      })
      if (page === 1) setProducts(newProducts)
      else setProducts([...products, ...newProducts])
    }
    if (userStore) fetchProductsData(userStore)

  }, [filterBrand, page, userStore])

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
      setColumnCount(3)
    } else if (width >= 600) {
      setRowHeight(410)
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

  const onScroll = useCallback(() => {
    if (productsInnerRef && productsInnerRef.current) {
      const outerRef = (productsInnerRef.current as any)._outerRef

      const { scrollTop, scrollHeight, clientHeight } = outerRef as any
      if (scrollTop + clientHeight === scrollHeight) {
        setPage((page) => page + 1)
      }
    }
  }, [productsInnerRef])

  return (
    <Box display="flex" maxHeight="100vh">
      <ClickAwayListener
        onClickAway={(e) => {
          if (matchesMobile && showBrands) {
            e.preventDefault()
            setShowBrands(false)
          }
        }}
      >
        <Box className={clsx(classes.brandsContainer, showBrands && 'show')}>
          <ul className="brand h-100vh center">
            <li style={{ paddingTop: 8, marginTop: 0, textAlign: 'left' }}>
              <TextWidget text="FEATURED BRANDS" size={16} />
            </li>
            {featuredBrands &&
              featuredBrands.map((brand: any) => {
                return (
                  <li
                    className={clsx(
                      classes.filterItem,
                      filterBrand === brand.id ? 'active' : ''
                    )}
                    key={brand.id}
                    onClick={() => {
                      setFilterBrand(brand.id)
                    }}
                  >

                    {brand.logo ? (
                      <img
                        alt=""
                        className="img-brand-scale"
                        src={brand.logo}
                      />
                    ):(
                      <Typography variant="body1" className="capital muliextrabold">
                        {brand.name}
                      </Typography>
                    )}
                     
                  </li>
                )
              })}
            <li style={{ paddingTop: 8, marginTop: 0, textAlign: 'left' }}>
              <TextWidget text="OTHER BRANDS" size={16} />
            </li>
            {otherBrands &&
              otherBrands.map((brand: any) => {
                return (
                  <li
                    className={clsx(
                      classes.filterItem,
                      filterBrand === brand.id ? 'active' : ''
                    )}
                    key={brand.id}
                    onClick={() => {
                      setFilterBrand(brand.id)
                    }}
                  >
                    
                    {brand.logo ? (
                      <img
                        alt=""
                        className="img-brand-scale"
                        src={brand.logo}
                      />
                    ):(
                      <Typography variant="body1" className="capital muliextrabold">
                        {brand.name}
                      </Typography>
                    )}  

                    <a style={{position:'relative',top:'-30px'}} id={brand.name.substr(0,1)}></a>                  
                  </li>
                )
              })}
          </ul>
        </Box>
      </ClickAwayListener>

      {!matchesMobile && (
        <Box
          position="relative"
          height="100vh"
          width={{ lg: '50px', md: '50px', sm: '30px', xs: '30px' }}
          flexShrink="0"
        >
          <Box className={classes.sortContainer}>
            {brandsInitials &&
              brandsInitials.map(({ initial, id }) => {
                return (
                    <Box
                      className={clsx(
                        classes.sortItem,
                        filterBrand && filterBrand === id ? 'active' : ''
                      )}
                      onClick={() => {
                        const brand = brands.find(
                          (b: IBrand) => b.name[0] === initial
                        )
                        setFilterBrand(brand ? brand.id : '')
                        setFilterSelected(initial);
                        if(initial && document.getElementById(initial)){
                          document.getElementById(initial)?.scrollIntoView();
                        }
                      
                      }}
                      key={initial}
                    >
                      <span style={{color: filterSelected === initial || filterBrandData?.name[0] === initial ? '#FFF':'rgba(255, 255, 255, 0.35)'}} >{initial}</span>
                    </Box>
                )
              })}
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
          <MobileSidebar activeMenu={3} />
        </Box>

        {matchesMobile &&  (
          <div className="category-border top-sticky">
            <TextWidget text="BRANDS" size={12} indent={10}/>
            <div className="brand-categories-mobile">
              {featuredBrands &&
                featuredBrands.map((brand: any) => {
                  return (
                    <div
                      className={clsx(
                        classes.filterItem,
                        filterBrand === brand.id ? 'active' : ''
                      )}
                      style={{
                        display:'flex',
                        alignItems:'center',
                        justifyContent:'center',
                      }}
                      key={brand.id}
                      onClick={() => {
                        setFilterBrand(brand.id)
                      }}
                    >
                      {brand.logo ? (
                        <img
                          alt=""
                          className="img-mobile-brand-scale"
                          src={brand.logo}
                        />
                      ):(
                        <Typography variant="body1" className="capital mobile-category-name">
                          {brand.name}
                        </Typography>
                      )}
                    </div>
                  )
                })}           
                 {otherBrands &&
                  otherBrands.map((brand: any, index) => {
                    return (
                      <div
                        className={clsx(
                          classes.filterItem,
                          filterBrand === brand.id ? 'active' : ''
                        )}
                        style={{
                          display:'flex',
                          alignItems:'center',
                          justifyContent:'center',
                        }}
                        key={index}
                        onClick={() => {
                          setFilterBrand(brand.id)
                        }}
                      >
                        {brand.logo ? (
                          <img
                          alt=""
                          className="img-mobile-brand-scale"
                          src={brand.logo}
                          />
                        ):(
                          <Typography variant="body1" className="capital mobile-category-name">
                          {brand.name}
                          </Typography>
                        )}
                      </div>
                    )
                  })}
               </div>
          </div>
        )}

        <div ref={productsRef} className={classes.productsContainer}>
          {filterBrandData && (
            <Box className={classes.brandData}>
              
                {filterBrandData.logo ? (
                  <img style={{maxWidth:'300px',marginBottom:16,marginTop:16}} src={filterBrandData.logo} alt=""/>
                ):(
                  <Typography className={classes.brandName}>
                    {filterBrandData.name}
                  </Typography>
                )}
              
              <Typography component="p" className={classes.brandDescription}>
                {filterBrandData.description}
              </Typography>
            </Box>
          )}
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
                  <div style={style} key={item.id}>
                    <ProductCard
                      product={item}
                      width={+(style?.width || -1)}
                      lessColumn={isXl}
                      isFavorite={
                        favorites.findIndex(
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
