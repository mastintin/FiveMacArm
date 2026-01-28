// NiceLayout.prg - Containers and Layouts

//----------------------------------------------------------------------------//
// Container Base
//----------------------------------------------------------------------------//

CLASS TNiceContainer FROM TNiceControl
    DATA aControls INIT {}
    METHOD Add( oControl )
    METHOD GetHtmlChildren()
ENDCLASS

METHOD Add( oControl ) CLASS TNiceContainer
    AAdd( ::aControls, oControl )
return nil

METHOD GetHtmlChildren() CLASS TNiceContainer
    local cHtml := ""
    local oCtrl
    for each oCtrl in ::aControls
    cHtml += oCtrl:GetHtml() + " "
    next
return cHtml

//----------------------------------------------------------------------------//
// Nice HStack
//----------------------------------------------------------------------------//

CLASS TNiceHStack FROM TNiceContainer
    METHOD New( oParent, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cClass, cStyle ) CLASS TNiceHStack
    ::Super:New( oParent, cClass, cStyle )
return Self

METHOD GetHtml() CLASS TNiceHStack
    local cHtml := '<div class="row q-gutter-md ' + ::cClass + '" '
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif
    cHtml += '>'
    cHtml += ::GetHtmlChildren()
    cHtml += '</div>'
return cHtml

//----------------------------------------------------------------------------//
// Nice VStack
//----------------------------------------------------------------------------//

CLASS TNiceVStack FROM TNiceContainer
    METHOD New( oParent, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cClass, cStyle ) CLASS TNiceVStack
    ::Super:New( oParent, cClass, cStyle )
return Self

METHOD GetHtml() CLASS TNiceVStack
    local cHtml := ""
    cHtml := '<div class="column q-gutter-md ' + ::cClass + '" '
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif
    cHtml += '>'
    cHtml += ::GetHtmlChildren()
    cHtml += '</div>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Card
//----------------------------------------------------------------------------//

CLASS TNiceCard FROM TNiceContainer
    DATA nRadius       INIT 4
    DATA cBorderColor  INIT ""
    DATA nBorderWidth  INIT 0
    DATA cBorderSide   INIT "all"  // "all", "left", "right", "top", "bottom"
    
    METHOD New( oParent, cClass, cStyle )
    METHOD GetHtml()
    METHOD SetRadius( nRadius )    INLINE ::nRadius := nRadius
    METHOD SetBorderColor( cCol )  INLINE ::cBorderColor := cCol
    METHOD SetBorderWidth( nWidth ) INLINE ::nBorderWidth := nWidth
    METHOD SetBorderSide( cSide )  INLINE ::cBorderSide := if( cSide != nil, Lower( cSide ), "all" )
ENDCLASS

METHOD New( oParent, cClass, cStyle ) CLASS TNiceCard
    ::Super:New( oParent, cClass, cStyle )
return Self

METHOD GetHtml() CLASS TNiceCard
    local cHtml := '<q-card class="' + ::cClass + '" '
    local cStyle := ::cStyle
    local cBorder := ""
    
    if ::nRadius != 4 .or. !Empty( ::cBorderColor )
    if !Empty( cStyle ) .and. Right( AllTrim(cStyle), 1 ) != ";"
    cStyle += ";"
    endif
        
    if ::nRadius != 4
    cStyle += "border-radius: " + AllTrim(Str(::nRadius)) + "px;"
    endif
        
    if !Empty( ::cBorderColor )
    cBorder := AllTrim(Str(Max(::nBorderWidth, 1))) + "px solid " + ::cBorderColor + ";"
    if ::cBorderSide == "all"
    cStyle += "border: " + cBorder
    elseif ::cBorderSide == "left"
    cStyle += "border-left: " + cBorder
    elseif ::cBorderSide == "right"
    cStyle += "border-right: " + cBorder
    elseif ::cBorderSide == "top"
    cStyle += "border-top: " + cBorder
    elseif ::cBorderSide == "bottom"
    cStyle += "border-bottom: " + cBorder
    endif
    endif
    endif

    if !Empty( cStyle )
    cHtml += 'style="' + cStyle + '" '
    else
    cHtml += 'style="min-width: 100px;" '
    endif
    cHtml += '>'
    cHtml += '<q-card-section>'
    cHtml += ::GetHtmlChildren()
    cHtml += '</q-card-section>'
    cHtml += '</q-card>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Drawer (Sidebar)
//----------------------------------------------------------------------------//

