resource "aws_eks_cluster" "eks_1" {
  name = "eks-argocd"

  access_config {
    authentication_mode = "API"
  }
  
  role_arn = aws_iam_role.cluster.arn
  version  = "1.32"

  vpc_config {
    subnet_ids = var.subnet_ids 
    endpoint_public_access = false
    security_group_ids = [aws_security_group.cluster_sg.id]
  }
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator","controllerManager","scheduler"]
  
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = {
    Name = "eks-cluster"
    Environment = "Dev"
    Service = "EKS cluster"
  }
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-example"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "eks-cluster-role"
    Environment = "Dev"
    Service = "IAM role"
  }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_launch_template" "eks_nodes_lt" {
  name_prefix = "eks-gp3-"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30        # GB (as per need)
      volume_type           = "gp3"
      iops                  = 3000      # optional (default 3000)
      throughput            = 125       # optional (default 125)
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "storage-for-nodes"
    Environment = "Dev"
    Service = "volume"
  }
  
}



resource "aws_eks_node_group" "eks_1_nodes" {
  cluster_name    = aws_eks_cluster.eks_1.name
  node_group_name = "eks-argocd-nodes"
  node_role_arn   = aws_iam_role.nodegroup_role.arn
  subnet_ids      = var.subnet_ids
  
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  instance_types = ["t2g.medium"]

  launch_template {
    id      = aws_launch_template.eks_nodes_lt.id
    version = "$Latest"
  }
   
  update_config {
    max_unavailable = 1
  }
  remote_access {
    ec2_ssh_key = "YCamp-key"
    source_security_group_ids = [aws_security_group.node_sg.id]
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Name = "eks-node-group"
    Environment = "Dev"
    Service = "EKS-nodes"
  }
}

resource "aws_iam_role" "nodegroup_role" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = {
    Name = "eks-nodegroup-role"
    Environment = "Dev"
    Service = "EKS-nodes"
  }
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodegroup_role.name
}

resource "aws_security_group" "node_sg" {
  description = "SG For Nodes"
  ingress {
    description = "EKS Node SSH Access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["223.237.8.75/32"]
  }
  egress {
    description = "EKS Node Internet Access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["223.237.8.75/32"]
  }
  tags = {
    Name = "eks-cluster-sg"
    Environment = "Dev"
    Service = "EKS-nodes"
  }
}

resource "aws_security_group" "cluster_sg" {
  description = "SG For Cluster"

  egress {
    description = "EKS Cluster Internet Access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["223.237.8.75/32"]
  }
  tags = {
    Name = "eks-cluster-sg"
    Environment = "Dev"
    Service = "EKS"
  }
}

data "aws_caller_identity" "current" {}


resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS Secrets Encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ✅ Account root – admin access
      {
        Sid    = "AllowAccountRoot"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },

      # ✅ EKS cluster role – secrets encryption
      {
        Sid    = "AllowEKSClusterUse"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.cluster.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "eks-secrets-kms-key"
    Environment = "Dev"
    Service = "EKS"
  }
}



resource "aws_kms_alias" "eks_secrets_alias" {
  name          = "alias/eks-secrets-encryption"
  target_key_id = aws_kms_key.eks_secrets.key_id
}


resource "aws_iam_role_policy" "eks_kms_access" {
  role = var.cluster_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*"
        ]
        Resource = aws_kms_key.eks_secrets.arn
      }
    ]
  })

}
