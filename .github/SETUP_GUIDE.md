# GitHub Actions Workflow Setup Guide

## Overview
This guide explains how to set up and configure the GitHub Actions workflow for building Docker images and deploying to Render.

**Workflow File**: `.github/workflows/render-docker-deploy.yml`

---

## 🔐 Required GitHub Secrets

Your GitHub repository needs **3 secrets** configured for the workflow to function. Set these in:
**Settings → Secrets and Variables → Actions → Repository secrets**

### 1. DOCKERHUB_USERNAME
**Description**: Your Docker Hub account username

**How to get it**:
1. Go to [Docker Hub](https://hub.docker.com) and log in
2. Click your profile icon (top-right) → Account Settings
3. Your username is displayed on the left sidebar
4. Example: `john_doe_docker`

**Set in GitHub**:
1. Settings → Secrets and Variables → Actions
2. Click "New repository secret"
3. Name: `DOCKERHUB_USERNAME`
4. Value: `your_docker_hub_username`

---

### 2. DOCKERHUB_TOKEN
**Description**: Docker Hub Personal Access Token (PAT) for authentication

**⚠️ IMPORTANT**: Create a Personal Access Token, NOT your password

**How to create PAT**:
1. Go to [Docker Hub Security Settings](https://hub.docker.com/settings/security)
2. Click "New Access Token"
3. Give it a name: `GitHub-Actions-egram`
4. Access permissions: Select `Read, Write, Delete`
5. Click "Generate"
6. Copy the token immediately (you won't see it again)

**Set in GitHub**:
1. Settings → Secrets and Variables → Actions
2. Click "New repository secret"
3. Name: `DOCKERHUB_TOKEN`
4. Value: `<paste_your_docker_hub_token>`

**Example Token Format**: 
```
dckr_pat_abCdEfGhIjKlMnOpQrStUvWxYz
```

---

### 3. RENDER_DEPLOY_HOOK_URL
**Description**: Render deployment webhook URL for triggering deployments

**How to get it**:
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Select your **egram-service** Web Service
3. Navigate to **Settings**
4. Scroll down to **Deploy Hook**
5. Copy the full URL (it looks like):
   ```
   https://api.render.com/deploy/srv-abcdefghijklmnopqrst?key=abc123xyz789
   ```
6. Keep this URL **private** - never commit it or share it publicly

**Set in GitHub**:
1. Settings → Secrets and Variables → Actions
2. Click "New repository secret"
3. Name: `RENDER_DEPLOY_HOOK_URL`
4. Value: `<paste_your_render_webhook_url>`

---

## ⚙️ Workflow Configuration

### Environment Variables
At the top of the workflow file, you can customize:

```yaml
env:
  REGISTRY: docker.io
  IMAGE_NAME: egram-service
```

**Change `IMAGE_NAME`** if you want a different Docker image name:
- Current: `your_username/egram-service:latest`
- To change: Edit `IMAGE_NAME: your-custom-name` in the workflow file

---

## 🚀 How the Workflow Works

### Trigger Events
The workflow automatically runs on:
1. **Push to `main` branch** - Whenever code is pushed to main
2. **Manual trigger** - Click "Run workflow" in GitHub Actions UI

### Execution Steps

| Step | Action | Purpose |
|------|--------|---------|
| 1 | Checkout | Clone the repository |
| 2 | Setup Java 17 | Install Java and Maven, cache dependencies |
| 3 | Build with Maven | `mvn clean package -DskipTests` |
| 4 | Setup Docker Buildx | Enable advanced Docker building |
| 5 | Login to Docker Hub | Authenticate using secrets |
| 6 | Extract Metadata | Generate image tags (latest, sha, etc.) |
| 7 | Build & Push | Build Docker image and push to Docker Hub |
| 8 | Trigger Render Deploy | Call Render webhook to start deployment |
| 9 | Status Summary | Post results to GitHub summary |

---

## ✅ Verification Steps

### 1. Verify Secrets Are Set
```bash
# In GitHub Settings → Secrets and Variables → Actions
# You should see 3 secrets:
# - DOCKERHUB_USERNAME ✓
# - DOCKERHUB_TOKEN ✓
# - RENDER_DEPLOY_HOOK_URL ✓
```

### 2. Test the Workflow Manually
1. Go to GitHub repository → **Actions** tab
2. Click **"Build and Deploy to Render"** workflow
3. Click **"Run workflow"** button
4. Select branch: `main`
5. Click **"Run workflow"**

### 3. Monitor Execution
1. The workflow will display live logs
2. Look for step **"Build and push Docker image"** - should show progress
3. Final step should show **"✅ Render deployment triggered successfully"**

### 4. Verify Docker Image
After successful build, check Docker Hub:
1. Go to [Docker Hub](https://hub.docker.com)
2. Click your repositories
3. You should see `egram-service` with:
   - Tag: `latest`
   - Recent push timestamp
   - Image size (~650MB for multi-stage build)

### 5. Check Render Deployment
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click your **egram-service** Web Service
3. Look at **Deployments** tab
4. Latest deployment should be from the workflow trigger
5. Check status: **Building** → **Deploying** → **Live**

---

## 🔍 Troubleshooting

### ❌ Workflow Fails: "Authentication to Docker Hub failed"
**Cause**: Invalid `DOCKERHUB_TOKEN` or `DOCKERHUB_USERNAME`

**Fix**:
1. Verify secrets in Settings → Secrets
2. Test Docker Hub login locally:
   ```bash
   docker login -u ${{ secrets.DOCKERHUB_USERNAME }}
   # Enter token when prompted
   ```
3. Regenerate token if expired:
   - Docker Hub → Settings → Security → New Access Token

---

### ❌ Workflow Fails: "Maven build failed"
**Cause**: Java compilation or dependency issues

**Fix**:
1. Check Maven logs in workflow output
2. Run locally: `mvn clean package -DskipTests`
3. Verify Java version in `pom.xml` (currently: 21)
4. Check for failing tests if not skipped

---

### ❌ Workflow Fails: "Docker build failed"
**Cause**: Dockerfile or build context issues

**Fix**:
1. Verify Dockerfile exists at project root
2. Run locally: `docker build -t test .`
3. Check for missing files (mvnw, pom.xml, src/)
4. Review Dockerfile syntax

---

### ❌ Render Deployment Not Triggered
**Cause**: Invalid webhook URL or network error

**Fix**:
1. Test webhook URL locally:
   ```bash
   curl -sSf -X POST "YOUR_RENDER_HOOK_URL"
   ```
2. Verify URL is correct and not expired
3. Check Render dashboard for recent deployments
4. Look for webhook logs in Render

---

### ❌ Image Not Appearing on Docker Hub
**Cause**: Push step failed or authentication issue

**Fix**:
1. Check workflow logs for build-push step
2. Verify `DOCKERHUB_USERNAME` is correct
3. Confirm Docker Hub token has `Read, Write, Delete` permissions
4. Check Docker Hub repository for visibility settings

---

## 📊 Monitoring & Logs

### GitHub Actions Logs
1. Repository → **Actions** tab
2. Select workflow run
3. Click job **"build-and-deploy"**
4. Expand any step to see detailed logs

**Key log sections**:
- `Build with Maven` - Build output
- `Build and push Docker image` - Docker build progress
- `Trigger Render deploy` - Webhook response

### Docker Hub Activity
1. Docker Hub → Repositories → **egram-service**
2. Click **Activity** tab
3. See push timestamps and image sizes

### Render Deployment Logs
1. Render Dashboard → **egram-service** → **Deployments**
2. Click latest deployment
3. View real-time deployment logs
4. Check `/actuator/health` endpoint after deployment

---

## 🔧 Advanced Configuration

### Change Image Name
To use a different Docker image name (e.g., `egram-backend`):

**Edit `.github/workflows/render-docker-deploy.yml`**:
```yaml
env:
  REGISTRY: docker.io
  IMAGE_NAME: egram-backend  # Change this
```

Result: `your_username/egram-backend:latest`

---

### Add Additional Triggers
To trigger on tags or pull requests, add to workflow:

```yaml
on:
  push:
    branches:
      - main
    tags:
      - 'v*'          # Trigger on version tags
  pull_request:       # Run on PR (without push to registry)
    branches:
      - main
  workflow_dispatch:
```

---

### Conditional Deployment
To only deploy on version tags:

```yaml
- name: Trigger Render deploy
  if: startsWith(github.ref, 'refs/tags/v')
  run: curl -sSf -X POST "${{ secrets.RENDER_DEPLOY_HOOK_URL }}"
```

---

## 🛡️ Security Best Practices

✅ **Secrets Management**:
- Never commit secrets to repository
- Regenerate tokens annually
- Use separate tokens for different CI/CD tools

✅ **Permissions**:
- Docker Hub token: Only `Read, Write, Delete` (no admin)
- GitHub workflow: Minimal permissions needed

✅ **Image Security**:
- Use `eclipse-temurin` as base (regularly updated)
- Multi-stage builds exclude build tools from final image
- Run container as non-root user

✅ **Webhook Security**:
- Render webhook URL contains unique key - keep it private
- Don't share deployment URLs in public channels
- Regenerate if accidentally exposed

---

## 📝 Summary

1. **Set 3 GitHub Secrets** (DOCKERHUB_USERNAME, DOCKERHUB_TOKEN, RENDER_DEPLOY_HOOK_URL)
2. **Commit workflow file** to `.github/workflows/render-docker-deploy.yml`
3. **Push to main** to trigger first build
4. **Monitor** GitHub Actions and Render Dashboard
5. **Done!** - Automatic builds and deployments on every push to main

---

**Questions?**
- GitHub Actions docs: https://docs.github.com/en/actions
- Docker Hub: https://hub.docker.com
- Render docs: https://render.com/docs

**Last Updated**: November 16, 2025

