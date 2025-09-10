import { useCallback } from 'react'
import { useAppDispatch, useAppSelector } from 'state'
import * as UserSlice from './user.slice'
import * as UserThunks from './user.thunks'

export const useUserFacade = () => {
  const dispatch = useAppDispatch()

  const userState = useAppSelector((state) => state.userState)

  const updateUserState = useCallback(
    (payload) => dispatch(UserSlice.actions.updateUserState(payload)),
    [dispatch]
  )
  return {
    userState,
    updateUserState,
  }
}
