###########
## SG
###########

resource "aws_security_group" "elasticache_sg" {
  name = "${local.app_name}-elasticache-sg"

  vpc_id = aws_vpc.this.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.app_name}-elasticache-sg"
  }
}

resource "aws_security_group_rule" "elasticache_sg_rule" {
  security_group_id = aws_security_group.elasticache_sg.id

  type = "ingress"

  from_port = 6379
  to_port   = 6379
  protocol  = "tcp"

  source_security_group_id = aws_security_group.app.id
}

###########
## Redis
###########

# エンドポイントをTerraform上から取得できるよう、replication_groupを使用
resource "aws_elasticache_replication_group" "test-cluster" {
  replication_group_id = "${local.app_name}-redis-cluster"
  description          = "${local.app_name}-redis-cluster"
  # engine               = "redis"
  port = 6379
  # parameter_group_name = "default.redis3.2"
  node_type = "cache.t2.micro"

  num_cache_clusters = 1
  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.elasticache_sg.id]
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.app_name}-redis-subnet"
  subnet_ids = [for subnet in aws_subnet.elasticache : subnet.id]
}

### create ssm redis endpoint
resource "aws_ssm_parameter" "elasticache_url" {
  name  = "${local.ssm_parameter_store_base}/elasticache_url"
  type  = "String"
  value = aws_elasticache_replication_group.test-cluster.primary_endpoint_address
}

# resource "aws_elasticache_subnet_group" "this" {
#   name       = "my-cache-subnet"
#   subnet_ids = [for subnet in aws_subnet.elasticache : subnet.id]
# }

# resource "aws_elasticache_cluster" "this" {
#   cluster_id           = "${local.app_name}-elasticache-cluster"
#   engine               = "redis"
#   node_type            = "cache.t2.micro"
#   num_cache_nodes      = 1
#   port                 = 6379
#   apply_immediately    = true
#   parameter_group_name = "default.redis3.2"
#   subnet_group_name    = aws_elasticache_subnet_group.this.name
#   security_group_ids   = [aws_security_group.elasticache_sg.id]
# }
