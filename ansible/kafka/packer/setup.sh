#! /bin/bash -e
unset HISTFILE
history -cw

echo ===> Waiting for EC2 Instance boot
timeout 180 /bin/bash -c 'until stat /var/lib/cloud/instance/boot-finished &>/dev/null; do echo waiting...; sleep 6; done'

echo === Configuring System Settings ===
echo 'dash dash/sh boolean false' | sudo debconf-set-selections
sudo dpkg-reconfigure -f noninteractive dash
sudo update-locale LC_CTYPE=en_US.UTF-8
echo 'export TZ=:/etc/localtime' | sudo tee /etc/profile.d/tz.sh > /dev/null

echo ===> Set proper permissions on copied scripts
sudo mv /tmp/80-ec2-nvme-devices.rules /etc/udev/rules.d/80-ec2-nvme-devices.rules
sudo mv /tmp/ebsnvme-id /sbin/ebsnvme-id
sudo chmod +x /sbin/ebsnvme-id

echo ===> Install Some utilities
sudo apt-get update
sudo apt-get install -y software-properties-common debconf-utils
sudo apt-get install -y ca-certificates apt-transport-https
sudo apt-get update
sudo apt-get install -y ssl-cert
sudo apt-get install -y python-dev python-simplejson python-setuptools curl htop python-pip unzip screen
sudo apt-get install -y tar bzip2


echo ==> Installing Oracle Java 8
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo 'oracle-java8-installer shared/accepted-oracle-license-v1-1 select true' | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer


echo ===> Installing Confluent OSS
wget -qO - https://packages.confluent.io/deb/5.0/archive.key | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.0 stable main"
sudo apt-get update -y -qq && sudo apt-get install confluent-platform-oss-2.11 -y -qq

echo ===> Download Debezium Connector Plugins for Mysql and Postgres
sudo mkdir /opt/dbz
sudo wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/0.8.3.Final/debezium-connector-mysql-0.8.3.Final-plugin.tar.gz -P /opt/dbz
sudo wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/0.8.3.Final/debezium-connector-postgres-0.8.3.Final-plugin.tar.gz -P /opt/dbz
sudo tar -xf /opt/dbz/debezium-connector-postgres-0.8.3.Final-plugin.tar.gz -C /usr/share/java
sudo tar -xf /opt/dbz/debezium-connector-mysql-0.8.3.Final-plugin.tar.gz -C /usr/share/java

echo === System Cleanup ===
sudo apt-get -y -qq --purge autoremove
sudo apt-get autoclean
sudo apt-get clean
sudo rm -f /root/.bash_history
sudo rm -f /home/ubuntu/.bash_history
sudo rm -f /var/log/wtmp
sudo rm -f /var/log/btmp
sudo rm -rf /var/log/installer
sudo rm -rf /var/lib/cloud/instances
sudo rm -rf /tmp/* /var/tmp/* /tmp/.*-unix
sudo find /var/cache -type f -delete
sudo find /var/log -type f | while read f; do echo -n '' | sudo tee $f > /dev/null; done;
sudo find /var/lib/apt/lists -not -name lock -type f -delete
sudo sync
sudo apt-get update
