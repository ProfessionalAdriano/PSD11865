---------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA     : AMADEUS CAPITALIZAÇÃO
-- DESCRIÇÃO   : EM VIRTUDE DO SALDAMENTO DO PLANO PSAP/ELETROPAULO (PLANO 19), O EXTRATO PREVIDENCIÁRIO PRECISARÁ PASSAR POR ALTERAÇÕES
-- ANALISTA    : ADRIANO LIMA
-- DATA CRIAÇÃO: 23/11/2020
-- MANUTENÇÕES : PROJ-760/PSD-11865 - DATA: 23/11/2020 – ANALISTA: ADRIANO LIMA/RENATO DAVI 
--               
--
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA     : AMADEUS CAPITALIZAÇÃO
-- DESCRIÇÃO   : TRATAR OS DADOS DO TXT DA CNPC32, EFETUAR A CARGA NO CHARGER E EXECUTAR PROCEDURE P/ AJUSTES DO EXTRATO PREVIDENCIÁRIO
-- ANALISTA    : ADRIANO LIMA
-- DATA CRIAÇÃO: 29/01/2021
-- MANUTENÇÕES : PROJ-3677 - DATA: 02/02/2021 – ANALISTA: ADRIANO LIMA/RENATO DAVI 
--               
--
---------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA(P_COD_EMPRESA FC_PRE_TBL_BASE_EXTRAT_CTB.COD_EMPRS%TYPE,
                                                               P_DCR_PLANO   FC_PRE_TBL_BASE_EXTRAT_CTB.DCR_PLANO%TYPE,
                                                               P_DTA_MOV     FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE) IS

  --VARIAVEL DECLARADA PARA GUARDAR A MAIOR DATA DA PUBLICACAO DO EXTRATO.
  L_DT_FIM     ATT.FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE;
  L_MAX_ANOMES ATT.SLD_CONTA_PARTIC_FSS.ANOMES_MOVIM_SDCTPR%TYPE;
  L_NUM_MATR_PARTF ATT.PARTICIPANTE_FSS.NUM_MATR_PARTF%TYPE;
  L_COUNT      NUMBER := 0;

