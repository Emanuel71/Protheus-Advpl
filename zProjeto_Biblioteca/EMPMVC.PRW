#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"

/* {Protheus.doc} Emprestimos =============================
@Função : Rotina para Efetuar Emprestimo dos livros
@Author : Fabrício Santos
@Since  : 16/04/2024
@Version: 1.0
======================================================*/

User Function EMPMVC()
local oBrowse
Local aTable:= {}

// Adiciona a tabelas que devem ser verificados
AADD(aTable, "SZ6")
AADD(aTable, "SZ7")

// Faz a validações se as tabelas existem

if !AvExisteTab(aTable)
    FWalertError("Tabelas não foram encontradas na base", "Contate o suporte")
    BREAK
Endif

//Criação do objeto do tipo Browse
oBrowse := FwmBrowse():NEW

//Definir qual a tabela que será apresentada no Browse
oBrowse:SetAlias('SZ6')

//Definir o título ou a descrição que será apresentado no Browse
oBrowse:SetDescription("Emprestimos")

/*======================================================
|| GREEN : Para a cor Verde
|| RED   : Para a cor Vermelha
|| YELLOW: Para a cor Amarela
|| ORANGE: Para a cor Laranja
|| BLUE  : Para a cor Azul
|| GRAY  : Para a cor Cinza
|| BROWN : Para a cor Marrom
|| BLACK : Para a cor Preta
|| PINK  : Para a cor Rosa
|| WHITE : Para a cor Branca
======================================================*/
// Adicionando legendas
oBrowse:AddLegend("Z6_STATUS=='E'","GREEN","LIVRO EMPRESTADO")
oBrowse:AddLegend("Z6_STATUS=='D'","RED","LIVRO DEVOLVIDO")

//Chamar Menu
oBrowse:SetMenuDef('EMPMVC')

//Realiza a ativação do Browse
oBrowse:Activate()

RETURN

/* {Protheus.doc} MenuDef ======================================================
|| @MenuDef: Função utilizada para criar as opções de menu
|| @Author : Fabrício Santos
|| @Since  : 16/04/2024
|| @Version: 1.0
================================================================================
|| @Retorno : aRotina no pabrão a seguir:
|| Conluna 1: Títulos a ser exibido no botão do browse
|| Conluna 2: Nome da função que será executada quando o usuario clicar no Botão
|| Conluna 3: Reservado
|| Conluna 4: Número da Operação
|| Conluna 5: Reservado
===============================================================================*/
Static Function MenuDef()
    Local aRotina := {}

    //=============================================================================================================
    //O ViewDef deve ser referenciado sempre de um fonte, pois ele é a função reponável pela interface da aplicação
    //=============================================================================================================
    AADD(aRotina, {"Pesquisar"         , 'PesqBrw'             , 0, 1, 0, Nil })
    AADD(aRotina, {"Visualizar"        , 'VIEWDEF.EMPMVC'      , 0, 2, 0, Nil })
    AADD(aRotina, {"Incluir"           , 'VIEWDEF.EMPMVC'      , 0, 3, 0, Nil })
    AADD(aRotina, {"Devolver Livros"   , 'U_FWMARK'            , 0, 4, 0, Nil })
    AADD(aRotina, {"Excluir"           , 'VIEWDEF.EMPMVC'      , 0, 5, 0, Nil })
    
Return aRotina

/* {Protheus.doc} ModelDef ======================================================
|| @MenuDef: Função utilizada para criar o modelo de dados
|| @Author : Fabricio Santos
|| @Since  : 16/04/2024
|| @Version: 1.0
================================================================================*/
Static Function ModelDef()

//bloco de codigo para validação
Local bVLdPos:={||u_VLPos()}

//bloco de codigo para validação da linha
Local bLinOK:={|oGridModel|vldLinOK(oGridModel)}

//Declaração de variaveis para construção do modelo
Local oModel    // Objeto do modelo de dados
Local oStruSZ6  // Objeto da estrutura de dados
Local oStruSZ7  // Objeto da estrutura de dados

//Cria o objeto do modelo de dados
oModel := MPFormModel():New('EMP',,bVLdPos)

//Cria a estrutura que será utilizada no modelo
oStruSZ6 := FWFormStruct(1,"SZ6") //1-Para modelo de dados (Model) e 2-para View
oStruSZ7 := FWFormStruct(1,"SZ7")

