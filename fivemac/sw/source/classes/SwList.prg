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

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, bAction, nStyle, lSearch ) CONSTRUCTOR
    METHOD AddRow( cId )
    METHOD AddItem( cId )   INLINE ::AddRow( cId )
    METHOD Add( cId )       INLINE ::AddRow( cId )
    
    METHOD Select( cId )    INLINE ( ::cSelectedId := cId, ::Apply( { "selectedid" => cId } ) )
    METHOD Clear()          INLINE ( ::Apply( { "clear" => .T. } ) )
    
    METHOD SetFilter( cText ) INLINE ::Apply( { "filter" => cText } )
    
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
       
    ::hState["hasscroll"]   := 1 
    ::hState["interactive"] := 0
    ::hState["style"]       := nStyle
    ::hState["hassearch"]   := iif( lSearch, 1, 0 )

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
    
 METHOD Update( hNewState ) CLASS TSwList
    
    if hb_HHasKey( hNewState, "selectedid" )
       ::cSelectedId := hNewState["selectedid"]
       
       if !Empty( ::bAction )
          Eval( ::bAction, ::cSelectedId, Self )
       endif
    endif
    
 return nil
 
 //----------------------------------------------------------------------------//
 
 CLASS TSwListRow FROM TSwHStack
    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId ) CONSTRUCTOR
 ENDCLASS
 
 METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId ) CLASS TSwListRow
    ::Super:New( nTop, nLeft, nWidth, nHeight, oWnd, cId )
    ::hState["type"]      := 2 // HStack
    ::hState["alignment"] := 1 // Leading (Izquierda)
    ::Create()
 return Self
