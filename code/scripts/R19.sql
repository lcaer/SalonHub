---Criação da Stored Procedure
CREATE OR REPLACE PROCEDURE PR_CRIAR_ATENDIMENTO(
    P_ID_ATEND            NUMBER,
    P_ID_CLI              NUMBER,
    P_DATA_HORA_INICIO    TIMESTAMP,
    P_STATUS              VARCHAR2 DEFAULT 'AGENDADO'
)
AS
BEGIN

    -- RF19: antecedência mínima de 2 horas
    IF P_DATA_HORA_INICIO < (SYSTIMESTAMP + INTERVAL '2' HOUR) THEN
        RAISE_APPLICATION_ERROR(
            -20019,
            'O agendamento deve ser realizado com pelo menos 2 horas de antecedencia.'
        );
    END IF;

    INSERT INTO ATENDIMENTO(
        ID_ATEND,
        ID_CLI,
        DATA_HORA_INICIO,
        STATUS
    )
    VALUES(
        P_ID_ATEND,
        P_ID_CLI,
        P_DATA_HORA_INICIO,
        P_STATUS
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

---Verifica se deu certo
SELECT OBJECT_NAME, STATUS
FROM USER_OBJECTS
WHERE OBJECT_NAME = 'PR_CRIAR_ATENDIMENTO';


---Teste que deve falahar, já que o cliente está marcado com duas horas de antecedência
BEGIN
    PR_CRIAR_ATENDIMENTO(
        1,
        1,
        SYSTIMESTAMP + INTERVAL '1' HOUR
    );
END;
/

/*Sendo o resultado esperado como:
Resultado esperado:
    ORA-20019:
    O agendamento deve ser realizado com pelo menos 2 horas de antecedencia.*/


---Teste que deve funcionar
BEGIN
    PR_CRIAR_ATENDIMENTO(
        2,
        1,
        SYSTIMESTAMP + INTERVAL '3' HOUR
    );
END;
/

---Verificar o resultado
SELECT
    ID_ATEND,
    ID_CLI,
    DATA_HORA_INICIO,
    STATUS
FROM ATENDIMENTO;