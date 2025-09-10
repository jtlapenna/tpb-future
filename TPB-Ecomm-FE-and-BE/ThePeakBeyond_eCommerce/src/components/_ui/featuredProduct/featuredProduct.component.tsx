import React, { useMemo } from 'react'
import { Link } from 'react-router-dom'
import { toast } from 'react-toastify'
import { makeStyles } from '@material-ui/core/styles'
import { Box, Typography } from '@material-ui/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faHeart } from '@fortawesome/free-solid-svg-icons'
import { faHeart as fasHeart } from '@fortawesome/free-solid-svg-icons'
import { faHeart as farHeart } from '@fortawesome/free-regular-svg-icons'

import { useUserFacade } from 'state/user'
import { useFavoritesFacade } from 'state/favorites'
import { useModal, useAuth } from 'hooks'
import { IProduct } from 'types'

import { CartModal } from '../cartModal'

import CartIcon from 'assets/icons/icon-quick-cart.svg'

const useStyles = makeStyles((theme) => ({
  featuredProduct: {
    textAlign: 'center',
    borderRadius: '1rem',
    padding: '1.75em 1.75em 1em',
    margin: '1em',
    color: 'white',
    position: 'relative',

    '& img': {
      maxWidth: 200,
      borderRadius: '50%',
      width: '100%',
      aspectRatio: '1',
      objectFit: 'cover',
    },

    '&:hover': {
      '& .favoriteIcon': {
        opacity: 1,
      },
    },

    [theme.breakpoints.down('xs')]: {
      padding: '0.5rem',
      margin: '0.5rem',
    },
  },
  featuredProductCompany: {
    marginTop: 20,
    color: 'rgba(255, 255, 255, 0.3) !important',
    fontSize: 14,
    lineHeight: 1.1,
    height: 26,
    display: '-webkit-box',
    '-webkit-line-clamp': 2,
    '-webkit-box-orient': 'vertical',
    overflow: 'hidden',
    paddingBottom: '5px',
    fontFamily:'mulibold !important',
  },
  featuredProductName: {
    fontSize: 20,
    lineHeight: 1.1,
    height: 44,
    display: '-webkit-box',
    '-webkit-line-clamp': 2,
    '-webkit-box-orient': 'vertical',
    overflow: 'hidden',
    marginTop: '5px',
    fontFamily:'muliregular !important',

    [theme.breakpoints.down('xs')]: {
      fontSize: 16,
      lineHeight: 1.2,
      height: 38,
      '-webkit-line-clamp': 2,
    },
  },
  featuredProductPrice: {
    color: 'rgba(255, 255, 255, 0.5) !important',
    marginTop: 10,
    fontSize:'13pt',
    fontFamily: 'muliextralight',
  },
  featuredProductPromotion: {
    padding: 10,
    fontSize: 12,
    textTransform: 'uppercase',
    backgroundColor: '#00c997',
    borderRadius: '50%',
    width: 60,
    height: 60,
    position: 'absolute',
    top: -20,
    left: -20,
    boxSizing: 'content-box',
    fontFamily:'mulibold !important',

    [theme.breakpoints.down('sm')]: {
      width: 40,
      height: 40,
      fontSize: 14,
      display: 'none',
    },

    [theme.breakpoints.down('xs')]: {
      width: 40,
      height: 40,
      fontSize: 14,
    },
  },
  featuredProductPromotionMobile: {
    padding: 10,
    fontSize: 16,
    textTransform: 'uppercase',
    backgroundColor: '#00c997',
    borderRadius: '20px',
    fontWeight: 'bold',
    boxSizing: 'content-box',
    display: 'none',
    marginTop: '5px',

    [theme.breakpoints.down('sm')]: {
      display: 'inline-flex',
      fontSize: 14,
      padding: 7,
    },
  },
  featuredProductAddToCart: {
    margin: '15px auto 0',
    width: '2em',
    height: '2em',
    backgroundColor: '#2b2d37',
    borderRadius: '50%',
    cursor: 'pointer',
    position: 'relative',

    '&::before': {
      display: 'block',
      backgroundImage: `url(${CartIcon})`,
      backgroundPosition: 'center',
      backgroundRepeat: 'no-repeat',
      backgroundSize: 'cover',
      content: '""',
      transform: 'translate(-50%, -50%)',
      position: 'absolute',
      top: '50%',
      left: '50%',
      width: '1em',
      height: '0.8em',
    },
  },
  productThumbnail: {
    position: 'relative',
    display: 'inline-block',

    '& .favoriteIcon': {
      position: 'absolute',
      right: '0',
      bottom: '0',
      opacity: 0,
      backgroundColor: '#00c796',
      borderRadius: '50%',
      width: '35px',
      height: '35px',
      boxSizing: 'border-box',
      padding: '8px',
      transition: 'all 300ms linear',

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
  },
}))

interface FeaturedProductProps {
  product: IProduct
}

export const FeaturedProduct: React.FC<FeaturedProductProps> = ({
  product,
}) => {
  const classes = useStyles()
  const { isLoggedIn } = useAuth()
  const { userState } = useUserFacade()
  const { store: userStore } = userState
  const { favorites, addFavorite, removeFavorite, loadFavorites } =
    useFavoritesFacade()
  const {
    isOpen: isCartModalOpen,
    showModal: showCartModal,
    hideModal: hideCartModal,
    Modal: CartModalWrapper,
  } = useModal()

  const isFavorite = useMemo(
    () =>
      (favorites || []).findIndex((favorite) => favorite.id === product.id) >=
      0,
    [favorites, product.id]
  )

  return (
    <>
      <Link to={`/product/${product.id}`}>
        <Box className={classes.featuredProduct}>
          <Box className={classes.productThumbnail}>
            <img
              src={
                product.image_url ??
                'https://treezculturecannabisclubbanning.s3.amazonaws.com/product/1e43a152-f84f-4022-a2c6-0c66c86e9e70_f82cd7ae-a76d-41d5-bcfb-ba04b7015908_null_20-04-21-09-27-54'
              }
              alt={product.name}
            />
            <FontAwesomeIcon
              className={`favoriteIcon ${isFavorite ? 'active' : ''}`}
              icon={fasHeart}
              onClick={(e) => {
                if (!isFavorite) {
                  if (isLoggedIn) addFavorite({ storeId: userStore, product })
                  else toast.info('Please Sign up or Log in to add favorites')
                } else {
                  removeFavorite(product.id)
                }
                e.preventDefault()
                return false
              }}
              color="red"
              fill="blue"
              size="2x"
            />

          {product.promotion && (
            <>
              <Box
                display="flex"
                alignItems="center"
                justifyContent="center"
                className={classes.featuredProductPromotion}
              >
                {product.promotion}
              </Box>
              <Box
                display="flex"
                alignItems="center"
                justifyContent="center"
                className={classes.featuredProductPromotionMobile}
              >
                {product.promotion}
              </Box>
            </>
          )}

          </Box>
          <Typography className={classes.featuredProductCompany}>
            {product.brand_name}
          </Typography>
          
          <Typography component="p" className={classes.featuredProductName}>
            {product.name}
          </Typography>
          <Typography component="p" className={classes.featuredProductPrice}>
            <span className='small-text'>From</span> ${product.min_price}
          </Typography>
          <Box
            className={classes.featuredProductAddToCart}
            onClick={(e) => {
              showCartModal()
              e.preventDefault()
              return false
            }}
          ></Box>
        </Box>
      </Link>
      <CartModalWrapper>
        <CartModal product={product} hide={hideCartModal} />
      </CartModalWrapper>
    </>
  )
}
