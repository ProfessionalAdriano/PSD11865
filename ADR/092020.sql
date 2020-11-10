--OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA  -- executar em NewDev             
SELECT * FROM own_funcesp.pre_tbl_tempextrat_ctb where 1=1
and num_registro = '0000816086-8';--'0002024023-0'--'0001996738-5' --'0000823465-9'--'0000637114-4' --'0002078236-9'

--att.fcesp_vlr_ctb_assist;                         -- FUNCTION -- VERIFICAR OK
SELECT * FROM ATT.fc_pre_tbl_base_extrat_ctb where num_rgtro_emprg = '0000816086-8'
AND COD_EMPRS = 40

SELECT * FROM ATT.participante_fss; -- OK
SELECT * FROM ATT.hist_valor_bnf; -- OK
SELECT * FROM ATT.sld_conta_partic_fss; -- OK
SELECT * FROM ATT.cotacao_dia_um; -- OK
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
SELECT X.COD_EMPRS, X.DCR_PLANO, X.DTA_FIM_EXTR, x.*
--SELECT  x.vlr_benef_psap_prop + x.vlr_benef_bd_prop + X.Vlr_Benef_Cv_Prop
--SELECT X.VLR_BENEF_PSAP_INTE + X.VLR_BENEF_BD_INTE + X.VLR_BENEF_CV_INTE
--SELECT x.vlr_benef_psap_prop, x.vlr_benef_bd_prop, X.Vlr_Benef_Cv_Prop
from att.fc_pre_tbl_base_extrat_ctb x
WHERE X.COD_EMPRS = 40
AND UPPER(X.DCR_PLANO) = 'PSAP/ELETROPAULO'
AND X.DTA_FIM_EXTR = TO_DATE('30/06/2020','DD/MM/YYYY')
AND X.NUM_RGTRO_EMPRG = '0000637114-4'; --0000823465-9 0001996738-5 0002024023-0 0002078236-9
--------------------------------------------------------------------------------------------
--SELECT NVL(max(VLR_BENEF1_HTBNF),0) --4354,03  --> 818,79
select b.VLR_BENEF1_HTBNF, b.* 
FROM hist_valor_bnf b
WHERE b.NUM_MATR_PARTF = 43446 --NUM_MATR
and b.COD_NATBNF = 4
and to_char(b.dat_inivg_htbnf,'yyyymm') = to_char('202006','yyyymm')


-- PROCESSO SARAH

SELECT PT.cod_empresa,    --OK
       PT.num_registro,   --OK
       PT.dcr_plano,      --OK
       PT.num_matr,       --OK
       PT.cod_plano,      --OK
       PT.DTA_FIM,        --OK
       PT.VLR_BENEF_INTE, --OK 4187 
       PT.VLR_DQ,         --OK SET 0
       PT.VLR_DR,         --OK 4187    818,79                             
       PT.VLR_DU,         -- 33827,11 deveria ser 29789,38 <-- ENTENDER PQ POPULOU ERRADO
       PT.VLR_DV,         -- 33827,11 deveria ser 33976,86 <-- ENTENDER PQ POPULOU ERRADO
       PT.VLR_EI,         --OK  116,56         pega o retorno da function --> att.fcesp_vlr_ctb_assist
       PT.VLR_EG,         --OK 0
       PT.VLR_RES1,       --0.00 deveria ser 33601,41115 <-- ENTENDER PQ POPULOU ERRADO  
       PT.VLR_RES2,       --0,0000000000 deveria ser 33,12320181
       PT.VLR_RES3,       -- 0,00 * 0,0000000000  (VLR_RES1 e vlr_res2 estao inconsistentes, por isso o erro)
       PT.VLR_RES4        -- 0,00/130 (vlr_res3/130 --> o vlr_res3 esta inconsistente, por isso do erro)
FROM own_funcesp.pre_tbl_tempextrat_ctb PT
WHERE PT.COD_EMPRESA = 40
AND UPPER(PT.DCR_PLANO) = 'PSAP/Eletropaulo'
AND PT.DTA_FIM >= TO_DATE('30/06/2020','DD/MM/YYYY')
--AND PT.NUM_REGISTRO IN ('0000823465-9')
-- FOR UPDATE;

SELECT P.VLR_CTB_INT_BD, P.DTA_FIM_EXTR, P.*
FROM att.fc_pre_tbl_base_extrat_ctb P
WHERE 1=1
--AND P.NUM_RGTRO_EMPRG = '0000816086-8'
ORDER BY P.DTA_FIM_EXTR DESC;



-- 1º UPDATE OK
--SELECT NVL(max(VLR_BENEF1_HTBNF),0)
SELECT H.VLR_BENEF1_HTBNF, H.*
FROM hist_valor_bnf H
WHERE H.NUM_MATR_PARTF = 2011301 --NUM_MATR
AND H.COD_NATBNF = 4
ORDER BY H.VLR_BENEF1_HTBNF DESC
--and dat_inivg_htbnf = 


-- 2º UPDATE
--SELECT NVL(max(VLR_BENEF1_HTBNF),0)
SELECT T.vlr_dq, T.*
FROM own_funcesp.pre_tbl_tempextrat_ctb T
where T.NUM_MATR = 43446




--select vlr_sdant_sdctpr + vlr_crmsan_sdctpr + vlr_entmes_sdctpr - vlr_saimes_sdctpr --33601,41115
select a.vlr_sdant_sdctpr, a.vlr_crmsan_sdctpr, a.vlr_entmes_sdctpr, a.vlr_saimes_sdctpr, a.*
from sld_conta_partic_fss a
where 1=1
and num_ctfss = 976 -- tem que escolher um fundo, pq 976 esta 00000...
--and cod_um = 248
and a.anomes_movim_sdctpr = 202004
and a.num_matr_partf = 83819 
--order by anomes_movim_sdctpr desc

--b.vlr_res1
select a.vlr_sdant_sdctpr, a.vlr_crmsan_sdctpr, a.vlr_entmes_sdctpr, a.vlr_saimes_sdctpr 
--select nvl(sum(a.vlr_sdant_sdctpr + a.vlr_crmsan_sdctpr + a.vlr_entmes_sdctpr - a.vlr_saimes_sdctpr),0) --33601,41115
from sld_conta_partic_fss a, 
     conta_fss c
where a.num_matr_partf = 83819 --b.num_matr
and a.num_ctfss = c.num_ctfss
and a.num_ctfss = 976
and c.num_plbnf_ctfss = 19 -- cod_plano
and a.anomes_movim_sdctpr =(select max(d.anomes_movim_sdctpr)
                             from sld_conta_partic_fss d
                             where d.num_matr_partf = a.num_matr_partf
                             and d.num_ctfss = a.num_ctfss
                             and d.anomes_movim_sdctpr <= to_char(to_date('30/06/2020','dd-mm-yyyy'), 'yyyymm'));
                             
                             



select nvl(sum(a.vlr_sdant_sdctpr + a.vlr_crmsan_sdctpr + a.vlr_entmes_sdctpr - a.vlr_saimes_sdctpr),0)
from sld_conta_partic_fss a, 
     conta_fss c
where a.num_matr_partf = 83819 --b.num_matr
and a.num_ctfss = c.num_ctfss
and a.num_ctfss = 976
and c.num_plbnf_ctfss = 19 -- cod_plano


-- tabela conta 
select *
from conta_fss c
where 1=1
--where a.num_matr_partf = 83819 --b.num_matr
--and a.num_ctfss = c.num_ctfss
--and a.num_ctfss = 976
and c.num_plbnf_ctfss = 19 -- 
and num_ctfss = 976



