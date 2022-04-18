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
  name       = "redis-cluster-mode-enable"
  subnet_ids = data.aws_subnets.all.ids
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id    = "redis-cluster-mode-enable"
  engine                  = "redis"
  num_node_groups         = 2
  replicas_per_node_group = 1
  parameter_group_name    = "default.redis6.x"
  engine_version          = "6.x"
  node_type               = "cache.t2.micro"
  description             = "Redis cluster mode enable"

  subnet_group_name  = aws_elasticache_subnet_group.group_name.name
  security_group_ids = [aws_security_group.allow_redis.id]
}

output "redis" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}
