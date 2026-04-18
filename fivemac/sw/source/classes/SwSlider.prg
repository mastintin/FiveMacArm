#include "FiveMac.ch"
 
 #define SW_TYPE_SLIDER 11
 
 CLASS TSwSlider FROM TSwiftControl
 
     ACCESS Value      INLINE ::hState["value"]
     ASSIGN Value( n ) INLINE ::SetValue( n )
 
     ACCESS Min        INLINE ::hState["min"]
     ASSIGN Min( n )   INLINE ( ::hState["min"] := n, SD:Apply( ::cId, { "min" => n } ) )
 
     ACCESS Max        INLINE ::hState["max"]
     ASSIGN Max( n )   INLINE ( ::hState["max"] := n, SD:Apply( ::cId, { "max" => n } ) )

     ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
     ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
                                      SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
  
     ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
     ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
                                      SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
 
     METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId, bAction, nAutoResize )
     METHOD SetValue( nVal, lSync )
     METHOD Update( hNewState )
     METHOD OnAction()
 
 ENDCLASS
 
 //----------------------------------------------------------------------------//

 METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId, bAction, nAutoResize ) CLASS TSwSlider
    
    DEFAULT nWidth := 200, nHeight := 30
    
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    
    ::hState["value"]       := nValue
    ::hState["min"]         := nMin
    ::hState["max"]         := nMax
    ::hState["showValue"]   := .T.
    ::hState["type"]        := 11
    ::hState["interactive"] := .F.

    ::bAction     := bAction
    ::oWnd        := oWnd

    ::Create()
 
 return self
 
 //----------------------------------------------------------------------------//

 METHOD SetValue( nVal, lSync ) CLASS TSwSlider
     DEFAULT lSync := .f.
     ::hState["value"] := nVal
     if ( lSync == .T. )
        SDS:Apply( ::cId, { "value" => nVal } )
     else
        SD:Apply( ::cId, { "value" => nVal } )
     endif
     ::OnAction()
 return nil
 
 //----------------------------------------------------------------------------//

 METHOD Update( hNewState ) CLASS TSwSlider
     local nOldVal := ::Value
     
     ::Super:Update( hNewState )
     
     if ::Value != nOldVal
         ::OnAction()
     endif
 return nil

 //----------------------------------------------------------------------------//

 METHOD OnAction() CLASS TSwSlider
    if !Empty( ::bPipeline )
       WITH OBJECT Sw_GetProxy()
          :Pipeline( ::bPipeline )
       END
    elseif !Empty( ::bAction )
       Eval( ::bAction, ::Value, Self )
    endif
 return nil

 //----------------------------------------------------------------------------//
