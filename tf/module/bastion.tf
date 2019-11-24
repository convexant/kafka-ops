data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_security_groups" "common" {
  filter {
    name   = "group-name"
    values = ["bation"]
  }

  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.kafka.id}"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.bastion_instance_type}"
  associate_public_ip_address = true
  key_name                    = "${local.ec2_public_key_name}"

  availability_zone = "${element(local.public_subnet_azs, count.index)}"
  subnet_id         = "${element(local.public_subnet_ids, count.index)}"

  vpc_security_group_ids = ["${data.aws_security_groups.common.ids}"]

  volume_tags = "${
    merge(
      var.tags,
      map(
        "Name", "bastion-kafka-ebs",
        "ebs_backup", "true"
      )
    )
  }"

  tags = "${
    merge(
      var.tags,
      map(
        "Name", "bastion-kafka"
      )
    )
  }"
}
