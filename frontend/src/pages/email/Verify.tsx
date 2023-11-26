import React from "react"
import { Link } from "react-router-dom"

const VerifyPage: React.FC = () => {
  return(
    <div className="align-center">
      <p>登録されたメールアドレスに認証リンクを送信しました。</p>
      <p>受信したリンクにアクセスして、メールアドレス認証を完了し再度ログインしてください。</p>
      <p><Link to="/login">ログインする</Link></p>
    </div>
  )
}

export default VerifyPage
