#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwiftPDF

    METHOD SaveView( oView, cPath )
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD SaveView( oView, cPath ) CLASS TSwiftPDF

    if ValType( oView ) == "O"
    if __ObjHasMsg( oView, "nIndex" )
    SWIFTPDFSAVE( oView:nIndex, cPath )
    else
    SWIFTPDFSAVE( oView:nId, cPath )
    endif
    else
    SWIFTPDFSAVE( oView, cPath ) // Assume ID passed directly
    endif

return nil

//----------------------------------------------------------------------------//
