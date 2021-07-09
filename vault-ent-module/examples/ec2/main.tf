provider "aws" {
  region = var.aws_region
}

####################################

# Provision Security Group
resource "aws_security_group" "allow_web" {
  name        = "webserver"
  vpc_id      = var.vpc_id
  description = "Allows access to Web Port"

  ingress {
    from_port   = 22 # Allow SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80 # Allow HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443 # Allow HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8200 # Vault API
    to_port     = 8201 # Vault Replication & Request Forwarding
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # Ping Testing
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0 # Allow Outbound
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

####################################

# Create EC2 instance profile and role
resource "aws_iam_instance_profile" "ec2-ssm-profile" {
  name = "ec2_ssm_profile"
  role = aws_iam_role.ec2-ssm-iam-role.name
}

resource "aws_iam_role" "ec2-ssm-iam-role" {
  name        = "dev-ssm-role"
  description = "The role for the developer resources EC2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.ec2-ssm-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

####################################

# Fetch the latest Ubuntu 18.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Load vault-setup.sh script
// data "template_file" "startup" {
//   template = file("vault-setup.sh")
// }

# Generate an ephemeral private keh to create SSH key pair
resource "tls_private_key" "vault" {
  algorithm = "RSA"
}

locals {
  private_key_filename = "${var.friendly_name_prefix}-ssh-key.pem"
}

resource "aws_key_pair" "vault" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.vault.public_key_openssh
}

# Fetch the private subnet IDs for the VPC
data "aws_subnet_ids" "vault" {
  vpc_id = var.vpc_id
  tags   = var.private_subnet_tags
}

# Randomly choose a subnet
resource random_id index {
  byte_length = 2
}

locals {
  subnet_ids_list = tolist(data.aws_subnet_ids.vault.ids)
  subnet_ids_random_index = random_id.index.dec % length(data.aws_subnet_ids.vault.ids)
  instance_subnet_id = local.subnet_ids_list[local.subnet_ids_random_index]
}

# Provision EC2 instance (Vault Server)
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = local.instance_subnet_id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2-ssm-profile.name
  key_name               = aws_key_pair.vault.key_name
  root_block_device {
    delete_on_termination = true
    volume_type           = "gp2"
    volume_size           = 20
  }
}

