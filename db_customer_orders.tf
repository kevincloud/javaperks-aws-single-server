module "cust-order-table" {
    source  = "app.terraform.io/kevindemos/jp-ddb-table/aws"
    version = "1.0.0"

    name = "customer-orders-${var.unit_prefix}"
    hash_key = "OrderId"

    attributes = [
        {
            name = "OrderId"
            type = "S"
        },
        {
            name = "CustomerId"
            type = "S"
        }
    ]

    global_secondary_indexes = [
        {
            name = "CustomerIndex"
            hash_key = "CustomerId"
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
