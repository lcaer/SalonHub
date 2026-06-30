CREATE OR REPLACE PROCEDURE SP_ANALISAR_INTERVALOS (
   p_id_profissional IN NUMBER,
   p_data            IN DATE,
   p_duracao_minutos IN NUMBER
) IS
   CURSOR c_agendamentos IS
      SELECT hora_inicio, hora_fim
      FROM ATENDIMENTO
      WHERE id_profissional = p_id_profissional
        AND TRUNC(hora_inicio) = TRUNC(p_data)
      ORDER BY hora_inicio;

   v_inicio DATE;
   v_fim    DATE;
   v_anterior_fim DATE;
BEGIN
   v_anterior_fim := p_data; -- começa no início do dia

   FOR reg IN c_agendamentos LOOP
      -- calcula intervalo entre fim anterior e início atual
      IF (reg.hora_inicio - v_anterior_fim) * 24 * 60 >= p_duracao_minutos THEN
         DBMS_OUTPUT.PUT_LINE('Horário disponível: ' || TO_CHAR(v_anterior_fim, 'HH24:MI'));
      END IF;

      v_anterior_fim := reg.hora_fim;
   END LOOP;

   -- verificar espaço após último agendamento até fim do dia
   IF (TRUNC(p_data)+1 - v_anterior_fim) * 24 * 60 >= p_duracao_minutos THEN
      DBMS_OUTPUT.PUT_LINE('Horário disponível: ' || TO_CHAR(v_anterior_fim, 'HH24:MI'));
   END IF;
END;
/
