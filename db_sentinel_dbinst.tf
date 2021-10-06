module "instance-table" {
    source  = "app.terraform.io/kevindemos/jp-ddb-table/aws"
    version = "1.0.0"

    name = "product-main-${var.unit_prefix}"
    hash_key = "ListType"
    range_key = "MachineType"

    attributes = [
        {
            name = "ListType"
            type = "S"
        },
        {
            name = "MachineType"
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

