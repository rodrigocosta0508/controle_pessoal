CREATE OR REPLACE EDITIONABLE PACKAGE "RODRIGO"."PKG_OPERADORAS" AS
    FUNCTION OPERADORA_EXISTE_F (
        P_NOME IN VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION OPERADORA_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN;

    FUNCTION GET_OPERADORA_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION GET_OPERADORA_F (
        P_NOME IN VARCHAR2
    ) RETURN NUMBER;

    PROCEDURE REMOVER_OPERADORA_P (
        P_NOME    IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE CRIAR_OPERADORA_P (
        P_NOME    IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

END PKG_OPERADORAS;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RODRIGO"."PKG_OPERADORAS" AS

    FUNCTION OPERADORA_EXISTE_F (
        P_NOME IN VARCHAR2
    ) RETURN BOOLEAN IS
        V_COUNT NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            OPERADORAS
        WHERE
            NM_OPERADORA = P_NOME;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END OPERADORA_EXISTE_F;

    FUNCTION OPERADORA_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN IS
        V_COUNT NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            OPERADORAS
        WHERE
            ID_OPERADORA = P_ID;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END OPERADORA_EXISTE_F;

    FUNCTION GET_OPERADORA_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2 IS
        V_NOME OPERADORAS.NM_OPERADORA%TYPE;
    BEGIN
        SELECT
            NM_OPERADORA
        INTO V_NOME
        FROM
            OPERADORAS
        WHERE
            ID_OPERADORA = P_ID;

        RETURN V_NOME;
    END GET_OPERADORA_F;

    FUNCTION GET_OPERADORA_F (
        P_NOME IN VARCHAR2
    ) RETURN NUMBER IS
        V_ID OPERADORAS.ID_OPERADORA%TYPE;
    BEGIN
        SELECT
            ID_OPERADORA
        INTO V_ID
        FROM
            OPERADORAS
        WHERE
            NM_OPERADORA = P_NOME;

        RETURN V_ID;
    END GET_OPERADORA_F;

    PROCEDURE REMOVER_OPERADORA_P (
        P_NOME    IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_ID OPERADORAS.ID_OPERADORA%TYPE;
    BEGIN
        IF OPERADORA_EXISTE_F(P_NOME) THEN
            V_ID := GET_OPERADORA_F(P_NOME);
            DELETE FROM OPERADORAS
            WHERE
                ID_OPERADORA = V_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Operadora removida: '
                         || V_ID
                         || ' - '
                         || P_NOME;
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            COMMIT;
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Operadora não existe';
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

    PROCEDURE CRIAR_OPERADORA_P (
        P_NOME    IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_ID OPERADORAS.ID_OPERADORA%TYPE;
    BEGIN
        IF NOT OPERADORA_EXISTE_F(P_NOME) THEN
            INSERT INTO OPERADORAS (
                ID_OPERADORA,
                NM_OPERADORA
            ) VALUES ( SEQ_OPERADORAS.NEXTVAL,
                       P_NOME ) RETURNING ID_OPERADORA INTO V_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Operadora criada: '
                         || V_ID
                         || ' - '
                         || GET_OPERADORA_F(V_ID);
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            COMMIT;
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Operadora já existe';
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
    END CRIAR_OPERADORA_P;

END PKG_OPERADORAS;
/

