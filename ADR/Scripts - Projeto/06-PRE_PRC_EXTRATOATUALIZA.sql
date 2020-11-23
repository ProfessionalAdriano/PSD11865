CREATE OR REPLACE Procedure OWN_FUNCESP.Pre_Prc_Extratoatualiza
IS

BEGIN

     Declare
      COD_EMPRESA     NUMBER(3);
      NUM_REGISTRO    VARCHAR2(12);
      DTA_FIM         DATE;
      DCR_PLANO       VARCHAR2(40);
      COD_PLANO       NUMBER;
      DQ              NUMBER(13, 2);
      DR              NUMBER(13, 2);
      DU              NUMBER(13, 2);
      DV              NUMBER(13, 2);
      EI              NUMBER(13, 2);
      EG              NUMBER(13, 2);
      RES1            NUMBER(13, 2);
      RES3            NUMBER(13, 2);
      RES4            NUMBER(13, 2);

    CURSOR CursorExtrato IS
      SELECT COD_EMPRESA
            ,NUM_REGISTRO
            ,DTA_FIM
            ,DCR_PLANO
            ,COD_PLANO
            ,VLR_DQ
            ,VLR_DR
            ,VLR_DU
            ,VLR_DV
            ,VLR_EI
            ,VLR_EG
            ,VLR_RES1
            ,VLR_RES3
            ,VLR_RES4
      FROM own_funcesp.PRE_TBL_TempExtrat_ctb
      ORDER BY COD_EMPRESA,NUM_REGISTRO;

    BEGIN

      OPEN CursorExtrato;
      LOOP

        FETCH CursorExtrato
          INTO COD_EMPRESA
              ,NUM_REGISTRO
              ,DTA_FIM
              ,DCR_PLANO
              ,COD_PLANO
              ,DQ
              ,DR
              ,DU
              ,DV
              ,EI
              ,EG
              ,RES1
              ,RES3
              ,RES4;
        EXIT WHEN CursorExtrato%NOTFOUND;

        UPDATE att.fc_pre_tbl_base_extrat_ctb a
           SET a.VLR_BENEF_BD_PROP   = DQ,
               a.VLR_BENEF_BD_INTE   = DR,
               a.RENDA_ESTIM_PROP    = DU,
               a.RENDA_ESTIM_INT     = DV,
               a.VLR_CTB_INT_BD      = EI,
               a.VLR_CTB_PROP_BD     = EG,
               a.VLR_SLD_ADICIONAL   = RES3, --  RES1
               a.VLR_BENEF_ADICIONAL = RES4  --  RES3 
         WHERE a.cod_emprs = COD_EMPRESA
           and a.num_rgtro_emprg = NUM_REGISTRO
           and a.dta_fim_extr = DTA_FIM
           and a.DCR_PLANO = DCR_PLANO;
      END LOOP;

      CLOSE CursorExtrato;
      dbms_output.put_line('final' );

    END;


END;
