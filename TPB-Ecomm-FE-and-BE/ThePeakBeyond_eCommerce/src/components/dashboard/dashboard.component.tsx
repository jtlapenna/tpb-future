import React, { useState, useEffect, useMemo } from 'react'
import { useHistory, useLocation } from 'react-router-dom'
import { Auth } from 'aws-amplify'
import { makeStyles, useTheme } from '@material-ui/core/styles'
import clsx from 'clsx'
import {
  Box,
  Grid,
  Button,
  Typography,
  Card,
  CardHeader,
  CardContent,
  CardMedia,
  useMediaQuery,
} from '@material-ui/core'
import {max} from "lodash";

import { useUserFacade } from 'state/user'
import { useCartFacade } from 'state/cart'
import { ICartState } from 'state/cart/cart.slice'
import { httpGet } from 'services/http-client.service'
import * as TreezService from 'services/treez.service'
import { IStore, ITreezUser, ITreezOrder, IProduct } from 'types'
import lp from "../../assets/images/last_purchase.png";
import bs from "../../assets/images/bs.png";
import dh from "../../assets/images/dh.png";
import hd from "../../assets/images/hd.png";

import { ReactComponent as SvgCart } from 'assets/icons/icon-cart.svg'

import {
  UserPicker,
  StorePicker,
  TextWidget,
  FeaturedProduct,
  Cart,
  LastPurchase,
} from '../_ui'
import userIcon from 'assets/images/user.png'
import banner from 'assets/images/cannabis_club_banner.png'
import dealHightlightImage from 'assets/images/spot.jpg'
import lastPurchaseImage from 'assets/images/last_purchase.png'
import { MobileSidebar } from '../sidebar'
import { getStoreImages } from 'utils/local-storage.utility'

