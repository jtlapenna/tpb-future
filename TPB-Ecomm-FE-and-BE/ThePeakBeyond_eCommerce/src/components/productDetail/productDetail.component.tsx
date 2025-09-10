import React, { useState, useEffect, useMemo } from 'react'
import { useParams } from 'react-router-dom'
import { makeStyles, useTheme } from '@material-ui/core/styles'
import { Box, Typography, Button, useMediaQuery } from '@material-ui/core'

import { httpGet } from '../../services/http-client.service'
import { IProduct } from 'types'
import { useCartFacade } from 'state/cart'

import { BackButton, HomeButton, TextWidget } from 'components/_ui'
import { MobileSidebar } from 'components'
import { useUserFacade } from 'state/user'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faHeart as fasHeart } from '@fortawesome/free-solid-svg-icons'
import { useFavoritesFacade } from 'state/favorites'
import { useAuth } from 'hooks'

const useStyles = makeStyles((theme) => ({
  product: {
    color: 'white',
    overflow: 'scroll',

    [theme.breakpoints.down('sm')]: {
      flexDirection: 'column',
      padding: 0,
    },
  },
  productInfo: {
    height: '100%',
    backgroundColor: 'rgba(1, 13, 23, 0.3)',
    padding: '30px 30px',
    flexGrow: 1,

    [theme.breakpoints.down('xs')]: {
      height: 'auto',
      padding: '30px 10px',
    },
  },
  productCart: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    padding: '50px 60px',
    flexShrink: 0,

    [theme.breakpoints.down('md')]: {
      flexShrink: 1,
    },

    [theme.breakpoints.down('sm')]: {
      padding: '20px',
      flexDirection: 'row',
    },

    [theme.breakpoints.down('xs')]: {
      flexDirection: 'column',
      paddingLeft: '24px',
      paddingRight:'24px',
    },
  },
  activeFav:{
    opacity: '1 !important',
  },
  productCartContainer: {
    width: '100%',
    textAlign: 'center',

    '&:hover .favoriteIcon':{
      opacity: 1,

    },
    '& .favoriteIcon': {
      position: 'relative',
      opacity: 0,
      backgroundColor: '#00c796',
      borderRadius: '50%',
      width: '35px',
      height: '35px',
      boxSizing: 'border-box',
      padding: '8px',
      transition: 'all 300ms linear',
      cursor:'pointer',
      // '& [data-prefix="far"]': {
      //   color: 'black',
      // },

      '&[data-prefix="fas"]': {
        color: '#03111b',
      },

      '&.active': {
        '&[data-prefix="fas"]': {
          color: 'white',
        },

        opacity: 1,
      },
    },

    [theme.breakpoints.down('xs')]: {
      width: '100%',
      textAlign: 'center',
    },
  },
  productCartButtons: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexWrap: 'wrap',
    width: '100%',
 
    [theme.breakpoints.down('sm')]: {
      flexDirection: 'column',
      paddingBottom:64,
    },

    [theme.breakpoints.down('xs')]: {
      flexDirection: 'row',
      flexWrap: 'nowrap',
      paddingBottom:64,
    },
  },
  productInfoHeader: {},
  productInfoContent: {
    paddingLeft: 20,
    paddingRight: 20,
    paddingTop: 15
  },
  productName: {
    fontSize: 50,
    textIndent: -3,
    textTransform: 'uppercase',
    fontFamily: 'muliextralight',

    [theme.breakpoints.down('sm')]: {
      fontSize: 50,
    },

    [theme.breakpoints.down('xs')]: {
      fontSize: 30,
      textIndent: -2,
      marginTop: 10,
    },
  },
  productCategory: {
    lineHeight: 1,
    paddingLeft: 5,
    position: 'relative',
    display: 'block',
    marginTop: 25,
    marginBottom: 60,

    '&::before': {
      display: 'block',
      position: 'absolute',
      width: 2,
      top: 0,
      bottom: 0,
      left: 0,
      backgroundColor: 'var(--primary)',
      content: '""',
    },

    [theme.breakpoints.down('xs')]: {
      marginBottom: 40,
    },
  },
  productOverviewHeading: {
    fontSize: 15,
    paddingBottom: 5,
    borderBottom: '5px solid var(--primary)',
    fontFamily: 'muliextrabold',
    letterSpacing:'.1em',
  },
  productDescription: {
    fontSize: 20,
    marginTop: 20,
    fontFamily: 'mulilight !important',

    [theme.breakpoints.down('xs')]: {
      fontSize: 14,
      lineHeight: 1.2,
    },
  },
  productImage: {
    width: '370px',
    height: '370px',
    borderRadius: '50%',
    aspectRatio: '1',

    [theme.breakpoints.down('xs')]: {
      width: 250,
      height: 250,
      overflow: 'hidden',
      borderRadius: '50%',
    },
  },
  productPrice: {
    textAlign: 'center',
    fontSize: 22,
    fontFamily: 'mulibold !important',
    padding: '30px 0',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    marginTop: 50,
    width: '100%',
    borderRadius: 20,

    [theme.breakpoints.down('xs')]: {
      marginTop: 30,
      // padding: '15px 0',
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

    [theme.breakpoints.down('xs')]: {
      fontSize: 18,
      width: 60,
    },
  },
  addToCartContainer: {
    displa: 'block',
    flexGrow: 1,
    textAlign: 'center',
    marginTop: '30px',
    padding: '0 25px',
    paddingRight: 0,

    [theme.breakpoints.down('xs')]: {
      padding: 0,
      textAlign: 'right',
    },
  },
  addToCart: {
    width: 250,
    height: 80,
    fontSize: 20,
    fontWeight: 'bold',
    backgroundColor: 'var(--primary)',
    borderRadius: 40,
    color: 'white',
    fontFamily: 'muliextrabold !important',

    [theme.breakpoints.down('xs')]: {
      width: 160,
      fontSize: 14,
      height: 50,
    },
  },
  pTag:{
    display:'block',

    '& div':{
      marginTop:20,
      display:'inline-block',
      textTransform:'uppercase',
      marginRight:16,
      background:'hsla(0,0%,100%,.1)',
      letterSpacing:'.1em',
      padding:'.75em 1.25em',
      borderRadius:'1.25em',
      fontSize:'16px',
      fontFamily:'mulibold',
      color:'hsla(0,0%,100%,.5)',
    }
  }
}))


