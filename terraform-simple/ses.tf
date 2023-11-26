###########
## SES domain dkim
###########

resource "aws_ses_domain_identity" "this" {
  domain = local.host_domain
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

resource "aws_route53_record" "this_amazonses_dkim_record" {
  count   = 3
  zone_id = data.aws_route53_zone.host_domain.zone_id
  name    = "${aws_ses_domain_dkim.this.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.this.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

###########
## SES domain identity mail from
###########

resource "aws_ses_domain_mail_from" "this" {
  domain           = aws_ses_domain_identity.this.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.this.domain}"
}

resource "aws_route53_record" "this_ses_domain_mail_from_mx" {
  zone_id = data.aws_route53_zone.host_domain.zone_id
  name    = aws_ses_domain_mail_from.this.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.ap-northeast-1.amazonses.com"]
}

resource "aws_route53_record" "this_ses_domain_mail_from_txt" {
  zone_id = data.aws_route53_zone.host_domain.zone_id
  name    = aws_ses_domain_mail_from.this.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}

###########
## SES IAM
###########

resource "aws_iam_user" "smtp" {
  name = "ses-smtp-user.20231123-121146"
}

resource "aws_iam_access_key" "smtp" {
  user = aws_iam_user.smtp.name
}

resource "aws_iam_user_policy" "smtp" {
  name = "AmazonSesSendingAccess"
  user = aws_iam_user.smtp.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ],
        "Resource" : "*"
      }
    ]
  })
}

###########
## SES SSM username, password
###########

resource "aws_ssm_parameter" "smtp_username" {
  name        = "${local.ssm_parameter_store_base}/MAIL_USERNAME"
  type        = "SecureString"
  value       = aws_iam_access_key.smtp.id
  description = "Access Key ID used as the SMTP username"
}

resource "aws_ssm_parameter" "smtp_password" {
  name        = "${local.ssm_parameter_store_base}/MAIL_PASSWORD"
  type        = "SecureString"
  value       = aws_iam_access_key.smtp.ses_smtp_password_v4
  description = "Secret access key converted into an SES SMTP password"
}
