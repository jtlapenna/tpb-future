import React, {
  useMemo,
  useState,
  useRef,
  MutableRefObject,
  useCallback,
} from 'react'
import { makeStyles } from '@material-ui/core/styles'
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

import { useUserFacade } from 'state/user'

const useStyles = makeStyles({
  cart: {
    marginTop: '100px',
    padding: 50,
  },
  cartHeading: {
    fontSize: 80,
    color: 'white',
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
  formGroup: {
    marginBottom: '30px',
    width: '400px',
    display: 'flex',
    flexDirection: 'row',
    flexWrap: 'nowrap',
  },
  formControl: {
    width: '100%',
    '& .MuiSvgIcon-root': {
      color: 'white',
    },
    '& .MuiFormLabel-root': {
      color: 'rgba(255, 255, 255, 0.3)',
      fontSize: '20px',
      transform: 'translate(0, 1.5px) scale(1)',
    },
    '& .MuiFormLabel-root.Mui-focused': {
      color: 'white',
      fontSize: '20px',
    },
    '& .MuiInputBase-input': {
      color: 'white',
      width: '300px',
      padding: '15px 5px',
    },

    '& .MuiButton-root': {
      width: '200px',
    },
  },
  formZipControl: {
    width: '100px',
    marginLeft: '15px',
    flexShrink: 0,

    '& .MuiSvgIcon-root': {
      color: 'white',
    },
    '& .MuiFormLabel-root': {
      color: 'rgba(255, 255, 255, 0.3)',
      fontSize: '20px',
      transform: 'translate(0, 1.5px) scale(1)',
    },
    '& .MuiFormLabel-root.Mui-focused': {
      color: 'white',
      fontSize: '20px',
    },
    '& .MuiInputBase-input': {
      color: 'white',
      padding: '15px 5px',
    },
  },
  error: {
    fontSize: '14px',
    color: 'red',
    fontWeight: 'bold',
    marginTop: '10px',
  },
})

type IAddressFormProps = {
  handleCreateOrder: () => void
}

export const AddressForm: React.FC<IAddressFormProps> = ({
  handleCreateOrder,
}) => {
  const classes = useStyles()
  const { userState, updateUserState } = useUserFacade()

  const [street, setStreet] = useState('')
  const [streetError, setStreetError] = useState('')
  const [city, setCity] = useState('')
  const [cityError, setCityError] = useState('')
  const [state, setState] = useState('')
  const [stateError, setStateError] = useState('')
  const [country, setCountry] = useState('')
  const [countryError, setCountryError] = useState('')
  const [zip, setZip] = useState('')
  const [zipError, setZipError] = useState('')

  return (
    <Box className={classes.cart}>
      <Typography component="h1" className={classes.cartHeading}>
        Your Address
      </Typography>
      <Box>
        <FormGroup className={classes.formGroup}>
          <FormControl className={classes.formControl}>
            <InputLabel htmlFor="dl-number">Street</InputLabel>
            <Input
              id="dl-number"
              aria-describedby="driver-license-number"
              value={street}
              onChange={(v) => setStreet(v.target.value)}
            />
          </FormControl>
          {streetError && (
            <Typography component="p" className={classes.error}>
              {streetError}
            </Typography>
          )}
        </FormGroup>
        <FormGroup className={classes.formGroup}>
          <FormControl className={classes.formControl}>
            <InputLabel htmlFor="dl-number">City</InputLabel>
            <Input
              id="dl-number"
              aria-describedby="driver-license-number"
              value={city}
              onChange={(v) => setCity(v.target.value)}
            />
          </FormControl>
          {cityError && (
            <Typography component="p" className={classes.error}>
              {cityError}
            </Typography>
          )}
        </FormGroup>
        <FormGroup className={classes.formGroup}>
          <FormControl className={classes.formControl}>
            <InputLabel htmlFor="dl-number">State</InputLabel>
            <Input
              id="dl-number"
              aria-describedby="driver-license-number"
              value={state}
              onChange={(v) => setState(v.target.value)}
            />
            {stateError && (
              <Typography component="p" className={classes.error}>
                {stateError}
              </Typography>
            )}
          </FormControl>
          <FormControl className={classes.formZipControl}>
            <InputLabel htmlFor="dl-number">Zip Code</InputLabel>
            <Input
              id="dl-number"
              aria-describedby="driver-license-number"
              value={zip}
              onChange={(v) => setZip(v.target.value)}
            />
            {zipError && (
              <Typography component="p" className={classes.error}>
                {zipError}
              </Typography>
            )}
          </FormControl>
        </FormGroup>
        <FormGroup className={classes.formGroup}>
          <FormControl className={classes.formControl}>
            <InputLabel htmlFor="dl-number">Country</InputLabel>
            <Input
              id="dl-number"
              aria-describedby="driver-license-number"
              value={country}
              onChange={(v) => setCountry(v.target.value)}
            />
          </FormControl>
          {countryError && (
            <Typography component="p" className={classes.error}>
              {countryError}
            </Typography>
          )}
        </FormGroup>
      </Box>
      <Box display="flex" justifyContent="space-evenly" mt="30px">
        <FormControl className={classes.formControl}>
          <Button
            variant="contained"
            className={classes.primaryButton}
            onClick={() => {
              updateUserState({
                ...userState,
                address: {
                  street,
                  city,
                  state,
                  zip,
                  country,
                },
              })
              handleCreateOrder()
            }}
          >
            OK
          </Button>
        </FormControl>
      </Box>
    </Box>
  )
}
