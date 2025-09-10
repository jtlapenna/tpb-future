import { createSlice, Reducer, AnyAction } from '@reduxjs/toolkit'

import { reducers, extraReducers } from './favorites.reducers'
import * as Thunks from './favorites.thunks'
import { IProduct } from 'types'

export interface IFavoritesState {
  favorites: IProduct[]
}

export const initialState: IFavoritesState = {
  favorites: [],
}

const favoritesSlice = createSlice({
  name: 'favorites',
  initialState,
  reducers,
  extraReducers: (builder) => {
    builder
      .addCase(Thunks.loadFavorites.fulfilled, (state, action) =>
        extraReducers.loadFavorites.fulfilled(state, action)
      )
      .addCase(Thunks.loadFavorites.rejected, (state, action) =>
        extraReducers.loadFavorites.rejected(state, action)
      )
      .addCase(Thunks.addFavorite.fulfilled, (state, action) =>
        extraReducers.addFavorite.fulfilled(state, action)
      )
      .addCase(Thunks.addFavorite.rejected, (state, action) =>
        extraReducers.addFavorite.rejected()
      )
      .addCase(Thunks.removeFavorite.fulfilled, (state, action) =>
        extraReducers.removeFavorite.fulfilled(state, action)
      )
      .addCase(Thunks.removeFavorite.rejected, (state, action) =>
        extraReducers.removeFavorite.rejected()
      )
  },
})

// Action Creators

export const actions = {
  // addFavorite: favoritesSlice.actions.addFavorite,
  // removeFavorite: favoritesSlice.actions.removeFavorite,
}

export default favoritesSlice.reducer as Reducer<IFavoritesState>
