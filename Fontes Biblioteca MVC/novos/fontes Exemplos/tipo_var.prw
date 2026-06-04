Static cVar5 := "Static"

User Function Func1()
Local cVar1 := "Local"
Private cVar2 := "Private"

U_Func4()

U_Func2()

Alert(cVar3) //Public
Alert(cVar4) //Private

RETURN

User Function Func2()
Public cVar3 := "Public"
Private cVar4 := "Private 2"

Alert(cVar2) //Private
Alert(cVar3) //Public

U_func3()

RETURN

User Function Func3()

Alert(cVar3) //Public
Alert(cVar2) //Private

RETURN
