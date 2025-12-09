-- 1. Gatilho de Auditoria de Cancelamento
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


-- 2. Gatilho de Bloqueio de Inscrição em Eventos Fechados
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