CLASS TNiceDrawer FROM TNiceContainer
    DATA lOpen INIT .T.
    DATA cSide INIT "left"
    
    METHOD New( oPage, cSide, cClass, cStyle, cJs )
    METHOD GetHtml()
ENDCLASS

METHOD New( oPage, cSide, cClass, cStyle, cJs ) CLASS TNiceDrawer
    ::Super:New( oPage, cClass, cStyle, cJs )
    ::cSide := cSide
    DEFAULT ::cSide := "left"
    oPage:SetDrawer( Self )
return Self

METHOD GetHtml() CLASS TNiceDrawer
    local cHtml := '<q-drawer v-model="drawerOpen" bordered '
    cHtml += 'side="' + ::cSide + '" '
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif
    cHtml += '>'
    cHtml += '<q-list>'
    cHtml += ::GetHtmlChildren()
    cHtml += '</q-list>'
    cHtml += '</q-drawer>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Drawer Item
//----------------------------------------------------------------------------//

CLASS TNiceDrawerItem FROM TNiceControl
    DATA cLabel
    DATA cIcon
    
    METHOD New( oDrawer, cLabel, cIcon, bAction, cClass, cStyle, cJs )
    METHOD GetHtml()
ENDCLASS

METHOD New( oDrawer, cLabel, cIcon, bAction, cClass, cStyle, cJs ) CLASS TNiceDrawerItem
    ::Super:New( oDrawer, cClass, cStyle, cJs )
    ::cLabel  := cLabel
    ::cIcon   := cIcon
    ::bAction := bAction
return Self

METHOD GetHtml() CLASS TNiceDrawerItem
    local cHtml := '<q-item clickable v-ripple '
    if !Empty( ::cClass )
    cHtml += 'class="' + ::cClass + '" '
    endif
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif

    cHtml += '@click="handleClick(' + "'" + ::cId + "', '" + ::cJs + "')" + '" '

    cHtml += '>'
    if !Empty( ::cIcon )
    cHtml += '<q-item-section avatar><q-icon name="' + ::cIcon + '" /></q-item-section>'
    endif
    cHtml += '<q-item-section>' + ::cLabel + '</q-item-section>'
    cHtml += '</q-item>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Grid
//----------------------------------------------------------------------------//

CLASS TNiceGrid FROM TNiceContainer
    DATA nCols
    METHOD New( oParent, nCols, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, nCols, cClass, cStyle ) CLASS TNiceGrid
    ::Super:New( oParent, cClass, cStyle )
    ::nCols := nCols
    DEFAULT ::nCols := 3
return Self

METHOD GetHtml() CLASS TNiceGrid
    local cHtml := '<div class="row q-col-gutter-md ' + ::cClass + '" '
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif
    cHtml += '>'
    cHtml += ::GetHtmlChildren()
    cHtml += '</div>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Tabs
//----------------------------------------------------------------------------//

CLASS TNiceTabs FROM TNiceControl
    DATA aTabs INIT {}
    DATA cName
    DATA lVertical
    
    METHOD New( oParent, lVertical )
    METHOD Add( oTab )
    METHOD GetHtml()
    METHOD GetModelName()
    METHOD GetModelValue()
ENDCLASS

METHOD New( oParent, lVertical ) CLASS TNiceTabs
    ::Super:New( oParent )
    ::cName := ::cId + "_tab"
    ::lVertical := lVertical
    DEFAULT ::lVertical := .F.
return Self

METHOD Add( oTab ) CLASS TNiceTabs
    AAdd( ::aTabs, oTab )
return nil

METHOD GetHtml() CLASS TNiceTabs
    local cHtml := ""
    local oTab
    local cClass := If( ::lVertical, "row full-width", "column full-width" )
    local cSep   := If( ::lVertical, "vertical", "" )
    local cTabsClass := "text-primary"
    
    if ::lVertical 
    cTabsClass += " col-auto"
    endif

    cHtml += '<div class="' + cClass + '">'
    
    // Header (QTabs)
    cHtml += '<q-tabs v-model="' + ::GetModelName() + '" class="' + cTabsClass + '" '
    if ::lVertical
    cHtml += ' vertical'
    endif
    cHtml += '>'
    
    for each oTab in ::aTabs
    cHtml += '<q-tab name="' + oTab:cId + '" '
    cHtml += 'label="' + oTab:cLabel + '" '
    if !Empty( oTab:cIcon )
    cHtml += 'icon="' + oTab:cIcon + '" '
    endif
    cHtml += '></q-tab>'
    next
    cHtml += '</q-tabs>'
    
    // Content (QTabPanels)
    cHtml += '<q-separator ' + cSep + '></q-separator>'
    
    cHtml += '<q-tab-panels v-model="' + ::GetModelName() + '" animated '
    if ::lVertical
    cHtml += ' class="col"'
    endif
    cHtml += '>'
    
    for each oTab in ::aTabs
    cHtml += oTab:GetHtml()
    next
    cHtml += '</q-tab-panels>'
    
    cHtml += '</div>'
