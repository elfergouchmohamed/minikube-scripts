#!/bin/bash

# Docker, kubectl, and Minikube installation script for Ubuntu

echo "Checking if Docker is already installed..."
if ! command -v docker &> /dev/null; then
  echo "Docker is not installed. Installing Docker..."

  # Add Docker's official GPG key
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add Docker repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Ensure docker group exists
  if getent group docker > /dev/null 2>&1; then
    echo "Group 'docker' already exists."
  else
    groupadd docker
    echo "Group 'docker' created."
  fi

  # Add current user to docker group
  usermod -aG docker $USER
  newgrp docker

  echo "Docker installed. Sleeping for 10 seconds..."
  sleep 10
else
  echo "Docker is already installed."
fi

# kubectl installation
echo "Checking if kubectl is already installed..."
if ! command -v kubectl &> /dev/null; then
  echo "kubectl is not installed. Installing kubectl..."

  KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

  echo "$(<kubectl.sha256) kubectl" | sha256sum --check
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  sudo rm kubectl kubectl.sha256

  kubectl version --client
  echo "kubectl installed. Sleeping for 10 seconds..."
  sleep 10
else
  echo "kubectl is already installed."
fi

# Minikube installation
echo "Checking if Minikube is already installed..."
if ! command -v minikube &> /dev/null; then
  echo "Minikube is not installed. Installing Minikube..."

  curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  sudo rm minikube-linux-amd64

  minikube start
else
  echo "Minikube is already installed."
fi
