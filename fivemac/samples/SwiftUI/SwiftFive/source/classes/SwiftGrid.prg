#include "FiveMac.ch"

static aGrids := {}

CLASS TSwiftGrid FROM TSwiftList

    METHOD New( nRow, nCol, nWidth, nHeight, aColumns, oWnd )

ENDCLASS

METHOD New( nRow, nCol, nWidth, nHeight, aColumns, oWnd, nAutoResize ) CLASS TSwiftGrid

    local cJson := "["
    local n

    DEFAULT nWidth := 200, nHeight := 200, oWnd := GetWndDefault()
    DEFAULT aColumns := {}, nAutoResize := 0

    ::oWnd = oWnd
    
    ::nId = Len( aGrids ) + 1
    AAdd( aGrids, Self )
    
    ::cId = "" 
    
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
    if Len( aColumns[n] ) >= 2; cJson += ',"min":' + AllTrim( Str( aColumns[n][2] ) ); endif
    if Len( aColumns[n] ) >= 3; cJson += ',"max":' + AllTrim( Str( aColumns[n][3] ) ); endif
    case Lower( aColumns[n][1] ) == "adaptive"
    cJson += '"type":"adaptive"'
    if Len( aColumns[n] ) >= 2; cJson += ',"min":' + AllTrim( Str( aColumns[n][2] ) ); endif
    if Len( aColumns[n] ) >= 3; cJson += ',"max":' + AllTrim( Str( aColumns[n][3] ) ); endif
    endcase
    cJson += "}"
    next
    cJson += "]"

    ::hWnd = SWIFTGRIDCREATE( oWnd:hWnd, ::nId, nRow, nCol, nWidth, nHeight, cJson )

    if nAutoResize != 0
    SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif
    
    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------//

function SwiftGridOnClick( nGridIndex, nItemIndex )
    local oGrid

    if nGridIndex > 0 .and. nGridIndex <= Len( aGrids )
    oGrid = aGrids[ nGridIndex ]
    if oGrid:bAction != nil
    Eval( oGrid:bAction, nItemIndex )
    endif
    endif

    return nil
return nil

function SwiftGridOnAction( nGridIndex, cId )
    local oGrid
    local uVal

    if nGridIndex > 0 .and. nGridIndex <= Len( aGrids )
    oGrid = aGrids[ nGridIndex ]
       
    // Try to resolve ID via Hash
    if __ObjHasMsg( oGrid, "GETITEM" )
    uVal := oGrid:GetItem( cId )
    endif
       
    if valtype( uVal ) == "N" // Found Index!
    if oGrid:bAction != nil
    Eval( oGrid:bAction, uVal )
    endif
    elseif valtype( uVal ) == "O" // Found Object!
    if __ObjHasMsg( uVal, "BACTION" ) .and. uVal:bAction != nil
    Eval( uVal:bAction, uVal )
    endif
    else
    // Fallback or Direct ID?
    // For now, if no mapping found, do nothing or log?
    // Alert( "Unknown ID: " + cId )
    endif
    endif

return nil
