
# to create database
resource "aws_db_instance" "database" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "10"
  instance_class         = "db.t2.micro"
  identifier             = "${var.names}-db-instance"
  db_name                = "test"
  username               = "postgres1"
  password               = var.password
  db_subnet_group_name   = var.vpc.database_subnet_group
  vpc_security_group_ids = [var.database_sg]  #B
  skip_final_snapshot    = true
}