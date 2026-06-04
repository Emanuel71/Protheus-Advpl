#INCLUDE "protheus.ch"
user function soma ()
local nNum1:= 20
local nNum2:= 10
soma := (nNum1 + nNum2)
Alert(soma)
nNum1:= "teste"
Alert(nNum1)
soma := (nNum1 + nNum2)
Alert(soma)
RETURN
