variable "aws_access_key" {
    description = "AWS Access Key"
}

variable "aws_secret_key" {
    description = "AWS Secret Key"
}

variable "aws_session_token" {
    description = "AWS Session Token"
}

variable "aws_region" {
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

variable "consul_dl_url" {
    description = "URL for downloading Consul"
    default = "https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip"
}

variable "vault_dl_url" {
    description = "URL for downloading Vault"
    default = "https://releases.hashicorp.com/vault/1.2.3/vault_1.2.3_linux_amd64.zip"
}

variable "nomad_dl_url" {
    description = "URL for downloading Nomad"
    default = "https://releases.hashicorp.com/nomad/0.10.1/nomad_0.10.1_linux_amd64.zip"
}

variable "ctemplate_dl_url" {
    description = "URL for downloading Consul Template"
    default = "https://releases.hashicorp.com/consul-template/0.22.0/consul-template_0.22.0_linux_amd64.zip"
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
    default = "master"
}

variable "owner" {
    description = ""
}

variable "hc_region" {
    description = ""
}

variable "purpose" {
    description = ""
}

variable "ttl" {
    description = ""
}
