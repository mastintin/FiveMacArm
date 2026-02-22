#include "FiveMac.ch"
#include "SwiftControls.ch"
#include "Nice.ch"

MEMVAR nActiveUser, oApli

//----------------------------------------------------------------------------//

function SimuladorView( oParent, oDb, oWnd, oSayHello )
    local nActive := GetActiveUserId()
    local oPanel
    local oTitle, oGrpParams, oGetStart, oSayDate, oBtnCalc, oBtnPdf
    local dStart := Date()
    local oUser 
    // UI Elements
    local oCardA, oSayBaseA, oSaySumA, oSayMonthsA, oSayDivA, oSayRedA, oIndA
    local oCardB, oSayBaseB, oSaySumB, oSayMonthsB, oSayDiscardB, oSayDivB, oSayRedB, oIndB
    local oCardBest, oSayBestTitle, oSayBestAmount, oSayIpcRef, oBtnDetail, oSayIrpfVal, oSayIrpfNet
    
    DEFAULT oDb := oApli:oDb
    oUser := GetUserData( nActive, oDb )
    
    if nActive == 0
    MsgAlert( "Seleccione un usuario primero" )
    return nil
    endif

    if ! Empty( oUser )
    dStart := CalcJubOrdinaria( oUser, oDb )
    if Year( dStart ) < 2000 
    dStart := Date() 
    endif
    endif
    
    UpdateHelloTitle( oSayHello , "Simulador Dual" )
    
    oPanel := TPanel():New( 0, 0, oParent:nWidth, oParent:nHeight, oParent )
    oPanel:_nAutoResize( 18 )

    @ 20, 20 SAY oTitle PROMPT "Simulador Dual (Normal vs Transición)" OF oPanel SIZE 400, 25
    oTitle:SetFont( "Helvetica-Bold", 18 )

    @ 55, 20 GROUP oGrpParams LABEL "Parámetros" OF oPanel SIZE oPanel:nWidth - 40, 80
    oGrpParams:_nAutoResize( 2 ) // Width

    @ 92, 40 SAY oSayDate PROMPT "Fecha Jubilación:" OF oPanel SIZE 160, 38
    oSayDate:SetFont( "Helvetica-Bold", 14 )

    @ 75, 210 DATEPICKER oGetStart OF oPanel SIZE 140, 38 
    // oGetStart:SetFont( "Helvetica", 14 ) // Removed as it causes a crash in Native NSDatePicker
    // MsgInfo( "Fecha Calculada: " + DToC( dStart ) )
    oGetStart:SetDate( DTOC( dStart ) )
    oGetStart:SetStyle( 0 )

    @ 82, 400 SWIFTBUTTON oBtnCalc PROMPT "Calcular Comparativa" OF oPanel SIZE 200, 38 ;
        ACTION RunDualCalc( nActive, oDb, oGetStart:GetDate(),;
        oSayBaseA, oSaySumA, oSayMonthsA, oSayDivA, oSayRedA, oIndA, ;
        oSayBaseB, oSaySumB, oSayMonthsB, oSayDiscardB, oSayDivB, oSayRedB, oIndB, ;
        oSayBestTitle, oSayBestAmount, oCardBest, oSayIpcRef, oBtnDetail, oSayIrpfVal, oSayIrpfNet, oCardA, oCardB )
    oBtnCalc:SetGlass( .T. )
    oBtnCalc:SetImage( "play.circle" )
    oBtnCalc:_nAutoResize( 0 )

    // Guardar PDF Button in Parameters Section
    @ 82, 620 SWIFTBUTTON oBtnPdf PROMPT "Guardar PDF" OF oPanel SIZE 150, 38 ;
        ACTION SimuladorPDF( nActive, oDb, oGetStart:GetDate() )
    oBtnPdf:SetGlass( .T. )
    oBtnPdf:SetImage( "doc.text" )
    oBtnPdf:_nAutoResize( 0 )

    // --- GRUPO A: NORMAL ---
    oCardA := TCard():New( 160, 20, (oPanel:nWidth/3) - 20, 280, oPanel, nRGB( 99, 102, 241 ), "Método Normal", "chart.bar.xaxis" )
    oCardA:_nAutoResize( 0 )

    @ 60, 20 SAY "Base Reguladora:" OF oCardA:oBody SIZE 150, 20
    @ 85, 20 SAY oSayBaseA PROMPT "0.00 €" OF oCardA:oBody SIZE 150, 30
    oSayBaseA:SetFont( "Helvetica-Bold", 24 )

    @ 115, 20 SAY "Coef. Reductor:" OF oCardA:oBody SIZE 120, 20
    @ 115, 140 SAY oSayRedA PROMPT "0.00 %" OF oCardA:oBody SIZE 80, 20
    oSayRedA:SetFont( "Helvetica-Bold", 14 )

    @ 145, 20 SAY "Suma Bases Reval.:" OF oCardA:oBody SIZE 150, 20
    @ 165, 20 SAY oSaySumA PROMPT "0.00 €" OF oCardA:oBody SIZE 150, 20
    
    @ 195, 20 SAY "Meses Computados:" OF oCardA:oBody SIZE 150, 20
    @ 215, 20 SAY oSayMonthsA PROMPT "-" OF oCardA:oBody SIZE 150, 20
    
    @ 240, 20 SAY "Divisor:" OF oCardA:oBody SIZE 150, 20
    @ 255, 20 SAY oSayDivA PROMPT "-" OF oCardA:oBody SIZE 150, 20

    // --- GRUPO B: TRANSICION ---
    oCardB := TCard():New( 160, (oPanel:nWidth/3) + 10, (oPanel:nWidth/3) - 20, 280, oPanel, nRGB( 99, 102, 241 ), "Método Transición", "arrow.up.right.circle" )
    oCardB:_nAutoResize( 0 )

    @ 60, 20 SAY "Base Reguladora:" OF oCardB:oBody SIZE 150, 20
    @ 85, 20 SAY oSayBaseB PROMPT "0.00 €" OF oCardB:oBody SIZE 150, 30
    oSayBaseB:SetFont( "Helvetica-Bold", 24 )

    @ 115, 20 SAY "Coef. Reductor:" OF oCardB:oBody SIZE 120, 20
    @ 115, 140 SAY oSayRedB PROMPT "0.00 %" OF oCardB:oBody SIZE 80, 20
    oSayRedB:SetFont( "Helvetica-Bold", 14 )

    @ 145, 20 SAY "Suma Bases Reval.:" OF oCardB:oBody SIZE 150, 20
    @ 165, 20 SAY oSaySumB PROMPT "0.00 €" OF oCardB:oBody SIZE 150, 20

    @ 195, 20 SAY "Meses Totales / Descartados:" OF oCardB:oBody SIZE 200, 20
    @ 215, 20 SAY oSayMonthsB PROMPT "-" OF oCardB:oBody SIZE 200, 20
    oSayDiscardB := oSayMonthsB 
    
    @ 240, 20 SAY "Divisor:" OF oCardB:oBody SIZE 150, 20
    @ 255, 20 SAY oSayDivB PROMPT "-" OF oCardB:oBody SIZE 150, 20

    // --- GRUPO BEST: RESULTADO ---
    oCardBest := TCard():New( 160, (oPanel:nWidth/3)*2, (oPanel:nWidth/3) - 20, 280, oPanel, nRGB( 79, 70, 229 ), "Pension a Cobrar", "star.circle.fill" )
    oCardBest:_nAutoResize( 0 )

    @ 55, 20 SAY oSayBestTitle PROMPT "" OF oCardBest:oBody SIZE 200, 30
    oSayBestTitle:SetFont( "Helvetica-Bold", 18 )
    
    @ 170, 20 SAY "Pensión Bruta (14 pagas):" OF oCardBest:oBody SIZE 180, 20
    @ 190, 20 SAY oSayBestAmount PROMPT "" OF oCardBest:oBody SIZE 200, 35
    oSayBestAmount:SetFont( "Helvetica-Bold", 18 )

    @ 145, 20 SAY "Retención IRPF:" OF oCardBest:oBody SIZE 100, 20
    @ 145, 120 SAY oSayIrpfVal PROMPT "" OF oCardBest:oBody SIZE 100, 20
    oSayIrpfVal:SetFont( "Helvetica-Bold", 14 )

    @ 85, 20 SAY "Pensión NETA Mensual:" OF oCardBest:oBody SIZE 200, 20
    @ 105, 20 SAY oSayIrpfNet PROMPT "" OF oCardBest:oBody SIZE 200, 30
    oSayIrpfNet:SetFont( "Helvetica-Bold", 24 )
    oSayIrpfNet:SetColor( nRGB( 34, 139, 34 ), nRGB( 0, 0, 0, 0 ) )

    // IPC Info
    @ 215, 20 SAY oSayIpcRef PROMPT "" OF oCardBest:oBody SIZE 200, 25
    oSayIpcRef:SetFont( "Helvetica", 10 )
    
    // Detail Button
    @ 248, 120 SWIFTBUTTON oBtnDetail PROMPT "Ver Detalle" OF oCardBest:oBody SIZE 150, 25 ;
        ACTION nil 
    oBtnDetail:SetGlass( .T. )
    oBtnDetail:SetImage( "list.bullet.rectangle" )
    oBtnDetail:Hide() 
    
