# DevOps Infrastructure with Terraform

This Terraform configuration provisions a complete DevOps infrastructure on AWS with the following components:

## Infrastructure Components

### 1. GitHub Self-Hosted Runner Server
- **Purpose**: CI/CD automation with GitHub Actions
- **Instance Type**: t3.medium (2 vCPU, 4 GB RAM)
- **Installed Software**:
  - Docker & Docker Compose
  - GitHub Actions Runner
  - SonarQube Scanner
  - Node.js, Maven, Gradle
  - AWS CLI, kubectl, Helm

### 2. Nexus Repository & SonarQube Server
- **Purpose**: Artifact management and code quality analysis
- **Instance Type**: t3.large (2 vCPU, 8 GB RAM)
- **Services**:
  - Nexus Repository Manager (Port 8081)
  - SonarQube Community Edition (Port 9000)
  - PostgreSQL (for SonarQube)

### 3. Monitoring Server
- **Purpose**: Infrastructure and application monitoring
- **Instance Type**: t3.medium (2 vCPU, 4 GB RAM)
- **Services**:
  - Prometheus (Port 9090)
  - Grafana (Port 3000)
  - AlertManager (Port 9093)
  - Node Exporter (Port 9100)
  - cAdvisor (Port 8080)

## Prerequisites

1. **AWS Account** with appropriate IAM permissions
2. **AWS CLI** configured with credentials
3. **Terraform** installed (>= 1.0)
4. **SSH Key Pair** for EC2 access
5. **GitHub Personal Access Token** for runner registration

## Setup Instructions

### 1. Generate SSH Key Pair
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops-pipeline
```

### 2. Create GitHub Personal Access Token
- Go to GitHub Settings > Developer settings > Personal access tokens
- Create token with `repo` and `admin:repo_hook` permissions

### 3. Configure Terraform Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply
```

### 5. Post-Deployment Configuration

#### GitHub Runner Setup
```bash
# SSH into GitHub runner server
ssh -i ~/.ssh/devops-pipeline ubuntu@<github-runner-ip>

# Switch to runner user and configure
sudo su - runner
./configure-runner.sh
```

#### Access Services
- **Nexus Repository**: http://nexus-server-ip:8081
  - Default: admin / (check `/opt/nexus-data/admin.password`)
- **SonarQube**: http://nexus-server-ip:9000
  - Default: admin / admin
- **Prometheus**: http://monitoring-server-ip:9090
- **Grafana**: http://monitoring-server-ip:3000
  - Default: admin / admin123

## Service Management

### Nexus & SonarQube Server
```bash
# Check status
/opt/status.sh

# Manage services
/opt/manage-services.sh {start|stop|restart|status|logs}

# View logs
/opt/manage-services.sh logs nexus
/opt/manage-services.sh logs sonarqube
```

### Monitoring Server
```bash
# Check status
/opt/manage-monitoring.sh status

# Manage services
/opt/manage-monitoring.sh {start|stop|restart|status|logs}

# Setup Grafana dashboards
/opt/manage-monitoring.sh setup-dashboards
```

## Security Considerations

1. **Change Default Passwords** immediately after deployment
2. **Restrict SSH Access** by updating `allowed_ssh_cidr` variable
3. **Enable HTTPS** for production deployments
4. **Configure Backup** strategies for persistent data
5. **Set up VPN** or bastion host for internal access

## Cost Optimization

- **Instance Types**: Adjust based on workload requirements
- **Storage**: Use gp3 volumes for better cost/performance
- **Scheduling**: Stop development instances during off-hours
- **Monitoring**: Set up billing alerts

## Troubleshooting

### Common Issues

1. **Services not starting**: Check logs using management scripts
2. **Port conflicts**: Ensure security groups allow required ports
3. **Storage issues**: Monitor disk space usage
4. **Performance**: Adjust instance types based on usage

### Log Locations
- GitHub Runner: `/var/log/github-runner-setup.log`
- Nexus/SonarQube: `/var/log/nexus-sonar-setup.log`
- Monitoring: `/var/log/monitoring-setup.log`

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## File Structure

```
terraform/
├── main.tf                     # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example variables file
├── user_data/
│   ├── github_runner.sh       # GitHub runner setup script
│   ├── nexus_sonar.sh         # Nexus & SonarQube setup script
│   └── monitoring.sh          # Monitoring stack setup script
└── README.md                  # This file
```

## Support

For issues and questions:
1. Check AWS CloudWatch logs
2. Review setup logs on each server
3. Use management scripts for service diagnostics
4. Monitor Grafana dashboards for system health