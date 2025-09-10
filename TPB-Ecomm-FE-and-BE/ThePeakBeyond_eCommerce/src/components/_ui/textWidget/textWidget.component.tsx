import React from 'react'
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles'
import { Box, Typography } from '@material-ui/core'

type TextWidgetProps = {
  text: string
  size: number
  indent?: number
  mycart?:boolean,
  style?:string,
  font?:string,
}

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    textWidget: {
      position: 'relative',
      

      '& span': {
        color: 'white',
        letterSpacing: '.1em',
      },
    },
    textWithUnderline: {
      color: 'white',
      borderBottom: '2px solid #00c796',
    },
    bold:{
      borderBottom: '2px solid #000',
    }
  })
)

export const TextWidget: React.FC<TextWidgetProps> = ({ text, size = 0 , indent = 0, mycart = false, font="mulibold", style = ""}) => {
  const classes = useStyles()

  return (
    <Box className={classes.textWidget}>
      {!mycart ? (
        <Typography
        style={{ fontSize: size, borderBottomWidth: size / 5, marginLeft: indent,fontFamily:font }}
        component="span"
        className={`${classes.textWithUnderline} ${style}`}
      >
        {text.substring(0, 2)}
      </Typography>
      ):(
        <span
          style={{ fontSize: 14, borderBottomWidth: size / 5, marginLeft: indent, color:'#000',fontFamily:font }}
          className={`${classes.bold} ${style}`}
        >
          {text.substring(0, 2)}
        </span>
      )}
      
      {!mycart ? (
        <Typography style={{ fontSize: size,fontFamily:font }} component="span" className={`${style}`}>
          {text.substring(2)}
        </Typography>
      ):(
        <span style={{ fontSize: 14,color:'#000',fontFamily:font }}>
          {text.substring(2)}
        </span>
      )}
     
    </Box>
  )
}
