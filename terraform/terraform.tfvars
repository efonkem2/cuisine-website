# Sample terraform.tfvars file
# Copy this to terraform.tfvars and update with your values

# AWS Configuration
aws_region = "us-east-1"

# Project Configuration
project_name = "devops-pipeline"
environment  = "production"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
allowed_ssh_cidr   = "0.0.0.0/0"  # Change to your IP for security

# Instance Configuration
instance_type_runner      = "t3.medium"     # 2 vCPU, 4 GB RAM
instance_type_nexus_sonar = "t3.large"      # 2 vCPU, 8 GB RAM
instance_type_monitoring  = "t3.medium"     # 2 vCPU, 4 GB RAM

# SSH Key (generate with: ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops-pipeline)
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAPsCwGi9SzMRU59mo4E0HFkTR+pwxUUS13MBnTioe2TXUlfK6zcfwYMmo162RbWmGHoCf0eGvQffY1FsT9xhH4Rs7jGfP1dw5MEBI2Mi4JOOiSUJ2hOfcvIFhnvekqxzzwpu1uNiXYJjyedErLpqTZOcpW5YElcTjljEbWJtWYs9xxUQ30sRNRFHuO8RTbEATepUlSr1fNAbGA6zRF4YXkPqgX2bQkIeCGhldIyaOz8dGmoMd0KUyYf0e6/dPBfq8td/j6HkewamyrPkaeUOBVjQrhw7B/nlmuAj4bAPLtOMAwNf2RqZsPZe6ttxIhYu9x02e3Ep83Kw/yJ2Z7n0S9ekCLqV5BwQAPipb7lZOztmveJ545ysh9hpnOtL3Om1eYUbrgA9Xp5o96ZVDXInbqLw2KnL+kcqXviT9AThryTH5YeHiIhPJoGr0x6BxPY1ZrPlm2DTQfbA5UrzfUTWoeuuttSy4QSa6kcEkVQf1HloHRkI9EdcNSK9t2hkLspS3eV3fgC/NZ64FJE6FbD+PwkkrNcR+9qmt5YjMEMy44XkBm9CAR122cuKSc0qtQdSRv1WsLmiDQDtWQeQNTB3WfCkLnO1sWhWKvE9fxGYpe9BgxHBwkloDbUamMdw1/YzZbi1fIWY0PsQ6aBZy45ud10/esU6dnAhp1aN2PGy+bQ== efonk@efonkem"

# GitHub Configuration
github_token = "ghp_your_github_personal_access_token_here"
github_repo  = "your-username/your-repository"