#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TMarkdownView FROM TControl

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cMarkdown )
   
    METHOD SetText( cMarkdown ) INLINE MarkdownSetText( ::hWnd, cMarkdown )
   
    METHOD SetFile( cPath ) INLINE ::SetText( memoread( cPath ) )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cMarkdown ) CLASS TMarkdownView

    DEFAULT oWnd := GetWndDefault()

    ::hWnd = MarkdownCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )
    ::oWnd = oWnd
   
    if ! Empty( cMarkdown )
    ::SetText( cMarkdown )
    endif

    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//
