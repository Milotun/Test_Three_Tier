# to store statefile in s3
terraform {
  backend "s3" {
    bucket = "terraform2218"
    key    = "Hello-devops.tfstate"
    region = "us-west-2"
    # dynamodb_table = "terraform-statefiletable"
  }
}