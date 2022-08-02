# to a create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr
  instance_tenancy        = "default"
  enable_dns_hostnames    = true

  tags      = {
    Name    = "${var.project_name}-vpc"
  }
}

# to create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "${var.project_name}-igw"
  }
}

# to use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# to create public subnet az1
resource "aws_subnet" "public_sub_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_sub_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "public sub az1"
  }
}

# to create public subnet az2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_sub_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags      = {
    Name    = "public sub az2"
  }
}

# to create route table and add public route
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags       = {
    Name     = "public route table"
  }
}

# to associate public subnet az1 to public route table
resource "aws_route_table_association" "public_subnet_az1_route_table_association" {
  subnet_id           = aws_subnet.public_sub_az1.id
  route_table_id      = aws_route_table.public_route_table.id 
}

# to associate public subnet az2 to public route table
resource "aws_route_table_association" "public_subnet_az2_route_table_association" {
  subnet_id           = aws_subnet.public_subnet_az2.id
  route_table_id      = aws_route_table.public_route_table.id
}

# to create private app subnet az1
resource "aws_subnet" "private_app_sub_az1" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_app_sub_az1_cidr
  availability_zone        = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private app subnet az1"
  }
}

# to create private app subnet az2
resource "aws_subnet" "private_app_sub_az2" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_app_sub_az2_cidr
  availability_zone        = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private app subnet az2"
  }
}

# to create EIP & NATgateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "natgateway_ngw" {
  allocation_id     = aws_eip.nat_eip.id
  subnet_id         = aws_subnet.public_sub_az1.id
}

# to create private route table and add private route
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  
  tags = {
    Name = "private route table"
  }
}

# private route
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgateway_ngw.id
}

# to associate private subnet az1 to private  route table
resource "aws_route_table_association" "private_app_sub_az1" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_app_sub_az1.id
}

# to associate private subnet az2 to private  route table
resource "aws_route_table_association" "private_app_sub_az2" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_app_sub_az2.id
}

# to create private data subnet az1
resource "aws_subnet" "private_data_subnet_az1" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_data_subnet_az1
  availability_zone        = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private data subnet az1"
  }
}

# to create private data subnet az2
resource "aws_subnet" "private_data_subnet_az2" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = var.private_data_subnet_az2
  availability_zone        = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch  = false

  tags      = {
    Name    = "private data subnet az2"
  }
}

#To create Security Groups
resource "aws_security_group" "three_tier_bastion_sgs" {
  name        = "three_tier_bastion_sg"
  description = "Allow SSH Inbound Traffic From Set IP"
  vpc_id      =  aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "three_tier_lb_sg" {
  name        = "three_tier_lb_sg"
  description = "Allow Inbound HTTP Traffic"
  vpc_id      =  aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three_tier_frontend_app_sg" {
  name        = "three_tier_frontend_app_sg"
  description = "Allow SSH inbound traffic from Bastion, and HTTP inbound traffic from loadbalancer"
  vpc_id      =  aws_vpc.vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_bastion_sgs.id]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three_tier_backend_app_sg" {
  name        = "three_tier_backend_app_sg"
  vpc_id      =  aws_vpc.vpc.id
  description = "Allow Inbound HTTP from FRONTEND APP, and SSH inbound traffic from Bastion"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_frontend_app_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_bastion_sgs.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["24.52.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "three_tier_postgres_sg" {
  name        = "three-tier_rds_sg"
  description = "Allow Postgres Port Inbound Traffic from Backend App Security Group"
  vpc_id      =  aws_vpc.vpc.id

  ingress {
    from_port       = 5432 
    to_port         = 5432 
    protocol        = "tcp"
    security_groups = [aws_security_group.three_tier_backend_app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database subnet group
resource "aws_db_subnet_group" "three_tier_postgres_subnetgroup" {
  name       = "three_tier_postgres_subnetg"
  subnet_ids = [aws_subnet.private_data_subnet_az1.id, aws_subnet.private_data_subnet_az2.id ]

  tags = {
    Name = "three_tier_postgres_subnetg"
  }
}