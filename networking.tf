# Create a VPC

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "Mayur_TestVPC"
  }
}


resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "Mayur_ExampleIGW"
  }
}


# Public Subnet

resource "aws_subnet" "example_subnet" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.1.0.0/24"
  availability_zone = "eu-west-1a"  # Choose an availability zone
  map_public_ip_on_launch = true

  tags = {
    Name = "Mayur_Public_Subnet"
  }
}


resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "Mayur_ExampleRouteTable"
  }
}

resource "aws_route_table_association" "example_subnet_association" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

resource "aws_nat_gateway" "example_nat_gateway" {
  allocation_id = aws_eip.example_eip.id
  subnet_id     = aws_subnet.example_subnet.id

  tags = {
    Name = "Mayur_ExampleNATGateway"
  }
}

resource "aws_eip" "example_eip" {
  domain = "vpc"
  tags = {
    Name = "Mayur_ExampleEIP"
  }
}


# Private Subnet

resource "aws_subnet" "example_private_subnet" {
  vpc_id     = aws_vpc.example_vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "eu-west-1a"  # Choose another availability zone for private subnet

  tags = {
    Name = "Mayur_Private_Subnet"
  }
}

resource "aws_route_table" "example_private_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "Mayur_PrivateRouteTable"
  }
}

resource "aws_route" "example_private_route" {
  route_table_id         = aws_route_table.example_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example_nat_gateway.id
}

resource "aws_route_table_association" "example_private_subnet_association" {
  subnet_id      = aws_subnet.example_private_subnet.id
  route_table_id = aws_route_table.example_private_route_table.id
}