import React, {
  useMemo,
  useState,
  useRef,
  MutableRefObject,
  useCallback,
} from 'react'
import { makeStyles,useTheme } from '@material-ui/core/styles'
import {
  Box,
  Typography,
  FormGroup,
  FormControl,
  FormControlLabel,
  Checkbox,
  FormLabel,
  Link,
  Button,
  TextField,
  InputLabel,
  Input,
  FormHelperText,
  Fab,
  useMediaQuery,
} from '@material-ui/core'

import { useCartFacade } from 'state/cart'
import { IProduct } from 'types'
import { useUserFacade } from 'state/user'

type ICartModal = {
  product: IProduct
  hide: () => void
}

const useStyles = makeStyles((theme) => ({
  cartModal: {
  },
  cartModalContainer: {
    padding: '2rem',
    display: 'flex',
    gap: '4rem',
    alignItems: 'center',

    [theme.breakpoints.down('sm')]: {
      padding: '1rem',
      gap: '2rem',
    },
    [theme.breakpoints.down('xs')]: {
      flexWrap: 'wrap',
      justifyContent: 'center',
      padding: 0,
    },
  },
  thumbnail: {
    width: '200px',
    height: '200px',
    objectFit: 'cover',
    borderRadius: '100%',

    [theme.breakpoints.down('xs')]: {
      width: '150px',
      height: '150px',
    },
  },
  brand: {
    fontSize: 15,
    color: 'white',
    opacity: 0.2,
    textAlign: 'left',
    textTransform:'uppercase',
    fontFamily:'mulibold !important',
  },
  name: {
    color: 'white',
    fontSize: 24,
    marginTop: '10px',
    marginBottom: '30px',
    textAlign: 'left',
    fontFamily:'muliregular !important',
  },
  price: {
    backgroundColor: 'hsla(0,0%,100%,.1)',
    borderRadius: '10px',
    color: 'white',
    display: 'inline-flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '20px',
    fontWeight: 'bold',
    padding: '30px 4rem',

    [theme.breakpoints.down('xs')]: {
      width: '100%',
      padding: '15px 4rem',
    },
  },
  productCartButtons: {
    display: 'flex',
    // alignItems: 'center',
    justifyContent: 'center',
    flexWrap: 'wrap',
    width: '100%',
    gap: '20px',

    [theme.breakpoints.down('sm')]: {
      flexDirection: 'column',
    },
  },
  productAdd: {
    width: 50,
    height: 50,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: '50%',
    padding: 0,
    minWidth: 0,
    color: 'white',
    fontSize: '30px',

    [theme.breakpoints.down('xs')]: {
      width: 30,
      height: 30,
      fontSize: 18,
    },
  },
  productCount: {
    fontSize: 30,
    width: 90,
    textAlign: 'center',
    userSelect: 'none',
    color: 'white',

    [theme.breakpoints.down('xs')]: {
      fontSize: 18,
      width: 60,
    },
  },
  addToCart: {
    width: 200,
    height: 60,
    fontSize: 12,
    backgroundColor: 'var(--primary)',
    borderRadius: 40,
    color: 'white',
    fontFamily:'muliextrabold !important',
    letterSpacing: '.2em',

    [theme.breakpoints.down('xs')]: {
      width: 140,
      fontSize: 14,
      height: 50,
    },
  },
  addToCartCancel: {
    width: 200,
    height: 60,
    fontSize: 12,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 40,
    color: 'white',
    marginRight: '20px',
    fontFamily:'muliextrabold !important',
    letterSpacing: '.2em',

    [theme.breakpoints.down('xs')]: {
      marginRight: 0,
      width: 140,
      fontSize: 14,
      height: 50,
    },
  },
  cartActions: {
    display: 'flex',
    flexGrow: 1,
    marginTop: '30px',
    gap: '20px',

    [theme.breakpoints.down('xs')]: {
      marginTop: 0,
    },
  },
}))

export const CartModal: React.FC<ICartModal> = ({ product, hide }) => {
  const { id, name, image_url, min_price, promotion, brand_name } = product

  const classes = useStyles()
  const { addCart, removeCart } = useCartFacade()
  const { userState } = useUserFacade()
  const {
    store: userStore,
  } = userState

  const theme = useTheme()
  const matchesMobile = useMediaQuery(theme.breakpoints.down('sm'))

  const [productCount, setProductCount] = useState(1)

  return (
    <Box className={classes.cartModal}>
      <Box className={classes.cartModalContainer}>
        <img src={image_url} className={classes.thumbnail} />
        <Box textAlign="center">
          <Typography component="p" className={classes.brand}>
            {brand_name}
          </Typography>
          <Typography component="h3" className={classes.name}>
            {name}
          </Typography>
          <Box
            display="flex"
            justifyContent={{
              xs: 'center',
              sm: 'left',
              md: 'left',
            }}
          >
            <Box className={classes.price}>${min_price}</Box>
          </Box>
          <Box className={classes.productCartButtons}>
            <Box
              display="flex"
              alignItems="center"
              justifyContent={{
                md: 'left',
                sm: 'center',
                xs: 'center',
              }}
              marginTop="30px"
              marginRight={{
                sm: '30px',
                xs: '0px',
              }}
            >
              <Button
                className={classes.productAdd}
                onClick={() => {
                  if (productCount > 0) {
                    setProductCount(productCount - 1)
                  }
                }}
                disabled={productCount === 0}
              >
                -
              </Button>
              <Typography component="p" className={classes.productCount}>
                {productCount}
              </Typography>
              <Button
                className={classes.productAdd}
                onClick={() => setProductCount(productCount + 1)}
              >
                +
              </Button>
            </Box>
            <Box className={classes.cartActions}>
              <Button className={classes.addToCartCancel} color="secondary" onClick={hide}>
                Cancel
              </Button>
              <Button
                className={classes.addToCart}
                onClick={() => {
                  addCart({ product, count: productCount, storeId: userStore });
                  hide();
                }}
              >
                Add to cart
              </Button>
            </Box>
          </Box>
        </Box>
      </Box>
    </Box>
  )
}
