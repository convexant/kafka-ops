variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_amis" {
  default = {
    # ami-name dev-confluent-common-ami
    "eu-west-1" = "ami-05f3e760ec4740cf4"
  }
}

variable "cluster_name" {}

variable "dns_zone" {}

# Brokers
variable "broker_count" {}

variable "broker_instance_type" {}
variable "broker_volume_size" {}

# Zookeeper
variable "zk_count" {}

variable "zk_instance_type" {}
variable "zk_volume_size" {}
variable "zk_iops" {}

# Confluent workers variables
variable "workers_count" {}

variable "workers_instance_type" {}

variable "bastion_instance_type" {
  default = "t3.nano"
}

variable "tags" {
  description = "Tags added for resources created by this module"
  type        = "map"

  default = {
    "terraformed" = "true"
  }
}
