#!/bin/bash
apt-get update
apt-get install -y docker.io docker-compose

mkdir /opt/monitoring
cd /opt/monitoring

cat <<EOF > docker-compose.yml
version: '3'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
EOF

cat <<EOF > prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'jenkins-node'
    static_configs:
      - targets: ['${aws_instance.jenkins.private_ip}:9100']
EOF

docker-compose up -d
