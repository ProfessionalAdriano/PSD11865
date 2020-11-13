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
  Autor: Adriano
  Data: 04/11/2020
*/ 

CREATE OR REPLACE PROCEDURE OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA(P_COD_EMPRESA FC_PRE_TBL_BASE_EXTRAT_CTB.COD_EMPRS%TYPE ,
                                                               P_DCR_PLANO   FC_PRE_TBL_BASE_EXTRAT_CTB.DCR_PLANO%TYPE,
                                                               P_DTA_MOV     FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE )IS

 -- VARIAVEL DECLARADA PARA GUARDAR A MAIOR DATA DA PUBLICACAO DO EXTRATO.
 L_DT_FIM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE;

BEGIN


    BEGIN
     IF ( P_DTA_MOV IS NOT NULL ) THEN

        IF P_COD_EMPRESA = P_COD_EMPRESA AND UPPER(P_DCR_PLANO) = UPPER(P_DCR_PLANO) THEN

        SELECT MAX(TO_DATE(FP.DTA_FIM_EXTR,'DD/MM/RRRR'))INTO L_DT_FIM FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP
        WHERE FP.COD_EMPRS = P_COD_EMPRESA AND UPPER(FP.DCR_PLANO) = UPPER(P_DCR_PLANO);


            INSERT INTO OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB(COD_EMPRESA, NUM_REGISTRO, DCR_PLANO, NUM_MATR,COD_PLANO)
              SELECT X.COD_EMPRS, X.NUM_RGTRO_EMPRG, X.DCR_PLANO, Y.NUM_MATR_PARTF,19
                FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB X
               INNER JOIN ATT.PARTICIPANTE_FSS Y ON Y.COD_EMPRS = X.COD_EMPRS
                                                AND Y.NUM_RGTRO_EMPRG =
                                                    TO_NUMBER(SUBSTR(X.NUM_RGTRO_EMPRG,1,LENGTH(X.NUM_RGTRO_EMPRG) - 2))
               WHERE X.COD_EMPRS = P_COD_EMPRESA
                 AND X.DCR_PLANO = P_DCR_PLANO
               GROUP BY X.COD_EMPRS,X.NUM_RGTRO_EMPRG,X.DCR_PLANO,Y.NUM_MATR_PARTF;


            --INICIO DAS CONSISTENCIAS DE DADOS
            IF P_DTA_MOV IS NULL THEN
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
                   SET E.DTA_FIM = P_DTA_MOV
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

					/* Esta sendo tratado na PROC --> OWN_FUNCESP.PROC_REND_ESTIM

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
					*/

                   B.VLR_EI = ATT.FCESP_VLR_CTB_ASSIST(B.COD_PLANO, B.VLR_BENEF_INTE),

                   B.VLR_EG = 0,

                   B.VLR_RES1 = (SELECT NVL(SUM(SCPF.VLR_SDANT_SDCTPR + SCPF.VLR_ENTMES_SDCTPR - SCPF.VLR_SAIMES_SDCTPR),0) AS VLR_RES1
                                    FROM  ATT.SLD_CONTA_PARTIC_FSS    SCPF -- A
                                         ,ATT.PARTICIPANTE_FSS        PF   -- P
                                         ,ATT.ADESAO_PLANO_PARTIC_FSS APPF -- B
                                         ,ATT.CONTA_FSS               CF   -- C
                                      WHERE  1=1
                                     AND SCPF.NUM_MATR_PARTF  = PF.NUM_MATR_PARTF
                                     AND SCPF.COD_UM       = CF.COD_UMARMZ_CTFSS --
                                     AND SCPF.NUM_CTFSS       = CF.NUM_CTFSS
                                     AND PF.NUM_MATR_PARTF    = APPF.NUM_MATR_PARTF
                                     --
                                     AND PF.NUM_MATR_PARTF = B.NUM_MATR
                                     --
                                     AND APPF.NUM_PLBNF  IN (19)
                                     AND SCPF.NUM_CTFSS  = 976
                                     AND SCPF.COD_UM     = 248
                                     AND PF.COD_EMPRS  IN (40,60)
                                     AND SCPF.ANOMES_MOVIM_SDCTPR <= TO_NUMBER(TRUNC(TO_CHAR(P_DTA_MOV,'YYYYMM')))

                                 ),


                   B.VLR_RES2 = (SELECT NVL(MAX(A.VLR_CDIAUM),0) AS VLR_CDIAUM
                                    FROM COTACAO_DIA_UM A
                                    WHERE A.COD_UM = 248
                                     AND A.DAT_CDIAUM = (SELECT MAX(DAT_CDIAUM)
                                                          FROM COTACAO_DIA_UM
                                                           WHERE COD_UM = A.COD_UM
                                                           AND DAT_CDIAUM = TO_DATE(TRUNC(P_DTA_MOV))
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


      ELSE

        IF P_COD_EMPRESA = P_COD_EMPRESA AND UPPER(P_DCR_PLANO) = UPPER(P_DCR_PLANO) THEN

          SELECT MAX(TO_DATE(FP.DTA_FIM_EXTR,'DD/MM/RRRR'))INTO L_DT_FIM FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP
          WHERE FP.COD_EMPRS = P_COD_EMPRESA AND UPPER(FP.DCR_PLANO) = UPPER(P_DCR_PLANO);


          DBMS_OUTPUT.PUT_LINE('L_DT_FIM: ' || TO_CHAR(L_DT_FIM));

            INSERT INTO OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB(COD_EMPRESA, NUM_REGISTRO, DCR_PLANO, NUM_MATR,COD_PLANO)
              SELECT X.COD_EMPRS, X.NUM_RGTRO_EMPRG, X.DCR_PLANO, Y.NUM_MATR_PARTF,19
                FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB X
               INNER JOIN ATT.PARTICIPANTE_FSS Y ON Y.COD_EMPRS = X.COD_EMPRS
                                                AND Y.NUM_RGTRO_EMPRG =
                                                    TO_NUMBER(SUBSTR(X.NUM_RGTRO_EMPRG,1,LENGTH(X.NUM_RGTRO_EMPRG) - 2))
               WHERE X.COD_EMPRS = P_COD_EMPRESA
                 AND X.DCR_PLANO = P_DCR_PLANO
               GROUP BY X.COD_EMPRS,X.NUM_RGTRO_EMPRG,X.DCR_PLANO,Y.NUM_MATR_PARTF;


            --INICIO DAS CONSISTENCIAS DE DADOS
            IF P_DTA_MOV IS NULL THEN
                UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
                   SET E.DTA_FIM = (SELECT MAX(DTA_FIM_EXTR)
                                      FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                                     WHERE COD_EMPRS = E.COD_EMPRESA
                                       AND DCR_PLANO = E.DCR_PLANO
                                       AND NUM_RGTRO_EMPRG = E.NUM_REGISTRO
                                       AND DTA_FIM_EXTR    = L_DT_FIM
                                    )
                 WHERE E.DTA_FIM IS NULL;

            ELSE
                 UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E
                   SET E.DTA_FIM = P_DTA_MOV
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
					/* Esta sendo tratado na PROC --> OWN_FUNCESP.PROC_REND_ESTIM

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
					*/

                   B.VLR_EI = ATT.FCESP_VLR_CTB_ASSIST(B.COD_PLANO, B.VLR_BENEF_INTE),

                   B.VLR_EG = 0,


                   B.VLR_RES1 = (SELECT NVL(SUM(SCPF.VLR_SDANT_SDCTPR + SCPF.VLR_ENTMES_SDCTPR - SCPF.VLR_SAIMES_SDCTPR),0) AS VLR_RES1
                                    FROM  ATT.SLD_CONTA_PARTIC_FSS    SCPF -- A
                                         ,ATT.PARTICIPANTE_FSS        PF   -- P
                                         ,ATT.ADESAO_PLANO_PARTIC_FSS APPF -- B
                                         ,ATT.CONTA_FSS               CF   -- C
                                      WHERE  1=1
                                     AND SCPF.NUM_MATR_PARTF  = PF.NUM_MATR_PARTF
                                     AND SCPF.NUM_CTFSS       = CF.NUM_CTFSS
                                     AND SCPF.COD_UM       = CF.COD_UMARMZ_CTFSS --
                                     AND PF.NUM_MATR_PARTF    = APPF.NUM_MATR_PARTF
                                     --
                                     AND PF.NUM_MATR_PARTF = B.NUM_MATR
                                     --
                                     AND APPF.NUM_PLBNF  IN (19)
                                     AND SCPF.NUM_CTFSS  = 976
                                     AND SCPF.COD_UM     = 248
                                     AND PF.COD_EMPRS  IN (40,60)
                                     AND SCPF.ANOMES_MOVIM_SDCTPR <= TO_NUMBER(TRUNC(TO_CHAR(L_DT_FIM,'YYYYMM')))

                                 ),


                   B.VLR_RES2 = (SELECT NVL(MAX(A.VLR_CDIAUM),0) AS VLR_CDIAUM
                                    FROM COTACAO_DIA_UM A
                                    WHERE A.COD_UM = 248
                                     AND A.DAT_CDIAUM = TO_DATE(TRUNC(L_DT_FIM))

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

          -- REGISTROS COM DTA_FIM RETROATIVO A 2019 ESTAO NULL PQ NAO FOI DADO CARGA NA TABELA ATT.FC_PRE_TBL_BASE_EXTRAT_CTB, PORTANTO, PRECISAM SER LIMPOS DA TABELA.
          DELETE FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB WHERE DTA_FIM IS NULL;
           COMMIT;


          DBMS_OUTPUT.PUT_LINE('TEMPORARIA PREENCHIDA');

        END IF;
    END;

    EXCEPTION

    WHEN OTHERS THEN
           DBMS_OUTPUT.PUT_LINE('CODIGO DO ERRO: '||SQLCODE||' MSG: '||SQLERRM);
           DBMS_OUTPUT.PUT_LINE('LINHA: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);


END;
