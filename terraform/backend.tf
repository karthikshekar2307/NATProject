terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "natterrabuck"
    key            = "nat-infra/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "tf-lock-monitoring-dev"
  }
}

provider "aws" {
  region = var.aws_region
}
