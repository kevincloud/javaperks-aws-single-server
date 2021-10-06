module "asset_bucket" {
    source  = "app.terraform.io/kevindemos/jp-s3-bucket/aws"
    version = "1.0.0"

    name = "hc-workshop-2.0-assets-${var.unit_prefix}"

    tags = {
        owner = var.owner
        se-region = var.se-region
        purpose = var.purpose
        ttl = var.ttl
        terraform = var.terraform
    }
}