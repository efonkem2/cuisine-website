#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install essential packages
apt-get install -y curl wget unzip git jq

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Node.js (for GitHub Actions runner)
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Create runner user
useradd -m -s /bin/bash runner
usermod -aG docker runner

# Download and configure GitHub Actions runner
cd /home/runner
mkdir actions-runner && cd actions-runner

# Get latest runner version
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | sed 's/v//')
curl -o actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v$${RUNNER_VERSION}/actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-linux-x64-$${RUNNER_VERSION}.tar.gz
chown -R runner:runner /home/runner/actions-runner

# Install SonarQube Scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip
mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner
echo 'export PATH="/opt/sonar-scanner/bin:$PATH"' >> /etc/environment

# Configure GitHub runner (to be run manually after Terraform deployment)
cat > /home/runner/configure-runner.sh << 'EOF'
#!/bin/bash
cd /home/runner/actions-runner
./config.sh --url https://github.com/${github_repo} --token ${github_token} --name "self-hosted-runner-$(hostname)" --work _work --unattended
sudo ./svc.sh install
sudo ./svc.sh start
EOF

chmod +x /home/runner/configure-runner.sh
chown runner:runner /home/runner/configure-runner.sh

# Install additional tools for CI/CD
apt-get install -y maven gradle

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install helm

# Create log file
echo "GitHub Runner setup completed at $(date)" > /var/log/github-runner-setup.log

# Instructions for manual configuration
cat > /home/ubuntu/README-RUNNER-SETUP.txt << 'EOF'
GitHub Actions Runner Setup Instructions:

1. SSH into this server
2. Switch to runner user: sudo su - runner
3. Run the configuration script: ./configure-runner.sh

Or configure manually:
cd /home/runner/actions-runner
./config.sh --url https://github.com/YOUR-ORG/YOUR-REPO --token YOUR-TOKEN
sudo ./svc.sh install
sudo ./svc.sh start

The runner will appear in your GitHub repository settings under Actions > Runners.
EOF

chown ubuntu:ubuntu /home/ubuntu/README-RUNNER-SETUP.txt