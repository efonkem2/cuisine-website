#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install essential packages
apt-get install -y curl wget unzip git openjdk-11-jdk

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /etc/environment
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create directories
mkdir -p /opt/nexus-data
mkdir -p /opt/sonarqube/data
mkdir -p /opt/sonarqube/logs
mkdir -p /opt/sonarqube/extensions

# Set proper ownership
chown -R 200:200 /opt/nexus-data
chown -R 999:999 /opt/sonarqube

# Create Docker Compose file for Nexus and SonarQube
cat > /opt/docker-compose.yml << 'EOF'
version: '3.8'

services:
  nexus:
    image: sonatype/nexus3:latest
    container_name: nexus
    restart: unless-stopped
    ports:
      - "8081:8081"
    volumes:
      - /opt/nexus-data:/nexus-data
    environment:
      - NEXUS_SECURITY_RANDOMPASSWORD=false
    ulimits:
      nofile:
        soft: 65536
        hard: 65536

  postgres:
    image: postgres:13
    container_name: sonarqube-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: sonar
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
    volumes:
      - postgres_data:/var/lib/postgresql/data

  sonarqube:
    image: sonarqube:community
    container_name: sonarqube
    restart: unless-stopped
    depends_on:
      - postgres
    ports:
      - "9000:9000"
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://postgres:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    volumes:
      - /opt/sonarqube/data:/opt/sonarqube/data
      - /opt/sonarqube/logs:/opt/sonarqube/logs
      - /opt/sonarqube/extensions:/opt/sonarqube/extensions
    ulimits:
      nofile:
        soft: 131072
        hard: 131072

volumes:
  postgres_data:
EOF

# Configure system settings for SonarQube
echo 'vm.max_map_count=524288' >> /etc/sysctl.conf
echo 'fs.file-max=131072' >> /etc/sysctl.conf
sysctl -p

# Add limits for SonarQube user
echo 'sonarqube   -   nofile   131072' >> /etc/security/limits.conf
echo 'sonarqube   -   nproc    8192' >> /etc/security/limits.conf

# Start services using Docker Compose
cd /opt
docker-compose up -d

# Wait for services to be ready and create initial admin user scripts
sleep 60

# Create Nexus setup script
cat > /opt/nexus-setup.sh << 'EOF'
#!/bin/bash
echo "Nexus Repository Manager is starting..."
echo "Default credentials:"
echo "Username: admin"
echo "Password: Check /opt/nexus-data/admin.password for initial password"
echo ""
echo "Access Nexus at: http://$(curl -s ifconfig.me):8081"
echo ""
echo "Docker Registry Setup:"
echo "1. Login to Nexus web interface"
echo "2. Go to Administration > Repository > Repositories"
echo "3. Create Docker (hosted) repository named 'docker-hosted'"
echo "4. Enable Docker Bearer Token Realm in Security > Realms"
echo "5. Docker registry will be available at: $(curl -s ifconfig.me):8081/repository/docker-hosted/"
EOF

chmod +x /opt/nexus-setup.sh

# Create SonarQube setup script
cat > /opt/sonarqube-setup.sh << 'EOF'
#!/bin/bash
echo "SonarQube is starting..."
echo "Default credentials:"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "Access SonarQube at: http://$(curl -s ifconfig.me):9000"
echo ""
echo "Change the default password after first login!"
EOF

chmod +x /opt/sonarqube-setup.sh

# Create status check script
cat > /opt/status.sh << 'EOF'
#!/bin/bash
echo "=== Service Status ==="
docker-compose -f /opt/docker-compose.yml ps
echo ""
echo "=== Nexus Repository ==="
echo "URL: http://$(curl -s ifconfig.me):8081"
echo "Initial admin password location: /opt/nexus-data/admin.password"
echo ""
echo "=== SonarQube ==="
echo "URL: http://$(curl -s ifconfig.me):9000"
echo "Default credentials: admin/admin"
echo ""
echo "=== Logs ==="
echo "Nexus logs: docker logs nexus"
echo "SonarQube logs: docker logs sonarqube"
EOF

chmod +x /opt/status.sh

# Create service management script
cat > /opt/manage-services.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        echo "Starting Nexus and SonarQube..."
        cd /opt && docker-compose up -d
        ;;
    stop)
        echo "Stopping Nexus and SonarQube..."
        cd /opt && docker-compose down
        ;;
    restart)
        echo "Restarting Nexus and SonarQube..."
        cd /opt && docker-compose restart
        ;;
    status)
        /opt/status.sh
        ;;
    logs)
        if [ -z "$2" ]; then
            echo "Usage: $0 logs [nexus|sonarqube]"
        else
            docker logs "$2" -f
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        exit 1
        ;;
esac
EOF

chmod +x /opt/manage-services.sh

# Create system service for auto-start
cat > /etc/systemd/system/devops-tools.service << 'EOF'
[Unit]
Description=DevOps Tools (Nexus and SonarQube)
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

systemctl enable devops-tools.service

# Create README for user
cat > /home/ubuntu/README-NEXUS-SONAR.txt << 'EOF'
Nexus Repository and SonarQube Setup Complete!

Services:
- Nexus Repository Manager: http://YOUR-SERVER-IP:8081
- SonarQube: http://YOUR-SERVER-IP:9000

Default Credentials:
- Nexus: admin / (check /opt/nexus-data/admin.password)
- SonarQube: admin / admin

Management Commands:
- Check status: /opt/status.sh
- Start services: /opt/manage-services.sh start
- Stop services: /opt/manage-services.sh stop
- Restart services: /opt/manage-services.sh restart
- View logs: /opt/manage-services.sh logs [nexus|sonarqube]

Initial Setup:
1. Access Nexus and change the admin password
2. Configure Docker repository:
   - Go to Administration > Repository > Repositories
   - Create Docker (hosted) repository named 'docker-hosted'
   - Enable Docker Bearer Token Realm in Security > Realms
3. Access SonarQube and change the default password
4. Configure repositories and quality gates as needed

Docker Registry:
- Registry URL: YOUR-SERVER-IP:8081/repository/docker-hosted/
- Docker login: docker login YOUR-SERVER-IP:8081/repository/docker-hosted/

Files Location:
- Docker Compose: /opt/docker-compose.yml
- Nexus data: /opt/nexus-data/
- SonarQube data: /opt/sonarqube/
EOF

chown ubuntu:ubuntu /home/ubuntu/README-NEXUS-SONAR.txt

echo "Nexus and SonarQube setup completed at $(date)" > /var/log/nexus-sonar-setup.log