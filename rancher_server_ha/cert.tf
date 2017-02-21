data "aws_acm_certificate" "rancher_ha_cert" {
  domain = "${var.acm_cert_domain}"
  statuses = ["ISSUED"]
}

# Or if you need your own certificate.
# resource "aws_iam_server_certificate" "rancher_ha"
#  {
#   name             = "rancher-ha-cert-ae"
#   certificate_body = "${file("${var.rancher_ssl_cert}")}"
#   private_key      = "${file("${var.rancher_ssl_key}")}"
#   certificate_chain = "${file("${var.rancher_ssl_chain}")}"

#   provisioner "local-exec" {
#     command = <<EOF
#       echo "Sleep 10 secends so that the cert is propagated by aws iam service"
#       echo "See https://github.com/hashicorp/terraform/issues/2499 (terraform ~v0.6.1)"
#       sleep 10
# EOF
#   }
# }
