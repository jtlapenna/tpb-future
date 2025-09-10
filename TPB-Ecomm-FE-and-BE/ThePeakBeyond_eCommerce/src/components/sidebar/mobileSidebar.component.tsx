import React, {useEffect, useState} from 'react'
import { useHistory } from 'react-router-dom'
import { makeStyles } from '@material-ui/core/styles'
import { Grid, Typography, Button } from '@material-ui/core'
import clsx from 'clsx'
import { navigations } from 'config'
import { Navigation } from 'types'
import hd from "../../assets/images/hd.png";
import { useUserFacade } from 'state/user'
import { getStoreImages } from 'utils/local-storage.utility'

const useStyles = makeStyles((theme) => ({
  mobileSidebar: { 
    position:'sticky',
    top:0,
    zIndex:32,
    backgroundColor:'#05111D',

    '& .MuiGrid-item': {
      padding: '4px',
      margin: '0px',
    },

    '& .mobileHeaderImage': {
      height: '140px',
      width: '100%',
      objectFit: 'cover',
      padding: "0px",
      margin: "0px",
    },
  },
  mobileHeaderImageContainer: {  
      padding: "0px !important",
      margin: "0px !important",
  },
  
  sidebarBtn: {
    position: 'relative',
    borderRadius: 20,
    color: 'white !important',
    backgroundColor: '#2a3b4e',
    cursor: 'pointer',
    transition: 'all 0.3s ease',
    width: '100%',
    height: 65,
    wordBreak: 'break-word',

    '& .MuiTypography-body1': {
      opacity: 0.7,
      },

    '&.active': {
  
      backgroundColor: 'var(--primary)',

      '& .MuiTypography-body1': {
      opacity: 1,
      },
    },
  },
  sideBtnText: {
    fontSize: 20,
    color: '#white !important',
    fontFamily: 'muliextrabold !important',
    textTransform: 'capitalize',
    [theme.breakpoints.down('md')]: {
      fontSize: 16,     
    },
    [theme.breakpoints.down('sm')]: {},
    [theme.breakpoints.down('xs')]: {
      lineHeight: 1.25,
      fontSize: 14,
    },
  },
  myCart: {
    width: 50,
    height: 50,
    borderRadius: '50%',
    backgroundColor: 'var(--primary)',
    position: 'absolute',
    top: 15,
    right: 15,
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',

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
}))

interface MobileSidebarProps {
  activeMenu: number
}

export const MobileSidebar: React.FC<MobileSidebarProps> = ({
  activeMenu = 1,
}) => {
  const classes = useStyles()
  const history = useHistory()
  const [img, setImg] = useState<any>(hd);

  const { userState } = useUserFacade()
  const { store} = userState

  useEffect(()=>{
    if(store) {
      const images = getStoreImages(store);
      const header = images.find(c=>c.codename === "HEADER_IMAGE");
      if(header && header.url){
        setImg(header.url);
      }else{
        setImg(hd);
      }
    }
  },[store]);

  return (    
    <Grid container className={classes.mobileSidebar} >
      <Grid item sm={12} xs={12} className={classes.mobileHeaderImageContainer}>
        <img
          className="mobileHeaderImage"
          src={img}
        />
      </Grid>
      <Grid item sm={6} xs={6} >
        <Button 
          className={
            activeMenu === 0
              ? clsx(classes.sidebarBtn, 'active')
              : classes.sidebarBtn
          }
          onClick={() => {
            history.push(navigations[0].link)
          }}
        >
          <Typography component="p" className={classes.sideBtnText}>
            My Dashboard
          </Typography>
        </Button>
      </Grid>
      <Grid item sm={6} xs={6}>
        <Button
          className={
            activeMenu === 1
              ? clsx(classes.sidebarBtn, 'active')
              : classes.sidebarBtn
          }
          onClick={() => {
            history.push(navigations[1].link)
          }}
        >
          <Typography component="p" className={classes.sideBtnText}>
            Favorites
          </Typography>
        </Button>
      </Grid>
      {navigations
        .slice(2, navigations.length - 1)
        .map((nav: Navigation, index: number) => {
          return (
            <Grid item sm={3} xs={3} key={index}>
              <Button
                className={
                  activeMenu === index + 2
                    ? clsx(classes.sidebarBtn, 'active')
                    : classes.sidebarBtn
                }
                onClick={() => {
                  history.push(navigations[index + 2].link)
                }}
              >
                <Typography component="p" className={classes.sideBtnText}>
                  {nav.title}
                </Typography>
              </Button>
            </Grid>
            
          )
        })}
      {/* <Box onClick={() => history.push('/cart')} className={classes.myCart}>
        <SvgCart />
        <Typography component="span" className="item-count">
          3
        </Typography>
      </Box> */}
    </Grid>
  )
}
