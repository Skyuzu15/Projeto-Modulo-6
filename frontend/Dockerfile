# ---- Stage 1: Build ----
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci

COPY tsconfig.json ./
COPY public/ ./public/
COPY src/ ./src/

# Variável disponível em build-time para o React
ARG REACT_APP_API_URL=/api
ENV REACT_APP_API_URL=$REACT_APP_API_URL

RUN npm run build

# ---- Stage 2: Serve via Nginx ----
FROM nginx:1.25-alpine AS production

# Remove configuração padrão do Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copia configuração específica para o SPA React
COPY nginx-spa.conf /etc/nginx/conf.d/default.conf

# Copia o build estático
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
