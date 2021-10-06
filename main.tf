provider "aws" {
    region = var.region
}

module "network" {
    source  = "app.terraform.io/kevindemos/jp-public-vpc/aws"
    version = "1.0.3"

    unit_prefix = var.unit_prefix
    region = var.region

    tags = {
        owner = var.owner
        se-region = var.se-region
        purpose = var.purpose
        ttl = var.ttl
        terraform = var.terraform
    }
}
