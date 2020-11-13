PROJ-760
PROJ-1380
PSD-11865 | RS | Ajustes no extrato previdenciário para atender o saldamento PSAP
-- EM ANDAMENTO



-- Usuário --> Luiz Carlos Queiroz Silva

 * ao efetuar a homologação, informou inconsistência...

-- Pegar o objeto neste diretório:
J:\Change_Request\Desenvolvimento\Amadeus\Capitalizacao\GMUD-5431_20201001_Desenv_Leandro_Proc



-- PSD-23824 - Aguardando execucao dos objetos abaixo para teste:
/*
Prezados, Boa Tarde!
Por gentileza executar o script 06-Execute.sql, no ambiente de Homologação, NEWTST.
J:\Change_Request\Desenvolvimento\Amadeus\Capitalizacao\GMUD-4050_20200716_Desenv_Leandro_Proc\Prod
*/

/*
--PSD-23884 cobrar 
Prezados, Boa Tarde!
Por gentileza executar o script 07-Execute.sql, no ambiente de Homologação, NEWTST.
J:\Change_Request\Desenvolvimento\Amadeus\Capitalizacao\GMUD-4050_20200716_Desenv_Leandro_Proc\Prod
*/







/*SELECT P.NUM_MATR, P.* FROM OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB P 
WHERE 1=1 --UPPER(P.DCR_PLANO) NOT IN ('PSAP/ELETROPAULO')
AND REGEXP_LIKE(DCR_PLANO,'(PSAP/ELETROPAULO)')
AND P.NUM_REGISTRO IN ('0000823465-9','0002024023-0','0002078236-9')
ORDER BY P.NUM_MATR*/

--TRUNCATE TABLE OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB;

/*BEGIN
 OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA_F02860(40,'PSAP/ELETROPAULO',NULL);
END;*/

--OWN_FUNCESP.PRE_PRC_EXTRATOATUALIZA;

/*
0000823465-9 VANDERLEI CUNHA
0002024023-0 RONALDO FERREIRA VICENTIN
0002078236-9 LUIS CARLOS SALLES COTA*/











-- PSD-23909 Chamado encerrado, de compilação de script...


-- PSD-23977
-- Aguardando execução das procedures


Pedir para o Edson, Hideyoshi compilar pra mim e executar o objeto...




/*

NUM_CTFSS = 976 --> Numero do Fundo (provavelmente é novo)
COD_UM --> Unidade Monetária

Todos os registros de participantes que atendem a condição de:



- Empresa: 40;
- Plano: 19/PSAP-EletroPaulo; e
- Com a maior data fim.

 

Não encontram matricula correspondente, relacionado ao saldo da conta de participante de folha (SLD_CONTA_PARTIC_FSS) 
que contenha o numero de NUM_CTFSS igual 976


--Luiz carlos queiroz
--cod_um 26 -   248  --> 
o saldo está parado no mes 4 carga em junho




[18:02] Leandro Leme
sim nesse caso utilizaremos o fundo 976

tem 5 matriculas no NewTst 
43842
37976
53534
83819
87445

43842,37976,53534,83819,87445

-- as vezes pode trazes dois registros por conta do TPO_DADO

*/

-- PSD-24169
-- Aguardando execução das procedures


-- PLANILHA COMPLETA DO USUÁRIO:
SELECT  *
FROM att.fc_pre_tbl_base_extrat_ctb a
         WHERE a.cod_emprs = 40
           --and a.num_rgtro_emprg = '0000965545-3'
           and a.dta_fim_extr = TO_DATE ('30/06/20','DD-MM-YY')
           and a.DCR_PLANO = 'PSAP/Eletropaulo';



-- COTACAO
select * from cotacao_dia_um a /*where dat_cdiaum = to_date('30/04/2020','dd/mm/yyyy')*/
--select nvl(max(a.vlr_cdiaum),0)  
--from cotacao_dia_um a
where a.cod_um = 26 -- na tabela de cotacao nao existe a undade monetária 248 (apenas 26), o que fazer neste caso
and a.dat_cdiaum = (select max(dat_cdiaum)
                    from cotacao_dia_um
                     where cod_um = a.cod_um
                      and dat_cdiaum <= sysdate);
                      --and dat_cdiaum <= to_date('30/04/2020','dd-mm-yyyy')) 



--

-- PSD-24238 Aguardando execução do Scripts 04 e 06





