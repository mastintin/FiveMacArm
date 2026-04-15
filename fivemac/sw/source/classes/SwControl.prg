#include "FiveMac.ch"

CLASS TSwiftControl

    DATA nTop, nLeft, nWidth, nHeight
    DATA cId
    DATA oWnd
    DATA hWnd
    DATA hState INIT {=>}

    METHOD New( nTop, nLeft, nWidth, nHeight, cId )
    METHOD End()
    METHOD SetPos( nTop, nLeft )
    METHOD SetSize( nWidth, nHeight )
    METHOD Sync()
    METHOD Update( hNewState )
    METHOD Refresh()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cId ) CLASS TSwiftControl
    ::nTop    := nTop
    ::nLeft   := nLeft
    ::nWidth  := nWidth
    ::nHeight := nHeight
    ::cId     := cId
    SwiftRegisterItem( ::cId, Self )
return Self

METHOD SetPos( nTop, nLeft ) CLASS TSwiftControl
   ::nTop := nTop
   ::nLeft := nLeft
return nil

METHOD SetSize( nWidth, nHeight ) CLASS TSwiftControl
   ::nWidth := nWidth
   ::nHeight := nHeight
return nil

METHOD Sync() CLASS TSwiftControl
return nil

METHOD Update( hNewState ) CLASS TSwiftControl
return nil

METHOD Refresh() CLASS TSwiftControl
return nil

METHOD End() CLASS TSwiftControl
    SwiftUnregisterItem( ::cId )
return nil
