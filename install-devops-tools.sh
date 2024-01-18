'''

This script automates the installation and configuration of key DevOps tools on an EC2 instance via user data.
It installs and sets up the following:

- Java 11: Required for running Jenkins
- Jenkins: Leading open source automation server
- AWS CLI: CLI tool to manage AWS services
- kubectl: CLI tool to manage Kubernetes clusters
- Helm: Kubernetes package manager
- Docker: Containerization platform

This allows the EC2 instance to serve as a ready-to-use CI/CD server with Docker, Kubernetes, and AWS access out of the box.

'''


#!/bin/bash

# Install Java 11
sudo apt update  
sudo apt install -y openjdk-11-jre

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt update
apt install -y jenkins

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install

# Install kubectl 
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add - 
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list  
sudo apt update
sudo apt install helm

# Install Docker
apt install -y gnupg2 pass
apt install -y docker.io
sudo usermod -aG docker ${USER}
sudo systemctl enable docker
sudo systemctl start docker

# Install Maven
sudo apt install maven