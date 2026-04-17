#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwWebView FROM TSwiftControl

   ACCESS Url      INLINE ::hState["url"]
   ASSIGN Url( c ) INLINE ::Load( c )

   METHOD New( nTop, nLeft, nWidth, nHeight, cUrl, oWnd, cId )
   METHOD Load( cUrl )
   METHOD LoadHtml( cHtml )
   METHOD GoBack()
   METHOD GoForward()
   METHOD Reload()

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, cUrl, oWnd, cId, nAutoResize ) CLASS TSwWebView

   DEFAULT nWidth := 500, nHeight := 400
   
   if Empty( cId ) ; cId := hb_UUID() ; endif
   
   ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
   
   ::oWnd := oWnd
   ::hState["url"]  := cUrl
   ::hState["type"] := 12 // webview
   
   ::Create()
   
   // 2. Registrar en Harbour
   SwiftRegisterItem( ::cId, Self )
   
   // 3. Añadir a la ventana

return Self

//----------------------------------------------------------------------------//

METHOD Load( cUrl ) CLASS TSwWebView
   ::hState["url"] := cUrl
   SD:Apply( ::cId, { "url" => cUrl } )
return nil

//----------------------------------------------------------------------------//

METHOD LoadHtml( cHtml ) CLASS TSwWebView
   ::hState["html"] := cHtml
   SD:Apply( ::cId, { "html" => cHtml } )
return nil

//----------------------------------------------------------------------------//

METHOD GoBack() CLASS TSwWebView
   SD:Apply( ::cId, { "goback" => .T. } )
return nil

//----------------------------------------------------------------------------//

METHOD GoForward() CLASS TSwWebView
   SD:Apply( ::cId, { "goforward" => .T. } )
return nil

//----------------------------------------------------------------------------//

METHOD Reload() CLASS TSwWebView
   SD:Apply( ::cId, { "reload" => .T. } )
return nil

//----------------------------------------------------------------------------//
