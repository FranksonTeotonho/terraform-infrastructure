#---------------------------------
# Data Source - AZs
#---------------------------------
data "aws_availability_zones" "available_azs" {
  state = "available"
}

#---------------------------------
# VPC
#---------------------------------
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name       = "${var.env}-vpc",
    managed_by = "Terraform"
  }
}

#---------------------------------
# Public Subnets
#---------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = var.number_of_public_subnets
  cidr_block              = var.public_subnets_cidr[count.index]
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name       = "${var.env}-public-subnet-${count.index}",
    type       = "Public",
    managed_by = "Terraform"
  }
}

#---------------------------------
# Private Subnets
#---------------------------------
resource "aws_subnet" "private_subnets" {
  count             = var.number_of_private_subnets
  cidr_block        = var.privates_subnets_cidr[count.index]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available_azs.names[count.index]

  tags = {
    Name       = "${var.env}-private-subnet-${count.index}",
    type       = "Private",
    managed_by = "Terraform"
  }
}

#---------------------------------
# Internet Gateway + Nat configuration
#---------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name       = "${var.env}-igw",
    managed_by = "Terraform"
  }
}

resource "aws_eip" "elastic_ips" {
  count      = length(aws_subnet.public_subnets)
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count         = length(aws_subnet.public_subnets)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)
  allocation_id = element(aws_eip.elastic_ips.*.id, count.index)
}

#---------------------------------
# Public route table
#---------------------------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name       = "${var.env}-public-rt",
    managed_by = "Terraform"
  }
}

resource "aws_route_table_association" "public_association" {
  count          = var.number_of_public_subnets
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

#---------------------------------
# Private route table
#---------------------------------
resource "aws_route_table" "private_route_table" {
  count  = length(aws_nat_gateway.nat)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }

  tags = {
    Name       = "${var.env}-private-rt",
    managed_by = "Terraform"
  }
}

resource "aws_route_table_association" "private_association" {
  count          = var.number_of_private_subnets
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}