// NiceControls.prg - Standard Controls

//----------------------------------------------------------------------------//
// Nice Button
//----------------------------------------------------------------------------//

CLASS TNiceButton FROM TNiceControl
    DATA cLabel
    DATA cIcon
   
    METHOD New( oParent, cLabel, bAction, cIcon, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cLabel, bAction, cIcon, cClass, cStyle, cJs ) CLASS TNiceButton
    ::Super:New( oParent, cClass, cStyle, cJs )
    ::cLabel  := cLabel
    ::bAction := bAction
    ::cIcon   := cIcon
    DEFAULT ::cIcon := ""
return Self

METHOD GetHtml() CLASS TNiceButton
    local cHtml := '<q-btn color="primary" '
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif

    cHtml += 'label="' + ::cLabel + '" '
    if !Empty( ::cIcon )
    cHtml += 'icon="' + ::cIcon + '" '
    endif
    
    cHtml += '@click="handleClick(' + "'" + ::cId + "', '" + ::cJs + "')" + '" '
    cHtml += '></q-btn>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Input
//----------------------------------------------------------------------------//

CLASS TNiceInput FROM TNiceControl
    DATA cLabel
    DATA cValue
   
    METHOD New( oParent, cLabel, cValue, cClass, cStyle )
    METHOD GetHtml()
    METHOD GetModelName()
ENDCLASS

METHOD New( oParent, cLabel, cValue, cClass, cStyle ) CLASS TNiceInput
    ::Super:New( oParent, cClass, cStyle )
    ::cLabel := cLabel
    ::cValue := cValue
    DEFAULT ::cValue := ""
return Self

METHOD GetHtml() CLASS TNiceInput
    local cHtml := '<q-input outlined ' 
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif

    cHtml += 'label="' + ::cLabel + '" '
   
    // Two-way binding
    cHtml += 'v-model="' + ::GetModelName() + '" ' 
   
    // Simplified Updater
    cHtml += '@update:model-value="updateVal( ' + "'" + ::cId + "'" + ', $event )" '
   
    cHtml += '></q-input>'
return cHtml

METHOD GetModelName() CLASS TNiceInput
return ::cId + "_val"

//----------------------------------------------------------------------------//
// Nice Icon
//----------------------------------------------------------------------------//

CLASS TNiceIcon FROM TNiceControl
    DATA cName
    DATA cSize
    DATA cColor
    
    METHOD New( oParent, cName, cSize, cColor, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cName, cSize, cColor, cClass, cStyle ) CLASS TNiceIcon
    ::Super:New( oParent, cClass, cStyle )
    ::cName  := cName
    ::cSize  := cSize
    ::cColor := cColor
    DEFAULT ::cSize  := "md"
    DEFAULT ::cColor := "primary"
return Self

METHOD GetHtml() CLASS TNiceIcon
    local cHtml := '<q-icon name="' + ::cName + '" size="' + ::cSize + '" '
    cHtml += 'color="' + ::cColor + '" '
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif
    cHtml += '></q-icon>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Label (SAY)
//----------------------------------------------------------------------------//

CLASS TNiceLabel FROM TNiceControl
    DATA cText
    
    METHOD New( oParent, cText, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cText, cClass, cStyle ) CLASS TNiceLabel
    ::Super:New( oParent, cClass, cStyle )
    ::cText := cText
return Self

METHOD GetHtml() CLASS TNiceLabel
    local cHtml := '<div '
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif
    cHtml += '>' + ::cText + '</div>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Select (Combobox)
//----------------------------------------------------------------------------//

CLASS TNiceSelect FROM TNiceControl
    DATA cLabel
    DATA cValue
    DATA aOptions
   
    METHOD New( oParent, cId, cLabel, cValue, aOptions, cClass, cStyle )
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetAuxName()
    METHOD GetAuxValue()
ENDCLASS

METHOD New( oParent, cId, cLabel, cValue, aItems, cClass, cStyle ) CLASS TNiceSelect
    ::Super:New( oParent, cClass, cStyle )
    if !Empty( cId )
    ::cId := cId 
    endif
    ::cLabel   := cLabel
    ::cValue   := cValue
    ::aOptions := aItems 
    DEFAULT ::cValue := ""
    DEFAULT ::aOptions := {}
