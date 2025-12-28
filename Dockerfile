# Use your existing Docker Hub image as base
FROM maortaieb/k8s-web-hello:latest

# Set working directory (optional)
WORKDIR /app

# Copy your app files (if needed)
# COPY . .

# Expose port your app uses
EXPOSE 3200

# Default command (adjust to your app)
CMD ["node", "index.js"]  # or your app's startup command
