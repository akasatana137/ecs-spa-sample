###########
## vpc
###########

resource "aws_vpc" "this" {
  cidr_block = var.cidr
  tags = {
    Name = local.app_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = local.app_name
  }
}

###########
## public subnet
###########
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${local.app_name}-public-subnet-${count.index + 1}"
  }
}

###########
## private subnet
###########
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${local.app_name}-private-subnet-${count.index + 1}"
  }
}

###########
## database subnet
###########
resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block        = element(var.database_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${local.app_name}-database-subnet-${count.index + 1}"
  }
}


###########
## elasticache subnet
###########
resource "aws_subnet" "elasticache" {
  count = length(var.elasticache_subnets)

  vpc_id = aws_vpc.this.id

  cidr_block        = element(var.elasticache_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${local.app_name}-elasticache-subnet-${count.index + 1}"
  }
}

###########
## NAT
###########
resource "aws_eip" "nat_1a" {
  domain = "vpc"

  tags = {
    Name = "${local.app_name}-eip-for-natgw-1a"
  }
}

resource "aws_nat_gateway" "nat_1a" {
  allocation_id = aws_eip.nat_1a.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${local.app_name}-natgw-1a"
  }
}

###########
## Route Table
###########
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${local.app_name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

# CodeBuildを配置(RDSとElasticacheが外部と通信する必要がある場合はroute_tableを追加)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_1a.id
  }
  tags = {
    Name = "${local.app_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.app_name}-database"
  }
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets)

  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}

resource "aws_route_table" "elasticache" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.app_name}-elasticache"
  }
}

resource "aws_route_table_association" "elasticache" {
  count = length(var.elasticache_subnets)

  subnet_id      = element(aws_subnet.elasticache[*].id, count.index)
  route_table_id = aws_route_table.elasticache.id
}
