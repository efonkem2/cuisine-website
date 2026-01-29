#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install essential packages
apt-get install -y curl wget unzip git

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create directories for persistent data
mkdir -p /opt/prometheus/data
mkdir -p /opt/grafana/data
mkdir -p /opt/alertmanager/data

# Set proper ownership for Grafana
chown -R 472:472 /opt/grafana

# Create Prometheus configuration
mkdir -p /opt/prometheus/config

cat > /opt/prometheus/config/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  # Add your application targets here
  # - job_name: 'your-app'
  #   static_configs:
  #     - targets: ['app-server:8080']
EOF

# Create Alertmanager configuration
mkdir -p /opt/alertmanager/config

cat > /opt/alertmanager/config/alertmanager.yml << 'EOF'
global:
  smtp_smarthost: 'localhost:587'
  smtp_from: 'alerts@yourdomain.com'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://127.0.0.1:5001/'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF

# Create Docker Compose file for monitoring stack
cat > /opt/docker-compose.yml << 'EOF'
version: '3.8'

networks:
  monitoring:
    driver: bridge

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
      - '--storage.tsdb.retention.time=30d'
    volumes:
      - /opt/prometheus/config:/etc/prometheus
      - /opt/prometheus/data:/prometheus
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
    volumes:
      - /opt/grafana/data:/var/lib/grafana
    networks:
      - monitoring
    depends_on:
      - prometheus

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    ports:
      - "9100:9100"
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    networks:
      - monitoring

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - monitoring

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    restart: unless-stopped
    ports:
      - "9093:9093"
    volumes:
      - /opt/alertmanager/config:/etc/alertmanager
      - /opt/alertmanager/data:/alertmanager
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    networks:
      - monitoring
EOF

# Start monitoring stack
cd /opt
docker-compose up -d

# Wait for services to start
sleep 30

# Create Grafana dashboards import script
cat > /opt/setup-dashboards.sh << 'EOF'
#!/bin/bash

# Wait for Grafana to be ready
until curl -s http://localhost:3000/api/health > /dev/null; do
    echo "Waiting for Grafana to be ready..."
    sleep 5
done

# Add Prometheus as data source
curl -X POST \
  http://admin:admin123@localhost:3000/api/datasources \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "basicAuth": false,
    "isDefault": true
  }'

# Import Node Exporter dashboard
curl -X POST \
  http://admin:admin123@localhost:3000/api/dashboards/import \
  -H 'Content-Type: application/json' \
  -d '{
    "dashboard": {
      "id": null,
      "title": "Node Exporter Full",
      "tags": ["node-exporter"],
      "timezone": "browser",
      "panels": [],
      "time": {"from": "now-1h", "to": "now"},
      "timepicker": {},
      "templating": {"list": []},
      "annotations": {"list": []},
      "refresh": "30s",
      "schemaVersion": 16,
      "version": 0,
      "links": []
    },
    "overwrite": false,
    "inputs": [
      {
        "name": "DS_PROMETHEUS",
        "type": "datasource",
        "pluginId": "prometheus",
        "value": "Prometheus"
      }
    ]
  }'

echo "Grafana setup completed!"
EOF

chmod +x /opt/setup-dashboards.sh

# Run the dashboard setup
/opt/setup-dashboards.sh

# Create monitoring management script
cat > /opt/manage-monitoring.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        echo "Starting monitoring stack..."
        cd /opt && docker-compose up -d
        ;;
    stop)
        echo "Stopping monitoring stack..."
        cd /opt && docker-compose down
        ;;
    restart)
        echo "Restarting monitoring stack..."
        cd /opt && docker-compose restart
        ;;
    status)
        echo "=== Monitoring Stack Status ==="
        docker-compose -f /opt/docker-compose.yml ps
        echo ""
        echo "=== Service URLs ==="
        echo "Prometheus: http://$(curl -s ifconfig.me):9090"
        echo "Grafana: http://$(curl -s ifconfig.me):3000 (admin/admin123)"
        echo "AlertManager: http://$(curl -s ifconfig.me):9093"
        echo "Node Exporter: http://$(curl -s ifconfig.me):9100"
        echo "cAdvisor: http://$(curl -s ifconfig.me):8080"
        ;;
    logs)
        if [ -z "$2" ]; then
            echo "Usage: $0 logs [prometheus|grafana|alertmanager|node-exporter|cadvisor]"
        else
            docker logs "$2" -f
        fi
        ;;
    setup-dashboards)
        /opt/setup-dashboards.sh
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|setup-dashboards}"
        exit 1
        ;;
esac
EOF

chmod +x /opt/manage-monitoring.sh

# Create system service for auto-start
cat > /etc/systemd/system/monitoring-stack.service << 'EOF'
[Unit]
Description=Monitoring Stack (Prometheus, Grafana, etc.)
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
WorkingDirectory=/opt
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down

[Install]
WantedBy=multi-user.target
EOF

systemctl enable monitoring-stack.service

# Create README for user
cat > /home/ubuntu/README-MONITORING.txt << 'EOF'
Monitoring Stack Setup Complete!

Services:
- Prometheus: http://YOUR-SERVER-IP:9090
- Grafana: http://YOUR-SERVER-IP:3000 (admin/admin123)
- AlertManager: http://YOUR-SERVER-IP:9093
- Node Exporter: http://YOUR-SERVER-IP:9100
- cAdvisor: http://YOUR-SERVER-IP:8080

Default Credentials:
- Grafana: admin / admin123

Management Commands:
- Check status: /opt/manage-monitoring.sh status
- Start services: /opt/manage-monitoring.sh start
- Stop services: /opt/manage-monitoring.sh stop
- Restart services: /opt/manage-monitoring.sh restart
- View logs: /opt/manage-monitoring.sh logs [service-name]
- Setup dashboards: /opt/manage-monitoring.sh setup-dashboards

Configuration Files:
- Docker Compose: /opt/docker-compose.yml
- Prometheus config: /opt/prometheus/config/prometheus.yml
- AlertManager config: /opt/alertmanager/config/alertmanager.yml

Data Directories:
- Prometheus data: /opt/prometheus/data/
- Grafana data: /opt/grafana/data/
- AlertManager data: /opt/alertmanager/data/

To add monitoring targets:
1. Edit /opt/prometheus/config/prometheus.yml
2. Add your targets to the scrape_configs section
3. Restart Prometheus: docker restart prometheus

Popular Grafana Dashboard IDs to import:
- Node Exporter Full: 1860
- Docker and system monitoring: 893
- Prometheus Stats: 2
EOF

chown ubuntu:ubuntu /home/ubuntu/README-MONITORING.txt

echo "Monitoring stack setup completed at $(date)" > /var/log/monitoring-setup.log