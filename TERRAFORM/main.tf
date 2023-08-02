terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  /*
  #Remote state comentado pois seria necessario antes a criação do S3. 
    backend "s3" {
      bucket = "quideroli-tf-remote-state"
      key    = "aws-challenge//terraform.tfstate"
      region = "us-east-1"
    }
  */

}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = local.common_tags
  }
}
