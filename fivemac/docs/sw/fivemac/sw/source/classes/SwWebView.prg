#include "swfive.ch"

//----------------------------------------------------------------------------//

CLASS TSwWebView FROM TSwiftControl

   ACCESS Url      INLINE ::hState["url"]
   ASSIGN Url( c ) INLINE ::Load( c )

   ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
   ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                    ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
                                    ::Apply( "interactive", ::hState["interactive"] ) )

   // Alias para compatibilidad
   ACCESS bOnMessage       INLINE ::bAction
   ASSIGN bOnMessage( u )  INLINE ::bAction := u
 
   ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
   ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
                                    ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
                                    ::Apply( "interactive", ::hState["interactive"] ) )

   ACCESS lScroll          INLINE hb_HGetDef( ::hState, "hasscroll", .T. )
   ASSIGN lScroll( l )     INLINE ( ::hState["hasscroll"] := l, ::Apply( "hasscroll", l ) )

   METHOD New( nTop, nLeft, nWidth, nHeight, cUrl, oWnd, cId, nAutoResize )
   
   METHOD Load( cUrl )
   METHOD SetURL( cUrl )           INLINE ::Load( cUrl )
   METHOD LoadHtml( cHtml )
   METHOD LoadFile( cPath )
   METHOD SaveToPDF( cPath )
   
   METHOD Eval( cScript )
   METHOD EvalArg( cMethod, cArg ) INLINE ::Eval( cMethod + "( '" + cArg + "' )" )
   
   // Alias para compatibilidad nativa
   METHOD ScriptCallMethod( cM )       INLINE ::Eval( cM + "()" )
   METHOD ScriptCallMethodArg( cM, cA ) INLINE ::EvalArg( cM, cA )

   METHOD SetZoom( nZoom )
   METHOD SetTextSize( nPercent )  INLINE ::Apply( "textsize", nPercent )
   
   // No soportados directamente por WKWebView (vacíos para compatibilidad nativa)
   METHOD StartSpeaking()          INLINE nil
   METHOD StopSpeaking()           INLINE nil

   METHOD GoBack()
   METHOD GoForward()
   METHOD Reload()
   METHOD Stop()
   METHOD Stopload()               INLINE ::Stop()
   
   METHOD IsLoading()              INLINE hb_HGetDef( ::hState, "isloading", .F. )
   METHOD Progress()               INLINE hb_HGetDef( ::hState, "progress", 0.0 )
   METHOD Title()                  INLINE hb_HGetDef( ::hState, "title", "" )
   
   METHOD Update( hNewState )
   METHOD OnAction( hData )

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

METHOD Update( hNewState ) CLASS TSwWebView
   if hb_HHasKey( hNewState, "event" )
      ::OnAction( hNewState )
   endif
return ::Super:Update( hNewState )

//----------------------------------------------------------------------------//

METHOD OnAction( hData ) CLASS TSwWebView
   
   local cEvent := hb_HGetDef( hData, "event", "" )
   local uBody  := hb_HGetDef( hData, "body", "" )

   if cEvent == "jsMessage"
      if !Empty( ::bAction )
         Eval( ::bAction, uBody, Self )
      endif
      
      if !Empty( ::bPipeline )
         Sw_GetProxy():Pipeline( ::bPipeline, uBody )
      endif
   
   elseif cEvent == "pdfExported"
      if !Empty( ::bAction )
         Eval( ::bAction, "pdf:" + hb_HGetDef( hData, "path", "" ), Self )
      endif
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Load( cUrl ) CLASS TSwWebView
   ::hState["url"] := cUrl
   ::Apply( "url", cUrl )
return nil

//----------------------------------------------------------------------------//

METHOD LoadHtml( cHtml ) CLASS TSwWebView
   ::hState["html"] := cHtml
   ::Apply( "html", cHtml )
return nil

//----------------------------------------------------------------------------//

METHOD LoadFile( cPath ) CLASS TSwWebView
   ::Apply( "loadfile", cPath )
return nil

//----------------------------------------------------------------------------//

METHOD SaveToPDF( cPath ) CLASS TSwWebView
   ::Apply( "savetopdf", cPath )
return nil

//----------------------------------------------------------------------------//

METHOD Eval( cScript ) CLASS TSwWebView
   ::Apply( "eval", cScript )
return nil

//----------------------------------------------------------------------------//

METHOD SetZoom( nZoom ) CLASS TSwWebView
   ::Apply( "zoom", nZoom )
return nil

//----------------------------------------------------------------------------//

METHOD GoBack() CLASS TSwWebView
   ::Apply( "goback", .T. )
return nil

//----------------------------------------------------------------------------//

METHOD GoForward() CLASS TSwWebView
   ::Apply( "goforward", .T. )
return nil

//----------------------------------------------------------------------------//

METHOD Reload() CLASS TSwWebView
   ::Apply( "reload", .T. )
return nil

//----------------------------------------------------------------------------//

METHOD Stop() CLASS TSwWebView
   ::Apply( "stop", .T. )
return nil

//----------------------------------------------------------------------------//
