/* 1. Implmentação de drops para poder rodar o codigo 
varias vezes sem precisar apagar ou comentar as tabelas */

-- ATENÇÂO: O CASCADE é essencial aqui: ele força o apagamento mesmo se houver ligações
-- roda mesmo sem o drop view.
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

-- 2. CRIAÇÃO DAS TABELAS

-- Tabela de Categorias
CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
);

-- Tabela dos Locais
CREATE TABLE locais (
    id_local SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    capacidade INT NOT NULL
);

-- Tabela de Participantes
CREATE TABLE participantes (
    id_participante SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,          
    email VARCHAR(100) NOT NULL UNIQUE,  
    cpf VARCHAR(14) NOT NULL UNIQUE
);

-- Tabelinha de eventos
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

-- Tabela de Inscrições
CREATE TABLE inscricoes (
    id_inscricao SERIAL PRIMARY KEY,
    data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fk_evento INT NOT NULL,
    fk_participante INT NOT NULL,
    FOREIGN KEY (fk_evento) REFERENCES eventos(id_evento),
    FOREIGN KEY (fk_participante) REFERENCES participantes(id_participante),
    UNIQUE(fk_evento, fk_participante)
);

-- 3. fazendo a inserção dos dados, ou seja, preenchendo o banco
INSERT INTO categorias (descricao) VALUES 
('Workshop'), ('Palestra'), ('Minicurso'), ('Congresso');

INSERT INTO locais (nome, endereco, capacidade) VALUES 
('Auditório Principal', 'Bloco A, Térreo', 100),
('Laboratório de Informática 1', 'Bloco C, 1º Andar', 30),
('Sala de Conferências', 'Bloco B, 2º Andar', 50);

INSERT INTO participantes (nome, email, cpf) VALUES 
('João Silva', 'joao.silva@email.com', '111.111.111-11'),
('Maria Oliveira', 'maria.oliveira@email.com', '222.222.222-22'),
('Carlos Souza', 'carlos.souza@email.com', '333.333.333-33'),
('Ana Pereira', 'ana.pereira@email.com', '444.444.444-44');

INSERT INTO eventos (titulo, data_hora, status, fk_local, fk_categoria) VALUES 
('Introdução ao SQL', '2025-11-20 14:00:00', 'Agendado', 2, 1),
('Futuro da Inteligência Artificial', '2025-11-21 19:00:00', 'Agendado', 1, 2),
('Gestão Ágil de Projetos', '2025-11-22 08:00:00', 'Cancelado', 3, 1),
('Segurança da Informação', '2025-12-01 10:00:00', 'Agendado', 1, 2);

-- a direita o evento, a esquerda os alunos
INSERT INTO inscricoes (fk_evento, fk_participante) VALUES 
(2, 1), (4, 2), (1, 1), (1, 3), (3, 4);

-- 4. CRIAÇÃO DAS VIEWS
--formatar a data
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

-- 5. TESTE FINAL (SELECT)
SELECT * FROM v_lista_presenca;

SELECT * FROM v_eventos_detalhados;

/* apartir daqui vamos implendo funções e gatilhos, 
depois eu reeorganizo melhor depois, hoje to cansado, preciso dormir */

-- 6. Criar Tabela de Logs 

CREATE TABLE logs_sistema (
    id_log SERIAL PRIMARY KEY,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(50),
    acao VARCHAR(100),
    detalhes TEXT
);

-- 7. FUNÇÃO: Calcular Vagas Restantes
CREATE OR REPLACE FUNCTION fn_vagas_restantes(p_id_evento INT) 
RETURNS INT AS $$
DECLARE
    v_capacidade INT;
    v_inscritos INT;
BEGIN
    SELECT l.capacidade INTO v_capacidade
    FROM eventos e JOIN locais l ON e.fk_local = l.id_local
    WHERE e.id_evento = p_id_evento;

    SELECT COUNT(*) INTO v_inscritos FROM inscricoes WHERE fk_evento = p_id_evento;

    RETURN GREATEST(v_capacidade - v_inscritos, 0);
END;
$$ LANGUAGE plpgsql;

