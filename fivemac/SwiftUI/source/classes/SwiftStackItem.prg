#include "FiveMac.ch"

// Shared Stack Item Class for both TSwiftVStack and TSwiftZStack
// All methods now expect and return String IDs from Swift

CLASS TSwiftStackItem
    DATA cId         // Unique String ID from Swift
    DATA oOwner      // Parent (can be TSwiftVStack/ZStack or another TSwiftStackItem)
    DATA bAction     // Codeblock to execute on action
    
    DATA aBatch      INIT {}

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
    METHOD SetLastItemId( cId )
    
    // Styling
    
    // Advanced Containers
    METHOD AddGrid( aColumns ) 
    METHOD AddList()           
    
    // Batch
    METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD AddBatch( aItems )
    METHOD SetSize( nWidth, nHeight )
    METHOD SetSpacing( nSpacing )
    METHOD SetText( cText )
    METHOD SetFont( nSize, lBold )
    METHOD SetColor( nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD SetBgColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetRadius( nRadius )

ENDCLASS

METHOD New( cId, oOwner ) CLASS TSwiftStackItem
    ::cId := cId
    ::oOwner := oOwner
    ::aBatch := {}
    SwiftRegisterItem( ::cId, Self )
return Self

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
    cId := VSTK_ADD_HSTACK( hb_ntos( oRoot:nIndex ), ::cId )
    else
    cId := ZSTK_ADD_HSTACK( hb_ntos( oRoot:nIndex ), ::cId )
    endif
    oItem := TSwiftStackItem():New( cId, Self )
return oItem

METHOD AddVStack() CLASS TSwiftStackItem
    local cId, oItem
    local oRoot := ::Root()
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := VSTK_ADD_VSTACK( hb_ntos( oRoot:nIndex ), ::cId )
    else
    cId := ZSTK_ADD_VSTACK( hb_ntos( oRoot:nIndex ), ::cId )
    endif
    oItem := TSwiftStackItem():New( cId, Self )
return oItem

// --- Element Support ---

METHOD AddText( cText, bAction ) CLASS TSwiftStackItem
    local cId, oItem
    local oRoot := ::Root()
    
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := VSTK_ADD_TEXT_TO( hb_ntos( oRoot:nIndex ), cText, ::cId )
    else
    cId := ZSTK_ADD_TEXT_TO( hb_ntos( oRoot:nIndex ), cText, ::cId )
    endif
    
    oItem := TSwiftStackItem():New( cId, Self )
    if bAction != nil .and. !Empty( cId )
    oItem:bAction := bAction
    endif 
return oItem

METHOD AddSystemImage( cName ) CLASS TSwiftStackItem
    local cId
    local oRoot := ::Root()
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := VSTK_ADD_SYSTEM_IMAGE_TO( hb_ntos( oRoot:nIndex ), cName, ::cId )
    else
    cId := ZSTK_ADD_SYSTEM_IMAGE_TO( hb_ntos( oRoot:nIndex ), cName, ::cId )
    endif
return TSwiftStackItem():New( cId, Self )

METHOD AddButton( cText, bAction ) CLASS TSwiftStackItem
    local cId, oItem
    local oRoot := ::Root()
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := VSTK_ADD_BUTTON_ITEM( hb_ntos( oRoot:nIndex ), cText, ::cId )
    else
    cId := ZSTK_ADD_BUTTON_TO( hb_ntos( oRoot:nIndex ), cText, ::cId )
    endif
    
    oItem := TSwiftStackItem():New( cId, Self )
    if bAction != nil .and. !Empty( cId )
    oItem:bAction := bAction
    endif
return oItem

METHOD AddSpacer() CLASS TSwiftStackItem
    local oRoot := ::Root()
    local cId
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := VSTK_ADD_SPACER_TO( hb_ntos( oRoot:nIndex ), ::cId )
    else 
    cId := ZSTK_ADD_SPACER( hb_ntos( oRoot:nIndex ), ::cId )
    endif
return TSwiftStackItem():New( cId, Self )

METHOD AddDivider() CLASS TSwiftStackItem
    local oRoot := ::Root()
    local cId
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := VSTK_ADD_DIVIDER_TO( hb_ntos( oRoot:nIndex ), ::cId )
    else 
    cId := ZSTK_ADD_DIVIDER( hb_ntos( oRoot:nIndex ), ::cId )
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
    cId := VSTK_ADD_LAZYVGRID( hb_ntos( oRoot:nIndex ), ::cId, cJson )
    else
    cId := ZSTK_ADD_LAZYVGRID( hb_ntos( oRoot:nIndex ), ::cId, cJson )
    endif
    
    oItem := TSwiftStackItem():New( cId, Self )
return oItem

METHOD AddList() CLASS TSwiftStackItem
    local oItem, cId
    local oRoot := ::Root()
    
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cId := VSTK_ADD_LIST( hb_ntos( oRoot:nIndex ), ::cId )
    else
    cId := ZSTK_ADD_LIST( hb_ntos( oRoot:nIndex ), ::cId )
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
    local aIds, n, cJson, cJsonIds
    local oTempItem, hItem
    local oRoot := ::Root()
    
    DEFAULT aItems := ::aBatch
    if Empty( aItems ) ; return {} ; endif

    for n := 1 to Len( aItems )
    hItem := { "type" => aItems[n]["type"], ;
        "content" => aItems[n]["content"], ;
        "secondaryContent" => If( hb_HHasKey( aItems[n], "secondaryContent" ), aItems[n]["secondaryContent"], nil ) }
        
    if hb_HHasKey( aItems[n], "nClrBack" ) .and. aItems[n]["nClrBack"] != nil
    hItem["bg"] := { "r" => nRGBRed( aItems[n]["nClrBack"] ) / 255.0, ;
        "g" => nRGBGreen( aItems[n]["nClrBack"] ) / 255.0, ;
        "b" => nRGBBlue( aItems[n]["nClrBack"] ) / 255.0, ;
        "a" => If( hb_HHasKey( aItems[n], "nAlphaBack" ) .and. aItems[n]["nAlphaBack"] != nil, aItems[n]["nAlphaBack"], 1.0 ) }
    endif
        
    if hb_HHasKey( aItems[n], "nClrFore" ) .and. aItems[n]["nClrFore"] != nil
    hItem["fg"] := { "r" => nRGBRed( aItems[n]["nClrFore"] ) / 255.0, ;
        "g" => nRGBGreen( aItems[n]["nClrFore"] ) / 255.0, ;
        "b" => nRGBBlue( aItems[n]["nClrFore"] ) / 255.0, ;
        "a" => If( hb_HHasKey( aItems[n], "nAlphaFore" ) .and. aItems[n]["nAlphaFore"] != nil, aItems[n]["nAlphaFore"], 1.0 ) }
    endif
    AAdd( aJsonData, hItem )
    next
   
    cJson := hb_jsonEncode( aJsonData )
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    cJsonIds := VSTK_ADD_BATCH( hb_ntos( oRoot:nIndex ), cJson, ::cId ) 
    else
    cJsonIds := ZSTK_ADD_BATCH( hb_ntos( oRoot:nIndex ), cJson, ::cId ) 
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
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    VSTK_SET_ITEM_LAYOUT( hb_ntos( oRoot:nIndex ), ::cId, hb_ntos( nWidth ), hb_ntos( nHeight ), "-1" )
    endif
return nil

METHOD SetSpacing( nSpacing ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    DEFAULT nSpacing := 8
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    VSTK_SET_ITEM_LAYOUT( hb_ntos( oRoot:nIndex ), ::cId, "0", "0", hb_ntos( nSpacing ) )
    endif
return nil

METHOD SetText( cText ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    VSTK_SET_ITEM_TEXT( hb_ntos( oRoot:nIndex ), ::cId, cText )
    endif
return nil

METHOD SetFont( nSize, lBold ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    DEFAULT nSize := 0, lBold := .F.
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    VSTK_SET_ITEM_FONT( hb_ntos( oRoot:nIndex ), ::cId, hb_ntos( nSize ), If( lBold, "1", "0" ) )
    endif
return nil

METHOD SetColor( nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    
    DEFAULT nAlphaFore := 1.0
    DEFAULT nAlphaBack := 1.0

    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    if nClrFore != nil
    VSTK_SET_ITEM_COLOR_HEX( hb_ntos( oRoot:nIndex ), ::cId, clrToHex( nClrFore, nAlphaFore ) )
    endif
        
    if nClrBack != nil
    VSTK_SET_ITEM_BGCOLOR_HEX( hb_ntos( oRoot:nIndex ), ::cId, clrToHex( nClrBack, nAlphaBack ) )
    endif
    endif

return nil

METHOD SetBgColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    local nClr 
    DEFAULT nAlpha := 1.0
    
    if pcount() <= 2
    nClr   := nRed
    else
    nClr := nRGB( nRed, nGreen, nBlue )
    endif

    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    VSTK_SET_ITEM_BGCOLOR_HEX( hb_ntos( oRoot:nIndex ), ::cId, clrToHex( nClr, nAlpha ) )
    endif
return nil

METHOD SetRadius( nRadius ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    DEFAULT nRadius := 0
    if oRoot:IsKindOf( "TSWIFTVSTACK" )
    VSTK_SET_ITEM_RADIUS( hb_ntos( oRoot:nIndex ), ::cId, nRadius )
    endif
return nil
