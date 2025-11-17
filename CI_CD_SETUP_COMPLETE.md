# CI/CD Workflow Complete - GitHub Actions + Render Deployment

## 📦 Files Created

### 1. `.github/workflows/render-docker-deploy.yml` ⭐ (Main Workflow)
**Production-ready GitHub Actions workflow** with 9 steps:

```
✓ Checkout repository
✓ Setup Java 17 & Maven with dependency caching
✓ Build Spring Boot app (mvn clean package -DskipTests)
✓ Setup Docker Buildx
✓ Login to Docker Hub
✓ Extract metadata (generate tags)
✓ Build & Push Docker image to Docker Hub
✓ Trigger Render deployment via webhook
✓ Post status summary to GitHub
```

**Triggers**:
- ✅ Automatic: On `push` to `main` branch
- ✅ Manual: Via `workflow_dispatch` in GitHub Actions UI

**Outputs**:
- Docker image: `docker.io/{username}/egram-service:latest`
- Render deployment automatically triggered

---

### 2. `.github/SETUP_GUIDE.md` (Detailed Configuration)
**Comprehensive setup documentation** covering:
- How to create Docker Hub Personal Access Token
- How to set GitHub secrets (3 required)
- How to get Render webhook URL
- Step-by-step verification process
- Troubleshooting guide
- Advanced configuration options
- Security best practices

---

### 3. `.github/SECRETS_QUICK_REF.md` (Quick Reference)
**TL;DR guide** with:
- 3-step quick setup
- Secrets reference table
- Testing the workflow
- Troubleshooting checklist
- Common issues & solutions

---

## 🔐 Required GitHub Secrets (3 Total)

Set these in: **Settings → Secrets and Variables → Actions**

| # | Secret Name | Source | Instructions |
|---|------------|--------|--------------|
| 1 | `DOCKERHUB_USERNAME` | Docker Hub Profile | Your Docker Hub username |
| 2 | `DOCKERHUB_TOKEN` | Docker Hub Security | Create Personal Access Token at hub.docker.com/settings/security |
| 3 | `RENDER_DEPLOY_HOOK_URL` | Render Dashboard | Get from: Web Service → Settings → Deploy Hook |

### Quick Secret Setup:

```bash
# 1. Create Docker Hub Token
#    Go to: https://hub.docker.com/settings/security
#    Name: "GitHub-Actions-egram"
#    Permissions: Read, Write, Delete
#    Copy token (format: dckr_pat_xxx...)

# 2. Get Render Webhook
#    Render Dashboard → egram-service → Settings → Deploy Hook
#    Copy full URL (https://api.render.com/deploy/srv-xxx?key=xxx)

# 3. Set in GitHub
#    Repo → Settings → Secrets and Variables → Actions → New repository secret
```

---

## 🚀 Getting Started

### Step 1: Add GitHub Secrets
1. Go to: GitHub Repository → **Settings**
2. Click: **Secrets and Variables** → **Actions**
3. Click: **New repository secret** (3 times)
4. Add:
   - `DOCKERHUB_USERNAME` = your_docker_hub_username
   - `DOCKERHUB_TOKEN` = dckr_pat_xxxxxxxxxxxx
   - `RENDER_DEPLOY_HOOK_URL` = https://api.render.com/deploy/srv-xxx?key=xxx

### Step 2: Commit Workflow
```bash
git add .github/workflows/render-docker-deploy.yml
git commit -m "Add GitHub Actions CI/CD workflow"
git push origin main
```

### Step 3: Monitor First Build
1. Go to: Repository → **Actions** tab
2. You'll see: **"Build and Deploy to Render"** workflow running
3. Watch the progress (takes ~5-10 minutes)
4. After success:
   - ✅ Docker image pushed to Docker Hub
   - ✅ Render deployment triggered
   - ✅ App live on Render

---

## 📊 Workflow Execution Flow

```
GitHub Push to main
    ↓
Trigger workflow_dispatch
    ↓
Checkout code
    ↓
Setup Java 17 + Maven (cache deps)
    ↓
Build JAR: mvn -B clean package -DskipTests
    ↓
Setup Docker Buildx (advanced build features)
    ↓
Login to Docker Hub (using secrets)
    ↓
Extract metadata (generate tags)
    ↓
Build Docker image using Dockerfile
    ↓
Push to Docker Hub: docker.io/username/egram-service:latest
    ↓
Trigger Render webhook: curl -X POST $RENDER_DEPLOY_HOOK_URL
    ↓
Render receives deployment request
    ↓
Render pulls image from Docker Hub
    ↓
Render deploys container
    ↓
App goes Live ✅
```

---

## ⚙️ Workflow Configuration

### Image Name
To change Docker image name, edit the workflow:

**File**: `.github/workflows/render-docker-deploy.yml`

```yaml
env:
  REGISTRY: docker.io
  IMAGE_NAME: egram-service    # ← CHANGE THIS
```

