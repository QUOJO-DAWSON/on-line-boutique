terraform {
  backend "s3" {
    bucket       = "eks-state-bucket-020925"
    key          = "terraform.tfstate"
    region       = "us-east-2"
    encrypt      = true

    /*dynamodb_table = "terraform-eks-state-locks"*/ # Uncomment if using DynamoDB for state locking
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  cluster_name         = var.cluster_name
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  node_groups     = var.node_groups
}