CREATE OR REPLACE PROCEDURE OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA(P_COD_EMPRESA FC_PRE_TBL_BASE_EXTRAT_CTB.COD_EMPRS%TYPE,

                                                               P_DCR_PLANO   FC_PRE_TBL_BASE_EXTRAT_CTB.DCR_PLANO%TYPE,

                                                               P_DTA_MOV     FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE) IS

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------                                                              

-- SISTEMA     : AMADEUS CAPITALIZACAO

-- DESCRIÇÃO   : EM VIRTUDE DO SALDAMENTO DO PLANO PSAP/ELETROPAULO (PLANO 19), O EXTRATO PREVIDENCIARIO PRECISARA PASSAR POR ALTERACOES

-- ANALISTA    : ADRIANO LIMA

-- DATA CRIACAO: 23/11/2020

-- MANUTENCOES : PROJ-760/PSD-11865 - DATA: 23/11/2020 – ANALISTA: ADRIANO LIMA/RENATO DAVI

-- MANUTENCOES : PROJ-3677 - DATA: 02/02/2021 – ANALISTA: ADRIANO LIMA/RENATO DAVI - DESCRICAO: EXECUTAR A PROCEDURE PARA AJUSTES DO EXTRATO PREVIDENCIARIO:

--               A EXECUCAO DA PROC: PRE_PRC_EXTRATOCALCULA CONTEMPLA OS CAMPOS DA TABELA FC_PRE_TBL_BASE_EXTRAT_CTB: VLR_BENEF_BD_PROP, VLR_BENEF_BD_INTE, VLR_CTB_INT_BD, VLR_CTB_PROP_BD, VLR_SLD_ADICIONAL, VLR_BENEF_ADICIONAL, VLR_RENDA_ESTIM_PROP, VLR_RENDA_ESTIM_INT

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* L_COD_NATBNF ATT.HIST_VALOR_BNF.COD_NATBNF%TYPE :=4;

L_NUM_PLBNF  ATT.HIST_VALOR_BNF.NUM_PLBNF%TYPE  :=19;

L_VLR_BENEF1 ATT.HIST_VALOR_BNF.VLR_BENEF1_HTBNF%TYPE;*/

  

   CURSOR CUR_RENDA_ESTIM( P_C_COD_EMPRS FC_PRE_TBL_BASE_EXTRAT_CTB.COD_EMPRS%TYPE

                          ,P_C_DCR_PLANO FC_PRE_TBL_BASE_EXTRAT_CTB.DCR_PLANO%TYPE

                          ,P_C_DTA_MOV   FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE ) IS

        SELECT   NVL(SUM(VLR_BENEF_PSAP_PROP + VLR_BENEF_BD_PROP + VLR_BENEF_CV_PROP),0)  AS RENDA_ESTIM_PROP

                ,NVL(SUM(VLR_BENEF_PSAP_INTE + VLR_BENEF_BD_INTE + VLR_BENEF_CV_INTE),0)  AS RENDA_ESTIM_INT

                ,FPTB.DCR_PLANO

                ,FPTB.NUM_RGTRO_EMPRG

                ,FPTB.DTA_FIM_EXTR

                ,FPTB.COD_EMPRS

      FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB  FPTB  -- OFICIAL

       WHERE FPTB.COD_EMPRS       = P_C_COD_EMPRS

       AND   FPTB.DCR_PLANO       = P_C_DCR_PLANO

       AND   FPTB.DTA_FIM_EXTR    = P_C_DTA_MOV

      GROUP BY FPTB.RENDA_ESTIM_PROP

              ,FPTB.RENDA_ESTIM_INT

              ,FPTB.DCR_PLANO

              ,FPTB.NUM_RGTRO_EMPRG

              ,FPTB.DTA_FIM_EXTR

              ,FPTB.COD_EMPRS;

 

 

  -- CURSOR: VALOR DO BDS - MODULO SALDADO:     

