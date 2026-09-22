#include "Protheus.Ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  M461ADT       ºAutor  ³FERNANDO        º Data ³   01/09/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³BLOQUEIO DE FATURAMENTO									 ¹±±
±±º          ³												              ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function M461ADT()
	Local lRet    := .T.
	Local cPedido  := PARAMIXB[1] //Número do Pedido de Venda
	Local cItem    := PARAMIXB[2] //Item do Pedido de Venda	
	Local aTpFret := { " "," "}	
	
	SC5->(DBSETORDER(1))
	SC6->(DBSETORDER(1))
	SC9->(DBSETORDER(1))
	SB1->(DBSETORDER(1))

	SC5->(DBSEEK(xFilial('SC5')+cPedido))

	If Empty( SC5->C5_ESPECI1 ) .OR. SC5->C5_VOLUME1 == 0 .OR. SC5->C5_PESOL == 0 .OR. SC5->C5_PBRUTO == 0
		FWALERTWARNING("Favor informar o Conteúdo dos Campos, Especie,Volume,Peso Liq e Peso Bruto !!!!!!","ATENÇÃO")
		RETURN.F. 
	Endif


IF  SC5->C5_TIPO=='N' .and. SC6->(DBSEEK(SC5->C5_FILIAL+SC5->C5_NUM+cItem))		
	
	DBSELECTAREA("ZZB")
	ZZB->(DBSETORDER(1))
	IF ZZB->(DBSEEK(FWXFILIAL('ZZB')+cPedido)) .AND. !ZZB->ZZB_STATUS $ "9,A,B"		
		MsgStop("Pedido "+cPedido+" não liberado pelos aprovadores.")		
		RETURN.F. 
	ENDIF

	aTpFret := GetAdvFVal( "SA1",{"A1_XTPFRET","A1_NREDUZ"}, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI , 1, {"",""}  )
	//Solic. Larissa
	//Ticket 4017
	//Alerta para Usuário que o Cliente deve ter melhor analise sobre Tipo de Frete
	//C=CIF;F=FOB
	If aTpFret[1] == "1"
		FWAlertWarning("Para o Cliente : < " + Alltrim(aTpFret[2]) + " > deve-se analisar o Tipo de Frete utilizado, pois pode ser CIF ou FOB !!! " ,"Tipo de Frete" )		   
		If !FwAlertYesNo( "Confirma a Preparação da NF ","Preparação da NF")
			RETURN.F. 
		Endif
	Endif

	SB1->(DBSEEK(xFilial("SB1")+SC6->C6_PRODUTO))	

	IF !EMPTY(SB1->B1_SEGUM) .AND. SC6->C6_UNSVEN==0
		_cPopUp := ' <font color="#FF0000" face="Arial" size="4"><b>Atenção</B></font> '
		_cPopUp += ' <br>'
		_cPopUp += ' <br>'
		_cPopUp += ' <font color="#FF0000" face="Arial" size="3">Verificar o item '+SC6->C6_ITEM+' do pedido.</font>'
		_cPopUp += ' <br>'
		_cPopUp += ' <br>'
		_cPopUp += '<font color="#000000" face="Arial" size="2">A segunda da unidade de medida está zerada.</font>'
		_cPopUp += '<br><br>'				
		FWALERTWARNING(_cPopUp,"ATENÇÃO")
		RETURN.F. 
	ENDIF

	IF SC9->(DBSEEK(SC5->C5_FILIAL+SC5->C5_NUM+SC6->C6_ITEM))			 
		WHILE SC9->C9_FILIAL==SC5->C5_FILIAL .AND. SC9->C9_PEDIDO==SC5->C5_NUM .and. SC6->C6_ITEM==SC9->C9_ITEM .AND. SC9->(!EOF())
			IF SC9->C9_SEQUEN<>"01"				
				SC9->(a460Estorna(.T.))					 		
			ENDIF					 									
			SC9->(DBSKIP())
		ENDDO	
	endif	 

	IF SC9->(DbSeek(FwXFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM ))	
		IF SC6->C6_QTDVEN <> SC9->C9_QTDLIB		
			SC9->(a460Estorna(.T.))
			nQtdLib := MaLibDoFat(;
					SC6->(RecNo()),; //nRegSC6
					SC6->C6_QTDVEN,; //nQtdaLib
								,; //lCredito
								,; //lEstoque
								.F.,; //lAvCred
								.F.,; //lAvEst
								.F.,; //lLibPar
								.F.; //lTrfLocal
									)    
		ENDIF

	ELSEIF !SC9->(DbSeek(FwXFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM ))
		nQtdLib := MaLibDoFat(;
				SC6->(RecNo()),; //nRegSC6
				SC6->C6_QTDVEN,; //nQtdaLib
							,; //lCredito
							,; //lEstoque
							.F.,; //lAvCred
							.F.,; //lAvEst
							.F.,; //lLibPar
							.F.; //lTrfLocal
								)      	
	ENDIF		
					
	SC9->(DbSeek(FwXFilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )) 
	IF SC6->C6_QTDVEN <> SC9->C9_QTDLIB	.or. SC9->C9_SEQUEN<>"01"	
		_cPopUp := ' <font color="#FF0000" face="Arial" size="4"><b>Atenção</B></font> '
		_cPopUp += ' <br>'
		_cPopUp += ' <br>'
		_cPopUp += ' <font color="#FF0000" face="Arial" size="3">Verificar o item '+SC6->C6_ITEM+' do pedido.</font>'
		_cPopUp += ' <br>'
		_cPopUp += ' <br>'
		_cPopUp += '<font color="#000000" face="Arial" size="2">A liberação não está condizente com a quantidade do pedido.</font>'
		_cPopUp += '<br><br>'
		_cPopUp += '<font color="#000000" face="Arial" size="2">Quantidade Pedido: '+cvaltochar(SC6->C6_QTDVEN)+' - Quantidade Liberada:'+CVALTOCHAR(SC9->C9_QTDLIB)+'</font>'	
		FWALERTWARNING(_cPopUp,"ATENÇÃO")
		RETURN.F. 
	ENDIF
	//		
	If Empty( SC9->C9_LOTECTL) .AND. SB1->B1_RASTRO == "L"

	ENDIF								

endif

Return lRet
