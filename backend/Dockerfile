# ---- Stage 1: Build ----
FROM node:20-alpine AS builder

WORKDIR /app

# Copia apenas os manifests primeiro para aproveitar o cache do Docker
COPY package.json package-lock.json ./

RUN npm ci --omit=dev=false

COPY tsconfig.json ./
COPY src/ ./src/

RUN npm run build

# ---- Stage 2: Production ----
FROM node:20-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

COPY package.json package-lock.json ./

# Instala somente dependências de produção
RUN npm ci --omit=dev && npm cache clean --force

# Copia o artefato compilado
COPY --from=builder /app/dist ./dist

# Usuário não-root para segurança
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3001

CMD ["node", "dist/server.js"]