return nil

//----------------------------------------------------------------------------//

Function SimuladorPDF( nUserId, oDb, dDate )
    local oUser := GetUserData( nUserId, oDb )
    local aRes, oPrn, oPage
    local cPdfPath := Path() + "/Simulacion_" + AllTrim(oUser["nombre"]) + ".pdf"

    if Empty( oUser ) 
    return nil 
    endif

    // 1. Calculate Data (Same as RunDualCalc)
    aRes := CalculateDualPension( oUser, dDate, oDb )
    
    // 2. Create Printer
    DEFINE NICE PRINTER oPrn
    
    //  

    BuildXjubilaReportHtml( oPrn, oUser, dDate, aRes )

    // --- CUSTOM HTML FOR XJUBILA ---
    //   oPage:Add( BuildXjubilaReportHtml( oPrinter, oUser, dDate, aRes ) )
        
    // END NICE PRINT PAGE
    
    // 3. Generate PDF
    oPrn:nativoPreview( cPdfPath )

return nil

//----------------------------------------------------------------------------//

Function BuildXjubilaReportHtml( oPrn, oUser, dDate, aRes )
    local hResA := aRes["a"]
    local hResB := aRes["b"]
    local nWinner := iif( hResA["base"] >= hResB["base"], 1, 2 )
    local cMask := "@E 9,999,999.99"
    local nAge := Year( dDate ) - Year( oUser["fecha_nac"] )
    local hIrpf, nWinnerBase
    local cHtml := ""

    local oPage, oSay, oCardA, oDiv, oDivH, oDiv2
    local oDivA,oDivB,oDivF,oDivIpc,oDivComp
    local oDivTbl1, oRowH, oRow1, oRow2, oRow3, oRow4, oRowTot
    local oDivTbl2, oRowH2, oRowTot2
    local oTbl

    
    // Age adjustments
    if Month( dDate ) < Month( oUser["fecha_nac"] ) .or. ( Month( dDate ) == Month( oUser["fecha_nac"] ) .and. Day( dDate ) < Day( oUser["fecha_nac"] ) )
    nAge--
    endif
    
    nWinnerBase := iif( nWinner == 1, hResA["base"], hResB["base"] )
    hIrpf := CalculateIRPF( nWinnerBase * 14, nAge, oApli:oDb )


    NICE PRINT PAGE oPage OF oPrn
        
    // Header
    cHtml += '<div class="row items-center q-mb-lg border-bottom pb-2">'
    cHtml += '<div class="col-8">'
    cHtml += '<div class="text-h4 text-primary text-weight-bold">INFORME DE SIMULACIÓN DUAL</div>'
    cHtml += '<div class="text-subtitle1 text-grey-7">Análisis Comparativo de Pensión de Jubilación</div>'
    cHtml += '</div>'
   
    cHtml += '<div class="col-4 text-right">'
    cHtml += '<div class="text-weight-bold">' + oUser["nombre"] + " " + oUser["apellidos"] + '</div>'
    cHtml += '<div>Nacimiento: ' + DToC( oUser["fecha_nac"] ) + " | Edad: " + AllTrim(Str(nAge)) + '</div>'
    cHtml += '<div class="text-primary text-weight-bold">Fecha Proyectada: ' + DToC( dDate ) + '</div>'
    cHtml += '</div>'
      
    cHtml += '</div>' // Header end
   
    // IPC
    cHtml += '<div class="row q-col-gutter-sm q-mb-md text-caption text-grey-8">'
    cHtml += '<div class="col">Ref. IPC (' + aRes["ipc_key"] + '): <b>' + AllTrim(Str(aRes["ipc_ref"])) + '</b></div>'
    cHtml += '<div class="col">Coef. Reductor: <b>' + AllTrim(Str(hResA["reduction"])) + '%</b></div>'
    cHtml += '<div class="col">Pensión % (Carrera): <b>' + Transform( hResA["pension_pct"] * 100, "99.99" ) + '%</b></div>'
    cHtml += '</div>'

    // 1. Comparativa
    cHtml += '<div class="text-h6 q-mb-sm text-primary">1. COMPARATIVA DE ESCENARIOS</div>'
    cHtml += '<div class="row q-col-gutter-md q-mb-lg">'
   
    // Card A
    cHtml += '<div class="col-6">'
    cHtml += '<div class="q-pa-md rounded-borders border ' + iif(nWinner==1, "bg-green-1 border-green", "bg-grey-1") + '">'
    cHtml += '<div class="text-overline text-weight-bold">MÉTODO NORMAL (25 AÑOS)</div>'
    cHtml += '<div class="text-h4 ' + iif(nWinner==1, "text-green-9", "") + '">' + Transform( hResA["base"], cMask ) + ' €</div>'
    cHtml += '<div class="text-caption">Cálculo estándar de bases revalorizadas</div>'
    cHtml += '</div></div>'
    
    // Card B
    cHtml += '<div class="col-6">'
    cHtml += '<div class="q-pa-md rounded-borders border ' + iif(nWinner==2, "bg-green-1 border-green", "bg-grey-1") + '">'
    cHtml += '<div class="text-overline text-weight-bold">MÉTODO TRANSICIÓN (DUAL)</div>'
    cHtml += '<div class="text-h4 ' + iif(nWinner==2, "text-green-9", "") + '">' + Transform( hResB["base"], cMask ) + ' €</div>'
    cHtml += '<div class="text-caption">Con descarte de peores meses</div>'
    cHtml += '</div></div>'
   
    cHtml += '</div>'
  
    // 2. Detalle
    cHtml += '<div class="text-h6 q-mb-sm text-primary">2. DETALLE DEL CÁLCULO (' + iif(nWinner==1, "NORMAL", "TRANSICIÓN") + ')</div>'
    
    cHtml += '<table class="report-table q-mb-lg full-width">'
    cHtml += '<thead><tr><th class="text-left">Concepto</th><th class="text-right" style="width:100px">Valor</th></tr></thead>'
    cHtml += '<tbody>'
        
    if nWinner == 1
    cHtml += '<tr><td>Suma de Bases Revalorizadas (' + AllTrim(Str(hResA["months"])) + ' meses)</td><td class="text-right">' + Transform( hResA["sum"], cMask ) + ' €</td></tr>'
    cHtml += '<tr><td>Divisor Aplicado</td><td class="text-right">' + AllTrim(Str(hResA["divisor"])) + '</td></tr>'
    else
    cHtml += '<tr><td>Meses Totales Computados</td><td class="text-right">' + AllTrim(Str(hResB["months_total"])) + '</td></tr>'
    cHtml += '<tr><td>(-) Meses Descartados (Peores)</td><td class="text-right">-' + AllTrim(Str(hResB["discarded"])) + '</td></tr>'
    cHtml += '<tr><td>Suma Efectiva de Bases</td><td class="text-right">' + Transform( hResB["sum"], cMask ) + ' €</td></tr>'
    cHtml += '<tr><td>Divisor Aplicado</td><td class="text-right">' + AllTrim(Str(hResB["divisor"])) + '</td></tr>'
    endif
        
    cHtml += '<tr class="bg-primary text-white text-weight-bold"><td>BASE REGULADORA (Bruta)</td><td class="text-right">' + Transform( iif(nWinner==1, hResA["base_raw"], hResB["base_raw"]), cMask ) + ' €</td></tr>'
    cHtml += '</tbody></table>'
    
    // 3. Estimación
    cHtml += '<div class="text-h6 q-mb-sm text-primary">3. ESTIMACIÓN NETA MENSUAL</div>'
    
    cHtml += '<table class="report-table q-mb-md full-width">'
    cHtml += '<thead><tr><th class="text-left">Concepto</th><th class="text-right" style="width:100px">Valor</th></tr></thead>'
    cHtml += '<tbody>'
        
    cHtml += '<tr><td>Pensión Bruta Anual (14 pagas)</td><td class="text-right">' + Transform( nWinnerBase * 14, cMask ) + ' €</td></tr>'
    cHtml += '<tr><td>Retención Proyectada IRPF</td><td class="text-right text-red">-' + AllTrim(Str(hIrpf["tipo_medio"], 5, 2)) + '%</td></tr>'
    cHtml += '<tr><td>Cuota IRPF Anual</td><td class="text-right text-red">-' + Transform( hIrpf["cuota_liquida"], cMask ) + ' €</td></tr>'
    cHtml += '<tr class="bg-green-2 text-weight-bold"><td><div class="text-h6">PENSIÓN NETA MENSUAL (14 pagas)</div></td>'
    cHtml += '<td class="text-right"><div class="text-h5 text-green-9">' + Transform( hIrpf["neto_mensual"], cMask ) + ' €</div></td></tr>'
        
    cHtml += '</tbody></table>'
    
    // Footer
    cHtml += '<div class="text-caption text-grey-6 q-mt-xl text-center border-top pt-2">'
    cHtml += 'Documento Informativo generado por Xjubila v3.0 (Powered by FiveMac & NiceGUI)<br/>Este cálculo es informativo y no vinculante.'
    cHtml += '</div>'
   
    oPage:Add( cHtml )

    END NICE PRINT PAGE

    return cHtml


