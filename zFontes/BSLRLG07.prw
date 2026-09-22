#INCLUDE "totvs.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BSLRLG07
Relatorio de Notas Fiscais de Entrada por Pedido de Compra.
Lista, por pedido de compra (SC7), os dados da nota fiscal de entrada
(SD1/SF1), o fornecedor (SA2) e a conta contabil (CT1).

@type       function
@author     Genesis Consultoria
@since       22/07/2026
@obs        Somente pedidos que geraram nota fiscal de entrada (INNER JOIN).
/*/
User Function BSLRLG07()
    Local oReport   := Nil
    Private cPerg   := PadR("BSLRLG07",10)
    
    ValidPerg(cPerg)

   If !Pergunte(cPerg, .T.)
        Return
    EndIf

    oReport := ReportDef()
    oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
Monta a estrutura do relatorio (secao e colunas).

@type       function
@author     Genesis Consultoria
@since       22/07/2026
@return     object, Objeto TReport configurado
/*/
Static Function ReportDef()
    Local oReport   := Nil
    Local oSection1 := Nil

    oReport := TReport():New("BSLRLG07", "Notas Fiscais por Pedido", cPerg, {|oReport| ReportPrint(oReport)}, "Relatorio de Notas Fiscais de Entrada por Pedido de Compra")
    oReport:SetLandScape()
    oReport:SetTotalInLine(.F.)

    oSection1 := TRSection():New(oReport, "Notas Fiscais", {""})

    TRCell():New(oSection1, "C7_FILIAL" , "QRY", "Filial"                , PesqPict("SC7", "C7_FILIAL") , 06)
    TRCell():New(oSection1, "D1_DOC"    , "QRY", "Nota Fiscal"           , PesqPict("SD1", "D1_DOC")    , 12)
    TRCell():New(oSection1, "D1_SERIE"  , "QRY", "Serie"                 , PesqPict("SD1", "D1_SERIE")  , 06)
    TRCell():New(oSection1, "D1_EMISSAO", "QRY", "Dt. Emissao NF"        , PesqPict("SD1", "D1_EMISSAO"), 10)
    TRCell():New(oSection1, "C7_FORNECE", "QRY", "Cod. Fornecedor"       , PesqPict("SC7", "C7_FORNECE"), 12)
    TRCell():New(oSection1, "A2_NOME"   , "QRY", "Nome do Fornecedor"    , PesqPict("SA2", "A2_NOME")   , 40)
    TRCell():New(oSection1, "F1_VALBRUT", "QRY", "Valor Total NF"        , PesqPict("SF1", "F1_VALBRUT"), 16)
    TRCell():New(oSection1, "C7_CONTA"  , "QRY", "Conta Contabil"        , PesqPict("CT1", "CT1_CONTA") , 20)
    TRCell():New(oSection1, "CT1_DESC01", "QRY", "Desc. Conta Contabil"  , PesqPict("CT1", "CT1_DESC01"), 40)

Return oReport

