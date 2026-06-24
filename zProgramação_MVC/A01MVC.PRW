#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

User Function A01MVC()
Local oBrowse

//Criação do objeto do Tipo Browse 
oBrowse := FwmBrowse():NEW()

//Definir qual a tabela que será apresentada no browse
oBrowse:SetAlias("SB1")

//Definir o titulo ou a descrição que será apresentada no Browse
oBrowse:SetDescription("Cadastro de Produto - Aula MVC")

//Realizar a ativação do Browse
oBrowse:Activate()

Return
