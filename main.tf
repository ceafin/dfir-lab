# main.tf
#

terraform {
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "dfirlab.tfstate"
    bucket  = "dfir-lab-statefile"
  }
}

locals {
  default_tags = {}
}


# Default to us-east-2 if user doesn't specify anything else.
provider "aws" {
  region = "us-east-1"

  default_tags { tags = local.default_tags }
}

provider "dns" {
}

