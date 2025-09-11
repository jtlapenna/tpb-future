"use client";
import { Provider } from "react-redux";
import { store } from "@/shared/store/store";
import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "@/shared/query/client";
import { CssBaseline, ThemeProvider, createTheme } from "@mui/material";

export function AppProviders({ children }: { children: React.ReactNode }) {
  return (
    <Provider store={store}>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider theme={createTheme()}>
          <CssBaseline />
          {children}
        </ThemeProvider>
      </QueryClientProvider>
    </Provider>
  );
}
