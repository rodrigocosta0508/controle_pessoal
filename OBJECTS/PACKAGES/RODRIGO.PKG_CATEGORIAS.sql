CREATE OR REPLACE EDITIONABLE PACKAGE "RODRIGO"."PKG_CATEGORIAS" AS
    FUNCTION CATEGORIA_EXISTE_F (
        P_NOME IN VARCHAR2,
        P_SUB  IN VARCHAR2
    ) RETURN BOOLEAN;

    FUNCTION CATEGORIA_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN;

    FUNCTION GET_CATEGORIA_F (
        P_ID   IN NUMBER,
        P_TIPO IN VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION GET_CATEGORIA_F (
        P_NOME IN VARCHAR2,
        P_SUB  IN VARCHAR2
    ) RETURN NUMBER;

    FUNCTION GET_CATEGORIA_DS_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2;

    PROCEDURE LISTAR_CATEGORIAS_P (
        P_NOME    IN VARCHAR2 DEFAULT NULL,
        P_SUB     IN VARCHAR DEFAULT NULL,
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE LISTAR_CATEGORIA_P (
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE LISTAR_SUBCATEGORIA_P (
        P_NOME    IN VARCHAR2,
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE REMOVER_CATEGORIA_P (
        P_ID      IN NUMBER,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE REMOVER_CATEGORIA_P (
        P_NOME    IN VARCHAR2,
        P_SUB     IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE ALTERAR_CATEGORIA_P (
        P_ID      IN NUMBER,
        P_NM      IN VARCHAR2,
        P_SUB     IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE CRIAR_CATEGORIA_P (
        P_NOME    IN VARCHAR2,
        P_SUB     IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

END PKG_CATEGORIAS;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RODRIGO"."PKG_CATEGORIAS" AS

    FUNCTION CATEGORIA_EXISTE_F (
        P_NOME IN VARCHAR2,
        P_SUB  IN VARCHAR2
    ) RETURN BOOLEAN IS
        V_COUNT NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            CATEGORIAS
        WHERE
                NM_CATEGORIA = P_NOME
            AND NM_SUB_CATEGORIA = P_SUB;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END CATEGORIA_EXISTE_F;

    FUNCTION CATEGORIA_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN IS
        V_COUNT NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            CATEGORIAS
        WHERE
            ID_CATEGORIA = P_ID;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END CATEGORIA_EXISTE_F;

    FUNCTION GET_CATEGORIA_F (
        P_ID   IN NUMBER,
        P_TIPO IN VARCHAR2
    ) RETURN VARCHAR2 IS
        V_NOME CATEGORIAS.NM_CATEGORIA%TYPE;
        V_SUB  CATEGORIAS.NM_SUB_CATEGORIA%TYPE;
    BEGIN
        SELECT
            NM_CATEGORIA,
            NM_SUB_CATEGORIA
        INTO
            V_NOME,
            V_SUB
        FROM
            CATEGORIAS
        WHERE
            ID_CATEGORIA = P_ID;

        IF P_TIPO = 'NM_CATEGORIA' THEN
            RETURN V_NOME;
        ELSIF P_TIPO = 'NM_SUB_CATEGORIA' THEN
            RETURN V_SUB;
        END IF;

    END GET_CATEGORIA_F;

    FUNCTION GET_CATEGORIA_F (
        P_NOME IN VARCHAR2,
        P_SUB  IN VARCHAR2
    ) RETURN NUMBER IS
        V_ID CATEGORIAS.ID_CATEGORIA%TYPE;
    BEGIN
        SELECT
            ID_CATEGORIA
        INTO V_ID
        FROM
            CATEGORIAS
        WHERE
                NM_CATEGORIA = P_NOME
            AND NM_SUB_CATEGORIA = P_SUB;

        RETURN V_ID;
    END GET_CATEGORIA_F;

    FUNCTION GET_CATEGORIA_DS_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2 IS
        V_DS VARCHAR2(100);
    BEGIN
        SELECT
            ID_CATEGORIA
            || ' - '
            || NM_CATEGORIA
            || ' - '
            || NM_SUB_CATEGORIA
        INTO V_DS
        FROM
            CATEGORIAS
        WHERE
            ID_CATEGORIA = P_ID;

        RETURN V_DS;
    END GET_CATEGORIA_DS_F;

    PROCEDURE LISTAR_CATEGORIAS_P (
        P_NOME    IN VARCHAR2 DEFAULT NULL,
        P_SUB     IN VARCHAR DEFAULT NULL,
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
    BEGIN
        OPEN P_CURSOR FOR SELECT
                                                *
                                            FROM
                                                CATEGORIAS C
                          WHERE
                                  C.NM_CATEGORIA = NVL(
                                      UPPER(P_NOME),
                                      C.NM_CATEGORIA
                                  )
                              AND C.NM_SUB_CATEGORIA = NVL(
                                  UPPER(P_SUB),
                                  C.NM_SUB_CATEGORIA
                              )
                          ORDER BY
                              C.NM_CATEGORIA,
                              C.NM_SUB_CATEGORIA;

    END LISTAR_CATEGORIAS_P;

    PROCEDURE LISTAR_CATEGORIA_P (
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
    BEGIN
        OPEN P_CURSOR FOR SELECT
                                                C.NM_CATEGORIA
                                            FROM
                                                CATEGORIAS C
                          GROUP BY
                              C.NM_CATEGORIA
                          ORDER BY
                              C.NM_CATEGORIA;

    END LISTAR_CATEGORIA_P;

    PROCEDURE LISTAR_SUBCATEGORIA_P (
        P_NOME    IN VARCHAR2,
        P_CURSOR  OUT SYS_REFCURSOR,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
    BEGIN
        OPEN P_CURSOR FOR SELECT
                                                C.ID_CATEGORIA,
                                                C.NM_SUB_CATEGORIA
                                            FROM
                                                CATEGORIAS C
                          WHERE
                              C.NM_CATEGORIA = P_NOME
                          ORDER BY
                              C.NM_CATEGORIA;

    END LISTAR_SUBCATEGORIA_P;

    PROCEDURE REMOVER_CATEGORIA_P (
        P_ID      IN NUMBER,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
    BEGIN
        IF CATEGORIA_EXISTE_F(P_ID) THEN
            DELETE FROM CATEGORIAS
            WHERE
                ID_CATEGORIA = P_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Categoria removida: ' || GET_CATEGORIA_DS_F(P_ID);
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            COMMIT;
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Categoria não existe';
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
    END REMOVER_CATEGORIA_P;

    PROCEDURE REMOVER_CATEGORIA_P (
        P_NOME    IN VARCHAR2,
        P_SUB     IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_ID CATEGORIAS.ID_CATEGORIA%TYPE;
    BEGIN
        IF CATEGORIA_EXISTE_F(P_NOME, P_SUB) THEN
            V_ID := GET_CATEGORIA_F(P_NOME, P_SUB);
            REMOVER_CATEGORIA_P(V_ID, P_STATUS, P_MESSAGE);
        END IF;
    END REMOVER_CATEGORIA_P;

    PROCEDURE ALTERAR_CATEGORIA_P (
        P_ID      IN NUMBER,
        P_NM      IN VARCHAR2,
        P_SUB     IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
    BEGIN
        IF CATEGORIA_EXISTE_F(P_ID) THEN
            UPDATE CATEGORIAS
            SET
                NM_CATEGORIA = P_NM,
                NM_SUB_CATEGORIA = P_SUB
            WHERE
                ID_CATEGORIA = P_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Categoria criada: ' || GET_CATEGORIA_DS_F(P_ID);
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            COMMIT;
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Categoria não existe';
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
            ROLLBACK;
    END ALTERAR_CATEGORIA_P;

    PROCEDURE CRIAR_CATEGORIA_P (
        P_NOME    IN VARCHAR2,
        P_SUB     IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_ID CATEGORIAS.ID_CATEGORIA%TYPE;
    BEGIN
        IF NOT CATEGORIA_EXISTE_F(P_NOME, P_SUB) THEN
            INSERT INTO CATEGORIAS (
                ID_CATEGORIA,
                NM_CATEGORIA,
                NM_SUB_CATEGORIA
            ) VALUES ( SEQ_CATEGORIAS.NEXTVAL,
                       P_NOME,
                       P_SUB ) RETURNING ID_CATEGORIA INTO V_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Categoria criada: ' || GET_CATEGORIA_DS_F(V_ID);
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - '
                                 || P_MESSAGE);
            COMMIT;
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Categoria já existe';
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
    END CRIAR_CATEGORIA_P;

END PKG_CATEGORIAS;
/

