/*======================================================================
    REQUISITO FUNCIONAL 25 (RF25)
    CONTROLE DE ACESSO BASEADO EM PAPÉIS (ROLES)

    Objetivo:
    Criar papéis de segurança para os diferentes usuários do sistema,
    concedendo apenas os privilégios necessários para a execução de
    suas atividades, seguindo o princípio do menor privilégio.
======================================================================*/


/*----------------------------------------------------------------------
    ETAPA 1 - Criação das Roles
----------------------------------------------------------------------*/

CREATE ROLE RL_ADMIN;

CREATE ROLE RL_RECEPCIONISTA;

CREATE ROLE RL_PROFISSIONAL;


/*----------------------------------------------------------------------
    ETAPA 2 - Permissões do Administrador

    O administrador possui acesso completo ao banco de dados, sendo
    responsável pelo gerenciamento de todas as entidades do sistema.
----------------------------------------------------------------------*/

GRANT SELECT, INSERT, UPDATE, DELETE ON CLIENTE TO RL_ADMIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON PROFISSIONAL TO RL_ADMIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON PROFISSIONAL_FUNCAO TO RL_ADMIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON FUNCAO TO RL_ADMIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON SERVICO TO RL_ADMIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON ATENDIMENTO TO RL_ADMIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON ATENDIMENTO_ITEM TO RL_ADMIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON ITEM_PROFISSIONAL TO RL_ADMIN;


/*----------------------------------------------------------------------
    ETAPA 3 - Permissões da Recepcionista

    Responsável pelos cadastros operacionais e agendamentos.

    As inserções que envolvem regras de negócio são realizadas
    exclusivamente através das procedures.
----------------------------------------------------------------------*/

--------------------------
-- Consultas
--------------------------

GRANT SELECT ON CLIENTE TO RL_RECEPCIONISTA;

GRANT SELECT ON PROFISSIONAL TO RL_RECEPCIONISTA;

GRANT SELECT ON FUNCAO TO RL_RECEPCIONISTA;

GRANT SELECT ON SERVICO TO RL_RECEPCIONISTA;

GRANT SELECT ON ATENDIMENTO TO RL_RECEPCIONISTA;

GRANT SELECT ON ATENDIMENTO_ITEM TO RL_RECEPCIONISTA;

GRANT SELECT ON ITEM_PROFISSIONAL TO RL_RECEPCIONISTA;

--------------------------
-- Alterações simples
--------------------------

GRANT INSERT, UPDATE ON CLIENTE TO RL_RECEPCIONISTA;

GRANT INSERT, UPDATE ON ATENDIMENTO TO RL_RECEPCIONISTA;

GRANT INSERT, UPDATE ON ATENDIMENTO_ITEM TO RL_RECEPCIONISTA;

--------------------------
-- Execução das Procedures
--------------------------

GRANT EXECUTE ON PRC_CADASTRAR_PROFISSIONAL
TO RL_RECEPCIONISTA;

GRANT EXECUTE ON PRC_ASSOCIAR_PROFISSIONAL_ITEM
TO RL_RECEPCIONISTA;


/*----------------------------------------------------------------------
    ETAPA 4 - Permissões do Profissional

    O profissional possui apenas acesso de consulta às informações
    necessárias para execução de seus atendimentos.
----------------------------------------------------------------------*/

GRANT SELECT ON CLIENTE TO RL_PROFISSIONAL;

GRANT SELECT ON SERVICO TO RL_PROFISSIONAL;

GRANT SELECT ON ATENDIMENTO TO RL_PROFISSIONAL;

GRANT SELECT ON ATENDIMENTO_ITEM TO RL_PROFISSIONAL;

GRANT SELECT ON ITEM_PROFISSIONAL TO RL_PROFISSIONAL;


/*----------------------------------------------------------------------
    ETAPA 5 - Associação das Roles aos usuários do banco

    Os usuários abaixo são apenas exemplos.
----------------------------------------------------------------------*/

-- CREATE USER ADMIN IDENTIFIED BY admin123;
-- CREATE USER RECEPCAO IDENTIFIED BY recepcao123;
-- CREATE USER PROF001 IDENTIFIED BY profissional123;

-- GRANT CREATE SESSION TO ADMIN;
-- GRANT CREATE SESSION TO RECEPCAO;
-- GRANT CREATE SESSION TO PROF001;

-- GRANT RL_ADMIN TO ADMIN;

-- GRANT RL_RECEPCIONISTA TO RECEPCAO;

-- GRANT RL_PROFISSIONAL TO PROF001;