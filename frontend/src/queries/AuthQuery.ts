import { useMutation, useQuery } from "react-query"
import * as api from "../api/AuthApi"
import { toast } from "react-toastify"
import { useAuth } from "../hooks/AuthContext"
import { AxiosError } from "axios"
import { useNavigate } from "react-router-dom"

const useGetLoginUser = () => {
  return useQuery('users', api.getLoginUser)
}

const useLogin = () => {
  const { setIsAuth } = useAuth()
  return useMutation(api.login, {
    onSuccess: () => {
      setIsAuth(true)
      toast.success('ログインしました')
    },
    onError: () => {
      toast.error('ログインに失敗しました')
    }
  })
}

const useLogout = () => {
  const { setIsAuth } = useAuth()
  return useMutation(api.logout, {
    onSuccess: (user) => {
      setIsAuth(false)
    },
    onError: () => {
      toast.error('ログアウトに失敗しました')
    }
  })
}

// useAuthの状態を変化させるべかきはあとで考える
const useSignIn = () => {
  const navigate = useNavigate()
  return useMutation(api.singIn, {
    onSuccess: (user) => {
      console.log(user)
      toast.success('新規ユーザー登録に成功しました')
      navigate('/verify')
    },
    onError: (error: AxiosError) => {
      const data: any = error.response?.data
      if (data.errors) {
        Object.values(data.errors).map((messages: any) => {
          messages.map((message: string) => {
            toast.error(message)
          })
        })
      } else {
        toast.error('新規ユーザー登録に失敗しました')
      }
    }
  })
}

const useGetVerifyEmail = (email: string, token: string) =>{
  return useQuery('user', () => api.verifyEmail({ email, token}))
};

export {
  useGetLoginUser,
  useLogin,
  useLogout,
  useSignIn,
  useGetVerifyEmail
}
