CREATE OR REPLACE EDITIONABLE PACKAGE "RODRIGO"."PKG_USUARIOS" AS
    FUNCTION USUARIO_EXISTE_F (
        P_NOME IN VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION USUARIO_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN;

    FUNCTION GET_USUARIO_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION GET_USUARIO_F (
        P_NOME IN VARCHAR2
    ) RETURN NUMBER;

    PROCEDURE REMOVER_USUARIO_P (
        P_NOME    IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE CRIAR_USUARIO_P (
        P_NOME    IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE LISTAR_USUARIOS_P (
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

END PKG_USUARIOS;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RODRIGO"."PKG_USUARIOS" AS

    FUNCTION USUARIO_EXISTE_F (
        P_NOME IN VARCHAR2
    ) RETURN BOOLEAN IS
        V_COUNT NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            USUARIOS
        WHERE
            NM_USUARIO = P_NOME;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END USUARIO_EXISTE_F;

    FUNCTION USUARIO_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN IS
        V_COUNT NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            USUARIOS
        WHERE
            ID_USUARIO = P_ID;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END USUARIO_EXISTE_F;

    FUNCTION GET_USUARIO_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2 IS
        V_NOME USUARIOS.NM_USUARIO%TYPE;
    BEGIN
        SELECT
            NM_USUARIO
        INTO V_NOME
        FROM
            USUARIOS
        WHERE
            ID_USUARIO = P_ID;

        RETURN V_NOME;
    END GET_USUARIO_F;

    FUNCTION GET_USUARIO_F (
        P_NOME IN VARCHAR2
    ) RETURN NUMBER IS
        V_ID USUARIOS.ID_USUARIO%TYPE;
    BEGIN
        SELECT
            ID_USUARIO
        INTO V_ID
        FROM
            USUARIOS
        WHERE
            NM_USUARIO = P_NOME;

        RETURN V_ID;
    END GET_USUARIO_F;

    PROCEDURE REMOVER_USUARIO_P (
        P_NOME    IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_ID USUARIOS.ID_USUARIO%TYPE;
    BEGIN
        IF USUARIO_EXISTE_F(P_NOME) THEN
            V_ID := GET_USUARIO_F(P_NOME);
            DELETE FROM USUARIOS
            WHERE
                ID_USUARIO = V_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Usuário removido: '
                         || V_ID
                         || ' - '
                         || P_NOME;
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            COMMIT;
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Usuário não existe';
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro inesperado: ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
    END;

    PROCEDURE CRIAR_USUARIO_P (
        P_NOME    IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_ID USUARIOS.ID_USUARIO%TYPE;
    BEGIN
        IF NOT USUARIO_EXISTE_F(P_NOME) THEN
            INSERT INTO USUARIOS (
                ID_USUARIO,
                NM_USUARIO
            ) VALUES ( SEQ_USUARIOS.NEXTVAL,
                       P_NOME ) RETURNING ID_USUARIO INTO V_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Usuário criado: '
                         || V_ID
                         || ' - '
                         || GET_USUARIO_F(V_ID);
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            COMMIT;
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Usuário já existe';
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            ROLLBACK;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro inesperado: ' || SQLERRM;
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            ROLLBACK;
    END CRIAR_USUARIO_P;

    PROCEDURE LISTAR_USUARIOS_P (
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
    BEGIN
        OPEN P_CURSOR FOR SELECT
                                ID_USUARIO,
                                NM_USUARIO
                            FROM
                                USUARIOS;

        P_STATUS := 'SUCESSO';
        P_MESSAGE := 'Usuários listados.';
    END LISTAR_USUARIOS_P;

END PKG_USUARIOS;
/

