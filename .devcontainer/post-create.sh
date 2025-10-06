#!/bin/bash

# Post-create script for AtlasStack DevContainer
# Installs required dependencies and sets up the development environment

set -e

echo "=== AtlasStack DevContainer Post-Create Setup ==="

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install essential tools
echo "Installing essential tools..."
sudo apt-get install -y \
  git \
  bash \
  bsdutils \
  curl \
  wget \
  jq \
  vim \
  nano \
  shellcheck \
  ansible \
  python3 \
  python3-pip \
  python3-venv

# Install additional DevOps tools
echo "Installing additional DevOps tools..."
sudo apt-get install -y \
  rsync \
  openssh-client \
  net-tools \
  iputils-ping \
  dnsutils \
  telnet

# Install Ansible collections if needed
if command -v ansible-galaxy &> /dev/null; then
  echo "Installing Ansible collections..."
  ansible-galaxy collection install community.general || true
fi

# Set proper permissions for workspace
echo "Setting workspace permissions..."
sudo chown -R vscode:vscode /workspaces || true

# Print versions
echo ""
echo "=== Installed versions ==="
echo "Git: $(git --version)"
echo "Bash: $(bash --version | head -n1)"
echo "Python: $(python3 --version)"
if command -v ansible &> /dev/null; then
  echo "Ansible: $(ansible --version | head -n1)"
fi

echo ""
echo "=== Setup complete! ==="
echo "AtlasStack development environment is ready."
echo ""
