#!/bin/bash
set -e

# Determine the OS type
if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

# Start SSM agent if not running (should be pre-installed on both Ubuntu and Amazon Linux 2)
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install dependencies based on OS
if [[ "$ID" == "amzn" ]]; then
    # Amazon Linux 2
    yum update -y
    yum install -y curl
    
    # Install Docker on Amazon Linux 2
    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker
    
    # Install GitLab Runner on Amazon Linux 2
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh" | bash
    yum install -y gitlab-runner
elif [[ "$ID" == "ubuntu" ]]; then
    # Ubuntu
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y curl
    
    # Install Docker on Ubuntu
    apt-get install -y apt-transport-https ca-certificates gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    systemctl start docker
    systemctl enable docker
    
    # Install GitLab Runner on Ubuntu
    curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | bash
    apt-get install -y gitlab-runner
else
    echo "Unsupported OS: $ID"
    exit 1
fi

# Register GitLab Runner with Docker executor
gitlab-runner register \
  --non-interactive \
  --url "${gitlab_url}" \
  --registration-token "${gitlab_runner_token}" \
  --executor "docker" \
  --docker-image "alpine:latest" \
  --description "Docker Runner" \
  --tag-list "${runner_tags}" \
  --run-untagged="true" \
  --locked="false" \
  --docker-privileged="true" \
  --docker-volumes "/cache"

# Start and enable GitLab Runner
systemctl enable gitlab-runner
systemctl start gitlab-runner

# Ensure Docker is properly set up for GitLab Runner
usermod -aG docker gitlab-runner