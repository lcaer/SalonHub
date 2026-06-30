CREATE OR REPLACE TRIGGER TRG_ITEM_ATUALIZA_FIM
AFTER INSERT OR UPDATE OF DELETADO_EM ON ATENDIMENTO_ITEM
FOR EACH ROW
DECLARE
    v_duracao_minutos SERVICO.DURACAO_MINUTOS%TYPE;
    v_delta           NUMBER;
BEGIN
    IF INSERTING OR
       (UPDATING AND :OLD.DELETADO_EM IS NULL AND :NEW.DELETADO_EM IS NOT NULL)
    THEN
        SELECT DURACAO_MINUTOS
        INTO v_duracao_minutos
        FROM SERVICO
        WHERE ID_SERV = :NEW.ID_SERV;

        IF INSERTING THEN
            v_delta := v_duracao_minutos;
        ELSE
            v_delta := -v_duracao_minutos;
        END IF;

        UPDATE ATENDIMENTO
        SET DATA_HORA_FIM = COALESCE(DATA_HORA_FIM, DATA_HORA_INICIO) --retorna o primeiro valor da sequência que não for nulo
                            + NUMTODSINTERVAL(v_delta, 'MINUTE'), --incrementar, em minutos, o horario
            ATUALIZADO_EM = CURRENT_TIMESTAMP
        WHERE ID_ATEND = :NEW.ID_ATEND;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'SERVICO ID ' || :NEW.ID_SERV || ' não encontrado.'
        );
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'Erro ao atualizar DATA_HORA_FIM: ' || SQLERRM
        );
END TRG_ITEM_ATUALIZA_FIM;