data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-pro-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

module "vpc" {
  source              = "../../modules/vpc"
  vpc_cidr_block      = "10.0.0.0/16"
  subnet_1_cidr_block = "10.0.1.0/24"
  subnet_2_cidr_block = "10.0.2.0/24"
  
}

module "eks" {
  source     = "../../modules/eks"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
}


module "sonar" {
  source             = "../../modules/ec2"
  instance_name      = "sonar"
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = "t3.large"
  key_name           = "YCamp-key"
  security_group_ids = [aws_security_group.app_sg.id]
  volume_size        = 30
  vpc_id = module.vpc.vpc_id
}

module "server" {
  source             = "../../modules/ec2"
  instance_name      = "server"
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = "t2.medium"
  key_name           = "YCamp-key"
  security_group_ids = [aws_security_group.app_sg.id]
  volume_size        = 20
  vpc_id = module.vpc.vpc_id

}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for application server"
  vpc_id      = module.vpc.vpc_id   

  # SSH
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SMTPS
  ingress {
    description = "SMTPS"
    from_port   = 465
    to_port     = 465
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SMTP
  ingress {
    description = "SMTP"
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SMTP Submission
  ingress {
    description = "SMTP Submission"
    from_port   = 587
    to_port     = 587
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB
  ingress {
    description = "MongoDB"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP 6443 (K8s API / custom app)
  ingress {
    description = "Custom TCP 6443"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom TCP Range
  ingress {
    description = "Custom TCP range"
    from_port   = 3000
    to_port     = 10000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OUTBOUND (default – allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