return Self

METHOD GetHtml() CLASS TNiceSelect
    local cHtml := '<q-select outlined '
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    else
    cHtml += 'style="min-width: 200px;" '
    endif

    cHtml += 'label="' + ::cLabel + '" '
    cHtml += 'v-model="' + ::GetModelName() + '" ' 
    cHtml += ':options="' + ::GetAuxName() + '" '
    
    // Update event
    cHtml += '@update:model-value="updateVal( ' + "'" + ::cId + "'" + ', $event )" '
    
    cHtml += '></q-select>'
return cHtml

METHOD GetModelName() CLASS TNiceSelect
return ::cId + "_val"

METHOD GetAuxName() CLASS TNiceSelect
return ::cId + "_opt"

METHOD GetAuxValue() CLASS TNiceSelect
    local cJson := "[", n
    for n := 1 to Len( ::aOptions )
    if n > 1 
    cJson += "," 
    endif
    cJson += "'" + ::aOptions[n] + "'"
    next
    cJson += "]"
return cJson

//----------------------------------------------------------------------------//
// Nice Checkbox
//----------------------------------------------------------------------------//

CLASS TNiceCheckbox FROM TNiceControl
    DATA cLabel
    DATA lValue
   
    METHOD New( oParent, cId, cLabel, lValue, cClass, cStyle )
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetModelValue()
ENDCLASS

METHOD New( oParent, cId, cLabel, lValue, cClass, cStyle ) CLASS TNiceCheckbox
    ::Super:New( oParent, cClass, cStyle )
    if !Empty( cId )
    ::cId := cId
    endif
    ::cLabel := cLabel
    ::lValue := lValue
    DEFAULT ::lValue := .F.
return Self

METHOD GetHtml() CLASS TNiceCheckbox
    local cHtml := '<q-checkbox '
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif

    cHtml += 'label="' + ::cLabel + '" '
    cHtml += 'v-model="' + ::GetModelName() + '" ' 
    
    // Update event
    cHtml += '@update:model-value="updateVal( ' + "'" + ::cId + "'" + ', $event )" '
    
    cHtml += '></q-checkbox>'
return cHtml

METHOD GetModelName() CLASS TNiceCheckbox
return ::cId + "_val"

METHOD GetModelValue() CLASS TNiceCheckbox
return If( ::lValue, "true", "false" )

//----------------------------------------------------------------------------//
// Nice Toggle (Switch)
//----------------------------------------------------------------------------//

CLASS TNiceToggle FROM TNiceCheckbox
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cId, cLabel, lValue, cClass, cStyle ) CLASS TNiceToggle
    ::Super:New( oParent, cId, cLabel, lValue, cClass, cStyle )
return Self

METHOD GetHtml() CLASS TNiceToggle
    local cHtml := '<q-toggle '
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif

    cHtml += 'label="' + ::cLabel + '" '
    cHtml += 'v-model="' + ::GetModelName() + '" ' 
    
    // Update event
    cHtml += '@update:model-value="updateVal( ' + "'" + ::cId + "'" + ', $event )" '
    
    cHtml += '></q-toggle>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Date (Datepicker)
//----------------------------------------------------------------------------//

CLASS TNiceDate FROM TNiceControl
    DATA cLabel
    DATA dValue
   
    METHOD New( oParent, cId, cLabel, dValue, cClass, cStyle )
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetModelValue()
ENDCLASS

METHOD New( oParent, cId, cLabel, dValue, cClass, cStyle ) CLASS TNiceDate
    ::Super:New( oParent, cClass, cStyle )
    if !Empty( cId )
    ::cId := cId
    endif
    ::cLabel := cLabel
    ::dValue := dValue
    DEFAULT ::dValue := Date()
return Self

