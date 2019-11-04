data "template_file" "hashi-server-setup" {
    template = "${file("${path.module}/scripts/single_install.sh")}"

    vars = {
        MYSQL_HOST = "${aws_db_instance.javaperks-mysql.address}"
        MYSQL_USER = "${var.mysql_user}"
        MYSQL_PASS = "${var.mysql_pass}"
        MYSQL_DB = "${var.mysql_database}"
        AWS_ACCESS_KEY = "${var.aws_access_key}"
        AWS_SECRET_KEY = "${var.aws_secret_key}"
        AWS_KMS_KEY_ID = "${var.aws_kms_key_id}"
        REGION = "${var.aws_region}"
        S3_BUCKET = "${aws_s3_bucket.staticimg.id}"
        VAULT_URL = "${var.vault_dl_url}"
        VAULT_LICENSE = "${var.vault_license_key}"
        CONSUL_URL = "${var.consul_dl_url}"
        CONSUL_LICENSE = "${var.consul_license_key}"
        CONSUL_JOIN_KEY = "${var.consul_join_key}"
        CONSUL_JOIN_VALUE = "${var.consul_join_value}"
        NOMAD_URL = "${var.nomad_dl_url}"
        CTEMPLATE_URL = "${var.ctemplate_dl_url}"
        TABLE_PRODUCT = "${aws_dynamodb_table.product-data-table.id}"
        TABLE_CART = "${aws_dynamodb_table.customer-cart.id}"
        TABLE_ORDER = "${aws_dynamodb_table.customer-order-table.id}"
        BRANCH_NAME = "${var.git_branch}"
        LDAP_ADMIN_PASS = "${var.ldap_pass}"
    }
}

resource "aws_instance" "hashi-server" {
    ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "${var.instance_size}"
    key_name = "${var.key_pair}"
    vpc_security_group_ids = ["${aws_security_group.hashi-server-sg.id}"]
    user_data = "${data.template_file.hashi-server-setup.rendered}"
    subnet_id = "${aws_subnet.public-subnet.id}"
    iam_instance_profile = "${aws_iam_instance_profile.hashi-main-profile.id}"

    tags = {
        Name = "javaperks-server-${var.unit_prefix}"
        TTL = "-1"
        owner = "kcochran@hashicorp.com"
    }

    depends_on = [
        "aws_dynamodb_table.customer-order-table",
        "aws_dynamodb_table.product-data-table"
    ]
}
resource "aws_db_subnet_group" "dbsubnets" {
    name = "javaperks-db-subnet-${var.unit_prefix}"
    subnet_ids = ["${aws_subnet.private-subnet.id}", "${aws_subnet.private-subnet-2.id}"]
}


resource "aws_db_instance" "javaperks-mysql" {
    allocated_storage = 10
    storage_type = "gp2"
    engine = "mysql"
    engine_version = "5.7"
    instance_class = "db.${var.instance_size}"
    name = "javaperks${var.unit_prefix}"
    identifier = "javaperksdb${var.unit_prefix}"
    db_subnet_group_name = "${aws_db_subnet_group.dbsubnets.name}"
    vpc_security_group_ids = ["${aws_security_group.javaperks-mysql-sg.id}"]
    username = "${var.mysql_user}"
    password = "${var.mysql_pass}"
    skip_final_snapshot = true
}

resource "aws_security_group" "javaperks-mysql-sg" {
    name = "javaperks-mysql-sg-${var.unit_prefix}"
    description = "mysql security group"
    vpc_id = "${aws_vpc.primary-vpc.id}"

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "hashi-server-sg" {
    name = "javaperks-server-sg-${var.unit_prefix}"
    description = "webserver security group"
    vpc_id = "${aws_vpc.primary-vpc.id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 389
        to_port = 389
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 4646
        to_port = 4648
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 4648
        to_port = 4648
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
       from_port = 5801
       to_port = 5801
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 5821
        to_port = 5826
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8200
        to_port = 8200
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8300
        to_port = 8303
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8500
        to_port = 8500
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["10.0.0.0/16"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "aws_iam_policy_document" "hashi-assume-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "hashi-main-access-doc" {
  statement {
    sid       = "FullAccess"
    effect    = "Allow"
    resources = ["*"]

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
  }
}

resource "aws_iam_role" "hashi-main-access-role" {
  name               = "javaperks-access-role-${var.unit_prefix}"
  assume_role_policy = "${data.aws_iam_policy_document.hashi-assume-role.json}"
}

resource "aws_iam_role_policy" "hashi-main-access-policy" {
  name   = "javaperks-access-policy-${var.unit_prefix}"
  role   = "${aws_iam_role.hashi-main-access-role.id}"
  policy = "${data.aws_iam_policy_document.hashi-main-access-doc.json}"
}

resource "aws_iam_instance_profile" "hashi-main-profile" {
  name = "javaperks-access-profile-${var.unit_prefix}"
  role = "${aws_iam_role.hashi-main-access-role.name}"
}