/*  CURSOR CUR_BDS (  P_C_CODEMPRS  ATT.FC_PRE_TBL_BASE_EXTRAT_CTB.COD_EMPRS%TYPE

                   ,P_C_DCR_PLANO ATT.FC_PRE_TBL_BASE_EXTRAT_CTB.DCR_PLANO%TYPE

                   ,P_C_DTA_FIM   ATT.FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE)IS        

     SELECT  FPT.COD_EMPRS        AS COD_EMPRS

            ,FPT.NUM_RGTRO_EMPRG  AS NUM_RGTRO_EMPRG

            ,FPT.DCR_PLANO        AS DCR_PLANO

            ,PTT.NUM_MATR         AS NUM_MATR_PARTF

            ,FPT.DTA_FIM_EXTR     AS DTA_FIM_EXTR       

       FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB      FPT

           ,OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB  PTT                                 

         WHERE FPT.NUM_RGTRO_EMPRG  = PTT.NUM_REGISTRO

           AND FPT.COD_EMPRS        = PTT.COD_EMPRESA

           --AND PTT.NUM_MATR       = 37976

           AND FPT.COD_EMPRS        = P_C_CODEMPRS

           AND UPPER(FPT.DCR_PLANO) = UPPER(P_C_DCR_PLANO)

           AND FPT.DTA_FIM_EXTR     = P_C_DTA_FIM;

          

   -- FUNCTION: VALOR DO BDS - MODULO SALDADO:

    FUNCTION FUN_BDR( P_NUM_MATR ATT.HIST_VALOR_BNF.NUM_MATR_PARTF%TYPE

                     ,P_DTA_FIM  ATT.FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE)                    

           

       RETURN NUMBER IS

       R_VLR_BENEF1 VARCHAR2(100);            

             

    BEGIN

            

            SELECT NVL(MAX(VLR_BENEF1_HTBNF),0)VLR_BENEF1_HTBNF

               INTO R_VLR_BENEF1

               FROM  ATT.HIST_VALOR_BNF

             WHERE NUM_MATR_PARTF  = P_NUM_MATR

               AND COD_NATBNF      = L_COD_NATBNF

               AND NUM_PLBNF       = L_NUM_PLBNF          

               AND TO_CHAR(DAT_INIVG_HTBNF, 'YYYYMM') = TO_CHAR(TO_DATE(P_DTA_MOV),'YYYYMM');

                            

               

             IF (R_VLR_BENEF1 IS NOT NULL) THEN

                RETURN R_VLR_BENEF1;         

             END IF;

             

    END;*/

 

