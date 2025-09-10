import React, { useEffect, useState } from 'react'
import { useHistory, useLocation } from 'react-router-dom'
import lottie from 'lottie-web'
import { makeStyles } from '@material-ui/core/styles'
import { Box, Typography, List, ListItem } from '@material-ui/core'
import clsx from 'clsx'

import { useCartFacade } from 'state/cart'
import { navigations } from '../../config'
import { Navigation } from 'types/navigation.interface'

import { TextWidget } from '../_ui/textWidget'
import { ReactComponent as SvgCart } from 'assets/icons/icon-cart.svg'

import animationJson from 'animations/block-intro.json'
import { useUserFacade } from 'state/user'

const useStyles = makeStyles({
  sidebarBtn: {
    position: 'relative',
    width: 250,
    height: 'calc(100vh/7 - 20px)',
    borderRadius: 20,
    color: '#565f68',
    fontSize: 22,
    marginTop: 15,
    cursor: 'pointer',
    transition: 'all 0.3s ease',

    '& .background-gray': {
      '& svg': {
        position: 'absolute',
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        zIndex: 2,
        borderRadius: 20,
        '& path': {
          fill: 'rgba(18, 28, 39, 0.7)',
        },
      },
    },

    '& .background-green': {
      '& svg': {
        position: 'absolute',
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        zIndex: 1,
        borderRadius: 20,
        '& path': {
          fill: '#00c796',
        },
        visibility: 'hidden',
      },
    },

    '&.active': {
      color: 'white !important',

      '& .background-green': {
        '& svg': {
          zIndex: 2,
          visibility: 'visible',
        },
      },

      '& .background-gray': {
        '& svg': {
          zIndex: 1,
        },
      },

      '& .MuiTypography-body1': {
        color: 'white !important',
      },
    },

    '&.myCart': {
      backgroundColor: '#060d14',
      padding: '30px 0',
      paddingLeft: 40,
      height: 'calc(100vh/7)',
      display: 'block',

      '&.active': {
        backgroundColor: '#00c796 !important',

        '& .totalPrice': {
          opacity: 1,
        },
      },

      '& .totalPrice': {
        opacity: 1,
        paddingTop:12,

        '& .price': {
          fontSize: 30,
          marginLeft: 10,
          color:'white',
          fontFamily:'mulilight !important',
        },

        '& svg': {
          width: 40,
        },
      },
    },
  },
  sideBarIndex: {
    fontSize: 14,
    position: 'absolute',
    top: 15,
    left: 15,
    borderBottom: '4px solid',
    color: '#565f68 !important',
    zIndex: 4,
  },
  sideBarText: {
    position: 'absolute',
    top: '50%',
    left: 40,
    transform: 'translateY(-50%)',
    fontSize: 28,
    color: '#565f68 !important',
    fontWeight: 'bold',
    fontFamily: 'muliextrabold !important',
    zIndex: 4,
  },
  sideBarArrow: {
    position: 'absolute',
    right: 10,
    bottom: 20,
    width: 44,
    height: 44,
    background: 'hsla(0,0%,20%,.3)',
    borderRadius: '50%',
    '-webkit-transition':
      'opacity .2s ease-in-out,-webkit-transform .2s ease-in-out',
    transition: 'opacity .2s ease-in-out,-webkit-transform .2s ease-in-out',
    zIndex: 4,

    '& .arrow-line': {
      display: 'block',
      position: 'absolute',
      top: '50%',
      left: '50%',
      width: 9,
      height: 2,
      transform: 'translate3d(-50%,-50%,0)',

      '&::before': {
        display: 'block',
        position: 'absolute',
        top: '50%',
        left: '50%',
        width: '100%',
        height: '100%',
        background: '#fff',
        borderRadius: '25%',
        content: '""',
        transformOrigin: '100% 50%',
        transform: 'translate3d(-50%,-50%,0) rotate(45deg)',
      },

      '&::after': {
        display: 'block',
        position: 'absolute',
        top: '50%',
        left: '50%',
        width: '100%',
        height: '100%',
        background: '#fff',
        borderRadius: '25%',
        content: '""',
        transformOrigin: '100% 50%',
        transform: 'translate3d(-50%,-50%,0) rotate(-45deg)',
      },
    },
  },
})
interface SidebarProps {
  activeMenu: number
  setActiveMenu: (menuItem: number) => void
}

