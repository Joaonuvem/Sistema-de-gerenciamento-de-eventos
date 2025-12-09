-- Função: Calcular Vagas Restantes
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

-- Função: Resumo do Participante
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