type Params = {
  id: string
}

export const ProductDetail = () => {
  const { id } = useParams<Params>()
  const classes = useStyles()
  const { addCart, removeCart } = useCartFacade()
  const { userState } = useUserFacade()
  const {
    store: userStore,
  } = userState
  const theme = useTheme()
  const matchesMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const { favorites, addFavorite, removeFavorite, } = useFavoritesFacade();
  const { isLoggedIn } = useAuth();

  const [product, setProduct] = useState<IProduct>()
  const [productCount, setProductCount] = useState(1)

  const fetchProduct = async (id) => {
    try {
      const product: IProduct = await httpGet(`/products/find/${id}`)
      setProduct(product)
    } catch (err) {
      console.log({ err })
    }
  }

  const hasTags = useMemo(()=>{
    if(!product){
      return false;
    }

    return product.tags && product.tags.length>0;
  },[product]);

  useEffect(() => {
    if (id) {
      fetchProduct(id)
    }
  }, [id])

  return product ? (
    <Box
      display="flex"
      alignItems="stretch"
      height="100%"
      className={classes.product}
      padding="10px 0"
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
        className={matchesMobile ? "top-sticky":""}
      >
        <MobileSidebar activeMenu={-1} />
      </Box>
      <Box display="block" className={classes.productInfo}>
        <Box
          display="flex"
          alignItems="center"
          justifyContent="space-between"
          className={classes.productInfoHeader}
        >
          <BackButton />
        </Box>
        <Box className={classes.productInfoContent}>
        
        {matchesMobile && (
            <div style={{width:'100%',textAlign:'center'}}>
              <img
                src={
                  product?.image_url ??
                  'https://treezculturecannabisclubbanning.s3.amazonaws.com/product/1e43a152-f84f-4022-a2c6-0c66c86e9e70_f82cd7ae-a76d-41d5-bcfb-ba04b7015908_null_20-04-21-09-27-54'
                }
                alt={product?.name}
                className={classes.productImage}
              />
            </div>
          )}
          <Typography component="h1" className={classes.productName}>
            {product?.name}
          </Typography>
          <Typography component="a" className={classes.productCategory}>
            {/* {product?.brand_name} */}
            FLAV
          </Typography>
          <Typography
            component="span"
            className={classes.productOverviewHeading}
          >
            OVERVIEW
          </Typography>
          <Typography component="p" className={classes.productDescription}>
            {product?.description}
          </Typography>

          {hasTags && (
            <>
              <div style={{marginTop:32}}>
                <TextWidget
                  text={"Tags"}
                  size={16}
                  style="tag-title-text"
                ></TextWidget>
              </div>
              <div className={classes.pTag}>
                {(product?.tags || []).map(tag=>(
                  <div>
                    {tag.name}
                  </div>
                ))}
              </div>
            </>
          )}
         
        </Box>
      </Box>
      <Box className={classes.productCart}>
        <Box className={classes.productCartContainer}>

          {!matchesMobile && (
            <img
              src={
                product?.image_url ??
                'https://treezculturecannabisclubbanning.s3.amazonaws.com/product/1e43a152-f84f-4022-a2c6-0c66c86e9e70_f82cd7ae-a76d-41d5-bcfb-ba04b7015908_null_20-04-21-09-27-54'
              }
              alt={product?.name}
              className={classes.productImage}
            />
          )}
          <FontAwesomeIcon
              className={`favoriteIcon${(favorites || []).findIndex(
                (favorite) => +favorite.id === +product.id
              ) !==-1 ? ' active':''}`}
              icon={fasHeart}
              onClick={(e) => {
                if ((favorites || []).findIndex(
                  (favorite) => +favorite.id === +product.id
                ) ===-1) {
                  if (isLoggedIn) addFavorite({
                    product,storeId: userStore})
                } else {
                  removeFavorite(product.id)
                }
                e.preventDefault()
                return false
              }}
              size="2x"
            />
          <Box className={classes.productPrice}>${product?.min_price}</Box>
        </Box>
        <Box className={classes.productCartButtons}>
          <Box display="flex" alignItems="center" marginTop="30px">
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
          
          <Box className={classes.addToCartContainer}>
            <Button
              className={classes.addToCart}
              onClick={() => addCart({ product, count: productCount, storeId: userStore })}
            >
              Add to cart
            </Button>
          </Box>
        </Box>
      </Box>
    </Box>
  ) : null
}
