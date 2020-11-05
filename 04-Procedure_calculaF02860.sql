CREATE OR REPLACE PROCEDURE OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA_F02860(COD_EMPRESA    NUMBER,
                                                                      DCR_PLANO      VARCHAR2,
                                                                      DTA_MOV        DATE
                                                                      )
IS

BEGIN

  IF COD_EMPRESA=40 AND UPPER(DCR_PLANO)= 'PSAP/ELETROPAULO' THEN

      INSERT INTO OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB(COD_EMPRESA, NUM_REGISTRO, DCR_PLANO, NUM_MATR,COD_PLANO)
        SELECT X.COD_EMPRS, X.NUM_RGTRO_EMPRG, X.DCR_PLANO, Y.NUM_MATR_PARTF,19
          FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB X
         INNER JOIN ATT.PARTICIPANTE_FSS Y ON Y.COD_EMPRS = X.COD_EMPRS
                                          AND Y.NUM_RGTRO_EMPRG =
                                              TO_NUMBER(SUBSTR(X.NUM_RGTRO_EMPRG,1,LENGTH(X.NUM_RGTRO_EMPRG) - 2))
         WHERE X.COD_EMPRS = COD_EMPRESA
           AND UPPER(X.DCR_PLANO) = UPPER(DCR_PLANO)
         GROUP BY X.COD_EMPRS,X.NUM_RGTRO_EMPRG,X.DCR_PLANO,Y.NUM_MATR_PARTF;


      --INICIO DAS CONSISTENCIAS DE DADOS
      IF DTA_MOV IS NULL THEN
          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
             SET E.DTA_FIM = (SELECT MAX(DTA_FIM_EXTR)
                                FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                               WHERE COD_EMPRS = E.COD_EMPRESA
                                 AND UPPER(DCR_PLANO) = UPPER(E.DCR_PLANO)
                                 AND NUM_RGTRO_EMPRG = E.NUM_REGISTRO
                              )
           WHERE E.DTA_FIM IS NULL;

      ELSE
           UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
             SET E.DTA_FIM = DTA_MOV
           WHERE E.DTA_FIM IS NULL;

      END IF;

      UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
       SET E.VLR_BENEF_INTE = (SELECT NVL(MAX(VLR_BENEF1_HTBNF),0)
                               FROM HIST_VALOR_BNF
                               WHERE NUM_MATR_PARTF = NUM_MATR
                                AND COD_NATBNF = 4
                                AND TO_CHAR(DAT_INIVG_HTBNF,'YYYYMM') = TO_CHAR(E.DTA_FIM,'YYYYMM')
                              )
     WHERE E.VLR_BENEF_INTE = 0;
     COMMIT;
                              
      UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB B
         SET B.VLR_DQ = 0,

             B.VLR_DR = (SELECT NVL(MAX(VLR_BENEF1_HTBNF),0)
                               FROM HIST_VALOR_BNF
                               WHERE NUM_MATR_PARTF = NUM_MATR
                                AND COD_NATBNF = 4
                                AND TO_CHAR(DAT_INIVG_HTBNF,'YYYYMM') = TO_CHAR(B.DTA_FIM,'YYYYMM')
                        ),

             B.VLR_DU = (SELECT NVL(SUM(VLR_BENEF_PSAP_PROP + VLR_BENEF_BD_PROP +
                                VLR_BENEF_CV_PROP),0)
                         FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                        WHERE COD_EMPRS = B.COD_EMPRESA
                          AND NUM_RGTRO_EMPRG = B.NUM_REGISTRO
                          AND UPPER(DCR_PLANO) = UPPER(B.DCR_PLANO)
                          AND DTA_FIM_EXTR = B.DTA_FIM

                         ),

             B.VLR_DV = (SELECT NVL(SUM(VLR_BENEF_PSAP_INTE + VLR_BENEF_BD_INTE +
                                VLR_BENEF_CV_INTE),0)
                           FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                          WHERE COD_EMPRS = B.COD_EMPRESA
                            AND NUM_RGTRO_EMPRG = B.NUM_REGISTRO
                            AND UPPER(DCR_PLANO) = UPPER(B.DCR_PLANO)
                            AND DTA_FIM_EXTR = B.DTA_FIM
                        ),

             B.VLR_EI = ATT.FCESP_VLR_CTB_ASSIST(B.COD_PLANO, B.VLR_BENEF_INTE),

             B.VLR_EG = 0,

             B.VLR_RES1 = ( SELECT NVL(SUM(A.VLR_SDANT_SDCTPR + A.VLR_CRMSAN_SDCTPR + A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR),0)
                              FROM SLD_CONTA_PARTIC_FSS A
                                  ,ATT.PARTICIPANTE_FSS P
                                  ,ATT.CONTA_FSS        C
                              WHERE  1=1   
                             AND A.NUM_MATR_PARTF  = P.NUM_MATR_PARTF
                             AND A.NUM_CTFSS       = C.NUM_CTFSS
                             AND A.NUM_MATR_PARTF  = B.NUM_MATR                            
                             AND P.COD_EMPRS       = COD_PLANO 
                             AND A.NUM_CTFSS       = 976
                             --AND A.COD_UM          = 248 -- AGUARDAR O FEEDBACK DO USUARIO
                             AND C.NUM_PLBNF_CTFSS = 19
                             AND A.ANOMES_MOVIM_SDCTPR =(SELECT MAX(D.ANOMES_MOVIM_SDCTPR)
                                                           FROM SLD_CONTA_PARTIC_FSS D
                                                           WHERE 1=1
                                                          AND D.NUM_MATR_PARTF = A.NUM_MATR_PARTF
                                                          AND D.NUM_CTFSS      = A.NUM_CTFSS
                                                          --AND D.COD_UM         = A.COD_UM -- AGUARDAR O FEEDBACK DO USUARIO
                                                          AND D.ANOMES_MOVIM_SDCTPR <= TO_NUMBER(SYSDATE,'YYYYMM')
                                
                                                         )
                                                           
                         ),

             B.VLR_RES2 = (SELECT NVL(MAX(A.VLR_CDIAUM),0)
                           FROM COTACAO_DIA_UM A
                          WHERE A.COD_UM = 26
                            AND A.DAT_CDIAUM = (SELECT MAX(DAT_CDIAUM)
                                                 FROM COTACAO_DIA_UM
                                                WHERE COD_UM = A.COD_UM
                                                  AND DAT_CDIAUM <= SYSDATE
                                               )
                                                                              )

       WHERE B.VLR_DQ = 0;

      COMMIT;

      UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
         SET VLR_RES3 = ROUND(VLR_RES1 * VLR_RES2)
      WHERE VLR_RES1>0;

      UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
         SET VLR_RES4 = VLR_RES3/130
      WHERE VLR_RES3>0;
      COMMIT;

  END IF;

  DBMS_OUTPUT.PUT_LINE('TEMPORARIA PREENCHIDA');


END;



