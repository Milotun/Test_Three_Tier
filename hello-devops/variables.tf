variable "names" {
  description = "The project name to use for unique resource naming"
  type        = string
}

variable "key_name" {
  description = "SSH keypair to use for EC2 instance"
  default     = null #A
  type        = string
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
  type        = string
}

variable "password" {
  type = string #A
}


