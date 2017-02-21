variable "vpc_id" {}

variable "database_port" { default = 3306 }

variable "database_name"    {}

variable "database_username" {}

variable "database_password" {}

variable "database_instance_class" {}

variable "database_subnet_ids" {
  type = "list"
}

variable "tag_name" {
  default     = "rancher-ha"
  description = "What to tag servers as"
}

resource "aws_db_subnet_group" "rancher_ha" {
  name        = "${var.tag_name}-db-subnet-group"
  description = "Rancher HA Subnet Group"
  subnet_ids = ["${var.database_subnet_ids}"]

  tags {
    Name = "${var.tag_name}-db-subnet-group"
  }
}

resource "aws_security_group" "rancher_ha_db_sg" {
  name = "rancher_ha_db_sg"
  description = "Allow traffic from our HA cluster"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.tag_name}-db-sg"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = "${var.database_port}"
    to_port = "${var.database_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rancherdb" {
  
  tags {
    Name = "${var.tag_name}-db_instance"
  }

  allocated_storage    = 10
  engine               = "mysql"
  instance_class       = "${var.database_instance_class}"
  name                 = "${var.database_name}"
  username             = "${var.database_username}"
  password             = "${var.database_password}"
  publicly_accessible  = false
  db_subnet_group_name = "${aws_db_subnet_group.rancher_ha.name}"
  vpc_security_group_ids = ["${aws_security_group.rancher_ha_db_sg.id}"]
}

output "endpoint" {
  value = "${aws_db_instance.rancherdb.endpoint}"
}
