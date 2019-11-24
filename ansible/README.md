
# Kafka Deploy Scripts
 - Terraform AWS Infra Provisioner
 - ansible/ : Ansible playbooks to configure Kafka and other related services.
 - packer/ : Packer configuration to build an AMI

# How to
 - Run the ``` terraform init ``` then plan and apply.
 - Copy and adapt the inventory from Terraform into ansible/hosts file, then run ``` ./install ```
   to configure the Cluster.
 - To install the monitoring tools, just run ``` ./setup-monitoring.sh ```

TODO :
  - Ansible Kafka-Manager (or add to the docker compose in Landoop)
  - Setup Rest Proxy in HA Mode
