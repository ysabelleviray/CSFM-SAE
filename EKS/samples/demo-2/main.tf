# EKS with ALB using Kubernetes and Helm resources

provider "aws" {
  region = "us-east-2"
  alias  = "us-east-2"
}

module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.0.0"

    name = "eks-vpc"
    cidr = "10.0.0.0/16"

    providers = {
        aws = aws.us-east-2
    }

    azs = ["us-east-2a", "us-east-2b", "us-east-2c"]
    #private_subnets     = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
    #public_subnets      = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    enable_nat_gateway = true

    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }

    tags = {
        Terraform   = "true"
        Environment = "dev"
    }
}

module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 19.0"

    cluster_name    = "tf-cluster"
    cluster_version = "1.27"

    providers = {
        aws = aws.us-east-2
    }

    cluster_endpoint_public_access = true

    create_kms_key              = false
    create_cloudwatch_log_group = false
    cluster_encryption_config   = {}

    cluster_addons = {
        coredns = {
        most_recent = true
        }
        kube-proxy = {
        most_recent = true
        }
        vpc-cni = {
        most_recent = true
        }
    }

    vpc_id                   = var.vpc_id
    subnet_ids               = var.private_subnets
    control_plane_subnet_ids = var.private_subnets

    # EKS Managed Node Group(s)
    eks_managed_node_group_defaults = {
        instance_types = ["m5.xlarge", "m5.large", "t3.medium"]
    }

    eks_managed_node_groups = {
        blue = {}
        green = {
        min_size     = 1
        max_size     = 10
        desired_size = 1

        instance_types = ["t3.large"]
        capacity_type  = "SPOT"
        }
    }

    tags = {
        env       = "dev"
        terraform = "true"
    }
}

module "lb_role" {
    source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

    role_name                              = "${var.env_name}_eks_lb"
    attach_load_balancer_controller_policy = true

    oidc_providers = {
        main = {
        provider_arn               = var.oidc_provider_arn
        namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
        }
    }
}

resource "kubernetes_service_account" "service-account" {
    metadata {
        name      = "aws-load-balancer-controller"
        namespace = "kube-system"
        labels = {
        "app.kubernetes.io/name"      = "aws-load-balancer-controller"
        "app.kubernetes.io/component" = "controller"
        }
        annotations = {
        "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
        "eks.amazonaws.com/sts-regional-endpoints" = "true"
        }
    }
}

resource "helm_release" "alb-controller" {
    name       = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    namespace  = "kube-system"
    depends_on = [
        kubernetes_service_account.service-account
    ]

    set {
        name  = "region"
        value = var.main-region
    }

    set {
        name  = "vpcId"
        value = var.vpc_id
    }

    set {
        name  = "image.repository"
        value = "602401143452.dkr.ecr.${var.main-region}.amazonaws.com/amazon/aws-load-balancer-controller"
    }

    set {
        name  = "serviceAccount.create"
        value = "false"
    }

    set {
        name  = "serviceAccount.name"
        value = "aws-load-balancer-controller"
    }

    set {
        name  = "clusterName"
        value = var.cluster_name
    }
}