METHOD GetHtml() CLASS TNiceDate
    local cHtml := '<q-input outlined ' 
    local cLocale := "{ days: 'Domingo_Lunes_Martes_Miércoles_Jueves_Viernes_Sábado'.split('_'), " + ;
        "daysShort: 'Dom_Lun_Mar_Mié_Jue_Vie_Sáb'.split('_'), " + ;
        "months: 'Enero_Febrero_Marzo_Abril_Mayo_Junio_Julio_Agosto_Septiembre_Octubre_Noviembre_Diciembre'.split('_'), " + ;
        "monthsShort: 'Ene_Feb_Mar_Abr_May_Jun_Jul_Ago_Sep_Oct_Nov_Dic'.split('_'), " + ;
        "firstDayOfWeek: 1 }"
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif

    // Label
    cHtml += 'label="' + ::cLabel + '" '
    
    // Model Binding
    cHtml += 'v-model="' + ::GetModelName() + '" ' 
    
    // Mask for Input (DD/MM/YYYY)
    cHtml += 'mask="##/##/####" '
    
    // Update event (for the input field)
    cHtml += '@update:model-value="updateVal( ' + "'" + ::cId + "'" + ', $event )" '
    
    cHtml += '>'
    
    // Append Slot (Icon + Popup)
    cHtml += '<template v-slot:append>'
    cHtml += '<q-icon name="event" class="cursor-pointer">'
    cHtml += '<q-popup-proxy cover transition-show="scale" transition-hide="scale">'
    
    // Date Component inside Popup
    cHtml += '<q-date v-model="' + ::GetModelName() + '" '
    cHtml += ':locale="' + cLocale + '" '
    cHtml += 'mask="DD/MM/YYYY" '
    cHtml += '@update:model-value="updateVal( ' + "'" + ::cId + "'" + ', $event )" '
    cHtml += '>'
    
    // Close button
    cHtml += '<div class="row items-center justify-end">'
    cHtml += '<q-btn v-close-popup label="Cerrar" color="primary" flat></q-btn>'
    cHtml += '</div>'
    
    cHtml += '</q-date>'
    cHtml += '</q-popup-proxy>'
    cHtml += '</q-icon>'
    cHtml += '</template>'
    
    cHtml += '</q-input>'
return cHtml

METHOD GetModelName() CLASS TNiceDate
return ::cId + "_val"

METHOD GetModelValue() CLASS TNiceDate
    // Convert Date to DD/MM/YYYY string for Quasar
    local cStr := StrZero( Day( ::dValue ), 2 ) + "/" + ;
        StrZero( Month( ::dValue ), 2 ) + "/" + ;
        hb_NtoS( Year( ::dValue ) )
return '"' + cStr + '"'

//----------------------------------------------------------------------------//
// Nice Badge
//----------------------------------------------------------------------------//

CLASS TNiceBadge FROM TNiceControl
    DATA cLabel
    DATA cColor
    DATA cTextColor
    DATA lFloating
    
    METHOD New( oParent, cId, cLabel, cColor, cTextColor, lFloating, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cId, cLabel, cColor, cTextColor, lFloating, cClass, cStyle ) CLASS TNiceBadge
    ::Super:New( oParent, cClass, cStyle )
    if !Empty( cId ); ::cId := cId; endif
    ::cLabel     := cLabel
    ::cColor     := cColor
    ::cTextColor := cTextColor
    ::lFloating  := lFloating
    DEFAULT ::lFloating := .F.
return Self

METHOD GetHtml() CLASS TNiceBadge
    local cHtml := '<q-badge '
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif

    if !Empty( ::cColor ); cHtml += 'color="' + ::cColor + '" '; endif
    if !Empty( ::cTextColor ); cHtml += 'text-color="' + ::cTextColor + '" '; endif
    if ::lFloating; cHtml += 'floating '; endif
    
    cHtml += '>' + ::cLabel + '</q-badge>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Chip
//----------------------------------------------------------------------------//

CLASS TNiceChip FROM TNiceControl
    DATA cLabel
    DATA cIcon
    DATA cColor
    DATA cTextColor
    
    METHOD New( oParent, cId, cLabel, cIcon, cColor, cTextColor, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cId, cLabel, cIcon, cColor, cTextColor, cClass, cStyle ) CLASS TNiceChip
    ::Super:New( oParent, cClass, cStyle )
    if !Empty( cId ); ::cId := cId; endif
    ::cLabel     := cLabel
    ::cIcon      := cIcon
    ::cColor     := cColor
    ::cTextColor := cTextColor
