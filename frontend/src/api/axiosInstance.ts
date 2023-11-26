import axios from "axios"

const apiEndpoint = process.env.REACT_APP_API_ENDPOINT

const http = axios.create({
  // 環境変数からInjectさせる
  baseURL: apiEndpoint,
  withCredentials: true,
});

export default http
