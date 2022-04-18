provider "aws" {
  region  = "us-west-2"
  profile = "kala"
}

data "aws_subnets" "all" {}

resource "aws_security_group" "allow_redis" {
  name = "allow-redis"

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "group_name" {
  name       = "redis-single-node"
  subnet_ids = data.aws_subnets.all.ids
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-single-node"
  engine               = "redis"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.x"
  node_type            = "cache.t2.micro"

  subnet_group_name  = aws_elasticache_subnet_group.group_name.name
  security_group_ids = [aws_security_group.allow_redis.id]
}

output "aws_subnets" {
  value = data.aws_subnets.all.ids
}

output "redis" {
  value = aws_elasticache_cluster.redis.cache_nodes
}