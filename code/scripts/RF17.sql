CREATE OR REPLACE PROCEDURE reordena_agenda_profissional(
    p_id_prof         IN NUMBER,
    p_ref_fim         IN TIMESTAMP,
    p_id_atend_origem IN NUMBER
) IS
    v_prev_fim    TIMESTAMP := p_ref_fim;
    v_duracao     INTERVAL DAY TO SECOND;
    v_novo_inicio TIMESTAMP;
    v_novo_fim    TIMESTAMP;

    CURSOR c_subsequentes IS
        SELECT a.id_atend, a.data_hora_inicio, a.data_hora_fim
        FROM   atendimento a
        WHERE  a.deletado_em IS NULL
          AND  a.id_atend <> p_id_atend_origem
          AND  a.data_hora_inicio >= p_ref_fim
          AND  EXISTS (
                   SELECT 1
                   FROM   atendimento_item ai
                   JOIN   item_profissional ip
                          ON ip.id_item = ai.id_item
                         AND ip.deletado_em IS NULL
                   WHERE  ai.id_atend = a.id_atend
                     AND  ai.deletado_em IS NULL
                     AND  ip.id_prof = p_id_prof
               )
        ORDER BY a.data_hora_inicio ASC;

BEGIN
    FOR r IN c_subsequentes LOOP

        v_duracao := r.data_hora_fim - r.data_hora_inicio;

        IF r.data_hora_inicio < v_prev_fim THEN
            v_novo_inicio := v_prev_fim;
            v_novo_fim    := v_prev_fim + v_duracao;

            UPDATE atendimento
               SET data_hora_inicio = v_novo_inicio,
                   data_hora_fim    = v_novo_fim,
                   atualizado_em    = SYSTIMESTAMP
             WHERE id_atend = r.id_atend;

            v_prev_fim := v_novo_fim;
        ELSE
            -- a partir daqui já está cronologicamente correto, encerra a cascata
            EXIT;
        END IF;

    END LOOP;
END reordena_agenda_profissional;

CREATE OR REPLACE TRIGGER trg_atendimento_fim_alterado
FOR UPDATE OF data_hora_fim ON atendimento
COMPOUND TRIGGER

    TYPE t_rec IS RECORD (
        id_atend NUMBER,
        novo_fim TIMESTAMP
    );
    TYPE t_tab IS TABLE OF t_rec INDEX BY PLS_INTEGER;
    g_alterados t_tab;
    g_idx       PLS_INTEGER := 0;

    BEFORE EACH ROW IS
    BEGIN
        IF :NEW.data_hora_fim <= :NEW.data_hora_inicio THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'DATA_HORA_FIM deve ser posterior a DATA_HORA_INICIO'
            );
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN
        g_idx := g_idx + 1;
        g_alterados(g_idx).id_atend := :NEW.id_atend;
        g_alterados(g_idx).novo_fim := :NEW.data_hora_fim;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1 .. g_idx LOOP
            FOR r_prof IN (
                SELECT DISTINCT ip.id_prof
                FROM   atendimento_item ai
                JOIN   item_profissional ip
                       ON ip.id_item = ai.id_item AND ip.deletado_em IS NULL
                WHERE  ai.id_atend = g_alterados(i).id_atend
                  AND  ai.deletado_em IS NULL
            ) LOOP
                reordena_agenda_profissional(
                    p_id_prof         => r_prof.id_prof,
                    p_ref_fim         => g_alterados(i).novo_fim,
                    p_id_atend_origem => g_alterados(i).id_atend
                );
            END LOOP;
        END LOOP;
        g_idx := 0;
        g_alterados.DELETE;
    END AFTER STATEMENT;

END trg_atendimento_fim_alterado;