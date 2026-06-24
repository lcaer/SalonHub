---Criar a Trigger
CREATE OR REPLACE TRIGGER TRG_RF19_ANTECEDENCIA
BEFORE INSERT ON ATENDIMENTO
FOR EACH ROW
BEGIN

    IF :NEW.DATA_HORA_INICIO < (SYSTIMESTAMP + INTERVAL '2' HOUR) THEN
        RAISE_APPLICATION_ERROR(
            -20019,
            'O agendamento deve ser realizado com pelo menos 2 horas de antecedencia.'
        );
    END IF;

END;
/

---Verificar se a trigger foi criada
SELECT OBJECT_NAME, STATUS
FROM USER_OBJECTS
WHERE OBJECT_NAME = 'TRG_RF19_ANTECEDENCIA';

---Verificar se tem algum cliente cadastrado para teste
SELECT *
FROM CLIENTE;

---Como não tinha, basta criar um:
INSERT INTO CLIENTE (
    ID_CLI,
    NOME,
    TELEFONE,
    EMAIL,
    CPF
)
VALUES (
    1,
    'Ana Maria',
    '(18)99812-3456',
    'AnaMaria@gmail.com',
    '12345678900'
);

COMMIT;

---Fazendo o Teste que deve falhar, já que o cliente vai tentar agendar para daqui a 1 hora:
INSERT INTO ATENDIMENTO (
    ID_ATEND,
    ID_CLI,
    DATA_HORA_INICIO,
    STATUS
)
VALUES (
    1,
    1,
    SYSTIMESTAMP + INTERVAL '1' HOUR,
    'AGENDADO'
);

/*Resultado esperado:
    ORA-20019:
    "O agendamento deve ser realizado com pelo menos 2 horas de antecedencia."
*/

---Fazendo o teste que deve funcionar, pois agora o cliente solicitou um atendimento para daqui a 3 horas:
INSERT INTO ATENDIMENTO (
    ID_ATEND,
    ID_CLI,
    DATA_HORA_INICIO,
    STATUS
)
VALUES (
    2,
    1,
    SYSTIMESTAMP + INTERVAL '3' HOUR,
    'AGENDADO'
);

COMMIT;


---Verificando, e a resposta é apenas o atendimento criado com 3 horas de antecedência
SELECT
    ID_ATEND,
    ID_CLI,
    DATA_HORA_INICIO,
    STATUS
FROM ATENDIMENTO;

