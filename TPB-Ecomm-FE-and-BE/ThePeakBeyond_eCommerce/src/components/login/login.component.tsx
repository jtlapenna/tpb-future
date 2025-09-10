import {
  Card,
  CardContent,
  Link,
  Grid,
  TextField,
  Button,
} from '@material-ui/core'
import { useState } from 'react'
import { useHistory, useLocation } from 'react-router-dom'
import { Auth } from 'aws-amplify'

import { useUserFacade } from 'state/user'

import { Register } from './register.component'
import { handleFormValue } from '../../utils/form.utility'
import Alert from '@material-ui/lab/Alert'
import { setBearerToken } from 'utils/local-storage.utility'
import FacebookIcon from '@material-ui/icons/Facebook'
import Google from '../../assets/icons/google.svg'

export const Login = () => {
  let history = useHistory()
  const location = useLocation()
  const { updateUserState } = useUserFacade()

  const [form, setForm] = useState({
    username: '',
    password: '',
  })
  const [showRegister, setShowRegister] = useState(false)

  const [submitted, setSubmitted] = useState(false)
  const [error, setError] = useState('')

  const login = async () => {
    setSubmitted(true)
    if (!form.username || !form.password) {
      return
    }

    setError('')

    const result = await Auth.signIn(form.username, form.password).catch(
      (e) => {
        setError(e.message)
        return null
      }
    )

    if (result) {
      const token = result.signInUserSession.accessToken.jwtToken
      setBearerToken(token)

      const {
        'custom:birthday': birthday,
        'custom:company': company,
        'custom:purpose': purpose,
        'custom:store': store,
        ...attributes
      } = result?.attributes

      updateUserState({
        id: result?.id,
        username: result?.username,
        birthday,
        company,
        purpose,
        store,
        ...attributes,
      })

      history.push('/')
      // window.location.reload()
    }
  }

  const fb = () => {
    document.location.href = `https://${process.env.REACT_APP_AWS_DOMAIN}/login?response_type=code&client_id=${process.env.REACT_APP_AWS_CLINET_ID}&redirect_uri=${window.location.protocol}//${window.location.host}/social_login`
  }

  return (
    <Card className="login-card">
      {!showRegister ? (
        <CardContent>
          {error && (
            <Alert className="mb-8" severity="error">
              {error}
            </Alert>
          )}

          <Grid container spacing={3}>
            <Grid item xs={12} className="left ml-32 mt-16 mr-32">
              <TextField
                error={submitted && !form.username}
                onChange={(e) => handleFormValue(e, 'username', form, setForm)}
                label="Email or phone number"
              />
            </Grid>
            <Grid item xs={12} className="left ml-32  mr-32">
              <TextField
                type="password"
                error={submitted && !form.password}
                onChange={(e) => handleFormValue(e, 'password', form, setForm)}
                label="Password"
              />
            </Grid>
            <Grid item xs={12} className="left ml-32  mr-32">
              <Link
                onClick={() => history.push('/resetpassword')}
                color="textSecondary"
              >
                Forgot password?
              </Link>
            </Grid>
            <Grid item xs={12} className="ml-32  mr-32">
              <Button onClick={login} variant="contained" color="secondary">
                Sign In
              </Button>
            </Grid>

            <Grid item xs={12}>
              <Button onClick={fb}>
                <FacebookIcon /> <img alt="" width="30" src={Google} /> Social
                Login
              </Button>
            </Grid>

            <Grid item xs={12}>
              <Link
                onClick={() => setShowRegister(true)}
                color="textSecondary"
                className="f-25"
              >
                Create Account
              </Link>
            </Grid>
          </Grid>
        </CardContent>
      ) : (
        <Register showLogin={() => setShowRegister(false)} />
      )}
    </Card>
  )
}
