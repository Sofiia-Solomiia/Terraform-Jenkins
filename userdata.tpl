#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y docker.io git
sudo systemctl start docker
sudo usermod -aG docker ${self.tags.Name}
sudo chmod 666 /var/run/docker.sock

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create directory structure
mkdir -p /opt/monitoring/data/prometheus/config
mkdir -p /opt/monitoring/data/prometheus/data
mkdir -p /opt/monitoring/data/grafana
mkdir -p /opt/monitoring/data/nginx

# Create nginx.conf
cat <<EOF > /opt/monitoring/data/nginx/nginx.conf
events {}

http {
    server {
        listen 80;

        location / {
            proxy_pass http://weather-page:80;
        }

        location /stub_status {
            stub_status;
            allow 127.0.0.1;
            allow all;
        }
    }
}
EOF

# Create Prometheus config
cat <<EOF > /opt/monitoring/data/prometheus/config/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx-exporter:9113']
EOF

# Create docker-compose.yml
cat <<EOF > /opt/monitoring/docker-compose.yml
version: '3'

services:
  nginx:
    image: nginx:latest
    container_name: weather_nginx
    restart: unless-stopped
    ports:
      - 80:80
    volumes:
      - ./data/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - weather-page

  weather-page:
    image: sofiasolomiia/weather-page:v11
    container_name: weather_page
    restart: unless-stopped
    expose:
      - "80"

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

  node-exporter:
    image: prom/node-exporter:latest
    container_name: monitoring_node_exporter
    restart: unless-stopped
    expose:
      - 9100

  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:latest
    container_name: nginx_exporter
    restart: unless-stopped
    ports:
      - "9113:9113"
    command: [
      "-nginx.scrape-uri", "http://nginx/stub_status"
    ]
    depends_on:
      - nginx

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
    volumes:
      - ./data/grafana:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - 3000:3000
EOF

# Change directory and start the stack
cd /opt/monitoring
sudo docker-compose up -d
