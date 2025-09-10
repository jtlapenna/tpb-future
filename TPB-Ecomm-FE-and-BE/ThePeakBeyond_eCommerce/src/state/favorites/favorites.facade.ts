import { useCallback } from 'react'
import { useAppDispatch, useAppSelector } from 'state'
import * as FavoritesSlice from './favorites.slice'
import * as FavoritesThunks from './favorites.thunks'

export const useFavoritesFacade = () => {
  const dispatch = useAppDispatch()

  const favorites = useAppSelector((state) => state.favoritesState.favorites)

  const loadFavorites = useCallback(
    (storeId: string) => dispatch(FavoritesThunks.loadFavorites(storeId)),
    [dispatch]
  )

  const addFavorite = useCallback(
    (payload) => dispatch(FavoritesThunks.addFavorite(payload)),
    [dispatch]
  )

  const removeFavorite = useCallback(
    (payload) => dispatch(FavoritesThunks.removeFavorite(payload)),
    [dispatch]
  )

  return {
    favorites,
    loadFavorites,
    addFavorite,
    removeFavorite,
  }
}
