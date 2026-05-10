# GitHub Actions - Build & Publish Docker Image

This guide explains how to build the Hermes Agent Docker image using GitHub Actions and push it to GitHub Container Registry (GHCR).

## Benefits

- **No local build needed** - GitHub's powerful servers build for you (free)
- **Fast VM deployment** - Pull pre-built image in ~2 minutes vs 30-45 min build
- **Consistent builds** - Same image works on all machines
- **Free** - GitHub Actions and GHCR are free for public repos

## One-Time Setup

### Step 1: Make Package Public (First Time Only)

After the first build, the package will be created but might be private by default:

1. Go to your repo: https://github.com/privinpt/hermes-agent-template
2. Click **Packages** (right sidebar)
3. Click **hermes-agent-template**
4. Click **Package settings** (gear icon)
5. Scroll to **Danger Zone** → **Change visibility**
6. Select **Public** → Type repo name to confirm

## How to Trigger a Build

### Option 1: Manual Trigger (Recommended for One-Time Builds)

1. Go to your repo: https://github.com/privinpt/hermes-agent-template
2. Click **Actions** tab
3. Click **Build Docker Image** workflow (left sidebar)
4. Click **Run workflow** button (right side)
5. Click green **Run workflow**
6. Wait ~15-20 minutes for build to complete

### Option 2: Automatic on Push (Optional)

Uncomment these lines in `.github/workflows/build-docker.yml`:

```yaml
on:
  workflow_dispatch:
  push:  # Uncomment these lines
    branches: [ main ]
    paths:
      - 'Dockerfile'
      - 'server.py'
      - 'requirements.txt'
      - 'templates/**'
```

Now every push to `main` will auto-build.

## Check Build Progress

1. Go to **Actions** tab
2. Click on the running workflow
3. Click **build-and-push** job
4. Expand steps to see live logs
5. Look for "Build and push Docker image" step (~15 min)

## After Build Completes

### Your Image Location:

```
ghcr.io/privinpt/hermes-agent-template:latest
```

**View package:** https://github.com/privinpt/hermes-agent-template/pkgs/container/hermes-agent-template

### Test Pull Locally (Optional):

```bash
docker pull ghcr.io/privinpt/hermes-agent-template:latest
```

### Deploy to Your VM:

**On your Oracle Cloud VM:**

```bash
# Download the pre-built compose file
wget https://raw.githubusercontent.com/privinpt/hermes-agent-template/main/docker-compose.ghcr.yml

# Or if you have the repo:
cd hermes-agent-template

# Deploy (uses pre-built image - FAST!)
docker compose -f docker-compose.ghcr.yml up -d

# View logs
docker compose -f docker-compose.ghcr.yml logs -f
```

**That's it!** Container starts in ~2 minutes instead of 30-45 minutes.

## Troubleshooting

### "No package found" Error

**Cause:** Package hasn't been created yet or is private

**Solution:**
1. Run the workflow at least once to create the package
2. Make the package public (see Step 1 above)

### Build Fails

**Check logs:**
1. Actions tab → Click failed workflow
2. Look for error messages
3. Most common: Dockerfile syntax errors or missing files

### Can't Pull Image on VM

**If image is private:**
```bash
# Create GitHub Personal Access Token with read:packages scope
echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Then pull
docker pull ghcr.io/privinpt/hermes-agent-template:latest
```

**If image is public:**
- Should work without authentication
- Check you're using correct image name

## Update Image

To rebuild after making changes:

1. Push changes to GitHub:
   ```bash
   git add .
   git commit -m "Update files"
   git push origin main
   ```

2. Manually trigger workflow (Actions tab → Run workflow)
   
3. On VM, pull new image:
   ```bash
   docker compose -f docker-compose.ghcr.yml pull
   docker compose -f docker-compose.ghcr.yml up -d
   ```

## Cost

**Everything is FREE:**
- ✅ GitHub Actions: 2,000 minutes/month (free tier)
- ✅ GHCR Storage: Unlimited for public repos
- ✅ Bandwidth: Unlimited for public packages
- ✅ Total cost: $0

## Next Steps

1. ✅ Create workflow file (done)
2. ✅ Push to GitHub (done)
3. ⏭️ Run workflow manually (Actions tab)
4. ⏭️ Make package public (after first build)
5. ⏭️ Deploy on VM with `docker-compose.ghcr.yml`
