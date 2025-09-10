import { configureStore, getDefaultMiddleware } from '@reduxjs/toolkit'

import userReducer from './user/user.slice'
import favoritesReducer from './favorites/favorites.slice'
import cartReducer from './cart/cart.slice'

export const store = configureStore({
  reducer: {
    userState: userReducer,
    favoritesState: favoritesReducer,
    cartState: cartReducer,
  },
  middleware: getDefaultMiddleware({
    serializableCheck: {
      ignoredActions: [],
      ignoredPaths: [],
    },
  }),
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch
