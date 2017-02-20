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
variable "fqdn" {}

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
  "${module.networking.vpc_subnet_c}",
 ]
 database_port = "${var.database_port}"
 database_name = "${var.database_name}"
 database_username = "${var.database_username}"
 database_password = "${var.database_password}"
 database_instance_class = "${var.database_instance_class}"
}


###############################
# Rancher EFS Layer
###############################

###############################
# Rancher Node Layer
###############################