/*-- verificar esse casom com o luiz e o Leandro em uma reunião....
-- PLANILHA COMPLETA DO USUÁRIO:
SELECT  a.vlr_ctb_int_bd, a.VLR_BENEF_BD_INTE, a.dta_fim_extr, a.*
FROM att.fc_pre_tbl_base_extrat_ctb a
         WHERE a.cod_emprs = 40
           and a.num_rgtro_emprg =  --'0000637114-4' -- '0001996738-5'
           --and a.dta_fim_extr = TO_DATE ('30/06/20','DD-MM-YY')
           and a.DCR_PLANO = 'PSAP/Eletropaulo'
           and a.vlr_ctb_int_bd = 0.00
           order by a.dta_fim_extr desc;
--uma tabela do charge que grava nessa tabela...
*/
           


-- PSD-24264 - Aguardando execução dos scripts em NewTst...
 Executado...
-- PSD-24283 - Aguardando execução dos scripts em NewTst...
-- PSD-24323 
-- PSD-24378
-- PSD-24338




0000823465-9 VANDERLEI CUNHA			-- 43842
0002024023-0 RONALDO FERREIRA VICENTIN  -- 83819
0002078236-9 LUIS CARLOS SALLES COTA	-- 87445



1) existem participante com saldo adicional e que não trouxe no arquivo


1) continua pendente. Você está se referindo ao campo VLR_SLD_ADICIONAL?
Aquelas abaixo que você mencionou no relatório trouxe 

0000823465-9 VANDERLEI CUNHA			-- matricula 43842
0002024023-0 RONALDO FERREIRA VICENTIN  -- matricula 83819
0002078236-9 LUIS CARLOS SALLES COTA	-- matricula 87445
'0000823465-9','0002024023-0','0002078236-9'

Prezados, Boa tarde!
Por gentileza recompilar o script
04-Procedure_calculaF02860, no ambiente de Homologação, NEWTST.
J:\Change_Request\Desenvolvimento\Amadeus\Capitalizacao\GMUD-4050_20200716_Desenv_Leandro_Proc\Prod
Posteriormente, executar o script 06-Execute

--PSD-24579 Aguardando execução

/*
-------------------------------------------------------------------------------------------------------------------------------
*/-- Reunião de alinhamento dessa atividade com Usuario:
-- Proc que trabalhei ontem
OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA;


BEGIN
OWN_FUNCESP.PRE_PRC_EXTRATOCALCULA(40,'psap/eletropaulo',NULL);
OWN_FUNCESP.PRE_PRC_EXTRATOATUALIZA;
OWN_FUNCESP.PROC_REND_ESTIM 	-- Eu criei
END;





Recompilar os objetos abaixo no ambiente de Homologação, NEWTST.
04-Procedure_calcula
07-PRE_PRC_EXTRATOATUALIZA

Diretório:
J:\Change_Request\Desenvolvimento\Amadeus\Capitalizacao\GMUD-4050_20200716_Desenv_Leandro_Proc\Prod

Posteriormente, executar o script 06-Execute
---------------------------------------------
---------------------------------------------
-- Novo teste, apenas Truncate na tabela --> OWN_FUNCESP.PRE_TBL_TEMPEXTRAT_CTB
														 
Prezados, boa tarde!

Por favor, executar o Script abaixo em NewTst:

Diretório:
J:\Change_Request\Desenvolvimento\Amadeus\Capitalizacao\GMUD-4050_20200716_Desenv_Leandro_Proc\Prod

-- Apenas este arquivo:
08-DDL_TRUNCATE

-- Aguardando execução de sub-tarefa...
-- Executado pelo Edson DBA...



Executar os objetos abaixo no ambiente de Homologação, NEWTST.
04-Procedure_calcula
10-PROC_REND_ESTIM


Diretório:
J:\Change_Request\Desenvolvimento\Amadeus\Capitalizacao\GMUD-4050_20200716_Desenv_Leandro_Proc\Prod
-- J:\Change_Request\Implantacao\Amadeus\Capitalizacao\2020\GMUD-4050_20200716_Desenv_Leandro_Proc\Prod (Implantacao Logs)

Posteriormente, executar o script 06-Execute



-- Criar uma Sub-Task em homologação 




Executar o objeto abaixo no ambiente de Homologação, NEWTST.
10-PROC_REND_ESTIM


Diretório:
J:\Change_Request\Desenvolvimento\Amadeus\Capitalizacao\GMUD-4050_20200716_Desenv_Leandro_Proc\Prod

Posteriormente, executar o script 06-Execute


---------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------
Executar os objetos abaixo no ambiente de Homologação, NEWTST.
10-PROC_REND_ESTIM

Diretório:
J:\Change_Request\Desenvolvimento\Amadeus\Capitalizacao\GMUD-4050_20200716_Desenv_Leandro_Proc\Prod

Posteriormente, executar o script 06-Execute


-- AGuardando Usuário validar...



















