return cHtml

//----------------------------------------------------------------------------//

function RunDualCalc( nUserId, oDb, dDate, oSayBaseA, oSaySumA, oSayMonthsA, oSayDivA, oSayRedA, oIndA, ;
        oSayBaseB, oSaySumB, oSayMonthsB, oSayDiscardB, oSayDivB, oSayRedB, oIndB, ;
        oSayBestTitle, oSayBestAmount, oCardBest, oSayIpcRef, oBtnDetail, ;
        oSayIrpfVal, oSayIrpfNet, oCardA, oCardB )

    local oUser := GetUserData( nUserId, oDb )
    local aRes, hResA, hResB, cTxt, dOrdinary, nMonthsEarly, lInvoluntary, hIrpf, nAge, nWinnerBase
    local cMask := "@E 9,999,999.99"
    local nIndigo := nRGB( 99, 102, 241 )
    local nGreen := nRGB( 34, 139, 34 )
    
    // Safety for 19xx vs 20xx issue (Epoch) - Redundant with SET EPOCH but keeps local safety
    if Year( dDate ) < 2000
    dDate := SToD( Str( Year( dDate ) + 100, 4 ) + StrZero( Month( dDate ), 2 ) + StrZero( Day( dDate ), 2 ) )
    endif

    MsgInfo( "Fecha seleccionada para cálculo: " + DToC( dDate ) )
    
    if Empty( oUser ) 
    MsgAlert( "Error: Usuario no cargado" )
    return nil 
    endif

    // Validation: Early retirement limits
    // Involuntary: 48 months, Voluntary: 24 months
    dOrdinary := CalcJubOrdinaria( oUser, oDb )
    nMonthsEarly := ( Year( dOrdinary ) - Year( dDate ) ) * 12 + ( Month( dOrdinary ) - Month( dDate ) )
    if Day( dOrdinary ) > Day( dDate )
    nMonthsEarly++
    endif
    lInvoluntary := ( hb_HGetDef( oUser, "invol", 0 ) != 0 )

    if ( lInvoluntary .and. nMonthsEarly > 48 ) .or. ( ! lInvoluntary .and. nMonthsEarly > 24 )
    MsgAlert( "En esa fecha no es posible la jubilación." + CRLF + ;
        "Adelanto: " + AllTrim( Str( nMonthsEarly ) ) + " meses." + CRLF + ;
        "Límite: " + iif( lInvoluntary, "48", "24" ) + " meses." )
    return nil
    endif
    
    aRes := CalculateDualPension( oUser, dDate, oDb )

    hResA := aRes["a"]
    hResB := aRes["b"]
    
    // Update UI A
    oSayBaseA:SetText( Transform( hResA["base"], cMask ) + " €" )
    oSaySumA:SetText( Transform( hResA["sum"], cMask ) + " €" )
    oSayMonthsA:SetText( AllTrim( Str( hResA["months"] ) ) )
    oSayDivA:SetText( AllTrim( Str( hResA["divisor"] ) ) )
    oSayRedA:SetText( AllTrim( Str( hResA["reduction"] ) ) + " %" )
    
    // Update UI B
    oSayBaseB:SetText( Transform( hResB["base"], cMask ) + " €" )
    oSaySumB:SetText( Transform( hResB["sum"], cMask ) + " €" )
    oSayMonthsB:SetText( AllTrim( Str( hResB["months_total"] ) ) + " / " + AllTrim( Str( hResB["discarded"] ) ) + " desc." )
    oSayDivB:SetText( AllTrim( Str( hResB["divisor"] ) ) )
    oSayRedB:SetText( AllTrim( Str( hResB["reduction"] ) ) + " %" )
    
    // Update Best
    // Update Best
    if hResA["base"] >= hResB["base"]
    oSayBestTitle:SetText( "GANADOR: NORMAL" )
    oSayBestTitle:SetColor( nGreen, nRGB( 0, 0, 0, 0 ) )
    oSayBestAmount:SetText( Transform( hResA["base"], cMask ) + " €" )
    oSayBestAmount:SetColor( nGreen, nRGB( 0, 0, 0, 0 ) )
        
    nWinnerBase := hResA["base"]
        
    // Highlight Card A (Green Top)
    oCardA:SetBorderColor( nGreen )
    oSayBaseA:SetColor( nGreen, nRGB( 0, 0, 0, 0 ) )
        
    // Reset Card B (Indigo Top)
    oCardB:SetBorderColor( nIndigo )
    oSayBaseB:SetColor( CLR_BLACK, nRGB( 0, 0, 0, 0 ) )
        
    oBtnDetail:bAction := {|| ShowDualDetail( hResA["lines"], aRes["ipc_ref"], oCardBest:oWnd ) }
    else
    oSayBestTitle:SetText( "GANADOR: TRANSICIÓN" )
    oSayBestTitle:SetColor( nGreen, nRGB( 0, 0, 0, 0 ) )
    oSayBestAmount:SetText( Transform( hResB["base"], cMask ) + " €" )
    oSayBestAmount:SetColor( nGreen, nRGB( 0, 0, 0, 0 ) )
        
    nWinnerBase := hResB["base"]
        
    // Highlight Card B (Green Top)
    oCardB:SetBorderColor( nGreen )
    oSayBaseB:SetColor( nGreen, nRGB( 0, 0, 0, 0 ) )
        
    // Reset Card A (Indigo Top)
    oCardA:SetBorderColor( nIndigo )
    oSayBaseA:SetColor( CLR_BLACK, nRGB( 0, 0, 0, 0 ) )
        
    oBtnDetail:bAction := {|| ShowDualDetail( hResB["lines"], aRes["ipc_ref"], oCardBest:oWnd ) }
    endif

    // --- IRPF Calculation ---
    nAge := Year( dDate ) - Year( oUser["fecha_nac"] )
    if Month( dDate ) < Month( oUser["fecha_nac"] ) .or. ( Month( dDate ) == Month( oUser["fecha_nac"] ) .and. Day( dDate ) < Day( oUser["fecha_nac"] ) )
    nAge--
    endif

    hIrpf := CalculateIRPF( nWinnerBase * 14, nAge, oDb )
    
    oSayIrpfVal:SetText( AllTrim( Str( hIrpf["tipo_medio"], 5, 2 ) ) + "% (" + Transform( hIrpf["cuota_liquida"] / 14, "@E 9,999.99" ) + " €)" )
    oSayIrpfNet:SetText( Transform( hIrpf["neto_mensual"], cMask ) + " €" )
    
    oBtnDetail:Show()

    // Update IPC Info & Reduction
    cTxt := "IPC Ref (" + aRes["ipc_key"] + "): " + iif( ! Empty( aRes["ipc_ref"] ) .and. aRes["ipc_ref"] > 0, AllTrim( Str( aRes["ipc_ref"] ) ), "N/A" )
    cTxt += "  |  Reducc: " + AllTrim( Str( hResA["reduction"] ) ) + "% (" + AllTrim( Str( hResA["months_early"] ) ) + " meses)"
    
    oSayIpcRef:SetText( cTxt )

