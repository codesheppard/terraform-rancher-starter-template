# User-data template
data "template_file" "user_data" {

    template = "${file("${path.module}/files/userdata.template")}"

    vars {
      cluster_size      = "${var.ha_size}"
      database_endpoint = "${var.database_endpoint}"
      database_username = "${var.database_username}"
      database_password = "${var.database_password}"
      database_name     = "${var.database_name}"
      registration_url  = "${var.registration_url}"
      rancher_version   = "${var.rancher_version}"
      ip-addr           = "local-ipv4"
    }
}

# rancher resource
resource "aws_launch_configuration" "rancher_ha" {
  name_prefix = "Launch-Config-rancher-server-ha"
  image_id    = "${lookup(var.ami, var.region)}"

  security_groups = [
    "${aws_security_group.rancher_ha_allow_elb.id}",
    "${aws_security_group.rancher_ha_web_elb.id}",
    "${aws_security_group.rancher_ha_allow_internal.id}",
  ]

  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  user_data                   = "${data.template_file.user_data.rendered}"
  associate_public_ip_address = false
  ebs_optimized               = false
}

resource "aws_autoscaling_group" "rancher_ha" {
  name                      = "${var.tag_name}-asg"
  min_size                  = "${var.ha_size}"
  max_size                  = "${var.ha_size}"
  desired_capacity          = "${var.ha_size}"
  health_check_grace_period = 900
  health_check_type         = "ELB"
  force_delete              = false
  launch_configuration      = "${aws_launch_configuration.rancher_ha.name}"
  load_balancers            = ["${aws_elb.rancher_ha.name}"]
  vpc_zone_identifier       = ["${var.subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.tag_name}"
    propagate_at_launch = true
  }
}


# output "asg_name" {
#   value = "${module.asg.name}"
# }

# output "asg_id" {
#   value = "${module.asg.id}"
# }

output "userdata" {
  value = "${data.template_file.user_data.rendered}"
}
