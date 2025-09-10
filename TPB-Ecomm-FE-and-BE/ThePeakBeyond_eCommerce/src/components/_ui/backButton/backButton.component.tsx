import React from 'react'
import { useHistory } from 'react-router'
import { withRouter } from 'react-router-dom'
import { makeStyles, Button } from '@material-ui/core'

const useStyles = makeStyles((theme) => ({
  backButton: {
    padding: '14px 24px',
    fontSize: 14,
    color: 'white',
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    borderRadius: 20,
    lineHeight: 1,
    letterSpacing:'.15em',
    fontFamily:'mulisemibold',
  },
  backArrow: {
    position: 'relative',
    display: 'inline-block',
    margin: '0 3px 0 0',
    width: '8px',
    height: '10px',
    verticalAlign: 'top',
    zIndex: 2,

    '&::before': {
      display: 'block',
      position: 'absolute',
      top: '50%',
      left: '50%',
      width: '6px',
      height: '1px',
      background: '#ffffff',
      borderRadius: '25%',
      content: '""',
      transformOrigin: '0 50%',
      transform: 'translate3d(-50%, -50%, 0) rotateZ(-45deg)',
    },

    '&::after': {
      display: 'block',
      position: 'absolute',
      top: '50%',
      left: '50%',
      width: '6px',
      height: '1px',
      background: '#ffffff',
      borderRadius: '25%',
      content: '""',
      transformOrigin: '0 50%',
      transform: 'translate3d(-50%, -50%, 0) rotateZ(45deg)',
    },
  },
}))

export const BackButton = ({onClick = null as any}) => {
  const classes = useStyles()
  const history = useHistory()

  return (
    <Button className={classes.backButton} onClick={() => onClick ? onClick():history.goBack()}>
      <span className={classes.backArrow}></span>Back
    </Button>
  )
}
