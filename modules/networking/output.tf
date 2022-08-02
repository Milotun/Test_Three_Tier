output "region" {
    value = var.region
}

output "project_name" {
    value = var.project_name
}

output "vpc" {
    value = aws_vpc.vpc.id
}

output "public_subnets" {
    value = aws_subnet.public_sub_az1.id
          = aws_subnet.public_subnet_az2.id
}


output "private_subnets" {
    value = aws_subnet.private_app_sub_az1.id
          = aws_subnet.private_app_sub_az2.id

}

output "database_subnets" {
    value = {
       az1     = aws_subnet.private_data_subnet_az1.id
       az2     = aws_subnet.private_data_subnet_az2.id
}
    } 

