#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TXlsxReader

    DATA hReader
    DATA hSheet
    DATA hSheetList

    METHOD New( cFileName )
    METHOD End()

    METHOD OpenSheet( cSheetName, nFlags )
    METHOD CloseSheet()
    METHOD NextRow()
    METHOD NextCell()
    METHOD LastRowIndex()    INLINE XlsxioReadSheetLastRowIndex( ::hSheet )
    METHOD LastColumnIndex() INLINE XlsxioReadSheetLastColumnIndex( ::hSheet )

    METHOD ListSheets()
    METHOD GetVersion()      INLINE XlsxioReadGetVersionString()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cFileName ) CLASS TXlsxReader

    if ! empty( cFileName )
    ::hReader = XlsxioReadOpen( cFileName )
    endif

return Self

//----------------------------------------------------------------------------//

METHOD End() CLASS TXlsxReader

    if ! empty( ::hSheet )
    ::CloseSheet()
    endif

    if ! empty( ::hReader )
    XlsxioReadClose( ::hReader )
    ::hReader = nil
    endif

return nil

//----------------------------------------------------------------------------//

METHOD OpenSheet( cSheetName, nFlags ) CLASS TXlsxReader

    DEFAULT nFlags := 0

    if empty( ::hReader )
    return .F.
    endif

    if ! empty( ::hSheet )
    ::CloseSheet()
    endif

    ::hSheet = XlsxioReadSheetOpen( ::hReader, cSheetName, nFlags )

return ! empty( ::hSheet )

//----------------------------------------------------------------------------//

METHOD CloseSheet() CLASS TXlsxReader

    if ! empty( ::hSheet )
    XlsxioReadSheetClose( ::hSheet )
    ::hSheet = nil
    endif

return nil

//----------------------------------------------------------------------------//

METHOD NextRow() CLASS TXlsxReader
return if( ! empty( ::hSheet ), XlsxioReadSheetNextRow( ::hSheet ), .F. )

//----------------------------------------------------------------------------//

METHOD NextCell() CLASS TXlsxReader
return if( ! empty( ::hSheet ), XlsxioReadSheetNextCell( ::hSheet ), nil )

//----------------------------------------------------------------------------//

METHOD ListSheets() CLASS TXlsxReader

    local aSheets := {}
    local hList, cSheet

    if ! empty( ::hReader )
    hList = XlsxioReadSheetListOpen( ::hReader )
    if ! empty( hList )
    while ( cSheet := XlsxioReadSheetListNext( hList ) ) != nil
    AAdd( aSheets, cSheet )
    end
    XlsxioReadSheetListClose( hList )
    endif
    endif

return aSheets

//----------------------------------------------------------------------------//
