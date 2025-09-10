import { IUserState } from './user.slice'

// Reducers
export const reducers = {
  updateUserState(state: IUserState, action: any) {
    return { ...state, ...action.payload }
  },
}

export const extraReducers = {}
