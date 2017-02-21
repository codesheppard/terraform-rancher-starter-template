# AWS specific
variable "aws_region" {}

# Global Tag Name Prefix for AWS resources
variable "tag_name" {}

# Top level variables for networking/vpc.tf template
variable "aws_vpc_cidr" {}
variable "aws_public_subnet_cidrs" {}

# Top level variables for database/rds.tf template
variable "database_port" {}
variable "database_name"    {}
variable "database_username" {}
variable "database_password" {}
variable "database_instance_class" {}

# Top level variables for rancher_ha_server/*.tf templates
variable "acm_cert_domain" {}
variable "fqdn" {}
variable "instance_type" {}
variable "rancher_version" {}
variable "registration_url" {}
variable "key_name" {}
variable "ha_size" {}


# If you haven't set up awscli before then you will need to add access and secret keys
provider "aws" {
  region     = "${var.aws_region}"
#  access_key = "${var.aws_access_key}"
#  secret_key = "${var.aws_secret_key}"
}

###############################
# Network VPC Layer 
###############################
module "networking" {
  source = "./networking"

  aws_region = "${var.aws_region}"
  tag_name = "${var.tag_name}"
  aws_vpc_cidr = "${var.aws_vpc_cidr}"
  aws_public_subnet_cidrs = "${var.aws_public_subnet_cidrs}"
}

###############################
# Rancher HA Server Layer
###############################
module "database" {
 source = "./database"

 vpc_id = "${module.networking.vpc_id}"
 database_subnet_ids = [
  "${module.networking.vpc_subnet_a}",
  "${module.networking.vpc_subnet_b}",
#  "${module.networking.vpc_subnet_c}",
 ]
 database_port = "${var.database_port}"
 database_name = "${var.database_name}"
 database_username = "${var.database_username}"
 database_password = "${var.database_password}"
 database_instance_class = "${var.database_instance_class}"
}

module "rancher_server_ha" {
  source = "./rancher_server_ha"

  vpc_id = "${module.networking.vpc_id}"
  tag_name = "${var.tag_name}"

  # ssled domain without protocol e.g. moo.test.com
  acm_cert_domain = "${var.acm_cert_domain}"
  # domain with protocol e.g. https://moo.test.com
  fqdn = "${var.fqdn}"

  # ami that you created with packer
  ami = {
    us-east-1 = "ami-f05d91e6"
  }

  subnet_ids = [
    "${module.networking.vpc_subnet_a}",
    "${module.networking.vpc_subnet_b}",
#    "${module.networking.vpc_subnet_c}",
  ]

  # database variables to be passed into Rancher Server Nodes
  database_port = "${var.database_port}"
  database_name = "${var.database_name}"
  database_username = "${var.database_username}"
  database_password = "${var.database_password}"
  database_endpoint = "${module.database.endpoint}"
  instance_type = "${var.instance_type}"
  region = "${var.aws_region}"
  key_name = "${var.key_name}"
  ha_size = "${var.ha_size}"
  rancher_version = "${var.rancher_version}"
  registration_url = "${var.registration_url}"
}


###############################
# Rancher EFS Layer
###############################

###############################
# Rancher Node Layer
###############################



output "vpc_id" {
  value = "${module.networking.vpc_id}"
}

output "database_endpoint" {
  value = "${module.database.endpoint}"
}