const useStyles = makeStyles((theme) => ({
  orderstatusName:{
    [theme.breakpoints.down('sm')]: {
     paddingTop:8,
    },
  },

  orderProducts: {
    height     : '60px',
    position   : 'relative',
    minWidth  : '280px',

    [theme.breakpoints.down('sm')]: {
      height        : '50px',
      minWidth  : '235px',
    },

    '& img': {
      height       : '100%',
      width        : '60px',
      float        : 'left',
      borderRadius: '50%',
      transform    : 'translateX(-50%)',
      marginRight : '10px',

      [theme.breakpoints.down('sm')]: {
        width        : '50px',
      },

    }
  },
  dashboard: {
    padding: '0 20px',
    position: 'relative',
    overflowX:'hidden',

    [theme.breakpoints.down('sm')]: {
      padding: 0,
      overflowX:'hidden',
    },
  },
  dashboardContainer: {
    animation: 'slideInWithTransationFromLeft 0.5s ease',
  },
  dashboardUserPicker: {
    position: 'absolute',
    right: 20,
    top: 20,

    [theme.breakpoints.down('sm')]: {
      position: 'static',
      flexShrink: 0,
      marginLeft: 'auto',
    },
  },
  header: {
    height: 300,
    animation: 'slideInWithTransationFromTop 0.7s ease',

    [theme.breakpoints.down('sm')]: {
      height: 200,
    },

    '& img': {
      height: '100%',
      width: '100%',
      objectFit: 'cover',
    },
  },
  card: {
    backgroundColor: 'transparent',
    boxShadow: 'none',
  },
  cardHeader: {
    textAlign: 'center',
    '& span': {
      fontWeight: 'bold',
    },
  },
  orderStatus: {
    marginTop: 50,
    textAlign: 'center',
    color: 'white',


    '& .MuiCardContent-root': {
      padding: 0,
    },
    [theme.breakpoints.down('xs')]: {
      marginTop: 0,
      paddingTop: 8,
      paddingBottom: 16,
    },
  },
  orderStatusHeader: {
    [theme.breakpoints.down('xs')]: {
      padding: 8,
    },

    '& span': {
      fontSize: 40,

      [theme.breakpoints.down('sm')]: {
        fontSize: 25,
      },
      [theme.breakpoints.down('xs')]: {
        fontSize: 20, 
      },
    },
  },
  orderStatusBox: {
    padding: '20px 50px',
    border: '1px solid white',
    borderRadius: 10,

    [theme.breakpoints.down('xs')]: {
      padding: '10px 10px',
      paddingLeft:'30px',
    },

    '& p': {
      fontSize: 30,
      marginLeft: 30,
      color: '#09c796 !important',
      whiteSpace: 'nowrap',

      [theme.breakpoints.down('xs')]: {
        fontSize: 16,
        marginLeft: 0,
      },
    },
  },
  orderStatusImage: {
    width: 40,
    height: 40,
    marginRight: 10,

    [theme.breakpoints.down('xs')]: {
      width: 25,
      height: 25,
    },
  },
  dealHighlight: {
    marginTop: 50,
    color: 'white',

    '& .MuiCardContent-root': {
      padding: 0,
    },

    [theme.breakpoints.down('xs')]: {
      marginTop: 0,
      paddingTop: 16,

      '& .MuiCardContent-root': {     
        paddingLeft: 0,
        paddingRight: 0,
      },
    },
  },
  dealHighlightHeader: {
    padding: 60,
    backgroundColor: 'transparent',
    '& span': {
      fontSize: 30,
      [theme.breakpoints.down('sm')]: {
        fontSize: 20,
      },
    },
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat',
    backgroundSize: 'cover',

    [theme.breakpoints.down('sm')]: {
      padding: 30,
    },
  },
  lastPurchase: {
    marginTop: 50,
    color: 'white',

    '& .MuiCardContent-root': {
      padding: '16px 0',
    },
  },
  lastPurchaseHeader: {
    padding: 40,
    textTransform: 'uppercase',
    backgroundColor: 'transparent',
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat',
    backgroundSize: 'cover',
  },
  spotLightContent: {
    width: '100%',
    height: 300,
    backgroundColor: 'black',
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat',
    backgroundSize: 'cover',
    cursor:'pointer',
  },
  yourRewards: {
    '& span': {
      color: 'white !important',
      marginRight: 20,
      fontSize: 30,
    },
    [theme.breakpoints.down('sm')]: {
      display: 'none',
    },
  },
  yourRewardsPoint: {
    color: '#00c796 !important',
    fontSize: 30,
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
  welcomeText: {
    justifyContent: 'flex-start',
    color: 'white',

    [theme.breakpoints.down('sm')]: {
      marginTop: 30,
    },
    [theme.breakpoints.down('xs')]: {
      marginTop: 8,
    },
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
  headerContainer: {
    height: 300,
  },
  orderProductsContainer: {
    minWidth: 'var(--dynamic-width, 280px)',
    [theme.breakpoints.down('sm')]: {
      minWidth: 'var(--dynamic-width, 235px)',
    },
  },
  dealHighlightsCard: {
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat',
    backgroundSize: 'cover',
  },
  lastPurchaseCard: {
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat',
    backgroundSize: 'cover',
  },
  lastPurchaseContent: {
    textAlign: 'center',
  },
  lastPurchaseText: {
    fontSize: 20,
  },
  brandSpotlightCard: {
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat',
    backgroundSize: 'cover',
  },
  spotlightContent: {
    backgroundPosition: 'center',
    backgroundRepeat: 'no-repeat',
    backgroundSize: 'cover',
  },
}))

export const Dashboard = () => {
  const classes = useStyles()
  const theme = useTheme()
  const history = useHistory()
  const matchesMobile = useMediaQuery(theme.breakpoints.down('sm'))
  const { userState, updateUserState } = useUserFacade()
  const { store: userStore, company} = userState

  const [activeMenu, setActiveMenu] = useState(0)
  const [stores, setStores] = useState<IStore[]>([])
  const [lastPurchaseData, setLastPurchaseData] = useState<ICartState>()
  const [treezUser, setTreezUser] = useState<ITreezUser>()
  const [treezOrders, setTreezOrders] = useState<ITreezOrder[]>([])
  const [maxOrderItems, setMaxOrderItems] = useState<number>(0)

  const [companyData, setCompanyData] = useState({
    header:hd,
    dealHighlights:dh,
    lastPurchase:lp,
    brandSpotlight:bs,
    dealHightlightImage:dealHightlightImage,
    brandId:117,
  })
  const [dealhighlights, setDealhighlights] = useState<IProduct[]>([])

  useEffect(()=> {

    if(userStore) {
      const images = getStoreImages(userStore);
        setCompanyData({
          header:images.find(c=>c.codename === "HEADER_IMAGE")?.url || hd,
          dealHighlights: images.find(c=>c.codename === "DEALS")?.url ||   dh,
          lastPurchase: images.find(c=>c.codename === "LAST_PURCHASE")?.url ||  lp,
          brandSpotlight: images.find(c=>c.codename === "BRAND_SPOTLIGHT")?.url || bs,
          dealHightlightImage:images.find(c=>c.codename === "BRAND_SPOTLIGHT")?.brand_url || dealHightlightImage,
          brandId:images.find(c=>c.codename === "BRAND_SPOTLIGHT")?.advertisable_id || 117,
        });
    }

    if (userStore && treezUser && userState) {
      TreezService.getOrders(userStore, userState)
        .then((result) => {
          setTreezOrders((result.ticketList || []).filter(order=> !['COMPLETED','CANCELED'].includes(order.order_status)));
          const images = (result.ticketList || []).map(c=>c.items.length);
          setMaxOrderItems(max(images) || 0);
        })
        .catch((err) => console.log({ err }))
    }

  },[userStore, treezUser, userState]);

  const setActiveStore = (store)=>{
    updateUserState({ store: store });
  }

  useEffect(() => {
    if (company) {
      httpGet(`/store/all/${company}/id/1/0/`).then((result: IStore[]) => {
        setStores(result)
      })
    }
  }, [company])

  useEffect(() => {
    if (stores && stores.length && !userStore) {
      updateUserState({ store: stores[0].id })
    } else if (stores && stores.length && userStore) {
      if (stores.filter((store) => store.id === userStore).length === 0) {
        updateUserState({ store: stores[0].id })
      }
    }
  }, [stores])

  useEffect(() => {
    if (userStore) {
      Auth.currentAuthenticatedUser().then((currentUser) => {
        Auth.updateUserAttributes(currentUser, {
          'custom:store': userStore,
        })
      })
    }
  }, [userStore])

  useEffect(() => {
    if (userState && userState.email && userStore) {
      TreezService.findUserByEmail(userStore, userState.email).then(
        (result) => {
          if (
            result.resultCode === 'SUCCESS' &&
            result.data &&
            result.data.length
          ) {
            setTreezUser(result.data[0])
          }
        }
      )
    }
  }, [userState, userStore])

  const gotobrand = ()=> {
    document.location.href = `/brands?brand=${companyData.brandId}`;
  }

  const formatOrderStatus = (status:string) =>{
    switch(status.toUpperCase()){
      case "VERIFICATION_PENDING":return "Verification Pending";
      case "AWAITING_PROCESSING":return "Awaiting Processing";
      case "IN_PROCESS":return "In Process";
      case "PACKED_READY":return "Ready for Pickup";
      case "OUT_FOR_DELIVERY":return "Out For Delivery";
      case "COMPLETED":return "Completed";
      case "CANCELED":return "Canceled";
      default:
        return status;
    }
  }
  useEffect(() => {
    if (userStore) {
      httpGet(`/products/highlights/${userStore}`)
        .then((result) => {
          setDealhighlights(result)
        })
        .catch((err) => console.log('Dealhighlights - ', err))
    }
  }, [userStore])

  useEffect(() => {
    if (treezOrders && treezOrders.length > 0) {
      const lastOrder = treezOrders[treezOrders.length - 1]
      const products = lastOrder.items.map((orderItem) => ({
        count: orderItem.quantity,
        storeId:userStore ,
        product: {
          id: orderItem.product_id,
          name: orderItem.product_size_name,
          category_id: '',
          description: '',
          brand_id: '',
          image_url:
            'https://treezculturecannabisclub.s3.amazonaws.com/product/1e43a152-f84f-4022-a2c6-0c66c86e9e70_632df828-31a5-4d8a-ac6a-49752cb38db6_null_19-05-21-12-47-41',
          thumb_image:
            'https://treezculturecannabisclub.s3.amazonaws.com/product/1e43a152-f84f-4022-a2c6-0c66c86e9e70_632df828-31a5-4d8a-ac6a-49752cb38db6_null_19-05-21-12-47-41',
          stock: 1,
          min_price: orderItem.price_sell,
          brand_name: orderItem.product_brand,
          sku:
            orderItem.barcodes && orderItem.barcodes.length > 0
              ? orderItem.barcodes[0]
              : '',
        },
      }))
      const totalPrice = products.reduce(
        (total, product) =>
          (total += product.count * product.product.min_price),
        0
      )

      const state = {
        [userStore]:{
          totalPrice, 
          items: products,
        }
      };

      setLastPurchaseData(state);
    }
  }, [treezOrders, userStore])

  return (
    <>
      <Box className={classes.dashboard}>
          {matchesMobile ? (
           <MobileSidebar activeMenu={activeMenu} />
          ):(
            <div className={classes.headerContainer}>
              <img src={companyData.header} alt="" className="commpany-header" />
            </div>
          )}
        <Box className={classes.dashboardContainer}>

          {!matchesMobile && (
            <Box
              mt={1}
              mb={1}
              display="flex"
              flexWrap="wrap"
              justifyContent="flex-end"
            >
              <StorePicker
                stores={stores}
                activeStore={userStore}
                setActiveStore={(store) => setActiveStore(store)}
              />
              {/* <Box display="inline-flex" className={classes.dashboardUserPicker}>
                <Box
                  display={{
                    xs: 'flex',
                    sm: 'flex',
                    md: 'none',
                    lg: 'none',
                    xl: 'none',
                  }}
                  onClick={() => history.push('/cart')}
                  className={classes.myCart}
                >
                  <SvgCart />
                  <Typography component="span" className="item-count">
                    {cartState.items.length ?? 0}
                  </Typography>
                </Box>
                <UserPicker />
              </Box> */}
            </Box>
          )}
          <Box
            display={{
              xs: 'block',
              sm: 'block',
              md: 'none',
              lg: 'none',
              xl: 'none',
            }}
          >
           

            {matchesMobile && (
            <Box
              mt={1}
              mb={1}
              display="flex"
              flexWrap="wrap"
              justifyContent="flex-end"
            >
              <StorePicker
                stores={stores}
                activeStore={userStore}
                setActiveStore={(store) => setActiveStore(store)}
              />
              {/* <Box display="inline-flex" className={classes.dashboardUserPicker}>
                <Box
                  display={{
                    xs: 'flex',
                    sm: 'flex',
                    md: 'none',
                    lg: 'none',
                    xl: 'none',
                  }}
                  onClick={() => history.push('/cart')}
                  className={classes.myCart}
                >
                  <SvgCart />
                  <Typography component="span" className="item-count">
                    {cartState.items.length ?? 0}
                  </Typography>
                </Box>
                <UserPicker />
              </Box> */}
            </Box>
          )}
          </Box>
          {userState.email && (
            <Box
              display="flex"
              alignItems="center"
              className={classes.welcomeText}
              p={1}
            >
              <TextWidget
                text={`Welcome${
                  userState.given_name ? ` Back, ${userState.given_name}` : ''
                }`}
                style={"muliregular"}
                font={'muliregular'}
                size={matchesMobile ? 25 : 50}
              />
              {/* <Box display="flex" className={classes.yourRewards}>
                <Typography component="span">Your Rewards</Typography>
                <Typography className={classes.yourRewardsPoint}>
                  390 PTS
                </Typography>
              </Box> */}
            </Box>
          )}
          {treezOrders && treezOrders.length > 0 ? (
            <div>
              <Card className={clsx(classes.card, classes.orderStatus)}>
                <CardHeader
                  className={clsx(classes.cardHeader, classes.orderStatusHeader)}
                  title="Order Status"
                />
                <CardContent>
                  <Box
                    className={classes.orderStatusBox}
                    display="inline-flex"
                    alignItems="flex-start"
                    flexDirection="column"
                  >
                    {treezOrders
                      ? treezOrders.map((order) => (
                          <Box display={matchesMobile ? "block":"flex"} alignItems="center" marginTop={'10px'} key={order.ticket_id}>
                            <div 
                              className={`${classes.orderProducts} ${classes.orderProductsContainer}`}
                              ref={(el) => {
                                if (el) {
                                  el.style.minWidth = `${(maxOrderItems*(matchesMobile ? 50:60))}px`;
                                }
                              }}
                            >
                              {order.items.map(product=>(
                                <img key={product.product_id}alt='' src={`${process.env.REACT_APP_EXTERNAL_API_URL}/products/findBySku/${product.product_id}`} />
                              ))}
                            </div>
                            <Typography component="p" className={classes.orderstatusName}>
                              {formatOrderStatus(order.order_status)}
                            </Typography>
                          </Box>
                        ))
                      : null}
                  </Box>
                </CardContent>
              </Card>
            </div>
          ) : null}
          <Card className={clsx(classes.card, classes.dealHighlight)}>
            <CardHeader
              className={clsx(classes.cardHeader, classes.dealHighlightHeader, classes.dealHighlightsCard)}
              title="DEAL HIGHLIGHTS"
              style={{ backgroundImage: `url(${companyData.dealHighlights})` }}
            />
            <CardContent>
              <Grid container>
                {dealhighlights &&
                  dealhighlights.map((product, index) => (
                    <Grid item lg={3} sm={4} xs={6} key={index}>
                      <FeaturedProduct product={product} />
                    </Grid>
                  ))}
              </Grid>
            </CardContent>
          </Card>
          <Grid container spacing={matchesMobile ? 0 : 8}>
            {userState.email && (
              <Grid item lg={6} xs={12}>
                <Card className={clsx(classes.card, classes.lastPurchase)}>
                  <CardHeader
                    className={clsx(
                      classes.cardHeader,
                      classes.lastPurchaseHeader,
                      classes.lastPurchaseCard
                    )}
                    title="Your Last Purchase"
                    style={{
                      backgroundImage: `url(${companyData.lastPurchase})`,
                    }}
                  />
                  <CardContent className={classes.lastPurchaseContent}>
                    {lastPurchaseData && lastPurchaseData[userStore]?.totalPrice > 0 ? (
                      <LastPurchase data={lastPurchaseData} />
                    ) : (
                      <h1 className={classes.lastPurchaseText}> Your most recent order will appear here once completed. </h1>
                    )}
                  </CardContent>
                </Card>
              </Grid>
            )}
            <Grid item lg={6} xs={12}>
              <Card className={clsx(classes.card, classes.lastPurchase)}>
                <CardHeader
                  className={clsx(
                    classes.cardHeader,
                    classes.lastPurchaseHeader,
                    classes.brandSpotlightCard
                  )}
                  title="Brand Spotlight"
                  style={{
                    backgroundImage: `url(${companyData.brandSpotlight})`,
                  }}
                />
                <CardContent>
                  <Box onClick={gotobrand} 
                    className={`${classes.spotLightContent} ${classes.spotlightContent}`}
                    style={{backgroundImage:`url(${companyData.dealHightlightImage})`}}
                  ></Box>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </Box>
      </Box>
    </>
  )
}
