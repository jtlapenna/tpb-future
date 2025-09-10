import React, { useState } from 'react'
import { Auth } from 'aws-amplify'
import { useHistory } from 'react-router-dom'
import { makeStyles } from '@material-ui/core/styles'
import {
  Box,
  ClickAwayListener,
  List,
  ListItem,
  ListItemText,
} from '@material-ui/core'
import { ListItemProps } from '@material-ui/core/ListItem'

import { useUserFacade, initialState } from 'state/user'
import { IsUserLoggedIn } from 'services/authentication.service'
import { setBearerToken, setUserInfo } from 'utils/local-storage.utility'

import { Register } from 'components'
import { Login } from 'components/login/login.component'
import userIcon from 'assets/images/user.png'

const useStyles = makeStyles({
  userPicker: {
    position: 'relative',
    '& img': {
      width: 50,
      cursor: 'pointer',
    },

    '& .login-card-container': {
      position: 'absolute',
      top: 40,
      left: -320,
      zIndex: -1,
      opacity: 0,
      transition: 'all 0.3s ease',

      '& .login-card': {
        marginTop: 0,
      },

      '&.active': {
        zIndex: 100,
        opacity: 1,
      },
    },

    '& .user-menu': {
      position: 'absolute',
      top: 50,
      left: -180,
      zIndex: -1,
      opacity: 0,
      transition: 'all 0.3s ease',
      backgroundColor: 'white',
      width: '200px',
      borderRadius: '20px',
      padding: '0px 15px',

      '&.account-settings': {
        left: -300,
        width: '300px',

        '& .close': {
          position: 'absolute',
          top: '25px',
          right: '25px',
          fontWeight: 'bold',
          fontSize: '25px',
          cursor: 'pointer',

          '&::after': {
            display: 'inline-block',
            content: '"X"',
          },
        },

        '& .MuiPaper-elevation1': {
          boxShadow: 'none',

          '& .MuiFormControl-root': {
            width: '100%',
          },
        },
      },

      '&.active': {
        zIndex: 100,
        opacity: 1,
      },

      '& a': {
        color: '#00c796',
      },
    },
  },
})

function ListItemLink(props: ListItemProps<'a', { button?: true }>) {
  return <ListItem button component="a" {...props} />
}

export const UserPicker = () => {
  const history = useHistory()
  const classes = useStyles()
  const loggedIn = IsUserLoggedIn()
  const { updateUserState } = useUserFacade()

  const [active, setActive] = useState(false)
  const [accountSettings, setAccountSettings] = useState(false)

  const logOut = async () => {
    await Auth.signOut()
    setBearerToken('')
    updateUserState({ ...initialState })
    history.push('/')
    window.location.reload()
  }

  const resetPwd = ()=>{
    history.push('/resetpassword')
  }

  return (
    <ClickAwayListener
      onClickAway={() => {
        if (active) {
          setActive(false)
          setAccountSettings(false)
        }
      }}
    >
      <Box className={classes.userPicker}>
        <img
          src={userIcon}
          alt="User"
          onClick={() => {
            setActive(!active)
            setAccountSettings(false)
          }}
        />

        {active &&
          (!loggedIn ? (
            <div className={`login-card-container ${active ? 'active' : ''}`}>
              <Login />
            </div>
          ) : (
            // <Register editProfile={true} />
            <div
              className={`user-menu ${active ? 'active ' : ''}${
                accountSettings ? 'account-settings' : ''
              }`}
            >
              {accountSettings ? (
                <>
                  <Register editProfile={true} />
                  <Box
                    className="close"
                    onClick={() => setAccountSettings(false)}
                  />
                </>
              ) : (
                <List>
                  <ListItemLink onClick={() => setAccountSettings(true)}>
                    <ListItemText primary="Account Settings" color="#00c796" />
                  </ListItemLink>
                  {/* <ListItemLink onClick={() => history.push('/order-status')}>
                  <ListItemText primary="Order Status" color="#00c796" />
                </ListItemLink>
                <ListItemLink onClick={() => history.push('/purchase-history')}>
                  <ListItemText primary="Purchase History" color="#00c796" />
                </ListItemLink> */}
                 <ListItemLink onClick={resetPwd}>
                    <ListItemText primary="Reset Password" color="#00c796" />
                  </ListItemLink>
                  <ListItemLink onClick={logOut}>
                    <ListItemText primary="Log Out" color="#00c796" />
                  </ListItemLink>
                </List>
              )}
            </div>
          ))}
      </Box>
    </ClickAwayListener>
  )
}
