# VPCs
data "aws_vpc" "kafka" {
  filter {
    name   = "tag:Name"
    values = ["kafka-eu-west-6"]
  }
}

# Subnets
data "aws_subnet_ids" "kafka_private" {
  vpc_id = "${data.aws_vpc.kafka.id}"

  tags {
    Tier = "Private"
  }
}

data "aws_subnet" "private" {
  count = "${length(data.aws_subnet_ids.kafka_private.ids)}"
  id    = "${data.aws_subnet_ids.kafka_private.ids[count.index]}"
}

data "aws_subnet_ids" "kafka_public" {
  vpc_id = "${data.aws_vpc.kafka.id}"

  tags {
    Tier = "Public"
  }
}

data "aws_subnet" "public" {
  count = "${length(data.aws_subnet_ids.kafka_public.ids)}"
  id    = "${data.aws_subnet_ids.kafka_public.ids[count.index]}"
}

# Security Groups
data "aws_security_groups" "storage" {
  filter {
    name = "group-name"

    values = [
      "kafka-common",
      "kafka-storage",
    ]
  }

  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.kafka.id}"]
  }
}

data "aws_security_groups" "compute" {
  filter {
    name = "group-name"

    values = [
      "kafka-common",
      "kafka-compute",
    ]
  }

  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.kafka.id}"]
  }
}

# DNS
data "aws_route53_zone" "main" {
  name = "${var.dns_zone}"
}

# Locals

locals {
  dns_ttl             = 300
  ec2_public_key_name = "kafka"
  private_subnet_azs  = ["${sort(data.aws_subnet.private.*.availability_zone)}"]

  private_subnet_ids = ["${values(zipmap(
    data.aws_subnet.private.*.availability_zone,
    data.aws_subnet.private.*.id
  ))}"]

  private_subnet_cidrs = ["${values(zipmap(
    data.aws_subnet.private.*.availability_zone,
    data.aws_subnet.private.*.cidr_block
  ))}"]

  public_subnet_azs = ["${sort(data.aws_subnet.public.*.availability_zone)}"]

  public_subnet_ids = ["${values(zipmap(
    data.aws_subnet.public.*.availability_zone,
    data.aws_subnet.public.*.id
  ))}"]

  public_subnet_cidrs = ["${values(zipmap(
    data.aws_subnet.public.*.availability_zone,
    data.aws_subnet.public.*.cidr_block
  ))}"]
}
