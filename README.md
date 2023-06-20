# Prometheus
A quick demo on Prometheus that shows its installation on a GCP ubuntu VM to monitor its resources utilization and visualize it on Garafana and fire alerts to a slack channels to notify the monitoring teams.

# Installation
```bash
git clone https://github.com/gaser98/Prometheus.git
cd <installation_dir>
bash ./Prometheus.sh
bash ./Node-Exporter.sh
bash ./Grafana.sh
```
# Access
Prometheus webui : http://<VM_external_ip>:9090

Node export      : https://<VM_external_ip>:9100

Grafana          : http://<VM_external_ip>:3000

# Slack
Create a channel on slack then build a customized new app,activate a webhook and run the given api link on the VM.

