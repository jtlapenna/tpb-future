import React, { useState, useMemo, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { toast } from 'react-toastify'
import { makeStyles,useTheme } from '@material-ui/core/styles'
import { Box, Typography, useMediaQuery } from '@material-ui/core'
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
  productCard: {
    textAlign: 'center',
    borderRadius: '1rem',
    padding: '30px 16px',
    color: 'white',
    position: 'relative',
    marginTop: 16,
    maxWidth: 300,
    
    '& img': {
      borderRadius: '50%',
      width: '80%',
      aspectRatio: '1',
    },

    [theme.breakpoints.down('xs')]: {
      padding: '1rem 0.25rem',

      '& img': {
  
        width: '80%',
        },
    },

    '&:hover': {
      '& .favoriteIcon': {
        opacity: 1,
      },
    },
  },
  productCardCompany: {
    fontSize: 14,
    lineHeight: 1.1,
    marginTop: 16,
    color: 'rgba(255, 255, 255, 0.3) !important',
    height: 26,
    display: '-webkit-box',
    '-webkit-line-clamp': 2,
    '-webkit-box-orient': 'vertical',
    overflow: 'hidden',
    textTransform: 'uppercase',
  },
  productCardBrand: {
    fontSize: 14,
    lineHeight: 1.1,
    marginTop: 16,
    color: 'rgba(255, 255, 255, 0.3) !important',
    height: 26,
    display: '-webkit-box',
    '-webkit-line-clamp': 2,
    '-webkit-box-orient': 'vertical',
    overflow: 'hidden',
    textTransform: 'uppercase',
    fontFamily:'mulibold !important',

    [theme.breakpoints.down('xl')]: {
      fontSize:'9pt',
    }
  },
  productCardName: {
    fontSize: 20,
    lineHeight: 1.1,
    height: 44,
    display: '-webkit-box',
    '-webkit-line-clamp': 2,
    '-webkit-box-orient': 'vertical',
    overflow: 'hidden',
    fontFamily:'muliextralight !important',

    [theme.breakpoints.down('xs')]: {
      fontSize: 16,
      lineHeight: 1.2,
      '-webkit-line-clamp': 2,
    },

    [theme.breakpoints.down('xl')]: {
      fontSize: '15pt',
    
    },
  },
  productCardPrice: {
    color: 'rgba(255, 255, 255, 0.5) !important',
    marginTop: 4,
    lineHeight: 2,
    whiteSpace: 'nowrap',

    [theme.breakpoints.down('xl')]: {
      fontSize: '13pt',
      fontFamily:'muliextralight !important',

      '& span': {
        fontSize: '9pt',
        fontFamily:'muliextralight !important',
      }
    },
  },
  productCardPromotion: {
    padding: 10,
    fontSize: 14,
    textTransform: 'uppercase',
    backgroundColor: '#00c997',
    borderRadius: '50%',
    width: 60,
    height: 60,
    fontWeight: 'bold',
    position: 'absolute',
    top: 10,
    left: 10,

    [theme.breakpoints.down('xs')]: {
      width: 40,
      height: 40,
      fontSize: 16,
    },
  },
  productCardAddToCart: {
    margin: '0 auto 0',
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
    backgroundPosition: 'center',
    backgroundSize: 'cover',
    borderRadius: '50%',
    backgroundColor:'white',

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
  },
  productImageXl: {
    width: 'calc(100% - 80px)',
  },
  productImageDefault: {
    width: 'calc(100% - 60px)',
  },
}))

interface IProductCardProps {
  product: IProduct
  isFavorite: boolean
  width?:number;
  lessColumn?:boolean,
  addFavorite: (product: IProduct) => void
  removeFavorite: (product: IProduct) => void
}

export const ProductCard: React.FC<IProductCardProps> = ({
  product,
  isFavorite,
  width,
  addFavorite,
  removeFavorite,
  lessColumn,
}) => {
  const classes = useStyles()
  const { isLoggedIn } = useAuth()
  const {
    isOpen: isCartModalOpen,
    showModal: showCartModal,
    hideModal: hideCartModal,
    Modal: CartModalWrapper,
  } = useModal()

  const theme = useTheme()
  const isXl = useMediaQuery(theme.breakpoints.down('xl'))

  const getImageClassName = () => {
    if(width && width!==-1){
      if(isXl){
        return classes.productImageXl;
      }else{
        return classes.productImageDefault;
      }
    }
    return '';
  }

  return (
    <>
      <Link to={`/product/${product.id}`}>
        <Box className={classes.productCard}>
          {width && width!==-1 ? (
            <Box
              display="inline-block"
              position="relative"
              className={classes.productThumbnail}
              style={{
                width: Math.max(172, width-(lessColumn  ? 200:100)),
                height:Math.max(172, width-(lessColumn  ? 200:100)),
                backgroundImage:`url(${product.image_url ??
                  'https://treezculturecannabisclubbanning.s3.amazonaws.com/product/1e43a152-f84f-4022-a2c6-0c66c86e9e70_f82cd7ae-a76d-41d5-bcfb-ba04b7015908_null_20-04-21-09-27-54'})`
              }}
            >
             
              <FontAwesomeIcon
                className={`favoriteIcon ${isFavorite ? 'active' : ''}`}
                icon={fasHeart}
                onClick={(e) => {
                  if (!isFavorite) {
                    if (isLoggedIn) addFavorite(product)
                    else toast.info('Please Sign up or Log in to add favorites')
                  } else {
                    removeFavorite(product)
                  }
                  e.preventDefault()
                  return false
                }}
                size="2x"
              />
            </Box>
          ):(
            <Box
              display="inline-block"
              position="relative"
              className={classes.productThumbnail}
            >
              <img
                src={
                  product.image_url ??
                  'https://treezculturecannabisclubbanning.s3.amazonaws.com/product/1e43a152-f84f-4022-a2c6-0c66c86e9e70_f82cd7ae-a76d-41d5-bcfb-ba04b7015908_null_20-04-21-09-27-54'
                }
                alt={product.name}
                className={getImageClassName()}
              />
              <FontAwesomeIcon
                className={`favoriteIcon ${isFavorite ? 'active' : ''}`}
                icon={fasHeart}
                onClick={(e) => {
                  if (!isFavorite) {
                    if (isLoggedIn) addFavorite(product)
                    else toast.info('Please Sign up or Log in to add favorites')
                  } else {
                    removeFavorite(product)
                  }
                  e.preventDefault()
                  return false
                }}
                size="2x"
              />
            </Box>
          )}
          
            
          <Typography className={classes.productCardBrand}>
            {product.brand_name}
          </Typography>
          <Typography component="p" className={classes.productCardName}>
            {product.name}
          </Typography>
          <Typography component="p" className={classes.productCardPrice}>
            <span>From</span> ${product.min_price}
          </Typography>
          <Box
            className={classes.productCardAddToCart}
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
