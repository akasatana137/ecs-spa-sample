import { User } from "../types/UserType"
// インスタンスで設定してるはずなのに、withCredentialsをここで指定しないとErrorになる
import http from "./axiosInstance"

const getLoginUser = async () => {
  const { data } = await http.get<User>('/api/user', { withCredentials: true})
  return data
}

// 後で修正
const login = async ({ email, password}: {email: string, password: string} ) => {
  await http.get('/sanctum/csrf-cookie', { withCredentials: true})
  const {data} = await http.post<User>('/api/login', {
    email: email,
    password: password
  }, {withCredentials: true})

  return data
}

const logout = async () => {
  const { data } = await http.post<User>('/api/logout')
  return data
}

const singIn = async ({ name, email, password}: { name: string, email: string, password: string}) => {
  const { data } = await http.post('/api/register', {
    name: name,
    email: email,
    password: password
  })
  return data
}

const verifyEmail= async ({ email, token }: { email: string, token: string }) => {
  const { data } = await http.get<User>(`/api/email/verify/${email}/${token}`)
  return data
}

export {
  getLoginUser,
  login,
  logout,
  singIn,
  verifyEmail
}
