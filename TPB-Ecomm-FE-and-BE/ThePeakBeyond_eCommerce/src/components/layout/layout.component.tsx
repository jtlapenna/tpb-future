import React, { useState, useEffect } from 'react'
import { Route, Switch, useLocation, useHistory } from 'react-router-dom'
import { Box, Typography } from '@material-ui/core'
import { makeStyles, useTheme } from '@material-ui/core/styles'

import { useUserFacade } from 'state/user'
import { useCartFacade } from 'state/cart'
import { useFavoritesFacade } from 'state/favorites'
import { useAuth } from 'hooks'

import {
  Sidebar,
  Dashboard,
  Cart,
  Products,
  ProductDetail,
  Brands,
  OnSales,
  BestSellers,
  Favorites,
  OrderStatus,
  PurchaseHistory,
  AccountSettings,
} from 'components'
import { UserPicker } from 'components/_ui'
import { ReactComponent as SvgCart } from 'assets/icons/icon-cart.svg'
import { navigations } from '../../config'
import { Navigation } from 'types/navigation.interface'
import Logo from '../../assets/images/logo-tpb.png'

const useStyles = makeStyles((theme) => ({
  topCart: {
    position: 'fixed',
    top: 20,
    right: 20,
    zIndex: 100,
    display: 'flex',
  },
  myCart: {
    width: 50,
    height: 50,
    borderRadius: '50%',
    backgroundColor: 'var(--primary)',
    cursor: 'pointer',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
    marginRight: '20px',
    display: 'flex',

    '& svg': {
      width: 30,
      marginLeft: -5,
    },

    '& .item-count': {
      position: 'absolute',
      width: 15,
      height: 15,
      padding: 3,
      borderRadius: '50%',
      backgroundColor: 'white',
      color: 'var(--primary) !important',
      top: 0,
      right: 0,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
    },
  },
  logo: {
    opacity: 0.4,
    fontSize: 11,
    lineHeight: 1,
    display: 'flex',
    alignItems: 'center',
    position: 'fixed',
    bottom: 5,
    right: 10,
    zIndex: 999,
    color: 'white',

    '& img': {
      width: 60,
      marginLeft: 5,
    },
  },
  cartItemCount: {
    fontFamily: 'mulisemibold',
    fontSize: '13px',
  },
}))

export const Layout = () => {
  const classes = useStyles()
  const theme = useTheme()
  const location = useLocation()
  const history = useHistory()
  const { userState } = useUserFacade()
  const { store: userStore } = userState
  const { loadFavorites } = useFavoritesFacade()
  const { isLoggedIn } = useAuth()
  const { cartState } = useCartFacade()

  const [activeMenu, setActiveMenu] = useState(0)

  useEffect(() => {
    if (userStore && isLoggedIn) loadFavorites(userStore)
  }, [loadFavorites, userStore, isLoggedIn])

  useEffect(() => {
    const pathname = location.pathname
    setActiveMenu(
      navigations.findIndex((nav: Navigation) => nav.link === pathname)
    )
  }, [setActiveMenu, location.pathname])

  return (
    <>
      <Box
        display={{
          xs: 'none',
          sm: 'none',
          md: 'block',
          lg: 'block',
          xl: 'block',
        }}
        overflow="scroll"
        paddingRight="70px"
        paddingLeft={1}        
      >
        <Sidebar activeMenu={activeMenu} setActiveMenu={setActiveMenu} />
      </Box>
      <Box className={classes.topCart}>
        <Box
          onClick={() => {
            // setActiveMenu(6)
            document.location.href="/cart";
            //history.push('/cart')
          }}
          className={classes.myCart}
        >
          <SvgCart />
          <Typography component="span" className="item-count" >
            <span className={classes.cartItemCount}>{cartState[userStore]?.items.length ?? 0}</span>
          </Typography>
        </Box>
        <UserPicker />
      </Box>
      <Box className={classes.logo}>
        <span>POWERED BY</span>
        <img src={Logo} alt="The Peak Beyond Logo" />
      </Box>
      <Box width="100%" overflow="scroll" paddingX={0} position="relative">
        <Switch>
          <Route path="/" render={() => <Dashboard />} exact />
          <Route path="/cart" render={() => <Cart />} exact />
          <Route path="/products" render={() => <Products />} exact />
          <Route path="/product/:id" render={() => <ProductDetail />} exact />
          <Route path="/brands" render={() => <Brands />} exact />
          <Route path="/onsales" render={() => <OnSales />} exact />
          <Route path="/bestsellers" render={() => <BestSellers />} exact />
          <Route path="/favorites" render={() => <Favorites />} exact />
          <Route
            path="/account-settings"
            render={() => <AccountSettings />}
            exact
          />
          <Route path="/order-status" render={() => <OrderStatus />} exact />
          <Route
            path="/purchase-history"
            render={() => <PurchaseHistory />}
            exact
          />
        </Switch>
      </Box>
    </>
  )
}
