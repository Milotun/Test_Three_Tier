
variable "key_name" {}
variable "instance_type" {}
variable "bastion_sgs" {} 
variable "frontend_app_sg" {}
variable "backend_app_sg" {}
variable "lb_tg" {}
variable "region" {}
variable "vpc" {
  type = any
}

variable "public_subnets" {
  type = list
}

variable "private_subnets" {
  type = list
}