BEGIN

 

  BEGIN

    IF (P_DTA_MOV IS NOT NULL) THEN

          

        EXECUTE IMMEDIATE 'TRUNCATE TABLE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB';

 

        INSERT INTO OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB( COD_EMPRESA

                                                       ,NUM_REGISTRO

                                                       ,DCR_PLANO

                                                       ,NUM_MATR

                                                       ,COD_PLANO

                                                       ,DTA_FIM

                                                      )

          SELECT X.COD_EMPRS,

                 X.NUM_RGTRO_EMPRG,

                 X.DCR_PLANO,

                 Y.NUM_MATR_PARTF,

                 19,

                 P_DTA_MOV

            FROM      ATT.FC_PRE_TBL_BASE_EXTRAT_CTB X

           INNER JOIN ATT.PARTICIPANTE_FSS           Y  ON Y.COD_EMPRS       = X.COD_EMPRS

                                                       AND Y.NUM_RGTRO_EMPRG = TO_NUMBER(SUBSTR(X.NUM_RGTRO_EMPRG, 1, LENGTH(X.NUM_RGTRO_EMPRG) - 2))

           WHERE X.COD_EMPRS       = P_COD_EMPRESA

             AND X.DCR_PLANO       = P_DCR_PLANO

             --AND Y.NUM_MATR_PARTF IN (49849, 44345, 84336)

           GROUP BY X.COD_EMPRS,

                    X.NUM_RGTRO_EMPRG,

                    X.DCR_PLANO,

                    Y.NUM_MATR_PARTF;

        BEGIN

              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB E

                 SET E.VLR_BENEF_INTE = ( SELECT NVL(MAX(H.VLR_BENEF1_HTBNF), 0)

                                            FROM HIST_VALOR_BNF H

                                           WHERE H.NUM_MATR_PARTF = E.NUM_MATR

                                             AND H.COD_NATBNF = 4

                                             AND TO_CHAR(H.DAT_INIVG_HTBNF, 'YYYYMM') = TO_CHAR(P_DTA_MOV, 'YYYYMM')

                                        )

               WHERE E.VLR_BENEF_INTE = 0;

              

              COMMIT;

 

              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB B

                 SET B.VLR_DQ = 0,

                     B.VLR_DR = (SELECT NVL(MAX(H.VLR_BENEF1_HTBNF), 0) VLR_BENEF1_HTBNF

                                     FROM HIST_VALOR_BNF H

                                    WHERE H.NUM_MATR_PARTF = B.NUM_MATR

                                      AND H.COD_NATBNF = 4

                                      AND H.NUM_PLBNF  = 19                                      

                                      AND TO_CHAR(DAT_INIVG_HTBNF, 'YYYYMM') = TO_CHAR(TO_DATE(P_DTA_MOV),'YYYYMM')

                                 ),

                     B.VLR_EI = ATT.FCESP_VLR_CTB_ASSIST(B.COD_PLANO, B.VLR_BENEF_INTE),

                     B.VLR_EG = 0,

                     B.VLR_RES1 = (SELECT NVL(SUM(SCPF.VLR_SDANT_SDCTPR + SCPF.VLR_ENTMES_SDCTPR - SCPF.VLR_SAIMES_SDCTPR), 0) AS VLR_RES1

                                     FROM ATT.SLD_CONTA_PARTIC_FSS    SCPF -- A

                                         ,ATT.PARTICIPANTE_FSS        PF   -- P

                                         ,ATT.ADESAO_PLANO_PARTIC_FSS APPF -- B

                                         ,ATT.CONTA_FSS               CF   -- C

                                    WHERE 1 = 1

                                      AND SCPF.NUM_MATR_PARTF = PF.NUM_MATR_PARTF

                                      AND SCPF.COD_UM         = CF.COD_UMARMZ_CTFSS --

                                      AND SCPF.NUM_CTFSS      = CF.NUM_CTFSS

                                      AND PF.NUM_MATR_PARTF   = APPF.NUM_MATR_PARTF

                                      --

                                      AND PF.NUM_MATR_PARTF = B.NUM_MATR

                                      AND APPF.NUM_PLBNF = 19

                                      AND SCPF.NUM_CTFSS = 976

                                      AND SCPF.COD_UM    = 248

                                      AND PF.COD_EMPRS IN (40, 60)

                                   ),

                                  

                     B.VLR_RES2 = ( SELECT NVL(MAX(A.VLR_CDIAUM), 0) AS VLR_CDIAUM

                                      FROM COTACAO_DIA_UM A

                                     WHERE A.COD_UM = 248

                                     AND   A.DAT_CDIAUM = P_DTA_MOV

 

                                   )

               WHERE B.VLR_DQ = 0;

 

              COMMIT;

 

              -- VLR_SLD_ADICIONAL

              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB

                 SET VLR_RES3 = ROUND(VLR_RES1 * VLR_RES2,2)

               WHERE VLR_RES1 > 0;

              

              COMMIT;

 

              -- VLR_BENEF_ADICIONAL

              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB

                 SET VLR_RES4 = ROUND(VLR_RES3 / 130,2)

               WHERE VLR_RES3 > 0;

              

              COMMIT;

             

              FOR RG IN CUR_RENDA_ESTIM(  P_COD_EMPRESA

                                         ,P_DCR_PLANO 

                                         ,P_DTA_MOV )

              LOOP

                 UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB

                    SET VLR_DU = RG.RENDA_ESTIM_PROP,

                        VLR_DV = RG.RENDA_ESTIM_INT

                  WHERE DTA_FIM      = RG.DTA_FIM_EXTR -- P_DTA_MOV

                    AND COD_EMPRESA  = RG.COD_EMPRS    -- P_COD_EMPRESA

                    AND NUM_REGISTRO = RG.NUM_RGTRO_EMPRG;             

              END LOOP;

             COMMIT;

              --

              --

  /*            FOR RG_CUR_BDS IN CUR_BDS ( P_COD_EMPRESA

                                         ,P_DCR_PLANO

                                         ,P_DTA_MOV)

             

              LOOP

             

              -- FUNCTION: VALOR DO BDS - MODULO SALDADO:

              L_VLR_BENEF1 := FUN_BDR(RG_CUR_BDS.NUM_MATR_PARTF, RG_CUR_BDS.DTA_FIM_EXTR);

             

                            

              UPDATE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB T

                 SET T.VLR_DR      = L_VLR_BENEF1

                WHERE COD_EMPRESA  = RG_CUR_BDS.COD_EMPRS

                  AND NUM_REGISTRO = RG_CUR_BDS.NUM_RGTRO_EMPRG

                  AND DTA_FIM      = RG_CUR_BDS.DTA_FIM_EXTR;                   

                 

              END LOOP;*/

 

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

        --DBMS_OUTPUT.PUT_LINE('TEMPORARIA PREENCHIDA');

       

    ELSE      

        DBMS_OUTPUT.PUT_LINE('DEVE SER INFORMADO A DATA NA ASSINATURA DA PROCEDURE: '||'P_DTA_MOV');

    END IF;

    --END IF;

  END;

EXCEPTION

  WHEN OTHERS THEN

    DBMS_OUTPUT.PUT_LINE('CODIGO DO ERRO: ' || SQLCODE || ' MSG: ' ||SQLERRM);

    DBMS_OUTPUT.PUT_LINE('LINHA: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

 

END;