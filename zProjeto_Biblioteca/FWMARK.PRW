#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
 
/* {Protheus.doc} Devolução de Livros ================
@Função : Rotina para devolução de livros
@Author : Fabrício Santos
@Since  : 27/05/2024
@Version: 1.0
======================================================*/
 
User Function FWMARK()
    Local aArea   As Array   // ÁREA DE TRABALHO CORRENTE
    Local oDialog As Object  // CAIXA DE DIÁLOGO

    // INICIALIZAÇÃO DE VARIÁVEIS
    aArea   := GetArea()
    oDialog := GenDialog(50)

    // INCORPORA A GRID
    GenMarkBrw(@oDialog)

    // EXIBE A CAIXA DE DIÁLOGO
    ACTIVATE MSDIALOG oDialog CENTERED

    // RESTAURA A ÁREA DE TRABALHO ANTERIOR
    RestArea(aArea)

Return

//--------------------------------------------------------
// EFETUA A MONTAGEM DA CAIXA DE DIÁLOGO DE FUNDO
//--------------------------------------------------------
Static Function GenDialog(nPercent As Numeric)
    Local oSize   As Object // TAMANHO DOS COMPONENTES
    Local oDialog As Object // CAIXA DE DIÁLOGO

    // INICIALIZAÇÃO DE VARIÁVEIS
    oSize := FwDefSize():New(.F.)

    // DEFINIÇÃO DA CAIXA DE DIÁLOGO
    DEFINE MSDIALOG oDialog TITLE "Devolução de Livros" FROM 000,000 TO Round(oSize:aWindSize[3] * (nPercent/100), 0), Round(oSize:aWindSize[4] * (nPercent/100), 0) PIXEL
Return (oDialog)

//--------------------------------------------------------
// INCORPORA A GRID EM UMA CAIXA DE DIÁLOGO
//--------------------------------------------------------
Static Function GenMarkBrw(oDialog As Object)

// Declação de Váriavéis 
Local  oMark          As Object // Objeto da caixa de selção
Local cFiltro 
Public cCodProtocol   As Character // Código do usuário


// Inicialização de Váriaveis 

cCodProtocol := SZ6->Z6_Protoco //Armazena o Código do Usuário de acordo com a posição no Browser
cFiltro := "SZ7->Z7_Protoco == cCodProtocol .and. Empty(SZ7->Z7_DEVREAL)"

// CAMPOS DO NAVEGADOR
    aFields := {}
    AAdd(aFields, {"Protocolo de Locação", "Z7_Protoco", "C",  15,  00})
    AAdd(aFields, {"Codigo do Exemplar"  , "Z7_Exempla", "C",  15,  00})


    // DEFINIÇÕES DO NAVEGADOR
    oMark := FwMarkBrowse():New()

        oMark:SetIgnoreARotina(.T.)
        oMark:SetMenuDef("FWMARK")
        oMark:SetAlias('SZ7')
        oMark:SetTemporary(.T.)
        oMark:SetFields(aFields)
        oMark:SetFieldMark('Z7_MARK')
        oMark:SetOwner(oDialog)
        oMark:IsInvert(.T.)
        oMark:SetSemaphore(.T.)
        oMark:SetDescription("Devoluções")
        oMark:SetOnlyFields({"Z7_Exempla"})
        oMark:SetFilterDefault(cFiltro)

    oMark:Activate()

Return NIL


/* {Protheus.doc} MenuDef ======================================================
|| @MenuDef: Função utilizada para criar as opções de menu
|| @Author : Fabrício Santos
|| @Since  : 16/04/2024
|| @Version: 1.0
================================================================================*/
Static Function MenuDef()
    Local aRotina := {}
     
    //Criação das opções
    ADD OPTION aRotina TITLE 'Devolver'  ACTION 'u_DEV' OPERATION 4 ACCESS 0

Return aRotina

/* {Protheus.doc} Devolver Livros ===============================================
|| @MenuDef: Função utilizada para devolver livros
|| @Author : Fabrício Santos
|| @Since  : 16/04/2024
|| @Version: 1.0
================================================================================*/

User Function DEV()

Local aArea  := GetArea()
Local cMarca := oMark:Mark()
Local nDev   := 0

SZ7->( dbGoTop() )

	While !SZ7->( EOF() )
		
        If oMark:IsMark(cMarca)
                DBSETORDER(2)
                DBSEEK(SZ7->Z7_EXEMPLA)
                RECLOCK('SZ7',.F.)
                    SZ7->Z7_DEVREAL := dDataBase
                SZ7->(MSUNLOCK())

                DBSELECTAREA('SZ5')
                DBSETORDER(2)
                DBSEEK(SZ7->Z7_EXEMPLA)
                RECLOCK('SZ5',.F.)
                SZ5->Z5_EMPREST  := 'N'
                SZ5->(MSUNLOCK())

		EndIf
        
	SZ7->( dbSkip() )
    End
	
    ApMsgInfo( 'Livros selecionados foram devolvidos' )


//Verifica se algum livro precisa ser devolvido

SZ7->( dbGoTop() )
While !SZ7->( EOF() )

IF SZ7->Z7_PROTOCO == cCodProtocol .and. Empty(SZ7->Z7_DEVREAL)
nDev++

EndIf
SZ7->( dbSkip() )

End

ApMsgInfo( AllTrim( Str( nDev ) ) + ' Livros presisam ser devolvidos  ' )

// Da baixa no protocolo caso todos os livros tenham sido devolvidos
if nDev == 0

DBSELECTAREA('SZ6')
DBSETORDER(1)
DBSEEK(cCodProtocol)
RECLOCK('SZ6',.F.)
SZ6->Z6_STATUS  := 'D'
SZ6->(MSUNLOCK())

EndIf

RestArea( aArea )

Return NIL
