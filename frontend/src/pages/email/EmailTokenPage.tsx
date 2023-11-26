import React from "react"
import { Link, useParams } from "react-router-dom"
import { useGetVerifyEmail } from "../../queries/AuthQuery";

const EmailTokenPage: React.FC = () => {
  const { email, token } = useParams<{email?: string, token?: string}>();
  if (!email || !token) {
    return <div>エラー: 適切なURLを指定してください</div>;
  }

  // eslint-disable-next-line react-hooks/rules-of-hooks
  const { data:user, status } = useGetVerifyEmail(email, token)
  if (status === 'loading') {
    return <div className="loader" />
  }

  const verifySuccess = (
    <p>メールアドレス認証が完了しました。</p>
  )

  const verifyFail = (
    <p>メールアドレス認証に失敗しました。</p>
  )

  return(
    <div className="align-center">
      {user ? verifySuccess : verifyFail}
      <p><Link to="/login">ログインする</Link></p>
    </div>
  )
}

export default EmailTokenPage
