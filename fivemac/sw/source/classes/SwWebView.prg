#include "swfive.ch"
 
 //----------------------------------------------------------------------------//
 
 CLASS TSwWebView FROM TSwiftControl
 
    ACCESS Url      INLINE ::hState["url"]
    ASSIGN Url( c ) INLINE ::Load( c )

    ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
    ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                     ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
                                     SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
  
    ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
    ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
                                     ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
                                     SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )

    ACCESS lScroll          INLINE hb_HGetDef( ::hState, "hasscroll", .T. )
    ASSIGN lScroll( l )     INLINE ( ::hState["hasscroll"] := l, SD:Apply( ::cId, { "hasscroll" => l } ) )
 
    METHOD New( nTop, nLeft, nWidth, nHeight, cUrl, oWnd, cId, nAutoResize )
    METHOD Load( cUrl )
    METHOD LoadHtml( cHtml )
    METHOD GoBack()
    METHOD GoForward()
    METHOD Reload()
    METHOD OnAction()
 
 ENDCLASS
 
 //----------------------------------------------------------------------------//
 
 METHOD New( nTop, nLeft, nWidth, nHeight, cUrl, oWnd, cId, nAutoResize ) CLASS TSwWebView
 
    DEFAULT nWidth := 500, nHeight := 400
    
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    
    ::oWnd           := oWnd
    ::hState["url"]  := cUrl
    ::hState["type"] := 12 // webview
    ::hState["hasscroll"]   := .T.
    ::hState["interactive"] := .F.
    
    ::Create()
 
 return Self
 
 //----------------------------------------------------------------------------//

 METHOD OnAction() CLASS TSwWebView
    if !Empty( ::bPipeline )
       WITH OBJECT Sw_GetProxy()
          :Pipeline( ::bPipeline )
       END
    elseif !Empty( ::bAction )
       Eval( ::bAction, Self )
    endif
 return nil

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
