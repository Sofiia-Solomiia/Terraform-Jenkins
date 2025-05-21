#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y docker.io git
sudo systemctl start docker
sudo usermod -aG docker ${self.tags.Name}
sudo chmod 666 /var/run/docker.sock
docker pull sofiasolomiia/weather-page:v11
sudo docker run -d -p 80:80 sofiasolomiia/weather-page:v11
