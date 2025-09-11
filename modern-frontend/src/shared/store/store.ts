import { configureStore, createSlice } from "@reduxjs/toolkit";

// Minimal placeholder slice to satisfy Redux store requirements
const uiSlice = createSlice({
  name: "ui",
  initialState: {} as Record<string, unknown>,
  reducers: {}
});

export const store = configureStore({ reducer: { ui: uiSlice.reducer } });
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
