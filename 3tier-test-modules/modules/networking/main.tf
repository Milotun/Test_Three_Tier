# to use data source to get all avalablility zones in region
data "aws_availability_zones" "available" {}


# To create VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"
  name = "${var.names}-vpc"
  cidr = "10.0.0.0/16"  
  azs                              = data.aws_availability_zones.available.names
  private_subnets                  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets                   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets                 = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  create_database_subnet_group     = true
  enable_nat_gateway               = true
  single_nat_gateway               = true
}


# To create SG Module for loadbalancer
module "loadbal_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  name    = "loadbal-sg"
  vpc_id = module.vpc.vpc_id
ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "allow all traffic"
      cidr_blocks = "0.0.0.0/0"
    },
  
  ]
}


# To create SG Module for bastion
module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  name    = "bastion-sg"
  vpc_id = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "allow ssh"
        cidr_blocks = "0.0.0.0/0"
      },
  ]
}



 # To create SG Module for webserver
module "webserver_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  name    = "webserver-sg"
  vpc_id = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
      {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        description = "allow ssh"
        cidr_blocks = "10.0.0.0/16"
    },
  ]
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "tcp"
      source_security_group_id = module.loadbal_sg.security_group_id
    }
  ]
}


# To create SG Module for appserver
module "appserver_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  name    = "appserver-sg"
  vpc_id = module.vpc.vpc_id
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "tcp"
      source_security_group_id = module.webserver_sg.security_group_id
    },
       {
      rule                     = "tcp"
      source_security_group_id = module.bastion_sg.security_group_id
    },
  ]
 
  ingress_with_cidr_blocks = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          description = "allow ssh"
          cidr_blocks = "24.52.0.0/16"
      },
    ]
  }


# To create SG Module for database
module "database_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"
  name    = "database-sg"
  vpc_id = module.vpc.vpc_id
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "tcp"
      source_security_group_id = module.appserver_sg.security_group_id
    },
  ]
}