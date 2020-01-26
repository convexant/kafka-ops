terraform {
  backend "s3" {
    bucket   = "s3://*******"
    role_arn = "arn:aws:iam::043244355:role/terraform-operator"
    key      = "kafka/terraform.tfstate"
    region   = "eu-west-1"
    encrypt  = true
  }
}

provider "aws" {
  region  = "eu-west-2"
  version = "~> 1.10"

  assume_role {
    role_arn = "arn:aws:iam::043244355:role/terraform-operator"
  }
}

module "kafka" {
  source                = "modules/"
  cluster_name          = "Kafka Musings "
  dns_zone              = "kafka.convexant.net."
  broker_count          = 3
  broker_instance_type  = "m5.xlarge"
  broker_volume_size    = 200
  zk_count              = 3
  zk_instance_type      = "m5.large"
  zk_volume_size        = 100
  zk_iops               = 5000
  workers_count         = 3
  workers_instance_type = "m5.xlarge"
}
