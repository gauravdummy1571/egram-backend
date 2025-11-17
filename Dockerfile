# Production-ready multi-stage Dockerfile for egram-service Spring Boot application
# Optimized for deployment on Render platform
# Uses Maven 3.9.6 with JDK 22 for build stage and Eclipse Temurin JRE 22 for runtime

# Build Arguments
ARG JAVA_VERSION=21
ARG MAVEN_IMAGE=maven:3.9.6-eclipse-temurin-${JAVA_VERSION}
ARG RUNTIME_IMAGE=eclipse-temurin:${JAVA_VERSION}-jre-alpine

FROM ${MAVEN_IMAGE} AS builder
WORKDIR /workspace

# Copy Maven wrapper and configuration files
COPY mvnw mvnw.cmd ./
COPY .mvn .mvn/
COPY pom.xml ./

# Copy source code
COPY src ./src

# Build the application: clean, package, skip tests for faster builds
# -B for batch mode, -DskipTests to skip test execution during build
RUN mvn -B clean package -DskipTests

# ============================================================================
# STAGE 2: Runtime Stage (Final Image)
# ============================================================================
FROM ${RUNTIME_IMAGE}

WORKDIR /app

# Create a non-root user for security best practices
RUN addgroup -g 1001 appuser && \
    adduser -D -u 1001 -G appuser appuser

# Copy the built JAR from the builder stage
# Spring Boot Maven plugin creates a fat JAR with the pattern: *-SNAPSHOT.jar
COPY --from=builder --chown=appuser:appuser /workspace/target/egram-service-*.jar app.jar

# Set ownership for the app directory
RUN chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Expose the default port (Render will provide $PORT environment variable at runtime)
EXPOSE 8080

# Health check endpoint (Spring Boot Actuator /health endpoint)
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT:-8080}/actuator/health || exit 1

# Default environment variables
ENV JAVA_OPTS="-Xmx512m -Xms256m"
ENV PORT=8080

# Run the application with dynamic port binding for Render
# Render sets PORT environment variable at runtime
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -Dserver.port=${PORT:-8080} -jar /app/app.jar"]

