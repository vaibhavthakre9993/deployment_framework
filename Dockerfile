FROM owasp/modsecurity-crs:nginx-alpine

# Switch to root to install packages and run Node.js alongside Nginx
USER root

WORKDIR /app

# Install Node.js, npm, and yq for config parsing
ENV CURL_CA_BUNDLE=""
ENV SSL_CERT_FILE=""
RUN apk update && \
    apk add --no-cache nodejs npm curl && \
    curl -L --insecure https://github.com/mikefarah/yq/releases/download/v4.35.2/yq_linux_amd64 -o /usr/bin/yq && \
    chmod +x /usr/bin/yq

# Copy application files
COPY . .

# Install dependencies if package.json exists
RUN if [ -f "package.json" ]; then npm install --production; fi

# Create custom entrypoint that starts Node.js, configures ModSecurity, and starts Nginx
RUN echo '#!/bin/sh' > /app-entrypoint.sh && \
    echo 'export NODE_PORT=$(yq e ".port" config.yml)' >> /app-entrypoint.sh && \
    echo 'export APP_NAME=$(yq e ".app_name" config.yml)' >> /app-entrypoint.sh && \
    echo 'echo "Starting Node.js application: $APP_NAME on internal port: $NODE_PORT"' >> /app-entrypoint.sh && \
    echo 'if [ -f "package.json" ]; then' >> /app-entrypoint.sh && \
    echo '  PORT=$NODE_PORT npm start &' >> /app-entrypoint.sh && \
    echo 'else' >> /app-entrypoint.sh && \
    echo '  PORT=$NODE_PORT node index.js &' >> /app-entrypoint.sh && \
    echo 'fi' >> /app-entrypoint.sh && \
    echo '' >> /app-entrypoint.sh && \
    echo '# Configure ModSecurity and Nginx proxy to Node.js' >> /app-entrypoint.sh && \
    echo 'export BACKEND=http://127.0.0.1:$NODE_PORT' >> /app-entrypoint.sh && \
    echo 'export SEC_RULE_ENGINE=On' >> /app-entrypoint.sh && \
    echo 'export PORT=8080' >> /app-entrypoint.sh && \
    echo '' >> /app-entrypoint.sh && \
    echo '# Start original CRS entrypoint which sets up Nginx and ModSecurity' >> /app-entrypoint.sh && \
    echo 'exec /docker-entrypoint.sh nginx -g "daemon off;"' >> /app-entrypoint.sh && \
    chmod +x /app-entrypoint.sh

# Expose port 8080 for Nginx (Node.js runs internally on port 3000)
EXPOSE 8080

ENTRYPOINT ["/app-entrypoint.sh"]
