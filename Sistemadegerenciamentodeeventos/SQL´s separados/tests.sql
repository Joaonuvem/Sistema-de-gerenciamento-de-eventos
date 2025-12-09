/* ARQUIVO 5: ROTEIRO DE TESTES */

-- 1. Testes de Inserção
-- Inserção válida
INSERT INTO participantes (nome, email, cpf) 
VALUES ('Teste da Silva', 'teste.silva@email.com', '999.999.999-99');

-- Inserção inválida (CPF duplicado) - DEVE DAR ERRO
-- INSERT INTO participantes (nome, email, cpf) 
-- VALUES ('Clone da Silva', 'clone@email.com', '999.999.999-99');

-- 2. Testes de Remoção
-- Remoção válida
DELETE FROM inscricoes WHERE fk_evento = 2 AND fk_participante = 1;

-- 3. Testes de Listagem e Views
SELECT * FROM v_lista_presenca;
SELECT * FROM v_eventos_detalhados;
SELECT * FROM v_relatorio_inscritos;

-- 4. Testes de Funções
-- Verificar vagas
SELECT fn_vagas_restantes(1) AS "Vagas Restantes Evento 1";
-- Verificar resumo
SELECT fn_resumo_participante(1) AS "Resumo Participante 1";

-- 5. Testes de Gatilhos
-- Teste Auditoria (apagar inscrição e checar log)
DELETE FROM inscricoes WHERE id_inscricao = 4;
SELECT * FROM logs_sistema;

-- Teste Bloqueio (tentar inscrever em evento Cancelado - ID 3) - DEVE DAR ERRO
-- INSERT INTO inscricoes (fk_evento, fk_participante) VALUES (3, 2);