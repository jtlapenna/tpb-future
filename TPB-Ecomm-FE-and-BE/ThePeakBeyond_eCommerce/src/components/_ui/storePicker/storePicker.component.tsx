import React, { useState, useEffect, useCallback, SyntheticEvent } from 'react'
import { createStyles, makeStyles, Theme } from '@material-ui/core/styles'
import {
  MenuItem,
  FormControl,
  Select,
  Box,
  Typography,
} from '@material-ui/core'
import { Auth } from 'aws-amplify'

import { useAuth } from 'hooks'
import { IStore } from 'types'

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    storePicker: {
      fontSize: 20,
      color: 'white',
    },
    formControl: {
      margin: theme.spacing(1),
      minWidth: 120,
      marginLeft: 15,

      '& .MuiSelect-selectMenu': {
        fontSize: '20px !important',
        color: '#08c696 !important',
        paddingRight: 40,
        minHeight: 'auto',
      },

      '& .MuiSelect-icon': {
        top: 0,
        fill: '#08c696',
      },
    },
  })
)

interface StorePickerProps {
  stores: IStore[]
  activeStore: string
  setActiveStore: (storeId: string) => void
}

export const StorePicker: React.FC<StorePickerProps> = ({
  stores,
  activeStore,
  setActiveStore,
}) => {
  const classes = useStyles()

  return (
    <Box
      className={classes.storePicker}
      display="flex"
      alignItems="center"
      justifyContent="flex-end"
    >
      <Typography component="span">Store:</Typography>
      <FormControl className={classes.formControl}>
        <Select
          id="store-select"
          className="remove-bb"
          value={
            stores &&
            stores.length &&
            stores.filter((store) => store.id === activeStore).length > 0
              ? activeStore
              : ''
          }
          onChange={(e) => setActiveStore(e.target.value as string)}
        >
          {stores &&
            stores.length &&
            stores.map((store: IStore) => (
              <MenuItem value={store.id} key={store.id}>
                {store.name}
              </MenuItem>
            ))}
        </Select>
      </FormControl>
    </Box>
  )
}
