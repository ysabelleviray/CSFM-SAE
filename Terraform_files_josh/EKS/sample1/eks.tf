resource "aws_iam_role" "eks_cluster" {
    name = "eks-cluster"
    assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks_cluster.name
}

resource "aws_eks_cluster" "eks" {
    name = "${local.env}-${local.eks_name}"
    role_arn = aws_iam_role.eks_cluster.arn
    version = "${local.eks_version}"

    vpc_config {
        endpoint_private_access = false
        endpoint_public_access = true

        subnet_ids = [
            aws_subnet.private_subnet1.id,
            aws_subnet.private_subnet2.id
            
        ]
    }

    depends_on = [
        aws_iam_role_policy_attachment.amazon_eks_cluster_policy
    ]
}