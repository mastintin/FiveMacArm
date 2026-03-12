#include "FiveMac.ch"

static aSwiftPickers := {}

//----------------------------------------------------------------------------//

CLASS TSwiftPicker FROM TControl

    DATA   bChange
    DATA   bSetGet
    DATA   aItems
    DATA   cVarName
    DATA   nIndex
    DATA   cID

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bChange, bSetGet, cVarName, cTextLabel, nAutoResize )
    METHOD Redefine( nId, oWnd, aItems, bChange, bSetGet, cVarName )
   
    METHOD SetItems( aItems ) 
    METHOD Set( cValue )      INLINE SD_PKR_SET_SELECTION( ::cID, cValue )
    METHOD SetGlass( lGlass ) INLINE SD_PKR_SET_GLASS( ::cID, lGlass )
    METHOD SetShowLabel( lShow ) INLINE SD_PKR_SET_SHOW_LABEL( ::cID, lShow )
    METHOD SetText( cText )      INLINE SD_PKR_SET_TITLE( ::cID, cText )
    METHOD SetColor( nAccent, nText )
    METHOD GetValue()            INLINE SD_PKR_GET_SELECTION( ::cID )
    METHOD SetPlaceholder( cText ) INLINE SD_PKR_SET_PLACEHOLDER( ::cID, cText )
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

    ::oWnd    = oWnd
    ::aItems  = aItems
    ::bChange = bChange
    ::bSetGet = bSetGet
    ::cVarName = cVarName

    AAdd( aSwiftPickers, Self )
    ::nIndex = Len( aSwiftPickers )
    ::cID = AllTrim( SWIFT_UUID() )

    ::hWnd = SD_SWIFT_PICKER_CREATE( nTop, nLeft, nWidth, nHeight, hb_jsonEncode( aItems ), oWnd:hWnd, ::nIndex, cTextLabel, ::cID )
    
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
    ::nIndex = Len( aSwiftPickers )
   
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

METHOD SetItems( aItems ) CLASS TSwiftPicker
    ::aItems := aItems
    SD_PKR_SET_ITEMS( ::cId,  aItems  )
return nil

METHOD SetColor( nAccent, nText ) CLASS TSwiftPicker
    SD_PKR_SET_COLORS( ::cID, clrToHex( nAccent ), clrToHex( nText ) )
return nil

METHOD End() CLASS TSwiftPicker
    if !Empty( ::hWnd )
        SD_PKR_DESTROY( ::cId, ::nIndex, ::hWnd )
        if ::nIndex > 0 .and. ::nIndex <= Len( aSwiftPickers )
            aSwiftPickers[ ::nIndex ] := nil
        endif
        ::hWnd := 0
        ::cId  := ""
    endif
return ::Super:End()

//----------------------------------------------------------------------------//

function SwiftPickerOnChange( nIndex, cValue )
    if nIndex > 0 .and. nIndex <= Len( aSwiftPickers )
        if aSwiftPickers[ nIndex ] != nil
            aSwiftPickers[ nIndex ]:OnChange( cValue )
        endif
    endif
return nil

//----------------------------------------------------------------------------//
