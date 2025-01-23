module "cluster_autoscaler_irsa_role"{
    source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"    
    version = "5.3.1"
    
    role_name = "cluster-autoscaler-irsa-role"
    # attach_vpc_cni_policy = true
    # vpc_cni_enable_ipv4   = true
    attach_cluster_autoscaler_policy = true
    cluster_autoscaler_cluster_ids = [module.eks.cluster_id]

    oidc_providers = {
        main = {
        provider_arn               = module.eks.oidc_provider_arn
        namespace_service_accounts = ["kube-system:aws-node"]
        }
    }

}