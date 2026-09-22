#INCLUDE "totvs.ch"
#Include "TopConn.ch"   
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO2     º Autor ³ AP6 IDE            º Data ³  17/12/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BSLR002()
	Local aPergs   := {}
	Local cRecDest := space(06)
	Local aRet	   := {} 


	aAdd(aPergs,{1,"Filial"    ,Space(6),"","","","",0,.F.}) // Tipo caractere
	aAdd(aPergs,{1,"Filial"    ,Space(6),"","","","",0,.F.}) // Tipo caractere
	aAdd(aPergs,{1,"Data De:"  ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data
	aAdd(aPergs,{1,"Data Até:" ,Ctod(Space(8)),"","","","",50,.F.}) // Tipo data

	lRet := ParamBox( @aPergs , "Entrada de Notas Fiscais - BSL" , aRet , {||BSLR002a(aRet)} , NIL , .T. )
return

Static Function BSLR002a(aRet)
	Processa( {|| BSLR002b(aRet) }, "Aguarde...", "Exportando Dados ...",.T.)
Return


Static Function BSLR002b(aRet)
	Local aArea    := GetArea()
	Local oFWMsExcel
	Local cSQL     := "" 
	Local oExcel
	Local cArquivo    := GetTempPath()+'BSLR002.xml'
	Local _nRegistros := 0


	//IF (lRet)
	//Query de consulta
	cSql := "SELECT D1_FILIAL, D1_DOC, D1_COD, D1_UM, "+ STR_PULA
	cSql += "D1_QUANT, D1_VUNIT, D1_TOTAL, " + STR_PULA
	cSql += "D1_VALIPI, D1_TES, D1_DESC, D1_IPI, "+ STR_PULA
	cSql += "D1_FORNECE, A2_NREDUZ, D1_LOJA , "+ STR_PULA
	cSql += "D1_PEDIDO, " + STR_PULA
	cSql += "CASE WHEN (D1_EMISSAO = '') THEN '' " + STR_PULA
	cSql += "ELSE CONVERT(varchar, CONVERT(datetime, D1_EMISSAO), 103) " + STR_PULA
	cSql += "END AS DT_EMISSAO, "+ STR_PULA
	cSql += "CASE WHEN (D1_DTDIGIT = '') THEN '' " + STR_PULA
	cSql += "ELSE CONVERT(varchar, CONVERT(datetime, D1_DTDIGIT), 103) " + STR_PULA
	cSql += "END AS DT_DIGITACAO, "+ STR_PULA
	cSql += "CASE WHEN (D1_ZDTETG = '') THEN '' " + STR_PULA
	cSql += "ELSE CONVERT(varchar, CONVERT(datetime, D1_ZDTETG), 103) " + STR_PULA
	cSql += "END AS DT_ENTREGA, "+ STR_PULA
	cSql += "D1_SERIE, D1_ITEMPC, C7_CONTRA, D1_CC, D1_CONTA, C7_USER, " 
	//--cSql += "C7_EMISSAO  EMISSAO_PEDIDO, "
	cSql += "CASE WHEN (C7_EMISSAO = '') THEN '' " 
	cSql += "ELSE CONVERT(varchar, CONVERT(datetime, C7_EMISSAO), 103) " 
	cSql += "END AS C7_EMISSAO, "
	cSql += "D1_ALQCOF, D1_ALQPIS, D1_ALIQISS, D1_VALICM, "
	cSql += "F1_COND, "
	cSql += "A2_EST, B1_DESC,F4_FINALID,CTT_DESC01,CT1_DESC01,F1_COND,E4_DESCRI,A2_NOME "
	cSql += "FROM "+RetSqlName("SD1") +" "
	cSql += "LEFT JOIN "+RetSqlName("SC7")  +" ON (D1_PEDIDO = C7_NUM AND D1_FILIAL = C7_FILIAL AND SD1010.D_E_L_E_T_ = SC7010.D_E_L_E_T_ AND D1_ITEMPC = C7_ITEM) "	
	cSql += "LEFT JOIN "+RetSqlName("SF1")  +" ON (D1_DOC = F1_DOC AND SD1010.D_E_L_E_T_ = SF1010.D_E_L_E_T_ AND D1_FILIAL = F1_FILIAL AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE) "
	cSql += "LEFT JOIN "+RetSqlName("SA2")  +" ON (D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SD1010.D_E_L_E_T_ = SA2010.D_E_L_E_T_) "
	cSql += "LEFT JOIN "+RetSqlName("SB1") +" ON (B1_COD = D1_COD AND SB1010.D_E_L_E_T_ = '')      "
	cSql += "LEFT JOIN "+RetSqlName("CTT") +" ON (CTT_CUSTO = D1_CC  AND CTT010.D_E_L_E_T_ = '')     "
	cSql += "LEFT JOIN "+RetSqlName("SF4") +" ON (F4_CODIGO = D1_TES AND SF4010.D_E_L_E_T_ = '')   "
	cSql += "LEFT JOIN "+RetSqlName("CT1") +" ON (CT1_CONTA = D1_CONTA AND CT1010.D_E_L_E_T_ = '') "
	cSql += "LEFT JOIN "+RetSqlName("SE4") +" ON (E4_CODIGO = F1_COND AND SE4010.D_E_L_E_T_ = '')  " 

	cSql += "WHERE "

	IncProc("Aplicando os filtros")
	//filtro filial
	If !empty(aRet[1]) .and. !empty(aRet[2])
		cSql += "D1_FILIAL BETWEEN '"+aRet[1]+"' AND '"+aRet[2]+"' AND " 
	Endif

	//filtro data de emissão 
	If !empty(aRet[3]) .and. !empty(aRet[4])
		cSql += "D1_EMISSAO BETWEEN '"+dtos(aRet[3])+"' AND '"+dtos(aRet[4])+"' AND " 
	Endif	

	cSql += "SD1010.D_E_L_E_T_ <> '*' "

	//executando a Query
	TCQuery cSql New Alias "QRYPRO"

	If QRYPRO->( !Eof() )  

		CursorWait()

		//Criando o objeto que irá gerar o conteúdo do Excel
		oFWMsExcel := FWMSExcel():New()

		//Criando a Tabela
		oFWMsExcel:AddworkSheet("Notas")

		//Criando a Tabela
		oFWMsExcel:AddTable("Notas","Itens")

		//add os títulos das colunas 
		oFWMsExcel:AddColumn("Notas","Itens","Filial",1)
		oFWMsExcel:AddColumn("Notas","Itens","Empresa",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Filial",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Nota",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Código Produto",1)
		oFWMsExcel:AddColumn("Notas","Itens","Descrição Produto",1)  
		oFWMsExcel:AddColumn("Notas","Itens","Unidade",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Quantidade",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Valor Unitario",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Valor Total",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Valor IPI",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Código TES",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Descrição TES",1) 
		oFWMsExcel:AddColumn("Notas","Itens","Valor IPI",1)
		oFWMsExcel:AddColumn("Notas","Itens","Cod. Fornecedor",1)
		oFWMsExcel:AddColumn("Notas","Itens","Loja",1)
		oFWMsExcel:AddColumn("Notas","Itens","Razão Social",1)
		oFWMsExcel:AddColumn("Notas","Itens","Numero Pedido",1)
		oFWMsExcel:AddColumn("Notas","Itens","Data de Emissao",1)
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_DTDIGIT"),1)
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_ZDTETG"),1)
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_SERIE"),1)
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_ITEMPC"),1) 
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("C7_CONTRA"),1) 
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_CC"),1) 
		oFWMsExcel:AddColumn("Notas","Itens","Descrição C.Custo",1) 
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_CONTA"),1) 
		oFWMsExcel:AddColumn("Notas","Itens","Descrição C.Contábil",1) 
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("C7_USER"),1)
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("C7_EMISSAO"),1)
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_ALQCOF"),1)
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_ALQPIS"),1)
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_ALIQISS"),1)
		oFWMsExcel:AddColumn("Notas","Itens",X3Desc("D1_VALICM"),1)
		oFWMsExcel:AddColumn("Notas","Itens","Condição PG",1)
		oFWMsExcel:AddColumn("Notas","Itens","Descrição Cond. Pagamento",1) 
		oFWMsExcel:AddColumn("Notas","Itens","UF",1)

		While !QRYPRO->(Eof())
			_nRegistros ++
			QRYPRO->(DbSkip())
		Enddo

		ProcRegua(_nRegistros)

		QRYPRO->(DbGoTop())
		While !(QRYPRO->(EoF()))
			IncProc()
			oFWMsExcel:AddRow("Notas","Itens",{;
			QRYPRO->D1_FILIAL,;
			exibeFil(QRYPRO->D1_FILIAL,"1"),;//Posicione("SM0",1,xFilial("SD1")+QRYPRO->D1_FILIAL,"M0_NOMECOM"),;
			exibeFil(QRYPRO->D1_FILIAL,"2"),;//Posicione("SM0",1,xFilial("SD1")+QRYPRO->D1_FILIAL,"M0_FILIAL"),;
			QRYPRO->D1_DOC,; 
			QRYPRO->D1_COD,;
			QRYPRO->B1_DESC,; 
			QRYPRO->D1_UM,; 
			QRYPRO->D1_QUANT,; 
			QRYPRO->D1_VUNIT,; 
			QRYPRO->D1_TOTAL,; 
			QRYPRO->D1_VALIPI,; 
			QRYPRO->D1_TES,;
			QRYPRO->F4_FINALID,;   
			QRYPRO->D1_IPI,;
			QRYPRO->D1_FORNECE,;
			QRYPRO->D1_LOJA,;
			QRYPRO->A2_NOME,;
			QRYPRO->D1_PEDIDO,;
			QRYPRO->DT_EMISSAO,;
			QRYPRO->DT_DIGITACAO,;
			QRYPRO->DT_ENTREGA,;
			QRYPRO->D1_SERIE,;
			QRYPRO->D1_ITEMPC,; 
			QRYPRO->C7_CONTRA,; 
			QRYPRO->D1_CC,; 
			QRYPRO->CTT_DESC01,;  
			QRYPRO->D1_CONTA,;
			QRYPRO->CT1_DESC01,; 
			QRYPRO->C7_USER,;
			QRYPRO->C7_EMISSAO,;
			QRYPRO->D1_ALQCOF,;
			QRYPRO->D1_ALQPIS,;
			QRYPRO->D1_ALIQISS,;
			QRYPRO->D1_VALICM,;
			QRYPRO->F1_COND,;
			QRYPRO->E4_DESCRI,; 
			QRYPRO->A2_EST})

			//Pulando Registro
			QRYPRO->(DbSkip())
		EndDo

		//Ativando o arquivo e gerando o xml
		oFWMsExcel:Activate()
		oFWMsExcel:GetXMLFile(cArquivo) 

		//Colocando um temporizador
		Sleep( 5000 )

		//Abrindo o excel e abrindo o arquivo xml
		oExcel := MsExcel():New()           //Abre uma nova conexão com Excel
		oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
		oExcel:SetVisible(.T.)              //Visualiza a planilha
		oExcel:Destroy()                    //Encerra o processo do gerenciador de tarefas
	Else
		Alert("Não há dados para serem exibidos.")
	EndIf  

	QRYPRO->(DbCloseArea())
	RestArea(aArea)
	//EndIF    
Return .T.   

/*--------------------------------------------- 
Função estática para trazer os nomes das colunas
da SX3
-----------------------------------------------*/
Static Function X3Desc(cCampo)

	Local cRet := ""

	dbSelectArea('SX3')
	SX3->( dbSetOrder(2) )
	SX3->( dbSeek( cCampo ) )
	cRet := X3Descric()

	dbCloseArea()

Return( cRet ) 

/*--------------------------------------------- 
Função estática para trazer os nomes das colunas
da SX3
-----------------------------------------------*/
Static Function exibeFil(_cFilial,_cTipo)
	Local _cEmpAnt := SM0->M0_CODIGO
	Local _cFilAnt := SM0->M0_CODFIL
	Local cRet := ""

	SM0->( dbSeek( _cEmpAnt + _cFilial ) )

	If _cTipo == "1"
		cRet := SM0->M0_NOMECOM  
	Else 
		cRet := SM0->M0_FILIAL    
	EndIF
	//RETORNAR À EMPRESA E FILIAL CORRENTE
	SM0->( dbSeek( _cEmpAnt + _cFilAnt ) )

return cRet
