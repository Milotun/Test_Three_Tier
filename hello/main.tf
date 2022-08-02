# the provider which helps to initiate connection  with AWS Account
provider "aws" {
  region  = var.region
  profile = "default"
}

# to create vpc 
module "networking" {
    source                   = "../modules/vpc_three_tier/networking"
    region                   = var.region
    project_name             = var.project_name
    vpc_cidr                 = var.vpc_cidr
    public_sub_az1_cidr      = var.public_sub_az1_cidr
    public_sub_az2_cidr      = var.public_sub_az2_cidr
    private_app_sub_az1_cidr = var.private_app_sub_az1_cidr
    private_app_sub_az2_cidr = var.private_app_sub_az2_cidr
    private_data_subnet_az1  = var.private_data_subnet_az1
    private_data_subnet_az2  = var.private_data_subnet_az2
  

}

# to create  ASGs
module "compute" {
    source                      = "../modules/vpc_three_tier/compute"
    key_name                    = var.key_name
    instance_type               = var.instance_type
    bastion_sgs                 = var.bastion_sgs
    public_subnets              = module.networking.public_subnets
    frontend_app_sg             = var.frontend_app_sg
    backend_app_sg              = var.backend_app_sg
    lb_tg                       = var.lb_tg 
    region                      = var.region
    vpc                         = module.networking.vpc
    private_subnets             = module.networking.private_subnets


}
