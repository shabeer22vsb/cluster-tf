terraform {
    required_providers {
        aws = {
           source = "hashicorp/aws"
           version = "~> 6.0"
        }
    }
}

provider aws {
       region = "eu-west-1"
    }

terraform {
  cloud {
    organization = "terraform-learning-from-scratch"

    workspaces {
      name = "terraform-learning"
    }
  }
}