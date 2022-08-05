variable "names" {
  type = string
}

variable "key_name" {
  type = string
}

variable "loadbal_sg" {
  type = any
}

variable "bastion_sg" {
  type = any
}

variable "webserver_sg" {
  type = any
}

variable "appserver_sg" {
  type = any
}

variable "private_subnets" {}

variable "public_subnets" {}

variable "vpc_id" {}