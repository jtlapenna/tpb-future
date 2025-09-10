import React from 'react'
import Amplify, { Auth } from 'aws-amplify'
import ReactDOM from 'react-dom'
import reportWebVitals from './reportWebVitals'
import { Provider } from 'react-redux'
import { Router } from 'react-router-dom'
import { createBrowserHistory } from 'history'

import { store } from 'state/store'

import App from './components/app/App'
import { Spinner } from './ui-components/spinner.component'
import './styles/_colors.scss'
import './styles/index.scss'

const hist = createBrowserHistory()

Amplify.configure({
  Auth: {
    region: process.env.REACT_APP_AWS_REGION,
    userPoolId: process.env.REACT_APP_AWS_USER_POOL,
    userPoolWebClientId: process.env.REACT_APP_AWS_CLINET_ID,
    mandatorySignIn: true,
    authenticationFlowType: 'USER_PASSWORD_AUTH',
    oauth:{
      domain:process.env.REACT_APP_AWS_DOMAIN,
      scope: ['phone', 'email', 'profile', 'openid', 'aws.cognito.signin.user.admin'],
      redirectSignIn: `${window.location.protocol}//${window.location.host}/social_login`,
      redirectSignOut:  `${window.location.protocol}//${window.location.host}/social_login`,
      responseType: 'code'
    }
  },
})

Auth.configure({
  Auth: {
    region: process.env.REACT_APP_AWS_REGION,
    userPoolId: process.env.REACT_APP_AWS_USER_POOL,
    userPoolWebClientId: process.env.REACT_APP_AWS_CLINET_ID,
    mandatorySignIn: true,
    authenticationFlowType: 'USER_PASSWORD_AUTH',
    oauth:{
      domain:process.env.REACT_APP_AWS_DOMAIN,
      scope: ['phone', 'email', 'profile', 'openid', 'aws.cognito.signin.user.admin'],
      redirectSignIn: `${window.location.protocol}//${window.location.host}/social_login`,
      redirectSignOut:  `${window.location.protocol}//${window.location.host}/social_login`,
      responseType: 'code'
    }
  },
})

ReactDOM.render(
  <React.StrictMode>
    <Provider store={store}>
      <Router history={hist}>
        <App />
      </Router>
      <Spinner />
    </Provider>
  </React.StrictMode>,
  document.getElementById('root')
)

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals()
