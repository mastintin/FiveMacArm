#include "swfive.ch"

CLASS TSwQuickLook FROM TSwiftControl

   ACCESS FileName          INLINE hb_HGetDef( ::hState, "filename", "" )
   ASSIGN FileName( c )     INLINE ( ::hState["filename"] := c, ::Apply( "filename", c ) )

   ACCESS nCorner           INLINE hb_HGetDef( ::hState, "corner", 8 )
   ASSIGN nCorner( n )      INLINE ( ::hState["corner"] := n, ::Apply( "corner", n ) )

   ACCESS nZoom             INLINE hb_HGetDef( ::hState, "zoom", 1.0 )
   ASSIGN nZoom( n )        INLINE ( ::hState["zoom"] := n, ::Apply( "zoom", n ) )

   ACCESS cPlaceholder      INLINE hb_HGetDef( ::hState, "placeholder", "" )
   ASSIGN cPlaceholder( c ) INLINE ( ::hState["placeholder"] := c, ::Apply( "placeholder", c ) )

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cFileName, nRes )

ENDCLASS

// -------------------------------------------------------------------------------- //

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cFileName, nRes ) CLASS TSwQuickLook

   DEFAULT nWidth := 400, nHeight := 300
   DEFAULT cFileName := ""

   ::Super:New( nTop, nLeft, nWidth, nHeight, , nRes )

   ::hState["type"]     := SW_TYPE_QUICKLOOK
   ::hState["filename"] := cFileName

   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
      ::oWnd := oWnd
   endif

   ::Create()

return self
