// Funciona em qualquer codigo .prw dentro da pasta
user function tipo1()

Alert("Essa é uma user function")

tipo2()

return

//Funciona apenas no codigo .prw criado e dentro de uma user function
Static Function tipo2()

Alert("Essa é uma static function")

Return
