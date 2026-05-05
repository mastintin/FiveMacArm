#include "swfive.ch"
 
 #define SW_TYPE_ZSTACK 24
  
 CLASS TSwZStack FROM TSwiftControl
 
     ACCESS cColor           INLINE hb_HGetDef( ::hState, "backcolor", "" )
     ASSIGN cColor( c )      INLINE ( ::hState["backcolor"] := c, ::Apply( "backcolor", c ) )
 
     ACCESS nSpacing         INLINE hb_HGetDef( ::hState, "spacing", 0 )
     ASSIGN nSpacing( n )    INLINE ( ::hState["spacing"] := n, ::Apply( "spacing", n ) )
 
     ACCESS nCorner          INLINE hb_HGetDef( ::hState, "corner", 0 )
     ASSIGN nCorner( n )     INLINE ( ::hState["corner"] := n, ::Apply( "corner", n ) )

     ACCESS nAlignment       INLINE hb_HGetDef( ::hState, "alignment", 0 )
     ASSIGN nAlignment( n )  INLINE ( ::hState["alignment"] := n, ::Apply( "alignment", n ) )

     ACCESS nPadding         INLINE hb_HGetDef( ::hState, "padding", 8 )
     ASSIGN nPadding( n )    INLINE ( ::hState["padding"] := n, ::Apply( "padding", n ) )
 
     METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize, cBackColor, nCorner )
 
 ENDCLASS
  
 //----------------------------------------------------------------------------//
  
 METHOD New( nTop, nLeft, nWidth, nHeight, oParent, cId, nAutoResize, cBackColor, nCorner ) CLASS TSwZStack
 
     DEFAULT nWidth := 100, nHeight := 100, nAutoResize := 0
      
     if Empty( cId ) ; cId := Lower( hb_uuid() ) ; endif
  
     ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
     
     if hb_IsObject( oParent )
        ::oWnd               := if( __ObjHasData( oParent, "oWnd" ), oParent:oWnd, oParent )
        ::hState["parentid"] := if( __ObjHasData( oParent, "cId"  ), oParent:cId , "NONE" )
     else 
        ::oWnd := oParent
     endif 
     
     ::oParent := oParent
      
     ::hState["type"] := SW_TYPE_ZSTACK
    if !Empty( cBackColor ); ::hState["backcolor"] := cBackColor; endif
    if !Empty( nCorner );    ::hState["corner"] := nCorner; endif

    ::Create()
  
 return Self
