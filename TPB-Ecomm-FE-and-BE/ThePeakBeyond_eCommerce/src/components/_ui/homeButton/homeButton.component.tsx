import React from 'react'
import { useHistory } from 'react-router'
import { makeStyles, Button } from '@material-ui/core'

import SvgHome from 'assets/icons/icon-home.svg'

const useStyles = makeStyles((theme) => ({
  homeButton: {
    width: 70,
    height: 70,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: '50%',

    '& img': {
      width: 20,
    },
  },
}))

export const HomeButton = () => {
  const classes = useStyles()
  const history = useHistory()

  return (
    <Button className={classes.homeButton} onClick={() => history.push('/')}>
      <img src={SvgHome} alt="Home" />
    </Button>
  )
}
