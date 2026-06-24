---------------------Verificar se as tabelas básicas existem---------------------

SELECT USER FROM DUAL;

SELECT TABLE_NAME
FROM USER_TABLES
WHERE TABLE_NAME IN (
    'CLIENTE',
    'FUNCAO',
    'PROFISSIONAL',
    'PROFISSIONAL_FUNCAO'
)
ORDER BY TABLE_NAME;

---------------------Cria o PROFISSIONAL_FUNCAO---------------------

CREATE TABLE PROFISSIONAL_FUNCAO (
    ID_PROF INTEGER NOT NULL,
    ID_FUNC INTEGER NOT NULL,

    CONSTRAINT PK_PROF_FUNC
        PRIMARY KEY (ID_PROF, ID_FUNC),

    CONSTRAINT FK_PF_PROF
        FOREIGN KEY (ID_PROF)
        REFERENCES PROFISSIONAL(ID_PROF),

    CONSTRAINT FK_PF_FUNC
        FOREIGN KEY (ID_FUNC)
        REFERENCES FUNCAO(ID_FUNC)
);

-----Para confirmar-----

SELECT TABLE_NAME
FROM USER_TABLES
WHERE TABLE_NAME = 'PROFISSIONAL_FUNCAO';

---------------------Inseririndo funções de teste---------------------

DELETE FROM PROFISSIONAL_FUNCAO;
DELETE FROM PROFISSIONAL;
DELETE FROM FUNCAO
WHERE ID_FUNC IN (1,2);

COMMIT;

---------------

INSERT INTO FUNCAO
VALUES (1, 'Cabeleireiro', SYSTIMESTAMP);

INSERT INTO FUNCAO
VALUES (2, 'Manicure', SYSTIMESTAMP);

COMMIT;

-----Verificando----

SELECT *
FROM FUNCAO;

---------------------Criando a Procedure RF14---------------------

CREATE OR REPLACE PROCEDURE PR_CADASTRAR_PROFISSIONAL(
    P_ID_PROF NUMBER,
    P_NOME VARCHAR2,
    P_TELEFONE VARCHAR2,
    P_ID_FUNC NUMBER
)
AS
    V_EXISTE NUMBER;
BEGIN

    SELECT COUNT(*)
    INTO V_EXISTE
    FROM FUNCAO
    WHERE ID_FUNC = P_ID_FUNC;

    IF V_EXISTE = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Função não cadastrada.'
        );
    END IF;

    INSERT INTO PROFISSIONAL (
        ID_PROF,
        NOME,
        TELEFONE
    )
    VALUES (
        P_ID_PROF,
        P_NOME,
        P_TELEFONE
    );

    INSERT INTO PROFISSIONAL_FUNCAO (
        ID_PROF,
        ID_FUNC
    )
    VALUES (
        P_ID_PROF,
        P_ID_FUNC
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-----Verificando----

SELECT OBJECT_NAME, STATUS
FROM USER_OBJECTS
WHERE OBJECT_NAME = 'PR_CADASTRAR_PROFISSIONAL';

---------------------Tesyando a Procedure ---------------------

BEGIN
    PR_CADASTRAR_PROFISSIONAL(
        1,
        'Mariana',
        '(18)99815-7531',
        1
    );
END;
/

---------------------Verificar RF14----------------------

SELECT *
FROM PROFISSIONAL;

SELECT *
FROM PROFISSIONAL_FUNCAO;