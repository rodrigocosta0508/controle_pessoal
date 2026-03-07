CREATE OR REPLACE EDITIONABLE PACKAGE "RODRIGO"."PKG_FATURAS" AS
    FUNCTION FATURA_EXISTE_F (
        P_NOME IN VARCHAR2,
        P_DS   IN VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION FATURA_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN;

    FUNCTION FATURA_EXISTE_F (
        P_ID_OPE IN NUMBER,
        P_DT_OPE IN DATE
    ) RETURN BOOLEAN;

    FUNCTION GET_FATURA_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION GET_FATURA_F (
        P_NOME IN VARCHAR2,
        P_DS   IN VARCHAR2
    ) RETURN NUMBER;

    FUNCTION GET_FATURA_F (
        P_ID_OPE IN NUMBER,
        P_DT_OPE IN DATE
    ) RETURN NUMBER;

    FUNCTION GET_OPERADORA_FAT_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION GET_VEN_FAT_F (
        P_ID IN NUMBER
    ) RETURN DATE;

    FUNCTION GEN_FATURA_INI_F (
        P_DATE IN DATE
    ) RETURN DATE;

    FUNCTION GEN_FATURA_FIM_F (
        P_DATE IN DATE
    ) RETURN DATE;

    PROCEDURE REMOVER_FATURA_P (
        P_ID      IN NUMBER,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE REMOVER_FATURA_P (
        P_NOME    IN VARCHAR2,
        P_DS      IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE LISTAR_FATURAS_P (
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE CRIAR_FATURA_P (
        P_ID_OPE  IN NUMBER,
        P_DS      IN VARCHAR2,
        P_INI     IN DATE,
        P_FIM     IN DATE,
        P_VEN     IN DATE,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE CRIAR_FATURA_P (
        P_NOME    IN VARCHAR2,
        P_DATE    IN DATE,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

END PKG_FATURAS;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RODRIGO"."PKG_FATURAS" AS

    FUNCTION FATURA_EXISTE_F (
        P_NOME IN VARCHAR2,
        P_DS   IN VARCHAR2
    ) RETURN BOOLEAN IS
        V_COUNT        NUMBER;
        V_ID_OPERADORA OPERADORAS.ID_OPERADORA%TYPE := PKG_OPERADORAS.GET_OPERADORA_F(P_NOME);
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            FATURAS
        WHERE
                ID_OPERADORA = V_ID_OPERADORA
            AND DESC_FATURA = P_DS;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END FATURA_EXISTE_F;

    FUNCTION FATURA_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN IS
        V_COUNT NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            FATURAS
        WHERE
            ID_FATURA = P_ID;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END FATURA_EXISTE_F;

    FUNCTION FATURA_EXISTE_F (
        P_ID_OPE IN NUMBER,
        P_DT_OPE IN DATE
    ) RETURN BOOLEAN IS
        V_COUNT NUMBER;
        V_ID    FATURAS.ID_FATURA%TYPE;
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            FATURAS
        WHERE
                ID_OPERADORA = P_ID_OPE
            AND P_DT_OPE BETWEEN INI_FATURA AND FIM_FATURA;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END FATURA_EXISTE_F;

    PROCEDURE LISTAR_FATURAS_P (
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
    BEGIN
        OPEN P_CURSOR FOR SELECT
                                                F.ID_FATURA,
                                                F.DESC_FATURA
                                            FROM
                                                FATURAS F
                          ORDER BY
                              F.VENCIMENTO DESC;

        P_STATUS := 'SUCESSO';
        P_MESSAGE := 'Faturas listadas.';
    END LISTAR_FATURAS_P;

    FUNCTION GET_FATURA_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2 IS
        V_NOME FATURAS.DESC_FATURA%TYPE;
    BEGIN
        SELECT
            DESC_FATURA
        INTO V_NOME
        FROM
            FATURAS
        WHERE
            ID_FATURA = P_ID;

        RETURN V_NOME;
    END GET_FATURA_F;

    FUNCTION GET_FATURA_F (
        P_NOME IN VARCHAR2,
        P_DS   IN VARCHAR2
    ) RETURN NUMBER IS

        V_ID           FATURAS.ID_FATURA%TYPE;
        V_ID_OPERADORA OPERADORAS.ID_OPERADORA%TYPE := PKG_OPERADORAS.GET_OPERADORA_F(P_NOME);
    BEGIN
        SELECT
            ID_FATURA
        INTO V_ID
        FROM
            FATURAS
        WHERE
                ID_OPERADORA = V_ID_OPERADORA
            AND DESC_FATURA = P_DS;

        RETURN V_ID;
    END GET_FATURA_F;

    FUNCTION GET_FATURA_F (
        P_ID_OPE IN NUMBER,
        P_DT_OPE IN DATE
    ) RETURN NUMBER IS
        V_ID FATURAS.ID_FATURA%TYPE;
    BEGIN
        SELECT
            F.ID_FATURA
        INTO V_ID
        FROM
            FATURAS F
        WHERE
                F.ID_OPERADORA = P_ID_OPE
            AND P_DT_OPE BETWEEN F.INI_FATURA AND F.FIM_FATURA;

        RETURN V_ID;
    END GET_FATURA_F;

    FUNCTION GET_OPERADORA_FAT_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2 IS
        V_NOME OPERADORAS.NM_OPERADORA%TYPE;
    BEGIN
        SELECT
            O.NM_OPERADORA
        INTO V_NOME
        FROM
                 FATURAS F
            JOIN OPERADORAS O ON O.ID_OPERADORA = F.ID_OPERADORA
        WHERE
            F.ID_FATURA = P_ID;

        RETURN V_NOME;
    END GET_OPERADORA_FAT_F;

    FUNCTION GET_VEN_FAT_F (
        P_ID IN NUMBER
    ) RETURN DATE IS
        V_VEN FATURAS.VENCIMENTO%TYPE;
    BEGIN
        SELECT
            VENCIMENTO
        INTO V_VEN
        FROM
            FATURAS
        WHERE
            ID_FATURA = P_ID;

        RETURN V_VEN;
    END GET_VEN_FAT_F;

    FUNCTION GEN_FATURA_DS_F (
        P_DATE IN DATE
    ) RETURN VARCHAR2 IS

        V_DS FATURAS.DESC_FATURA%TYPE;
        V_DD VARCHAR2(2) := TO_CHAR(P_DATE, 'dd');
    BEGIN
        IF V_DD >= 7 THEN
            V_DS := TO_CHAR(
                ADD_MONTHS(P_DATE, 1),
                'yyyy-mm'
            );
        ELSE
            V_DS := TO_CHAR(P_DATE, 'yyyy-mm');
        END IF;

        RETURN V_DS;
    END GEN_FATURA_DS_F;

    FUNCTION GEN_FATURA_VEN_F (
        P_DATE IN DATE
    ) RETURN DATE IS

        V_VEN FATURAS.VENCIMENTO%TYPE;
        V_DD  VARCHAR2(2) := TO_CHAR(P_DATE, 'dd');
    BEGIN
        IF V_DD >= 7 THEN
            V_VEN := TO_DATE ( '15/'
                               || TO_CHAR(
                ADD_MONTHS(P_DATE, 1),
                'mm/yyyy'
            ), 'dd/mm/yyyy' );
        ELSE
            V_VEN := TO_DATE ( '15/'
                               || TO_CHAR(P_DATE, 'mm/yyyy'), 'dd/mm/yyyy' );
        END IF;

        RETURN V_VEN;
    END GEN_FATURA_VEN_F;

    FUNCTION GEN_FATURA_INI_F (
        P_DATE IN DATE
    ) RETURN DATE IS

        V_DATE FATURAS.INI_FATURA%TYPE;
        V_DD   VARCHAR2(2) := TO_CHAR(P_DATE, 'dd');
    BEGIN
        IF V_DD >= 7 THEN
            V_DATE := TO_DATE ( '07/'
                                || TO_CHAR(P_DATE, 'mm/yyyy'), 'dd/mm/yyyy' );
        ELSE
            V_DATE := TO_DATE ( '07/'
                                || TO_CHAR(
                ADD_MONTHS(P_DATE, -1),
                'mm/yyyy'
            ), 'dd/mm/yyyy' );
        END IF;

        RETURN V_DATE;
    END GEN_FATURA_INI_F;

    FUNCTION GEN_FATURA_FIM_F (
        P_DATE IN DATE
    ) RETURN DATE IS

        V_DATE FATURAS.INI_FATURA%TYPE;
        V_DD   VARCHAR2(2) := TO_CHAR(P_DATE, 'dd');
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Data Original: ' || P_DATE);
        DBMS_OUTPUT.PUT_LINE('Nova Data: '
                             || '06/'
                             || TO_CHAR(
            ADD_MONTHS(P_DATE, 1),
            'mm/yyyy'
        ));

        IF V_DD >= 7 THEN
            V_DATE := TO_DATE ( '06/'
                                || TO_CHAR(
                ADD_MONTHS(P_DATE, 1),
                'mm/yyyy'
            ), 'dd/mm/yyyy' );
        ELSE
            V_DATE := TO_DATE ( '06/'
                                || TO_CHAR(P_DATE, 'mm/yyyy'), 'dd/mm/yyyy' );
        END IF;

        RETURN V_DATE;
    END GEN_FATURA_FIM_F;

    PROCEDURE REMOVER_FATURA_P (
        P_ID      IN NUMBER,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_NOME OPERADORAS.NM_OPERADORA%TYPE;
        V_DS   FATURAS.DESC_FATURA%TYPE;
    BEGIN
        IF FATURA_EXISTE_F(P_ID) THEN
            V_NOME := GET_OPERADORA_FAT_F(P_ID);
            V_DS := GET_FATURA_F(P_ID);
            DELETE FROM FATURAS
            WHERE
                ID_FATURA = P_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Fatura removida: '
                         || P_ID
                         || ' - '
                         || V_NOME
                         || ' - '
                         || V_DS;

            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            COMMIT;
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Fatura não existe';
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro inesperado: '
                         || SQLERRM
                         || ' - '
                         || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
    END REMOVER_FATURA_P;

    PROCEDURE REMOVER_FATURA_P (
        P_NOME    IN VARCHAR2,
        P_DS      IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_ID FATURAS.ID_FATURA%TYPE;
    BEGIN
        IF FATURA_EXISTE_F(P_NOME, P_DS) THEN
            V_ID := GET_FATURA_F(P_NOME, P_DS);
            REMOVER_FATURA_P(V_ID, P_STATUS, P_MESSAGE);
        END IF;
    END REMOVER_FATURA_P;

    PROCEDURE CRIAR_FATURA_P (
        P_ID_OPE  IN NUMBER,
        P_DS      IN VARCHAR2,
        P_INI     IN DATE,
        P_FIM     IN DATE,
        P_VEN     IN DATE,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS

        V_ID     FATURAS.ID_FATURA%TYPE;
        V_NM_OPE OPERADORAS.NM_OPERADORA%TYPE := PKG_OPERADORAS.GET_OPERADORA_F(P_ID_OPE);
    BEGIN
        IF NOT FATURA_EXISTE_F(V_NM_OPE, P_DS) THEN
            INSERT INTO FATURAS (
                ID_FATURA,
                ID_OPERADORA,
                DESC_FATURA,
                INI_FATURA,
                FIM_FATURA,
                VENCIMENTO
            ) VALUES ( SEQ_FATURAS.NEXTVAL,
                       P_ID_OPE,
                       P_DS,
                       P_INI,
                       P_FIM,
                       P_VEN ) RETURNING ID_FATURA INTO V_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Fatura criada: '
                         || V_ID
                         || ' - '
                         || V_NM_OPE
                         || ' - '
                         || P_DS;

            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            COMMIT;
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Fatura já existe';
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro inesperado: '
                         || SQLERRM
                         || ' - '
                         || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            ROLLBACK;
    END CRIAR_FATURA_P;

    PROCEDURE CRIAR_FATURA_P (
        P_NOME    IN VARCHAR2,
        P_DATE    IN DATE,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS

        V_ID_OPE OPERADORAS.ID_OPERADORA%TYPE := PKG_OPERADORAS.GET_OPERADORA_F(P_NOME);
        V_DS     FATURAS.DESC_FATURA%TYPE := PKG_FATURAS.GEN_FATURA_DS_F(P_DATE);
        V_VEN    FATURAS.VENCIMENTO%TYPE := PKG_FATURAS.GEN_FATURA_VEN_F(P_DATE);
        V_INI    FATURAS.INI_FATURA%TYPE := PKG_FATURAS.GEN_FATURA_INI_F(P_DATE);
        V_FIM    FATURAS.FIM_FATURA%TYPE := PKG_FATURAS.GEN_FATURA_FIM_F(P_DATE);
    BEGIN
        CRIAR_FATURA_P(V_ID_OPE, V_DS, V_INI, V_FIM, V_VEN,
                       P_STATUS, P_MESSAGE);
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro inesperado: '
                         || SQLERRM
                         || ' - '
                         || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            ROLLBACK;
    END CRIAR_FATURA_P;

END PKG_FATURAS;
/

