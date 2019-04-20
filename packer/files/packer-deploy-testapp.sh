#!/bin/bash

# Upgrade
apt update && apt -y upgrade

# Install Ruby
apt -y install ruby-full ruby-bundler build-essential

# Install Mongodb
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
apt update
apt -y install mongodb-org
systemctl start mongod.service
systemctl enable mongod.service

# Deploy testapp
mkdir /opt/testapp
cd /opt/testapp
git clone -b monolith https://github.com/express42/reddit.git
cd reddit
bundle install
useradd puma
chown -R puma.puma /opt/testapp

# Create systemd unit for testapp and enable his
echo "[Unit]" > /etc/systemd/system/testapp.service
echo "Description=TestApp Unit" >> /etc/systemd/system/testapp.service
echo "" >> /etc/systemd/system/testapp.service
echo "[Service]" >> /etc/systemd/system/testapp.service
echo "ExecStart=/bin/su puma -c \"cd /opt/testapp/reddit && puma -d\"" >> /etc/systemd/system/testapp.service
echo "" >> /etc/systemd/system/testapp.service
echo "[Install]" >> /etc/systemd/system/testapp.service
echo "WantedBy=default.target" >> /etc/systemd/system/testapp.service
echo "" >> /etc/systemd/system/testapp.service
systemctl enable testapp.service