/*/{Protheus.doc} ReportPrint
Executa a consulta e imprime as linhas do relatorio.

@type       function
@author     Genesis Consultoria
@since       22/07/2026
@param      oReport, object, Objeto TReport
/*/
Static Function ReportPrint(oReport)
    Local oSection1 := oReport:Section(1)
    Local cAlias    := GetNextAlias()

    Pergunte(cPerg, .F.)

    BeginSql Alias cAlias
        SELECT DISTINCT SC7.C7_FILIAL,
               SC7.C7_FORNECE,
               SC7.C7_CONTA,
               SD1.D1_DOC,
               SD1.D1_SERIE,
               SD1.D1_EMISSAO,
               SF1.F1_VALBRUT,
               SA2.A2_NOME,
               CT1.CT1_DESC01
        FROM %Table:SC7% SC7
            INNER JOIN %Table:SD1% SD1
                ON  SD1.D1_FILIAL = SC7.C7_FILIAL
                AND SD1.D1_PEDIDO = SC7.C7_NUM
                AND SD1.D1_ITEMPC = SC7.C7_ITEM
                AND SD1.%NotDel%
            INNER JOIN %Table:SF1% SF1
                ON  SF1.F1_FILIAL  = SD1.D1_FILIAL
                AND SF1.F1_DOC     = SD1.D1_DOC
                AND SF1.F1_SERIE   = SD1.D1_SERIE
                AND SF1.F1_FORNECE = SD1.D1_FORNECE
                AND SF1.F1_LOJA    = SD1.D1_LOJA
                AND SF1.%NotDel%
            LEFT JOIN %Table:SA2% SA2
                ON  SA2.A2_FILIAL = %xFilial:SA2%
                AND SA2.A2_COD    = SC7.C7_FORNECE
                AND SA2.A2_LOJA   = SC7.C7_LOJA
                AND SA2.%NotDel%
            LEFT JOIN %Table:CT1% CT1
                ON  CT1.CT1_FILIAL = %xFilial:CT1%
                AND CT1.CT1_CONTA  = SC7.C7_CONTA
                AND CT1.%NotDel%
        WHERE SC7.C7_FILIAL BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
          AND SD1.D1_EMISSAO BETWEEN %Exp:DtoS(MV_PAR03)% AND %Exp:DtoS(MV_PAR04)%
          AND SC7.%NotDel%
        ORDER BY SC7.C7_FILIAL, SD1.D1_DOC, SD1.D1_SERIE
    EndSql

    oSection1:Init()

    While (cAlias)->(!Eof())
        oReport:IncMeter()

        oSection1:Cell("C7_FILIAL"):SetValue((cAlias)->C7_FILIAL)
        oSection1:Cell("D1_DOC"):SetValue((cAlias)->D1_DOC)
        oSection1:Cell("D1_SERIE"):SetValue((cAlias)->D1_SERIE)
        oSection1:Cell("D1_EMISSAO"):SetValue(StoD((cAlias)->D1_EMISSAO))
        oSection1:Cell("C7_FORNECE"):SetValue((cAlias)->C7_FORNECE)
        oSection1:Cell("A2_NOME"):SetValue((cAlias)->A2_NOME)
        oSection1:Cell("F1_VALBRUT"):SetValue((cAlias)->F1_VALBRUT)
        oSection1:Cell("C7_CONTA"):SetValue((cAlias)->C7_CONTA)
        oSection1:Cell("CT1_DESC01"):SetValue((cAlias)->CT1_DESC01)

        oSection1:PrintLine()
        (cAlias)->(DbSkip())
    EndDo

    oSection1:Finish()
    //(cAlias)->(DbCloseArea())

Return

/*/{Protheus.doc} ValidPerg
Cria/valida o grupo de perguntas (SX1) do relatorio.

@type       function
@author     Genesis Consultoria
@since       22/07/2026
@param      cPerg, character, Nome do grupo de perguntas
/*/
Static Function ValidPerg(cPerg)
    /*Local aRegs := {}
    Local nI    := 0
    Local nJ    := 0

    DbSelectArea("SX1")
    DbSetOrder(1)
    cPerg := PadR(cPerg, 10)*/

    //     Grupo  Ord  Pergunta              Spa Eng  Var       Tipo Tam Dec Pre GSC  Valid F3    GrpSxg Pyme Var01       Def01 Spa1 Eng1 Cnt01
    PutSx1(cPerg, "01", "Filial de         ?", "", "", "mv_ch1", "C", 06, 0, 0, "G", "", "SM0", "",   "",  "mv_par01", "",  "",  "",  "")
    PutSx1(cPerg, "02", "Filial ate        ?", "", "", "mv_ch2", "C", 06, 0, 0, "G", "", "SM0", "",   "",  "mv_par02", "",  "",  "",  "")
    PutSx1(cPerg, "03", "Emissao NF de     ?", "", "", "mv_ch3", "D", 08, 0, 0, "G", "", "",    "",   "",  "mv_par03", "",  "",  "",  "")
    PutSx1(cPerg, "04", "Emissao NF ate    ?", "", "", "mv_ch4", "D", 08, 0, 0, "G", "", "",    "",   "",  "mv_par04", "",  "",  "",  "")

    
    /*         Grupo/Ordem/Pergunta/Var/Tipo/Tam/Dec/Presel/GSC/Valid/Var01/Def01/Cnt01/.../F3
    aAdd(aRegs, {cPerg, "01", "Filial de           ?", "", "", "mv_ch1", "C", 06, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "", "", ""})
    aAdd(aRegs, {cPerg, "02", "Filial ate          ?", "", "", "mv_ch2", "C", 06, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0", "", "", ""})
    aAdd(aRegs, {cPerg, "03", "Emissao NF de       ?", "", "", "mv_ch3", "D", 08, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
    aAdd(aRegs, {cPerg, "04", "Emissao NF ate      ?", "", "", "mv_ch4", "D", 08, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

    For nI := 1 To Len(aRegs)
        If !DbSeek(cPerg + aRegs[nI, 2])
            RecLock("SX1", .T.)
            For nJ := 1 To FCount()
                If nJ <= Len(aRegs[nI])
                    FieldPut(nJ, aRegs[nI, nJ])
                EndIf
            Next nJ
            MsUnlock()
        EndIf
    Next nI

    DbCloseArea()*/

Return .T.
