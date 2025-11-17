# GitHub Secrets Configuration - Quick Reference

## TL;DR - 3 Steps to Enable CI/CD

### Step 1: Create Docker Hub Token
```
1. Go to: https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name: "GitHub-Actions-egram"
4. Permissions: Read, Write, Delete
5. Click Generate and Copy token
```

### Step 2: Add GitHub Secrets
```
Go to: GitHub Repo → Settings → Secrets and Variables → Actions
Click "New repository secret" for each:

Secret 1:
  Name: DOCKERHUB_USERNAME
  Value: your_docker_hub_username

Secret 2:
  DOCKERHUB_TOKEN
  Value: dckr_pat_xxxxxxxxxxxx (from Step 1)

Secret 3:
  RENDER_DEPLOY_HOOK_URL
  Value: https://api.render.com/deploy/srv-xxx?key=xxx
```

### Step 3: Get Render Webhook
```
1. Go to: Render Dashboard
2. Select: egram-service Web Service
3. Go to: Settings
4. Find: Deploy Hook section
5. Copy: Full webhook URL
6. Paste: Into RENDER_DEPLOY_HOOK_URL secret
```

---

## Secrets Reference Table

| Secret Name | Source | Format | Example |
|------------|--------|--------|---------|
| `DOCKERHUB_USERNAME` | Docker Hub Profile | Text | `john_doe_docker` |
| `DOCKERHUB_TOKEN` | Docker Hub → Security | Token | `dckr_pat_abcdef123456` |
| `RENDER_DEPLOY_HOOK_URL` | Render → Settings | Full URL | `https://api.render.com/deploy/srv-abc?key=xyz` |

---

## After Setup: Test the Workflow

1. **Push to main**:
   ```bash
   git add .
   git commit -m "Enable CI/CD workflow"
   git push origin main
   ```

2. **Monitor GitHub Actions**:
   - Go to: Repository → Actions tab
   - Watch: "Build and Deploy to Render" workflow
   - Status: Running → Passed ✓

3. **Verify Docker Image**:
   - Go to: https://hub.docker.com/r/your_username/egram-service
   - Check: `latest` tag is present
   - Size: ~650MB

4. **Check Render Deployment**:
   - Go to: Render Dashboard → egram-service
   - Check: Deployments tab shows recent build
   - Status: Should be "Live" or "Deploying"

---

## Troubleshooting Checklist

- [ ] Secrets are set (Settings → Secrets → 3 secrets visible)
- [ ] DOCKERHUB_TOKEN is a PAT, not password
- [ ] RENDER_DEPLOY_HOOK_URL is full URL with ?key= parameter
- [ ] Dockerfile exists at project root
- [ ] pom.xml exists at project root
- [ ] Java version in pom.xml is 21 or 22 (✓ for this project)
- [ ] No uncommitted changes in workflow file

---

## Common Issues

| Error | Solution |
|-------|----------|
| "Invalid Docker credentials" | Check DOCKERHUB_USERNAME and DOCKERHUB_TOKEN are correct |
| "Maven build failed" | Run `mvn clean package -DskipTests` locally to debug |
| "Dockerfile not found" | Verify Dockerfile exists at project root (C:\egram\main\egram-service\Dockerfile) |
| "Render deploy failed" | Test webhook: `curl -X POST "YOUR_WEBHOOK_URL"` |
| "Image not pushed" | Check Docker Hub permissions and token expiration |

---

## Files Included

✅ `.github/workflows/render-docker-deploy.yml` - Main CI/CD workflow
✅ `.github/SETUP_GUIDE.md` - Detailed setup instructions
✅ `.github/SECRETS_QUICK_REF.md` - This file
✅ `Dockerfile` - Production-ready multi-stage build
✅ `.dockerignore` - Optimize build context
✅ `RENDER_DEPLOYMENT.md` - Deployment documentation

---

**Status**: Ready to configure secrets and deploy!

