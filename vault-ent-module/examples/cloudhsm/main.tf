provider "aws" {
  region = var.aws_region
}

data "aws_subnet_ids" "cloudhsm_v2_subnets" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Vault"
    values = ["deploy"]
  }
}

resource "aws_cloudhsm_v2_cluster" "cloudhsm_v2_cluster" {
  hsm_type   = "hsm1.medium"
  subnet_ids = data.aws_subnet_ids.cloudhsm_v2_subnets.ids

  tags = {
    Name = "${var.friendly_name_prefix}-vault-aws_cloudhsm_v2_cluster"
  }
}

resource "aws_cloudhsm_v2_hsm" "cloudhsm_v2_hsm" {
  cluster_id        = aws_cloudhsm_v2_cluster.cloudhsm_v2_cluster.cluster_id
  availability_zone = "us-east-1a"
  subnet_id = "subnet-0ec5d51179bd38c7b"
}