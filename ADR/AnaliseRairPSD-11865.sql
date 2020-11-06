SELECT NVL(SUM(A.VLR_SDANT_SDCTPR + A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR),0)
  FROM SLD_CONTA_PARTIC_FSS A
      ,ATT.PARTICIPANTE_FSS P
      ,ATT.CONTA_FSS        C
  WHERE  1=1   
   AND A.NUM_MATR_PARTF  = P.NUM_MATR_PARTF
   AND A.NUM_CTFSS       = C.NUM_CTFSS
   AND A.NUM_MATR_PARTF  = 37976 --B.NUM_MATR
   AND A.NUM_CTFSS       = 976
   AND A.COD_UM          = 248
   AND P.COD_EMPRS       IN (40,60)     
   AND C.NUM_PLBNF_CTFSS = 19 --COD_PLANO
    AND A.ANOMES_MOVIM_SDCTPR =(SELECT MAX(D.ANOMES_MOVIM_SDCTPR)
                                 FROM SLD_CONTA_PARTIC_FSS D        
                                 WHERE 1=1
                                   AND D.NUM_MATR_PARTF = 37976 --A.NUM_MATR_PARTF
                                   AND D.NUM_CTFSS      = 976   --A.NUM_CTFSS
                                   AND D.COD_UM         = 248   --A.COD_UM
                                   --AND D.ANOMES_MOVIM_SDCTPR <= TO_CHAR(,'YYYYMM')-- maior data no mes da publicacao do extrato
                                );

------------------------
------------------------
select  s.num_matr_partf, ( (VLR_SDANT_SDCTPR)  + (VLR_ENTMES_SDCTPR)) - (VLR_SAIMES_SDCTPR) Sld_Benf_Adic
	   ,s.*
from       att.sld_conta_partic_fss s
inner join att.participante_fss p on s.num_matr_partf = p.num_matr_partf
where num_ctfss = 976 
and cod_um 		= 248
and p.cod_emprs in ( 40 , 60 )
and s.num_matr_partf = 37976


select * from att.sld_conta_partic_fss s where s.num_matr_partf = 37976 and s.num_ctfss = 976
select * from att.participante_fss p where  p.num_rgtro_emprg = 0000637114 
,
--
--
SELECT * FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
WHERE NUM_MATR = 37976 
AND UPPER(DCR_PLANO) = UPPER('PSAP/Eletropaulo') 
                               


-- 04-Procedure_calcula
DELETE FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB PT WHERE REGEXP_LIKE (PT.DCR_PLANO,'(Plano CD 2 Eletropaulo|Plano CD Eletropaulo)');
COMMIT;


-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
Efetuado teste em Desenvolvimento, não gerou a inconsistencia que gerou no ambiente NewTst:

-- EXEMPLO EM DESENVOLVIMENTO:
SELECT * FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
WHERE NUM_MATR = 37976 -- matricula de teste do Rair
                               

-- Tabela Temporaria:
--TRUNCATE Table own_funcesp.PRE_TBL_TempExtrat_ctb;
SELECT * --COUNT(*) -- 7134 Registros
FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB PT
WHERE REGEXP_LIKE (PT.DCR_PLANO,'(PSAP/Eletropaulo)') 
AND PT.NUM_MATR = 37976 -- matricula de teste do Rair

Nos teste trouxe zero no valor do beneficio adicional, que é o esperado para essa matricula!!!

------------------------------
------------------------------
-- Divergencia do NewTst para NewDev:

-- EXEMPLO EM HOMOLOGAÇÃO:

-- Tabela Temporaria:
/*Gerou mais registros do que deveria, e isso está sendo tratado e foi testado em 
  desenvolvimento, portanto, não deveria...
*/

-- O DBA Edson, estava executando o Script errado...

SELECT COUNT(*)-- 11140...7134 = 4006 a mais 
FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB





-- PLANILHA COMPLETA DO USUÁRIO:
SELECT  A.VLR_SLD_PROJETADO
       ,A.VLR_SLD_ADICIONAL
       ,A.VLR_BENEF_ADICIONAL
       ,A.*
FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB A
WHERE A.COD_EMPRS = 40
--AND A.NUM_RGTRO_EMPRG = '0000637114' -- Registro de ex. do Rair
--AND A.NUM_RGTRO_EMPRG IN ('0000823465-9','0002024023-0','0002078236-9') -- Registro de ex. Luiz
AND A.DTA_FIM_EXTR = TO_DATE ('30/06/20','DD-MM-YY')
AND REGEXP_LIKE (A.DCR_PLANO,'PSAP/Eletropaulo')


--
--
-- TABELA CORRETA PRA PEGAR O PLANO(INFORMACAO DO RAIR)  
--  ADESAO PLANO PARTIC_FSS 




--TRUNCATE Table own_funcesp.PRE_TBL_TempExtrat_ctb
--select COUNT(*) from own_funcesp.PRE_TBL_TempExtrat_ctb

/*
   esse mesmo select em desenvolvimento não traz nada em homo tras, atualizar a proc e subir 
   em new, tratar o parametro de data da entrada, implementar a logica...
*/

SELECT p.num_matr_partf,  p.num_rgtro_emprg,  NVL((A.VLR_SDANT_SDCTPR + A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR),0) AS VLR_RES1, b.num_plbnf , p.cod_emprs
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
and A.VLR_SDANT_SDCTPR + A.VLR_ENTMES_SDCTPR - A.VLR_SAIMES_SDCTPR <> 0


--SELECT MAX(DAT_CDIAUM)
SELECT max(DAT_CDIAUM)AS DAT_CDIAUM, VLR_CDIAUM
--SELECT * 
FROM COTACAO_DIA_UM
WHERE COD_UM = 248 --A.COD_UM
--AND DAT_CDIAUM = TO_DATE('30/06/2020','DD/MM/YYYY') nao devo fazer isso, tenho q pegar a maior cotacao no momento da consulta
GROUP BY VLR_CDIAUM

-- isso esta certo, implementar no proc em dev e subir para homo
DECLARE

 

     VDATA_FIM DATE;
     VALOR NUMERIC;
      
 

BEGIN 
      SELECT MAX(FP.DTA_FIM_EXTR)INTO VDATA_FIM FROM ATT.FC_PRE_TBL_BASE_EXTRAT_CTB FP WHERE FP.COD_EMPRS = 40 AND UPPER(FP.DCR_PLANO) = 'PSAP/ELETROPAULO';
     -- SELECT VDATA_FIM
     
     
     SELECT NVL(MAX(A.VLR_CDIAUM),0)  INTO VALOR
                                  FROM COTACAO_DIA_UM A
                                  WHERE A.COD_UM = 248
                                   AND A.DAT_CDIAUM = (SELECT MAX(DAT_CDIAUM)
                                                        FROM COTACAO_DIA_UM
                                                         WHERE COD_UM = A.COD_UM
                                                         --AND DAT_CDIAUM = TO_DATE('2020-06-30  00:00:00','YYYY-MM-DD  HH24:MI:SS')
                                                         
                                                       );
     
     
     DBMS_OUTPUT.PUT_LINE(VDATA_FIM); 
     DBMS_OUTPUT.PUT_LINE(VALOR); 
END;





SELECT MAX(D.ANOMES_MOVIM_SDCTPR)
  FROM SLD_CONTA_PARTIC_FSS D
 WHERE 1=1
  AND D.NUM_MATR_PARTF = A.NUM_MATR_PARTF
  AND D.NUM_CTFSS      = A.NUM_CTFSS
  AND D.COD_UM         = A.COD_UM					  
  AND D.ANOMES_MOVIM_SDCTPR = TO_NUMBER(TO_CHAR(TRUNC(VDATA_FIM,'YYYYMM'))) OR TO_NUMBER(TO_CHAR(TRUNC(DTA_MOV,'YYYYMM')))
																	-- erro no operador relacional OR



