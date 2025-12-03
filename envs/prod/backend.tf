terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"        # replace
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
