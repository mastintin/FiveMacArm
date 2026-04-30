#include "swfive.ch"
 
 #define SW_TYPE_LIST 8
 
 CLASS TSwList FROM TSwiftControl
   
    DATA cSelectedId
 
    ACCESS SelectedIndex    INLINE hb_HGetDef( ::hState, "selectedindex", 0 )
    ASSIGN SelectedIndex(n) INLINE ( ::hState["selectedindex"] := n, ::Apply( { "selectedindex" => n } ) )
 
    ACCESS nStyle           INLINE hb_HGetDef( ::hState, "style", 0 )
    ASSIGN nStyle( n )      INLINE ( ::hState["style"] := n, ::Apply( { "style" => n } ) )

    ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
    ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
       ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
       ::Apply( { "interactive" => ::hState["interactive"] } ) )
   
    ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
    ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
       ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
       ::Apply( { "interactive" => ::hState["interactive"] } ) )
 
    ACCESS lScroll          INLINE hb_HGetDef( ::hState, "hasscroll", .F. )
    ASSIGN lScroll( l )     INLINE ( ::hState["hasscroll"] := l, ::Apply( { "hasscroll" => l } ) )
    
    ACCESS lSearch          INLINE hb_HGetDef( ::hState, "hassearch", .F. )
    ASSIGN lSearch( l )     INLINE ( ::hState["hassearch"] := l, ::Apply( { "hassearch" => l } ) )
    
    ACCESS nSearchStyle          INLINE hb_HGetDef( ::hState, "searchstyle", 0 )
    ASSIGN nSearchStyle( n )     INLINE ( ::hState["searchstyle"] := n, ::Apply( { "searchstyle" => n } ) )
   
    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, bAction, nStyle, lSearch )
    METHOD AddRow()
    METHOD Clear()
    METHOD Filter( cText )
    METHOD GetIndex( cRowId )
    METHOD OnAction()
    METHOD Update( hNewState )
    
 ENDCLASS
   
 //----------------------------------------------------------------------------//
   
 METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, bAction, nStyle, lSearch ) CLASS TSwList
    
    DEFAULT nWidth := 200, nHeight := 300, nAutoResize := 0, nStyle := 0, lSearch := .F.
       
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    ::oWnd := oWnd
       
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif
       
    ::hState["hasscroll"]   := .T. 
    ::hState["interactive"] := .F.
    ::hState["style"]       := nStyle
    ::hState["hassearch"]   := lSearch
 
    if !Empty( bAction )
       ::bAction := bAction
    endif
    
    ::hState["type"] := SW_TYPE_LIST
 
    ::Create()
    ::Apply( { "style" => ::hState["style"], "hassearch" => ::hState["hassearch"] } )
    
 return Self
    
 //----------------------------------------------------------------------------//
    
 METHOD AddRow( cId ) CLASS TSwList
    return TSwListRow():New( 0, 0, 0, 0, Self, cId )
     
 //----------------------------------------------------------------------------//
  
 METHOD Clear() CLASS TSwList
    ::Apply( { "clear" => .T. } )
 return nil
  
 METHOD Filter( cText ) CLASS TSwList
    ::Apply( { "filter" => cText } )
 return nil
     
 //----------------------------------------------------------------------------//
    
 METHOD Update( hNewState ) CLASS TSwList
     
    if hb_HHasKey( hNewState, "SelectedId" )
       ::cSelectedId := hNewState["SelectedId"]
       // Update the index automatically based on the ID
       ::hState["selectedindex"] := ::GetIndex( ::cSelectedId )
    elseif hb_HHasKey( hNewState, "selectedId" )
       ::cSelectedId := hNewState["selectedId"]
       ::hState["selectedindex"] := ::GetIndex( ::cSelectedId )
    endif
 
    ::Super:Update( hNewState )
     
 return nil
     
 //----------------------------------------------------------------------------//
    
 METHOD OnAction() CLASS TSwList
    if !Empty( ::bPipeline )
       WITH OBJECT Sw_GetProxy()
          :Pipeline( ::bPipeline )
       END
    elseif !Empty( ::bAction )
       Eval( ::bAction, ::cSelectedId, Self )
    endif
 return nil
 
 //----------------------------------------------------------------------------//
 
 METHOD GetIndex( cRowId ) CLASS TSwList
    local nIndex
    // El Proxy ya nos devuelve el valor contenido en la clave "result" directamente
    nIndex := SWProxy("q"):GetIndex( ::cId, cRowId )
    if !hb_IsNumeric( nIndex ) .or. nIndex == -1
       return 0
    endif
 return nIndex + 1
 
 //----------------------------------------------------------------------------//
 // clase fila de lista 
  
 CLASS TSwListRow FROM TSwHStack
 ENDCLASS
