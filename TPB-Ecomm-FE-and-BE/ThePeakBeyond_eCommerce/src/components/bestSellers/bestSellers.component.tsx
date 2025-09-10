import { useEffect, useState, useCallback, useRef } from 'react'
import { useHistory } from 'react-router-dom'
import { makeStyles, useTheme } from '@material-ui/core/styles'
import {
  Typography,
  Box,
  useMediaQuery,
  ClickAwayListener,
} from '@material-ui/core'
import 'react-responsive-carousel/lib/styles/carousel.min.css'
import { Carousel } from 'react-responsive-carousel'

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
  bestSellers: {},
  heading: {
    color: 'white',
    textAlign: 'center',
    fontSize: 50,
    marginTop: 50,
    marginBottom: 50,
    display: 'inline-block',
  },
  description: {
    color: 'white',
  },
  productsContainer: {
    width: '100%',
    overflowY: 'scroll',
    paddingLeft: '1rem',
    paddingRight: '1rem',
    flexGrow: 1,
    animation: 'slideInWithTransationFromLeft 0.5s ease',

    [theme.breakpoints.down('xs')]: {
      paddingLeft: '1rem',
      paddingRight: '1rem',
    },
  },
  carousel: {
    marginTop: '40px',

    [theme.breakpoints.down('xs')]: {
      marginTop: 10,
    },

    '& .slide': {
      [theme.breakpoints.down('sm')]: {
        margin: 'auto',
      },
    },
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

  const products: IProduct[] = await httpPost(
    '/products/featuredProducts',
    requestBody
  )
  return products
}

export const BestSellers: React.FC = () => {
  const classes = useStyles()
  const history = useHistory()
  const theme = useTheme()
  const matchesMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const { userState } = useUserFacade()
  const { store: userStore } = userState

  const [products, setProducts] = useState<IProduct[]>([])

  useEffect(() => {
    const fetchProductsData = async (storeId: string) => {
      const products: IProduct[] = await fetchProducts({
        category: '',
        tag: '',
        sortBy: '',
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

  return (
    <Box
      display="flex"
      flexDirection="column"
      maxHeight="100vh"
      height="100%"
      paddingLeft={matchesMobile ? '0' : '60px'}
      className={classes.bestSellers}
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
        <MobileSidebar activeMenu={5} />
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
        paddingBottom='64px'
      >
        <TextWidget text="Featured Products" size={60} />
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
        paddingBottom='32px'
        paddingLeft="20px"
      >
        <TextWidget text="Featured Products" size={30} />
      </Box>
      {products && products.length > 0 && (
        <Carousel
          centerSlidePercentage={matchesMobile ? 80 : 30}
          showThumbs={false}
          showArrows={true}
          centerMode
          showStatus={false}
          swipeable={true}
          //emulateTouch={true}
          className={products.length === 1 ? classes.carousel : ''}
        >
          {products.map((product, index) => {
            return (
              <>
                <Box
                  style={{
                    backgroundColor: 'rgba(255, 255, 255, 0.1)',
                    maxWidth: '400px',
                    margin: 'auto',
                    borderRadius: '20px',
                    marginRight: 20,
                  }}
                  key={product.id}
                >
                  <FeaturedProduct product={product} />
                </Box>
              </>
            )
          })}
        </Carousel>
      )}
    </Box>
  )
}
