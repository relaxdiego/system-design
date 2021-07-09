resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
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


#
# PUBLIC SUBNET 1 RESOURCES
#

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_public_subnet1_cidr
  availability_zone       = var.vpc_az1
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
  cidr_block              = var.vpc_public_subnet2_cidr
  availability_zone       = var.vpc_az2
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
    Name = "${var.cluster_name}-2"
  }
}


#
# PRIVATE SUBNET 1 RESOURCES
#

resource "aws_subnet" "private_subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_private_subnet1_cidr
  availability_zone       = var.vpc_az1
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
    Name = "${var.cluster_name}-private-subnet1-egress"
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
  cidr_block              = var.vpc_private_subnet2_cidr
  availability_zone       = var.vpc_az2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-private2"
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
    Name = "${var.cluster_name}-private-subnet2-egress"
  }
}

resource "aws_route_table_association" "private_subnet2_egress" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_subnet2_egress.id
}
