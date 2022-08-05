# the provider which helps to initiate connection  with AWS Account
provider "aws" {
  region  = var.region
  profile = "default"
} 

module "compute" {
  source        = "../3tier-test-modules/modules/compute" 
  key_name      = var.key_name         
  names         = var.names          
  vpc_id        = module.networking.vpc_id
  loadbal_sg    = module.networking.loadbal_sg 
  appserver_sg  = module.networking.appserver_sg 
  bastion_sg    = module.networking.bastion_sg 
  webserver_sg  = module.networking.webserver_sg  
  private_subnets = module.networking.private_subnets
  public_subnets  = module.networking.public_subnets

}

module "networking" {
  source     = "../3tier-test-modules/modules/networking" 
  names      = var.names          
}

module "database" {
  source                 = "../3tier-test-modules/modules/database"
  names                  = var.names          
  vpc                    = module.networking.vpc
  database_sg            = module.networking.database_sg
  password               = var.password

}

