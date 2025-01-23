module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "19.21.0"

    cluster_name = "my-eks"
    cluster_version = "1.31"

    cluster_endpoint_private_access = true
    cluster_endpoint_public_access = true

    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    enable_irsa = true

    eks_managed_node_group_defaults = {
        disk_size = 50
    }

    eks_managed_node_groups = {
        general = {
            desired_size = 1
            min_size = 1
            max_size = 10

            labels = {
                role = "general"
            }

            instance_types = ["t3.small"]
            capacity_type  = "ON_DEMAND"
        }

        spot = {
            desired_size = 1
            min_size = 1
            max_size = 10

            labels = {
                role = "spot"
            }

            taints = [{
                key = "market"
                value = "spot"
                effect = "NO_SCHEDULE"
            }]
            
            instance_types = ["t3.micro"]
            capacity_type  = "SPOT"

        }
    }

    manage_aws_auth_configmap = true
    aws_auth_roles = [{
        rolearn  = "module.eks_admins_iam_role.iam_role_arn"
        username = "module.eks_admins_iam_role.iam_role_name"
        groups   = ["system:masters"]
    }]

    tags = {
        Environment = "staging"
    }
    



}

data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

provider "kubernetes" {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token

    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
}