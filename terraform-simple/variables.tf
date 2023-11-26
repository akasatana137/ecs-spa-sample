###########
## provider
###########

variable "region" {
  type = string
}

variable "profile_name" {
  type = string
}

###########
## vpc
###########

variable "cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "database_subnets" {
  type = list(string)
}

variable "elasticache_subnets" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}
