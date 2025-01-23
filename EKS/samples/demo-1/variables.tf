# VPC Configuration
variable "vpc_name" {
  default = "eks-vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# EKS Cluster Configuration
variable "cluster_name" {
  default = "my-eks-cluster"
}

variable "cluster_version" {
  default = "1.21"
}

variable "eks_role_name" {
  default = "my-app"
}

variable "eks_managed_node_groups" {
  default = {
    example = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]
      min_size       = 2
      max_size       = 10
      desired_size   = 2
    }
  }
}

variable "fargate_profiles" {
  default = {
    name      = "fargate-profile"
    selectors = [
      {
        namespace = "default"
      }
    ]
  }
}

# ALB Configuration
variable "alb_name" {
  default = "eks-alb"
}

variable "target_groups" {
  default = [
    {
      name        = "eks-target-group"
      port        = 80
      protocol    = "HTTP"
      target_type = "ip"
    }
  ]
}

variable "alb_policy_name" {
  default = "ALB-EKS-Access-Policy"
}

variable "alb_policy_document" {
  default = {
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "ec2:DescribeInstances"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "ec2:DescribeSecurityGroups"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  }
}

# S3 Bucket Configuration
variable "eks_logs_bucket_name" {
  default = "my-eks-logs-bucket"
}

variable "eks_logs_bucket_tags" {
  default = {
    Name        = "eks-logs"
    Environment = "prod"
  }
}

# Secrets Manager Configuration
variable "db_credentials_name" {
  default = "db-credentials"
}

variable "db_credentials_description" {
  default = "My database credentials for use in EKS pods"
}

variable "db_credentials_values" {
  default = {
    username = "dbuser"
    password = "dbpassword123"
  }
}

# CloudWatch Configuration
variable "eks_logs_group_name" {
  default = "/aws/eks/my-eks-cluster"
}

# New Variables
variable "cluster_service_accounts" {
  description = "Map of EKS cluster names to service accounts"
  type        = map(list(string))
  default     = {
    "cluster1" = ["default:my-app"]
    "cluster2" = [
      "default:my-app",
      "canary:my-app",
    ]
  }
}

variable "eks_role_tags" {
  description = "Tags to apply to the EKS role"
  type        = map(string)
  default     = {
    Name = "eks-role"
  }
}
