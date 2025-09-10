import React, { useState, useEffect } from 'react'
import { useHistory } from 'react-router'
import { makeStyles } from '@material-ui/core/styles'
import clsx from 'clsx'
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
} from '@material-ui/core'

import { useCartFacade } from 'state/cart'
import { useUserFacade } from 'state/user'
import { useModal } from 'hooks'
import * as TreezService from 'services/treez.service'
import { ICartState } from 'state/cart/cart.slice'
import { IStore, ITreezUser, ITreezOrder } from 'types'

import { TextWidget } from '../textWidget'

const useStyles = makeStyles({
  cart: {
    marginTop: '100px',
    padding: 50,
  },
  cartHeading: {
    fontSize: 80,
    color: 'white',
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
    marginRight: '10px',

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
    color: 'white',
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
    color: 'white',

    '& .price': {
      fontSize: 50,
    },

    '& .tax': {
      fontSize: 14,
      color: 'rgba(255, 255, 255, 0.3)',
    },
  },
  primaryButton: {
    backgroundColor: '#09c796 !important',
    fontSize: 25,
    fontWeight: 700,
    color: 'white !important',
    borderRadius: 25,
    lineHeight: 1.1,
    padding: '15px 20px',
    margin: '0 5px',
    minWidth: '100px',
  },
  secondaryButton: {
    backgroundColor: '#242B35 !important',
    fontSize: 25,
    fontWeight: 700,
    color: 'white !important',
    borderRadius: 25,
    lineHeight: 1.1,
    padding: '15px 20px',
    margin: '0 5px',
  },
  cartItemEditInput: {
    color: 'white',
    width: '100px',
    marginRight: '10px',
  },
  button: {
    backgroundColor: '#09c796 !important',
    fontSize: 25,
    fontWeight: 700,
    color: 'white !important',
    borderRadius: 25,
    lineHeight: 1.1,
    padding: '15px 20px',
    margin: '0 5px',
  },
})

type ILastPurchaseProps = {
  data?: ICartState
}

export const LastPurchase: React.FC<ILastPurchaseProps> = ({ data }) => {
  const classes = useStyles()
  const history = useHistory()
  const { cartState, setCart } = useCartFacade()
  const { isOpen, showModal, hideModal, Modal } = useModal()
  const { userState, updateUserState } = useUserFacade()
  const { store: userStore, company } = userState

  const [purchaseData, setPurchaseData] = useState(data)
  const [editItem, setEditItem] = useState('')
  const [editItemCount, setEditItemCount] = useState(0)
  const [modalMessage, setModalMessage] = useState('Your current cart items will be removed.')

  const reorderPickup = () => {
    if(modalMessage === 'Your current cart items will be removed.'){
      setCart(purchaseData)
      history.push('/cart')
    }
  }

  useEffect(() => {
    setPurchaseData(data)
  }, [data])

  return (
    <>
      {purchaseData && purchaseData[userStore] &&
        purchaseData[userStore].items.map((item, index) => {
          const { product, count } = item
          return (
            <Box display="flex" className={classes.cartItem} key={product.id}>
              {index === 0 && (
                <div className={clsx(classes.cartItemSeparator, 'top')} />
              )}
              <Box className={classes.cartItemImage}>
                <img src={`${process.env.REACT_APP_EXTERNAL_API_URL}/products/findBySku/${product.id}`} alt={product.name} />
              </Box>
              <Box>
                <Typography component="p" className={classes.cartItemName}>
                  {product.name}
                </Typography>
                <Typography className={classes.cartItemAmount}>
                  ${product.min_price} x{' '}
                  {editItem === product.id ? (
                    <Box display="inline-flex">
                      <TextField
                        InputProps={{
                          className: classes.cartItemEditInput,
                        }}
                        type="number"
                        value={editItemCount}
                        onChange={(e) => {
                          if (+e.target.value >= 1)
                            setEditItemCount(+e.target.value)
                        }}
                        color="primary"
                      />
                      <Link
                        href="#"
                        className={classes.cartItemEdit}
                        onClick={() => {
                          setPurchaseData((purchaseData) => {
                            if (purchaseData && purchaseData[userStore]) {
                              const items = purchaseData[userStore].items.map((item) => {
                                if (item.product.id === editItem) {
                                  return { ...item, count: editItemCount }
                                }
                                return item
                              })

                              const totalPrice = items.reduce((sum, item) => {
                                return (
                                  sum + item.count * +item.product.min_price
                                )
                              }, 0)

                              return { ...purchaseData, [userStore]:{ totalPrice, items} }
                            }
                          })
                          setEditItem('')
                        }}
                      >
                        OK
                      </Link>
                    </Box>
                  ) : (
                    count
                  )}
                </Typography>
                
              </Box>
              <Typography className={classes.cartItemPrice}>{`$${
                count * +product.min_price
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
          <Typography className="price">${purchaseData && purchaseData[userStore] ? purchaseData[userStore]?.totalPrice:0}</Typography>
          <Typography component="p" className="tax">
            PRICES DO NOT INCLUDE TAX
          </Typography>
        </Box>
      </Box>
      <Box display="flex" mt={2} justifyContent="right">
        <Button
          className={classes.button}
          variant="contained"
          onClick={()=>{setModalMessage('Your current cart items will be removed.');showModal()}}
        >
          Re-order Pickup
        </Button>
          {/*
          <Button className={classes.button} variant="contained" 
            onClick={()=>{setModalMessage('Delivery not yet available. Check back for Updates');showModal()}}>
            Re-order
            <br />
            Delivery
          </Button>
         */}        
      </Box>
      <Modal>
        <Typography component="h1" className={classes.cartItemName}>
          {modalMessage}
        </Typography>
        <Box mt="30px" textAlign="center">
          <Button
            variant="contained"
            className={classes.primaryButton}
            onClick={() => {
              hideModal()
              reorderPickup()
            }}
          >
            OK
          </Button>
        </Box>
      </Modal>
    </>
  )
}
