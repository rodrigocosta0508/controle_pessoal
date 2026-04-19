CREATE OR REPLACE FORCE EDITIONABLE VIEW "RODRIGO"."DESC_OPERACOES_CRIS_V" ("ID_OPERACAO", "ID_OPERACAO_PAR", "TIPO_OPERACAO", "NM_OPERADORA", "DESC_FATURA", "VENCIMENTO", "DT_OPERACAO", "DT_OPERACAO_UNICA", "NM_USUARIO", "NM_CATEGORIA", "NM_SUB_CATEGORIA", "PARCELA_ATUAL", "PARCELA_TOTAL", "TP_RESPONSAVEL", "VL_OPERACAO") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
        "ID_OPERACAO",
        "ID_OPERACAO_PAR",
        "TIPO_OPERACAO",
        "NM_OPERADORA",
        "DESC_FATURA",
        "VENCIMENTO",
        "DT_OPERACAO",
        "DT_OPERACAO_UNICA",
        "NM_USUARIO",
        "NM_CATEGORIA",
        "NM_SUB_CATEGORIA",
        "PARCELA_ATUAL",
        "PARCELA_TOTAL",
        "TP_RESPONSAVEL",
        "VL_OPERACAO"
    FROM
        (
            SELECT
                ID_OPERACAO,
                ID_OPERACAO_PAR,
                TIPO_OPERACAO,
                NM_OPERADORA,
                DESC_FATURA,
                VENCIMENTO,
                DT_OPERACAO,
                DT_OPERACAO_UNICA,
                NM_USUARIO,
                NM_CATEGORIA,
                NM_SUB_CATEGORIA,
                PARCELA_ATUAL,
                PARCELA_TOTAL,
                TP_RESPONSAVEL,
                VL_OPERACAO
            FROM
                DESC_OPERACOES_V
            WHERE
                TP_RESPONSAVEL = 'C'
            UNION ALL
            SELECT
                ID_OPERACAO,
                ID_OPERACAO_PAR,
                TIPO_OPERACAO,
                NM_OPERADORA,
                DESC_FATURA,
                VENCIMENTO,
                DT_OPERACAO,
                DT_OPERACAO_UNICA,
                NM_USUARIO,
                NM_CATEGORIA,
                NM_SUB_CATEGORIA,
                PARCELA_ATUAL,
                PARCELA_TOTAL,
                TP_RESPONSAVEL,
                ROUND((VL_OPERACAO * 0.4), 2) VL_OPERACAO
            FROM
                DESC_OPERACOES_V
            WHERE
                TP_RESPONSAVEL = 'A'
            UNION ALL
            SELECT
                ID_OPERACAO,
                ID_OPERACAO_PAR,
                TIPO_OPERACAO,
                NM_OPERADORA,
                DESC_FATURA,
                VENCIMENTO,
                DT_OPERACAO,
                DT_OPERACAO_UNICA,
                NM_USUARIO,
                NM_CATEGORIA,
                NM_SUB_CATEGORIA,
                PARCELA_ATUAL,
                PARCELA_TOTAL,
                TP_RESPONSAVEL,
                VL_OPERACAO * -1
            FROM
                DESC_OPERACOES_V
            WHERE
                NM_OPERADORA = 'NUBANK'
        )
    ORDER BY
        PARCELA_ATUAL,
        DT_OPERACAO_UNICA DESC,
        DT_OPERACAO DESC,
        ID_OPERACAO DESC
;

