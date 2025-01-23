module "allow_eks_iam_policy" {
    source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
    version = "~> 5.0"

    name        = "allow-eks"
    path        = "/"
    description = "IAM policy to allow EKS"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action   = [
                    "eks:DescribeCluster",
                    "eks:ListClusters"
                ]
                Effect   = "Allow"
                Resource = "*"
            }
        ]
    })
  
} 

module "eks_admins_iam_role" {
    source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
    version = "~> 5.0"

    role_name = "eks-admins"
    create_role = true
    role_requires_mfa = false   
    
    custom_role_policy_arns = [module.allow_eks_iam_policy.arn]

    trusted_role_arns = [
        "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
    ]
}

module "user1_iam_user" {
    source = "terraform-aws-modules/iam/aws//modules/iam-user"
    name   = "user1"

    create_iam_access_key = false
    create_iam_user_login_profile = false 
    force_destroy = true
}