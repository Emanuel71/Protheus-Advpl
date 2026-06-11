#Include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/* {Protheus.doc} Acervo =============================
@Função : Rotina de cadastro de acervo
@Author : Fabrício Santos
@Since  : 16/04/2024
@Version: 1.0
======================================================*/

User Function ACVMVC()
local oBrowse
Local aTable:= {}

// Adiciona a tabelas que devem ser verificados
AADD(aTable, "SZ4")
AADD(aTable, "SZ5")

// Faz a validações se as tabelas existem

if AvExisteTab(aTable)
    FWAlertSuccess("Todas as tabelas diponiveis na base","Pode Prosseguir")
else
    FWalertError("Tabelas não foram encontradas na base", "Contate o suporte")
    BREAK
Endif

//Criação do objeto do tipo Browse
oBrowse := FwmBrowse():NEW

//Definir qual a tabela que será apresentada no Browse
oBrowse:SetAlias('SZ4')

//Definir o título ou a descrição que será apresentado no Browse
oBrowse:SetDescription("Acervo")

//Chamar Menu
oBrowse:SetMenuDef('ACVMVC')

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
    AADD(aRotina, {"Pesquisar" , 'PesqBrw'           , 0, 1, 0, Nil })
    AADD(aRotina, {"Visualizar", 'VIEWDEF.ACVMVC'    , 0, 2, 0, Nil })
    AADD(aRotina, {"Incluir"   , 'VIEWDEF.ACVMVC'    , 0, 3, 0, Nil })
    AADD(aRotina, {"Alterar"   , 'VIEWDEF.ACVMVC'    , 0, 4, 0, Nil })
    AADD(aRotina, {"Excluir"   , 'VIEWDEF.ACVMVC'    , 0, 5, 0, Nil })
    
Return aRotina

/* {Protheus.doc} ModelDef ======================================================
|| @MenuDef: Função utilizada para criar o modelo de dados
|| @Author : Fabricio Santos
|| @Since  : 16/04/2024
|| @Version: 1.0
================================================================================*/
Static Function ModelDef()
Local oModel    // Objeto do modelo de dados
Local oStruSZ4  // Objeto da estrutura de dados
Local oStruSZ5  // Objeto da estrutura de dados

//Cria o objeto do modelo de dados
oModel := MPFormModel():New('ACMVC')

//Cria a estrutura que será utilizada no modelo
oStruSZ4 := FWFormStruct(1,"SZ4") //1-Para modelo de dados (Model) e 2-para View
oStruSZ5 := FWFormStruct(1,"SZ5")

// Cria campos obrigatorios
oStruSZ4:SetProperty( 'Z4_CODIGO' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ4:SetProperty( 'Z4_TIPO' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ4:SetProperty( 'Z4_TITULO' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ4:SetProperty( 'Z4_AUTOR' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ4:SetProperty( 'Z4_PAGINAS' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ4:SetProperty( 'Z4_DEVPREV' , MODEL_FIELD_OBRIGAT, .T.)

// Cria o Cabeçalho da Tela de Cadastro
oModel:AddFields('SZ4_TOPO', /*OWNER*/ ,oStruSZ4)
oModel:GetModel('SZ4_TOPO'):SetPrimaryKey({'Z4_Codigo'})

// Cria Grid
oModel:AddGrid('SZ5_GRID','SZ4_TOPO',oStruSZ5)
oModel:GetModel('SZ5_GRID'):Setoptional(.F.)

// Relacionamento entre entidade Pai e Filho
oModel:SetRelation('SZ5_GRID',{{"Z5_Filial","xFilial('SZ5')"} , {"Z5_ACERVO","Z4_CODIGO"}}, SZ5->(IndexKey(1)) )
oModel:GetModel("SZ5_GRID"):SetUniqueLine({'Z5_CODIGO'})

// Define a Descrição
oModel:SetDescription("Controle de Acervo")
oModel:GetModel("SZ4_TOPO"):SetDescription('Informações do Acervo')
oModel:GetModel("SZ5_GRID"):SetDescription('Detalhes do Acervo')

Return oModel

/* {Protheus.doc} ViewDef ======================================================
|| @ViewDef: Função utilizada para criar a interface
|| @Author : Fabricio Santos
|| @Since  : 16/04/2024
|| @Version: 1.0
================================================================================*/

Static Function ViewDef()
Local oView    :=Nil     // Objeto de view
Local oModel   := FwLoadModel('ACVMVC') //Cria o objeto do modelo de dados com base no ModelDef do fonte informado
Local oStruSZ4 := FWFormStruct(2,"SZ4") //Cria a estrutura do view Cabeçalho
Local oStruSZ5 := FWFormStruct(2,"SZ5")// Cria a estrutura do view GRID

//Cria o objeto de view
oView :=FwFormView():New()

//Define qual é o modelo de dados que será utilizado na View
oView:SetModel(oModel)

//Adiciona no View um componente do tipo formulário (enchoice), vinculando o formulário da view com o formulário do modelo
oView:AddField('VIEW_SZ4',oStruSZ4,'SZ4_TOPO')

//Adiciona no View um componente do tipo Grid, vinculando o formulário da view
oView:AddGrid('VIEW_SZ5',oStruSZ5,'SZ5_GRID')

//Cria um box horizontal para receber o elemento da View
oView:CreateHorizontalBox("CABEC", 70)
oView:CreateHorizontalBox("GRID", 30)

// Relaciona o box com a view criada para apresentação
oView:SetOwnerView('VIEW_SZ4' , 'CABEC')
oView:SetOwnerView('VIEW_SZ5' , 'GRID')

// Remove o campo Filial
oStruSZ4:RemoveField("Z4_FILIAL")
oStruSZ5:RemoveField("Z5_FILIAL")

// Cria o Título
oView:EnableTitle('VIEW_SZ4' , "Informações do Livro")
oView:EnableTitle('VIEW_SZ5' , "Informações do Exemplar")

// Retorna o objeto view criado pela função
Return oView
