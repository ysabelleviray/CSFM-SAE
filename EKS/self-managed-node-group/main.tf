provider "aws" {
  region = var.region
}

# Provision VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "eks_vpc"
  }
}

# Provision 2 subnets (public and private)
resource "aws_subnet" "eks_subnet_public" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.subnet_public_cidr
  availability_zone       = var.subnet_az_order[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public-subnet"
  }
}

resource "aws_subnet" "eks_subnet_private" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.subnet_private_cidr
  availability_zone       = var.subnet_az_order[1]
  tags = {
    Name = "eks-private-subnet"
  }
}

# Provision EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_subnet_public.id,
      aws_subnet.eks_subnet_private.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# Define IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect   = "Allow"
        Sid      = ""
      }
    ]
  })
}

# Attach IAM Policy to IAM Role for EKS Cluster
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Define IAM Role for EC2 instances in EKS Node Group
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect   = "Allow"
        Sid      = ""
      }
    ]
  })
}

# Attach IAM Policies to IAM Role for EKS Node Group
resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

# Provision EC2 instances (Self-Managed Node Group)
resource "aws_instance" "eks_worker_node" {
  count             = var.node_group_desired_size
  ami               = var.node_ami_id # EKS optimized AMI or custom AMI
  instance_type     = var.node_instance_types[0]
  key_name          = var.ssh_key_name
  subnet_id         = aws_subnet.eks_subnet_private.id
  iam_instance_profile = aws_iam_instance_profile.eks_node_group_instance_profile.name

  security_groups   = [aws_security_group.eks_node_group_sg.name]

  tags = {
    Name = "eks-node"
  }

  # Ensure nodes are launched after the EKS cluster
  depends_on = [aws_eks_cluster.eks]
}

# IAM Instance Profile for Worker Nodes
resource "aws_iam_instance_profile" "eks_node_group_instance_profile" {
  name = "eks-node-group-instance-profile"
  role = aws_iam_role.eks_node_group_role.name
}

# Security Group for EKS Node Group
resource "aws_security_group" "eks_node_group_sg" {
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-group-sg"
  }
}

# EC2 Auto Scaling (optional but recommended for self-managed node groups)
resource "aws_autoscaling_group" "eks_node_group_asg" {
  desired_capacity     = var.node_group_desired_size
  max_size             = var.node_group_max_size
  min_size             = var.node_group_min_size
  vpc_zone_identifier  = [aws_subnet.eks_subnet_private.id]
  launch_configuration = aws_launch_configuration.eks_node_group_launch_config.id

  tag {
      key                 = "Name"
      value               = "eks-node-group-asg"
      propagate_at_launch = true
    }
  
}


# Launch Configuration for Auto Scaling Group
resource "aws_launch_configuration" "eks_node_group_launch_config" {
  name          = "eks-node-group-launch-config"
  image_id      = var.node_ami_id
  instance_type = var.node_instance_types[0]
  key_name      = var.ssh_key_name
  security_groups = [aws_security_group.eks_node_group_sg.id]

  iam_instance_profile = aws_iam_instance_profile.eks_node_group_instance_profile.name

  lifecycle {
    create_before_destroy = true
  }
}

