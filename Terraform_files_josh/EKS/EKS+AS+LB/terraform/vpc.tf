module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "5.17"
    name = "main"
    cidr = "10.0.0.0/16"
    
    azs             =   ["us-east-1a","us-east-1b"]
    private_subnets =   ["10.0.0.0/19","10.0.32.0/19"]
    public_subnets  =   ["10.0.64.0/19","10.0.96.0/19"]

    public_subnet_tags = {
        "kubernetes.io/cluster/main" = "shared"
        "kubernetes.io/role/elb" = "1"
    }    
    private_subnet_tags = {
        "kubernetes.io/cluster/main" = "shared"
        "kubernetes.io/role/internal-elb" = "1"
    }
    
    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false

    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Environment = "development"
    }

    
}

resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "Allow SSH inbound traffic"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
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
        Name = "allow_ssh"
    }
}

resource "aws_security_group" "allow_http" {
    name        = "allow_http"
    description = "Allow HTTP inbound traffic"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
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
        Name = "allow_http"
    }
}

resource "aws_security_group" "allow_https" {
    name        = "allow_https"
    description = "Allow HTTPS inbound traffic"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
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
        Name = "allow_https"
    }
}