#include "FiveMac.ch"

static aZStacks := {}
// Removed s_hRegistry from here, now in SwiftCommon.prg

INIT PROCEDURE SwiftZStackInit()
    // s_hRegistry initialization handled in SwiftCommon or lazy init
return

// SwiftVStackOnAction removed - moved to SwiftCommon.prg as SwiftOnAction
// SwiftRegisterItem removed - moved to SwiftCommon.prg

#define SWIFT_TYPE_TEXT          0
#define SWIFT_TYPE_SYSTEMIMAGE   1
#define SWIFT_TYPE_HSTACK        2
#define SWIFT_TYPE_IMAGEFILE     3
#define SWIFT_TYPE_VSTACK        4
#define SWIFT_TYPE_HSTACKCONTAINER 5
#define SWIFT_TYPE_SPACER        6
#define SWIFT_TYPE_LAZYVGRID     7
#define SWIFT_TYPE_LIST          8
#define SWIFT_TYPE_BUTTON        9
#define SWIFT_TYPE_DIVIDER       10

CLASS TSwiftZStack FROM TControl

    DATA nIndex
    DATA hItems INIT {=>}
    DATA aBatch INIT {}

    METHOD New( nRow, nCol, nWidth, nHeight, oWnd )
    
    METHOD RegItem( cId, oItem ) INLINE SwiftRegisterItem( cId, oItem )
    METHOD GetItem( cId ) INLINE SwiftGetItem( cId ) 
    
    METHOD AddText( cText )
    METHOD AddButton( cText, bAction )
    METHOD AddImage( cSystemName )
    METHOD AddImageFile( cFile )
    METHOD Reset()
    
    METHOD AddVStack( oParent )
    METHOD AddHStack( oParent )
    
    METHOD SetAlignment( nAlign )
    METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha )
    METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha )
    
    METHOD AddGrid( aColumns ) // Returns Item
    METHOD AddList()           // Returns Item

    METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD AddBatch( aItems )

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, oWnd ) CLASS TSwiftZStack

    DEFAULT nWidth := 200
    DEFAULT nHeight := 200
    DEFAULT oWnd := GetWndDefault()

    ::oWnd = oWnd
    
    ::nIndex = Len( aZStacks ) + 1
    AAdd( aZStacks, Self )
    ::hItems := {=>}
    ::aBatch := {}

    ::hWnd = SWIFTZSTACKCREATE( oWnd:hWnd, ::nIndex, nRow, nCol, nWidth, nHeight )

    oWnd:AddControl( Self )

return Self

METHOD AddText( cText ) CLASS TSwiftZStack
    SWIFTZSTACKADDITEM( cText )
return nil

METHOD AddImage( cSystemName ) CLASS TSwiftZStack
    SWIFTZSTACKADDIMAGE( cSystemName )
return nil

METHOD AddImageFile( cFile ) CLASS TSwiftZStack
    SWIFTZSTACKADDFILEIMAGE( cFile )
return nil

METHOD AddButton( cText, bAction ) CLASS TSwiftZStack
    local cId, oItem
    // Pass nil as parent to add to root ZStack
    cId := SWIFTZSTACKADDBUTTONTO( cText, nil )
    if bAction != nil .and. !Empty( cId )
    oItem := TSwiftStackItem():New( cId, Self )
    oItem:bAction := bAction
    SwiftRegisterItem( cId, oItem )
    endif
return nil

