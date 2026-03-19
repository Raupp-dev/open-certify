# apps/backend/Dockerfile

# ─── Stage base ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./

# ─── Stage desenvolvimento ────────────────────────────────────────────────────
FROM base AS development
# Instala TODAS as dependências (incluindo devDeps para ts-node-dev, nodemon etc.)
RUN npm ci
COPY . .
EXPOSE 3001
CMD ["npm", "run", "dev"]

# ─── Stage build ─────────────────────────────────────────────────────────────
FROM base AS builder
RUN npm ci
COPY . .
RUN npm run build

# ─── Stage produção ───────────────────────────────────────────────────────────
FROM node:20-alpine AS production
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY --from=builder /app/dist ./dist
EXPOSE 3001
CMD ["node", "dist/server.js"]
