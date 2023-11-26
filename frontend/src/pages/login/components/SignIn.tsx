import React, { useState } from "react";
import { Link } from "react-router-dom";
import { useSignIn } from "../../../queries/AuthQuery";
import { toast } from "react-toastify"

const SignInPage: React.FC = () => {
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const signIn = useSignIn()

  const handleRegister = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (password !== confirmPassword) {
      return toast.error("確認用パスワードが違います")
    }
    signIn.mutate({name, email, password})
  }

  return (
    <div className="login-page">
      <div className="login-panel">
          <form onSubmit={handleRegister}>
            <div className="input-group">
                <label>ユーザー名</label>
                <input
                  type="name"
                  className="input"
                  value={name}
                  onChange={e => setName(e.target.value)}
                />
            </div>
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
            <div className="input-group">
                <label>確認用パスワード</label>
                <input
                  type="confirmPassword"
                  className="input"
                  value={confirmPassword}
                  onChange={e => setConfirmPassword(e.target.value)}
                />
            </div>
            <button type="submit" className="btn">サインイン</button>
            <div className="links">
              <p><Link to="/login">ログインはこちら</Link></p>
            </div>
          </form>
      </div>
      <div className="links">
        <p><Link to="/help">ヘルプ</Link></p>
      </div>
    </div>
  )
}

export default SignInPage;
