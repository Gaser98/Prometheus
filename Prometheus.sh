#!/bin/bash
sudo apt-get update

#Installing Docker comment if you don't need it 
#If you are running a GCP Ubuntu VM uncomment the following lines and comment the 5 lines prior the dash line
# sudo apt update
# sudo apt install --yes apt-transport-https ca-certificates curl gnupg2 software-properties-common
# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
# sudo apt update
# sudo apt install --yes docker-ce
#-----------------------------------------------------------------------
Installing Docker comment if you don't need it 
sudo apt-get install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

#Installing Node.js & NPM comment if you don't need it 
 sudo apt install nodejs -y
 sudo apt install npm -y

#Prometheus installation
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
cd /tmp/
wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz
tar -xvf prometheus-2.35.0.linux-amd64.tar.gz
cd prometheus-2.35.0.linux-amd64
sudo mv console* /etc/prometheus
sudo mv prometheus.yml /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

#Creating a systemd unit file for the prometheus to run it as a service
sudo bash -c "echo -e \"[Unit] \n\
Description=Prometheus \n\
Wants=network-online.target \n\
After=network-online.target \n\
\n\
[Service] \n\
User=prometheus \n\
Group=prometheus \n\
Type=simple \n\
ExecStart=/usr/local/bin/prometheus \ \n\
--config.file /etc/prometheus/prometheus.yml \ \n\
--storage.tsdb.path /var/lib/prometheus/ \ \n\
--web.console.templates=/etc/prometheus/consoles \ \n\
--web.console.libraries=/etc/prometheus/console_libraries \n\
\n\
[Install] \n\
WantedBy=multi-user.target \" > /etc/systemd/system/prometheus.service"

#Remove the spaces after the \ in each line in the unit file
sudo sed -i 's/[[:space:]]*$//' /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus
sudo systemctl status prometheus
$SHELL
