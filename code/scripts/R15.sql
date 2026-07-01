CREATE OR REPLACE PROCEDURE PRC_ASSOCIAR_PROFISSIONAL_ITEM (
    p_id_item IN INTEGER,
    p_id_prof IN INTEGER
)
AS
    /* Dados do atendimento que será validado */
    v_data_inicio ATENDIMENTO.DATA_HORA_INICIO%TYPE;
    v_data_fim    ATENDIMENTO.DATA_HORA_FIM%TYPE;
    v_id_func     SERVICO.ID_FUNC%TYPE;

    /* Quantidade de conflitos encontrados */
    v_conflitos NUMBER;

    /* Variáveis utilizadas pelo cursor de recomendação */
    v_id_prof_sugestao PROFISSIONAL.ID_PROF%TYPE;
    v_nome_prof_sugestao PROFISSIONAL.NOME%TYPE;

    ------------------------------------------------------------------
    -- Cursor responsável por localizar profissionais da mesma função
    -- que estejam disponíveis no intervalo do atendimento.
    ------------------------------------------------------------------
    CURSOR c_profissionais IS
        SELECT DISTINCT
               p.ID_PROF,
               p.NOME
          FROM PROFISSIONAL p
               JOIN PROFISSIONAL_FUNCAO pf
                    ON pf.ID_PROF = p.ID_PROF
         WHERE pf.ID_FUNC = v_id_func
           AND p.ID_PROF <> p_id_prof
           AND p.DELETADO_EM IS NULL
           AND pf.DELETADO_EM IS NULL

           AND NOT EXISTS (

                SELECT 1
                  FROM ITEM_PROFISSIONAL ip
                       JOIN ATENDIMENTO_ITEM ai
                            ON ai.ID_ITEM = ip.ID_ITEM
                       JOIN ATENDIMENTO a
                            ON a.ID_ATEND = ai.ID_ATEND

                 WHERE ip.ID_PROF = p.ID_PROF
                   AND ip.DELETADO_EM IS NULL
                   AND ai.DELETADO_EM IS NULL
                   AND a.DELETADO_EM IS NULL
                   AND a.STATUS IN ('AGENDADO','EM_ANDAMENTO')

                   /* Verificação de conflito de horários */
                   AND v_data_inicio < a.DATA_HORA_FIM
                   AND v_data_fim    > a.DATA_HORA_INICIO
           );

BEGIN

    ------------------------------------------------------------------
    -- Recupera o período do atendimento e identifica a função
    -- exigida pelo serviço associado ao item.
    ------------------------------------------------------------------
    SELECT a.DATA_HORA_INICIO,
           a.DATA_HORA_FIM,
           s.ID_FUNC
      INTO v_data_inicio,
           v_data_fim,
           v_id_func
      FROM ATENDIMENTO a
           JOIN ATENDIMENTO_ITEM ai
                ON ai.ID_ATEND = a.ID_ATEND
           JOIN SERVICO s
                ON s.ID_SERV = ai.ID_SERV
     WHERE ai.ID_ITEM = p_id_item
       AND a.DELETADO_EM IS NULL
       AND ai.DELETADO_EM IS NULL;

    ------------------------------------------------------------------
    -- Verifica se o profissional informado já possui outro
    -- atendimento ativo no mesmo intervalo de horário.
    ------------------------------------------------------------------
    SELECT COUNT(*)
      INTO v_conflitos
      FROM ITEM_PROFISSIONAL ip
           JOIN ATENDIMENTO_ITEM ai
                ON ai.ID_ITEM = ip.ID_ITEM
           JOIN ATENDIMENTO a
                ON a.ID_ATEND = ai.ID_ATEND
     WHERE ip.ID_PROF = p_id_prof
       AND ip.DELETADO_EM IS NULL
       AND ai.DELETADO_EM IS NULL
       AND a.DELETADO_EM IS NULL
       AND a.STATUS IN ('AGENDADO','EM_ANDAMENTO')

       /* Verificação de sobreposição de horários */
       AND v_data_inicio < a.DATA_HORA_FIM
       AND v_data_fim    > a.DATA_HORA_INICIO;

    ------------------------------------------------------------------
    -- Caso exista conflito, recomenda profissionais alternativos.
    ------------------------------------------------------------------
    IF v_conflitos > 0 THEN

        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Profissional indisponível para este horário.');
        DBMS_OUTPUT.PUT_LINE('Profissionais recomendados:');
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

        OPEN c_profissionais;

        LOOP

            FETCH c_profissionais
            INTO v_id_prof_sugestao,
                 v_nome_prof_sugestao;

            EXIT WHEN c_profissionais%NOTFOUND;

            DBMS_OUTPUT.PUT_LINE(
                'ID: ' || v_id_prof_sugestao ||
                ' | Nome: ' || v_nome_prof_sugestao
            );

        END LOOP;

        CLOSE c_profissionais;

        RAISE_APPLICATION_ERROR(
            -20015,
            'Associação cancelada. O profissional informado possui conflito de agenda.'
        );

    END IF;

    ------------------------------------------------------------------
    -- Não existindo conflito, realiza a associação do profissional
    -- ao item do atendimento.
    ------------------------------------------------------------------
    INSERT INTO ITEM_PROFISSIONAL (
        ID_ITEM,
        ID_PROF
    )
    VALUES (
        p_id_item,
        p_id_prof
    );

    DBMS_OUTPUT.PUT_LINE(
        'Profissional associado com sucesso.'
    );

EXCEPTION

    ------------------------------------------------------------------
    -- Item inexistente ou serviço não localizado.
    ------------------------------------------------------------------
    WHEN NO_DATA_FOUND THEN

        RAISE_APPLICATION_ERROR(
            -20016,
            'Item de atendimento não encontrado.'
        );

    ------------------------------------------------------------------
    -- Tratamento para demais falhas.
    ------------------------------------------------------------------
    WHEN OTHERS THEN

        IF c_profissionais%ISOPEN THEN
            CLOSE c_profissionais;
        END IF;

        RAISE_APPLICATION_ERROR(
            -20017,
            'Erro ao associar profissional: ' || SQLERRM
        );

END;
/