return nil

//----------------------------------------------------------------------------//

function CalculateDualPension( oUser, dJub, oDb )
    local aBases, hScenarioA, hScenarioB
    local nYearJub := Year( dJub )
    local aDualRow
    local nExtra, nDiscard, nDivisor
    local nTotalMonths
    local nDiasAFecha
    local hBasesData
    local nIpcRef := 0, cIpcKey := ""
    local dOrdinary, nMonthsEarly, nTotalYears, lInvoluntary, nReductionCoef, nPensionPct

    // 1. Get Revalued Bases (All history available)
    hBasesData := GetRevaluedBases( oUser["id"], dJub, oDb ) 
    
    if Empty( hBasesData ) .or. Empty( hBasesData["bases"] )
    return { "a"=>{ "base"=>0, "sum"=>0 }, "b"=>{ "base"=>0, "sum"=>0 }, "ipc_ref"=>0, "ipc_key"=>"" } 
    endif

    aBases := hBasesData["bases"]
    nIpcRef := hBasesData["ipc"]
    cIpcKey := hBasesData["key"]

    // 2. Scenario A: Last 300 months, 0 discard, 350 divisor
    
    // Calculate Early Retirement months
    dOrdinary := CalcJubOrdinaria( oUser, oDb )
    nMonthsEarly := ( Year( dOrdinary ) - Year( dJub ) ) * 12 + ( Month( dOrdinary ) - Month( dJub ) )
    
    // Handle partial month diff correctly for retirement count
    if Day( dOrdinary ) > Day( dJub )
    nMonthsEarly++
    endif
    
    if nMonthsEarly < 0 ; nMonthsEarly := 0 ; endif
    
    // Get Total Years for tranche
    nDiasAFecha:= GetTotalDiasCot( oUser )+ ( dJub - date() )
    
    nTotalYears := nDiasAFecha / 365.25
    lInvoluntary := ( hb_HGetDef( oUser, "invol", 0 ) != 0 )
    
    // Calculate Pension Percentage based on Years Worked (e.g., < 37 years)
    nPensionPct := CalcPensionPercent( nTotalYears ) / 100.0
    
    
    // Get Coefficient Impact (Reduction %)

    
    nReductionCoef := GetCoefReductorDB( nMonthsEarly, nTotalYears, lInvoluntary, oDb )
    
    // Scenario A
    hScenarioA := CalcScenario( aBases, 300, 0, 350 )
    
    hScenarioA["base_raw"] := hScenarioA["base"]
    hScenarioA["base"] := hScenarioA["base"] * ( 1 - ( nReductionCoef / 100 ) ) * nPensionPct
    hScenarioA["reduction"] := nReductionCoef
    hScenarioA["months_early"] := nMonthsEarly
    hScenarioA["pension_pct"] := nPensionPct // Store for debugging if needed

    // Scenario B: Transición
    aDualRow := oDb:Query( "SELECT meses_add, meses_descarte, divisor FROM transicion_dual WHERE year = " + cValToChar( nYearJub ) )
    
    if ! Empty( aDualRow )
    nExtra := AnyToNum( aDualRow[1][1] )
    nDiscard := AnyToNum( aDualRow[1][2] )
    nDivisor := AnyToNum( aDualRow[1][3] )
    nTotalMonths := 300 + nExtra
        
    hScenarioB := CalcScenario( aBases, nTotalMonths, nDiscard, nDivisor )
    else
    // Explain logic why 0
    MsgAlert( "No hay datos de Transición (transicion_dual) para el año: " + cValToChar( nYearJub ) + CRLF + ;
        "Asumiendo Método Normal." )
    hScenarioB := { "base" => 0, "sum" => 0, "months" => 0, "months_total" => 0, "divisor" => 0, "discarded" => 0, "lines" => {} }
    endif
    
    hScenarioB["base_raw"] := hScenarioB["base"]
    hScenarioB["base"] := hScenarioB["base"] * ( 1 - ( nReductionCoef / 100 ) ) * nPensionPct
    hScenarioB["reduction"] := nReductionCoef
    hScenarioB["months_early"] := nMonthsEarly
    hScenarioB["pension_pct"] := nPensionPct
    
