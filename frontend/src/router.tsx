import { BrowserRouter, Routes, Route, Link, Navigate } from "react-router-dom";
import HelpPage from "./pages/help";
import LoginPage from "./pages/login/components/Login";
import SignInPage from "./pages/login/components/SignIn";
import VerifyPage from "./pages/email/Verify";
import TaskPage from "./pages/tasks";
import EmailTokenPage from "./pages/email/EmailTokenPage";
import { useGetLoginUser, useLogout } from "./queries/AuthQuery";
import { useAuth } from "./hooks/AuthContext";
import { useEffect } from "react";
import Error404Page from "./pages/errors";

const Router: React.FC = () => {
  const logout = useLogout()
  const { isLoading, data: authUser} = useGetLoginUser()
  const { isAuth, setIsAuth } = useAuth()

  useEffect(() => {
    if (authUser) {
      setIsAuth(true)
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [authUser])

  const loginNavigation = (
    <header className="global-head">
      <ul>
        <li><Link to="/help">ヘルプ</Link></li>
        <li><Link to="/login">ログイン</Link></li>
      </ul>
    </header>
  )

  const logoutNavigation = (
    <header className="global-head">
      <ul>
        <li><Link to="/">ホーム</Link></li>
        <li><Link to="/help">ヘルプ</Link></li>
        <li><span onClick={() => logout.mutate()}>ログアウト</span></li>
      </ul>
    </header>
  )

  // if (isLoading) return <div className="loader"></div>

  return (
    <BrowserRouter>
      <div>
        {isAuth ? logoutNavigation : loginNavigation}
      </div>
      <Routes>
        <Route
          path="/"
          element={(isAuth) ? <TaskPage /> : <Navigate replace to="/login" />}
        />
        <Route
          path="login"
          element={(!isAuth) ? <LoginPage /> : <Navigate replace to="/" />}
        />
        <Route
          path="register"
          element={(!isAuth) ? <SignInPage /> : <Navigate replace to="/" />}
        />
        {/* 後で修正 */}
        <Route
          path="verify"
          element={(!isAuth) ? <VerifyPage /> : <Navigate replace to="/" />}
        />
        <Route
          path=":email/:token"
          element={(!isAuth) ? <EmailTokenPage /> : <Navigate replace to="/" />}
        />
        <Route path="help" element={<HelpPage />} />
        <Route path="*" element={<Error404Page />} />
      </Routes>
    </BrowserRouter>
  )
}

export default Router;
