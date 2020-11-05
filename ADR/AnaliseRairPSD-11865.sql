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

















