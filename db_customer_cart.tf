module "cust-cart-table" {
    source  = "app.terraform.io/kevindemos/jp-ddb-table/aws"
    version = "1.0.0"

    name = "customer-cart-${var.unit_prefix}"
    hash_key = "SessionId"
    range_key = "ProductId"

    attributes = [
        {
            name = "SessionId"
            type = "S"
        },
        {
            name = "ProductId"
            type = "S"
        }
    ]

    global_secondary_indexes = [
        {
            name = "SessionIndex"
            hash_key = "SessionId"
            write_capacity = 10
            read_capacity = 10
            projection_type = "ALL"
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

