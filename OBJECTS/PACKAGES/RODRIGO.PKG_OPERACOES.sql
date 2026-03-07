CREATE OR REPLACE EDITIONABLE PACKAGE "RODRIGO"."PKG_OPERACOES" AS
    FUNCTION OPERACAO_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN;

    FUNCTION GET_OPERACOES_DET_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2;

    FUNCTION GET_ID_OPERACAO_UNI_F (
        P_ID IN NUMBER
    ) RETURN NUMBER;

    PROCEDURE LISTAR_OPERACOES_P (
        P_ID_OPERACAO     IN NUMBER DEFAULT NULL,
        P_ID_OPERACAO_PAR IN NUMBER DEFAULT NULL,
        P_TIPO_OPERACAO   IN VARCHAR2 DEFAULT NULL,
        P_USUARIO         IN VARCHAR2 DEFAULT NULL,
        P_CATEGORIA       IN VARCHAR2 DEFAULT NULL,
        P_SUB_CATEGORIA   IN VARCHAR2 DEFAULT NULL,
        P_RESPONSAVEL     IN VARCHAR2 DEFAULT NULL,
        P_DT_INI          IN VARCHAR2 DEFAULT NULL, -- formato: DD/MM/YYYY
        P_DT_FIM          IN VARCHAR2 DEFAULT NULL,
        P_DESC_FATURA     IN VARCHAR2 DEFAULT NULL,
        P_LIMIT           IN NUMBER DEFAULT 30,
        P_OFFSET          IN NUMBER DEFAULT 0,
        P_CURSOR          OUT SYS_REFCURSOR,
        P_STATUS          OUT VARCHAR2,
        P_MESSAGE         OUT VARCHAR2
    );

    PROCEDURE ALTERAR_OPERACOES_FAT_P (
        P_ID_OPERACAO IN NUMBER,
        P_ID_FATURA   IN NUMBER,
        P_STATUS      OUT VARCHAR2,
        P_MESSAGE     OUT VARCHAR2
    );

    PROCEDURE ALTERAR_OPERACOES_P (
        P_ID_OPERACAO    IN NUMBER,
        P_TIPO_OPERACAO  IN VARCHAR2 DEFAULT NULL,
        P_ID_OPERADORA   IN NUMBER DEFAULT NULL,
        P_ID_FATURA      IN NUMBER DEFAULT NULL,
        P_ID_USUARIO     IN NUMBER DEFAULT NULL,
        P_ID_CATEGORIA   IN NUMBER DEFAULT NULL,
        P_DT_OPERACAO    IN VARCHAR2 DEFAULT NULL,
        P_VL_OPERACAO    IN NUMBER DEFAULT NULL,
        P_PARCELA_ATUAL  IN NUMBER DEFAULT NULL,
        P_PARCELA_TOTAL  IN NUMBER DEFAULT NULL,
        P_TP_RESPONSAVEL IN CHAR DEFAULT NULL,
        P_STATUS         OUT VARCHAR2,
        P_MESSAGE        OUT VARCHAR2
    );

    PROCEDURE ALTERAR_OPERACOES_COMPLETO_P (
        P_ID_OPERACAO    IN NUMBER,
        P_VL_OPERACAO    IN NUMBER DEFAULT NULL,
        P_DT_OPERACAO    IN VARCHAR2 DEFAULT NULL,
        P_ID_CATEGORIA   IN NUMBER DEFAULT NULL,
        P_ID_USUARIO     IN NUMBER DEFAULT NULL,
        P_TP_RESPONSAVEL IN CHAR DEFAULT NULL,
        P_PARCELA_ATUAL  IN NUMBER DEFAULT NULL,
        P_PARCELA_TOTAL  IN NUMBER DEFAULT NULL,
        P_STATUS         OUT VARCHAR2,
        P_MESSAGE        OUT VARCHAR2
    );

    PROCEDURE REMOVER_OPERACAO_P (
        P_ID      IN NUMBER,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE REMOVER_OPERACAO_FULL_P (
        P_ID      IN NUMBER,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE CRIAR_OPERACOES_P (
        P_ID_OPE_PAR IN OUT NUMBER,
        P_ID_FAT     IN NUMBER DEFAULT NULL,
        P_ID_OPE     IN NUMBER DEFAULT NULL,
        P_ID_USU     IN NUMBER DEFAULT NULL,
        P_ID_CAT     IN NUMBER,
        P_TP_OPE     IN VARCHAR2,
        P_VL_OPE     IN NUMBER,
        P_TP_RESP    IN VARCHAR2,
        P_PAR_ATU    IN NUMBER DEFAULT 1,
        P_PAR_TOT    IN NUMBER DEFAULT 1,
        P_DT_OPE     IN DATE,
        P_STATUS     OUT VARCHAR2,
        P_MESSAGE    OUT VARCHAR2
    );

    PROCEDURE CRIAR_OPERACOES_DEB_P (
        P_NM_CAT  IN VARCHAR2,
        P_NM_SUB  IN VARCHAR2,
        P_VL_OPE  IN NUMBER,
        P_TP_RESP IN VARCHAR2,
        P_DT_OPE  IN VARCHAR2,
        P_PAR_ATU IN NUMBER DEFAULT 1,
        P_PAR_TOT IN NUMBER DEFAULT 1,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE CRIAR_OPERACOES_CRE_P (
        P_NM_OPE  IN VARCHAR2,
        P_NM_USU  IN VARCHAR2,
        P_NM_CAT  IN VARCHAR2,
        P_NM_SUB  IN VARCHAR2,
        P_VL_OPE  IN NUMBER,
        P_TP_RESP IN VARCHAR2,
        P_PAR_TOT IN NUMBER,
        P_DT_OPE  IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

    PROCEDURE CREATE_OPERACOES_LOAD_P (
        P_NM_OPE  IN VARCHAR2,
        P_DS_FAT  IN VARCHAR2,
        P_NM_USU  IN VARCHAR2,
        P_NM_CAT  IN VARCHAR2,
        P_NM_SUB  IN VARCHAR2,
        P_VL_OPE  IN NUMBER,
        P_TP_RESP IN VARCHAR2,
        P_PAR_ATU IN NUMBER,
        P_PAR_TOT IN NUMBER,
        P_DT_OPE  IN DATE,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    );

END PKG_OPERACOES;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "RODRIGO"."PKG_OPERACOES" AS

    FUNCTION OPERACAO_EXISTE_F (
        P_ID IN NUMBER
    ) RETURN BOOLEAN IS
        V_COUNT NUMBER;
    BEGIN
        SELECT
            COUNT(1)
        INTO V_COUNT
        FROM
            OPERACOES
        WHERE
            ID_OPERACAO = P_ID;

        IF V_COUNT > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END OPERACAO_EXISTE_F;

    FUNCTION GET_OPERACOES_DET_F (
        P_ID IN NUMBER
    ) RETURN VARCHAR2 IS
        V_OPE VARCHAR2(1000);
    BEGIN
        FOR I IN (
            SELECT
                ID_OPERACAO
                || ' - '
                || ID_OPERACAO_PAR
                || ' - '
                || TIPO_OPERACAO
                || ' - '
                || NM_OPERADORA
                || ' - '
                || DESC_FATURA
                || ' - '
                || VENCIMENTO
                || ' - '
                || DT_OPERACAO
                || ' - '
                || NM_USUARIO
                || ' - '
                || NM_CATEGORIA
                || ' - '
                || NM_SUB_CATEGORIA
                || ' - '
                || PARCELA_ATUAL
                || ' - '
                || PARCELA_TOTAL
                || ' - '
                || TP_RESPONSAVEL
                || ' - '
                || VL_OPERACAO OPERACAO
            FROM
                DESC_OPERACOES_V
            WHERE
                ID_OPERACAO = P_ID
        ) LOOP
            V_OPE := I.OPERACAO;
        END LOOP;

        RETURN V_OPE;
    END GET_OPERACOES_DET_F;

    FUNCTION GET_ID_OPERACAO_UNI_F (
        P_ID IN NUMBER
    ) RETURN NUMBER IS
        V_ID OPERACOES.ID_OPERACAO%TYPE;
    BEGIN
        SELECT
            ID_OPERACAO_UNI
        INTO V_ID
        FROM
            DESC_OPERACOES_PARC_V
        WHERE
            ID_OPERACAO = P_ID;

        RETURN V_ID;
    END GET_ID_OPERACAO_UNI_F;

    PROCEDURE LISTAR_OPERACOES_P (
        P_ID_OPERACAO     IN NUMBER DEFAULT NULL,
        P_ID_OPERACAO_PAR IN NUMBER DEFAULT NULL,
        P_TIPO_OPERACAO   IN VARCHAR2 DEFAULT NULL,
        P_USUARIO         IN VARCHAR2 DEFAULT NULL,
        P_CATEGORIA       IN VARCHAR2 DEFAULT NULL,
        P_SUB_CATEGORIA   IN VARCHAR2 DEFAULT NULL,
        P_RESPONSAVEL     IN VARCHAR2 DEFAULT NULL,
        P_DT_INI          IN VARCHAR2 DEFAULT NULL, -- formato: DD/MM/YYYY
        P_DT_FIM          IN VARCHAR2 DEFAULT NULL,
        P_DESC_FATURA     IN VARCHAR2 DEFAULT NULL,
        P_LIMIT           IN NUMBER DEFAULT 30,
        P_OFFSET          IN NUMBER DEFAULT 0,
        P_CURSOR          OUT SYS_REFCURSOR,
        P_STATUS          OUT VARCHAR2,
        P_MESSAGE         OUT VARCHAR2
    ) IS
        V_DT_INI DATE;
        V_DT_FIM DATE;
    BEGIN
        -- Conversão segura de datas (se preenchidas)
        IF P_DT_INI IS NOT NULL THEN
            V_DT_INI := TO_DATE ( P_DT_INI, 'DD/MM/YYYY' );
        END IF;

        IF P_DT_FIM IS NOT NULL THEN
            V_DT_FIM := TO_DATE ( P_DT_FIM, 'DD/MM/YYYY' );
        END IF;

        OPEN P_CURSOR FOR SELECT
                                              *
                                          FROM
                                              DESC_OPERACOES_V
                         WHERE
                             ( P_ID_OPERACAO IS NULL
                               OR ID_OPERACAO = P_ID_OPERACAO )
                             AND ( P_ID_OPERACAO_PAR IS NULL
                                   OR ID_OPERACAO_PAR = P_ID_OPERACAO_PAR )
                             AND ( P_TIPO_OPERACAO IS NULL
                               OR TIPO_OPERACAO = P_TIPO_OPERACAO )
                             AND ( P_USUARIO IS NULL
                                   OR NM_USUARIO = P_USUARIO )
                             AND ( P_CATEGORIA IS NULL
                                   OR NM_CATEGORIA = P_CATEGORIA )
                             AND ( P_SUB_CATEGORIA IS NULL
                                   OR NM_SUB_CATEGORIA = P_SUB_CATEGORIA )
                             AND ( P_RESPONSAVEL IS NULL
                                   OR TP_RESPONSAVEL = P_RESPONSAVEL )
                             AND ( P_DESC_FATURA IS NULL
                                   OR DESC_FATURA = P_DESC_FATURA )
                             AND ( V_DT_INI IS NULL
                                   OR DT_OPERACAO >= V_DT_INI )
                             AND ( V_DT_FIM IS NULL
                                   OR DT_OPERACAO <= V_DT_FIM )
                         OFFSET P_OFFSET ROWS FETCH NEXT P_LIMIT ROWS ONLY;

        P_STATUS := 'SUCESSO';
        P_MESSAGE := 'Operações listadas com sucesso.';
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro: ' || SQLERRM;
    END LISTAR_OPERACOES_P;

    PROCEDURE ALTERAR_OPERACOES_FAT_P (
        P_ID_OPERACAO IN NUMBER,
        P_ID_FATURA   IN NUMBER,
        P_STATUS      OUT VARCHAR2,
        P_MESSAGE     OUT VARCHAR2
    ) IS
        E_OPE_INVALIDA EXCEPTION;
        E_FAT_INVALIDA EXCEPTION;
    BEGIN
        IF NOT PKG_OPERACOES.OPERACAO_EXISTE_F(P_ID_OPERACAO) THEN
            RAISE E_OPE_INVALIDA;
        END IF;
        IF NOT PKG_FATURAS.FATURA_EXISTE_F(P_ID_FATURA) THEN
            RAISE E_FAT_INVALIDA;
        END IF;
        UPDATE OPERACOES O
        SET
            O.ID_FATURA = P_ID_FATURA
        WHERE
            O.ID_OPERACAO = P_ID_OPERACAO;

        P_STATUS := 'SUCESSO';
        P_MESSAGE := 'Operação atualizada com sucesso: ' || GET_OPERACOES_DET_F(P_ID_OPERACAO);
        COMMIT;
    EXCEPTION
        WHEN E_FAT_INVALIDA THEN
            P_STATUS := 'ERRO';
            P_MESSAGE := 'Fatura inválida.';
            ROLLBACK;
        WHEN E_OPE_INVALIDA THEN
            P_STATUS := 'ERRO';
            P_MESSAGE := 'Operação inválida.';
            ROLLBACK;
        WHEN OTHERS THEN
            P_STATUS := 'ERRO';
            P_MESSAGE := 'Erro ao atualizar operação: ' || SQLERRM;
            ROLLBACK;
    END ALTERAR_OPERACOES_FAT_P;

    PROCEDURE ALTERAR_OPERACOES_P (
        P_ID_OPERACAO    IN NUMBER,
        P_TIPO_OPERACAO  IN VARCHAR2 DEFAULT NULL,
        P_ID_OPERADORA   IN NUMBER DEFAULT NULL,
        P_ID_FATURA      IN NUMBER DEFAULT NULL,
        P_ID_USUARIO     IN NUMBER DEFAULT NULL,
        P_ID_CATEGORIA   IN NUMBER DEFAULT NULL,
        P_DT_OPERACAO    IN VARCHAR2 DEFAULT NULL,
        P_VL_OPERACAO    IN NUMBER DEFAULT NULL,
        P_PARCELA_ATUAL  IN NUMBER DEFAULT NULL,
        P_PARCELA_TOTAL  IN NUMBER DEFAULT NULL,
        P_TP_RESPONSAVEL IN CHAR DEFAULT NULL,
        P_STATUS         OUT VARCHAR2,
        P_MESSAGE        OUT VARCHAR2
    ) IS
        V_COUNT NUMBER;
    BEGIN

    -- Verifica se a operação existe
        SELECT
            COUNT(*)
        INTO V_COUNT
        FROM
            RODRIGO.OPERACOES
        WHERE
            ID_OPERACAO = P_ID_OPERACAO;

        IF V_COUNT = 0 THEN
            P_STATUS := 'ERRO';
            P_MESSAGE := 'Operação não encontrada.';
            RETURN;
        END IF;

   -- Atualiza a operação
        UPDATE RODRIGO.OPERACOES
        SET
            /*TIPO_OPERACAO = P_TIPO_OPERACAO,
            ID_OPERADORA = P_ID_OPERADORA,
            ID_FATURA = P_ID_FATURA,
            ID_USUARIO = P_ID_USUARIO,
            ID_CATEGORIA = P_ID_CATEGORIA,
            DT_OPERACAO = TO_DATE(P_DT_OPERACAO, 'DD/MM/YYYY'),
            VL_OPERACAO = P_VL_OPERACAO,
            PARCELA_ATUAL = P_PARCELA_ATUAL,
            PARCELA_TOTAL = P_PARCELA_TOTAL,
            TP_RESPONSAVEL = P_TP_RESPONSAVEL*/
            VL_OPERACAO = P_VL_OPERACAO
        WHERE
            ID_OPERACAO = P_ID_OPERACAO;

        P_STATUS := 'SUCESSO';
        P_MESSAGE := 'Operação atualizada com sucesso: ' || GET_OPERACOES_DET_F(P_ID_OPERACAO);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'ERRO';
            P_MESSAGE := 'Erro ao atualizar operação: ' || SQLERRM;
            ROLLBACK;
    END ALTERAR_OPERACOES_P;

    PROCEDURE ALTERAR_OPERACOES_COMPLETO_P (
        P_ID_OPERACAO    IN NUMBER,
        P_VL_OPERACAO    IN NUMBER DEFAULT NULL,
        P_DT_OPERACAO    IN VARCHAR2 DEFAULT NULL,
        P_ID_CATEGORIA   IN NUMBER DEFAULT NULL,
        P_ID_USUARIO     IN NUMBER DEFAULT NULL,
        P_TP_RESPONSAVEL IN CHAR DEFAULT NULL,
        P_PARCELA_ATUAL  IN NUMBER DEFAULT NULL,
        P_PARCELA_TOTAL  IN NUMBER DEFAULT NULL,
        P_STATUS         OUT VARCHAR2,
        P_MESSAGE        OUT VARCHAR2
    ) IS
        V_COUNT NUMBER;
        V_DT_OPE DATE;
    BEGIN
        -- Verifica se a operação existe
        SELECT
            COUNT(*)
        INTO V_COUNT
        FROM
            RODRIGO.OPERACOES
        WHERE
            ID_OPERACAO = P_ID_OPERACAO;

        IF V_COUNT = 0 THEN
            P_STATUS := 'ERRO';
            P_MESSAGE := 'Operação não encontrada.';
            RETURN;
        END IF;

        -- Converte data se informada
        IF P_DT_OPERACAO IS NOT NULL THEN
            V_DT_OPE := TO_DATE(P_DT_OPERACAO, 'DD/MM/YYYY');
        END IF;

        -- Atualiza a operação com todos os campos informados
        UPDATE RODRIGO.OPERACOES
        SET
            VL_OPERACAO = COALESCE(P_VL_OPERACAO, VL_OPERACAO),
            DT_OPERACAO = COALESCE(V_DT_OPE, DT_OPERACAO),
            ID_CATEGORIA = COALESCE(P_ID_CATEGORIA, ID_CATEGORIA),
            ID_USUARIO = COALESCE(P_ID_USUARIO, ID_USUARIO),
            TP_RESPONSAVEL = COALESCE(P_TP_RESPONSAVEL, TP_RESPONSAVEL),
            PARCELA_ATUAL = COALESCE(P_PARCELA_ATUAL, PARCELA_ATUAL),
            PARCELA_TOTAL = COALESCE(P_PARCELA_TOTAL, PARCELA_TOTAL)
        WHERE
            ID_OPERACAO = P_ID_OPERACAO;

        P_STATUS := 'SUCESSO';
        P_MESSAGE := 'Operação atualizada com sucesso: ' || GET_OPERACOES_DET_F(P_ID_OPERACAO);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'ERRO';
            P_MESSAGE := 'Erro ao atualizar operação: ' || SQLERRM;
            ROLLBACK;
    END ALTERAR_OPERACOES_COMPLETO_P;

    PROCEDURE REMOVER_OPERACAO_P (
        P_ID      IN NUMBER,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_OPE VARCHAR2(1000);
    BEGIN
        IF OPERACAO_EXISTE_F(P_ID) THEN
            V_OPE := GET_OPERACOES_DET_F(P_ID);
            DELETE FROM OPERACOES
            WHERE
                ID_OPERACAO = P_ID;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Operação removida: ' || V_OPE;
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - ' || P_MESSAGE);
        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Operação não existe: ' || P_ID;
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - ' || P_MESSAGE);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro inesperado: '
                         || SQLERRM
                         || ' - '
                         || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - ' || P_MESSAGE);
    END REMOVER_OPERACAO_P;

    PROCEDURE REMOVER_OPERACAO_FULL_P (
        P_ID      IN NUMBER,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS
        V_OPE VARCHAR2(1000);
    BEGIN
        FOR O IN (
            SELECT
                ID_OPERACAO
            FROM
                OPERACOES
            WHERE
                ID_OPERACAO = P_ID
                OR ID_OPERACAO_PAR = P_ID
        ) LOOP
            V_OPE := GET_OPERACOES_DET_F(O.ID_OPERACAO);
            DELETE FROM OPERACOES
            WHERE
                ID_OPERACAO = O.ID_OPERACAO;

            P_STATUS := 'SUCESSO';
            P_MESSAGE := 'Operação removida: ' || V_OPE;
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - ' || P_MESSAGE);
        END LOOP;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro inesperado: '
                         || SQLERRM
                         || ' - '
                         || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - ' || P_MESSAGE);
    END REMOVER_OPERACAO_FULL_P;

    PROCEDURE CRIAR_OPERACOES_P (
        P_ID_OPE_PAR IN OUT NUMBER,
        P_ID_FAT     IN NUMBER DEFAULT NULL,
        P_ID_OPE     IN NUMBER DEFAULT NULL,
        P_ID_USU     IN NUMBER DEFAULT NULL,
        P_ID_CAT     IN NUMBER,
        P_TP_OPE     IN VARCHAR2,
        P_VL_OPE     IN NUMBER,
        P_TP_RESP    IN VARCHAR2,
        P_PAR_ATU    IN NUMBER DEFAULT 1,
        P_PAR_TOT    IN NUMBER DEFAULT 1,
        P_DT_OPE     IN DATE,
        P_STATUS     OUT VARCHAR2,
        P_MESSAGE    OUT VARCHAR2
    ) IS
        V_ID  OPERACOES.ID_OPERACAO%TYPE;
        V_OPE VARCHAR2(1000);
    BEGIN
        INSERT INTO OPERACOES (
            ID_OPERACAO,
            ID_OPERACAO_PAR,
            ID_FATURA,
            ID_OPERADORA,
            ID_USUARIO,
            ID_CATEGORIA,
            TIPO_OPERACAO,
            DT_OPERACAO,
            VL_OPERACAO,
            TP_RESPONSAVEL,
            PARCELA_ATUAL,
            PARCELA_TOTAL
        ) VALUES ( SEQ_OPERACOES.NEXTVAL,
                   NVL(P_ID_OPE_PAR, SEQ_OPERACOES.CURRVAL),
                   P_ID_FAT,
                   P_ID_OPE,
                   P_ID_USU,
                   P_ID_CAT,
                   P_TP_OPE,
                   P_DT_OPE,
                   P_VL_OPE,
                   P_TP_RESP,
                   P_PAR_ATU,
                   P_PAR_TOT ) RETURNING ID_OPERACAO INTO V_ID;

        COMMIT;
        V_OPE := GET_OPERACOES_DET_F(V_ID);
        P_STATUS := 'SUCESSO';
        P_MESSAGE := 'Operação Criada: ' || V_OPE;
        DBMS_OUTPUT.PUT_LINE(P_STATUS
                             || ' - ' || P_MESSAGE);
        IF (
            P_PAR_ATU = 1
            AND P_PAR_TOT > 1
        ) THEN
            P_ID_OPE_PAR := V_ID;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro inesperado: '
                         || SQLERRM
                         || ' - '
                         || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - ' || P_MESSAGE);
    END CRIAR_OPERACOES_P;

    PROCEDURE CRIAR_OPERACOES_DEB_P (
        P_NM_CAT  IN VARCHAR2,
        P_NM_SUB  IN VARCHAR2,
        P_VL_OPE  IN NUMBER,
        P_TP_RESP IN VARCHAR2,
        P_DT_OPE  IN VARCHAR2,
        P_PAR_ATU IN NUMBER DEFAULT 1,
        P_PAR_TOT IN NUMBER DEFAULT 1,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS

        V_ID_CAT     CATEGORIAS.ID_CATEGORIA%TYPE;
        V_TP_OPE     OPERACOES.TIPO_OPERACAO%TYPE := 'DÉBITO';
        V_ID_OPE_PAR OPERACOES.ID_OPERACAO_PAR%TYPE;
        V_DT_OPE     OPERACOES.DT_OPERACAO%TYPE := TO_DATE ( P_DT_OPE, 'DD/MM/YYYY' );
    BEGIN
        IF PKG_CATEGORIAS.CATEGORIA_EXISTE_F(P_NM_CAT, P_NM_SUB) THEN
            V_ID_CAT := PKG_CATEGORIAS.GET_CATEGORIA_F(P_NM_CAT, P_NM_SUB);
            CRIAR_OPERACOES_P(
                P_ID_OPE_PAR => V_ID_OPE_PAR,
                P_ID_CAT     => V_ID_CAT,
                P_TP_OPE     => V_TP_OPE,
                P_VL_OPE     => P_VL_OPE,
                P_TP_RESP    => P_TP_RESP,
                P_DT_OPE     => V_DT_OPE,
                P_PAR_ATU    => P_PAR_ATU,
                P_PAR_TOT    => P_PAR_TOT,
                P_STATUS     => P_STATUS,
                P_MESSAGE    => P_MESSAGE
            );

        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Categoria Inválida: '
                         || V_TP_OPE
                         || ' - '
                         || P_NM_CAT
                         || ' - '
                         || P_NM_SUB
                         || ' - '
                         || P_VL_OPE
                         || ' - '
                         || P_TP_RESP
                         || ' - '
                         || V_DT_OPE;

            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - ' || P_MESSAGE);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Erro inesperado: '
                         || SQLERRM
                         || ' - '
                         || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE();
    END CRIAR_OPERACOES_DEB_P;

    PROCEDURE CRIAR_OPERACOES_CRE_P (
        P_NM_OPE  IN VARCHAR2,
        P_NM_USU  IN VARCHAR2,
        P_NM_CAT  IN VARCHAR2,
        P_NM_SUB  IN VARCHAR2,
        P_VL_OPE  IN NUMBER,
        P_TP_RESP IN VARCHAR2,
        P_PAR_TOT IN NUMBER,
        P_DT_OPE  IN VARCHAR2,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS

        V_ID_OPE_PAR OPERACOES.ID_OPERACAO_PAR%TYPE;
        V_ID_FAT     FATURAS.ID_FATURA%TYPE;
        V_ID_OPE     OPERADORAS.ID_OPERADORA%TYPE;
        V_ID_USU     USUARIOS.ID_USUARIO%TYPE;
        V_ID_CAT     CATEGORIAS.ID_CATEGORIA%TYPE;
        V_TP_OPE     OPERACOES.TIPO_OPERACAO%TYPE := 'CRÉDITO';
        V_DT_OPE     OPERACOES.DT_OPERACAO%TYPE := TO_DATE ( P_DT_OPE, 'DD/MM/YYYY' );
        V_DT_OPE_NEW OPERACOES.DT_OPERACAO%TYPE := V_DT_OPE;
    BEGIN
        IF PKG_OPERADORAS.OPERADORA_EXISTE_F(P_NM_OPE) THEN
            V_ID_OPE := PKG_OPERADORAS.GET_OPERADORA_F(P_NM_OPE);
            IF PKG_USUARIOS.USUARIO_EXISTE_F(P_NM_USU) THEN
                V_ID_USU := PKG_USUARIOS.GET_USUARIO_F(P_NM_USU);
                IF PKG_CATEGORIAS.CATEGORIA_EXISTE_F(P_NM_CAT, P_NM_SUB) THEN
                    V_ID_CAT := PKG_CATEGORIAS.GET_CATEGORIA_F(P_NM_CAT, P_NM_SUB);
                    FOR V_PAR_ATU IN 1..P_PAR_TOT LOOP
                        IF
                            P_PAR_TOT > 1
                            AND V_PAR_ATU > 1
                        THEN
                            V_DT_OPE_NEW := ADD_MONTHS(V_DT_OPE, V_PAR_ATU - 1);
                        END IF;

                        IF NOT PKG_FATURAS.FATURA_EXISTE_F(V_ID_OPE, V_DT_OPE_NEW) THEN
                            PKG_FATURAS.CRIAR_FATURA_P(
                                PKG_OPERADORAS.GET_OPERADORA_F(V_ID_OPE),
                                V_DT_OPE_NEW,
                                P_STATUS,
                                P_MESSAGE
                            );
                        END IF;

                        V_ID_FAT := PKG_FATURAS.GET_FATURA_F(V_ID_OPE, V_DT_OPE_NEW);
                        CRIAR_OPERACOES_P(
                            P_ID_OPE_PAR => V_ID_OPE_PAR,
                            P_ID_FAT     => V_ID_FAT,
                            P_ID_OPE     => V_ID_OPE,
                            P_ID_USU     => V_ID_USU,
                            P_ID_CAT     => V_ID_CAT,
                            P_TP_OPE     => V_TP_OPE,
                            P_VL_OPE     => P_VL_OPE,
                            P_TP_RESP    => P_TP_RESP,
                            P_PAR_ATU    => V_PAR_ATU,
                            P_PAR_TOT    => P_PAR_TOT,
                            P_DT_OPE     => V_DT_OPE_NEW,
                            P_STATUS     => P_STATUS,
                            P_MESSAGE    => P_MESSAGE
                        );

                    END LOOP;

                    V_ID_OPE_PAR := NULL;
                ELSE
                    P_STATUS := 'FALHA';
                    P_MESSAGE := 'Categoria Inválida: '
                                 || P_NM_CAT
                                 || ' - '
                                 || P_NM_SUB
                                 || '.';
                    DBMS_OUTPUT.PUT_LINE(P_STATUS
                                         || ' - ' || P_MESSAGE);
                END IF;

            ELSE
                P_STATUS := 'FALHA';
                P_MESSAGE := 'Usuário Inválido: '
                             || P_NM_USU
                             || '.';
                DBMS_OUTPUT.PUT_LINE(P_STATUS
                                     || ' - ' || P_MESSAGE);
            END IF;

        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Operadora Inválida: '
                         || P_NM_OPE
                         || '.';
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - ' || P_MESSAGE);
        END IF;
    END CRIAR_OPERACOES_CRE_P;

    PROCEDURE CREATE_OPERACOES_LOAD_P (
        P_NM_OPE  IN VARCHAR2,
        P_DS_FAT  IN VARCHAR2,
        P_NM_USU  IN VARCHAR2,
        P_NM_CAT  IN VARCHAR2,
        P_NM_SUB  IN VARCHAR2,
        P_VL_OPE  IN NUMBER,
        P_TP_RESP IN VARCHAR2,
        P_PAR_ATU IN NUMBER,
        P_PAR_TOT IN NUMBER,
        P_DT_OPE  IN DATE,
        P_STATUS  OUT VARCHAR2,
        P_MESSAGE OUT VARCHAR2
    ) IS

        V_ID_OPE_PAR OPERACOES.ID_OPERACAO_PAR%TYPE;
        V_ID_FAT     FATURAS.ID_FATURA%TYPE;
        V_ID_OPE     OPERADORAS.ID_OPERADORA%TYPE;
        V_ID_USU     USUARIOS.ID_USUARIO%TYPE;
        V_ID_CAT     CATEGORIAS.ID_CATEGORIA%TYPE;
        V_TP_OPE     OPERACOES.TIPO_OPERACAO%TYPE := 'CRÉDITO';
    BEGIN
        IF PKG_OPERADORAS.OPERADORA_EXISTE_F(P_NM_OPE) THEN
            V_ID_OPE := PKG_OPERADORAS.GET_OPERADORA_F(P_NM_OPE);
            IF PKG_FATURAS.FATURA_EXISTE_F(P_NM_OPE, P_DS_FAT) THEN
                V_ID_FAT := PKG_FATURAS.GET_FATURA_F(P_NM_OPE, P_DS_FAT);
                IF PKG_USUARIOS.USUARIO_EXISTE_F(P_NM_USU) THEN
                    V_ID_USU := PKG_USUARIOS.GET_USUARIO_F(P_NM_USU);
                    IF PKG_CATEGORIAS.CATEGORIA_EXISTE_F(P_NM_CAT, P_NM_SUB) THEN
                        V_ID_CAT := PKG_CATEGORIAS.GET_CATEGORIA_F(P_NM_CAT, P_NM_SUB);
                        CRIAR_OPERACOES_P(
                            P_ID_OPE_PAR => V_ID_OPE_PAR,
                            P_ID_FAT     => V_ID_FAT,
                            P_ID_OPE     => V_ID_OPE,
                            P_ID_USU     => V_ID_USU,
                            P_ID_CAT     => V_ID_CAT,
                            P_TP_OPE     => V_TP_OPE,
                            P_VL_OPE     => P_VL_OPE,
                            P_TP_RESP    => P_TP_RESP,
                            P_PAR_ATU    => P_PAR_ATU,
                            P_PAR_TOT    => P_PAR_TOT,
                            P_DT_OPE     => P_DT_OPE,
                            P_STATUS     => P_STATUS,
                            P_MESSAGE    => P_MESSAGE
                        );

                    ELSE
                        P_STATUS := 'FALHA';
                        P_MESSAGE := 'Categoria Inválida: '
                                     || P_NM_CAT
                                     || ' - '
                                     || P_NM_SUB
                                     || '.';
                        DBMS_OUTPUT.PUT_LINE(P_STATUS
                                             || ' - ' || P_MESSAGE);
                    END IF;

                ELSE
                    P_STATUS := 'FALHA';
                    P_MESSAGE := 'Usuário Inválido: '
                                 || P_NM_USU
                                 || '.';
                    DBMS_OUTPUT.PUT_LINE(P_STATUS
                                         || ' - ' || P_MESSAGE);
                END IF;

            ELSE
                P_STATUS := 'FALHA';
                P_MESSAGE := 'Fatura Inválida: '
                             || P_NM_OPE
                             || ' - '
                             || P_DT_OPE
                             || '.';
                DBMS_OUTPUT.PUT_LINE(P_STATUS
                                     || ' - ' || P_MESSAGE);
            END IF;

        ELSE
            P_STATUS := 'FALHA';
            P_MESSAGE := 'Operadora Inválida: '
                         || P_NM_OPE
                         || '.';
            DBMS_OUTPUT.PUT_LINE(P_STATUS
                                 || ' - ' || P_MESSAGE);
        END IF;
    END CREATE_OPERACOES_LOAD_P;

END PKG_OPERACOES;
/

