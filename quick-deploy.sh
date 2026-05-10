#!/bin/bash
# Quick deployment script for Hermes Agent
# This script automates the initial setup on a fresh Ubuntu VM

set -e  # Exit on error

echo "=============================================="
echo "   Hermes Agent - Quick Deploy Script"
echo "=============================================="
echo ""

# Check if running on Ubuntu/Debian
if ! command -v apt-get &> /dev/null; then
    echo "❌ Error: This script is designed for Ubuntu/Debian systems"
    exit 1
fi

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "⚠️  Please run as normal user (not root). Use sudo for individual commands if needed."
    exit 1
fi

# 1. Update system
echo "📦 Step 1/5: Updating system packages..."
sudo apt update && sudo apt upgrade -y

# 2. Install Docker
echo "🐳 Step 2/5: Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# 3. Install Docker Compose plugin
echo "🔧 Step 3/5: Installing Docker Compose..."
if ! docker compose version &> /dev/null; then
    sudo apt install -y docker-compose-plugin
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# 4. Configure firewall
echo "🔥 Step 4/5: Configuring firewall..."
sudo ufw allow 22/tcp > /dev/null 2>&1
sudo ufw allow 8080/tcp > /dev/null 2>&1
echo "y" | sudo ufw enable > /dev/null 2>&1
echo "✅ Firewall configured (ports 22, 8080 open)"

# 5. Setup environment
echo "⚙️  Step 5/5: Setting up environment..."

if [ -f .env ]; then
    echo "⚠️  .env file already exists. Skipping..."
else
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ Created .env from template"
        
        # Generate random password if not set
        if ! grep -q "^ADMIN_PASSWORD=.\+" .env; then
            RANDOM_PASSWORD=$(openssl rand -base64 16)
            echo "ADMIN_PASSWORD=$RANDOM_PASSWORD" >> .env
            echo "✅ Generated random admin password"
        fi
    else
        echo "⚠️  .env.example not found. You'll need to configure manually."
    fi
fi

echo ""
echo "=============================================="
echo "   Installation Complete! 🎉"
echo "=============================================="
echo ""
echo "⚠️  IMPORTANT: Docker group membership requires logout/login"
echo ""
echo "Please run these commands:"
echo ""
echo "  1. Logout and login again (or run: newgrp docker)"
echo "  2. docker compose up -d"
echo "  3. docker compose logs -f"
echo ""
echo "Then access the admin UI at: http://$(curl -s ifconfig.me):8080"
echo ""

# Show admin credentials if .env exists
if [ -f .env ]; then
    ADMIN_PASS=$(grep "^ADMIN_PASSWORD=" .env | cut -d '=' -f2)
    if [ -n "$ADMIN_PASS" ]; then
        echo "Your admin credentials:"
        echo "  Username: admin"
        echo "  Password: $ADMIN_PASS"
        echo ""
    fi
fi

echo "For more details, see DEPLOY.md"
echo "=============================================="
