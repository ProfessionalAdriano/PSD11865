-- VLR_RES1  = VLR_SLD_ADICIONAL
-- Procurar o Samuel sandes milani  
SELECT A.VLR_SDANT_SDCTPR, A.VLR_CRMSAN_SDCTPR, A.VLR_ENTMES_SDCTPR, A.VLR_SAIMES_SDCTPR
  FROM SLD_CONTA_PARTIC_FSS A, 
       CONTA_FSS C  -- ERRADO, NAO DEVERIA FAZER O RELACIONAMENTO COM A CONTA, PQ NAO ATENDE AOS REQUISITOS (NUM_CTFSS = 976/A.COD_UM    = 248)
  WHERE  1=1
   --AND A.NUM_MATR_PARTF = 43446 --B.NUM_MATR
   AND A.NUM_CTFSS = C.NUM_CTFSS
   --AND A.NUM_CTFSS = 976
   --AND A.COD_UM    = 248
   AND C.NUM_PLBNF_CTFSS = 40 --COD_PLANO
   AND A.ANOMES_MOVIM_SDCTPR =(SELECT MAX(D.ANOMES_MOVIM_SDCTPR)
                                 FROM SLD_CONTA_PARTIC_FSS D
                                 WHERE 1=1
                                   AND D.NUM_MATR_PARTF = 43446 --A.NUM_MATR_PARTF
                                   AND D.NUM_CTFSS = 976  --A.NUM_CTFSS
                                   AND D.COD_UM    = 248   -- Outro erro, não estava chumbado o codigo da unidade monetaria no processo da Sarah, fundamental...
                                   AND D.ANOMES_MOVIM_SDCTPR <= TO_NUMBER(202010)
                                   );



--
-- CONTA PARTICIPANTE
-- NAO EXISTE UM REGISTRO NESSA TABELA QUE ATENDA A ESSA CONDIÇÕES... DEVERIA TER FEITO O RALACIONAMENTO COM A --> PARTICIPANTE_FSS
SELECT * 
FROM CONTA_FSS C
WHERE 1=1
AND C.NUM_CTFSS = 976
AND C.COD_UM    = 248



-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-- SOLUÇÃO:
-- VLR_RES1  = VLR_SLD_ADICIONAL (FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB)

-- VLR_RES1  = VLR_SLD_ADICIONAL

SELECT A.VLR_SDANT_SDCTPR, A.VLR_CRMSAN_SDCTPR, A.VLR_ENTMES_SDCTPR, A.VLR_SAIMES_SDCTPR
--SELECT NVL(SUM(A.VLR_SDANT_SDCTPR + A.VLR_CRMSAN_SDCTPR + A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR),0)
--SELECT A.VLR_SDANT_SDCTPR + /*A.VLR_CRMSAN_SDCTPR +*/ A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR   
  FROM SLD_CONTA_PARTIC_FSS A
      ,ATT.PARTICIPANTE_FSS P
      ,ATT.CONTA_FSS        C
  WHERE  1=1   
   AND A.NUM_MATR_PARTF  = P.NUM_MATR_PARTF
   AND A.NUM_CTFSS       = C.NUM_CTFSS
   AND A.NUM_MATR_PARTF  = 43446 --B.NUM_MATR
   AND A.NUM_CTFSS       = 976
   AND A.COD_UM          = 248
   AND P.COD_EMPRS       IN (40,60)     
   AND C.NUM_PLBNF_CTFSS = 19 --COD_PLANO
    AND A.ANOMES_MOVIM_SDCTPR =(SELECT MAX(D.ANOMES_MOVIM_SDCTPR)
                                 FROM SLD_CONTA_PARTIC_FSS D        ---- cotacao_dia
                                 WHERE 1=1
                                   AND D.NUM_MATR_PARTF = 43446 --A.NUM_MATR_PARTF
                                   AND D.NUM_CTFSS      = 976   --A.NUM_CTFSS
                                   AND D.COD_UM         = 248   --A.COD_UM
                                   AND D.ANOMES_MOVIM_SDCTPR <= TO_CHAR(SYSDATE,'YYYYMM')-- maior data no mes da publicacao do extrato
                                );
                                
                                   
								
--SELECT * FROM ATT.CONTA_FSS WHERE NUM_PLBNF_CTFSS = 19 
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-- Essa regra não funciona, o unico campo q tem valor, é subtraido o mesmo valor, por isso fica zero, quando aplica a regra...
									
