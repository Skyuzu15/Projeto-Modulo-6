-- =============================================================
-- Schema do banco de dados — Projeto Módulo 5
-- Executado automaticamente ao iniciar o container MySQL
-- =============================================================

CREATE DATABASE IF NOT EXISTS `projeto_db`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `projeto_db`;

-- ---- Usuários ----
CREATE TABLE IF NOT EXISTS usuarios (
  id          INT          NOT NULL AUTO_INCREMENT,
  nome        VARCHAR(100) NOT NULL,
  email       VARCHAR(150) NOT NULL,
  senha       VARCHAR(255) NOT NULL,   -- hash bcrypt
  cpf         VARCHAR(14)  NOT NULL,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_email (email),
  UNIQUE KEY uq_cpf   (cpf)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Produtos ----
CREATE TABLE IF NOT EXISTS produtos (
  id          INT             NOT NULL AUTO_INCREMENT,
  usuario_id  INT             NOT NULL,
  nome        VARCHAR(150)    NOT NULL,
  descricao   TEXT,
  preco       DECIMAL(10, 2)  NOT NULL,
  quantidade  INT             NOT NULL DEFAULT 0,
  categoria   VARCHAR(100)    NOT NULL DEFAULT 'Sem categoria',
  created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_produto_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Pedidos ----
CREATE TABLE IF NOT EXISTS pedidos (
  id           INT            NOT NULL AUTO_INCREMENT,
  usuario_id   INT            NOT NULL,
  produto_id   INT            NOT NULL,
  quantidade   INT            NOT NULL,
  valor_total  DECIMAL(10, 2) NOT NULL,
  status       ENUM('pendente','aprovado','enviado','entregue','cancelado') NOT NULL DEFAULT 'pendente',
  created_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_pedido_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  CONSTRAINT fk_pedido_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---- Dados de exemplo (opcional) ----
-- INSERT INTO usuarios (nome, email, senha, cpf) VALUES
--   ('Admin', 'admin@exemplo.com', '$2b$10$...hash...', '000.000.000-00');
