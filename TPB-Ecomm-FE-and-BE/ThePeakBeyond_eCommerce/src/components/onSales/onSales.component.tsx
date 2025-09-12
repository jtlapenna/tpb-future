import { useEffect, useState, useCallback, useRef } from 'react'
import { useHistory } from 'react-router-dom'
import { makeStyles, useTheme } from '@material-ui/core/styles'
import {
  Typography,
  Box,
  useMediaQuery,
  ClickAwayListener,
} from '@material-ui/core'
import { FixedSizeGrid as ReactWindowGrid } from 'react-window'

import { useUserFacade } from 'state/user'

import {
  TextWidget,
  FeaturedProduct,
  BackButton,
  HomeButton,
} from 'components/_ui'
import { MobileSidebar } from 'components'
import { httpGet, httpPost } from '../../services/http-client.service'
import { useQuery } from 'utils'
import { IProduct } from 'types'

const useStyles = makeStyles((theme) => ({
  onSales: {},
  heading: {
    color: 'white',
    textAlign: 'center',
    fontSize: 50,
    marginTop: 50,
    marginBottom: 50,
    display: 'inline-block',
  },
  productsContainer: {
    width: '100%',
    marginTop: '40px',
    overflowY: 'scroll',
    paddingLeft: '1rem',
    paddingRight: '1rem',
    flexGrow: 1,
    animation: 'slideInWithTransationFromLeft 0.5s ease',

    [theme.breakpoints.down('xs')]: {
      paddingLeft: '0',
      paddingRight: '0',
      marginTop: '15px',
    },
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
}) => {
  const requestBody = {
    storeId,
    sortColumn: sortBy,
    sortDirection,
    page,
    count,
  }

  if (category) {
    requestBody['category'] = +category
  }
  if (tag) {
    requestBody['tag'] = tag
  }

  const products: IProduct[] = await httpPost('/products/onsales', requestBody)
  return products
}

export const OnSales: React.FC = () => {
  const classes = useStyles()
  const history = useHistory()
  const theme = useTheme()
  const matchesMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const { userState } = useUserFacade()
  const { store: userStore } = userState

  const [products, setProducts] = useState<IProduct[]>([])

  // States for UI
  const [width, setWidth] = useState(0)
  const [height, setHeight] = useState(0)
  const [columnCount, setColumnCount] = useState(4)
  const [rowHeight, setRowHeight] = useState(400)

  const productsRef = useRef(null)
  const productsInnerRef = useRef(null)

  useEffect(() => {
    const fetchProductsData = async (storeId: string) => {
      const products: IProduct[] = await fetchProducts({
        category: '',
        tag: '',
        sortBy: 'id',
        sortDirection: '',
        storeId,
        page: 1,
        count: 50,
      })
      setProducts(products)
    }
    if (userStore) {
      fetchProductsData(userStore)
    }
  }, [history, userStore])

  useEffect(() => {
    if (productsRef && productsRef.current) {
      setWidth(
        (productsRef?.current as any).offsetWidth - (matchesMobile ? 16 : 64)
      )
      setHeight((productsRef?.current as any).offsetHeight)
    }
  }, [productsRef, matchesMobile, productsRef.current])

  useEffect(() => {
    if (productsRef && productsRef.current) {
      setWidth(
        (productsRef?.current as any).offsetWidth - (matchesMobile ? 16 : 64)
      )
      setHeight((productsRef?.current as any).offsetHeight)
    }
  }, [])

  useEffect(() => {
    if (width >= 1200) {
      setRowHeight(500)
    } else if (width >= 1000) {
      setColumnCount(4)
      setRowHeight(440)
    } else if (width >= 700) {
      setColumnCount(3)
      setRowHeight(450)
    } else if (width >= 500) {
      setColumnCount(2)
      setRowHeight(500)
    } else if (width >= 400) {
      setColumnCount(2)
      setRowHeight(450)
    } else if (width >= 300) {
      setColumnCount(2)
      setRowHeight(400)
    } else if (width >= 100) {
      setColumnCount(2)
      setRowHeight(370)
    }
  }, [width])

  window.addEventListener('resize', () => {
    if (productsRef && productsRef.current) {
      setWidth(
        (productsRef?.current as any).offsetWidth - (matchesMobile ? 16 : 64)
      )
      setHeight((productsRef?.current as any).offsetHeight)
    }
  })

  return (
    <Box
      display="flex"
      flexDirection="column"
      maxHeight="100vh"
      height="100%"
      paddingLeft={matchesMobile ? '0' : '60px'}
      className={classes.onSales}
    >
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
        <MobileSidebar activeMenu={4} />
      </Box>
      <Box
        display={{
          xs: 'none',
          sm: 'none',
          md: 'block',
          lg: 'block',
          xl: 'block',
        }}
        marginTop="60px"
      >
        <TextWidget text="Today's Sales" size={50} font="muliregular" />
      </Box>
      <Box
        display={{
          xs: 'block',
          sm: 'block',
          md: 'none',
          lg: 'none',
          xl: 'none',
        }}
        marginTop="10px"
        paddingLeft="20px"
      >
        <TextWidget text="Today's Sales" size={30} />
      </Box>
      <div ref={productsRef} className={classes.productsContainer}>
        {
          <ReactWindowGrid
            columnCount={columnCount}
            columnWidth={
              matchesMobile ? width / columnCount : width / columnCount
            }
            height={height}
            rowCount={
              products.length % columnCount
                ? products.length / columnCount + 1
                : products.length / columnCount
            }
            rowHeight={rowHeight}
            width={width}
            itemData={products}
            ref={productsInnerRef}
          >
            {({ columnIndex, rowIndex, style, data }) => {
              const item: IProduct = data[rowIndex * columnCount + columnIndex]
              return item ? (
                <div 
                  style={style} 
                  className={classes.productGridItem} 
                  key={item.id}
                  // eslint-disable-next-line react/forbid-dom-props
                >
                  <FeaturedProduct product={item} />
                </div>
              ) : null
            }}
          </ReactWindowGrid>
        }
      </div>
    </Box>
  )
}
