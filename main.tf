terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
  }
}


provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name                 = "test"
  cidr                 = "10.0.0.0/16"
  azs                  = ["us-west-1a","us-west-1b"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}


resource "aws_db_subnet_group" "rds" {
  name       = "test_cpg_db_subnet_group${random_id.id.hex}"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "test_cpg_db_subnet_group${random_id.id.hex}"
  }
}
resource "aws_security_group" "rds" {
  name   = "test_cpg_rds${random_id.id.hex}"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test_rds${random_id.id.hex}"
  }
}

resource "aws_db_parameter_group" "rds" {
  name   = "test-cpg-aws-db-parameter-group${random_id.id.hex}"
  family = "mysql5.7"

   parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

resource "aws_db_instance" "test_db_instance" {
  identifier             = "test-cpg-aws-db-instance${random_id.id.hex}"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "5.7"
  username               = "cmpdev"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.rds.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
  
resource "random_id" "id" {
  byte_length = 2
}
