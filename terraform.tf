terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }

  backend "s3" {
    bucket = "samarth-bucket-16-jan"
    key = "terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "samarth-state-table"
  }

  # remember when we change or add new block in the terraform block we have to do "teraform init" again
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}