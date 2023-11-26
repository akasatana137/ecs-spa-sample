locals {
  app_name = "ecs-spa"
  tags     = "ecs-terraform-practice"

  # domain
  host_domain     = "akasatana.net"
  app_domain_name = "app.akasatana.net"
  api_domain_name = "api.akasatana.net"

  # ssm parameter store prefix
  ssm_parameter_store_base = "/spa/prod"

  # ecr repository
  ecr_frontend_repository_name           = "nginx-react"
  ecr_backend_middleware_repository_name = "nginx-php"
  ecr_backend_app_repository_name        = "php-fpm"

  # ecs task definition
  frontend_task_name                     = "${local.app_name}-task-frontend"
  backend_task_name                      = "${local.app_name}-task-backend"
  frontend_task_container_name           = "${local.app_name}-container-nginx-frontend"
  backend_task_middleware_container_name = "${local.app_name}-container-nginx-backend"
  backend_task_app_container_name        = "${local.app_name}-container-phpfpm-backend"

  # codebuild(必要であればカスタムImageを作成)
  app_env_codebuild                                 = "local"
  app_debug_codebuild                               = "true"
  IAM_POLICY_ARN_AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  IMA_POLICY_ARN_AmazonSSMReadOnlyAccess            = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"

  # ses
  app_mail_mailer     = "smtp"
  app_mail_host       = "email-smtp.${var.region}.amazonaws.com"
  app_mail_port       = 587
  app_mail_encryption = "tls"
  app_mail_from_name  = "ToDoアプリ"

  # alb maintenance HTML
  maintenance_body = <<EOF
<!doctype html> <title>メンテナンス中</title> <style> body { text-align: center; padding: 150px; } h1 { font-size: 50px; } body { font: 20px Helvetica, sans-serif; color: #333; } article { display: block; text-align: left; width: 650px; margin: 0 auto; } a { color: #dc8100; text-decoration: none; } a:hover { color: #333; text-decoration: none; } </style> <article> <h1>只今メンテナンス中です</h1> <div> <p>システムの改修を行なっております。ご不便をおかけいたしますが今しばらくお待ちください。</p> <p>&mdash; 開発チーム</p> </div> </article>
EOF
}
