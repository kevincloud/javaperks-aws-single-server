variable "aws_access_key" {
    description = "AWS Access Key"
}

variable "aws_secret_key" {
    description = "AWS Secret Key"
}

variable "aws_region" {
    description = "AWS Region"
}

variable "aws_kms_key_id" {
    description = "AWS KMS Key for Unsealing"
}

variable "key_pair" {
    description = "Key pair used to login to the instance"
}

variable "mysql_user" {
    description = "Root user name for the MySQL server backend for Vault"
}

variable "mysql_pass" {
    description = "Root user password for the MySQL server backend for Vault"
}

variable "mysql_database" {
    description = "Name of database for Java Perks"
}

variable "instance_size" {
    description = "Size of instance for most servers"
}

variable "consul_dl_url" {
    description = "URL for downloading Consul"
}

variable "vault_dl_url" {
    description = "URL for downloading Vault"
}

variable "nomad_dl_url" {
    description = "URL for downloading Nomad"
}

variable "ctemplate_dl_url" {
    description = "URL for downloading Consul Template"
}

variable "consul_license_key" {
    description = "License key for Consul Enterprise"
}

variable "vault_license_key" {
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

variable "git_branch" {
    description = "Branch used for this instance"
    default = "master"
}