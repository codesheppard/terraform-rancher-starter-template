# Elastic Load Balancer
resource "aws_elb" "rancher_ha" {
  name                      = "rancher-ha"
  cross_zone_load_balancing = true
  internal                  = false
  security_groups           = ["${aws_security_group.rancher_ha_web_elb.id}"]

  subnets = ["${var.subnet_ids}"]

  listener {
    instance_port      = 81
    instance_protocol  = "tcp"
    lb_port            = 443
    lb_protocol        = "ssl"
    ssl_certificate_id = "${data.aws_acm_certificate.rancher_ha_cert.arn}"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 4
    timeout             = 5

    # target = "TCP:22"
    target   = "HTTP:8080/ping"
    interval = 7
  }
}

resource "aws_proxy_protocol_policy" "rancher_ha" {
  load_balancer  = "${aws_elb.rancher_ha.name}"
  instance_ports = ["81", "444"]
}

output "elb_dns" {
  value = "${aws_elb.rancher_ha.dns_name}"
}
