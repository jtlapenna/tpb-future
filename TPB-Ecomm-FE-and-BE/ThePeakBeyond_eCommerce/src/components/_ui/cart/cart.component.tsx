import React, { useMemo } from 'react'
import { makeStyles } from '@material-ui/core/styles'
import clsx from 'clsx'
import { Box, Typography, Link } from '@material-ui/core'

import { TextWidget } from '../textWidget'

const useStyles = makeStyles({
  cart: {
    padding: '30px 15px',
  },
  cartItem: {
    padding: '30px 0px',
    paddingRight: 90,
    position: 'relative',
  },
  cartItemImage: {
    width: 80,
    marginRight: 30,

    '& img': {
      borderRadius: '50%',
    },
  },
  cartItemName: {
    margin: 0,
    fontSize: 20,
    lineHeight: 1.4,
    color: 'white',
  },
  cartItemAmount: {
    marginTop: 0,
    marginBottom: 10,
    fontSize: 20,
    lineHeight: 1.4,
    color: 'rgba(255, 255, 255, 0.5) !important',
  },
  cartItemEdit: {
    color: '#00c796 !important',
    textDecoration: 'none',
    cursor: 'pointer',

    '&:hover': {
      textDecoration: 'underline',
    },
  },
  cartItemPrice: {
    position: 'absolute',
    top: 30,
    right: 0,
    fontSize: 20,
    lineHeight: 1.4,
    fontWeight: 700,
  },
  cartItemSeparator: {
    display: 'block',
    position: 'absolute',
    left: 0,
    width: '100%',
    height: 1,
    background: 'rgba(255, 255, 255, 0.3)',

    '&.top': {
      top: 0,
    },
    '&.bottom': {
      bottom: 0,
    },
  },
  cartTotal: {
    padding: 15,
  },
  cartTotalPrice: {
    marginLeft: 60,
    textAlign: 'right',

    '& .price': {
      fontSize: 50,
    },

    '& .tax': {
      fontSize: 12,
      color: 'rgba(255, 255, 255, 0.3)',
    },
  },
})

export const Cart = ({ purchases }) => {
  const classes = useStyles()

  const totalPrice = useMemo(() => {
    return purchases.reduce((sum, purchase) => {
      return sum + purchase.amount * purchase.price
    }, 0)
  }, [purchases])

  return (
    <Box className={classes.cart}>
      {purchases &&
        purchases.map((purchase, index) => {
          const { productName, amount, price, image } = purchase
          return (
            <Box display="flex" className={classes.cartItem} key={index}>
              {index === 0 && (
                <div className={clsx(classes.cartItemSeparator, 'top')} />
              )}
              <Box className={classes.cartItemImage}>
                <img src={image} alt={productName} />
              </Box>
              <Box>
                <Typography component="p" className={classes.cartItemName}>
                  {productName}
                </Typography>
                <Typography className={classes.cartItemAmount}>
                  {amount} x
                </Typography>
                <Link href="#" className={classes.cartItemEdit}>
                  EDIT
                </Link>
              </Box>
              <Typography className={classes.cartItemPrice}>{`$${
                amount * price
              }`}</Typography>
              <div className={clsx(classes.cartItemSeparator, 'bottom')} />
            </Box>
          )
        })}
      <Box
        display="flex"
        justifyContent="flex-end"
        className={classes.cartTotal}
      >
        <Box mt={2}>
          <TextWidget text="TOTAL" size={16} />
        </Box>
        <Box className={classes.cartTotalPrice}>
          <Typography className="price">${totalPrice}</Typography>
          <Typography component="p" className="tax">
            PRICES DO NOT INCLUDE TAX
          </Typography>
        </Box>
      </Box>
    </Box>
  )
}
