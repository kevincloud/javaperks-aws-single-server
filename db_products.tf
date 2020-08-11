resource "aws_dynamodb_table" "product-data-table" {
    name = "product-main-${var.unit_prefix}"
    billing_mode = "PROVISIONED"
    read_capacity = 20
    write_capacity = 20
    hash_key = "ProductId"
    range_key = "ProductName"
    
    attribute {
        name = "ProductId"
        type = "S"
    }
    
    attribute {
        name = "ProductName"
        type = "S"
    }

    tags = {
        Name = "product-main-${var.unit_prefix}"
        Owner = var.owner
        Region = var.hc_region
        Purpose = var.purpose
        TTL = var.ttl
    }
}
