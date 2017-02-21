variable "vpc_id" {}

variable "tag_name" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "ami" {
  description = "Our Packer Created AMI ID"
  type = "map"
}

variable "database_port" {}
variable "database_name"  {}
variable "database_username" {}
variable "database_password" {}
variable "database_endpoint" {}

variable "fqdn" {}
variable "acm_cert_domain" {}

# Management Server specific variables
variable "registration_url" {}
variable "rancher_version" {}
variable "instance_type" {}
variable "region" {}
variable "ha_size" {}
variable "key_name" {}
