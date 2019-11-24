# Instances
resource "aws_instance" "zookeeper" {
  count         = "${var.zk_count}"
  ami           = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.zk_instance_type}"
  key_name      = "${local.ec2_public_key_name}"

  availability_zone      = "${element(local.private_subnet_azs, count.index)}"
  subnet_id              = "${element(local.private_subnet_ids, count.index)}"
  vpc_security_group_ids = ["${data.aws_security_groups.storage.ids}"]

  associate_public_ip_address = false

  private_ip = "${cidrhost(
    element(local.private_subnet_cidrs, count.index),
    5 + count.index / length(local.private_subnet_azs)
  )}"

  tags = "${
    merge(
      var.tags,
      map(
        "Name", "kafka-zookeeper-${count.index}"
      )
    )
  }"
}

resource "aws_ebs_volume" "zk_volume" {
  count             = "${var.zk_count}"
  encrypted         = true
  type              = "io1"
  availability_zone = "${element(local.private_subnet_azs, count.index)}"
  size              = "${var.zk_volume_size}"
  iops              = "${var.zk_iops}"

  tags = "${
    merge(
      var.tags,
      map(
            "Name", "kafka-zk-ebs-${count.index}",
    "com.jobteaser.backup", "${count.index} == 0"
      )
    )
  }"
}

resource "aws_volume_attachment" "zk_volume_attachment" {
  count       = "${var.zk_count}"
  device_name = "/dev/xvdg"
  volume_id   = "${element(aws_ebs_volume.zk_volume.*.id, count.index)}"
  instance_id = "${element(aws_instance.zookeeper.*.id, count.index)}"
}

resource "aws_instance" "broker" {
  count         = "${var.broker_count}"
  ami           = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.broker_instance_type}"
  key_name      = "${local.ec2_public_key_name}"

  availability_zone      = "${element(local.private_subnet_azs, count.index)}"
  subnet_id              = "${element(local.private_subnet_ids, count.index)}"
  vpc_security_group_ids = ["${data.aws_security_groups.storage.ids}"]

  associate_public_ip_address = false

  private_ip = "${cidrhost(
    element(local.private_subnet_cidrs, count.index),
    10 + count.index / length(local.private_subnet_azs)
  )}"

  tags = "${
    merge(
      var.tags,
      map(
        "Name", "kafka-broker-${count.index}"
      )
    )
  }"
}

resource "aws_ebs_volume" "broker_volume" {
  count             = "${var.broker_count}"
  encrypted         = true
  type              = "st1"
  availability_zone = "${element(local.private_subnet_azs, count.index)}"
  size              = "${var.broker_volume_size}"

  tags = "${
    merge(
      var.tags,
      map(
        "Name", "kafka-broker-ebs-${count.index}",
        "com.jobteaser.backup", true
      )
    )
  }"
}

resource "aws_volume_attachment" "broker_volume_attachment" {
  count       = "${var.broker_count}"
  device_name = "/dev/xvdf"
  volume_id   = "${element(aws_ebs_volume.broker_volume.*.id, count.index)}"
  instance_id = "${element(aws_instance.broker.*.id, count.index)}"
}

# ONLY FOR PREPROD !!
resource "aws_ebs_volume" "zk_brokers_volume" {
  count             = "${var.zk_count < 3 ? var.broker_count - var.zk_count : 0}"
  encrypted         = true
  type              = "io1"
  availability_zone = "${element(local.private_subnet_azs, count.index + var.zk_count)}"
  size              = "${var.zk_volume_size}"
  iops              = "${var.zk_iops}"

  tags = "${
    merge(
      var.tags,
      map(
        "Name", "kafka-zk-ebs-${count.index + var.zk_count}-broker"
      )
    )
  }"
}

resource "aws_volume_attachment" "zk_brokers_volume_attachment" {
  count       = "${var.zk_count < 3 ? var.broker_count - var.zk_count : 0}"
  device_name = "/dev/xvdg"
  volume_id   = "${element(aws_ebs_volume.zk_brokers_volume.*.id, count.index)}"
  instance_id = "${element(aws_instance.broker.*.id, count.index + var.zk_count)}"
}

resource "aws_instance" "worker" {
  count         = "${var.workers_count}"
  ami           = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.workers_instance_type}"
  key_name      = "${local.ec2_public_key_name}"

  availability_zone      = "${element(local.private_subnet_azs, count.index)}"
  subnet_id              = "${element(local.private_subnet_ids, count.index)}"
  vpc_security_group_ids = ["${data.aws_security_groups.compute.ids}"]

  associate_public_ip_address = false

  tags = "${
    merge(
      var.tags,
      map(
        "Name", "kafka-worker-${count.index}"
      )
    )
  }"
}
