###########
## ECS cluster
###########

resource "aws_ecs_cluster" "this" {
  name = "${local.app_name}-ecs-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  capacity_providers = ["FARGATE"]
  cluster_name       = aws_ecs_cluster.this.name
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
}

###########
## ECS IAM Role
###########

# https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task_execution_IAM_role.html

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ecs-tasks.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]
}

resource "aws_iam_policy" "kms_decrypt_policy" {
  name = "${local.app_name}-kms-decrypt-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt"
        ],
        "Resource" : [
          # data.aws_ssm_parameter.database_password.arn,
          "arn:aws:ssm:ap-northeast-1:${data.aws_caller_identity.current.account_id}:parameter/spa/prod/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_kms" {
  policy_arn = aws_iam_policy.kms_decrypt_policy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_iam_policy" "ses_send_email_policy" {
  name = "${local.app_name}-ses-send-email-policy"
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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_ses" {
  policy_arn = aws_iam_policy.ses_send_email_policy.arn
  role       = aws_iam_role.ecs_task_execution_role.name
}

###########
## ECS Task Container Log Group
###########

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "${local.app_name}/frontend"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "backend_middleware" {
  name              = "${local.app_name}/backend/middleware"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "backend_app" {
  name              = "${local.app_name}/backend/app"
  retention_in_days = 7
}

###########
## ECR
###########

data "aws_ecr_repository" "frontend" {
  name = local.ecr_frontend_repository_name
}

data "aws_ecr_repository" "backend_middleware" {
  name = local.ecr_backend_middleware_repository_name
}

data "aws_ecr_repository" "backend_app" {
  name = local.ecr_backend_app_repository_name
}

data "aws_ecr_image" "frontend" {
  repository_name = data.aws_ecr_repository.frontend.name
  most_recent     = true
}

data "aws_ecr_image" "backend_middleware" {
  repository_name = data.aws_ecr_repository.backend_middleware.name
  most_recent     = true
}

data "aws_ecr_image" "backend_app" {
  repository_name = data.aws_ecr_repository.backend_app.name
  most_recent     = true
}

###########
## ECS Task Definition
###########

data "aws_ssm_parameter" "app_env" {
  name = "${local.ssm_parameter_store_base}/app_env"
}
data "aws_ssm_parameter" "app_key" {
  name = "${local.ssm_parameter_store_base}/app_key"
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = local.frontend_task_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name         = local.frontend_task_container_name
      image        = "${data.aws_ecr_repository.frontend.repository_url}:${data.aws_ecr_image.frontend.image_tags[0]}"
      portMappings = [{ containerPort : 80 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.frontend.name
          awslogs-stream-prefix : "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "backend" {
  family                   = local.backend_task_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  volume {
    name = "php-fpm-socket"
  }

  container_definitions = jsonencode([
    {
      name         = local.backend_task_middleware_container_name
      image        = "${data.aws_ecr_repository.backend_middleware.repository_url}:${data.aws_ecr_image.backend_middleware.image_tags[0]}"
      portMappings = [{ containerPort : 80 }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.backend_middleware.name
          awslogs-stream-prefix : "ecs"
        }
      }

      # FARGATEのため、仕方なく
      volumesFrom = [
        {
          sourceContainer : local.backend_task_app_container_name
          readOnly : null
        }
      ]

      dependsOn = [
        {
          containerName : local.backend_task_app_container_name
          condition : "START"
        }
      ]

      # mount_points = [
      #   {
      #     sourceVolume  = "php-fpm-socket"
      #     containerPath = "/var/run/php-fpm/php-fpm.sock"
      #     readOnly      = false
      #   }
      # ]
    },
    {
      name  = local.backend_task_app_container_name
      image = "${data.aws_ecr_repository.backend_app.repository_url}:${data.aws_ecr_image.backend_app.image_tags[0]}"
      environment = [
        # Laravel
        {
          name : "SESSION_DOMAIN"
          value : ".${local.host_domain}"
        },
        {
          name : "SANCTUM_STATEFUL_DOMAINS"
          value : "https://${local.app_domain_name}"
        },
        # SES
        {
          name : "MAIL_MAILER"
          value : local.app_mail_mailer
        },
        {
          name : "MAIL_HOST"
          value : local.app_mail_host
        },
        {
          name : "MAIL_PORT"
          value : local.app_mail_port
        },
        {
          name : "MAIL_ENCRYPTION"
          value : local.app_mail_encryption
        },
        {
          name : "MAIL_FROM_ADDRESS"
          value : aws_ses_domain_mail_from.this.mail_from_domain
        },
        {
          name : "MAIL_FROM_NAME"
          value : local.app_mail_from_name
        }
      ]
      # 今回はcodebuild内でDBのMigrationを実行するために、環境変数を挿入するので以下は重複
      secrets = [
        {
          name : "APP_ENV"
          valueFrom : data.aws_ssm_parameter.app_env.arn
        },
        {
          name : "APP_KEY"
          valueFrom : data.aws_ssm_parameter.app_key.arn
        },
        # MySQL
        {
          name : "DB_DATABASE"
          valueFrom : data.aws_ssm_parameter.database_name.arn
        },
        {
          name : "DB_USERNAME"
          valueFrom : data.aws_ssm_parameter.database_user.arn
        },
        {
          name : "DB_PASSWORD"
          valueFrom : data.aws_ssm_parameter.database_password.arn
        },
        {
          name : "DB_HOST"
          valueFrom : aws_ssm_parameter.db_url.arn
        },
        # SES
        {
          name : "MAIL_USERNAME"
          valueFrom : aws_ssm_parameter.smtp_username.arn
        },
        {
          name : "MAIL_PASSWORD"
          valueFrom : aws_ssm_parameter.smtp_password.arn
        }
        # Redis
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.backend_app.name
          awslogs-stream-prefix : "ecs"
        }
      }

      # FARGATEでは、コンテナ間で直接のファイルシステム共有は、かなり制限されているっぽい
      # mount_points = [
      #   {
      #     sourceVolume  = "php-fpm-socket"
      #     containerPath = "/var/run/php-fpm/php-fpm.sock"
      #     readOnly      = false
      #   }
      # ]
    }
  ])
}

###########
## ECS Service
###########

resource "aws_ecs_service" "frontend" {
  name                               = "${local.app_name}-frontend"
  cluster                            = aws_ecs_cluster.this.id
  platform_version                   = "LATEST"
  task_definition                    = aws_ecs_task_definition.frontend.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  propagate_tags                     = "SERVICE"
  enable_execute_command             = true
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 60
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  network_configuration {
    assign_public_ip = true
    subnets          = [for subnet in aws_subnet.public : subnet.id]
    security_groups  = [aws_security_group.app.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = local.frontend_task_container_name
    container_port   = 80
  }
}

resource "aws_lb_target_group" "frontend" {
  name                 = "${local.app_name}-tg-frontend"
  vpc_id               = aws_vpc.this.id
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60
  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  condition {
    host_header {
      values = [local.app_domain_name]
    }
  }
}

resource "aws_ecs_service" "backend" {
  name                               = "${local.app_name}-backend"
  cluster                            = aws_ecs_cluster.this.id
  platform_version                   = "LATEST"
  task_definition                    = aws_ecs_task_definition.backend.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  propagate_tags                     = "SERVICE"
  enable_execute_command             = true
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 60
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  network_configuration {
    assign_public_ip = true
    subnets          = [for subnet in aws_subnet.public : subnet.id]
    security_groups  = [aws_security_group.app.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = local.backend_task_middleware_container_name
    container_port   = 80
  }
}

resource "aws_lb_target_group" "backend" {
  name                 = "${local.app_name}-tg-backend"
  vpc_id               = aws_vpc.this.id
  target_type          = "ip"
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 60
  health_check {
    path = "/api/health_check"
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 2
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {
    host_header {
      values = [local.api_domain_name]
    }
  }
}

resource "aws_lb_listener_rule" "maintenance" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = local.maintenance_body
      status_code  = "503"
    }
  }
  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
