#! /bin/bash

Colour='\033[1;31m'
less='\033[0m'

echo -e "${Colour}By using this script, you'll update the system, install the stable sion of prometheus and grafana of your choice.\nUse CTRL+C to cancel the script\n\n${less}"
read -p "Please enter a sion (e.g: 2.23.0) of Prometheus or press enter for version 2.23.0: " version_prometheus

if [[ -z "$version_prometheus" ]]; then
        version_prometheus='2.23.0'
fi

read -p "Please enter a sion (e.g: 7.3.3) of Grafana or press enter for version 7.3.3: " version_grafana

if [[ -z "$sion_prometheus" ]]; then
        version_grafana='7.3.3'
fi

echo -e "${Colour}\n\nThe system will now upgrade all the software and firmware, as well as clean up old/unused packages.\n\n${less}"
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoremove -y && sudo apt-get autoclean -y

echo -e "${Colour}\n\nPrometheus with version $version_prometheus is downloading now.\n\n${less}"
wget https://github.com/prometheus/prometheus/releases/download/v$version_prometheus/prometheus-$version_prometheus.linux-armv7.tar.gz

echo -e "${Colour}\nPrometheus will now be installed to /home/pi/prometheus.\n\n${less}"
tar zxf prometheus-$version_prometheus.linux-armv7.tar.gz
rm prometheus-$version_prometheus.linux-armv7.tar.gz
mv prometheus-$version_prometheus.linux-armv7/ prometheus/

echo -e "Create systemd service Prometheus"
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Ser
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=pi
Restart=on-failure

ExecStart=/home/pi/prometheus/prometheus \
  --config.file=/home/pi/prometheus/prometheus.yml \
  --storage.tsdb.path=/home/pi/prometheus/data

[Install]
WantedBy=multi-user.target
EOF

echo -e "${Colour}\n\nGrafana with version $version_grafana is downloading now.\n\n${less}"
wget https://dl.grafana.com/oss/release/grafana-$version_grafana.linux-armv7.tar.gz

echo -e "${Colour}\nGrafana will now be installed to /home/pi/grafana.\n\n${less}"
tar zxf grafana-$version_grafana.linux-armv7.tar.gz
rm grafana-$version_grafana.linux-armv7.tar.gz
mv grafana-$version_grafana grafana/

echo -e "Create systemd service Grafana"
cat <<EOF | sudo tee /etc/systemd/system/grafana.service
[Unit]
Description=Grafana Server
After=network.target

[Service]
Type=simple
User=pi
ExecStart=/home/pi/grafana/bin/grafana-server
WorkingDirectory=/home/pi/grafana/
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo -e "${Colour}\n\nReload systemctl daemon\n${less}"
sudo systemctl daemon-reload

echo -e "${Colour}\n\nEnable and start Prometheus service\n${less}"
sudo systemctl enable prometheus
sudo systemctl start prometheus

echo -e "${Colour}\n\nEnable and start Grafana service.\n${less}"
sudo systemctl enable grafana
sudo systemctl start grafana



echo -e "${Colour}\n\nNow browse to your raspberry on port 3000.\n${less}"
echo -e "${Colour}Default user/pw is admin/admin.\n${less}"
