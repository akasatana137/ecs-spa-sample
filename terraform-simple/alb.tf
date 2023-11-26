###########
## SG
###########

resource "aws_security_group" "alb" {
  name        = "${local.app_name}-alb"
  description = "${local.app_name} alb rule based routing"
  vpc_id      = aws_vpc.this.id
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.app_name}-alb"
  }
}

resource "aws_security_group_rule" "alb_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

###########
## ALB
###########

resource "aws_lb" "this" {
  name               = "${local.app_name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "${local.app_name}-alb"
    enabled = true
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.host_domain_wc_acm.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "503 Service Temporarily Unavailable"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

###########
## Route53 A record alb
###########

resource "aws_route53_record" "a_record_for_app_subdomain" {
  name    = aws_route53_zone.app_subdomain.name
  type    = "A"
  zone_id = aws_route53_zone.app_subdomain.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
  }
}

resource "aws_route53_record" "a_record_for_api_subdomain" {
  name    = aws_route53_zone.api_subdomain.name
  type    = "A"
  zone_id = aws_route53_zone.api_subdomain.zone_id
  alias {
    evaluate_target_health = true
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
  }
}

###########
## S3 Access Logs
###########

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "${local.app_name}-alb-logs"
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.alb_logs_policy_document.json
}

data "aws_iam_policy_document" "alb_logs_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_logs.arn}/${local.app_name}-alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }
}

# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
#       },
#       "Action": "s3:PutObject",
#       "Resource": "arn:aws:s3:::bucket-name/prefix/AWSLogs/aws-account-id/*"
#     }
#   ]
# }