//Cria campos obrigatorios
oStruSZ6:SetProperty( 'Z6_PROTOCO' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ6:SetProperty( 'Z6_USUARIO' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ6:SetProperty( 'Z6_DATA'    , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ6:SetProperty( 'Z6_STATUS'  , MODEL_FIELD_OBRIGAT, .T.)

// Cria o Cabeçalho da Tela de Cadastro
oModel:AddFields('SZ6_TOPO', /*OWNER*/ ,oStruSZ6)
oModel:GetModel('SZ6_TOPO'):SetPrimaryKey({'Z6_Protoco'})

// Cria Grid
oModel:AddGrid('SZ7_GRID','SZ6_TOPO',oStruSZ7, bLinOK)
oModel:GetModel('SZ7_GRID'):Setoptional(.F.)

// Relacionamento entre entidade Pai e Filho
oModel:SetRelation('SZ7_GRID',{{"Z7_Filial","xFilial('SZ7')"} , {"Z7_Protoco","Z6_Protoco"}})
oModel:GetModel("SZ7_GRID"):SetUniqueLine({'Z7_EXEMPLA'})

// Limita a quantidade de linhas
oModel:GetModel("SZ7_GRID"):SetMaxLine(5)

// Define a Descrição
oModel:SetDescription("Controle de Emprestimos")
oModel:GetModel("SZ6_TOPO"):SetDescription('Informações do Cliente')
oModel:GetModel("SZ7_GRID"):SetDescription('Detalhes do Emprestimo')

Return oModel

/* {Protheus.doc} ViewDef ======================================================
|| @ViewDef: Função utilizada para criar a interface
|| @Author : Fabricio Santos
|| @Since  : 16/04/2024
|| @Version: 1.0
================================================================================*/

Static Function ViewDef()
Local oView    :=Nil     // Objeto de view
Local oModel   := FwLoadModel('EMPMVC') //Cria o objeto do modelo de dados com base no ModelDef do fonte informado
Local oStruSZ6 := FWFormStruct(2,"SZ6") //Cria a estrutura do view Cabeçalho
Local oStruSZ7 := FWFormStruct(2,"SZ7")// Cria a estrutura do view GRID

//Cria o objeto de view
oView :=FwFormView():New()

//Define qual é o modelo de dados que será utilizado na View
oView:SetModel(oModel)

//Adiciona no View um componente do tipo formulário (enchoice), vinculando o formulário da view com o formulário do modelo
oView:AddField('VIEW_SZ6',oStruSZ6,'SZ6_TOPO')

//Adiciona no View um componente do tipo Grid, vinculando o formulário da view
oView:AddGrid('VIEW_SZ7',oStruSZ7,'SZ7_GRID')

//Cria um box horizontal para receber o elemento da View
oView:CreateHorizontalBox("CABEC", 50)
oView:CreateHorizontalBox("GRID", 50)

// Relaciona o box com a view criada para apresentação
oView:SetOwnerView('VIEW_SZ6' , 'CABEC')
oView:SetOwnerView('VIEW_SZ7' , 'GRID')

// Remove o campo Filial
oStruSZ7:RemoveField("Z7_FILIAL")
oStruSZ7:RemoveField("Z7_MARK")
oStruSZ7:RemoveField("Z7_PROTOCO")
oStruSZ6:RemoveField("Z6_FILIAL")

// Cria o Título
oView:EnableTitle('VIEW_SZ6' , "Informações do Cliente")
oView:EnableTitle('VIEW_SZ7' , "Detalhes do Emprestimo")

// Cria  campo número do Item
oView:AddIncrementalField('VIEW_SZ7','Z7_ITEM')

// Ordena o campo item
oStruSZ7:SetProperty('Z7_ITEM', MVC_VIEW_ORDEM, '01')

// Retorna o objeto view criado pela função
Return oView

// Valida Se o Exemplar Está Emprestado
Static Function vldLinOK(oGridModel)
Local cValue := oGridModel:GetValue('Z7_EXEMPLA')
Local aArea  := GetArea()
Local lRet   := .T.

DBSELECTAREA('SZ5')
    DBSETORDER(1)
    // Avisa que o exemplar está emprestado
    If cValue == SZ5->Z5_CODIGO .and. SZ5->Z5_EMPREST == 'S' 
        lRet := .F.
        Help(Nil,Nil, "Help",Nil, "Este livro está alugado",1,0,Nil,Nil,Nil,Nil,Nil,{"Selecione Outro Exemplar"})
    Endif    

RestArea( aArea )
Return lRet

// Valida Se o Exemplar Está Emprestado

User Function VLPos()
Local oModelPad:= FWModelActive()
Local oModelGrid:= oModelPad:GetModel('SZ7_GRID')
Local aArea  := GetArea()
Local cValue
local nLinha
Local lRet   := .T.


// Acessa a tabela SZ5
For nLinha := 1 To oModelGrid:Length()
oModelGrid:GoLine(nLinha)
cValue := oModelPad:GetValue('SZ7_GRID','Z7_EXEMPLA')

    DBSELECTAREA('SZ5')
        DBSETORDER(2)
    DBSEEK(cValue)
    // Altera o Exemplar para emprestado
  if cValue==SZ5->Z5_CODIGO .and. SZ5->Z5_EMPREST=='N'
    RECLOCK('SZ5',.F.)
        SZ5->Z5_EMPREST:='S'
    SZ5->(MSUNLOCK())
    Endif
next
RestArea( aArea )

Return lRet