return { "a" => hScenarioA, "b" => hScenarioB, "ipc_ref" => nIpcRef, "ipc_key" => cIpcKey }

//----------------------------------------------------------------------------//

function CalcScenario( aBases, nMonthsCount, nDiscardCount, nDivisor )
    local aSubset := {}
    local nTotal := 0
    local nLen := Len( aBases )
    local nStart := Max( 1, nLen - nMonthsCount + 1 )
    local i, aSorted, nKeep
    
    // Get subset (Last nMonthsCount)
    // aBases is sorted by date ASC (oldest first)
    // BUT we need default strict ASC
    
    for i := nStart to nLen
    AAdd( aSubset, aBases[i] )
    next
    
    if Len( aSubset ) == 0
    return { "base" => 0, "sum" => 0, "months" => 0, "months_total" => 0, "divisor" => nDivisor, "discarded" => 0, "lines" => {} }
    endif
    
    // Discard logic: Remove WORST months (Lowest Revalued Base)
    if nDiscardCount > 0
    // Sort by Revalued Base (Index 5) ASCENDING
    ASort( aSubset,,, { |x,y| x[5] < y[5] } )
        
    // Mark first nDiscardCount elements as Discarded
    for i := 1 to nDiscardCount
    if i <= Len( aSubset )
    aSubset[i][8] := 1 // Mark as Discarded
    endif
    next
    endif
    
    // Sum those NOT discarded
    nTotal := 0
    for i := 1 to Len( aSubset )
    if aSubset[i][8] == 0
    nTotal += aSubset[i][5]
    endif
    next

    // Sort by Date (Year, Month) ASC for display
    ASort( aSubset,,, { |x,y| Str(x[1],4)+Str(x[2],2) < Str(y[1],4)+Str(y[2],2) } )
    
    return { "base" => nTotal / nDivisor, ;
        "sum" => nTotal, ;
        "months" => Len( aSubset ) - nDiscardCount, ;
        "months_total" => nMonthsCount, ; 
        "divisor" => nDivisor, ;
        "discarded" => nDiscardCount, ;
        "lines" => aSubset }

