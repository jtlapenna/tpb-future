import { useEffect } from 'react'
import { Auth } from 'aws-amplify'
import { useHistory } from 'react-router-dom'
import { setBearerToken } from 'utils/local-storage.utility'
import { useUserFacade } from 'state/user'
import { companies } from 'config'

export const SocialLogin = () => {
  let history = useHistory()
  const { updateUserState } = useUserFacade()

  const { host } = window.location
  const companyName = host.split('.')[0]

  useEffect(() => {
    ;(async () => {
      const user = await Auth.currentUserInfo()
      if (user && user.username) {
        const result = await Auth.currentSession()
        const token = result.getAccessToken().getJwtToken()
        setBearerToken(token)

        const { attributes } = user

        updateUserState({
          id: attributes.sub,
          username: user.username,
          birthday: attributes.birthdate,
          company: companies[companyName] ?? 0,
          purpose: '',
          store: '',
          ...attributes,
        })

        history.push('/')
      }
    })()
  }, [history, updateUserState])
  return <></>
}
