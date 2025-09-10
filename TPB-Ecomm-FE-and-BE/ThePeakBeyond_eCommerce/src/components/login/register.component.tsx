import React, { useState, useEffect } from 'react'
import {
  Card,
  CardContent,
  Link,
  Grid,
  TextField,
  Button,
  RadioGroup,
  FormControlLabel,
  Radio,
} from '@material-ui/core'
import { useHistory, useParams } from 'react-router-dom'
import { Auth } from 'aws-amplify'
import Alert from '@material-ui/lab/Alert'

import { useUserFacade, initialState } from 'state/user'
import { companies } from 'config'
import { handleFormValue } from 'utils/form.utility'
import { setBearerToken, setUserInfo } from 'utils/local-storage.utility'

interface IRegister {
  editProfile?: boolean
  showLogin?: () => void
}

export const Register: React.FC<IRegister> = ({
  editProfile = false,
  showLogin,
}) => {
  let history = useHistory()
  const { updateUserState } = useUserFacade()

  const [submitted, setSubmitted] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const [form, setForm] = useState({
    email: '',
    firstName: '',
    lastName: '',
    birthday: '',
    phone: '+1',
    usage: 'ADULT',
    password: '',
    companyId: '',
  })

  const register = async () => {
    setSubmitted(true)

    if (
      !form.email ||
      !form.firstName ||
      !form.lastName ||
      !form.birthday ||
      !form.phone ||
      !form.password
    ) {
      return
    }
    setSuccess('')
    setError('')

    if (editProfile) {
      const currentUser = await Auth.currentAuthenticatedUser()

      await Auth.updateUserAttributes(currentUser, {
        phone_number: form.phone,
        email: form.email,
        given_name: form.firstName,
        family_name: form.lastName,
        birthdate: form.birthday,
        'custom:purpose': form.usage,
        'custom:birthday': form.birthday,
        'custom:company': form.companyId,
      })
      const newUser = await Auth.currentAuthenticatedUser()
      const {
        'custom:birthday': birthday,
        'custom:company': company,
        'custom:purpose': purpose,
        'custom:store': store,
        ...attributes
      } = newUser?.attributes

      updateUserState({
        id: newUser?.id,
        username: newUser?.username,
        birthday,
        company,
        purpose,
        store,
        ...attributes,
      })
      // window.location.reload()
    } else {
      const { host } = window.location
      const companyName = host.split('.')[0]

      const result = await Auth.signUp({
        username: form.email,
        password: form.password, // May have a chance to not comply with the Cognito password rules
        attributes: {
          phone_number: formatPhonenumber(),
          email: form.email,
          given_name: form.firstName,
          family_name: form.lastName,
          'custom:company': companies[companyName] ?? '23',
          'custom:store': '',
          'custom:purpose': form.usage,
          'custom:birthday': form.birthday,
        },
      }).catch((e) => {
        setError(e.message)
        return null
      })

      if (result) {
        setSuccess('Your account has been created')
      }
    }
  }

  const formatPhonenumber = () =>{
    if(form.phone) {
        let phone = form.phone;

        if(phone.indexOf("-") !==-1){
          phone = phone.replace(/-/g,"");
        }

        if(phone.indexOf("(") !==-1){
          phone = phone.replace(/\(/g,"");
        }

        if(phone.indexOf(")") !==-1){
          phone = phone.replace(/\)/g,"");
        }

        if(phone.indexOf(" ") !==-1){
          phone = phone.replace(/ /g,"");
        }

        if(phone.indexOf("+1")===-1){
          return `+1`+phone;
        }

        return phone;
    }

    return "";
  }
  const logOut = async () => {
    await Auth.signOut()
    setBearerToken('')
    updateUserState({ ...initialState })
    history.push('/')
    window.location.reload()
  }

  useEffect(() => {
    ;(async () => {
      if (editProfile) {
        const currentUser = await Auth.currentUserInfo().catch(() => null)

        if (currentUser) {
          setForm({
            email: currentUser.attributes.email,
            firstName: currentUser.attributes.given_name,
            lastName: currentUser.attributes.family_name,
            birthday:
              currentUser.attributes.birthdate ||
              currentUser.attributes['custom:birthday'] ||
              '',
            phone: currentUser.attributes.phone_number || '',
            usage: currentUser.attributes['custom:purpose'] || 'ADULT',
            password: '111',
            companyId: currentUser.attributes['custom:company'] || '',
          })
        }
      }
    })()
  }, [editProfile])

  return (
    <Card className={`h-${!editProfile ? '550' : '400'}`}>
      <CardContent>
        <Grid container spacing={1}>
          {error && (
            <Grid item xs={12}>
              <Alert severity="error">{error}</Alert>
            </Grid>
          )}

          {success && (
            <Grid item xs={12}>
              <Alert severity="success">{success}</Alert>
            </Grid>
          )}
          <Grid item xs={12} className="left ml-32 mt-16 mr-32">
            <TextField
              value={form.firstName}
              error={submitted && !form.firstName}
              onChange={(e) => handleFormValue(e, 'firstName', form, setForm)}
              label="First Name"
            />
          </Grid>
          <Grid item xs={12} className="left ml-32 mr-32">
            <TextField
              value={form.lastName}
              error={submitted && !form.lastName}
              onChange={(e) => handleFormValue(e, 'lastName', form, setForm)}
              label="Last Name"
            />
          </Grid>

          {!editProfile && (
            <>
              <Grid item xs={12} className="left ml-32 mr-32">
                <TextField
                  value={form.email}
                  error={submitted && !form.email}
                  onChange={(e) => handleFormValue(e, 'email', form, setForm)}
                  label="Email Address"
                />
              </Grid>

              <Grid item xs={12} className="left ml-32 mr-32">
                <TextField
                  type="password"
                  error={submitted && !form.password}
                  onChange={(e) =>
                    handleFormValue(e, 'password', form, setForm)
                  }
                  label="Password"
                />
              </Grid>
            </>
          )}

          <Grid item xs={12} className="left ml-32  mr-32">
            <TextField
              value={form.phone}
              placeholder={'+1'}
              error={submitted && !form.phone}
              onChange={(e) => handleFormValue(e, 'phone', form, setForm)}
              label="Phone Number"
            />
          </Grid>
          <Grid item xs={12} className="left ml-32  mr-32">
            <TextField
              value={form.birthday}
              placeholder={'MM-DD-YYYY'}
              error={submitted && !form.birthday}
              onChange={(e) => handleFormValue(e, 'birthday', form, setForm)}
              label="Birthday"
            />
          </Grid>
          
          <Grid item xs={12} className="left ml-32  mr-32">
            <RadioGroup
              value={form.usage}
              onChange={(e) => handleFormValue(e, 'usage', form, setForm)}
            >
              <FormControlLabel
                value="ADULT"
                control={<Radio />}
                label="Adult Use"
              />
              <FormControlLabel
                value="MEDICAL"
                control={<Radio />}
                label="Medical Use"
              />
            </RadioGroup>
          </Grid>
          <Grid item xs={12} className="ml-32  mr-32">
            <Button onClick={register} variant="contained" color="secondary">
              {editProfile ? 'Update' : 'Create Account'}
            </Button>
          </Grid>
          {editProfile && (
            <Grid item xs={12} className="ml-32  mr-32">
              <Button onClick={logOut} variant="contained" color="secondary">
                Log out
              </Button>
            </Grid>
          )}

          {!editProfile && (
            <Grid item xs={12}>
              <Link
                onClick={() => {
                  if (showLogin) showLogin()
                }}
                color="textSecondary"
                className="f-25"
              >
                Sign In
              </Link>
            </Grid>
          )}
        </Grid>
      </CardContent>
    </Card>
  )
}
