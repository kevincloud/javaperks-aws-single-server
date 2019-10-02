resource "aws_dynamodb_table" "db-instance-table" {
    name = "allowed-instances-${var.unit_prefix}"
    billing_mode = "PROVISIONED"
    read_capacity = 20
    write_capacity = 20
    hash_key = "ListType"
    range_key = "MachineType"
    
    attribute {
        name = "ListType"
        type = "S"
    }
    
    attribute {
        name = "MachineType"
        type = "S"
    }

    tags = {
        Name = "allowed-instances-${var.unit_prefix}"
    }
}
