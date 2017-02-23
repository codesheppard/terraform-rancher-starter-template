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

# Management Server specific variables
variable "rancher_reg_url" {}
variable "rancher_agent_version" {}
variable "instance_type" {}
variable "region" {}
variable "cluster_size" {}
variable "key_name" {}