return Self

METHOD GetHtml() CLASS TNiceChip
    local cHtml := '<q-chip clickable '
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif

    if !Empty( ::cIcon ); cHtml += 'icon="' + ::cIcon + '" '; endif
    if !Empty( ::cColor ); cHtml += 'color="' + ::cColor + '" '; endif
    if !Empty( ::cTextColor ); cHtml += 'text-color="' + ::cTextColor + '" '; endif
    
    cHtml += '>' + ::cLabel + '</q-chip>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Progress (Linear)
//----------------------------------------------------------------------------//

CLASS TNiceProgress FROM TNiceControl
    DATA cLabel // Not rendered, but needed for Base
    DATA nValue // 0.0 - 1.0
    DATA cColor
    DATA nSize  // Height in pixels
    
    METHOD New( oParent, cId, nValue, cColor, nSize, cClass, cStyle )
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetModelValue()
ENDCLASS

METHOD New( oParent, cId, nValue, cColor, nSize, cClass, cStyle ) CLASS TNiceProgress
    ::Super:New( oParent, cClass, cStyle )
    if !Empty( cId ); ::cId := cId; endif
    
    ::nValue := nValue
    DEFAULT ::nValue := 0.0
    
    ::cColor := cColor
    ::nSize  := nSize // Default is nil (Quasar default)
return Self

METHOD GetHtml() CLASS TNiceProgress
    local cHtml := '<q-linear-progress '
    
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    else
    cHtml += 'class="q-mt-md" ' // Default margin
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif

    // Model Binding
    cHtml += ':value="' + ::GetModelName() + '" '
    
    if !Empty( ::cColor ); cHtml += 'color="' + ::cColor + '" '; endif
    if ::nSize != nil;     cHtml += 'size="' + AllTrim(Str(::nSize)) + 'px" '; endif
    
    cHtml += '></q-linear-progress>'
return cHtml

METHOD GetModelName() CLASS TNiceProgress
return ::cId + "_val"

METHOD GetModelValue() CLASS TNiceProgress
return AllTrim( Str( ::nValue ) )

//----------------------------------------------------------------------------//
// Nice Chart (ECharts wrapper)
//----------------------------------------------------------------------------//

CLASS TNiceChart FROM TNiceControl
    DATA cOptions // JSON String
    DATA nWidth
    DATA nHeight
    
    METHOD New( oParent, cOptions, nWidth, nHeight, cClass, cStyle )
    METHOD GetHtml()
    METHOD SetOptions( cOptions )
ENDCLASS

METHOD New( oParent, cOptions, nWidth, nHeight, cClass, cStyle ) CLASS TNiceChart
    ::Super:New( oParent, cClass, cStyle )
    ::cOptions := cOptions
    ::nWidth   := nWidth
    ::nHeight  := nHeight
    DEFAULT ::cOptions := "{}"
    DEFAULT ::nWidth   := 400
    DEFAULT ::nHeight  := 300
return Self

METHOD GetHtml() CLASS TNiceChart
    local cHtml := '<div id="' + ::cId + '" '
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    cHtml += 'style="'
    if !Empty( ::cStyle )
    cHtml += ::cStyle + ';'
    endif
    cHtml += 'width:' + AllTrim(Str(::nWidth)) + 'px;height:' + AllTrim(Str(::nHeight)) + 'px;" '
    cHtml += 'v-on:vnode-mounted="() => { '
    cHtml += '  let chart = echarts.init(document.getElementById(' + "'" + ::cId + "'" + ')); '
    cHtml += '  chart.setOption(' + ::cOptions + '); '
    cHtml += '  window.charts[' + "'" + ::cId + "'" + '] = chart; '
    cHtml += '}" '
    cHtml += '></div>'
return cHtml

METHOD SetOptions( cOptions ) CLASS TNiceChart
    local oPage := ::GetPage()
    ::cOptions := cOptions
    if oPage != nil .and. oPage:oWeb != nil
    // Update live chart if possible
    oPage:oWeb:ScriptCallMethodArg( "eval", "if(window.charts['" + ::cId + "']) window.charts['" + ::cId + "'].setOption(" + cOptions + ")" )
    endif
return nil
