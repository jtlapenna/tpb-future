import { useUserFacade } from 'state/user'

export const useAuth = () => {
  const { userState } = useUserFacade()

  const isLoggedIn = !!userState.email

  return { isLoggedIn }
}
