variable "tag_name" {
  default = "rancherVPC"
}

variable "aws_region" {}
variable "aws_vpc_cidr" { default = "10.0.0.0/16" }
variable "aws_public_subnet_cidrs" { default  = "10.0.32.0/24,10.0.96.0/24,10.0.160.0/24" }


resource "aws_vpc" "vpc" {
  cidr_block           = "${var.aws_vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.tag_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "rancher_ha_a" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(split(",", var.aws_public_subnet_cidrs), 0)}"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.tag_name}-subnet-a"
  }
}

resource "aws_subnet" "rancher_ha_b" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(split(",", var.aws_public_subnet_cidrs), 1)}"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.tag_name}-subnet-b"
  }
}

resource "aws_subnet" "rancher_ha_c" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(split(",", var.aws_public_subnet_cidrs), 2)}"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.tag_name}-subnet-c"
  }
}

resource "aws_internet_gateway" "rancher_ha" {
  vpc_id     = "${aws_vpc.vpc.id}"
  depends_on = ["aws_vpc.vpc"]

  tags {
    Name = "${var.tag_name}-igw"
  }
}

resource "aws_route" "rancher_ha" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.rancher_ha.id}"
  depends_on             = ["aws_vpc.vpc", "aws_internet_gateway.rancher_ha"]
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "vpc_subnet_a" {
  value = "${aws_subnet.rancher_ha_a.id}"
}
output "vpc_subnet_b" {
  value = "${aws_subnet.rancher_ha_b.id}"
}
output "vpc_subnet_c" {
  value = "${aws_subnet.rancher_ha_c.id}"
}
