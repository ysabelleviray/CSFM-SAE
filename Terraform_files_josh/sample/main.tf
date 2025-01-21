terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "joshdemovpc" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags = {
    Name = "Josh Demo VPC"
  }
}

resource "aws_internet_gateway" "joshdemogateway" {
  vpc_id = "${aws_vpc.joshdemovpc.id}"
  
  tags = {
    Name = "Josh IGW"
  }
}

resource "aws_subnet" "public_subnets" {
 count      = length(var.public_subnet_cidrs)
 vpc_id     = aws_vpc.joshdemovpc.id
 cidr_block = element(var.public_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Josh Public Subnet ${count.index + 1}"
 }
}

resource "aws_subnet" "private_subnets" {
 count      = length(var.private_subnet_cidrs)
 vpc_id     = aws_vpc.joshdemovpc.id
 cidr_block = element(var.private_subnet_cidrs, count.index)
 availability_zone = element(var.azs, count.index)
 
 tags = {
   Name = "Josh Private Subnet ${count.index + 1}"
 }
}

resource "aws_route_table" "public_rt" {
 vpc_id = aws_vpc.joshdemovpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.joshdemogateway.id
 }
 
 tags = {
   Name = "Josh Public Route Table"
 }
}

resource "aws_route_table_association" "public_subnet_asso" {
 count = length(var.public_subnet_cidrs)
 subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
 route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
 vpc_id = aws_vpc.joshdemovpc.id
 
 tags = {
   Name = "Josh Private Route Table"
 }
}

resource "aws_route_table_association" "private_subnet_asso" {
 count = length(var.private_subnet_cidrs)
 subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
 route_table_id = aws_route_table.private_rt.id
}