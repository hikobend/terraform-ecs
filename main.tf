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

resource "aws_security_group" "ingress-security-group" {
  name        = "${var.title}-ingress-security-group"
  description = "ingress-security-group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-ingress-security-group"
  }
}

resource "aws_security_group_rule" "ingress-security-group-role-ingress-HTTP-IPv4" {
  type        = "ingress"
  description = "ingress-security-group-role-ingress-HTTP-IPv4"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.ingress-security-group.id
}

resource "aws_security_group_rule" "ingress-security-group-ingress-HTTP-IPv6" {
  type        = "ingress"
  description = "ingress-security-group-ingress-HTTP-IPv6"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  ipv6_cidr_blocks = [
    "::/0"
  ]

  security_group_id = aws_security_group.ingress-security-group.id
}

resource "aws_security_group_rule" "ingress-security-group-role-egress-all" {
  type        = "egress"
  description = "ingress-security-group-role-egress-all"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.ingress-security-group.id
}

resource "aws_security_group" "front-container-security-group" {
  name        = "${var.title}-front-container-security-group"
  description = "front-container-security-group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-front-container-security-group"
  }
}

resource "aws_security_group_rule" "front-container-security-group-role-from-ingress-security-group" {
  type                     = "ingress"
  description              = "front-container-security-group-role-from-ingress-security-group"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ingress-security-group.id

  security_group_id = aws_security_group.front-container-security-group.id
}

resource "aws_security_group_rule" "front-container-security-group-role-egress-all" {
  type        = "egress"
  description = "front-container-security-group-role-egress-all"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.front-container-security-group.id
}

resource "aws_security_group" "internal-alb-security-group" {
  name        = "${var.title}-internal-alb-security-group"
  description = "internal-alb-security-group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-internal-alb-security-group"
  }
}

resource "aws_security_group_rule" "internal-alb-security-group-from-front-container-security-group" {
  type                     = "ingress"
  description              = "internal-alb-security-group-from-front-container-security-group"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.front-container-security-group.id

  security_group_id = aws_security_group.internal-alb-security-group.id
}

resource "aws_security_group_rule" "internal-alb-security-group-role-from-management-security-group" {
  type                     = "ingress"
  description              = "front-container-security-group-role-from-management-security-group"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.management-security-group.id

  security_group_id = aws_security_group.internal-alb-security-group.id
}

resource "aws_security_group_rule" "internal-alb-security-group-role-egress-all" {
  type        = "egress"
  description = "front-container-security-group-role-egress-all"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.internal-alb-security-group.id
}


resource "aws_security_group" "backend-container-security-group" {
  name        = "${var.title}-backend-container-security-group"
  description = "backend-container-security-group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-backend-container-security-group"
  }
}

resource "aws_security_group_rule" "backend-container-security-group-rule-from-internal-alb-security-group" {
  type                     = "ingress"
  description              = "backend-container-security-group-rule-from-internal-alb-security-group"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internal-alb-security-group.id

  security_group_id = aws_security_group.backend-container-security-group.id
}

resource "aws_security_group_rule" "backend-container-security-group-rule-egress-all" {
  type        = "egress"
  description = "backend-container-security-group-rule-egress-all"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.backend-container-security-group.id
}

resource "aws_security_group" "db-security-group" {
  name        = "${var.title}-db-security-group"
  description = "db-security-group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-db-security-group"
  }
}


resource "aws_security_group_rule" "db-security-group-rule-from-front-container-security-group" {
  type                     = "ingress"
  description              = "db-security-group-rule-from-front-container-security-group"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.front-container-security-group.id

  security_group_id = aws_security_group.db-security-group.id
}

resource "aws_security_group_rule" "db-security-group-rule-from-backend-container-security-group" {
  type                     = "ingress"
  description              = "db-security-group-rule-from-backend-container-security-group"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend-container-security-group.id

  security_group_id = aws_security_group.db-security-group.id
}

resource "aws_security_group_rule" "db-security-group-rule-from-management-security-group" {
  type                     = "ingress"
  description              = "db-security-group-rule-from-management-security-group"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.management-security-group.id

  security_group_id = aws_security_group.db-security-group.id
}

resource "aws_security_group_rule" "db-security-group-rule-egress-all" {
  type        = "egress"
  description = "management-security-group-rule-egress-all"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.db-security-group.id
}


resource "aws_security_group" "management-security-group" {
  name        = "${var.title}-management-security-group"
  description = "management-security-group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${var.title}-management-security-group"
  }
}

resource "aws_security_group_rule" "management-security-group-rule-egress-all" {
  type        = "egress"
  description = "management-security-group-rule-egress-all"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  security_group_id = aws_security_group.management-security-group.id
}