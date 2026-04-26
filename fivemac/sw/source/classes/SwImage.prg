#include "swfive.ch"
 
 #define SW_TYPE_IMAGE 7
 
 CLASS TSwImage FROM TSwiftControl
  
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
 
      METHOD New( nTop, nLeft, nWidth, nHeight, cSymbol, oWnd, cFile, cUrl, cId, nAutoResize )
      METHOD SetSymbol( cName ) INLINE ::cSymbol := cName
      METHOD SetFile( cFile )   INLINE ::cFile := cFile
      METHOD SetUrl( cUrl )     INLINE ::cUrl := cUrl
      METHOD SetMode( nMode )   INLINE ::nMode := nMode
      METHOD SetColor( nClr )   INLINE ::nColor := nClr
   
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
