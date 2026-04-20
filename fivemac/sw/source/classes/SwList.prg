#include "swfive.ch"
 
 #define SW_TYPE_LIST 8
 
 CLASS TSwList FROM TSwiftControl
   
    DATA cSelectedId
 
    ACCESS SelectedIndex   INLINE hb_HGetDef( ::hState, "selectedindex", 0 )
    ASSIGN SelectedIndex(n) INLINE ::SelectIndex( n )
 
    ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
    ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
       ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
       SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
   
    ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
    ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
       ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
       SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
 
    ACCESS lScroll          INLINE hb_HGetDef( ::hState, "hasscroll", .F. )
    ASSIGN lScroll( l )     INLINE ( ::hState["hasscroll"] := l, SD:Apply( ::cId, { "hasscroll" => l } ) )
   
    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, bAction )
    METHOD AddRow()
    METHOD SelectIndex( nIndex )
    METHOD Clear()
    METHOD Filter( cText )
    METHOD GetIndex( cRowId )
    METHOD OnAction()
    METHOD Update( hNewState )
    
 ENDCLASS
   
 //----------------------------------------------------------------------------//
   
 METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, bAction ) CLASS TSwList
    
    DEFAULT nWidth := 200, nHeight := 300, nAutoResize := 0
       
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    ::oWnd := oWnd
       
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif
       
    ::hState["hasscroll"]   := .T. 
    ::hState["interactive"] := .F.
 
    if !Empty( bAction )
       ::bAction := bAction
    endif
    
    ::hState["type"] := SW_TYPE_LIST
 
    ::Create()
    
 return Self
    
 //----------------------------------------------------------------------------//
    
 METHOD AddRow( cId ) CLASS TSwList
    return TSwListRow():New( 0, 0, 0, 0, Self, cId )
     
 //----------------------------------------------------------------------------//
    
 METHOD SelectIndex( nIndex ) CLASS TSwList
    ::hState["selectedindex"] := nIndex
    SD:Apply( ::cId, { "selectedindex" => nIndex } )
 return nil
  
 METHOD Clear() CLASS TSwList
    SD:Apply( ::cId, { "clear" => .T. } )
 return nil
  
 METHOD Filter( cText ) CLASS TSwList
    SD:Apply( ::cId, { "filter" => cText } )
 return nil
     
 //----------------------------------------------------------------------------//
    
 METHOD Update( hNewState ) CLASS TSwList
     
    if hb_HHasKey( hNewState, "SelectedId" )
       ::cSelectedId := hNewState["SelectedId"]
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
    nIndex := Sw_GetQueryProxy():GetIndex( ::cId, cRowId )
    if !hb_IsNumeric( nIndex ) .or. nIndex == -1
       return 0
    endif
 return nIndex + 1
 
 //----------------------------------------------------------------------------//
 // clase fila de lista 
  
 CLASS TSwListRow FROM TSwHStack
 ENDCLASS
