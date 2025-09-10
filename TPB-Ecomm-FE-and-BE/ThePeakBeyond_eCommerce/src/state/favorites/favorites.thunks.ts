import { createAsyncThunk } from '@reduxjs/toolkit'

import { IProduct } from 'types'
import * as FavoritesService from './favorites.service'

export const loadFavorites = createAsyncThunk(
  'favorites/loadFavorites',
  async (storeId: string) => await FavoritesService.loadFavorites(storeId)
)

export const addFavorite = createAsyncThunk(
  'favorites/addFavorite',
  async (params: { storeId: string; product: IProduct }) =>
    await FavoritesService.addFavorite(params)
)

export const removeFavorite = createAsyncThunk(
  'favorites/removeFavorite',
  async (productId: string) => await FavoritesService.removeFavorite(productId)
)
