module "instance_profile" {
    source  = "app.terraform.io/kevindemos/jp-instance-profile/aws"
    version = "1.0.0"

    unit_prefix = var.unit_prefix
    actions = [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2messages:GetMessages",
        "ssm:UpdateInstanceInformation",
        "ssm:ListInstanceAssociations",
        "ssm:ListAssociations",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey",
        "s3:*"
    ]
    tags = {
        owner = var.owner
        se-region = var.se-region
        purpose = var.purpose
        ttl = var.ttl
        terraform = var.terraform
    }
}


module "server" {
    source  = "app.terraform.io/kevindemos/jp-server/aws"
    version = "1.0.4"

    vpc_id = module.network.vpc_id
    unit_prefix = var.unit_prefix
    key_pair = var.key_pair
    subnet_id = module.network.public_subnet_id
    instance_profile_id = module.instance_profile.id
    mysql_host = module.mysql.db_address
    mysql_user = var.mysql_user
    mysql_pass = var.mysql_pass
    mysql_database = var.mysql_database
    aws_kms_key_id = var.aws_kms_key_id
    region = var.region
    s3_bucket_id = module.asset_bucket.id
    vault_license_key = var.vault_license_key
    consul_license_key = var.consul_license_key
    nomad_license_key = var.nomad_license_key
    consul_join_key = var.consul_join_key
    consul_join_value = var.consul_join_value
    table_product_id = module.product-table.id
    table_cart_id = module.cust-cart-table.id
    table_order_id = module.cust-order-table.id
    git_branch = var.git_branch
    ldap_pass = var.ldap_pass

    tags = {
        owner = var.owner
        se-region = var.se-region
        purpose = var.purpose
        ttl = var.ttl
        terraform = var.terraform
    }
}
module "mysql" {
    source  = "app.terraform.io/kevindemos/jp-mysql/aws"
    version = "1.0.3"

    name = "javaperks${var.unit_prefix}"
    vpc_id = module.network.vpc_id
    unit_prefix = var.unit_prefix
    identifier = "javaperksdb${var.unit_prefix}"
    instance_size = "db.${var.instance_size}"
    subnet_ids = module.network.private_subnet_ids
    mysql_user = var.mysql_user
    mysql_pass = var.mysql_pass

    tags = {
        owner = var.owner
        se-region = var.se-region
        purpose = var.purpose
        ttl = var.ttl
        terraform = var.terraform
    }
}

