ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '1608';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS techcycle;
USE techcycle;

CREATE TABLE IF NOT EXISTS materiais (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255),
    quantidade INT
);
CREATE TABLE IF NOT EXISTS usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL
);
USE techcycle;

-- Recriar a tabela de chamados se necessário
DROP TABLE IF EXISTS chamados;

CREATE TABLE IF NOT EXISTS chamados (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome_chamado VARCHAR(255) NOT NULL,
  tipo VARCHAR(100),
  marca VARCHAR(100),
  data_abertura DATE,
  dashboard VARCHAR(255),
  problema TEXT,
  prioridade VARCHAR(50) DEFAULT 'Média',
  status VARCHAR(50) DEFAULT 'Aberto',
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