//----------------------------------------------------------------------------//
// DUPLICATED HELPERS (Should be moved to Calculos.prg if time permits)

static function GetRevaluedBases( nUserId, dTarget, oDb )
    // ... [Copy content from Comparador.prg or make Shared] ...
    // For safety, I'll copy the body here, but slightly simplified if needed
    local aRows, aIpc, aParams, nLimitNoReval, nLimitGap100, hIpc, nYearJub
    local nMonthJub, nTotalMonthsJub, nRefTotal, nRefYear, nRefMonth, nRefIpc, aRes, nGapsFound, i, nCoef, nRevalued, cKey, cSql
    local nIdxUsed, nFilterDate
    
    aIpc := oDb:Query( "SELECT year, month, indice FROM ipc_indices ORDER BY year, month" )
    if Empty( aIpc ) ; return {} ; endif

    aParams := GetCalculosParams( oDb ) // Using shared function from Calculos.prg
    nLimitNoReval := Val( aParams["meses_sin_revalorizar"] )
    nLimitGap100 := Val( aParams["laguna_limite_100"] )
    hIpc := { => }
    nYearJub := Year( dTarget )
    nMonthJub := Month( dTarget )
    
    // Original Date for IPC/Revaluation calculations (User Request: "IPC ref counts")
    nTotalMonthsJub := ( nYearJub * 12 + nMonthJub - 1 )
    
    // LAG FILTER DATE: 2 months previous do not count for contributions.
    nFilterDate := nTotalMonthsJub - 2
    
    nRefTotal := nTotalMonthsJub - nLimitNoReval - 1
    nRefYear := Int( nRefTotal / 12 )
    nRefMonth := ( nRefTotal % 12 ) + 1
    nRefIpc := 1
    aRes := {}
    
    nGapsFound := 0
    
    if nLimitNoReval == 0 ; nLimitNoReval := 24 ; endif
    if nLimitGap100 == 0 ; nLimitGap100 := 48 ; endif

    AEval( aIpc, { | a | hIpc[ AllTrim( Str( Int( AnyToNum( a[1] ) ) ) ) + "-" + AllTrim( Str( Int( AnyToNum( a[2] ) ) ) ) ] := AnyToNum( a[3] ) } )
    
    cKey := AllTrim( Str( Int( nRefYear ) ) ) + "-" + AllTrim( Str( Int( nRefMonth ) ) )
    if cKey $ hIpc
    nRefIpc := hIpc[ cKey ]
    else
    nRefIpc := 0
    endif
    
    cSql := "SELECT year, month, amount, es_laguna FROM cotizaciones WHERE user_id = " + cValToChar( nUserId ) + " ORDER BY year DESC, month DESC" 
    
    aRows := oDb:Query( cSql )
    if Empty( aRows ) ; return {} ; endif

    for i := 1 to Len( aRows )
    
    // FUTURE FILTER: Ignore rows future to Retirement Date (e.g. simulating past year)
    // These should NOT count as gaps.
    if ( AnyToNum( aRows[i][1] ) * 12 + AnyToNum( aRows[i][2] ) - 1 ) > nTotalMonthsJub
    loop
    endif
        
    nCoef := 1.0
    nRevalued := AnyToNum( aRows[i][3] )
        
    // Gap Logic (Reverse Order: Newest First)
    if AnyToNum( aRows[i][4] ) == 1 
    nGapsFound++
    if nGapsFound > nLimitGap100 ; nRevalued := nRevalued * 0.5 ; endif
    endif

    // LAG FILTER: Ignore rows after Filter Date (Simulated - 2 months)
    // Note: Even if filtered, the gap was already counted above.
    if ( AnyToNum( aRows[i][1] ) * 12 + AnyToNum( aRows[i][2] ) - 1 ) > nFilterDate
    loop
    endif
        
    nIdxUsed := 0

    // Check revaluation date limit
    // Compare against nTotalMonthsJub (Effective calculated date)
    if ( nTotalMonthsJub - ( AnyToNum( aRows[i][1] ) * 12 + AnyToNum( aRows[i][2] ) - 1 ) ) > nLimitNoReval
    cKey := AllTrim( Str( Int( AnyToNum( aRows[i][1] ) ) ) ) + "-" + AllTrim( Str( Int( AnyToNum( aRows[i][2] ) ) ) )
    if nRefIpc > 0 .and. cKey $ hIpc .and. hIpc[ cKey ] > 0
    nIdxUsed := hIpc[ cKey ]
    nCoef := nRefIpc / nIdxUsed
    nRevalued := nRevalued * nCoef
    endif
    endif
    
    // Structure: 1:Year, 2:Month, 3:Amount, 4:Gap, 5:Revalued, 6:IPC_Idx, 7:Coef
    AAdd( aRes, { AnyToNum( aRows[i][1] ), ;
        AnyToNum( aRows[i][2] ), ;
        AnyToNum( aRows[i][3] ), ;
        AnyToNum( aRows[i][4] ), ;
        nRevalued, ;
        nIdxUsed, ;
        nCoef, ;
        0 } ) // 8: Discarded (0=No, 1=Yes)
    next i
    
    // Restore ASC order for calculation consistency
    ASort( aRes, , , { |x, y| x[1] < y[1] .or. ( x[1] == y[1] .and. x[2] < y[2] ) } )
    
    return { "bases" => aRes, ;
        "ipc" => nRefIpc, ;
        "key" => AllTrim( Str( Int( nRefYear ) ) ) + "-" + AllTrim( Str( Int( nRefMonth ) ) ) }

