terraform {
  required_version = "1.3.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

variable "title" {
  type = string
}


provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.title}-vpc"
  }
}

resource "aws_subnet" "public-subnet-ingress-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title}-public-subnet-ingress-1a"
  }
}

resource "aws_subnet" "public-subnet-ingress-1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title}-public-subnet-ingress-1c"
  }
}

resource "aws_subnet" "private-subnet-container-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.8.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title}-private-subnet-container-1a"
  }
}

resource "aws_subnet" "private-subnet-container-1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.9.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title}-private-subnet-container-1c"
  }
}

resource "aws_subnet" "private-subnet-db-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.16.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title}-private-subnet-db-1a"
  }
}

resource "aws_subnet" "private-subnet-db-1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.17.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title}-private-subnet-db-1c"
  }
}

resource "aws_subnet" "public-subnet-management-1a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.240.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title}-public-subnet-management-1a"
  }
}

resource "aws_subnet" "public-subnet-management-1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.241.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title}-public-subnet-management-1c"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-internet-gateway"
  }
}

# ルート

resource "aws_route_table" "route-table-ingress" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "${var.title}-route-table-ingress"
  }
}

# サブネットと関連付け

resource "aws_route_table_association" "association-public-subnet-ingress-1a" {
  subnet_id      = aws_subnet.public-subnet-ingress-1a.id
  route_table_id = aws_route_table.route-table-ingress.id
}

resource "aws_route_table_association" "association-public-subnet-ingress-1c" {
  subnet_id      = aws_subnet.public-subnet-ingress-1c.id
  route_table_id = aws_route_table.route-table-ingress.id
}

resource "aws_route_table_association" "association-public-subnet-management-1a" {
  subnet_id      = aws_subnet.public-subnet-management-1a.id
  route_table_id = aws_route_table.route-table-ingress.id
}

resource "aws_route_table_association" "association-public-subnet-management-1c" {
  subnet_id      = aws_subnet.public-subnet-management-1c.id
  route_table_id = aws_route_table.route-table-ingress.id
}

# ルート

resource "aws_route_table" "route-table-db" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-route-table-db"
  }
}

# サブネットと関連付け

resource "aws_route_table_association" "association-private-subnet-db-1a" {
  subnet_id      = aws_subnet.private-subnet-db-1a.id
  route_table_id = aws_route_table.route-table-db.id
}

resource "aws_route_table_association" "association-private-subnet-db-1c" {
  subnet_id      = aws_subnet.private-subnet-db-1c.id
  route_table_id = aws_route_table.route-table-db.id
}

# ルート

resource "aws_route_table" "route-table-app" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-route-table-app"
  }
}

# サブネットと関連付け

resource "aws_route_table_association" "private-subnet-container-1a" {
  subnet_id      = aws_subnet.private-subnet-container-1a.id
  route_table_id = aws_route_table.route-table-app.id
}

resource "aws_route_table_association" "private-subnet-container-1c" {
  subnet_id      = aws_subnet.private-subnet-container-1c.id
  route_table_id = aws_route_table.route-table-app.id
}