resource "aws_subnet" "private_subnet1" {
    vpc_id = aws_vpc.main.id
    cidr_block = element(local.private_subnet_cidrs, 0)
    availability_zone = element(local.azs, 0)
    tags = {
        "Name" = "${local.env}-private-${element(local.azs,0)}"
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
    }
}

resource "aws_subnet" "private_subnet2" {
    vpc_id = aws_vpc.main.id
    cidr_block = element(local.private_subnet_cidrs, 1)
    availability_zone = element(local.azs, 1)
    tags = {
        "Name" = "${local.env}-private-${element(local.azs,1)}"
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
    }
}

resource "aws_subnet" "public_subnet1" {
    vpc_id     = aws_vpc.main.id
    cidr_block = element(local.public_subnet_cidrs, 0)
    availability_zone = element(local.azs, 0)
    
    tags = {
        "Name" = "${local.env}-public-${element(local.azs,0)}"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
    }
}

resource "aws_subnet" "public_subnet2" {
    vpc_id     = aws_vpc.main.id
    cidr_block = element(local.public_subnet_cidrs, 1)
    availability_zone = element(local.azs, 1)
    
    tags = {
        "Name" = "${local.env}-public-${element(local.azs,1)}"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
    }
}

# resource "aws_subnet" "private_subnets" {
#   vpc_id = aws_vpc.main.id
#   count = length(local.private_subnet_cidrs)
#   cidr_block = element(local.private_subnet_cidrs, count.index)
#   availability_zone = element(local.azs, count.index)
#   tags = {
#     "Name" = "${local.env}-private-${count.index + 1}"
#     "kubernetes.io/role/internal-elb" = "1"
#     "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
#   }
# }
# resource "aws_subnet" "public_subnets" {
#  count      = length(local.public_subnet_cidrs)
#  vpc_id     = aws_vpc.main.id
#  cidr_block = element(local.public_subnet_cidrs, count.index)
#  availability_zone = element(local.azs, count.index)
 
#   tags = {
#     "Name" = "${local.env}-public-${count.index + 1}"
#     "kubernetes.io/role/elb" = "1"
#     "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "owned"
#   }
# }