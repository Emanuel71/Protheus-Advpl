/*/{Protheus.doc} Tipo Variavel
Estamos entendendo como uma variavel Local e Private funciona.
@author Emanuel
@since 27/05/2026
/*/

Static cVar5 := "Static"

User Function Funct1()
    Local cVar1     := "Local"
    Private cVar2   := "Private"

    U_Funct4()

    //U_Funct2()
 // Aqui aprensentou um erro, pois, cVar1(Local) só irá aparecer no Funct1 e não Funct2 por ser uma variavel local.
Return


/*/{Protheus.doc} Tipo Variavel
Estamos entendendo como uma variavel Public e Private2 funciona.
(long_description)
@type user function
@author user
@since 27/05/2026
/*/
User Function Funct2()
    Public cVar3 := "Public"
    Private cVar4 := "Private 2"

    Alert(cVar2) //Private
    Alert(cVar3) //Public

    U_Funct3()

 Return  

User Function Funct3()

    Alert(cVar3) //Public
    Alert(cVar2) //Private

Return
