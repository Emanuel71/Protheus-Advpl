#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"  // Biblioteca com recursos para contrução de fontes MVC

/* {Protheus.doc} Autores =============================
@Função : Rotina de cadastro de autores
@Author : Fabrício Santos
@Since  : 19/07/2024 
@Version: 1.0
======================================================*/

User Function zAutMV()
    local oBrowse

    //Criação do objeto do tipo Browse
    oBrowse := FwmBrowse():NEW

    //Definir qual a tabela que será apresentada no Browse
    oBrowse:SetAlias('SZ2')

    //Definir o título ou a descrição que será apresentado no Browse
    oBrowse:SetDescription("Cadastro de Autores")

    // Cria um filtro para o Browse
    oBrowse:SetFilterDefault("!Empty(Z2_TIPO)")

    // Desabilitar o detalhes do registro
    oBrowse:DisableDetails()

    //Chamar Menu
    oBrowse:SetMenuDef('zAutMV')

    //Realiza a ativação do Browse
    oBrowse:Activate()

RETURN

/* {Protheus.doc} MenuDef ======================================================
|| @MenuDef: Função utilizada para criar as opções de menu
|| @Author : Fabrício Santos
|| @Since  : 19/07/2024
|| @Version: 1.0
================================================================================
|| @Retorno : aRotina no pabrão a seguir:
|| Conluna 1: Títulos a ser exibido no botão do browse
|| Conluna 2: Nome da função que será executada quando o usuario clicar no Botão
|| Conluna 3: Reservado
|| Conluna 4: Número da Operação (1 para Pesquisar, 2 para Visualizar, 3 para Incluir, 4 para Alterar, 5 para Excluir)
|| Conluna 5: Reservado
===============================================================================*/
Static Function MenuDef()
    Local aRotina := {}

    //=============================================================================================================
    //O ViewDef deve ser referenciado sempre de um fonte, pois ele é a função reponável pela interface da aplicação
    //=============================================================================================================
    AADD(aRotina, {"Pesquisar" , 'PesqBrw'           , 0, 1, 0, Nil })
    AADD(aRotina, {"Visualizar", 'VIEWDEF.zAutMV', 0, 2, 0, Nil })
    AADD(aRotina, {"Incluir"   , 'VIEWDEF.zAutMV', 0, 3, 0, Nil })
    AADD(aRotina, {"Alterar"   , 'VIEWDEF.zAutMV', 0, 4, 0, Nil })
    AADD(aRotina, {"Excluir"   , 'VIEWDEF.zAutMV', 0, 5, 0, Nil })
    

Return aRotina

/* {Protheus.doc} ModelDef ======================================================
|| @MenuDef: Função utilizada para criar o modelo de dados
|| @Author : Fabrício Santos
|| @Since  : 19/07/2024
|| @Version: 1.0
================================================================================*/
Static Function ModelDef()
    Local oModel    // Objeto do modelo de dados
    Local oStruSZ2  // Objeto da estrutura de dados

    //Cria o objeto do modelo de dados
    oModel := MPFormModel():New('zAutMV')

    //Cria a estrutura que será utilizada no modelo
    oStruSZ2 := FWFormStruct(1,"SZ2") //1-Para modelo de dados (Model) e 2-para View

    //Adiciona ao modelo um componete do tipo formulario
    oModel:AddFields('SZ2MASTER', /*OWNER*/ ,oStruSZ2)

    //Define a decrição para o modelo (Model)
    oModel:SetDescription("Modelo de Dados - Cadastro de Autores")

    //Define a descrição do componente fomulario
    oModel:GetModel('SZ2MASTER'):SetDescription('Dados dos Autores')

    //Define a PrimaryKey do Modelo
    oModel:setPrimaryKey({'Z2_FILIAL'})

    // Retorna o objeto model criado pela função
    Return oModel

/* {Protheus.doc} ViewDef ======================================================
|| @ViewDef: Função utilizada para criar a interface
|| @Author : Fabrício Santos
|| @Since  : 19/07/2024
|| @Version: 1.0
================================================================================*/ 
Static Function ViewDef()
    Local oModel    // Objeto do modelo de dados
    Local oStruSZ2  // Objeto da estrutura de dados
    Local oView     // Objeto de view

    //Cria o objeto do modelo de dados com base no ModelDef do fonte informado
    oModel := FwLoadModel('zAutMV')

    //Cria a estrutura do view
    oStruSZ2 := FWFormStruct(2,"SZ2")  //Tipo de estrutura: 1-Para modelo de dados (Model) e 2-para View {SZ2 = tabela do banco de dados que vai compor a estrutura}

    //Cria o objeto de view
    oView :=FwFormView():New()

    //Define qual é o modelo de dados que será utilizado na View
    oView:SetModel(oModel)

    //Adiciona no View um componente do tipo formulário (enchoice), vinculando o formulário da view com o formulario do modelo
    oView:AddField('VIEW_SZ2',oStruSZ2,'SZ2MASTER')

    //Cria um box horizontal para receber o elemento da View
    oView:CreateHorizontalBox("FORMULARIO", 100)

    // Relaciona o box com a view criada para apresentação
    oView:SetOwnerView('VIEW_SZ2' , 'FORMULARIO')

    // Retorna o objeto view criado pela função
    Return oView
