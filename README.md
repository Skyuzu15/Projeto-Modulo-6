# Projeto Módulo 5 — DevOps & Docker

Aplicação Full Stack containerizada com Docker, Nginx como reverse proxy, HTTPS e boas práticas de segurança.

---

## Descrição

Sistema de gerenciamento de usuários, produtos e pedidos desenvolvido como projeto acadêmico do Módulo 5 (DevOps, Docker, Redes e Cibersegurança).

---

## Tecnologias

| Camada     | Tecnologia                     |
|------------|-------------------------------|
| Frontend   | React 19 + TypeScript          |
| Backend    | Node.js + Express + TypeScript |
| Banco      | MySQL 8.0                      |
| Proxy      | Nginx 1.25                     |
| Container  | Docker + Docker Compose        |
| Auth       | JWT (jsonwebtoken + bcryptjs)  |
| Validação  | Zod                            |
| Testes     | Jest + Supertest               |

---

## Estrutura

```
projeto/
├── backend/            # API Node.js/Express/TypeScript
│   ├── src/
│   │   ├── middlewares/
│   │   ├── models/
│   │   ├── services/
│   │   ├── tests/
│   │   ├── types/
│   │   ├── validations/
│   │   └── server.ts
│   ├── Dockerfile
│   ├── package.json
│   └── tsconfig.json
├── frontend/           # React SPA
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   └── package.json
├── nginx/              # Reverse Proxy
│   ├── Dockerfile
│   ├── nginx.conf
│   └── certs/         # Certificados SSL (não versionados)
├── scripts/
│   ├── database.sql          # Schema do banco
│   └── gerar-certificados.sh # Geração de certificados SSL
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## Como instalar

### Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) >= 24
- [Docker Compose](https://docs.docker.com/compose/) >= 2.20
- `openssl` (para gerar certificados)

### 1. Clonar o repositório

```bash
git clone <url-do-repositorio>
cd projeto
```

### 2. Configurar variáveis de ambiente

```bash
cp .env.example .env
# Edite .env e preencha senhas e segredos
```

### 3. Gerar certificados SSL

```bash
chmod +x scripts/gerar-certificados.sh
./scripts/gerar-certificados.sh
```

---

## Como executar

```bash
docker compose up --build
```

Acesse: **https://localhost**

> O browser exibirá um aviso sobre o certificado auto-assinado — clique em "Avançado" e prossiga.

Para parar sem perder dados:

```bash
docker compose down
```

Para parar E remover os dados do banco:

```bash
docker compose down -v
```

---

## Docker

### Serviços

| Container        | Descrição                            | Porta interna |
|------------------|--------------------------------------|---------------|
| `projeto_nginx`  | Reverse proxy (único ponto público)  | 80, 443       |
| `projeto_frontend` | React build estático via Nginx     | 80 (interno)  |
| `projeto_backend`  | API Express                        | 3001 (interno)|
| `projeto_mysql`    | Banco de dados MySQL               | 3306 (interno)|

### Fluxo de rede

```
Navegador
   ↓  (HTTPS :443)
Nginx  ←  único container com portas públicas
   ↓ /          ↓ /api/
Frontend      Backend
                 ↓
               MySQL
```

### Comandos úteis

```bash
# Ver logs de um serviço
docker compose logs -f backend

# Acessar o banco de dados
docker exec -it projeto_mysql mysql -u app_user -p projeto_db

