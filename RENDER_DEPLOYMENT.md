# egram-service Docker Deployment Guide for Render

## Overview
This document provides instructions for deploying the egram-service Spring Boot application as a Docker container on the Render platform.

## Project Details
- **Application**: egram-service (Spring Boot 3.5.7)
- **Java Version**: 22
- **Build Tool**: Maven 3.9.6
- **Database**: PostgreSQL
- **Framework**: Spring Boot with JPA, Security, Validation, AOP

## Docker Image Build

### Local Build & Test

#### Build the Docker image:
```bash
docker build -t egram-service:latest .
```

#### Run locally with environment variables:
```bash
docker run \
  -e PORT=8080 \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=your_password \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/egram_service \
  -p 8080:8080 \
  egram-service:latest
```

#### Test the application:
```bash
# Health check
curl http://localhost:8080/actuator/health

# Swagger/OpenAPI documentation
curl http://localhost:8080/swagger-ui.html
```

## Deployment on Render

### Prerequisites
1. Create a Docker image repository on Docker Hub or use Render's built-in container registry
2. Render account with a new "Web Service" ready to deploy

### Deployment Steps

#### Option 1: Using Render's GitHub Integration (Recommended)
1. Push the repository to GitHub
2. In Render Dashboard:
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select the egram-service repository
   - Configure:
     - **Name**: egram-service
     - **Environment**: Docker
     - **Region**: Choose closest region
     - **Branch**: main (or your deployment branch)

#### Option 2: Using Docker Image Registry
1. Build and push image to Docker Hub:
   ```bash
   docker build -t your-dockerhub-username/egram-service:latest .
   docker push your-dockerhub-username/egram-service:latest
   ```

2. In Render Dashboard:
   - Click "New +" → "Web Service"
   - Select "Docker Image"
   - Enter image URL: `your-dockerhub-username/egram-service:latest`
   - Configure similar settings as above

### Environment Variables Configuration

Set these environment variables in Render's dashboard under "Environment":

```
# Database Configuration
DB_USERNAME=<your-db-username>
DB_PASSWORD=<your-secure-db-password>
SPRING_DATASOURCE_URL=jdbc:postgresql://<host>:<port>/<database>?currentSchema=egram_service

# Java Options (Optional - for memory tuning)
JAVA_OPTS=-Xmx512m -Xms256m

# Render will automatically set PORT=10000 (or similar)
# The Dockerfile forwards this to Spring Boot's server.port
```

### Health Checks

The Dockerfile includes a health check that pings the `/actuator/health` endpoint.

**Render Configuration** (in Web Service settings):
- **Health Check Path**: `/actuator/health`
- **Check Interval**: 30s
- **Timeout**: 5s
- **Failure Threshold**: 3

### Dockerfile Key Features

✅ **Multi-stage Build**
- Build stage: Maven with JDK 22
- Runtime stage: Eclipse Temurin JRE 22 Alpine (minimal, ~200MB)
- Reduces final image size significantly

✅ **Security**
- Non-root user (appuser) runs the application
- Minimal base image (Alpine Linux)

✅ **Render Compatibility**
- Dynamic port binding via `$PORT` environment variable
- Proper ENTRYPOINT for containerized execution
- Health check included

✅ **Performance**
- Layer caching optimized (dependencies cached separately)
- Memory limits: 512MB max heap / 256MB min heap (adjustable)
- Clean package build with `-DskipTests`

## Troubleshooting

### Build Fails
- Ensure `pom.xml` is at project root
- Check Maven dependencies: `mvn dependency:tree`
- Verify Java 22 compatibility

### Application Won't Start
- Check logs in Render dashboard
- Verify database credentials and connection URL
- Ensure actuator health endpoint responds: `curl -v http://localhost:$PORT/actuator/health`

### Port Not Exposed
- Verify `PORT` environment variable is set in Render
- Check Dockerfile ENTRYPOINT uses `-Dserver.port=${PORT:-8080}`
- Default fallback is 8080 if PORT not set

### Memory Issues
- Increase Render instance tier to have more RAM
- Adjust `JAVA_OPTS` in environment: `-Xmx1g -Xms512m`

## Additional Notes

- **Database Migrations**: Flyway is configured (see `application.yaml` - `flyway.enabled: true`)
- **Logging**: Currently set to DEBUG level for `com.egram` package
- **API Documentation**: OpenAPI/Swagger available at `/swagger-ui.html`

## Monitoring & Logs

View logs in Render Dashboard:
- **Logs Tab**: Real-time application output
- **Metrics**: CPU, Memory, Network usage

## Scaling

For production:
1. Enable auto-scaling (if available in Render tier)
2. Configure PostgreSQL connection pool:
   - `hikari.maximum-pool-size: 20` (adjust per instance)
   - `hikari.minimum-idle: 5`

---

**Last Updated**: November 16, 2025

