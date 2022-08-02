# data
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
}

# Launch template & ASG for bastion host
resource "aws_launch_template" "three_tier_bastion" {
  name_prefix            = "three_tier_bastion"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.amazon_linux_2.id
  vpc_security_group_ids = [var.bastion_sgs]
  key_name               = var.key_name
 

  tags = {
    Name = "three_tier_bastion"
  }
}

resource "aws_autoscaling_group" "three_tier_bastion" {
  name                = "three_tier_bastion"
  vpc_zone_identifier = [aws_subnet.public_sub_az1.id, aws_subnet.public_subnet_az2.id]
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.three_tier_bastion.id
    version = "$Latest"
  }
}


# Launch template & ASG for front end app tier

resource "aws_launch_template" "three_tier_web" {
  name_prefix            = "three_tier_web"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.amazon_linux_2.id
  vpc_security_group_ids = [var.frontend_app_sg]
  key_name               = var.key_name
  user_data              = filebase64("install_docker.sh")
 

  tags = {
    Name = "three_tier_app"
  }
}

data "aws_lb_target_group" "three_tier_tg" {
  name = var.lb_tg
}


resource "aws_autoscaling_group" "three_tier_app" {
  name                = "three_tier_app"
  vpc_zone_identifier = [aws_subnet.public_sub_az1.id, aws_subnet.public_subnet_az2.id] 
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  target_group_arns = [data.aws_lb_target_group.three_tier_tg.arn]

  launch_template {
    id      = aws_launch_template.three_tier_app.id
    version = "$Latest"
  }
}


# Launch template & ASG for backend end app tier

resource "aws_launch_template" "three_tier_backend" {
  name_prefix            = "three_tier_backend"
  instance_type          = var.instance_type
  image_id               = data.aws_ami.amazon_linux_2.id
  vpc_security_group_ids = [var.backend_app_sg]
  key_name               = var.key_name
  user_data              = filebase64("install_postgresclient_10.sh")

  tags = {
    Name = "three_tier_backend"
  }
}

resource "aws_autoscaling_group" "three_tier_backend" {
  name                = "three_tier_backend"
  vpc_zone_identifier = [aws_subnet.private_app_sub_az1.id, aws_subnet.private_app_sub_az2.id]
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.three_tier_backend.id
    version = "$Latest"
  }
}

# Autoscaling attachment from front tier app to load balancer
resource "aws_autoscaling_attachment" "asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.three_tier_app.id
  lb_target_group_arn    = var.lb_tg
}