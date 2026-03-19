# ── Development stage (Vite dev server with HMR) ─────────────────────────────
FROM node:20-alpine AS dev
WORKDIR /app

# Install dependencies first (layer-cached)
COPY package*.json ./
RUN npm install

# Copy source (in Docker Compose, the project directory is bind-mounted over this)
COPY . .

EXPOSE 5173

# Bind to all interfaces so Docker port-forwarding works, and enable polling
# for file-change detection inside Docker volumes on Windows/macOS hosts.
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