export const Sidebar: React.FC<SidebarProps> = ({
  activeMenu = 1,
  setActiveMenu,
}) => {
  const classes = useStyles()
  const history = useHistory()
  const { cartState } = useCartFacade()
  const { userState } = useUserFacade()
  const { store: userStore } = userState
  const location = useLocation()

  const [animations, setAnimations] = useState<{ green: any; gray: any }[]>([])

  useEffect(() => {
    setAnimations(
      navigations.map((nav, index) => {
        const animationGreen = lottie.loadAnimation({
          container: document.querySelector(
            `[data-id=nav-background-green-${index}]`
          ) as Element,
          animationData: animationJson,
          renderer: 'svg',
          rendererSettings: {
            progressiveLoad: true,
            preserveAspectRatio: 'none',
          },
          loop: false,
          autoplay: false,
        })

        animationGreen.setSpeed(1)

        const animationGray = lottie.loadAnimation({
          container: document.querySelector(
            `[data-id=nav-background-gray-${index}]`
          ) as Element,
          animationData: animationJson,
          renderer: 'svg',
          rendererSettings: {
            progressiveLoad: true,
            preserveAspectRatio: 'none',
          },
          loop: false,
          autoplay: false,
        })

        animationGray.setSpeed(1)

        // (document as any).querySelector(`[data-id=nav-background-green-${index}]`).style.visibility = 'hidden'

        animationGray.play()
        animationGreen.play()

        return { green: animationGreen, gray: animationGray }
      })
    )
  }, [])

  useEffect(() => {
    if (location.pathname === '/cart' && activeMenu >= 0 && animations.length) {
      animations[activeMenu].green.setDirection(-1)
      animations[activeMenu].green.goToAndPlay(0)
      setActiveMenu(6)
    } else if (
      activeMenu >= 0 &&
      animations.length &&
      navigations.findIndex((nav) => nav.link === location.pathname) === -1
    ) {
      animations[activeMenu].green.setDirection(-1)
      animations[activeMenu].green.goToAndPlay(0)
    }
  }, [location.pathname])

  return (
    <>
      <List dense={false}>
        {navigations
          .slice(0, navigations.length - 1)
          .map((nav: Navigation, index: number) => {
            return (
              <ListItem
                id={`nav-${index}`}
                className={
                  activeMenu === index
                    ? clsx(classes.sidebarBtn, 'active')
                    : classes.sidebarBtn
                }
                onClick={() => {
                  if (
                    activeMenu < navigations.length - 1 &&
                    activeMenu >= 0 &&
                    index < navigations.length - 1
                  ) {
                    ;(document as any).querySelector(
                      `[data-id=nav-background-green-${activeMenu}] svg`
                    ).style.visibility = 'visible'
                    // (document as any).querySelector(`[data-id=nav-background-green-${activeMenu}] svg`).style.zIndex = 3;
                    ;(document as any).querySelector(
                      `[data-id=nav-background-green-${index}] svg`
                    ).style.visibility = 'visible'
                    setActiveMenu(index)

                    animations[activeMenu].green.setDirection(-1)
                    animations[activeMenu].green.play()
                    animations[index].green.setDirection(1)
                    animations[index].green.goToAndPlay(0)
                    setTimeout(() => {
                      if(nav.link === "/cart"){
                        document.location.href=nav.link;
                      }else{
                        history.push(nav.link)
                      }
                      
                    }, 500)
                  } else if (activeMenu < 0) {
                    ;(document as any).querySelector(
                      `[data-id=nav-background-green-${index}] svg`
                    ).style.visibility = 'visible'
                    setActiveMenu(index)

                    animations[index].green.setDirection(1)
                    animations[index].green.goToAndPlay(0)
                    setTimeout(() => {
                      if(nav.link === "/cart"){
                        document.location.href=nav.link;
                      }else{
                        history.push(nav.link)
                      }
                    }, 500)
                  } else if (activeMenu === navigations.length - 1) {
                    ;(document as any).querySelector(
                      `[data-id=nav-background-green-${index}] svg`
                    ).style.visibility = 'visible'
                    setActiveMenu(index)

                    animations[index].green.setDirection(1)
                    animations[index].green.goToAndPlay(0)
                    setTimeout(() => {
                      if(nav.link === "/cart"){
                        document.location.href=nav.link;
                      }else{
                        history.push(nav.link)
                      }
                    }, 1000)
                  }
                }}
                key={index}
              >
                <Typography className={classes.sideBarIndex}>{`0${
                  index + 1
                }`}</Typography>
                <Typography className={classes.sideBarText}>
                  {nav.title}
                </Typography>

                {activeMenu !== index && (
                  <Box className={classes.sideBarArrow}>
                    <Box className="arrow-line" />
                  </Box>
                )}
                <Box
                  className="background-green"
                  data-id={`nav-background-green-${index}`}
                />
                <Box
                  className="background-gray"
                  data-id={`nav-background-gray-${index}`}
                />
              </ListItem>
            )
          })}
        <ListItem
          className={
            activeMenu === navigations.length - 1
              ? clsx(classes.sidebarBtn, 'myCart', 'active')
              : clsx(classes.sidebarBtn, 'myCart')
          }
          onClick={() => {
            // if (activeMenu >= 0) {
            //   (document as any).querySelector(
            //     `[data-id=nav-background-green-${activeMenu}] svg`
            //   )?.style?.visibility = 'visible'
            //   animations[activeMenu].green.setDirection(-1)
            //   animations[activeMenu].green.play()
            // }

            setActiveMenu(navigations.length - 1)
            document.location.href=navigations[navigations.length - 1].link;
           
          }}
        >
          <TextWidget
            text={navigations[navigations.length - 1].title}
            size={14}
            style={"muli-bold"}
            mycart={activeMenu === navigations.length - 1}
          ></TextWidget>
          <Box className="totalPrice" display="flex" >
            <SvgCart style={{width:34}} />
            <Typography className="price">
              $
              {cartState[userStore]?.totalPrice
                ? cartState[userStore]?.totalPrice.toFixed(2)
                : 0}
            </Typography>
          </Box>
        </ListItem>
      </List>
    </>
  )
}
