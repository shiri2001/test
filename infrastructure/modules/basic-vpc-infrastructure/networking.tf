resource "aws_vpc" "vpc" {
  cidr_block       = var.app_vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name    = "${var.project}_vpc"
    project = "${var.project}"
  }
}


resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = false
  availability_zone       = var.az[count.index]

  tags = {
    Name    = "${var.project}_private_subnet_${count.index}"
    project = "${var.project}"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true
  availability_zone       = var.az[count.index]

  tags = {
    Name    = "${var.project}_public_subnet_${count.index}"
    project = "${var.project}"
  }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name    = "${var.project}_internet_gw"
    project = "${var.project}"
  }
}

resource "aws_eip" "nat_gw_eip" {
  count  = length(var.public_subnet_cidr_blocks)
  domain = "vpc"

  tags = {
    Name    = "${var.project}_nat_gw_eip_${count.index}"
    project = "${var.project}"
  }

  depends_on = [aws_internet_gateway.internet_gw]
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.public_subnet_cidr_blocks)
  allocation_id = aws_eip.nat_gw_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name    = "${var.project}_nat_gw_${count.index}"
    project = "${var.project}"
  }

  depends_on = [aws_internet_gateway.internet_gw]
}

resource "aws_route_table" "private_route_table" {
  count  = length(var.private_subnet_cidr_blocks)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = var.allowed_cidr_block_access
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name    = "${var.project}_private_route_table_${count.index}"
    project = "${var.project}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.allowed_cidr_block_access
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  tags = {
    Name    = "${var.project}_public_route_table"
    project = "${var.project}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}