return cHtml

METHOD GetModelName() CLASS TNiceTabs
return ::cName

METHOD GetModelValue() CLASS TNiceTabs
    if Len( ::aTabs ) > 0
    return '"' + ::aTabs[1]:cId + '"'
    endif
return '""'

//----------------------------------------------------------------------------//
// Nice Tab (Child of Tabs)
//----------------------------------------------------------------------------//

CLASS TNiceTab FROM TNiceContainer
    DATA cLabel
    DATA cIcon
    
    METHOD New( oTabs, cLabel, cIcon )
    METHOD GetHtml() 
ENDCLASS

METHOD New( oTabs, cLabel, cIcon ) CLASS TNiceTab
    ::oParent := oTabs
    ::cLabel  := cLabel
    ::cIcon   := cIcon
    ::cId     := "tab_" + AllTrim(Str(Len(oTabs:aTabs) + 1)) + "_" + AllTrim(Str(Hb_RandomInt(9999)))
    ::Super:New( oTabs )
return Self

METHOD GetHtml() CLASS TNiceTab
    local cHtml := '<q-tab-panel name="' + ::cId + '">'
    cHtml += ::GetHtmlChildren()
    cHtml += '</q-tab-panel>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Expansion Item (Accordion)
//----------------------------------------------------------------------------//

CLASS TNiceExpansionItem FROM TNiceContainer
    DATA cLabel
    DATA cIcon
    DATA lOpen
    
    METHOD New( oParent, cLabel, cIcon, lOpen )
    METHOD GetHtml()
ENDCLASS

METHOD New( oParent, cLabel, cIcon, lOpen ) CLASS TNiceExpansionItem
    ::Super:New( oParent )
    ::cLabel  := cLabel
    ::cIcon   := cIcon
    ::lOpen   := lOpen
    DEFAULT ::lOpen := .F.
return Self

METHOD GetHtml() CLASS TNiceExpansionItem
    local cHtml := '<q-expansion-item '
    
    cHtml += 'label="' + ::cLabel + '" '
    if !Empty( ::cIcon )
    cHtml += 'icon="' + ::cIcon + '" '
    endif
    if ::lOpen
    cHtml += 'default-opened '
    endif
    
    // Style
    cHtml += 'header-class="text-primary" '
    cHtml += 'style="width: 100%" '
    
    cHtml += '>'
    
    cHtml += '<q-card><q-card-section>'
    cHtml += ::GetHtmlChildren()
    cHtml += '</q-card-section></q-card>'
    
    cHtml += '</q-expansion-item>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Header
//----------------------------------------------------------------------------//

CLASS TNiceHeader FROM TNiceContainer
    METHOD New( oPage, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oPage, cClass, cStyle ) CLASS TNiceHeader
    ::Super:New( oPage, cClass, cStyle )
    oPage:SetHeader( Self )
return Self

METHOD GetHtml() CLASS TNiceHeader
    local cHtml := '<q-header elevated class="' + ::cClass + '" '
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif
    cHtml += '>'
    cHtml += '<q-toolbar>'
    cHtml += ::GetHtmlChildren()
    cHtml += '</q-toolbar>'
    cHtml += '</q-header>'
return cHtml

//----------------------------------------------------------------------------//
// Nice Footer
//----------------------------------------------------------------------------//

CLASS TNiceFooter FROM TNiceContainer
    METHOD New( oPage, cClass, cStyle )
    METHOD GetHtml()
ENDCLASS

METHOD New( oPage, cClass, cStyle ) CLASS TNiceFooter
    ::Super:New( oPage, cClass, cStyle )
    oPage:SetFooter( Self )
return Self

METHOD GetHtml() CLASS TNiceFooter
    local cHtml := '<q-footer elevated class="' + ::cClass + '" '
    if !Empty( ::cStyle )
    cHtml += 'style="' + ::cStyle + '" '
    endif
    cHtml += '>'
    cHtml += '<q-toolbar>'
    cHtml += ::GetHtmlChildren()
    cHtml += '</q-toolbar>'
    cHtml += '</q-footer>'
return cHtml
