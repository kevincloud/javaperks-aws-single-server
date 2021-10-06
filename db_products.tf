module "product-table" {
    source  = "app.terraform.io/kevindemos/jp-ddb-table/aws"
    version = "1.0.0"

    name = "product-main-${var.unit_prefix}"
    hash_key = "ProductId"
    range_key = "ProductName"

    attributes = [
        {
            name = "ProductId"
            type = "S"
        },
        {
            name = "ProductName"
            type = "S"
        }
    ]

    tags = {
        owner = var.owner
        se-region = var.se-region
        purpose = var.purpose
        ttl = var.ttl
        terraform = var.terraform
    }
}