SELECT A.VLR_SDANT_SDCTPR, A.VLR_CRMSAN_SDCTPR, A.VLR_ENTMES_SDCTPR, A.VLR_SAIMES_SDCTPR
--SELECT NVL(SUM(A.VLR_SDANT_SDCTPR + A.VLR_CRMSAN_SDCTPR + A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR),0)
--SELECT A.VLR_SDANT_SDCTPR, /*A.VLR_CRMSAN_SDCTPR +*/ A.VLR_ENTMES_SDCTPR, A.VLR_SAIMES_SDCTPR
  FROM SLD_CONTA_PARTIC_FSS A
      ,ATT.PARTICIPANTE_FSS P
  WHERE  1=1   
   AND A.NUM_MATR_PARTF = P.NUM_MATR_PARTF
   --AND A.NUM_MATR_PARTF = 43446 --B.NUM_MATR
   AND A.NUM_CTFSS = 976
   AND A.COD_UM    = 248
   AND P.COD_EMPRS = 40         --COD_PLANO 
   AND A.ANOMES_MOVIM_SDCTPR =(SELECT MAX(D.ANOMES_MOVIM_SDCTPR)
                                 FROM SLD_CONTA_PARTIC_FSS D
                                 WHERE 1=1
                                   AND D.NUM_MATR_PARTF = A.NUM_MATR_PARTF
                                   AND D.NUM_CTFSS      = A.NUM_CTFSS
                                   AND D.COD_UM         = A.COD_UM
                                   AND D.ANOMES_MOVIM_SDCTPR <= TO_CHAR(SYSDATE,'YYYYMM')
                                   );										
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
Gravou errado, compilar a procedure e pedir para o usuário validar...

-- DU --> RENDA_ESTIM_PROP  -- ESTÁ CERTO!
SELECT NVL(SUM(VLR_BENEF_PSAP_PROP + VLR_BENEF_BD_PROP + VLR_BENEF_CV_PROP),0)
--SELECT VLR_BENEF_PSAP_PROP,  VLR_BENEF_BD_PROP,  VLR_BENEF_CV_PROP, DTA_FIM_EXTR
FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
WHERE COD_EMPRS = 40                 -- B.COD_EMPRESA
AND NUM_RGTRO_EMPRG = '0000816086-8' --B.NUM_REGISTRO
AND DCR_PLANO = 'PSAP/Eletropaulo'   --B.DCR_PLANO
AND DTA_FIM_EXTR = TO_DATE('30/06/2020','DD/MM/YYYY')-- B.DTA_FIM
--OWN_FUNCESP.PRE_PRC_EXTRATOATUALIZA;    

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
Gravou errado, compilar a procedure e pedir para o usuário validar...
-- DV --> RENDA_ESTIM_INT -- ESTÁ CERTO!
SELECT NVL(SUM(VLR_BENEF_PSAP_INTE + VLR_BENEF_BD_INTE + VLR_BENEF_CV_INTE),0) -- 18746,84
--SELECT VLR_BENEF_PSAP_INTE, VLR_BENEF_BD_INTE, VLR_BENEF_CV_INTE, DTA_FIM_EXTR
FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB
WHERE COD_EMPRS = 40 --B.COD_EMPRESA
AND NUM_RGTRO_EMPRG = '0000816086-8' --B.NUM_REGISTRO
AND DCR_PLANO = 'PSAP/Eletropaulo'--B.DCR_PLANO
AND DTA_FIM_EXTR = TO_DATE('30/06/2020','DD/MM/YYYY')-- B.DTA_FIM


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
VLR_RES2 --> Pega a maior data e maior valor da tab cotacao: 

SELECT NVL(MAX(A.VLR_CDIAUM),0)
--SELECT A.VLR_CDIAUM, a.* -- VALOR
FROM COTACAO_DIA_UM A
WHERE A.COD_UM = 248


SELECT DAT_CDIAUM, C.* --MAIOR DATA
--SELECT MAX(DAT_CDIAUM) -- COTA 248
FROM COTACAO_DIA_UM C
WHERE COD_UM = 248--A.COD_UM
AND DAT_CDIAUM <= SYSDATE



VLR_RES3 = VLR_BENEF_ADICIONAL (FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB)
--> vlr_res1 * vlr_res2



mov_conta_partic



