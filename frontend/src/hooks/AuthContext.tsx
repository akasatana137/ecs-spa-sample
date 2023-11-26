import React, { createContext, useState, useContext, ReactNode } from "react";
import { AuthContextProps } from "../types/AuthContextType";

const AuthContext = createContext<AuthContextProps>({
  isAuth: false,
  // eslint-disable-next-line @typescript-eslint/no-empty-function
  setIsAuth: () => {}
})

export const AuthProvider: React.FC<{ children: ReactNode}> = ({ children }) => {
  const [isAuth, setIsAuth] = useState(false)

  return (
    <AuthContext.Provider value={{ isAuth, setIsAuth }}>
      { children }
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
