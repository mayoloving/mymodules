# data source for availability zones
data "aws_availability_zones" "region_availability_zones" {
  state = "available"
}

# Create a VPC
resource "aws_vpc" "yotambenz-tf-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name            = "yotambenz-tf-vpc"
    owner           = var.owner_tag
    expiration_date = var.expiration_tag
    bootcamp        = var.bootcamp_tag
  }
}

# Create Internet Gateway and attach it to VPC
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.yotambenz-tf-vpc.id

  tags = {
    owner           = var.owner_tag
    expiration_date = var.expiration_tag
    bootcamp        = var.bootcamp_tag
  }
}

# ==============================================================================

# Create a Public Subnets.
resource "aws_subnet" "publicsubnets" {
  vpc_id            = aws_vpc.yotambenz-tf-vpc.id
  count             = var.subnet_count
  cidr_block        = var.pubsub_cidrs[count.index]
  availability_zone = data.aws_availability_zones.region_availability_zones.names[count.index]

  tags = {
    owner           = var.owner_tag
    expiration_date = var.expiration_tag
    bootcamp        = var.bootcamp_tag
  }
}

# ==============================================================================

# Route tables
resource "aws_route_table" "PublicRTs" {
  vpc_id = aws_vpc.yotambenz-tf-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    owner           = var.owner_tag
    expiration_date = var.expiration_tag
    bootcamp        = var.bootcamp_tag
  }

  depends_on = [
    aws_internet_gateway.IGW
  ]
}

resource "aws_route_table_association" "rtb_association" {
  route_table_id = aws_route_table.PublicRTs.id
  count          = var.subnet_count
  subnet_id      = aws_subnet.publicsubnets[count.index].id
}
