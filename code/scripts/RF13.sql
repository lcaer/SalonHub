/*Stored Procedure*/
CREATE OR REPLACE PROCEDURE PRC_CADASTRAR_PROFISSIONAL (
    p_nome     IN VARCHAR2,
    p_telefone IN VARCHAR2,
    p_id_func  IN INTEGER
)
AS
    /*Identificador do profissional gerado após a inserção.*/
    v_id_prof PROFISSIONAL.ID_PROF%TYPE;

    /*Variável utilizada na validação da função informada.*/
    v_funcao_encontrada FUNCAO.ID_FUNC%TYPE;

BEGIN

    /* Validação da função
    Garante que a função informada exista e esteja ativa antes
    da criação do vínculo com o profissional.
    */
    SELECT ID_FUNC
      INTO v_funcao_encontrada
      FROM FUNCAO
     WHERE ID_FUNC = p_id_func
       AND DELETADO_EM IS NULL;

    /* Cadastro do profissional
    Insere o profissional e recupera o identificador gerado
    automaticamente para utilização nas próximas operações.*/
    INSERT INTO PROFISSIONAL (
        NOME,
        TELEFONE
    )
    VALUES (
        p_nome,
        p_telefone
    )
    RETURNING ID_PROF INTO v_id_prof;

   /*Associação profissional-função
    Atende ao RF13, garantindo que todo profissional possua
    pelo menos uma função cadastrada no sistema.*/
    INSERT INTO PROFISSIONAL_FUNCAO (
        ID_PROF,
        ID_FUNC
    )
    VALUES (
        v_id_prof,
        p_id_func
    );

    /* Confirmação da transação */
    COMMIT;

EXCEPTION

    /* Nenhuma função válida foi encontrada para o identificador informado.*/

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(
            -20003,
            'A função especificada não existe ou está inativa.'
        );

    /* Tratamento de falhas não previstas durante a execução.*/
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(
            -20004,
            'Falha ao cadastrar profissional: ' || SQLERRM
        );

END;
/