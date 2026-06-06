CREATE OR REPLACE VIEW RODRIGO.DESC_OPERACOES_RODRIGO_V AS 
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
                TP_RESPONSAVEL,
                VL_OPERACAO
            FROM
                DESC_OPERACOES_V
            WHERE
                    TP_RESPONSAVEL = 'R'
                AND NM_CATEGORIA NOT IN ( 'PAGAMENTO', 'RESERVA', 'RESSARCIMENTO' )
                AND NM_SUB_CATEGORIA NOT IN ( 'EXTERIOR', 'RESERVA', 'NACIONAL' )
                AND ID_OPERACAO NOT IN (10999,10998,10996,10995,10994,10993,10992)
            UNION ALL
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
                TP_RESPONSAVEL,
                ROUND((VL_OPERACAO * 0.6), 2) VL_OPERACAO
            FROM
                DESC_OPERACOES_V
            WHERE
                TP_RESPONSAVEL = 'A'
        )
    ORDER BY   DT_OPERACAO_ORI DESC
;

