# User-data template
data "template_file" "user_data" {

    template = "${file("${path.module}/files/userdata.template")}"

    vars {
      rancher_agent_version = "${var.rancher_agent_version}"
      rancher_reg_url  = "${var.rancher_reg_url}"
      ip-addr           = "local-ipv4"
    }
}

# rancher resource
resource "aws_launch_configuration" "rancher_node" {
  name_prefix = "Launch-Config-rancher-server-ha"
  image_id    = "${lookup(var.ami, var.region)}"

  security_groups = [
    "${aws_security_group.rancher_ha_allow_internal.id}",
  ]

  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  user_data                   = "${data.template_file.user_data.rendered}"
  associate_public_ip_address = false
  ebs_optimized               = false
}

resource "aws_autoscaling_group" "rancher_node" {
  name                      = "${var.tag_name}-asg"
  min_size                  = "${var.cluster_size}"
  max_size                  = "${var.cluster_size}"
  desired_capacity          = "${var.cluster_size}"
  health_check_grace_period = 900
  health_check_type         = "EC2"
  force_delete              = false
  launch_configuration      = "${aws_launch_configuration.rancher_node.name}"
  vpc_zone_identifier       = ["${var.subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "${var.tag_name}"
    propagate_at_launch = true
  }
}


output "asg_name" {
  value = "${aws_autoscaling_group.rancher_node.name}"
}

output "asg_id" {
  value = "${aws_autoscaling_group.rancher_node.id}"
}

output "userdata" {
  value = "${data.template_file.user_data.rendered}"
}
