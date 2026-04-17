#include "FiveMac.ch"
 
 #define SW_TYPE_IMAGE 4
 
 CLASS TSwImage FROM TSwiftControl
  
      ACCESS cSymbol          INLINE ::hState["symbol"]
      ASSIGN cSymbol( c )     INLINE ( ::hState["symbol"] := c, ::Send():Apply( { "systemname" => c } ) )
      
      ACCESS cFile            INLINE ::hState["file"]
      ASSIGN cFile( c )       INLINE ( ::hState["file"] := c, ::Send():Apply( { "file" => c } ) )

      ACCESS cUrl             INLINE ::hState["url"]
      ASSIGN cUrl( c )        INLINE ( ::hState["url"] := c, ::Send():Apply( { "url" => c } ) )

      ACCESS nMode            INLINE ::hState["mode"]
      ASSIGN nMode( n )       INLINE ( ::hState["mode"] := n, ::Send():Apply( { "mode" => n } ) )

      ACCESS nColor           INLINE hb_HGetDef( ::hState, "color", CLR_BLACK )
      ASSIGN nColor( n )      INLINE ( ::hState["color"] := n, ::Send():Color( ClrToHex( n ) ) )

      METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cSymbol, cFile, cUrl, cId, nAutoResize )
      METHOD SetSymbol( cName ) INLINE ::cSymbol := cName
      METHOD SetFile( cFile )   INLINE ::cFile := cFile
      METHOD SetUrl( cUrl )     INLINE ::cUrl := cUrl
      METHOD SetMode( nMode )   INLINE ::nMode := nMode
      METHOD SetColor( nClr )   INLINE ::nColor := nClr
   
  ENDCLASS
  
  //----------------------------------------------------------------------------//
  
  METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cSymbol, cFile, cUrl, cId, nAutoResize ) CLASS TSwImage
   
      DEFAULT nWidth := 100, nHeight := 100, oWnd := GetWndDefault(), nAutoResize := 0,;
              cSymbol := "", cFile := "", cUrl := ""
      
      if Empty( cId ) ; cId := hb_UUID() ; endif
   
      ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
      ::oWnd := oWnd
      
      ::hState["symbol"] := cSymbol
      ::hState["file"]   := cFile
      ::hState["url"]    := cUrl
      ::hState["mode"]   := 0  // fit por defecto
   
      ::Create( SW_TYPE_IMAGE )
   
   return Self
   
  //----------------------------------------------------------------------------//
