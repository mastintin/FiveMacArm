#include "FiveMac.ch"

// Shared Stack Item Class for both TSwiftVStack and TSwiftZStack
// All methods now expect and return String IDs from Swift

CLASS TSwiftStackItem
    DATA cId         // Unique String ID from Swift
    DATA oOwner      // Parent (can be TSwiftVStack/ZStack or another TSwiftStackItem)
    DATA bAction     // Codeblock to execute on action
    
    DATA aBatch      INIT {}

    ACCESS Text        INLINE ::GetText()
    
    ASSIGN OnClick( b )  INLINE ::bAction := b
    ASSIGN OnAction( b ) INLINE ::bAction := b
    
    ASSIGN Color( n )   INLINE ::SetColor( n )
    ASSIGN BgColor( n ) INLINE ::SetBgColor( n )

    METHOD New( cId, oOwner )
    
    METHOD Root() 
    METHOD RegItem( cId, oItem )
    
    // Nesting
    METHOD AddHStack()
    METHOD AddVStack()
    
    // Elements
    METHOD AddText( cText, bAction )
    METHOD AddSystemImage( cName )
    METHOD AddSpacer()
    METHOD AddDivider()
    METHOD AddButton( cText, bAction )
    METHOD AddToggle( cCaption, lOn, bAction, lSwitch, cId )
    METHOD AddSlider( nVal, nMin, nMax, bAction, lGlass, cId )
    METHOD SetLastItemId( cId )
    
    // Advanced Containers
    METHOD AddGrid( aColumns ) 
    METHOD AddList()           
    
    // Batch
    METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD AddBatch( aItems )

    METHOD SetSize( nWidth, nHeight )
    METHOD SetSpacing( nSpacing )
    METHOD SetText( cText )
    METHOD GetText()
    METHOD SetFont( nSize, lBold )
    METHOD SetColor( nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD SetBgColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetRadius( nRadius )
    METHOD OnAction()
    METHOD End()

ENDCLASS

METHOD OnAction() CLASS TSwiftStackItem
    if ::bAction != nil
        Eval( ::bAction, ::cId, Self )
    endif
return nil

METHOD New( cId, oOwner ) CLASS TSwiftStackItem
    ::cId := cId
    ::oOwner := oOwner
    ::aBatch := {}
    SwiftRegisterItem( ::cId, Self )
return Self

METHOD End() CLASS TSwiftStackItem
    SwiftUnregisterItem( ::cId )
    ::cId := ""
return nil

METHOD Root() CLASS TSwiftStackItem
    local oParent := ::oOwner
    while oParent != nil .and. oParent:IsKindOf( "TSWIFTSTACKITEM" )
    oParent := oParent:oOwner
    end
return oParent

METHOD RegItem( cId, uValue ) CLASS TSwiftStackItem
    SwiftRegisterItem( cId, uValue )
return nil

METHOD SetLastItemId( cId ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    oRoot:SetLastItemId( cId )
    ::cId := cId
    ::RegItem( cId, Self )
return nil

// --- Nesting Support ---

METHOD AddHStack() CLASS TSwiftStackItem
    local cId, oItem
    local oRoot := ::Root()
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := SD_VSTK_ADD_HSTACK( oRoot:cId, ::cId )
    else
    cId := SD_ZSTK_ADD_HSTACK( oRoot:cId, ::cId )
    endif
    oItem := TSwiftStackItem():New( cId, Self )
return oItem

METHOD AddVStack() CLASS TSwiftStackItem
    local cId, oItem
    local oRoot := ::Root()
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := SD_VSTK_ADD_VSTACK( oRoot:cId, ::cId )
    else
    cId := SD_ZSTK_ADD_VSTACK( oRoot:cId, ::cId )
    endif
    oItem := TSwiftStackItem():New( cId, Self )
return oItem

// --- Element Support ---

METHOD AddText( cText, bAction ) CLASS TSwiftStackItem
return TSwiftLabelStack():New( Self, cText, nil, bAction )

METHOD AddSystemImage( cName ) CLASS TSwiftStackItem
    local cId
    local oRoot := ::Root()
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := SD_VSTK_ADD_SYSTEM_IMAGE_TO( oRoot:cId, cName, ::cId )
    else
    cId := SD_ZSTK_ADD_SYSTEM_IMAGE_TO( oRoot:cId, cName, ::cId )
    endif
return TSwiftStackItem():New( cId, Self )

METHOD AddButton( cText, bAction ) CLASS TSwiftStackItem
return TSwiftButtonStack():New( Self, cText, nil, bAction )

METHOD AddToggle( cCaption, lOn, bAction, lSwitch, cId ) CLASS TSwiftStackItem
return TSwiftToggleStack():New( Self, cCaption, lOn, lSwitch, cId, bAction )

METHOD AddSlider( nVal, nMin, nMax, bAction, lGlass, cId ) CLASS TSwiftStackItem
return TSwiftSliderStack():New( Self, nVal, nMin, nMax, lGlass, cId, bAction )

METHOD AddSpacer() CLASS TSwiftStackItem
    local oRoot := ::Root()
    local cId
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := SD_VSTK_ADD_SPACER_TO( oRoot:cId, ::cId )
    else 
    cId := SD_ZSTK_ADD_SPACER( oRoot:cId, ::cId )
    endif
return TSwiftStackItem():New( cId, Self )

METHOD AddDivider() CLASS TSwiftStackItem
    local oRoot := ::Root()
    local cId
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := SD_VSTK_ADD_DIVIDER_TO( oRoot:cId, ::cId )
    else 
    cId := SD_ZSTK_ADD_DIVIDER( oRoot:cId, ::cId )
    endif
return TSwiftStackItem():New( cId, Self )


// --- Advanced Containers ---

METHOD AddGrid( aColumns ) CLASS TSwiftStackItem
    local cJson := "["
    local n, oItem, cId
    local oRoot := ::Root()
    
    DEFAULT aColumns := {}
    for n := 1 to Len( aColumns )
    if n > 1 ; cJson += "," ; endif
    cJson += "{"
    do case
    case Lower( aColumns[n][1] ) == "fixed"
    cJson += '"type":"fixed","size":' + AllTrim( Str( aColumns[n][2] ) )
    case Lower( aColumns[n][1] ) == "flexible"
    cJson += '"type":"flexible"'
    if Len( aColumns[n] ) >= 2 ; cJson += ',"min":' + AllTrim( Str( aColumns[n][2] ) ) ; endif
    if Len( aColumns[n] ) >= 3 ; cJson += ',"max":' + AllTrim( Str( aColumns[n][3] ) ) ; endif
    case Lower( aColumns[n][1] ) == "adaptive"
    cJson += '"type":"adaptive"'
    if Len( aColumns[n] ) >= 2 ; cJson += ',"min":' + AllTrim( Str( aColumns[n][2] ) ) ; endif
    if Len( aColumns[n] ) >= 3 ; cJson += ',"max":' + AllTrim( Str( aColumns[n][3] ) ) ; endif
    endcase
    cJson += "}"
    next
    cJson += "]"
    
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := SD_VSTK_ADD_LAZYVGRID( oRoot:cId, ::cId, cJson )
    else
    cId := SD_ZSTK_ADD_LAZYVGRID( oRoot:cId, ::cId, cJson )
    endif
    
    oItem := TSwiftStackItem():New( cId, Self )
return oItem

METHOD AddList() CLASS TSwiftStackItem
    local oItem, cId
    local oRoot := ::Root()
    
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := SD_VSTK_ADD_LIST( oRoot:cId, ::cId )
    else
    cId := SD_ZSTK_ADD_LIST( oRoot:cId, ::cId )
    endif
    
    oItem := TSwiftStackItem():New( cId, Self )
return oItem

// --- Batch Support ---

METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftStackItem
    AAdd( ::aBatch, { "type" => nType, "content" => cContent, "action" => bAction, ;
        "secondaryContent" => cSecondary, "nClrFore" => nClrFore, "nClrBack" => nClrBack, ;
        "nAlphaFore" => nAlphaFore, "nAlphaBack" => nAlphaBack } )
return nil

METHOD AddBatch( aItems ) CLASS TSwiftStackItem
    local aJsonData := {}
    local aIds, n, cJson, cJsonIds, aRGBA
    local oTempItem, hItem
    local oRoot := ::Root()
    
    DEFAULT aItems := ::aBatch
    if Empty( aItems ) ; return {} ; endif

    for n := 1 to Len( aItems )
    hItem := { "type" => aItems[n]["type"], ;
        "content" => aItems[n]["content"], ;
        "secondaryContent" => If( hb_HHasKey( aItems[n], "secondaryContent" ), aItems[n]["secondaryContent"], nil ) }
        
    if hb_HHasKey( aItems[n], "nClrBack" ) .and. aItems[n]["nClrBack"] != nil
        if aItems[n]["nClrBack"] == -2 .or. ( hb_HHasKey( aItems[n], "isProminent" ) .and. aItems[n]["isProminent"] )
            hItem["isProminent"] := .T.
        else
            aRGBA := hb_ClrToRGBA( aItems[n]["nClrBack"], aItems[n]["nAlphaBack"] )
            hItem["bgColor"] := { "r" => aRGBA[1], "g" => aRGBA[2], "b" => aRGBA[3], "a" => aRGBA[4] }
        endif
    endif
        
    if hb_HHasKey( aItems[n], "nClrFore" ) .and. aItems[n]["nClrFore"] != nil
        aRGBA := hb_ClrToRGBA( aItems[n]["nClrFore"], aItems[n]["nAlphaFore"] )
        hItem["fgColor"] := { "r" => aRGBA[1], "g" => aRGBA[2], "b" => aRGBA[3], "a" => aRGBA[4] }
    endif
    AAdd( aJsonData, hItem )
    next
   
    cJson := hb_jsonEncode( aJsonData )
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cJsonIds := SD_VSTK_ADD_BATCH( oRoot:cId, cJson, ::cId ) 
    else
    cJsonIds := SD_ZSTK_ADD_BATCH( oRoot:cId, cJson, ::cId ) 
    endif
   
    aIds := hb_jsonDecode( cJsonIds )
    if ValType( aIds ) == "A"
    for n := 1 to Len( aIds )
    if n <= Len( aItems ) .and. hb_HHasKey( aItems[n], "action" ) .and. !Empty( aItems[n]["action"] )
    oTempItem := TSwiftStackItem():New( aIds[n], Self )
    oTempItem:bAction := aItems[n]["action"]
    SwiftRegisterItem( aIds[n], oTempItem )
    endif
    next
    endif
    
    if ValType( aItems ) == "A" .and. aItems == ::aBatch
    ::aBatch := {} 
    endif
return aIds

METHOD SetSize( nWidth, nHeight ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    DEFAULT nWidth := 0, nHeight := 0
    if oRoot:IsKindOf( "TSWIFTLIST" )
        SD_LST_SET_ITEM_LAYOUT( oRoot:cId, ::cId, hb_ntos( nWidth ), hb_ntos( nHeight ), "-1" )
    elseif oRoot:IsKindOf( "TSWIFTZSTACK" )
        SD_ZSTK_SET_ITEM_LAYOUT( oRoot:cId, ::cId, hb_ntos( nWidth ), hb_ntos( nHeight ), "-1" )
    else
        SD_VSTK_SET_ITEM_LAYOUT( oRoot:cId, ::cId, hb_ntos( nWidth ), hb_ntos( nHeight ), "-1" )
    endif
return nil

METHOD SetSpacing( nSpacing ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    DEFAULT nSpacing := 8
    if oRoot:IsKindOf( "TSWIFTLIST" )
        SD_LST_SET_ITEM_LAYOUT( oRoot:cId, ::cId, "0", "0", hb_ntos( nSpacing ) )
    elseif oRoot:IsKindOf( "TSWIFTZSTACK" )
        SD_ZSTK_SET_ITEM_LAYOUT( oRoot:cId, ::cId, "0", "0", hb_ntos( nSpacing ) )
    else
        SD_VSTK_SET_ITEM_LAYOUT( oRoot:cId, ::cId, "0", "0", hb_ntos( nSpacing ) )
    endif
return nil

METHOD SetText( cText ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    if oRoot:IsKindOf( "TSWIFTLIST" )
        SD_LST_SET_ITEM_TEXT( oRoot:cId, ::cId, cText )
    elseif oRoot:IsKindOf( "TSWIFTZSTACK" )
        SD_ZSTK_SET_ITEM_TEXT( oRoot:cId, ::cId, cText )
    else
        SD_VSTK_SET_ITEM_TEXT( oRoot:cId, ::cId, cText )
    endif
return nil

METHOD GetText() CLASS TSwiftStackItem
    local oRoot := ::Root()
return SD_SW_GET_ITEM_TEXT( oRoot:cId, ::cId )

METHOD SetFont( nSize, lBold ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    DEFAULT nSize := 0, lBold := .F.
    if oRoot:IsKindOf( "TSWIFTLIST" )
        SD_LST_SET_ITEM_FONT( oRoot:cId, ::cId, hb_ntos( nSize ), lBold )
    elseif oRoot:IsKindOf( "TSWIFTZSTACK" )
        SD_ZSTK_SET_ITEM_FONT( oRoot:cId, ::cId, hb_ntos( nSize ), If( lBold, "1", "0" ) )
    else
        SD_VSTK_SET_ITEM_FONT( oRoot:cId, ::cId, hb_ntos( nSize ), If( lBold, "1", "0" ) )
    endif
return nil

METHOD SetColor( nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    
    DEFAULT nAlphaFore := 255
    DEFAULT nAlphaBack := 255

    if oRoot:IsKindOf( "TSWIFTLIST" )
        if nClrFore != nil
            SD_LST_SET_ITEM_COLOR( oRoot:cId, ::cId, nClrFore, nAlphaFore )
        endif
        if nClrBack != nil
            SD_LST_SET_ITEM_BGCOLOR( oRoot:cId, ::cId, nClrBack, nAlphaBack )
        endif
    elseif oRoot:IsKindOf( "TSWIFTZSTACK" )
        if nClrFore != nil
            SD_ZSTK_SET_ITEM_COLOR( oRoot:cId, ::cId, nClrFore, nAlphaFore )
        endif
        if nClrBack != nil
            SD_ZSTK_SET_ITEM_BGCOLOR( oRoot:cId, ::cId, nClrBack, nAlphaBack )
        endif
    else
        if nClrFore != nil
            SD_VSTK_SET_ITEM_COLOR( oRoot:cId, ::cId, nClrFore, nAlphaFore )
        endif
        if nClrBack != nil
            SD_VSTK_SET_ITEM_BGCOLOR( oRoot:cId, ::cId, nClrBack, nAlphaBack )
        endif
    endif

return nil

METHOD SetBgColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    local nClr 
    DEFAULT nAlpha := 255
    
    if pcount() <= 2
    nClr   := nRed
    else
    nClr := nRGB( nRed, nGreen, nBlue )
    endif

    if oRoot:IsKindOf( "TSWIFTLIST" )
        SD_LST_SET_ITEM_BGCOLOR( oRoot:cId, ::cId, nClr, nAlpha )
    elseif oRoot:IsKindOf( "TSWIFTZSTACK" )
        SD_ZSTK_SET_ITEM_BGCOLOR( oRoot:cId, ::cId, nClr, nAlpha )
    else
        SD_VSTK_SET_ITEM_BGCOLOR( oRoot:cId, ::cId, nClr, nAlpha )
    endif
return nil

METHOD SetRadius( nRadius ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    DEFAULT nRadius := 0
    if oRoot:IsKindOf( "TSWIFTLIST" )
        SD_LST_SET_ITEM_RADIUS( oRoot:cId, ::cId, nRadius )
    elseif oRoot:IsKindOf( "TSWIFTZSTACK" )
        SD_ZSTK_SET_ITEM_RADIUS( oRoot:cId, ::cId, nRadius )
    else
        SD_VSTK_SET_ITEM_RADIUS( oRoot:cId, ::cId, nRadius )
    endif
return nil
