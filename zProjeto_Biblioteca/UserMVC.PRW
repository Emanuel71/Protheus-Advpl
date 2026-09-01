#Include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/* {Protheus.doc} Usuarios =============================
@Função : Rotina de cadastro de Usuarios
@Author : Fabri­cio Santos
@Since  : 28/02/2024
@Version: 1.0
======================================================*/

User Function UserMVC()
local oBrowse
Local aTable:= {}

// Adiciona a tabelas que devem ser verificados
AADD(aTable, "SZ1")

// Faz a validação se as tabelas existem
if !AvExisteTab(aTable)
    FWAlertError("Tabelas não foram encontradas na base", "Contate o suporte")
    Break
Endif

//Criação do objeto do tipo Browse
oBrowse := FwmBrowse():NEW

//Definir qual a tabela que será apresentada no Browse
oBrowse:SetAlias('SZ1')

//Definir o titulo ou a descrição que será apresentado no Browse
oBrowse:SetDescription("Cadastro de Usuarios")

//Chamar Menu
oBrowse:SetMenuDef('UserMVC')

//Realiza a ativação do Browse
oBrowse:Activate()

RETURN

/* {Protheus.doc} MenuDef ======================================================
|| @MenuDef: Função utilizada para criar as opções de menu
|| @Author : Fabricio Santos
|| @Since  : 28/02/2024
|| @Version: 1.0
================================================================================*/
Static Function MenuDef()
    Local aRotina := {}

    //=============================================================================================================
    //O ViewDef deve ser referenciado sempre de um fonte, pois ele é a função reponável pela interface da aplicação
    //=============================================================================================================
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.UserMVC' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.UserMVC' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.UserMVC' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.UserMVC' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRotina

/* {Protheus.doc} ModelDef ======================================================
|| @MenuDef: Função utilizada para criar o modelo de dados
|| @Author : Fabricio Santos
|| @Since  : 28/02/2024
|| @Version: 1.0
================================================================================*/
Static Function ModelDef()
Local oModel    // Objeto do modelo de dados
Local oStruSZ1  // Objeto da estrutura de dados

//Cria o objeto do modelo de dados
oModel := MPFormModel():New('UserMVCM')

//Cria a estrutura que será utilizada no modelo
oStruSZ1 := FWFormStruct(1,"SZ1") //1-Para modelo de dados (Model) e 2-para View

// Cria campos obrigatorios
oStruSZ1:SetProperty( 'Z1_CPF' , MODEL_FIELD_OBRIGAT, .F.)
oStruSZ1:SetProperty( 'Z1_TIPODOC' , MODEL_FIELD_OBRIGAT, .T.)
oStruSZ1:SetProperty( 'Z1_DOC' , MODEL_FIELD_OBRIGAT, .T.)

//Adiciona ao modelo um componete do tipo formulario
oModel:AddFields('SZ1MASTER', /*OWNER*/ ,oStruSZ1)

//Define a decrição para o modelo (Model)
oModel:SetDescription("Modelo de Dados - Cadastro de Úsuarios")

//Define a descrição do componente fomulario
oModel:GetModel('SZ1MASTER'):SetDescription('Informações dos Úsuarios')

//Define a PrimaryKey do Modelo
oModel:setPrimaryKey({'Z1_Filial','Z1_CODIGO'})

// Retorna o objeto model criado pela função
Return oModel

/* {Protheus.doc} ViewDef ======================================================
|| @ViewDef: Função utilizada para criar a interface
|| @Author : Fabricio Santos
|| @Since  : 28/02/2024
|| @Version: 1.0
================================================================================*/
Static Function ViewDef()
Local oModel    // Objeto do modelo de dados
Local oStruSZ1  // Objeto da estrutura de dados
Local oView     // Objeto de view

//Cria o objeto do modelo de dados com base no ModelDef do fonte informado
oModel := FwLoadModel('UserMVC')

//Cria a estrutura do view
oStruSZ1 := FWFormStruct(2,"SZ1")  //Tipo de estrutura: 1-Para modelo de dados (Model) e 2-para View {SZ1 = tabela do banco de dados que vai compor a estrutura}

//Altera a ordem dos campos
oStruSZ1:SetProperty( 'Z1_CODIGO' ,  MVC_VIEW_ORDEM ,  '01')
oStruSZ1:SetProperty( 'Z1_NOME' ,  MVC_VIEW_ORDEM ,    '02') 
oStruSZ1:SetProperty( 'Z1_GENERO' ,  MVC_VIEW_ORDEM ,  '03') 
oStruSZ1:SetProperty( 'Z1_NASCIME' ,  MVC_VIEW_ORDEM , '04') 
oStruSZ1:SetProperty( 'Z1_TIPODOC' ,  MVC_VIEW_ORDEM , '05') 
oStruSZ1:SetProperty( 'Z1_DOC' ,  MVC_VIEW_ORDEM ,     '06') 
oStruSZ1:SetProperty( 'Z1_CPF' ,  MVC_VIEW_ORDEM ,     '07') 
oStruSZ1:SetProperty( 'Z1_DDDFIXO' ,  MVC_VIEW_ORDEM , '08') 
oStruSZ1:SetProperty( 'Z1_FIXO' ,  MVC_VIEW_ORDEM ,    '09') 
oStruSZ1:SetProperty( 'Z1_DDDCEL' ,  MVC_VIEW_ORDEM ,  '10') 
oStruSZ1:SetProperty( 'Z1_CELULAR' ,  MVC_VIEW_ORDEM , '11') 
oStruSZ1:SetProperty( 'Z1_EMAIL' ,  MVC_VIEW_ORDEM ,   '12') 
oStruSZ1:SetProperty( 'Z1_LOGRADO' ,  MVC_VIEW_ORDEM , '13') 
oStruSZ1:SetProperty( 'Z1_NUMERO' ,  MVC_VIEW_ORDEM ,  '14') 
oStruSZ1:SetProperty( 'Z1_COMPLE' ,  MVC_VIEW_ORDEM ,  '15') 
oStruSZ1:SetProperty( 'Z1_BAIRRO' ,  MVC_VIEW_ORDEM ,  '16') 
oStruSZ1:SetProperty( 'Z1_MUNICIP' ,  MVC_VIEW_ORDEM , '17') 
oStruSZ1:SetProperty( 'Z1_UF' ,  MVC_VIEW_ORDEM ,      '18') 
oStruSZ1:SetProperty( 'Z1_CEP' ,  MVC_VIEW_ORDEM ,     '19')

//Cria o objeto de view
oView :=FwFormView():New()

//Define qual é o modelo de dados que será utilizado na View
oView:SetModel(oModel)

//Adiciona no View um componente do tipo formulário (enchoice), vinculando o formulário da view com o formulario do modelo
oView:AddField('VIEW_SZ1',oStruSZ1,'SZ1MASTER')

//Cria um box horizontal para receber o elemento da View
oView:CreateHorizontalBox("FORMULARIO", 100)

// Relaciona o box com a view criada para apresentação
oView:SetOwnerView('VIEW_SZ1' , 'FORMULARIO')

// Retorna o objeto view criado pela função
Return oView
