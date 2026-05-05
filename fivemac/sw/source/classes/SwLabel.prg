#include "swfive.ch"
 
 #define SW_TYPE_TEXT 0
 
 CLASS TSwLabel FROM TSwiftControl
 
    ACCESS Caption          INLINE ::hState["text"]
    ASSIGN Caption(c)       INLINE ( ::hState["text"] := c, ::Apply( "text", c ) )
 
    ACCESS Value            INLINE ::Caption
    ASSIGN Value(c)         INLINE ::Caption := c
 
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
 
    ACCESS cBorderShape     INLINE hb_HGetDef( ::hState, "bordershape", "" )
    ASSIGN cBorderShape( c ) INLINE ( ::hState["bordershape"] := c, ::Apply( "bordershape", c ) )

    ACCESS nIconSize        INLINE hb_HGetDef( ::hState, "iconsize", 0 )
    ASSIGN nIconSize( n )   INLINE ( ::hState["iconsize"] := n, ::Apply( "iconsize", n ) )

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId, nAutoResize, cFont, cColor, cBackColor, cIcon, cIconColor, cShape, nAlign, nIconSize )
    METHOD SetText( cText, lSync )
    METHOD SetPrompt( cText ) INLINE ::SetText( cText )
   
 ENDCLASS
 
 // -------------------------------------------------------------------------------- //
 
 METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId, nAutoResize, cFont, cColor, cBackColor, cIcon, cIconColor, cShape, nAlign, nIconSize ) CLASS TSwLabel
 
    DEFAULT nWidth := 100, nHeight := 20
     
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
  
    ::hState["text"]        := cText
    ::hState["type"]        := SW_TYPE_TEXT
    ::hState["hasscroll"]   := .F.
  
    ::oWnd     := oWnd
     
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif

    if !Empty( cFont );      ::hState["fontstyle"] := cFont; endif
    if !Empty( cColor );     ::hState["color"] := cColor; endif
    if !Empty( cBackColor ); ::hState["backcolor"] := cBackColor; endif
    if !Empty( cIcon );      ::hState["icon"] := cIcon; endif
    if !Empty( cIconColor ); ::hState["iconcolor"] := cIconColor; endif
    if !Empty( cShape );     ::hState["bordershape"] := cShape; endif
    if !Empty( nAlign );     ::hState["alignment"] := nAlign; endif
    if !Empty( nIconSize );  ::hState["iconsize"] := nIconSize; endif
 
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
