# Deploying Hermes Agent to Oracle Cloud

This guide walks you through deploying the Hermes Agent to an Oracle Cloud VM using Docker Compose.

## Prerequisites

- Oracle Cloud account (free tier works fine)
- Basic familiarity with SSH and command line

## Step 1: Create Oracle Cloud VM

### 1.1 Launch Compute Instance

1. Log in to [Oracle Cloud Console](https://cloud.oracle.com)
2. Navigate to: **Compute** → **Instances** → **Create Instance**
3. Configure:
   - **Name**: `hermes-agent` (or your choice)
   - **Image**: Ubuntu 22.04 or Ubuntu 24.04
   - **Shape**: 
     - Free tier: `VM.Standard.E2.1.Micro` (1 OCPU, 1GB RAM)
     - Better performance: `VM.Standard.A1.Flex` (4 OCPUs, 24GB RAM - free tier)
   - **Networking**: Use default VCN or create new
   - **SSH Keys**: Add your SSH public key (or download the generated private key)

4. Click **Create**

### 1.2 Configure Networking

1. Go to: **Networking** → **Virtual Cloud Networks** → Your VCN → **Security Lists**
2. Click your security list (usually `Default Security List`)
3. Click **Add Ingress Rules**
4. Add rule for HTTP:
   - **Source CIDR**: `0.0.0.0/0`
   - **Destination Port Range**: `8080`
   - **Description**: `Hermes Admin UI`
5. Click **Add Ingress Rules**

### 1.3 Configure VM Firewall

SSH into your VM and configure the Ubuntu firewall:

```bash
ssh ubuntu@<your-vm-public-ip>

# Allow ports
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 8080/tcp  # Hermes UI
sudo ufw enable
sudo ufw status
```

## Step 2: Install Docker

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker using official script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Logout and login again for group changes to take effect
exit
```

Re-connect via SSH:
```bash
ssh ubuntu@<your-vm-public-ip>

# Verify installations
docker --version
docker compose version
```

## Step 3: Deploy Hermes Agent

### 3.1 Get the Code

```bash
# Clone the repository (or upload files via SCP)
cd ~
git clone <your-repository-url> hermes-agent
cd hermes-agent
```

Alternatively, if you have the files locally:
```bash
# From your local machine
scp -r /path/to/hermes-agent ubuntu@<your-vm-ip>:~/
```

### 3.2 Configure Environment

```bash
cd ~/hermes-agent

# Copy environment template
cp .env.example .env

# Edit with your credentials
nano .env
```

**Minimum required configuration:**
```env
ADMIN_PASSWORD=YourSecurePassword123!
```

**Optional: Pre-configure LLM provider:**
```env
ADMIN_PASSWORD=YourSecurePassword123!
OPENROUTER_API_KEY=sk-or-v1-your-key-here
LLM_MODEL=google/gemma-3-1b-it:free
```

Press `Ctrl+X`, then `Y`, then `Enter` to save.

### 3.3 Start the Container

```bash
# Build and start in detached mode
docker compose up -d

# Check logs to see if it started successfully
docker compose logs -f
```

Press `Ctrl+C` to exit log viewing.

## Step 4: Access the Admin UI

1. Open browser: `http://<your-vm-public-ip>:8080`
2. Log in with:
   - **Username**: `admin`
   - **Password**: Value from your `.env` file (or check logs if auto-generated)

## Step 5: Configure Hermes

### 5.1 Initial Setup

1. In the admin UI, go to **Setup** tab
2. Configure:
   - **LLM Provider**: Select OpenRouter (or your choice)
   - **API Key**: Paste your provider API key
   - **Model**: e.g., `google/gemma-3-1b-it:free`

### 5.2 Add Messaging Channel

1. Click **Channels** tab
2. Enable Telegram:
   - Get a bot token from [@BotFather](https://t.me/BotFather)
   - Paste the token
   - Click **Save**

3. Click **Start Gateway** button

### 5.3 Approve Users

1. Message your Telegram bot
2. Go to **Users** tab in admin UI
3. Click **Approve** for pending requests

## Useful Commands

### View logs
```bash
docker compose logs -f hermes-agent
```

### Restart the container
```bash
docker compose restart
```

### Stop the container
```bash
docker compose down
```

### Update to latest version
```bash
cd ~/hermes-agent
git pull
docker compose build --no-cache
docker compose up -d
```

### Check container status
```bash
docker compose ps
```

### Access container shell (debugging)
```bash
docker compose exec hermes-agent bash
```

## Troubleshooting

### Container won't start
```bash
# Check logs for errors
docker compose logs hermes-agent

# Check if port is already in use
sudo netstat -tulpn | grep 8080
```

### Can't connect to UI
1. Verify VM firewall: `sudo ufw status`
2. Verify Oracle Cloud security list has ingress rule for port 8080
3. Check container is running: `docker compose ps`
4. Check logs: `docker compose logs`

### Reset configuration
```bash
# Stop container
docker compose down

# Remove data volume (WARNING: deletes all config!)
docker volume rm hermes-agent-template_hermes-data

# Start fresh
docker compose up -d
```

### Find auto-generated password
```bash
# If you didn't set ADMIN_PASSWORD, check logs
docker compose logs hermes-agent | grep "Admin credentials"
```

## Security Recommendations

1. **Change default password**: Always set a strong `ADMIN_PASSWORD`
2. **Use HTTPS**: Consider setting up a reverse proxy with Let's Encrypt (Nginx/Caddy)
3. **Restrict IP access**: Update security list to only allow your IP if possible
4. **Keep updated**: Regularly update the Hermes agent and Ubuntu packages
5. **Backup data**: The Docker volume contains all config - back it up periodically

## Free Tier Limits

Oracle Cloud Free Tier includes:
- 2 VM.Standard.E2.1.Micro instances (1 OCPU, 1GB RAM each)
- OR 4 ARM-based Ampere A1 cores (up to 24GB RAM total)
- 200GB block storage
- Always Free (no expiration)

The Hermes Agent runs comfortably on free tier VMs.

## Getting LLM API Keys

### OpenRouter (Recommended - Free Models Available)
1. Sign up: https://openrouter.ai/
2. Get API key: https://openrouter.ai/keys
3. Browse free models: https://openrouter.ai/models?order=pricing-low-to-high
4. Use model IDs like: `google/gemma-3-1b-it:free`

### Alternative Providers
- **DeepSeek**: https://platform.deepseek.com (very cheap)
- **Anthropic**: https://console.anthropic.com (paid)
- **OpenAI**: https://platform.openai.com (paid)

## Support

- Hermes Agent: https://github.com/NousResearch/hermes-agent
- Issues: Open an issue on the repository
- Oracle Cloud: https://docs.oracle.com/iaas/
