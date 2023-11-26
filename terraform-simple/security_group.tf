###########
## Application SG
###########

resource "aws_security_group" "app" {
  name        = "${local.app_name}-app"
  description = "Application SG"
  vpc_id      = aws_vpc.this.id
  tags = {
    Name = "${local.app_name}-app"
  }
}

resource "aws_security_group_rule" "app_from_this" {
  security_group_id = aws_security_group.app.id
  type              = "ingress"
  description       = "Allow from this"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
}

resource "aws_security_group_rule" "app_from_alb" {
  security_group_id        = aws_security_group.app.id
  type                     = "ingress"
  description              = "Allow from ALB"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.alb.id
}

# NATの通信料を抑えるため、publicに配置
resource "aws_security_group_rule" "app_to_any" {
  security_group_id = aws_security_group.app.id
  type              = "egress"
  description       = "Allow to any"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
