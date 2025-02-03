resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
        Name = "private"
    }
  
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "public"
    }
  
}

# Associate Public Subnets with the Public Route Table
resource "aws_route_table_association" "public_association_a" {
    subnet_id      = aws_subnet.public-us-east-1a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_association_b" {
    subnet_id      = aws_subnet.public-us-east-1b.id
    route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with the Private Route Table
resource "aws_route_table_association" "private_association_a" {
    subnet_id      = aws_subnet.private-us-east-1a.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_association_b" {
    subnet_id      = aws_subnet.private-us-east-1b.id
    route_table_id = aws_route_table.private.id
}