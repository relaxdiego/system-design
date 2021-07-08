resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = var.vpc_instance_tenancy

  tags = {
    Name = "${var.cluster_name}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}"
  }
}

resource "aws_route" "egress" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_security_group" "workers" {
  vpc_id = aws_vpc.main.id

  # Based on https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html

  ingress {
    description = "Inbound traffic from other workers"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    self        = true
  }

  ingress {
    description = "Inbound HTTPS traffic from control plance"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "All other inbound traffic from control plance"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Recommended outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Additional worker rules

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.group_id]
  }

  tags = {
    Name = "${var.cluster_name}-workers"
  }
}


resource "aws_security_group" "database" {
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Incoming access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }

  tags = {
    Name = "${var.cluster_name}-database"
  }
}


#
# PUBLIC SUBNET 1 RESOURCES
#

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_public_subnet1_cidr
  availability_zone       = var.aws_az1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public1"
    # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/subnet_discovery/
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_eip" "nat_gw1" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat_gw1" {
  allocation_id = aws_eip.nat_gw1.id
  subnet_id     = aws_subnet.public_subnet1.id
  depends_on    = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.cluster_name}-1"
  }
}


#
# PUBLIC SUBNET 2 RESOURCES
#

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = var.aws_az2
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public2"
    # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/subnet_discovery/
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_eip" "nat_gw2" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_nat_gateway" "nat_gw2" {
  allocation_id = aws_eip.nat_gw2.id
  subnet_id     = aws_subnet.public_subnet2.id
  depends_on    = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.env_name}-2"
  }
}


#
# PRIVATE SUBNET 1 RESOURCES
#

resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet1_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-private1"
    # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/subnet_discovery/
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table" "private_subnet1_egress" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1.id
  }

  tags = {
    Name = "${var.env_name}-private-subnet1-egress"
  }
}

resource "aws_route_table_association" "private_subnet1_egress" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_subnet1_egress.id
}


#
# PRIVATE SUBNET 2 RESOURCES
#

resource "aws_subnet" "private_subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet2_cidr
  availability_zone       = var.aws_az2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env_name}-private2"
    # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/deploy/subnet_discovery/
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_route_table" "private_subnet2_egress" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw2.id
  }

  tags = {
    Name = "${var.env_name}-private-subnet2-egress"
  }
}

resource "aws_route_table_association" "private_subnet2_egress" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_subnet2_egress.id
}
