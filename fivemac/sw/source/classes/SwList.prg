#include "FiveMac.ch"
 
 #define SW_TYPE_LIST 8
 
 CLASS TSwList FROM TSwiftControl
  
      DATA cSelectedId

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
      METHOD OnAction()
      METHOD Update( hNewState )
   
  ENDCLASS
  
  //----------------------------------------------------------------------------//
  
  METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, bAction ) CLASS TSwList
   
      DEFAULT nWidth := 200, nHeight := 300, oWnd := GetWndDefault(), nAutoResize := 0
      
      ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
      ::oWnd := oWnd
      
      ::hState["hasscroll"]   := .T. // Las listas suelen tener scroll por defecto
      ::hState["interactive"] := .F.

      if !Empty( bAction )
         ::bAction := bAction
      endif
   
      ::Create( SW_TYPE_LIST )
   
   return Self
   
  //----------------------------------------------------------------------------//
   
  METHOD AddRow( cId ) CLASS TSwList
     return TSwListRow():New( 0, 0, 0, 0, Self, cId )
    
   //----------------------------------------------------------------------------//
   
   METHOD SelectIndex( nIndex ) CLASS TSwList
       ::hState["selectedindex"] := nIndex
       ::Send():Apply( { "selectedindex" => nIndex } )
   return nil
 
   METHOD Clear() CLASS TSwList
      ::Send():Apply( { "clear" => .T. } )
   return nil
 
   METHOD Filter( cText ) CLASS TSwList
      ::Send():Apply( { "filter" => cText } )
   return nil
    
   //----------------------------------------------------------------------------//
   
   METHOD Update( hNewState ) CLASS TSwList
    
       ::Super:Update( hNewState )
    
       if hb_HHasKey( hNewState, "SelectedId" )
          ::cSelectedId := hNewState["SelectedId"]
       endif
    
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
 // clase fila de lista 
 
   CLASS TSwListRow FROM TSwHStack
   ENDCLASS