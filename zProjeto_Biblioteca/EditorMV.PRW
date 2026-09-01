#Include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/* {Protheus.doc} Editores =============================
@Function : Rotina de cadastro de Editores
@Author : Fabrício Santos
@Since  : 27/03/2024
@Version: 1.0
======================================================*/

User Function EditorMV()
local oBrowse
Local aTable:= {}

// Adiciona a tabelas que devem ser verificados
AADD(aTable, "SZ3")

// Faz a validações se as tabelas existem
// ! - faz a negação da ação
if !AvExisteTab(aTable)
    FWalertError("Tabelas não foram encontradas na base", "Contate o suporte")
    BREAK
Endif

//Criação do objeto do tipo Browse
oBrowse := FwmBrowse():NEW

//Definir qual a tabela que será apresentada no Browse
oBrowse:SetAlias('SZ3')

//Definir o titulo ou a descrição que será apresentado no Browse
oBrowse:SetDescription("Cadastro de Editoras")

//Chamar Menu
oBrowse:SetMenuDef('EditorMV')

//Realiza a Ativação do Browse
oBrowse:Activate()

RETURN

/* {Protheus.doc} MenuDef ======================================================
|| @MenuDef: Função utilizada para criar as opções de menu
|| @Author : Fabricio Santos
|| @Since  : 27/03/2024
|| @Version: 1.0
================================================================================*/
Static Function MenuDef()
    Local aRotina := {}

    //=============================================================================================================
    //O ViewDef deve ser referenciado sempre de um fonte, pois ele é a função reponável pela interface da aplicação
    //=============================================================================================================
    AADD(aRotina, {"Pesquisar" , 'PesqBrw'          , 0, 1, 0, Nil })
    AADD(aRotina, {"Visualizar", 'VIEWDEF.EditorMV', 0, 2, 0, Nil })
    AADD(aRotina, {"Incluir"   , 'VIEWDEF.EditorMV', 0, 3, 0, Nil })
    AADD(aRotina, {"Alterar"   , 'VIEWDEF.EditorMV', 0, 4, 0, Nil })
    AADD(aRotina, {"Excluir"   , 'VIEWDEF.EditorMV', 0, 5, 0, Nil })
    

Return aRotina

/* {Protheus.doc} ModelDef ======================================================
|| @MenuDef: Função utilizada para criar o modelo de dados
|| @Author : Fabricio Santos
|| @Since  : 27/03/2024
|| @Version: 1.0
================================================================================*/
Static Function ModelDef()
Local oModel    // Objeto do modelo de dados
Local oStruSZ3  // Objeto da estrutura de dados

//Cria o objeto do modelo de dados
oModel := MPFormModel():New('EditMVCM')

//Cria a estrutura que será utilizada no modelo
oStruSZ3 := FWFormStruct(1,"SZ3") //1-Para modelo de dados (Model) e 2-para View

// Cria campos obrigatorios
oStruSZ3:SetProperty( 'Z3_NOME' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ3:SetProperty( 'Z3_CNPJ' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ3:SetProperty( 'Z3_LOGRADO' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ3:SetProperty( 'Z3_MUNICIP' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ3:SetProperty( 'Z3_CEP' , MODEL_FIELD_OBRIGAT, .T.)

//Adiciona ao modelo um componete do tipo formulario
oModel:AddFields('SZ3MASTER', /*OWNER*/ ,oStruSZ3)

//Define a decrição para o modelo (Model)
oModel:SetDescription("Modelo de Dados - Cadastro de Editoras")

//Define a descrição do componente fomulario
oModel:GetModel('SZ3MASTER'):SetDescription('Informações das Editoras')

//Define a PrimaryKey do Modelo
oModel:setPrimaryKey({'Z3_Filial','Z3_CODIGO'})

// Retorna o objeto model criado pela função
Return oModel

/* {Protheus.doc} ViewDef ======================================================
|| @ViewDef: Função utilizada para criar a interface
|| @Author : Fabricio Santos
|| @Since  : 27/03/2024
|| @Version: 1.0
================================================================================*/
Static Function ViewDef()
Local oModel    // Objeto do modelo de dados
Local oStruSZ3  // Objeto da estrutura de dados
Local oView     // Objeto de view

//Cria o objeto do modelo de dados com base no ModelDef do fonte informado
oModel := FwLoadModel('EditorMV')

//Cria a estrutura do view
oStruSZ3 := FWFormStruct(2,"SZ3")  //Tipo de estrutura: 1-Para modelo de dados (Model) e 2-para View {SZ3 = tabela do banco de dados que vai compor a estrutura}

//Define a Ordem dos Campos
oStruSZ3:SetProperty( 'Z3_CODIGO' ,  MVC_VIEW_ORDEM ,  '01' )

// Altera o Título do campo
oStruSZ3:SetProperty( 'Z3_NOME' , MVC_VIEW_TITULO, 'Razão Social')

// Remove o campo Filial
oStruSZ3:RemoveField("Z3_FILIAL")

//Cria o objeto de view
oView :=FwFormView():New()

//Define qual é o modelo de dados que será utilizado na View
oView:SetModel(oModel)

//Adiciona no View um componente do tipo formulário (enchoice), vinculando o formulário da view com o formulário do modelo
oView:AddField('VIEW_SZ3',oStruSZ3,'SZ3MASTER')

//Cria um box horizontal para receber o elemento da View
oView:CreateHorizontalBox("FORMULARIO", 100)

// Relaciona o box com a view criada para apresentação
oView:SetOwnerView('VIEW_SZ3' , 'FORMULARIO')

// Retorna o objeto view criado pela função
Return oView