# Reconstruir apenas um serviço
docker compose up --build backend
```

---

## HTTPS

Certificados auto-assinados gerados com OpenSSL e armazenados em `nginx/certs/` (ignorado pelo git).

Para produção, substitua por certificados do **Let's Encrypt** via Certbot.

O Nginx redireciona automaticamente toda requisição HTTP (porta 80) para HTTPS (porta 443).

---

## Variáveis de ambiente

| Variável             | Descrição                        |
|----------------------|----------------------------------|
| `MYSQL_ROOT_PASSWORD`| Senha root do MySQL              |
| `MYSQL_DATABASE`     | Nome do banco                    |
| `MYSQL_USER`         | Usuário da aplicação             |
| `MYSQL_PASSWORD`     | Senha do usuário da aplicação    |
| `JWT_SECRET`         | Segredo para assinatura dos JWTs |
| `JWT_EXPIRES_IN`     | Validade do token (ex: `7d`)     |
| `PORT`               | Porta do backend (padrão: 3001)  |
| `DB_HOST`            | Host do MySQL (padrão: `mysql`)  |
| `DB_PORT`            | Porta do MySQL (padrão: `3306`)  |

> **Nunca** versione o arquivo `.env` — ele está no `.gitignore`.

---

## Banco de Dados

O arquivo `scripts/database.sql` contém o schema completo e é executado automaticamente na primeira inicialização do container MySQL.

Tabelas:

- `usuarios` — cadastro com email/CPF únicos e senha em hash bcrypt
- `produtos` — catálogo de produtos por usuário
- `pedidos` — pedidos vinculados a produto e usuário, com controle de estoque

Os dados persistem em um volume Docker (`projeto_mysql_data`) mesmo após `docker compose down`.

---

## Segurança

### Cabeçalhos HTTP (configurados no Nginx)

| Cabeçalho                 | Função                                                                                  |
|---------------------------|-----------------------------------------------------------------------------------------|
| `X-Frame-Options`         | Impede que a página seja embutida em `<iframe>` de outros domínios (anti-clickjacking) |
| `X-Content-Type-Options`  | Desativa MIME sniffing — o browser respeita o `Content-Type` declarado                 |
| `Referrer-Policy`         | Controla quanta informação de origem é enviada ao navegar entre domínios                |
| `Content-Security-Policy` | Define quais recursos e origens são permitidos (scripts, estilos, imagens etc.)         |
| `X-XSS-Protection`        | Ativa o filtro XSS embutido em browsers legados                                         |
| `Strict-Transport-Security`| Força HTTPS por 1 ano em browsers que já visitaram o site (HSTS)                      |

### Outras práticas

- Senhas armazenadas com **bcrypt** (fator 10)
- Autenticação via **JWT** com expiração configurável
- Backend **não exposto** ao host — acessível apenas via Nginx na rede interna do Docker
- Usuário **não-root** no container do backend
- Segredos gerenciados exclusivamente via **variáveis de ambiente**

---

## Testes

```bash
# Rodar testes do backend
cd backend
npm test

# Modo watch
npm run test:watch
```

---

## Git

### .gitignore

Arquivos ignorados:

- `node_modules/`
- `.env`
- `dist/` e `build/`
- `coverage/`
- `logs/`
- `nginx/certs/` (certificados gerados localmente)

### GitFlow

| Branch        | Propósito                                 |
|---------------|-------------------------------------------|
| `main`        | Código estável / produção                 |
| `develop`     | Integração de features                    |
| `feature/*`   | Desenvolvimento de novas funcionalidades  |

Fluxo:

```bash
# Criar feature
git checkout develop
git checkout -b feature/minha-feature

# Trabalhar e commitar
git add .
git commit -m "feat: adiciona minha feature"

# Merge na develop
git checkout develop
git merge --no-ff feature/minha-feature
git branch -d feature/minha-feature

# Release para main
git checkout main
git merge --no-ff develop
git tag -a v1.0.0 -m "Release v1.0.0"
```

---

## Solução de Problemas

**Porta 80/443 em uso:**

```bash
sudo lsof -i :80
sudo lsof -i :443
```

**Container MySQL não inicia (healthcheck falhando):**

```bash
docker compose logs mysql
# Aguarde mais tempo; o MySQL demora ~30s no primeiro boot
```

**Erro de certificado no Nginx:**

```bash
# Verifique se os certificados existem
ls nginx/certs/
# Se não existirem, execute:
./scripts/gerar-certificados.sh
```

**Limpar tudo e recomeçar:**

```bash
docker compose down -v --remove-orphans
docker system prune -f
docker compose up --build
```
