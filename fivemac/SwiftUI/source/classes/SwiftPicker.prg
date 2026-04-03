#include "FiveMac.ch"

static aSwiftPickers := {}

//----------------------------------------------------------------------------//

CLASS TSwiftPicker FROM TSwiftControl

    DATA   bChange
    DATA   bSetGet
    DATA   aItems
    DATA   cVarName

    ACCESS Value      INLINE ::GetValue()
    ASSIGN Value( v ) INLINE ::Set( v )
    
    ACCESS Items       INLINE ::aItems
    ASSIGN Items( a )  INLINE ::SetItems( a )
    
    ASSIGN OnChange( b ) INLINE ::bChange := b

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bChange, bSetGet, cVarName, cTextLabel, nAutoResize )
    METHOD Redefine( nId, oWnd, aItems, bChange, bSetGet, cVarName )
   
    METHOD SetItems( aItems ) 
    METHOD Set( cValue )      INLINE SD_PKR_SET_SELECTION( ::cId, cValue )
    METHOD SetGlass( lGlass ) INLINE SD_PKR_SET_GLASS( ::cId, lGlass )
    METHOD SetShowLabel( lShow ) INLINE SD_PKR_SET_SHOW_LABEL( ::cId, lShow )
    METHOD SetText( cText )      INLINE SD_PKR_SET_TITLE( ::cId, cText )
    METHOD SetColor( nAccent, nText )
    METHOD GetValue()            
    METHOD SetPlaceholder( cText ) INLINE SD_PKR_SET_PLACEHOLDER( ::cId, cText )
    METHOD End()
    METHOD SetAutoResize( nStyle ) INLINE ::_nAutoResize( nStyle )
   
    METHOD OnChange( cValue )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bChange, bSetGet, cVarName, cTextLabel, nAutoResize ) CLASS TSwiftPicker

    DEFAULT nWidth := 100, nHeight := 24
    DEFAULT oWnd := GetWndDefault()
    DEFAULT aItems := {}
    DEFAULT cTextLabel := "Categoría"

    ::Super:New( nTop, nLeft, nWidth, nHeight, "" )
    ::oWnd    = oWnd
    ::aItems  = aItems
    ::bChange = bChange
    ::bSetGet = bSetGet
    ::cVarName = cVarName

    AAdd( aSwiftPickers, Self )

    ::hWnd = SD_SWIFT_PICKER_CREATE( nTop, nLeft, nWidth, nHeight, hb_jsonEncode( aItems ), oWnd:hWnd, cTextLabel, ::cId )
    ::cId := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cId, Self )
    
    oWnd:AddControl( Self )

    if nAutoResize != nil
        ::SetAutoResize( nAutoResize )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD Redefine( nId, oWnd, aItems, bChange, bSetGet, cVarName ) CLASS TSwiftPicker

    DEFAULT oWnd := GetWndDefault()
   
    ::nId     = nId
    ::oWnd    = oWnd
    ::aItems  = aItems
    ::bChange = bChange
    ::bSetGet = bSetGet
    ::cVarName = cVarName

    AAdd( aSwiftPickers, Self )
   
    oWnd:DefControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD OnChange( cValue ) CLASS TSwiftPicker

    if ::bSetGet != nil
        Eval( ::bSetGet, cValue )
    endif

    if ::bChange != nil
        Eval( ::bChange, cValue, Self )
    endif
   
return nil

METHOD SetItems( uItems ) CLASS TSwiftPicker
    ::aItems := uItems
    if ValType( uItems ) == "A"
       SD_PKR_SET_ARRAY( ::cID, uItems )
    else
       SD_PKR_SET_ITEMS( ::cID, uItems )
    endif
return nil

METHOD GetValue() CLASS TSwiftPicker
return SD_PKR_GET_SELECTION( ::cId )

METHOD SetColor( nAccent, nText ) CLASS TSwiftPicker
    if nAccent != nil ; ::SetAccentColor( nAccent ) ; endif
    if nText != nil   ; ::SetTextColor( nText )   ; endif
return nil

METHOD End() CLASS TSwiftPicker
    local nPos 
    if !Empty( ::hWnd )
        SD_PKR_DESTROY( ::cId, ::hWnd )
        SwiftUnregisterItem( ::cId )
        nPos := AScan( aSwiftPickers, { |o| o != nil .and. o:cID == ::cID } )
        if nPos > 0
            aSwiftPickers[ nPos ] := nil
        endif
        ::cId  := ""
    endif
return ::Super:End()
