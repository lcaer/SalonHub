CREATE OR REPLACE TRIGGER trg_bloquear_edicao_item_prof
BEFORE INSERT OR UPDATE OR DELETE ON item_profissional
FOR EACH ROW
DECLARE
    v_status_atendimento VARCHAR2(20);
    v_id_atend NUMBER;
BEGIN
    -- Descobre o ID do atendimento dependendo da operação
    IF DELETING THEN
        v_id_atend := :OLD.id_atend;
    ELSE
        v_id_atend := :NEW.id_atend;
    END IF;

    -- Busca o status do atendimento
    SELECT status INTO v_status_atendimento
    FROM atendimento
    WHERE id_atend = v_id_atend;

    -- Se o atendimento já estiver concluído ou cancelado, bloqueia
    IF v_status_atendimento = 'CONCLUIDO' OR v_status_atendimento = 'CANCELADO' THEN
        RAISE_APPLICATION_ERROR(-20021, 'Não é permitido alterar profissionais de atendimento ' || v_status_atendimento);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_bloquear_edicao_atend_item
BEFORE INSERT OR UPDATE OR DELETE ON atendimento_item
FOR EACH ROW
DECLARE
    v_status_atendimento VARCHAR2(20);
    v_id_atend NUMBER;
BEGIN
    -- Descobre o ID do atendimento dependendo da operação
    IF DELETING THEN
        v_id_atend := :OLD.id_atend;
    ELSE
        v_id_atend := :NEW.id_atend;
    END IF;

    -- Busca o status do atendimento
    SELECT status INTO v_status_atendimento
    FROM atendimento
    WHERE id_atend = v_id_atend;

    -- Se o atendimento já estiver concluído ou cancelado, bloqueia
    IF v_status_atendimento = 'CONCLUIDO' OR v_status_atendimento = 'CANCELADO' THEN
        RAISE_APPLICATION_ERROR(-20020, 'Não é permitido alterar itens de atendimento ' || v_status_atendimento);
    END IF;
END;
/
