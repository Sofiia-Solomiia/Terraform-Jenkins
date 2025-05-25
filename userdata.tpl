#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y docker.io git
sudo systemctl start docker
sudo usermod -aG docker ${self.tags.Name}
sudo chmod 666 /var/run/docker.sock
docker pull sofiasolomiia/weather-page:v11
sudo docker run -d -p 80:80 sofiasolomiia/weather-page:v11

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

cat <<EOF | sudo tee /monitoring/prometheus.yml
# my global config
global:
  scrape_interval: 15s
  evaluation_interval: 120s

external_labels:
  monitor: 'my-project'
# Load and evaluate rules in this file every 'evaluation_interval' seconds.
rule_files:
  # - "alert.rules"
  # - "first.rules"
  # - "second.rules"

scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 120s
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
      - targets: ['localhost:9090', 'cadvisor:8080', 'node-exporter:9100', 'nginx-exporter:9113']

EOF

# Сервіс Node Exporter
cat <<EOF | sudo tee /monitoring/docker-compose.yml
version: '3'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: monitoring_prometheus
    restart: unless-stopped
    volumes:
      - ./data/prometheus/config:/etc/prometheus/
      - ./data/prometheus/data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'

    ports:
      - 9090:9090
    links:
      - cadvisor:cadvisor
      - node-exporter:node-exporter
      - nginx-exporter:nginx-exporter

  node-exporter:
    image: prom/node-exporter:latest
    container_name: monitoring_node_exporter
    restart: unless-stopped
    expose:
      - 9100
  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:latest
    container_name: nginx-exporter
    ports:
      - "9113:9113"
    command: ["-nginx.scrape-uri", "http://nginx:80/stub_status"]

  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    container_name: monitoring_cadvisor
    restart: unless-stopped
    privileged: true
    command: ["/usr/bin/cadvisor", "--cgroupv2"]
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    expose:
      - 8080

  grafana:
    image: grafana/grafana:latest
    container_name: monitoring_grafana
    restart: unless-stopped
    links:
      - prometheus:prometheus
    volumes:
      - ./data/grafana:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
      - GF_SERVER_DOMAIN=myrul.com
      - GF_SMTP_ENABLED=true
      - GF_SMTP_HOST=smtp.gmail.com:587
      - GF_SMTP_USER=myadrress@gmail.com
      - GF_SMTP_PASSWORD=mypassword
      - GF_SMTP_FROM_ADDRESS=myaddress@gmail.com
    ports:
      - 3000:3000
EOF

sudo docker compose up -d
