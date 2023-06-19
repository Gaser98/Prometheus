sudo useradd --no-create-home --shell /bin/false node_exporter
sudo apt update
sudo apt install apache2-utils -y
cd /tmp/
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.3.1.linux-amd64.tar.gz
cd node_exporter-1.3.1.linux-amd64
sudo mv node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
mkdir ~/NodeExporter-cert-key
cd ~/NodeExporter-cert-key
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout node_exporter.key -out node_exporter.crt -subj "/C=US/ST=California/L=Oakland/O=MyOrg/CN=localhost" -addext "subjectAltName = DNS:localhost"
sudo mkdir /etc/node_exporter
sudo cp node_exporter.* /etc/node_exporter

sudo bash -c "echo -e \"tls_server_config: \n\
  cert_file: node_exporter.crt
  key_file: node_exporter.key\" > /etc/node_exporter/config.yml"

sudo chown -R node_exporter:node_exporter /etc/node_exporter

#Creating a systemd unit file for the the NodeExporter to run it as a service
sudo bash -c "echo -e \"[Unit] \n\
Description=Node Exporter \n\
After=network-online.target \n\
\n\
[Service] \n\
User=node_exporter \n\
Group=node_exporter \n\
Type=simple \n\
ExecStart=/usr/local/bin/node_exporter --web.config=/etc/node_exporter/config.yml \n\
\n\
[Install] \n\
WantedBy=multi-user.target \" > /etc/systemd/system/node_exporter.service"

#Remove the spaces after the \ in each line in the unit file
sudo sed -i 's/[[:space:]]*$//' /etc/systemd/system/node_exporter.service

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
sudo cp node_exporter.crt /etc/prometheus/
sudo chown prometheus:prometheus /etc/prometheus/node_exporter.crt

#use the command htpasswd -nBC 10 "" | tr -d ':\n'; echo to enter your new password and the hashed password will be printed on the screen
#then sudo vi  /etc/node_exporter/config.yml  and add the next lines
#basic_auth_users:
#  prometheus: <htpasswd command output>

sudo bash -c "echo -e \"  - job_name: "nodes" \n\
    scheme: https \n\
    tls_config: \n\
         ca_file: /etc/prometheus/node_exporter.crt \n\
         insecure_skip_verify: true \n\
#    basic_auth: \n\
#         username: prometheus \n\
#         password: #Password you entered in htpasswd command as plain text not HASHED \n\
    static_configs: \n\
       - targets: ["localhost:9100"]\" >> /etc/prometheus/prometheus.yml"
      
#Remove the spaces after the \ in each line in the unit file
sudo sed -i 's/[[:space:]]*$//' /etc/prometheus/prometheus.yml

sudo systemctl restart prometheus
sudo systemctl restart node_exporter
sudo systemctl status node_exporter
$SHELL
