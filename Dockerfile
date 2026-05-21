FROM node:18-alpine

# Install yq to parse config.yml
RUN apk add --no-cache curl && \
    curl -L https://github.com/mikefarah/yq/releases/download/v4.35.2/yq_linux_amd64 -o /usr/bin/yq && \
    chmod +x /usr/bin/yq

WORKDIR /app

# Copy application files
COPY . .

# Install dependencies if package.json exists
RUN if [ -f "package.json" ]; then npm install --production; fi

# Create an entrypoint script that reads port and app_name from config.yml
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'export PORT=$(yq e ".port" config.yml)' >> /entrypoint.sh && \
    echo 'export APP_NAME=$(yq e ".app_name" config.yml)' >> /entrypoint.sh && \
    echo 'echo "Starting application: $APP_NAME on port: $PORT"' >> /entrypoint.sh && \
    echo 'if [ -f "package.json" ]; then' >> /entrypoint.sh && \
    echo '  npm start' >> /entrypoint.sh && \
    echo 'else' >> /entrypoint.sh && \
    echo '  node index.js' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
