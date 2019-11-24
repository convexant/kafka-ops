output "zookeeper_private_ip" {
  description = "Internal IP for ZK"
  value       = "${aws_instance.zookeeper.*.private_ip}"
}

output "zookeeper_public_dns" {
  description = "DNS for Zookeeper "
  value       = "${aws_route53_record.zookeepers.*.name}"
}

output "broker_private_ip" {
  description = "Internal IP  Brokers"
  value       = "${aws_instance.broker.*.private_ip}"
}

output "broker_public_dns" {
  description = "DNS for Brokers "
  value       = "${aws_route53_record.brokers.*.name}"
}

output "worker_private_ip" {
  description = "Internal IP for Brokers"
  value       = "${aws_instance.worker.*.private_ip}"
}

output "worker_public_dns" {
  description = "DNS for Workers (private)"
  value       = "${aws_route53_record.workers.*.name}"
}

output "bastion_public_dns" {
  description = "DNS for Bastion (public)"
  value       = "${aws_route53_record.bastion.*.name}"
}
