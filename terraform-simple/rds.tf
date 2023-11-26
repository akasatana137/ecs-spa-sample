###########
## SSM
###########

data "aws_ssm_parameter" "database_name" {
  name = "${local.ssm_parameter_store_base}/database_name"
}

data "aws_ssm_parameter" "database_user" {
  name = "${local.ssm_parameter_store_base}/database_user"
}

data "aws_ssm_parameter" "database_password" {
  name            = "${local.ssm_parameter_store_base}/database_password"
  with_decryption = true
}

###########
## SG
###########

resource "aws_security_group" "database_sg" {
  name        = "${local.app_name}-database-sg"
  description = "${local.app_name}-database"

  vpc_id = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.app_name}-database-sg"
  }
}

resource "aws_security_group_rule" "database_sg_rule" {
  security_group_id = aws_security_group.database_sg.id

  type = "ingress"

  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"

  source_security_group_id = aws_security_group.app.id
}

resource "aws_db_subnet_group" "database_sg_group" {
  name        = "${local.app_name}-database-subnet-group"
  description = "${local.app_name}-database-subnet-group"

  subnet_ids = [for subnet in aws_subnet.database : subnet.id]
}

###########
## RDS
###########

resource "aws_db_parameter_group" "this" {
  name   = "${local.app_name}-mysql-parameter-group"
  family = "mysql8.0"

  # データベースに設定するパラメーター
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}

resource "aws_db_instance" "this" {
  identifier        = "${local.app_name}-db"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t2.micro"

  username = data.aws_ssm_parameter.database_user.value
  password = data.aws_ssm_parameter.database_password.value
  db_name  = data.aws_ssm_parameter.database_name.value

  parameter_group_name = aws_db_parameter_group.this.name

  vpc_security_group_ids = [aws_security_group.database_sg.id]

  db_subnet_group_name = aws_db_subnet_group.database_sg_group.name
  # 削除できるよう修正
  skip_final_snapshot = true
}

## create ssm db endpoint
resource "aws_ssm_parameter" "db_url" {
  name  = "${local.ssm_parameter_store_base}/db_url"
  type  = "String"
  value = aws_db_instance.this.endpoint
}
