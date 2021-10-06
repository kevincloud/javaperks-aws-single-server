variable "region" {
    description = "AWS Region"
    default = "us-east-1"
}

variable "aws_kms_key_id" {
    description = "AWS KMS Key for Unsealing"
}

variable "key_pair" {
    description = "Key pair used to login to the instance"
}

variable "mysql_user" {
    description = "Root user name for the MySQL server backend for Vault"
    default = "root"
}

variable "mysql_pass" {
    description = "Root user password for the MySQL server backend for Vault"
    default = "MySecretPassword"
}

variable "mysql_database" {
    description = "Name of database for Java Perks"
    default = "javaperks"
}

variable "instance_size" {
    description = "Size of instance for most servers"
    default = "t3.large"
}

variable "consul_license_key" {
    description = "License key for Consul Enterprise"
}

variable "vault_license_key" {
    description = "License key for Vault Enterprise"
}

variable "nomad_license_key" {
    description = "License key for Vault Enterprise"
}

variable "unit_prefix" {
    description = "Prefix for each resource to be created"
}

variable "consul_join_key" {
    description = "Key for joining Consul"
}

variable "consul_join_value" {
    description = "value for the join key"
}

variable "ldap_pass" {
    description = "Admin password for the OpenLDAP server"
    default = "MySecretPassword"
}

variable "git_branch" {
    description = "Branch used for this instance"
    default = "main"
}

variable "owner" {
    description = ""
}

variable "se-region" {
    description = ""
}

variable "purpose" {
    description = ""
}

variable "ttl" {
    description = ""
}

variable "terraform" {
    description = ""
}