Result: `docker.io/your_username/egram-service:latest`

---

### Customize Triggers
To trigger on tags or pull requests:

```yaml
on:
  push:
    branches:
      - main
    tags:
      - 'v*'              # Add: trigger on version tags
  pull_request:           # Add: run on PRs (no push)
    branches:
      - main
  workflow_dispatch:
```

---

### Only Deploy on Version Tags
To skip deployment on regular commits:

```yaml
- name: Trigger Render deploy
  if: startsWith(github.ref, 'refs/tags/v')    # ← Add this condition
  run: curl -sSf -X POST "${{ secrets.RENDER_DEPLOY_HOOK_URL }}"
```

---

## ✅ Verification Checklist

After setup, verify everything works:

- [ ] 3 GitHub secrets are set (Settings → Secrets)
- [ ] Workflow file exists: `.github/workflows/render-docker-deploy.yml`
- [ ] Dockerfile exists at project root
- [ ] Code is pushed to main branch
- [ ] GitHub Actions shows workflow running
- [ ] Build completes successfully (green checkmark)
- [ ] Docker image appears on Docker Hub
- [ ] New deployment appears in Render Dashboard
- [ ] App is accessible and healthy

**Full verification**:
```bash
# 1. Check GitHub Actions
#    Repository → Actions → "Build and Deploy to Render"

# 2. Check Docker Hub
#    hub.docker.com/r/your_username/egram-service → latest tag

# 3. Check Render
#    dashboard.render.com → egram-service → Deployments tab

# 4. Test endpoint
#    curl https://your-render-url/actuator/health
```

---

## 🔍 Monitoring & Debugging

### GitHub Actions Logs
1. Repository → **Actions** tab
2. Click workflow run
3. Click job **"build-and-deploy"**
4. Expand any step to view logs

**Key steps to watch**:
- `Build with Maven` - Check for compilation errors
- `Build and push Docker image` - Check for Docker errors
- `Trigger Render deploy` - Check webhook response

### Docker Hub Activity
1. docker.io → Your repositories → **egram-service**
2. Click **Activity** tab
3. See recent pushes and image sizes

### Render Deployments
1. Render Dashboard → **egram-service**
2. Click **Deployments** tab
3. Click latest deployment
4. View real-time logs
5. Check `/actuator/health` endpoint

---

## 🛠️ Troubleshooting

### Docker Hub Login Fails
```
Error: "Invalid Docker credentials"
Fix: Verify DOCKERHUB_TOKEN is a PAT, not password
     Regenerate at: hub.docker.com/settings/security
```

### Maven Build Fails
```
Error: "BUILD FAILURE"
Fix: Run locally: mvn clean package -DskipTests
    Check Java version matches pom.xml (currently: 21)
    Check all dependencies can be resolved
```

### Dockerfile Not Found
```
Error: "Dockerfile: not found"
Fix: Verify Dockerfile exists at: PROJECT_ROOT/Dockerfile
    Check file name case sensitivity (Dockerfile, not dockerfile)
```

### Render Deploy Not Triggered
```
Error: Deployment webhook not called
Fix: Test URL locally: curl -X POST "YOUR_WEBHOOK_URL"
    Verify RENDER_DEPLOY_HOOK_URL secret is set correctly
    Check webhook URL includes ?key= parameter
    Check Render deploy hook is enabled
```

### Image Not Pushed to Docker Hub
```
Error: Image tag not found on Docker Hub
Fix: Check workflow logs for "Build and push" step
    Verify DOCKERHUB_USERNAME is correct
    Verify DOCKERHUB_TOKEN has Read, Write, Delete permissions
    Check Docker Hub login step succeeded
```

---

## 📚 Additional Resources

### Documentation
- GitHub Actions: https://docs.github.com/en/actions
- Docker Hub: https://hub.docker.com
- Render: https://render.com/docs
- Spring Boot: https://spring.io/projects/spring-boot

### Related Files
- ✅ `Dockerfile` - Multi-stage production build
- ✅ `.dockerignore` - Optimize build context
- ✅ `RENDER_DEPLOYMENT.md` - Render deployment guide
- ✅ `.github/SETUP_GUIDE.md` - Detailed setup instructions
- ✅ `.github/SECRETS_QUICK_REF.md` - Quick reference

---

## 🎯 Summary

✅ **Workflow Created**: `.github/workflows/render-docker-deploy.yml`
✅ **Triggers**: Push to main + Manual dispatch
✅ **Features**: Maven build, Docker multi-stage, Docker Hub push, Render deploy
✅ **Secrets Required**: 3 (DOCKERHUB_USERNAME, DOCKERHUB_TOKEN, RENDER_DEPLOY_HOOK_URL)
✅ **Documentation**: Complete setup and troubleshooting guides included

**Next Step**: Set the 3 GitHub secrets and push code to main branch to start CI/CD!

---

**Status**: ✅ Production-Ready
**Last Updated**: November 16, 2025

