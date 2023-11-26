import React, { useState } from "react";
import { Link } from "react-router-dom";
import { useLogin } from "../../../queries/AuthQuery";

const LoginPage: React.FC = () => {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const login = useLogin()

  const handleLogin = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    login.mutate({email, password})
  }

  return (
    <div className="login-page">
      <div className="login-panel">
          <form onSubmit={handleLogin}>
              <div className="input-group">
                  <label>メールアドレス</label>
                  <input
                    type="email"
                    className="input"
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                  />
              </div>
              <div className="input-group">
                  <label>パスワード</label>
                  <input
                    type="password"
                    className="input"
                    value={password}
                    onChange={e => setPassword(e.target.value)}
                  />
              </div>
              <button type="submit" className="btn">ログイン</button>
              <div className="links">
                <p><Link to="/register">サインインはこちら</Link></p>
              </div>
          </form>
      </div>
      <div className="links">
        <p><Link to="/help">ヘルプ</Link></p>
      </div>
    </div>
  )
}

export default LoginPage;
