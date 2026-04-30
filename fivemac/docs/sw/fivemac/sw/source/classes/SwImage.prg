#include "swfive.ch"
 
  #define SW_TYPE_IMAGE 7
 
  CLASS TSwImage FROM TSwiftControl
   
       DATA bAction
       DATA bOnDrop
 
       ACCESS cSymbol          INLINE ::hState["systemname"]
       ASSIGN cSymbol( c )     INLINE ( ::hState["systemname"] := c, ::Apply( { "systemname" => c } ) )
       
       ACCESS cFile            INLINE ::hState["file"]
       ASSIGN cFile( c )       INLINE ( ::hState["file"] := c, ::Apply( { "file" => c } ) )
  
       ACCESS cUrl             INLINE ::hState["url"]
       ASSIGN cUrl( c )        INLINE ( ::hState["url"] := c, ::Apply( { "url" => c } ) )
  
       ACCESS nMode            INLINE ::hState["mode"]
       ASSIGN nMode( n )       INLINE ( ::hState["mode"] := n, ::Apply( { "mode" => n } ) )
  
       ACCESS nColor           INLINE hb_HGetDef( ::hState, "color", CLR_BLACK )
       ASSIGN nColor( n )      INLINE ( ::hState["color"] := n, ::Apply( { "color" => n } ) )
  
       ACCESS nScaling         INLINE hb_HGetDef( ::hState, "scaling", 0 )
       ASSIGN nScaling( n )    INLINE ( ::hState["scaling"] := n, ::Apply( { "scaling" => n } ) )
  
       ACCESS nFrame           INLINE hb_HGetDef( ::hState, "frame", 0 )
       ASSIGN nFrame( n )      INLINE ( ::hState["frame"] := n, ::Apply( { "frame" => n } ) )
  
       METHOD New( nTop, nLeft, nWidth, nHeight, cSymbol, oWnd, cFile, cUrl, cId, nAutoResize )
       METHOD SetSymbol( cName ) INLINE ::cSymbol := cName
       METHOD SetFile( cFile )   INLINE ::cFile := cFile
       METHOD SetUrl( cUrl )     INLINE ::cUrl := cUrl
       METHOD SetMode( nMode )   INLINE ::nMode := nMode
       METHOD SetColor( nClr )   INLINE ::nColor := nClr
       METHOD SetScaling( n )    INLINE ::nScaling := n
       METHOD SetFrame( n )      INLINE ::nFrame := n
  
       METHOD SetQr( cText, nScale ) INLINE ::Apply( { "qr" => cText, "qrscale" => nScale } )
       METHOD SetBorderColor( nClr ) INLINE ::Apply( "bordercolor", nClr )
       
       METHOD OnAction()             INLINE if( !Empty( ::bAction ), Eval( ::bAction, Self ), )
       METHOD OnDrop( aFiles )       INLINE if( !Empty( ::bOnDrop ), Eval( ::bOnDrop, aFiles, Self ), )
    
  ENDCLASS
  
  //----------------------------------------------------------------------------//
  
  METHOD New( nTop, nLeft, nWidth, nHeight, cSymbol, oWnd, cFile, cUrl, cId, nAutoResize ) CLASS TSwImage
   
      DEFAULT nWidth := 100, nHeight := 100, nAutoResize := 0,;
              cSymbol := "", cFile := "", cUrl := ""
      
      if Empty( cId ) ; cId := Lower( hb_uuid() ) ; endif
   
      ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
      ::oWnd := oWnd
      
      if hb_IsObject( oWnd )
         ::hState["parentid"] := oWnd:cId
      endif
      
      ::hState["type"]       := SW_TYPE_IMAGE
      ::hState["systemname"] := cSymbol
      ::hState["file"]       := cFile
      ::hState["url"]        := cUrl
      ::hState["mode"]       := 0  // fit por defecto
      
      ::Create()
   
   return Self
  
  //----------------------------------------------------------------------------//
