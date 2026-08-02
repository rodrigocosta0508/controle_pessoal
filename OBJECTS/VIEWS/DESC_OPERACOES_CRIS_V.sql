CREATE OR REPLACE VIEW RODRIGO.DESC_OPERACOES_CRIS_V AS 
SELECT
    *
FROM
    (
        SELECT
            ID_OPERACAO,
            ID_OPERACAO_PAR,
            TIPO_OPERACAO,
            ID_OPERADORA,
            NM_OPERADORA,
            ID_FATURA,
            DESC_FATURA,
            VENCIMENTO,
            DT_OPERACAO,
            DT_OPERACAO_UNICA,
            DT_OPERACAO_ORI,
            ID_USUARIO,
            NM_USUARIO,
            ID_CATEGORIA,
            NM_CATEGORIA,
            NM_SUB_CATEGORIA,
            PARCELA_ATUAL,
            PARCELA_TOTAL,
            PARCELA,
            TP_RESPONSAVEL,
            CASE 
                WHEN NM_OPERADORA = 'NUBANK' THEN VL_OPERACAO * -1
                WHEN TP_RESPONSAVEL = 'A' THEN ROUND((VL_OPERACAO * 0.4), 2)
                WHEN TP_RESPONSAVEL = 'C' THEN VL_OPERACAO
                ELSE VL_OPERACAO
            END VL_OPERACAO
        FROM
            DESC_OPERACOES_V
        WHERE
            TP_RESPONSAVEL IN ('C', 'A') OR NM_OPERADORA = 'NUBANK'
    )
;