output "vpc" {
  value = module.vpc #A
}

output "loadbal_sg" {
  value = module.loadbal_sg.security_group_id #BB
}

output "bastion_sg" {
  value = module.bastion_sg.security_group_id #BB
}

output "webserver_sg" {
  value =  module.webserver_sg.security_group_id #B#B
}

output "appserver_sg" {
  value = module.appserver_sg.security_group_id#B
}


output "database_sg" {
  value = module.database_sg.security_group_id#B
}


output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "security_group_id" {
  value = { #B
    loadbal_sg     = module.loadbal_sg.security_group_id #B
    bastion_sg     = module.bastion_sg.security_group_id #B
    webserver_sg   = module.webserver_sg.security_group_id #B
    appserver_sg   = module.appserver_sg.security_group_id #    
  } #B
}