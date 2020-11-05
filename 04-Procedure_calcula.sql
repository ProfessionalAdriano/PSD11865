SET ECHO ON
SET TIME ON
SET TIMING ON
SET SQLBL ON
SET SERVEROUTPUT ON SIZE 1000000
SHOW USER
SELECT * FROM GLOBAL_NAME;
SELECT INSTANCE_NAME, HOST_NAME FROM V$INSTANCE;
SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') DATA FROM DUAL;


/*Projeto criado para a PSD-11865 - Ajustes no extrato previdenciário para atender o saldamento PSAP
  Autor: Adriano/Sarah/Renato
  Data: 04/11/2020
*/ 

CREATE OR REPLACE PROCEDURE OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA(COD_EMPRESA NUMBER,
                                                               DCR_PLANO   VARCHAR2,
                                                               DTA_MOV     DATE)IS

BEGIN

  DECLARE

     -- VARIAVEL DECLARADA PARA GUARDAR A MAIOR DATA DA PUBLICACAO DO EXTRATO.
     VDATA_FIM VARCHAR2(200);

    BEGIN

      SELECT MAX(FP.DTA_FIM_EXTR)INTO VDATA_FIM FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP WHERE FP.COD_EMPRS = COD_EMPRESA AND FP.DCR_PLANO = DCR_PLANO;
      IF COD_EMPRESA = 40 AND UPPER(DCR_PLANO) = 'PSAP/ELETROPAULO' THEN


          INSERT INTO OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB(COD_EMPRESA, NUM_REGISTRO, DCR_PLANO, NUM_MATR,COD_PLANO)
            SELECT X.COD_EMPRS, X.NUM_RGTRO_EMPRG, X.DCR_PLANO, Y.NUM_MATR_PARTF,19
              FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB X
             INNER JOIN ATT.PARTICIPANTE_FSS Y ON Y.COD_EMPRS = X.COD_EMPRS
                                              AND Y.NUM_RGTRO_EMPRG =
                                                  TO_NUMBER(SUBSTR(X.NUM_RGTRO_EMPRG,1,LENGTH(X.NUM_RGTRO_EMPRG) - 2))
             WHERE X.COD_EMPRS = COD_EMPRESA
               AND X.DCR_PLANO = DCR_PLANO
             GROUP BY X.COD_EMPRS,X.NUM_RGTRO_EMPRG,X.DCR_PLANO,Y.NUM_MATR_PARTF;


          --INICIO DAS CONSISTENCIAS DE DADOS
          IF DTA_MOV IS NULL THEN
              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
                 SET E.DTA_FIM = (SELECT MAX(DTA_FIM_EXTR)
                                    FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                                   WHERE COD_EMPRS = E.COD_EMPRESA
                                     AND DCR_PLANO = E.DCR_PLANO
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

          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB B SET B.VLR_DQ = 0,

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
                              AND DCR_PLANO = B.DCR_PLANO
                              AND DTA_FIM_EXTR = B.DTA_FIM

                             ),

                 B.VLR_DV = (SELECT NVL(SUM(VLR_BENEF_PSAP_INTE + VLR_BENEF_BD_INTE +
                                    VLR_BENEF_CV_INTE),0)
                               FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                              WHERE COD_EMPRS = B.COD_EMPRESA
                                AND NUM_RGTRO_EMPRG = B.NUM_REGISTRO
                                AND DCR_PLANO = B.DCR_PLANO
                                AND DTA_FIM_EXTR = B.DTA_FIM
                            ),

                 B.VLR_EI = ATT.FCESP_VLR_CTB_ASSIST(B.COD_PLANO, B.VLR_BENEF_INTE),

                 B.VLR_EG = 0,

                 B.VLR_RES1 = (SELECT NVL(SUM(A.VLR_SDANT_SDCTPR + A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR),0) AS VLR_RES1
                                 FROM SLD_CONTA_PARTIC_FSS A
                                      ,ATT.PARTICIPANTE_FSS P
                                      ,ATT.CONTA_FSS        C
                                  WHERE  1=1
                                   AND A.NUM_MATR_PARTF  = P.NUM_MATR_PARTF
                                   AND A.NUM_CTFSS       = C.NUM_CTFSS
                                   AND A.NUM_MATR_PARTF  = B.NUM_MATR
                                   AND A.NUM_CTFSS       = 976
                                   AND A.COD_UM          = 248
                                   AND P.COD_EMPRS       IN (40,60)
                                   AND C.NUM_PLBNF_CTFSS = COD_PLANO -- 19
                               ),


                 B.VLR_RES2 = (SELECT NVL(MAX(A.VLR_CDIAUM),0) AS VLR_CDIAUM
                                  FROM COTACAO_DIA_UM A
                                  WHERE A.COD_UM = 248
                                   AND A.DAT_CDIAUM = (SELECT MAX(DAT_CDIAUM)
                                                        FROM COTACAO_DIA_UM
                                                         WHERE COD_UM = A.COD_UM
                                                         AND DAT_CDIAUM = TO_DATE(VDATA_FIM,'DD/MM/YYYY')
                                                       )
                               )


           WHERE B.VLR_DQ = 0;

          COMMIT;

          -- VLR_SLD_ADICIONAL
          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
             SET VLR_RES3 = ROUND(VLR_RES1 * VLR_RES2)
          WHERE VLR_RES1>0;

          -- VLR_BENEF_ADICIONAL
          UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
             SET VLR_RES4 = VLR_RES3/130
          WHERE VLR_RES3>0;
          COMMIT;

      END IF;
      
      -- ELIMINA OS REGISTRO QUE PERTENCEM AO PLANO 19 COM A DESCRICAO --> (Plano CD 2 Eletropaulo/Plano CD Eletropaulo)
      DELETE FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB PT WHERE REGEXP_LIKE (PT.DCR_PLANO,'(Plano CD 2 Eletropaulo|Plano CD Eletropaulo)');
      COMMIT;
      DBMS_OUTPUT.PUT_LINE('TEMPORARIA PREENCHIDA');


    END;
END;


