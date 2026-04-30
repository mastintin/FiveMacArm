#include "swfive.ch"
 
 #define SW_TYPE_TEXT 0
 
 CLASS TSwLabel FROM TSwiftControl
 
    ACCESS Caption          INLINE ::hState["text"]
    ASSIGN Caption(c)       INLINE ( ::hState["text"] := c, ::Apply( "text", c ) )
 
    ACCESS lScroll          INLINE hb_HGetDef( ::hState, "hasscroll", .F. )
    ASSIGN lScroll( l )     INLINE ( ::hState["hasscroll"] := l, ::Apply( "hasscroll", l ) )
   
    ACCESS uFontSize        INLINE hb_HGetDef( ::hState, "fontsize", 13 )
    ASSIGN uFontSize( u )   INLINE ( ::hState["fontsize"] := u, ::Apply( "fontsize", u ) )

    ACCESS cFontStyle       INLINE hb_HGetDef( ::hState, "fontstyle", "" )
    ASSIGN cFontStyle( c )  INLINE ( ::hState["fontstyle"] := c, ::Apply( "fontstyle", c ) )

    ACCESS cColor           INLINE hb_HGetDef( ::hState, "color", "" )
    ASSIGN cColor( c )      INLINE ( ::hState["color"] := c, ::Apply( "color", c ) )

    ACCESS nAlignment       INLINE hb_HGetDef( ::hState, "alignment", 0 )
    ASSIGN nAlignment( n )  INLINE ( ::hState["alignment"] := n, ::Apply( "alignment", n ) )

    ACCESS cBackColor       INLINE hb_HGetDef( ::hState, "backcolor", "" )
    ASSIGN cBackColor( c )  INLINE ( ::hState["backcolor"] := c, ::Apply( "backcolor", c ) )

    ACCESS nShadow          INLINE hb_HGetDef( ::hState, "shadow", 0 )
    ASSIGN nShadow( n )     INLINE ( ::hState["shadow"] := n, ::Apply( "shadow", n ) )

    ACCESS nTextShadow      INLINE hb_HGetDef( ::hState, "textshadow", 0 )
    ASSIGN nTextShadow( n ) INLINE ( ::hState["textshadow"] := n, ::Apply( "textshadow", n ) )

    ACCESS cVibrance        INLINE hb_HGetDef( ::hState, "vibrance", "" )
    ASSIGN cVibrance( c )   INLINE ( ::hState["vibrance"] := c, ::Apply( "vibrance", c ) )

    ACCESS cIcon            INLINE hb_HGetDef( ::hState, "icon", "" )
    ASSIGN cIcon( c )       INLINE ( ::hState["icon"] := c, ::Apply( "icon", c ) )

    ACCESS cIconColor       INLINE hb_HGetDef( ::hState, "iconcolor", "" )
    ASSIGN cIconColor( c )  INLINE ( ::hState["iconcolor"] := c, ::Apply( "iconcolor", c ) )
 
    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId, nAutoResize )
    METHOD SetText( cText, lSync )
    METHOD SetPrompt( cText ) INLINE ::SetText( cText )
   
 ENDCLASS
 
 // -------------------------------------------------------------------------------- //
 
 METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId, nAutoResize ) CLASS TSwLabel
 
    DEFAULT nWidth := 100, nHeight := 20
     
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
  
    ::hState["text"]        := cText
    ::hState["type"]        := SW_TYPE_TEXT
    ::hState["hasscroll"]   := .F.
  
    ::oWnd     := oWnd
     
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif
 
    ::Create()
  
 return self
  
 // -------------------------------------------------------------------------------- //
  
 METHOD SetText( cText, lSync ) CLASS TSwLabel
    if hb_DefaultValue( lSync, .F. )
       ::hState["text"] := cText
       ::Apply( { "text" => cText } ):Sync()
    else
       ::Caption := cText
    endif
 return nil
