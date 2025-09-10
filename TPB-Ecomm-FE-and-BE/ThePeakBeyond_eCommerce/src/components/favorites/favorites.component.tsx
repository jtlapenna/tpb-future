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

import { useUserFacade } from 'state/user'
import { useFavoritesFacade } from 'state/favorites'
import { httpGet, httpPost } from '../../services/http-client.service'
import { useQuery } from 'utils'
import { IProduct } from 'types'

import { TextWidget, ProductCard, BackButton, HomeButton } from 'components/_ui'
import { MobileSidebar } from 'components'
import { useAuth } from 'hooks'

const useStyles = makeStyles((theme) => ({

   productsContainer: {
    overflowY: 'scroll',
    paddingLeft: '1em',
    paddingRight: '1rem',
    boxSizing: 'border-box',
    animation: 'slideInWithTransationFromLeft 0.5s ease',

    [theme.breakpoints.down('xs')]: {
      paddingLeft: '1rem',
      paddingRight: '1rem',
    },
  },
  noFavorites: {
    fontSize: '30px',
    color: 'white',
    position: 'absolute',
    left: 15,
    right: 15,
    top: '50%',
    transform: 'translateY(-50%)',
    textAlign: 'center',

    [theme.breakpoints.down('xs')]: {
        marginTop:80,
        fontSize: '20px',
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

  const products: IProduct[] = await httpPost('/products/all', requestBody)
  return products
}

export const Favorites: React.FC = () => {
  const classes = useStyles()
  const history = useHistory()
  const theme = useTheme()
  const matchesMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const query = useQuery()
  const { userState } = useUserFacade()
  const { store: userStore } = userState
  const { favorites, addFavorite, removeFavorite } = useFavoritesFacade()

  const [products, setProducts] = useState<IProduct[]>([])
  const [categories, setCategories] = useState<any>([])
  const [tags, setTags] = useState([])
  const { isLoggedIn } = useAuth()

  const [page, setPage] = useState(1)
  // console.log({ favorites })
  // States for UI
  const [width, setWidth] = useState(0)
  const [rowHeight, setRowHeight] = useState(390)
  const [columnCount, setColumnCount] = useState(4)

  const productsRef = useRef(null)
  const productsInnerRef = useRef(null)

  useEffect(() => {
    console.log('userState',userState)
    if (productsRef && productsRef.current) {
      setWidth(
        (productsRef?.current as any).offsetWidth - (matchesMobile ? 32 : 64)
      )
    }
  }, [productsRef, matchesMobile, favorites])

  useEffect(() => {
    if (width >= 800) {
      setRowHeight(420)
      setColumnCount(4)
    } else if (width >= 600) {
      setRowHeight(410)
      setColumnCount(3)
    } else if (width >= 400) {
      setRowHeight(390)
      setColumnCount(3)
    } else if (width >= 300) {
      setColumnCount(2)
      setRowHeight(350)
    } else if (width >= 100) {
      setColumnCount(2)
      setRowHeight(320)
    }
  }, [width])

  window.addEventListener('resize', () => {
    if (productsRef && productsRef.current) {
      setWidth(
        (productsRef?.current as any).offsetWidth - (matchesMobile ? 32 : 64)
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
    <>
      <Box maxHeight="100vh">
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
          className={matchesMobile ? "top-sticky":""}
        >
          <MobileSidebar activeMenu={1} />
        </Box>
        {favorites.length ? (
          <>
            <Box overflow="scroll" flexGrow={1}>
              <div ref={productsRef} className={classes.productsContainer}>
                {
                  <ReactWindowGrid
                    columnCount={columnCount}
                    columnWidth={width / columnCount}
                    height={1050}
                    rowCount={
                      favorites.length % columnCount
                        ? favorites.length / columnCount + 1
                        : favorites.length / columnCount
                    }
                    rowHeight={rowHeight}
                    width={width}
                    itemData={favorites}
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
          </>
        ) : (
          <Typography className={classes.noFavorites}>
             {isLoggedIn ? "You haven't added any favorites here yet.":'You must be logged into your account to view favorites'}.          
          </Typography>
        )}
      </Box>
    </>
  )
}