// Recursion / Nesting Support
METHOD AddVStack( oParent ) CLASS TSwiftZStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := SWIFTZSTACKADDVSTACKCONTAINER( cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD Reset() CLASS TSwiftZStack
    SWIFTZSTACKREMOVEALLITEMS()
return nil

METHOD AddHStack( oParent ) CLASS TSwiftZStack
    local cId
    local cParentId := If( oParent != nil, oParent:cId, nil )
    cId := SWIFTZSTACKADDHSTACKCONTAINER( cParentId )
return TSwiftStackItem():New( cId, Self )

METHOD SetAlignment( nAlign ) CLASS TSwiftZStack
    // 0: Center, 1: TopLeading...
    SWIFTZSTACKSETALIGNMENT( nAlign )
return nil

METHOD AddGrid( aColumns ) CLASS TSwiftZStack
    local cId, oItem
    local cJsonColumns := "["
    local n
   
    DEFAULT aColumns := {}
    
    for n := 1 to Len( aColumns )
    if n > 1 ; cJsonColumns += "," ; endif
    cJsonColumns += '{"type":"' + aColumns[n][1] + '"'
    if Len( aColumns[n] ) >= 2 ; cJsonColumns += ',"min":' + AllTrim( Str( aColumns[n][2] ) ) ; endif
    if Len( aColumns[n] ) >= 3 ; cJsonColumns += ',"max":' + AllTrim( Str( aColumns[n][3] ) ) ; endif
    cJsonColumns += '}'
    next
    cJsonColumns += "]"
   
    cId := SWIFTZSTACKADDLAZYVGRID( nil, cJsonColumns )
    
    oItem := TSwiftStackItem():New( cId, Self )
return oItem

METHOD AddList() CLASS TSwiftZStack
    local cId
    cId := SWIFTZSTACKADDLIST( nil )
    SWIFTSETID( cId )
return TSwiftStackItem():New( cId, Self )

METHOD SetForegroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftZStack
    DEFAULT nRed := 0, nGreen := 0, nBlue := 0
    DEFAULT nAlpha := 1.0
    SWIFTZSTACKSETFGCOLOR( nRed / 255.0, nGreen / 255.0, nBlue / 255.0, nAlpha )
return nil

METHOD SetBackgroundColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftZStack
    DEFAULT nRed := 0, nGreen := 0, nBlue := 0
    DEFAULT nAlpha := 1.0
    // Normalized 0.0-1.0 from 0-255 in Harbour
    SWIFTZSTACKSETBGCOLOR( nRed / 255.0, nGreen / 255.0, nBlue / 255.0, nAlpha )
return nil

METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftZStack
    AAdd( ::aBatch, { "type" => nType, "content" => cContent, "action" => bAction, ;
        "secondaryContent" => cSecondary, "nClrFore" => nClrFore, "nClrBack" => nClrBack, ;
        "nAlphaFore" => nAlphaFore, "nAlphaBack" => nAlphaBack } )
return nil

METHOD AddBatch( aItems ) CLASS TSwiftZStack
    local aJsonData := {}
    local aIds, n, cJson, cJsonIds
    local oItem, oTempItem, hItem
   
    DEFAULT aItems := ::aBatch
   
    if Empty( aItems )
    return {}
    endif

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
    cJsonIds := SWIFTZSTACKADDBATCH( cJson, nil ) // nil parent for root
   
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
    ::aBatch := {} // Reset after flush
    endif

return aIds


//---------------------------------------------------------//

CLASS TSwiftStackItem
    DATA cId
    DATA oOwner
    DATA bAction
    
    DATA nChildCount INIT 0
    DATA aBatch INIT {}

    METHOD New( cId, oOwner )
    
    METHOD Root() 
    METHOD RegItem( cId, uValue )
    
    METHOD AddHStack()
    METHOD AddVStack()
    METHOD AddText( cText )
    METHOD AddSystemImage( cName )
    METHOD AddSpacer()
    METHOD AddDivider()
    
    METHOD SetColor( nRed, nGreen, nBlue, nAlpha )

    METHOD AddGrid( aColumns ) // Returns Item
    METHOD AddList()           // Returns Item
    METHOD AddButton( cText, bAction )
    
    METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack )
    METHOD AddBatch( aItems )

ENDCLASS

METHOD New( cId, oOwner ) CLASS TSwiftStackItem
    ::cId = cId
    ::oOwner = oOwner
    ::aBatch := {}
return Self

METHOD Root() CLASS TSwiftStackItem
    local oParent := ::oOwner
    // Traverse up until we find a Root control (Window's control or one that has hItems)
    while oParent != nil .and. __ObjHasMsg( oParent, "OWNER" ) .and. oParent:IsKindOf( "TSWIFTSTACKITEM" )
    oParent = oParent:oOwner
    end
return oParent

METHOD RegItem( cId, uValue ) CLASS TSwiftStackItem
    local oRoot := ::Root()
    if oRoot != nil .and. __ObjHasMsg( oRoot, "REGITEM" )
    oRoot:RegItem( cId, uValue )
    endif
return nil

METHOD AddHStack() CLASS TSwiftStackItem
    local cId, oItem
    cId := SWIFTZSTACKADDHSTACKCONTAINER( ::cId )
    oItem := TSwiftStackItem():New( cId, Self )
    ::nChildCount++
return oItem

METHOD AddVStack() CLASS TSwiftStackItem
    local cId, oItem
    cId := SWIFTZSTACKADDVSTACKCONTAINER( ::cId )
    oItem := TSwiftStackItem():New( cId, Self )
    ::nChildCount++
return oItem

