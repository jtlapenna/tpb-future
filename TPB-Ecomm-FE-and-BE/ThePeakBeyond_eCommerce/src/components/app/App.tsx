import React, { useEffect, useState } from 'react'
import { Route, Switch, useHistory } from 'react-router-dom'
import { Auth } from 'aws-amplify'
import { ToastContainer, toast } from 'react-toastify'
import 'react-toastify/dist/ReactToastify.css'

import { useUserFacade } from 'state/user'
import { setBearerToken } from 'utils/local-storage.utility'
import { httpGet } from 'services/http-client.service'
import { useAuth } from 'hooks'
import { companies } from 'config'
import { IStore, IStoreImages } from 'types'

import { Login, Register, ResetPassword, Layout, Favorites } from 'components'
import { SocialLogin } from 'components/login/social-login.component'
import { reduce } from 'lodash'

function App() {
  const hisotry = useHistory()
  const { userState, updateUserState } = useUserFacade()
  const { store: userStore, company } = userState
  const { isLoggedIn } = useAuth()

  const [stores, setStores] = useState<IStore[]>([])

  useEffect(() => {
    if (!isLoggedIn) {
      Auth.currentUserInfo()
        .then((result) => {
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
        })
        .catch((error) => {
          const { host } = window.location
          const companyName = host.split('.')[0]
          if (companies[companyName]) {
            updateUserState({ company: companies[companyName] })
          } else{
            updateUserState({ company: '23' })
          }
        })
    }
  }, [isLoggedIn, updateUserState ])

  useEffect(() => {
    (async()=>{
      if (company) {
        const result: IStore[] = await httpGet(`/store/all/${company}/id/1/0/`);
        

        const images: IStoreImages[] = await httpGet(`/store/images/company/${company}`);

        const fullStore = reduce((result || []), (results:IStore[],item:IStore)=>{

              return results.concat({
                ...item,
                images:images.filter(i=>i.store_id === item.id),
              });
          
        },[]);

        setStores(fullStore);
        localStorage.setItem('USER_STORES',JSON.stringify(fullStore));
      }
    })();
    
  }, [company])

  useEffect(() => {
    if (stores && stores.length && !userStore) {
      updateUserState({ store: stores[0].id })
    } else if (stores && stores.length && userStore) {
      if (stores.filter((store) => store.id === userStore).length === 0) {
        updateUserState({ store: stores[0].id })
      }
    }
  }, [stores, userStore, updateUserState])

  useEffect(() => {
    ;(async () => {
      const session = await Auth.currentSession().catch(() => null)
      if (session) {
        setBearerToken(session.getAccessToken().getJwtToken())
      } else {
        // hisotry.push('/')
      }
    })()
  }, [hisotry])

  return (
    <div className="App">
      <Switch>
        <Route path="/login" render={() => <Login />} exact />
        <Route path="/social_login" render={() => <SocialLogin />} exact />
        <Route path="/resetpassword/:login?" render={() => <ResetPassword />} exact />
        <Route exact path="/register" render={() => <Register />} />
        <Route exact path="/register/:companyId" render={() => <Register />} />
        <Route path="/" render={() => <Layout />} />
      </Switch>
      <ToastContainer hideProgressBar={true} />
    </div>
  )
}

export default App
