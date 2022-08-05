# data
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
}

# Launch template & ASG for bastion host
resource "aws_launch_template" "three_tier_bastion" {
  name_prefix            = "three_tier_bastion"
  instance_type          = "t2.micro"
  image_id               = data.aws_ami.amazon_linux_2.id
  vpc_security_group_ids = [var.bastion_sg]
  key_name               = var.key_name
 

  tags = {
    Name = "three_tier_bastion"
  }
}

resource "aws_autoscaling_group" "three_tier_bastion" {
  name                = "three_tier_bastion"
  vpc_zone_identifier = var.public_subnets
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_bastion.id
    version = "$Latest"
  }
}

# Launch template & ASG for  web tier
resource "aws_launch_template" "three_tier_web" {
  name_prefix            = "three_tier_web"
  instance_type          = "t2.micro"
  image_id               = data.aws_ami.amazon_linux_2.id
  vpc_security_group_ids = [var.webserver_sg]
  key_name               = var.key_name
  user_data              = filebase64("install_docker.sh")
 

  tags = {
    Name = "three_tier_web"
  }
}

resource "aws_autoscaling_group" "three_tier_web" {
  name                = "three_tier_web"
  vpc_zone_identifier = var.public_subnets
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  target_group_arns   = module.alb.target_group_arns

  launch_template {
    id      = aws_launch_template.three_tier_web.id
    version = "$Latest"
  }
}

# Launch template & ASG for app tier
resource "aws_launch_template" "three_tier_app" {
  name_prefix            = "three_tier_app"
  instance_type          = "t2.micro"
  image_id               = data.aws_ami.amazon_linux_2.id
  vpc_security_group_ids = [var.appserver_sg]
  key_name               = var.key_name
  user_data              = filebase64("install_postgresclient_10.sh")

  tags = {
    Name = "three_tier_app"
  }
}

resource "aws_autoscaling_group" "three_tier_app" {
  name                = "three_tier_app"
  vpc_zone_identifier = var.private_subnets
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_app.id
    version = "$Latest"
  }
}

# to create module for alb & attachment to asg
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"
  name                = var.names
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.public_subnets
  security_groups    = [var.loadbal_sg]

  http_tcp_listeners = [
    {
      port               = 80, #C
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    { name_prefix      = "websvr",
      backend_protocol = "HTTP",
      backend_port     = 8080
      target_type      = "instance"
    }
  ]

}
