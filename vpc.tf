# Define the VPC
resource "aws_vpc" "vpc1" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Terraform-vpc"
    env  = "dev"
    Team = "DevOps"
  }
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "gwy1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "InternetGateway"
    env  = "dev"
  }
}

# Create public subnets
resource "aws_subnet" "public1" {
  availability_zone = "us-east-1a"
  cidr_block       = "192.168.1.0/24"
  vpc_id           = aws_vpc.vpc1.id

  tags = {
    Name = "public-subnet-1"
    env  = "dev"
  }
}

resource "aws_subnet" "public2" {
  availability_zone = "us-east-1b"
  cidr_block       = "192.168.2.0/24"
  vpc_id           = aws_vpc.vpc1.id
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
    env  = "dev"
  }
}

# Create private subnets
resource "aws_subnet" "private1" {
  availability_zone = "us-east-1a"
  cidr_block       = "192.168.3.0/24"
  vpc_id           = aws_vpc.vpc1.id

  tags = {
    Name = "private-subnet-1"
    env  = "dev"
  }
}

resource "aws_subnet" "private2" {
  availability_zone = "us-east-1b"
  cidr_block       = "192.168.4.0/24"
  vpc_id           = aws_vpc.vpc1.id

  tags = {
    Name = "private-subnet-2"
    env  = "dev"
  }
}

# Create an Elastic IP for the NAT gateway
resource "aws_eip" "eip" {}

# Create a NAT gateway in the public subnet and associate it with an Elastic IP
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "NATGateway"
    env  = "dev"
  }
}

# Create a public route table and associate it with the internet gateway
resource "aws_route_table" "rtpublic" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gwy1.id
  }

  tags = {
    Name = "PublicRouteTable"
    env  = "dev"
  }
}

# Create a private route table and associate it with the NAT gateway
resource "aws_route_table" "rtprivate" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = {
    Name = "PrivateRouteTable"
    env  = "dev"
  }
}

# Associate route tables with subnets
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.rtprivate.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.rtprivate.id
}

resource "aws_route_table_association" "rta3" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.rtpublic.id
}

resource "aws_route_table_association" "rta4" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.rtpublic.id
}
