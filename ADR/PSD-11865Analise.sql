
SELECT *
OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB;



-- TABELA OFICIAL:
--(PK --> TPO_DADO, COD_EMPRS, NUM_RGTRO_EMPRG, DTA_FIM_EXTR)
--SELECT MAX(DTA_FIM_EXTR)
SELECT *
FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP
WHERE FP.NUM_RGTRO_EMPRG = '0002112941-3'
ORDER BY FP.DTA_FIM_EXTR DESC


--SELECT MAX(TO_DATE(FP.DTA_FIM_EXTR,'DD/MM/RRRR'))INTO L_DT_FIM
SELECT MAX(FP.DTA_FIM_EXTR)
FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP 
WHERE FP.COD_EMPRS = 40 --P_COD_EMPRESA 
AND UPPER(FP.DCR_PLANO) = UPPER('PSAP/Eletropaulo')--UPPER(P_DCR_PLANO);



SELECT * --MAX(FP.DTA_FIM_EXTR)
FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP
WHERE FP.NUM_RGTRO_EMPRG = '0000951307-1'


 --------------------------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------------
 --> Script Teste Rair:
 
SELECT p.num_matr_partf,  p.num_rgtro_emprg,  NVL((A.VLR_SDANT_SDCTPR + A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR),0) AS VLR_RES1, b.num_plbnf , p.cod_emprs, a.num_ctfss, a.anomes_movim_sdctpr
FROM SLD_CONTA_PARTIC_FSS A
  ,ATT.PARTICIPANTE_FSS P
  ,att.adesao_plano_partic_fss b
  ,ATT.CONTA_FSS        C
WHERE  1=1
AND A.NUM_MATR_PARTF  = P.NUM_MATR_PARTF
AND A.NUM_CTFSS       = C.NUM_CTFSS
and p.num_matr_partf  = b.num_matr_partf
and b.num_plbnf in (19)
-- AND A.NUM_MATR_PARTF  = B.NUM_MATR
AND A.NUM_CTFSS       = 976
AND A.COD_UM          = 248
AND P.COD_EMPRS       IN (40,60)
--AND A.ANOMES_MOVIM_SDCTPR <= (202028)
AND A.VLR_SDANT_SDCTPR + A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR <> 0 

 --------------------------------------------------------------------------------------------------------------------------------
 --------------------------------------------------------------------------------------------------------------------------------
SELECT * FROM  
OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB




























 
 
 
 
 
