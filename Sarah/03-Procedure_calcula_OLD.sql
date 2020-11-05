SET ECHO ON
SET TIME ON
SET TIMING ON
SET SQLBL ON
SET SERVEROUTPUT ON SIZE 1000000
SHOW USER
SELECT * FROM GLOBAL_NAME;
SELECT INSTANCE_NAME, HOST_NAME FROM V$INSTANCE;
SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') DATA FROM DUAL;

CREATE OR REPLACE PROCEDURE OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA
(
  cod_empresa    number,
  dcr_plano      varchar2,
  dta_mov        date
)
is

begin

  if cod_empresa=40 and UPPER(dcr_plano)= 'PSAP/ELETROPAULO' then

      insert into own_funcesp.pre_tbl_tempextrat_ctb(cod_empresa, num_registro, dcr_plano, num_matr,cod_plano)
        select x.cod_emprs, x.num_rgtro_emprg, x.dcr_plano, y.num_matr_partf,19
          from att.fc_pre_tbl_base_extrat_ctb x
         inner join att.participante_fss y on y.cod_emprs = x.cod_emprs
                                          and y.num_rgtro_emprg =
                                              to_number(substr(x.num_rgtro_emprg,1,length(x.num_rgtro_emprg) - 2))
         where x.cod_emprs = cod_empresa
           and x.dcr_plano = dcr_plano
         group by x.cod_emprs,x.num_rgtro_emprg,x.dcr_plano,y.num_matr_partf;


      --inicio das consistencias de dados
      if dta_mov is null then
          update own_funcesp.pre_tbl_tempextrat_ctb e
             set e.dta_fim = (select max(dta_fim_extr)
                                from att.fc_pre_tbl_base_extrat_ctb
                               where cod_emprs = e.cod_empresa
                                 and dcr_plano = e.dcr_plano
                                 and num_rgtro_emprg = e.num_registro
                              )
           where e.dta_fim is null;

      else
           update own_funcesp.pre_tbl_tempextrat_ctb e
             set e.dta_fim = dta_mov
           where e.dta_fim is null;

      end if;

      UPDATE own_funcesp.PRE_TBL_TempExtrat_ctb e
       SET e.VLR_BENEF_INTE = (SELECT NVL(max(VLR_BENEF1_HTBNF),0)
                               FROM hist_valor_bnf
                               WHERE NUM_MATR_PARTF = NUM_MATR
                                and COD_NATBNF = 4
                                and to_char(dat_inivg_htbnf,'yyyymm') = to_char(e.dta_fim,'yyyymm')
                              )
     WHERE e.vlr_benef_inte = 0;
     commit;
                              
      update own_funcesp.pre_tbl_tempextrat_ctb b
         set b.vlr_dq = 0,

             b.vlr_dr = (select nvl(max(vlr_benef1_htbnf),0)
                               from hist_valor_bnf
                               where num_matr_partf = num_matr
                                and cod_natbnf = 4
                                and to_char(dat_inivg_htbnf,'yyyymm') = to_char(b.dta_fim,'yyyymm')
                        ),

             b.vlr_du = (select nvl(sum(vlr_benef_psap_prop + vlr_benef_bd_prop +
                                vlr_benef_cv_prop),0)
                         from att.fc_pre_tbl_base_extrat_ctb
                        where cod_emprs = b.cod_empresa
                          and num_rgtro_emprg = b.num_registro
                          and dcr_plano = b.dcr_plano
                          and dta_fim_extr = b.dta_fim

                         ),

             b.vlr_dv = (select nvl(sum(vlr_benef_psap_inte + vlr_benef_bd_inte +
                                vlr_benef_cv_inte),0)
                           from att.fc_pre_tbl_base_extrat_ctb
                          where cod_emprs = b.cod_empresa
                            and num_rgtro_emprg = b.num_registro
                            and dcr_plano = b.dcr_plano
                            and dta_fim_extr = b.dta_fim
                        ),

             b.vlr_ei = att.fcesp_vlr_ctb_assist(b.cod_plano, b.VLR_BENEF_INTE),

             b.vlr_eg = 0,
 
             b.vlr_res1 = (select nvl(sum(a.vlr_sdant_sdctpr + a.vlr_crmsan_sdctpr +
                                  a.vlr_entmes_sdctpr - a.vlr_saimes_sdctpr),0)
                           from sld_conta_partic_fss a, conta_fss c
                          where  a.num_matr_partf = b.num_matr
                            and a.num_ctfss = c.num_ctfss
                            and a.num_ctfss = 976
                            and c.num_plbnf_ctfss = cod_plano
                            and a.anomes_movim_sdctpr =(select max(d.anomes_movim_sdctpr)
                                                         from sld_conta_partic_fss d
                                                        where d.num_matr_partf = a.num_matr_partf
                                                          and d.num_ctfss = a.num_ctfss
                                                          and d.anomes_movim_sdctpr <=
                                                               to_char(to_date(dta_fim,'dd-mm-yyyy'), 'yyyymm')                                                              
                                                        )
                         ),

             b.vlr_res2 = (select nvl(max(a.vlr_cdiaum),0)
                           from cotacao_dia_um a
                          where a.cod_um = 248
                            and a.dat_cdiaum = (select max(dat_cdiaum)
                                                 from cotacao_dia_um
                                                where cod_um = a.cod_um
                                                  and dat_cdiaum <= to_date(dta_fim,'dd-mm-yyyy')                                                     
                                               )
                          )

       where b.vlr_dq = 0;

      commit;

      update own_funcesp.pre_tbl_tempextrat_ctb
         set vlr_res3 = round(vlr_res1 * vlr_res2)
      where vlr_res1>0;

      update own_funcesp.pre_tbl_tempextrat_ctb
         set vlr_res4 = vlr_res3/130
      where vlr_res3>0;
      commit;

  end if;

  dbms_output.put_line('temporaria preenchida');


end;



