import axios from "axios";
export const http = axios.create({ baseURL: process.env.NEXT_PUBLIC_API_URL });
http.interceptors.response.use(r => r, e => {
  if (e?.response?.status === 401) {
    // TODO: route to login or refresh token
  }
  return Promise.reject(e);
});
