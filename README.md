# Java Perks Online Store

### A demonstration of HashiCorp Terraform, Vault, Consul, and Nomad

Java Perks is a ficticious wholesale company who sells equipment and supplies to coffee shops around the US. All business is conducted through their online store, so quickly responding to market trends and customer demands is critical.

To get started with this demo, copy the terraform.tfvars.example and fill in with your own information. The variables are as follows:

* `aws_access_key`: Your AWS IAM access key. This account should be able to provision any AWS resource
* `aws_secret_key`: The secret id key paired with the access key
* `aws_region`: Region to deploy the demo to. Defaults to `us-east-1`
* `aws_kms_key_id`: A KMS key is needed for Vault's auto unseal. You'll need to provide a KMS key in the specified region
* `key_pair`: This is the EC2 key pair you created in order to SSH into your EC2 instance
* `mysql_user`: Admin username for the MySQL instance. Defaults to `root`
* `mysql_pass`: Password for the MySQL admin user. Defaults to `MySecretPassword`
* `mysql_database`: Name of the database for the demo. Defaults to `javaperks`
* `instance_size`: Size of the AWS instance to run the demo on. Defaults to `t3.large`
* `consul_dl_url`: Download URL for Consul. Defaults to OSS v1.6.1
* `vault_dl_url`: Download URL for Vault. Defaults to OSS v1.2.3
* `nomad_dl_url`: Download URL for Nomad. Defaults to OSS v0.10.1
* `ctemplate_dl_url`: Download URL for Consul Template. Defaults to v0.22.0
* `consul_license_key`: License key for Consul Enterprise. Optional
* `vault_license_key`: License key for Vault Enterprise. Optional
* `unit_prefix`: A unique identifier which is appended to each resource name to avoid name clashes
* `consul_join_key`: Tag key for Consul agents locate the Consul leader
* `consul_join_value`: Tag value for Consul agents to locate the Consul leader
* `ldap_pass`: LDAP admin password. Defaults to `MySecretPassword`
* `git_branch`: Branch to use for cloning install scripts. Defaults to `master`

### Application Repos

Java Perks is comprised of 6 total applications:

Online Store (Frontend):
https://github.com/kevincloud/javaperks-online-store

Customer data API, MySQL backend:
https://github.com/kevincloud/javaperks-customer-api

Shopping cart API, DynamoDB backend:
https://github.com/kevincloud/javaperks-cart-api

Order API, DynamoDB backend:
https://github.com/kevincloud/javaperks-order-api

Product API, DynamoDB backend:
https://github.com/kevincloud/javaperks-product-api

Authentication API, Vault/LDAP backend:
https://github.com/kevincloud/javaperks-auth-api
