#include "FiveMac.ch"

static aSwiftDatePickers := {}

//----------------------------------------------------------------------------//

CLASS TSwiftDatePicker FROM TControl

    DATA   bChange
    DATA   dDate
    DATA   cID

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, dDate, bChange, cTitle )
    
    METHOD SetDate( dDate )  
    METHOD GetDate()         
    
    METHOD SetColor( nAccent, nText )
    METHOD SetEnabled( lEnabled ) INLINE SD_DTP_SET_ENABLED( ::cID, lEnabled )
    
    METHOD End()
    METHOD OnChange( cDateStr )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, dDate, bChange, cTitle ) CLASS TSwiftDatePicker

    DEFAULT nWidth := 150, nHeight := 24
    DEFAULT oWnd := GetWndDefault()
    DEFAULT dDate := Date()
    DEFAULT cTitle := ""

    ::oWnd    = oWnd
    ::dDate   = dDate
    ::bChange = bChange

    ::cID := ""
    
    AAdd( aSwiftDatePickers, Self )

    ::hWnd = SD_SWIFT_DATEPICKER_CREATE( nTop, nLeft, nWidth, nHeight, DToS( dDate ), oWnd:hWnd, cTitle, ::cID )
    ::cID := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cID, Self )
   
    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD SetDate( dDate ) CLASS TSwiftDatePicker
    ::dDate := dDate
    SD_DTP_SET_DATE( ::cId, DToS( dDate ) )
return nil

//----------------------------------------------------------------------------//

METHOD GetDate() CLASS TSwiftDatePicker
    local cDate := SD_DTP_GET_DATE( ::cId )
    ::dDate := SToD( cDate )
return ::dDate

//----------------------------------------------------------------------------//

METHOD SetColor( nAccent, nText ) CLASS TSwiftDatePicker
    SD_DTP_SET_COLORS( ::cID, clrToHex( nAccent ), clrToHex( nText ) )
return nil

//----------------------------------------------------------------------------//

METHOD OnChange( cDateStr ) CLASS TSwiftDatePicker
    ::dDate := SToD( cDateStr )
    if ::bChange != nil
        Eval( ::bChange, ::dDate, Self )
    endif
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TSwiftDatePicker
    local nPos 
    if !Empty( ::hWnd )
        SD_DTP_DESTROY( ::cID, ::hWnd )
        SwiftUnregisterItem( ::cID )
        nPos := AScan( aSwiftDatePickers, { |o| o != nil .and. o:cID == ::cID } )
        if nPos > 0
            aSwiftDatePickers[ nPos ] := nil
        endif
        ::cId  := ""
    endif
return ::Super:End()

//----------------------------------------------------------------------------//