METHOD AddText( cText, bAction ) CLASS TSwiftStackItem
    local cId, oItem
    ::nChildCount++
    
    // Use the ID returned by Swift
    cId := SWIFTZSTACKADDTEXTTO( cText, ::cId )
    
    if bAction != nil .and. !Empty( cId )
    oItem := TSwiftStackItem():New( cId, ::oOwner )
    oItem:bAction := bAction
    SwiftRegisterItem( cId, oItem )
    else 
    // Legacy fallback or just register for ID stability
    SwiftRegisterItem( cId, { Self, ::nChildCount } )
    endif 
    
return nil

METHOD AddSystemImage( cName ) CLASS TSwiftStackItem
    local cId
    ::nChildCount++
    cId := ::cId + "_Img_" + AllTrim( Str( ::nChildCount ) )
    
    SWIFTZSTACKADDSYSTEMIMAGETO( cName, ::cId )
    SWIFTSETID( cId )
    
    ::RegItem( cId, { Self, ::nChildCount } )
return nil

METHOD AddButton( cText, bAction ) CLASS TSwiftStackItem
    local cId, oItem
    cId := SWIFTZSTACKADDBUTTONTO( cText, ::cId )
    if bAction != nil .and. !Empty( cId )
    oItem := TSwiftStackItem():New( cId, ::oOwner )
    oItem:bAction := bAction
    SwiftRegisterItem( cId, oItem )
    endif
return nil

METHOD AddSpacer() CLASS TSwiftStackItem
    SWIFTZSTACKADDSPACER( ::cId )
return nil

METHOD AddDivider() CLASS TSwiftStackItem
    SWIFTZSTACKADDDIVIDER( ::cId )
return nil

METHOD SetColor( nRed, nGreen, nBlue, nAlpha ) CLASS TSwiftStackItem
    DEFAULT nRed := 0, nGreen := 0, nBlue := 0
    DEFAULT nAlpha := 1.0
    // Normalized 0.0-1.0
    SWIFTZSTACKSETITEMBGCOLOR( ::cId, nRed / 255.0, nGreen / 255.0, nBlue / 255.0, nAlpha )
return nil

METHOD AddGrid( aColumns ) CLASS TSwiftStackItem
    local cJson := "["
    local n, oItem
    local cId
    
    DEFAULT aColumns := {}
    
    for n := 1 to Len( aColumns )
    if n > 1
    cJson += ","
    endif
    cJson += "{"
       
    do case
    case Lower( aColumns[n][1] ) == "fixed"
    cJson += '"type":"fixed","size":' + AllTrim( Str( aColumns[n][2] ) )
             
    case Lower( aColumns[n][1] ) == "flexible"
    cJson += '"type":"flexible"'
    if Len( aColumns[n] ) >= 2
    cJson += ',"min":' + AllTrim( Str( aColumns[n][2] ) )
    endif
    if Len( aColumns[n] ) >= 3
    cJson += ',"max":' + AllTrim( Str( aColumns[n][3] ) )
    endif
             
    case Lower( aColumns[n][1] ) == "adaptive"
    cJson += '"type":"adaptive"'
    if Len( aColumns[n] ) >= 2
    cJson += ',"min":' + AllTrim( Str( aColumns[n][2] ) )
    endif
    if Len( aColumns[n] ) >= 3
    cJson += ',"max":' + AllTrim( Str( aColumns[n][3] ) )
    endif
    endcase
       
    cJson += "}"
    next
    cJson += "]"
    
    cId := SWIFTZSTACKADDLAZYVGRID( ::cId, cJson )
    
    oItem := TSwiftStackItem():New( cId, ::oOwner )
return oItem

METHOD AddList() CLASS TSwiftStackItem
    local oItem
    local cId
    
    cId := SWIFTZSTACKADDLIST( ::cId )
    
    oItem := TSwiftStackItem():New( cId, ::oOwner )
return oItem

//----------------------------------------------------------------------------//

METHOD AddItem( nType, cContent, bAction, cSecondary, nClrFore, nClrBack, nAlphaFore, nAlphaBack ) CLASS TSwiftStackItem
    AAdd( ::aBatch, { "type" => nType, "content" => cContent, "action" => bAction, ;
        "secondaryContent" => cSecondary, "nClrFore" => nClrFore, "nClrBack" => nClrBack, ;
        "nAlphaFore" => nAlphaFore, "nAlphaBack" => nAlphaBack } )
return nil

METHOD AddBatch( aItems ) CLASS TSwiftStackItem
    local aJsonData := {}
    local aIds, n, cJson, cJsonIds
    local oItem, oTempItem, hItem
   
    DEFAULT aItems := ::aBatch

    if Empty( aItems )
    return {}
    endif

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
    cJsonIds := SWIFTZSTACKADDBATCH( cJson, ::cId ) 
   
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
    ::aBatch := {} // Reset after flush
    endif

return aIds
