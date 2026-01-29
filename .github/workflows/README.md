# 🚀 GitHub Actions Workflows for NoelaCuisine

This directory contains GitHub Actions workflows for the NoelaCuisine project, providing comprehensive CI/CD, security scanning, and infrastructure management using **self-hosted GitHub runners** provisioned by Terraform.

## 📁 Workflow Files

### 1. [`ci-cd.yml`](.github/workflows/ci-cd.yml) - Main CI/CD Pipeline
**Triggers**: Push to `main`/`develop`, Pull Requests, Manual Dispatch  
**Runner**: Self-hosted Linux runner (provisioned by Terraform)

**Features**:
- 🔍 **Code Quality & Security Analysis**
  - Trivy vulnerability scanning (self-hosted)
  - **SonarQube integration** (self-hosted server)
  - HTML/CSS/JS linting
  - Web accessibility checks
  
- 🔨 **Build & Test**
  - HTML/CSS/JS validation
  - Build artifact generation
  - Accessibility testing
  
- 🐳 **Docker Management**
  - Multi-platform Docker builds (on self-hosted runner)
  - Container security scanning
  - Docker Hub publishing
  
- 🏗️ **Infrastructure as Code**
  - Terraform validation
  - Infrastructure provisioning
  - Environment-specific deployments
  
- 🚀 **Automated Deployment**
  - Staging deployment (develop branch)
  - Production deployment (main branch)
  - Environment protection rules

### 2. [`infrastructure.yml`](.github/workflows/infrastructure.yml) - Infrastructure Management
**Triggers**: Manual Dispatch Only  
**Runner**: Self-hosted Linux runner

**Features**:
- Manual Terraform operations (plan/apply/destroy)
- Environment selection (staging/production)
- Infrastructure state management
- Resource cleanup capabilities

### 3. [`security.yml`](.github/workflows/security.yml) - Security Scanning
**Triggers**: Weekly Schedule, Manual Dispatch, Main Branch Changes  
**Runner**: Self-hosted Linux runner

**Features**:
- 🔒 **Comprehensive Security Scanning**
  - Filesystem vulnerability scanning with Trivy
  - Docker image security analysis
  - Secret detection with TruffleHog
  
- 🌐 **Web Security Checks**
  - XSS vulnerability detection
  - Insecure HTTP link scanning
  - Security attribute validation
  
- 📦 **Dependency Analysis**
  - NPM audit for JavaScript dependencies
  - Vulnerability reporting
  - Security advisory integration

## 🏃‍♂️ Self-Hosted Runner Configuration

The workflows are designed to run on the GitHub self-hosted runner provisioned by Terraform:

**Runner Labels**: `[self-hosted, linux]`

**Pre-installed Tools** (via Terraform user data):
- Docker & Docker Compose
- Node.js (v20)
- AWS CLI
- kubectl & Helm
- Maven & Gradle
- SonarQube Scanner (`/opt/sonar-scanner/bin/sonar-scanner`)
- Git and essential build tools

**Auto-installed Tools** (via workflows):
- Trivy (security scanner)
- TruffleHog (secret scanner)
- Terraform
- Various linting tools (htmlhint, stylelint, eslint)

## 🔧 Required Secrets

Configure these secrets in your GitHub repository settings:

### 🔐 Container Registry
```
DOCKER_USERNAME          # Docker Hub username
DOCKER_PASSWORD          # Docker Hub password or token
```

### ☁️ AWS Credentials
```
AWS_ACCESS_KEY_ID        # AWS access key
AWS_SECRET_ACCESS_KEY    # AWS secret key
```

### 🏗️ Terraform Variables
```
TF_VAR_PUBLIC_KEY        # SSH public key for EC2 instances
TF_VAR_GITHUB_TOKEN      # GitHub PAT for runner registration
```

### 📊 Code Quality
```
SONAR_TOKEN              # SonarCloud authentication token
```

## 🌐 Environment Setup

### Staging Environment
- **Trigger**: Pushes to `develop` branch
- **Resources**: Smaller instance types for cost optimization
- **Purpose**: Testing and validation

### Production Environment
- **Trigger**: Pushes to `main` branch
- **Resources**: Production-grade instance types
- **Purpose**: Live application hosting

## 📋 Workflow Features

### 🎯 Automated Quality Gates
- ✅ Code linting and formatting
- ✅ Security vulnerability scanning
- ✅ Infrastructure validation
- ✅ Container security checks

### 📊 Comprehensive Reporting
- Build and deployment summaries
- Security scan results
- Infrastructure output details
- Performance metrics

### 🔄 Branch Strategy Support
- **Main Branch**: Production deployments
- **Develop Branch**: Staging deployments
- **Feature Branches**: CI validation only
- **Pull Requests**: Full validation + Terraform planning

### 🛡️ Security Integration
- GitHub Security tab integration
- SARIF report uploads
- Automated vulnerability detection
- Dependency security monitoring

## 🚀 Usage Examples

### Manual Infrastructure Deployment
```yaml
# Navigate to Actions tab > Infrastructure Management
# Select environment: staging/production
# Choose action: plan/apply/destroy
```

### Triggering Security Scans
```yaml
# Automatic: Weekly on Mondays at 2 AM
# Manual: Actions tab > Security Scan > Run workflow
# Automatic: Push to main branch
```

### Environment Deployments
```yaml
# Staging: Push to develop branch
# Production: Push to main branch
# Manual: Actions tab > CI/CD Pipeline > Run workflow
```

## 📈 Monitoring & Observability

The workflows provide:
- **Deployment Status**: Real-time deployment progress
- **Infrastructure URLs**: Direct links to deployed services
- **Security Reports**: Detailed vulnerability findings
- **Performance Metrics**: Build and deployment times
- **Resource Information**: Infrastructure costs and sizing

## 🔗 Service Integrations

- **SonarCloud**: Code quality and security analysis
- **Docker Hub**: Container image registry
- **AWS**: Cloud infrastructure hosting
- **GitHub Security**: Vulnerability management
- **Terraform Cloud**: Infrastructure state management (optional)

## 🛠️ Customization

To customize the workflows for your environment:

1. **Update environment variables** in workflow files
2. **Modify instance types** in Terraform variables
3. **Add custom security rules** in security workflow
4. **Configure notification channels** for deployment status
5. **Adjust resource sizing** based on requirements

## 📝 Best Practices

- 🔐 **Never commit secrets** - use GitHub Secrets
- 🎯 **Use environment protection rules** for production
- 📊 **Monitor workflow execution times** and optimize
- 🔄 **Keep workflows updated** with latest action versions
- 🛡️ **Review security findings** regularly
- 📈 **Track infrastructure costs** and optimize

## 📞 Support

For workflow issues:
1. Check GitHub Actions logs
2. Review AWS CloudWatch logs
3. Validate Terraform state
4. Check Docker Hub build status
5. Review SonarCloud analysis results

Each workflow includes comprehensive error handling and detailed logging for troubleshooting purposes.