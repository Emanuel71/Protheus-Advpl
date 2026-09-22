#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"  // Biblioteca com recursos para construção de fontes MVC

/* {Protheus.doc} Autores =============================
@Função : Rotina de cadastro de autores
@Author : Fabrício Santos
@Since  : 19/07/2024 
@Version: 1.1 - 10/09/2026 - Correção: ModelDef sem ID (erro "parâmetro cID, previsto C->U")
======================================================*/

User Function zAutMV()
    Local oBrowse

    //Criação do objeto do tipo Browse
    oBrowse := FwmBrowse():New()

    //Definir qual a tabela que será apresentada no Browse
    oBrowse:SetAlias('SZ2')

    //Definir o título ou a descrição que será apresentado no Browse
    oBrowse:SetDescription("Cadastro de Autores")

    //---------------------------------------------------------------------------------
    // ATENÇÃO: o filtro abaixo ESCONDE do browse todo autor que estiver com Z2_TIPO
    // em branco. Os registros incluídos pelo APSDU estão com Z2_TIPO vazio, por isso
    // eles "somem" da tela. Deixei comentado; se quiser o filtro de volta, basta
    // descomentar (e garantir que Z2_TIPO seja obrigatório no SX3 ou preenchido).
    //---------------------------------------------------------------------------------
    //oBrowse:SetFilterDefault("!Empty(Z2_TIPO)")

    // Desabilitar o detalhes do registro
    oBrowse:DisableDetails()

    //Chamar Menu
    oBrowse:SetMenuDef('zAutMV')

    //Realiza a ativação do Browse
    oBrowse:Activate()

Return

/* {Protheus.doc} MenuDef ======================================================
|| @MenuDef: Função utilizada para criar as opções de menu
|| @Author : Fabrício Santos
|| @Since  : 19/07/2024
|| @Version: 1.0
================================================================================
|| @Retorno : aRotina no padrão a seguir:
|| Coluna 1: Título a ser exibido no botão do browse
|| Coluna 2: Nome da função que será executada quando o usuário clicar no botão
|| Coluna 3: Reservado
|| Coluna 4: Número da Operação (1 Pesquisar, 2 Visualizar, 3 Incluir, 4 Alterar, 5 Excluir)
|| Coluna 5: Reservado
===============================================================================*/
Static Function MenuDef()
    Local aRotina := {}

    //=============================================================================================================
    //O ViewDef deve ser referenciado sempre de um fonte, pois ele é a função responsável pela interface da aplicação
    //=============================================================================================================
    AADD(aRotina, {"Pesquisar" , 'PesqBrw'       , 0, 1, 0, Nil })
    AADD(aRotina, {"Visualizar", 'VIEWDEF.zAutMV', 0, 2, 0, Nil })
    AADD(aRotina, {"Incluir"   , 'VIEWDEF.zAutMV', 0, 3, 0, Nil })
    AADD(aRotina, {"Alterar"   , 'VIEWDEF.zAutMV', 0, 4, 0, Nil })
    AADD(aRotina, {"Excluir"   , 'VIEWDEF.zAutMV', 0, 5, 0, Nil })

Return aRotina

/* {Protheus.doc} ModelDef ======================================================
|| @ModelDef: Função utilizada para criar o modelo de dados
|| @Author : Fabrício Santos
|| @Since  : 19/07/2024
|| @Version: 1.1
================================================================================*/
Static Function ModelDef()
    Local oModel    // Objeto do modelo de dados
    Local oStruSZ2  // Objeto da estrutura de dados

    //---------------------------------------------------------------------------------
    // CORREÇÃO PRINCIPAL:
    // O 1º parâmetro do New() é o ID do modelo (texto, tipo "C") e é OBRIGATÓRIO.
    // Antes estava New() vazio -> o framework recebia NIL (tipo "U") e estourava:
    //   "argumento #0, parâmetro cID erro, previsto C->U on FWFORMMODEL:NEW"
    // Por convenção, usa-se o mesmo nome do fonte.
    //---------------------------------------------------------------------------------
    oModel := MPFormModel():New("zAutMVM", /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

    //Cria a estrutura que será utilizada no modelo (1 = Model, 2 = View)
    oStruSZ2 := FWFormStruct(1, "SZ2")

    //Adiciona ao modelo um componente do tipo formulário (cabeçalho, sem pai)
    oModel:AddFields('SZ2MASTER', /*cOwner*/, oStruSZ2)

    //Define a descrição para o modelo (Model)
    oModel:SetDescription("Modelo de Dados - Cadastro de Autores")

    //Define a descrição do componente formulário
    oModel:GetModel('SZ2MASTER'):SetDescription('Dados dos Autores')

    //---------------------------------------------------------------------------------
    // Chave primária: precisa identificar UM registro. Só Z2_FILIAL não serve, pois
    // todos os autores da mesma filial teriam a "mesma chave" e o MVC bloquearia
    // a inclusão do 2º autor como duplicado. Usa-se filial + código (X2_UNICO).
    //---------------------------------------------------------------------------------
    oModel:SetPrimaryKey({'Z2_FILIAL', 'Z2_CODIGO'})

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

    //Cria a estrutura do view (2 = View)
    oStruSZ2 := FWFormStruct(2, "SZ2")

    //Cria o objeto de view
    oView := FwFormView():New()

    //Define qual é o modelo de dados que será utilizado na View
    oView:SetModel(oModel)

    //Adiciona no View um componente do tipo formulário (enchoice), vinculando com o formulário do modelo
    oView:AddField('VIEW_SZ2', oStruSZ2, 'SZ2MASTER')

    //Cria um box horizontal para receber o elemento da View
    oView:CreateHorizontalBox("FORMULARIO", 100)

    // Relaciona o box com a view criada para apresentação
    oView:SetOwnerView('VIEW_SZ2', 'FORMULARIO')

Return oView
