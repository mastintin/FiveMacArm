#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwiftPDF

    METHOD SaveView( oView, cPath )
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD SaveView( oView, cPath ) CLASS TSwiftPDF
    local cId := ""

    if ValType( oView ) == "O"
        if __ObjHasData( oView, "cId" )
            cId := oView:cId
        elseif __ObjHasData( oView, "cID" )
            cId := oView:cID
        endif
    elseif ValType( oView ) == "C"
        cId := oView
    endif

    if !Empty( cId )
        SD_SWIFT_PDF_SAVE( cId, cPath )
    endif

return nil

//----------------------------------------------------------------------------//
