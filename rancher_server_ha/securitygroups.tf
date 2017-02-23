# Into ELB from upstream
resource "aws_security_group" "rancher_ha_web_elb" {
  name = "rancher_ha_web_elb"
  description = "Allow ports rancher"
  vpc_id = "${var.vpc_id}"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Network restrictions for rancher_ha instances
resource "aws_security_group" "rancher_ha_allow_elb" {
  name = "rancher_ha_allow_elb"
  description = "Allow Connection from elb"
  vpc_id = "${var.vpc_id}"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = ["${aws_security_group.rancher_ha_web_elb.id}"]
  }

  ingress {
    from_port = 81
    to_port = 81
    protocol = "tcp"
    security_groups = ["${aws_security_group.rancher_ha_web_elb.id}"]
  }
  ingress {
    from_port = 444
    to_port = 444
    protocol = "tcp"
    security_groups = ["${aws_security_group.rancher_ha_web_elb.id}"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.rancher_ha_web_elb.id}"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = ["${aws_security_group.rancher_ha_web_elb.id}"]
  }
}

#Direct into Rancher HA instances
resource "aws_security_group" "rancher_ha_allow_internal" {
  name        = "rancher_ha_allow_internal"
  description = "Allow Connection from internal"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 81
    to_port     = 81
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 444
    to_port     = 444
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 18080
    to_port     = 18080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2376
    to_port     = 2376
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2888
    to_port     = 2888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3888
    to_port     = 3888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]    
  }

  ingress {
    from_port   = 9345
    to_port     = 9345
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_all_rancher_ha" {
  security_group_id        = "${aws_security_group.rancher_ha_allow_internal.id}"
  type                     = "ingress"
  from_port                = 0
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.rancher_ha_allow_internal.id}"
}

resource "aws_security_group_rule" "egress_all_rancher_ha" {
  security_group_id        = "${aws_security_group.rancher_ha_allow_internal.id}"
  type                     = "egress"
  from_port                = 0
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.rancher_ha_allow_internal.id}"
}