//----------------------------------------------------------------------------//

function ShowDualDetail( aBases, nRefIpc, oParent )

    local oWnd, oBrw, oBtnClose, oBtnExcel, oSayHeader
    local cTitle := "Detalle de Bases (Revalorizadas con IPC Ref: " + AllTrim( Str( nRefIpc ) ) + ")"

    
    if ValType( aBases ) != "A" .or. Len( aBases ) == 0
    MsgAlert( "No hay datos detallados para mostrar." )
    return nil
    endif
    
    // Sort Descending (Newest first)
    ASort( aBases, , , { |x, y| x[1] > y[1] .or. ( x[1] == y[1] .and. x[2] > y[2] ) } )
    
    DEFINE WINDOW oWnd TITLE cTitle SIZE 820, 680 FLIPPED 
    
    @ 20, 20 SWIFTSAY oSayHeader PROMPT cTitle OF oWnd SIZE 780, 25
    oSayHeader:SetFont( "Helvetica-Bold", 16 )

    @ 60, 10 BROWSE oBrw OF oWnd SIZE 800, 520 ;
        HEADERS "Año", "Mes", "Base Nom.", "IPC", "Coef.", "Base Reval.", "Laguna", "Descarte" ;
        FIELDS "", "", "", "", "", "", "", "" ;
        AUTORESIZE 18

    oBrw:SetArray( aBases )
    oBrw:bLine = { | nRow | If( nRow <= Len( aBases ), ;
        { Str( aBases[ nRow ][1], 4 ), ;
        StrZero( aBases[ nRow ][2], 2 ), ;
        Transform( aBases[ nRow ][3], "@E 99,999.99" ), ;
        Transform( aBases[ nRow ][6], "@E 999.99" ), ;
        Transform( aBases[ nRow ][7], "@E 99.9999999" ), ; 
        Transform( aBases[ nRow ][5], "@E 99,999.99" ), ;
        If( aBases[ nRow ][4] == 1, "SI", "NO" ), ;
        If( aBases[ nRow ][8] == 1, "SI", "NO" ) }, ;
        { "", "", "", "", "", "", "", "" } ) }

    oBrw:SetRowHeight( 25 )
    oBrw:SetFont( "Helvetica", 12 )
    oBrw:SetAlternateColor( .T. )
    
    @ 600, 260 SWIFTBUTTON oBtnExcel PROMPT "Exportar Excel (CSV)" OF oWnd SIZE 200, 40 ;
        ACTION ExportDualToExcel( aBases )
    oBtnExcel:SetGlass( .T. )
    oBtnExcel:SetImage( "tablecells" )
    
    @ 600, 480 SWIFTBUTTON oBtnClose PROMPT "Cerrar" OF oWnd SIZE 120, 40 ;
        ACTION oWnd:End()
    oBtnClose:SetGlass( .T. )
    oBtnClose:SetImage( "xmark" )
    
    ACTIVATE WINDOW oWnd CENTERED 
    
return nil

function ExportDualToExcel( aBases )
    local cFile := SaveFile( "Guardar como CSV", "csv" )
    local cText := "Año;Mes;Base Nominal;IPC;Coeficiente;Base Reval;Laguna;Descarte" + CRLF
    local i
    
    if Empty( cFile ) ; return nil ; endif
    
    if Right( Lower( cFile ), 4 ) != ".csv"
    cFile += ".csv"
    endif
    
    for i := 1 to Len( aBases )
    cText += Str( aBases[i][1], 4 ) + ";" + ;
        StrZero( aBases[i][2], 2 ) + ";" + ;
        Transform( aBases[i][3], "@E 99,999.99" ) + ";" + ;
        Transform( aBases[i][6], "@E 999.99" ) + ";" + ;
        Transform( aBases[i][7], "@E 99.9999999" ) + ";" + ;
        Transform( aBases[i][5], "@E 99,999.99" ) + ";" + ;
        If( aBases[i][4] == 1, "SI", "NO" ) + ";" + ;
        If( aBases[i][8] == 1, "SI", "NO" ) + CRLF
    next
    
    hb_MemoWrit( cFile, cText )
    
    MsgInfo( "Fichero generado: " + cFile )
return nil