-- 8. FUNÇÃO: Resumo do Participante
CREATE OR REPLACE FUNCTION fn_resumo_participante(p_id_participante INT)
RETURNS TEXT AS $$
DECLARE
    v_nome VARCHAR(100);
    v_qtd_eventos INT;
BEGIN
    SELECT nome INTO v_nome FROM participantes WHERE id_participante = p_id_participante;
    SELECT COUNT(*) INTO v_qtd_eventos FROM inscricoes WHERE fk_participante = p_id_participante;
    RETURN 'Participante: ' || v_nome || ' | Total de Eventos: ' || v_qtd_eventos;
END;
$$ LANGUAGE plpgsql;

-- Verificar as vagas restantes
SELECT fn_vagas_restantes(1) AS "Vagas Agora";

-- 9. GATILHO 1: Auditoria de Cancelamento (Salva no Log ao deletar)
CREATE OR REPLACE FUNCTION fn_log_cancelamento() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO logs_sistema (usuario, acao, detalhes)
    VALUES (current_user, 'CANCELAMENTO', 'Inscrição ID ' || OLD.id_inscricao || ' removida.');
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_auditoria_cancelamento
AFTER DELETE ON inscricoes
FOR EACH ROW EXECUTE FUNCTION fn_log_cancelamento();

-- 10. GATILHO 2: Bloqueio de Inscrição (Impede se não estiver 'Agendado')
CREATE OR REPLACE FUNCTION fn_bloqueia_evento_fechado() RETURNS TRIGGER AS $$
DECLARE
    v_status VARCHAR(20);
BEGIN
    SELECT status INTO v_status FROM eventos WHERE id_evento = NEW.fk_evento;
    IF v_status <> 'Agendado' THEN
        RAISE EXCEPTION 'Erro: Evento com status % não aceita inscrições.', v_status;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_verifica_status_evento
BEFORE INSERT ON inscricoes
FOR EACH ROW EXECUTE FUNCTION fn_bloqueia_evento_fechado();

/* PARTE 11: PLANO DE TESTES (validação Final)
 Aqui provamos que tudo funciona(ou pelo menos deveria, se Deus quiser)
 */

-- Teste A: Usando a Função de Vagas
SELECT fn_vagas_restantes(1) AS "Vagas Restantes no Evento 1";

-- Teste B: Usando a Função de Resumo
SELECT fn_resumo_participante(1) AS "Resumo do João";

-- Teste C: Testando o Gatilho de Auditoria
-- Vamos apagar a inscrição 1 e ver se aparece no log
DELETE FROM inscricoes WHERE id_inscricao = 1;
SELECT * FROM logs_sistema; -- Deve aparecer o log aqui!

-- Teste D: Testando o Gatilho de Bloqueio (Opcional - vai dar erro proposital)
-- Se você descomentar a linha abaixo, o script vai parar com ERRO (o que é bom, prova que funciona!)
-- INSERT INTO inscricoes (fk_evento, fk_participante) VALUES (3, 4);

-- Verificar se o João realmente sumiu da lista
SELECT * FROM v_lista_presenca;

-- 12. ANTES: Vamos ver como estão as coisas antes de mexer
SELECT * FROM v_lista_presenca; -- Mostra que o João (ID 1) está lá
SELECT fn_vagas_restantes(1) AS "Vagas ANTES da remoção"; -- Ex: Deve mostrar 98 (pois eram 100 - 2 inscritos)

-- 13. AÇÃO: O Grande Momento - Remover o João do Evento 1 (que é o ID 3)
DELETE FROM inscricoes WHERE id_inscricao = 3;

-- 14. DEPOIS: Vamos provar que funcionou
-- Prova A: O Gatilho dedurou?
SELECT * FROM logs_sistema; 

-- Prova B: O João sumiu da lista?
SELECT * FROM v_lista_presenca; 

-- Prova C: A vaga foi liberada? (O número tem que ser maior que o do passo 1)
SELECT fn_vagas_restantes(1) AS "Vagas DEPOIS da remoção";

-- 5. TESTE FINAL (SELECT)
SELECT * FROM v_lista_presenca;

/*O código chega ao fim aqui, mas após o termino das aulas
pretendo utiliza-lo para realização de um esrtudo de redes
neurais artificiais, mais no meu Github: Joaonuvem*/