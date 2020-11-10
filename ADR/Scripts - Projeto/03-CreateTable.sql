SET ECHO ON
SET TIME ON
SET TIMING ON
SET SQLBL ON
SET SERVEROUTPUT ON SIZE 1000000
SHOW USER
SELECT * FROM GLOBAL_NAME;
SELECT INSTANCE_NAME, HOST_NAME FROM V$INSTANCE;
SELECT TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI:SS') DATA FROM DUAL;

     CREATE table own_Funcesp.PRE_TBL_TempExtrat_ctb
      (COD_EMPRESA    NUMBER(3) not null,
        NUM_REGISTRO    VARCHAR2(12) not null,
        DTA_FIM         DATE,
        DCR_PLANO       VARCHAR2(40),
        VLR_BENEF_INTE  NUMBER(13, 2) default 0,
        NUM_MATR        NUMBER,
        COD_PLANO       NUMBER,
        VLR_DQ          NUMBER(13, 2) default 0,
        VLR_DR          NUMBER(13, 2) default 0,
        VLR_DU          NUMBER(13, 2) default 0,
        VLR_DV          NUMBER(13, 2) default 0,
        VLR_EI          NUMBER(13, 2) default 0,
        VLR_EG          NUMBER(13, 2) default 0,
        VLR_RES1        NUMBER(13, 2) default 0,
        VLR_RES2        NUMBER(20, 10) default 0,
        VLR_RES3        NUMBER(13, 2) default 0,
        VLR_RES4        NUMBER(13, 2) default 0
      );
