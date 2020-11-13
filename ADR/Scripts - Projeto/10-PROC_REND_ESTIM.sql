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
  Autor: Adriano Lima
  Data: 11/11/2020
  Calcula os campos: RENDA_ESTIM_PROP e RENDA_ESTIM_INT
*/ 

CREATE OR REPLACE PROCEDURE OWN_FUNCESP.PROC_REND_ESTIM (P_COD_EMPRESA FC_PRE_TBL_BASE_EXTRAT_CTB.COD_EMPRS%TYPE ,
                                                         P_DCR_PLANO   FC_PRE_TBL_BASE_EXTRAT_CTB.DCR_PLANO%TYPE,
                                                         P_DTA_MOV     FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE DEFAULT NULL)AS

BEGIN

 DECLARE
 
   --VARIAVEL DECLARADA PARA GUARDAR A MAIOR DATA DA PUBLICACAO DO EXTRATO.
     L_DT_FIM  ATT.FC_PRE_TBL_BASE_EXTRAT_CTB.DTA_FIM_EXTR%TYPE;
	 
	 

   -- CURSOR RENDA_ESTIM_PROP --> DU = DO + DQ + DS
   CURSOR CUR_RENDA_ESTIM IS


        SELECT   NVL(SUM(VLR_BENEF_PSAP_PROP + VLR_BENEF_BD_PROP + VLR_BENEF_CV_PROP),0)  AS RENDA_ESTIM_PROP
                ,NVL(SUM(VLR_BENEF_PSAP_INTE + VLR_BENEF_BD_INTE + VLR_BENEF_CV_INTE),0)  AS RENDA_ESTIM_INT
                ,FPTB.DCR_PLANO
                ,FPTB.NUM_RGTRO_EMPRG
                ,FPTB.DTA_FIM_EXTR
      FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB  FPTB  -- OFICIAL
       WHERE FPTB.COD_EMPRS       = P_COD_EMPRESA
       AND   FPTB.DCR_PLANO       = P_DCR_PLANO
       AND   FPTB.DTA_FIM_EXTR    = P_DTA_MOV
       --AND   FPTB.NUM_RGTRO_EMPRG = '0002014424-9'
       GROUP BY FPTB.RENDA_ESTIM_PROP, FPTB.RENDA_ESTIM_INT, FPTB.DCR_PLANO, FPTB.NUM_RGTRO_EMPRG, FPTB.DTA_FIM_EXTR;

   V_CUR_RENDA_ESTIM CUR_RENDA_ESTIM%ROWTYPE;
   
   
    -- CURSOR RENDA_ESTIM_INT --> DV = DP + DR + DT
    CURSOR CUR_RENDA_ESTIM_DAT IS


      SELECT   NVL(SUM(VLR_BENEF_PSAP_PROP + VLR_BENEF_BD_PROP + VLR_BENEF_CV_PROP),0)  AS RENDA_ESTIM_PROP
              ,NVL(SUM(VLR_BENEF_PSAP_INTE + VLR_BENEF_BD_INTE + VLR_BENEF_CV_INTE),0)  AS RENDA_ESTIM_INT
              ,FPTB.DCR_PLANO
              ,FPTB.NUM_RGTRO_EMPRG
              ,FPTB.DTA_FIM_EXTR
    FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB  FPTB  -- OFICIAL
     WHERE FPTB.COD_EMPRS       = P_COD_EMPRESA
     AND   FPTB.DCR_PLANO       = P_DCR_PLANO
     AND   FPTB.DTA_FIM_EXTR    = L_DT_FIM
     --AND   FPTB.NUM_RGTRO_EMPRG = '0002014424-9'
     GROUP BY FPTB.RENDA_ESTIM_PROP, FPTB.RENDA_ESTIM_INT, FPTB.DCR_PLANO, FPTB.NUM_RGTRO_EMPRG, FPTB.DTA_FIM_EXTR;

   V_CUR_RENDA_ESTIM_DAT CUR_RENDA_ESTIM_DAT%ROWTYPE;


--
--
    BEGIN
    
          IF ( P_DTA_MOV IS NOT NULL ) THEN
          
           
                         OPEN CUR_RENDA_ESTIM;
                           LOOP
                              FETCH CUR_RENDA_ESTIM INTO V_CUR_RENDA_ESTIM;
                              EXIT WHEN CUR_RENDA_ESTIM%NOTFOUND;

                               UPDATE ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                                   SET RENDA_ESTIM_PROP    = V_CUR_RENDA_ESTIM.RENDA_ESTIM_PROP,
                                       RENDA_ESTIM_INT     = V_CUR_RENDA_ESTIM.RENDA_ESTIM_INT
                                    WHERE DTA_FIM_EXTR     =  P_DTA_MOV
                                       AND COD_EMPRS       =  P_COD_EMPRESA
                                       AND NUM_RGTRO_EMPRG =  V_CUR_RENDA_ESTIM.NUM_RGTRO_EMPRG;

                           END LOOP;
                         CLOSE CUR_RENDA_ESTIM;
                         COMMIT;
                                               
                               
          ELSE


          SELECT MAX(TO_DATE(FP.DTA_FIM_EXTR,'DD/MM/RRRR'))INTO L_DT_FIM FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP
          WHERE FP.COD_EMPRS = P_COD_EMPRESA AND UPPER(FP.DCR_PLANO) = UPPER(P_DCR_PLANO);

                         OPEN CUR_RENDA_ESTIM_DAT;
                           LOOP
                              FETCH CUR_RENDA_ESTIM_DAT INTO V_CUR_RENDA_ESTIM_DAT;
                              EXIT WHEN CUR_RENDA_ESTIM_DAT%NOTFOUND;



                               UPDATE ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
                                   SET RENDA_ESTIM_PROP    = V_CUR_RENDA_ESTIM_DAT.RENDA_ESTIM_PROP,
                                       RENDA_ESTIM_INT     = V_CUR_RENDA_ESTIM_DAT.RENDA_ESTIM_INT
                                    WHERE DTA_FIM_EXTR     = L_DT_FIM
                                       AND COD_EMPRS       =  P_COD_EMPRESA
                                       AND NUM_RGTRO_EMPRG =  V_CUR_RENDA_ESTIM_DAT.NUM_RGTRO_EMPRG;

                           END LOOP;
                         CLOSE CUR_RENDA_ESTIM_DAT;
                         COMMIT;
                         DBMS_OUTPUT.PUT_LINE('L_DT_FIM: ' || TO_CHAR(L_DT_FIM));              
                         

          END IF;
    END;
        
        
               EXCEPTION
                  WHEN OTHERS THEN
                         DBMS_OUTPUT.PUT_LINE('CODIGO DO ERRO: '||SQLCODE||' MSG: '||SQLERRM);
                         DBMS_OUTPUT.PUT_LINE('LINHA: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);      

END;
