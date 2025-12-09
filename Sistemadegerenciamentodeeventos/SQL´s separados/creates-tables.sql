
-- Drops para limpeza (garantir que o banco está limpo antes de criar)
DROP VIEW IF EXISTS v_usuarios_gmail CASCADE;
DROP VIEW IF EXISTS v_relatorio_inscritos CASCADE;
DROP VIEW IF EXISTS v_lista_presenca CASCADE;
DROP VIEW IF EXISTS v_eventos_detalhados CASCADE;
DROP TABLE IF EXISTS inscricoes CASCADE;
DROP TABLE IF EXISTS eventos CASCADE;
DROP TABLE IF EXISTS participantes CASCADE;
DROP TABLE IF EXISTS locais CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
DROP TABLE IF EXISTS logs_sistema CASCADE;

-- 1. CRIAÇÃO DAS TABELAS

CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
);

CREATE TABLE locais (
    id_local SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    capacidade INT NOT NULL
);

CREATE TABLE participantes (
    id_participante SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,          
    email VARCHAR(100) NOT NULL UNIQUE,  
    cpf VARCHAR(14) NOT NULL UNIQUE
);

CREATE TABLE eventos (
    id_evento SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendado',
    fk_local INT NOT NULL,
    fk_categoria INT NOT NULL,
    FOREIGN KEY (fk_local) REFERENCES locais(id_local),
    FOREIGN KEY (fk_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE inscricoes (
    id_inscricao SERIAL PRIMARY KEY,
    data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fk_evento INT NOT NULL,
    fk_participante INT NOT NULL,
    FOREIGN KEY (fk_evento) REFERENCES eventos(id_evento),
    FOREIGN KEY (fk_participante) REFERENCES participantes(id_participante),
    UNIQUE(fk_evento, fk_participante)
);

CREATE TABLE logs_sistema (
    id_log SERIAL PRIMARY KEY,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(50),
    acao VARCHAR(100),
    detalhes TEXT
);

-- 2. CRIAÇÃO DAS VIEWS

CREATE OR REPLACE VIEW v_eventos_detalhados AS
SELECT 
    e.id_evento, e.titulo, e.data_hora, e.status,
    l.nome AS local, c.descricao AS categoria
FROM eventos e
JOIN locais l ON e.fk_local = l.id_local
JOIN categorias c ON e.fk_categoria = c.id_categoria;

CREATE OR REPLACE VIEW v_lista_presenca AS
SELECT 
    i.id_inscricao, p.nome AS participante, p.email,
    e.titulo AS evento, e.data_hora
FROM inscricoes i
JOIN participantes p ON i.fk_participante = p.id_participante
JOIN eventos e ON i.fk_evento = e.id_evento;

CREATE OR REPLACE VIEW v_relatorio_inscritos AS
SELECT 
    e.titulo AS evento, COUNT(i.id_inscricao) AS total_inscritos
FROM eventos e
LEFT JOIN inscricoes i ON e.id_evento = i.fk_evento
GROUP BY e.titulo;

CREATE OR REPLACE VIEW v_usuarios_gmail AS
SELECT * FROM participantes WHERE email LIKE '%@gmail.com%';