BEGIN

  BEGIN
  
    IF (P_DTA_MOV IS NOT NULL) THEN
      IF (P_COD_EMPRESA = P_COD_EMPRESA AND
         UPPER(P_DCR_PLANO) = UPPER(P_DCR_PLANO)) THEN
      
        SELECT MAX(TO_DATE(FP.DTA_FIM_EXTR, 'DD/MM/RRRR'))
          INTO L_DT_FIM
          FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP
         WHERE FP.COD_EMPRS = P_COD_EMPRESA
           AND UPPER(FP.DCR_PLANO) = UPPER(P_DCR_PLANO);
      
        INSERT INTO OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
          (COD_EMPRESA, NUM_REGISTRO, DCR_PLANO, NUM_MATR, COD_PLANO)
          SELECT X.COD_EMPRS,
                 X.NUM_RGTRO_EMPRG,
                 X.DCR_PLANO,
                 Y.NUM_MATR_PARTF,
                 19
            FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB X
           INNER JOIN ATT.PARTICIPANTE_FSS Y ON Y.COD_EMPRS = X.COD_EMPRS
                                            AND Y.NUM_RGTRO_EMPRG =
                                                TO_NUMBER(SUBSTR(X.NUM_RGTRO_EMPRG,
                                                                 1,
                                                                 LENGTH(X.NUM_RGTRO_EMPRG) - 2))
           WHERE X.COD_EMPRS = P_COD_EMPRESA
             AND X.DCR_PLANO = P_DCR_PLANO
             AND Y.NUM_MATR_PARTF IN (49849, 44345, 84336)
           GROUP BY X.COD_EMPRS,
                    X.NUM_RGTRO_EMPRG,
                    X.DCR_PLANO,
                    Y.NUM_MATR_PARTF;
      
        --INICIO DAS CONSISTENCIAS DE DADOS
        IF P_DTA_MOV IS NULL THEN
          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
             SET E.DTA_FIM = (SELECT MAX(DTA_FIM_EXTR)
                                FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                               WHERE COD_EMPRS = E.COD_EMPRESA
                                 AND DCR_PLANO = E.DCR_PLANO
                                 AND NUM_RGTRO_EMPRG = E.NUM_REGISTRO)
          
           WHERE E.DTA_FIM IS NULL;
        
        ELSE
          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
             SET E.DTA_FIM = P_DTA_MOV
           WHERE E.DTA_FIM IS NULL;
        
        END IF;
      
        BEGIN
          FOR RG IN (SELECT DISTINCT X.COD_EMPRS       AS COD_EMPRS,
                                     19                AS COD_PLANO,
                                     Y.NUM_MATR_PARTF  AS NUM_MATR_PARTF,
                                     X.NUM_RGTRO_EMPRG AS NUM_RGTRO_EMPRG
                     --
                       FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB X
                      INNER JOIN ATT.PARTICIPANTE_FSS Y ON Y.COD_EMPRS =
                                                           X.COD_EMPRS
                                                       AND Y.NUM_RGTRO_EMPRG =
                                                           TO_NUMBER(SUBSTR(X.NUM_RGTRO_EMPRG,
                                                                            1,
                                                                            LENGTH(X.NUM_RGTRO_EMPRG) - 2))
                      INNER JOIN ATT.SLD_CONTA_PARTIC_FSS S ON S.NUM_MATR_PARTF =
                                                               Y.NUM_MATR_PARTF
                      WHERE X.COD_EMPRS IN (40, 60) --= P_CR_CODEMPRS
                        AND UPPER(X.DCR_PLANO) = UPPER('PSAP/ELETROPAULO')
                        AND S.NUM_CTFSS IN
                            (23, 24, 30, 31, 165, 166, 259, 260, 436, 948, 949, 959, 976)
                        AND S.COD_UM = 248
                        AND Y.NUM_MATR_PARTF IN (49849, 44345, 84336))
         LOOP
            L_NUM_MATR_PARTF := RG.NUM_MATR_PARTF;
            --
            SELECT MAX(SCPF.ANOMES_MOVIM_SDCTPR)
              INTO L_MAX_ANOMES
              FROM ATT.SLD_CONTA_PARTIC_FSS SCPF
             WHERE 0 = 0
               AND SCPF.NUM_MATR_PARTF = RG.NUM_MATR_PARTF
               AND SCPF.NUM_CTFSS IN (23, 24, 30, 31, 165, 166, 259, 260, 436, 948, 949, 959, 976)
               AND SCPF.COD_UM = 248;
          
            /*       DBMS_OUTPUT.put_line('L_MAX_ANOMES: ' || TO_CHAR(L_MAX_ANOMES) || CHR(13) ||
            'P_DTA_MOV: ' || TO_CHAR(P_DTA_MOV) || CHR(13) ||
            'L_DT_FIM: ' || TO_CHAR(L_DT_FIM));*/
            --
            -- se a data informada como parametro for diferente do ano/mes da tabela saldo conta
            -- ou a data de ultimo processamento for diferente do ano/mes da tabela saldo conta
            -- atribui a data da tabela saldo conta como condicao para alterar os dados na
            
            -- OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
            IF NOT (TO_CHAR(L_MAX_ANOMES) <> TO_CHAR(TO_DATE(P_DTA_MOV, 'DD/MM/RRRR'), 'YYYYMM') 
             OR TO_CHAR(L_MAX_ANOMES) <> TO_CHAR(TO_DATE(L_DT_FIM, 'DD/MM/RRRR'), 'YYYYMM')) THEN
              --
              /*DBMS_OUTPUT.PUT_LINE('IF');
              DBMS_OUTPUT.put_line('P_DTA_MOV: ' || TO_CHAR(TO_NUMBER(TRUNC(P_DTA_MOV,'YYYYMM'))));
              DBMS_OUTPUT.put_line('L_DT_FIM: '  || TO_CHAR(TO_NUMBER(TRUNC(L_DT_FIM,'YYYYMM'))));*/
            
              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
                 SET E.VLR_BENEF_INTE = (SELECT NVL(MAX(H.VLR_BENEF1_HTBNF),
                                                    0)
                                           FROM HIST_VALOR_BNF H
                                          WHERE H.NUM_MATR_PARTF = NUM_MATR
                                            AND H.COD_NATBNF = 4
                                            AND TO_CHAR(H.DAT_INIVG_HTBNF,
                                                        'YYYYMM') =
                                                TO_CHAR(E.DTA_FIM, 'YYYYMM'))
               WHERE E.VLR_BENEF_INTE = 0;
              COMMIT;
            
              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB B
                 SET B.VLR_DQ = 0,
                     
                     B.VLR_DR = (SELECT NVL(MAX(VLR_BENEF1_HTBNF), 0)
                                   FROM HIST_VALOR_BNF
                                  WHERE NUM_MATR_PARTF = NUM_MATR
                                    AND COD_NATBNF = 4
                                    AND TO_CHAR(DAT_INIVG_HTBNF, 'YYYYMM') =
                                        TO_CHAR(B.DTA_FIM, 'YYYYMM')),
                     
                     B.VLR_EI = ATT.FCESP_VLR_CTB_ASSIST(B.COD_PLANO,
                                                         B.VLR_BENEF_INTE),
                     
                     B.VLR_EG = 0,
                     
                     B.VLR_RES2 = (SELECT NVL(MAX(A.VLR_CDIAUM), 0) AS VLR_CDIAUM
                                     FROM COTACAO_DIA_UM A
                                    WHERE A.COD_UM = 248
                                      AND A.DAT_CDIAUM =
                                          (SELECT MAX(DAT_CDIAUM)
                                             FROM COTACAO_DIA_UM
                                            WHERE COD_UM = A.COD_UM
                                              AND DAT_CDIAUM =
                                                  TO_DATE(TRUNC(P_DTA_MOV))))
              
               WHERE B.VLR_DQ = 0;
            
              COMMIT;
            
              -- VLR_SLD_ADICIONAL
              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
                 SET VLR_RES3 = ROUND(VLR_RES1 * VLR_RES2)
               WHERE VLR_RES1 > 0;
            
              -- VLR_BENEF_ADICIONAL
              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
                 SET VLR_RES4 = VLR_RES3 / 130
               WHERE VLR_RES3 > 0;
              COMMIT;
            ELSE
              --DBMS_OUTPUT.PUT_LINE('ELSE');
            
              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB B
                 SET B.VLR_RES1 = (SELECT NVL(SUM(SCPF.VLR_SDANT_SDCTPR +
                                                  SCPF.VLR_ENTMES_SDCTPR -
                                                  SCPF.VLR_SAIMES_SDCTPR),
                                              0) AS VLR_RES1
                                     FROM ATT.SLD_CONTA_PARTIC_FSS    SCPF -- A
                                         ,ATT.PARTICIPANTE_FSS        PF -- P
                                         ,ATT.ADESAO_PLANO_PARTIC_FSS APPF -- B
                                         ,ATT.CONTA_FSS               CF -- C
                                    WHERE 1 = 1
                                      AND SCPF.NUM_MATR_PARTF = PF.NUM_MATR_PARTF
                                      AND SCPF.COD_UM = CF.COD_UMARMZ_CTFSS --
                                      AND SCPF.NUM_CTFSS = CF.NUM_CTFSS
                                      AND PF.NUM_MATR_PARTF = APPF.NUM_MATR_PARTF
                                         --
                                      AND PF.NUM_MATR_PARTF = L_NUM_MATR_PARTF --B.NUM_MATR
                                         --
                                      AND APPF.NUM_PLBNF = 19
                                      AND SCPF.NUM_CTFSS IN (23, 24, 30, 31, 165, 166, 259, 260, 436, 948, 949, 959, 976)
                                      AND SCPF.COD_UM = 248
                                      AND PF.COD_EMPRS IN (40, 60)
                                      AND SCPF.ANOMES_MOVIM_SDCTPR <= L_MAX_ANOMES
                                   );
                                   
                IF SQL%ROWCOUNT > 0 THEN
                  COMMIT;
                END IF;
            END IF;
            
            L_COUNT := L_COUNT + 1;
          END LOOP;
        EXCEPTION
          WHEN OTHERS THEN
            --NULL;
            DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
        END;
      
        -- ELIMINA OS REGISTRO QUE PERTENCEM AO PLANO 19 COM A DESCRICAO --> (Plano CD 2 Eletropaulo/Plano CD Eletropaulo)
        DELETE FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB PT
         WHERE REGEXP_LIKE(PT.DCR_PLANO,
                           '(Plano CD 2 Eletropaulo|Plano CD Eletropaulo)');
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('TEMPORARIA PREENCHIDA');
      
      ELSE
      
        IF P_COD_EMPRESA = P_COD_EMPRESA AND
           UPPER(P_DCR_PLANO) = UPPER(P_DCR_PLANO) THEN
        
          SELECT MAX(TO_DATE(FP.DTA_FIM_EXTR, 'DD/MM/RRRR'))
            INTO L_DT_FIM
            FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP
           WHERE FP.COD_EMPRS = P_COD_EMPRESA
             AND UPPER(FP.DCR_PLANO) = UPPER(P_DCR_PLANO);
        
          --DBMS_OUTPUT.PUT_LINE('L_DT_FIM: ' || TO_CHAR(L_DT_FIM));
        
          INSERT INTO OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
            (COD_EMPRESA, NUM_REGISTRO, DCR_PLANO, NUM_MATR, COD_PLANO)
            SELECT X.COD_EMPRS,
                   X.NUM_RGTRO_EMPRG,
                   X.DCR_PLANO,
                   Y.NUM_MATR_PARTF,
                   19
              FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB X
             INNER JOIN ATT.PARTICIPANTE_FSS Y ON Y.COD_EMPRS = X.COD_EMPRS
                                              AND Y.NUM_RGTRO_EMPRG =
                                                  TO_NUMBER(SUBSTR(X.NUM_RGTRO_EMPRG,
                                                                   1,
                                                                   LENGTH(X.NUM_RGTRO_EMPRG) - 2))
             WHERE X.COD_EMPRS = P_COD_EMPRESA
               AND X.DCR_PLANO = P_DCR_PLANO
             GROUP BY X.COD_EMPRS,
                      X.NUM_RGTRO_EMPRG,
                      X.DCR_PLANO,
                      Y.NUM_MATR_PARTF;
        
          --INICIO DAS CONSISTENCIAS DE DADOS
          IF P_DTA_MOV IS NULL THEN
            UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
               SET E.DTA_FIM = (SELECT MAX(DTA_FIM_EXTR)
                                  FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                                 WHERE COD_EMPRS = E.COD_EMPRESA
                                   AND DCR_PLANO = E.DCR_PLANO
                                   AND NUM_RGTRO_EMPRG = E.NUM_REGISTRO
                                   AND DTA_FIM_EXTR = L_DT_FIM)
             WHERE E.DTA_FIM IS NULL;
          
          ELSE
            UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
               SET E.DTA_FIM = P_DTA_MOV
             WHERE E.DTA_FIM IS NULL;
          
          END IF;
        
          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
             SET E.VLR_BENEF_INTE = (SELECT NVL(MAX(VLR_BENEF1_HTBNF), 0)
                                       FROM HIST_VALOR_BNF
                                      WHERE NUM_MATR_PARTF = NUM_MATR
                                        AND COD_NATBNF = 4
                                        AND TO_CHAR(DAT_INIVG_HTBNF, 'YYYYMM') =
                                            TO_CHAR(E.DTA_FIM, 'YYYYMM'))
           WHERE E.VLR_BENEF_INTE = 0;
          COMMIT;
        
          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB B
             SET B.VLR_DQ = 0,
                 
                 B.VLR_DR = (SELECT NVL(MAX(VLR_BENEF1_HTBNF), 0)
                               FROM HIST_VALOR_BNF
                              WHERE NUM_MATR_PARTF = NUM_MATR
                                AND COD_NATBNF = 4
                                AND TO_CHAR(DAT_INIVG_HTBNF, 'YYYYMM') =
                                    TO_CHAR(B.DTA_FIM, 'YYYYMM')),
                 
                 B.VLR_EI = ATT.FCESP_VLR_CTB_ASSIST(B.COD_PLANO,
                                                     B.VLR_BENEF_INTE),
                 
                 B.VLR_EG = 0,
                 
                 B.VLR_RES1 = (SELECT NVL(SUM(SCPF.VLR_SDANT_SDCTPR +
                                              SCPF.VLR_ENTMES_SDCTPR -
                                              SCPF.VLR_SAIMES_SDCTPR),
                                          0) AS VLR_RES1
                                 FROM ATT.SLD_CONTA_PARTIC_FSS    SCPF -- A
                                     ,
                                      ATT.PARTICIPANTE_FSS        PF -- P
                                     ,
                                      ATT.ADESAO_PLANO_PARTIC_FSS APPF -- B
                                     ,
                                      ATT.CONTA_FSS               CF -- C
                                WHERE 1 = 1
                                  AND SCPF.NUM_MATR_PARTF = PF.NUM_MATR_PARTF
                                  AND SCPF.NUM_CTFSS = CF.NUM_CTFSS
                                  AND SCPF.COD_UM = CF.COD_UMARMZ_CTFSS --
                                  AND PF.NUM_MATR_PARTF = APPF.NUM_MATR_PARTF
                                     --
                                  AND PF.NUM_MATR_PARTF = B.NUM_MATR
                                     --
                                  AND APPF.NUM_PLBNF IN (19)
                                  AND SCPF.NUM_CTFSS = 976
                                  AND SCPF.COD_UM = 248
                                  AND PF.COD_EMPRS IN (40, 60)
                                  AND SCPF.ANOMES_MOVIM_SDCTPR <=
                                      TO_NUMBER(TRUNC(TO_CHAR(L_DT_FIM,
                                                              'YYYYMM')))
                               
                               ),
                 
                 B.VLR_RES2 = (SELECT NVL(MAX(A.VLR_CDIAUM), 0) AS VLR_CDIAUM
                                 FROM COTACAO_DIA_UM A
                                WHERE A.COD_UM = 248
                                  AND A.DAT_CDIAUM = TO_DATE(TRUNC(L_DT_FIM))
                               
                               )
          
           WHERE B.VLR_DQ = 0;
        
          COMMIT;
        
          -- VLR_SLD_ADICIONAL
          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
             SET VLR_RES3 = ROUND(VLR_RES1 * VLR_RES2)
           WHERE VLR_RES1 > 0;
        
          -- VLR_BENEF_ADICIONAL
          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
             SET VLR_RES4 = VLR_RES3 / 130
           WHERE VLR_RES3 > 0;
          COMMIT;
        
        END IF;
      
        -- ELIMINA OS REGISTRO QUE PERTENCEM AO PLANO 19 COM A DESCRICAO --> (Plano CD 2 Eletropaulo/Plano CD Eletropaulo)
        DELETE FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB PT
         WHERE REGEXP_LIKE(PT.DCR_PLANO,
                           '(Plano CD 2 Eletropaulo|Plano CD Eletropaulo)');
        COMMIT;
      
        -- REGISTROS COM DTA_FIM RETROATIVO A 2019 ESTAO NULL PQ NAO FOI DADO CARGA NA TABELA ATT.FC_PRE_TBL_BASE_EXTRAT_CTB, PORTANTO, PRECISAM SER LIMPOS DA TABELA.
        DELETE FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
         WHERE DTA_FIM IS NULL;
        COMMIT;
      
        DBMS_OUTPUT.PUT_LINE('TEMPORARIA PREENCHIDA');
      
      END IF;
    END IF;
  END;

  --DBMS_OUTPUT.PUT_LINE('L_COUNT: ' || TO_CHAR(L_COUNT));
EXCEPTION

  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('CODIGO DO ERRO: ' || SQLCODE || ' MSG: ' ||SQLERRM);
    DBMS_OUTPUT.PUT_LINE('LINHA: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
  
END;
/
