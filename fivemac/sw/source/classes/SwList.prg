#include "FiveMac.ch"
 
 #define SW_TYPE_LIST 8
 
 CLASS TSwList FROM TSwiftControl
  
      DATA cSelectedId
  
      METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, bAction )
      METHOD AddRow()
      METHOD SelectIndex( nIndex )
      METHOD OnAction()
      METHOD Update( hNewState )
   
  ENDCLASS
  
  //----------------------------------------------------------------------------//
  
  CLASS TSwListRow FROM TSwHStack
  ENDCLASS
  
  //----------------------------------------------------------------------------//
  
  METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cId, nAutoResize, bAction ) CLASS TSwList
   
      DEFAULT nWidth := 200, nHeight := 300, oWnd := GetWndDefault(), nAutoResize := 0
      
      if Empty( cId ) ; cId := hb_UUID() ; endif
   
      ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
      ::oWnd := oWnd
      
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
    
   //----------------------------------------------------------------------------//
   
   METHOD Update( hNewState ) CLASS TSwList
    
       ::Super:Update( hNewState )
    
       if hb_HHasKey( hNewState, "SelectedId" )
          ::cSelectedId := hNewState["SelectedId"]
       endif
    
   return nil
    
   //----------------------------------------------------------------------------//
   
   METHOD OnAction() CLASS TSwList
       if ::bAction != nil
          Eval( ::bAction, ::cSelectedId, Self )
       endif
   return nil
