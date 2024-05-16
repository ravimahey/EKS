terraform {
  required_version = ">= 0.12.0"

  backend "s3" {
    bucket         = "terraform-backend-statefile20240514190621861500000001"
    key            = "state/terraform.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
    kms_key_id     = "alias/terraform-bucket-key"
    dynamodb_table = "terraform-statefile-lock"
    # assume_role = {
    #   role_arn = "arn:aws:iam::167437618295:role/terraform-backend"
    # }
  }
}

provider "aws" {
  region = var.region
}
