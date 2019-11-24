resource "aws_route53_record" "brokers" {
  count   = "${var.broker_count}"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "b${count.index+1}.kafka.internal.${var.dns_zone}"
  type    = "A"
  ttl     = "${local.dns_ttl}"
  records = ["${element(aws_instance.broker.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "zookeepers" {
  count   = "${var.zk_count}"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "z${count.index+1}.kafka.internal.${var.dns_zone}"
  type    = "A"
  ttl     = "${local.dns_ttl}"
  records = ["${element(aws_instance.zookeeper.*.private_ip, count.index)}"]
}

resource "aws_route53_record" "bastion" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "bastion.kafka.${var.dns_zone}"
  type    = "A"
  ttl     = "${local.dns_ttl}"
  records = ["${aws_instance.bastion.public_ip}"]
}

resource "aws_route53_record" "workers" {
  count   = "${var.workers_count}"
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "c${count.index+1}.kafka.internal.${var.dns_zone}"
  type    = "A"
  ttl     = "${local.dns_ttl}"
  records = ["${element(aws_instance.worker.*.private_ip, count.index)}"]
}
