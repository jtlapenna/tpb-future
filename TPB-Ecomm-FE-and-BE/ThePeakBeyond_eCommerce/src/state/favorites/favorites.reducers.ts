import { AnyAction, PayloadAction } from '@reduxjs/toolkit'
import { toast } from 'react-toastify'

import { IProduct } from 'types'
import { IFavoritesState } from './favorites.slice'

// Reducers
export const reducers = {}

// Extra Reducers
export const loadFavorites = {
  fulfilled: (
    state: IFavoritesState,
    action: PayloadAction<IProduct[]>
  ): void => {
    //console.log({ action })
    state.favorites = action.payload
  },
  rejected: (state: IFavoritesState, action: AnyAction): void => {
    state.favorites = []
  },
}

export const addFavorite = {
  fulfilled: (state: IFavoritesState, action: PayloadAction): void => {
    state.favorites.push((action as any).meta.arg.product as IProduct)
    toast.success('Product is added to favorites')
  },
  rejected: (): void => {
    toast.error('Something went wrong. Please try again. ')
  },
}

export const removeFavorite = {
  fulfilled: (state: IFavoritesState, action: PayloadAction): void => {
    state.favorites = state.favorites.filter(
      (favorite) => favorite.id !== (action.payload as any).productId
    )
    toast.dark('Product is removed from favorites')
  },
  rejected: (): void => {
    toast.error('Something went wrong. Please try again. ')
  },
}

export const extraReducers = { loadFavorites, addFavorite, removeFavorite }
