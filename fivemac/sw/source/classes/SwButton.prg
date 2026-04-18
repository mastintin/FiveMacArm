#include "FiveMac.ch"
 
 CLASS TSwButton FROM TSwiftControl
 
     ACCESS Caption      INLINE ::hState["caption"]
     ASSIGN Caption( c ) INLINE ::SetText( c )
 
     ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
     ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
                                      SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )
  
     ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
     ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
                                      SD:Apply( ::cId, { "interactive" => ::hState["interactive"] } ) )

     METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId )
     METHOD SetText( cText )
     METHOD OnAction()
     METHOD End()
       
 ENDCLASS
 
 //----------------------------------------------------------------------------//

 METHOD New( nTop, nLeft, nWidth, nHeight, cPrompt, oWnd, bAction, nAutoResize, cId ) CLASS TSwButton
 
     DEFAULT nWidth := 90, nHeight := 30, cPrompt := "SwBtn", nAutoResize := 0
     
     ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
     
     ::oWnd     := oWnd
     ::hState["caption"] := cPrompt
     ::hState["type"]    := 9
     ::hState["interactive"] := .F.

     ::bAction  := bAction
    
     ::Create( 9 )
     
  return Self
 
 //----------------------------------------------------------------------------//

 METHOD OnAction() CLASS TSwButton
    if !Empty( ::bPipeline )
       WITH OBJECT Sw_GetProxy()
          :Pipeline( ::bPipeline )
       END
    elseif !Empty( ::bAction )
       Eval( ::bAction, Self )
    endif
 return nil

 //----------------------------------------------------------------------------//

 METHOD SetText( cText ) CLASS TSwButton
     SD:Text( ::cId, cText )
 return nil
  
 //----------------------------------------------------------------------------//

 METHOD End() CLASS TSwButton
     SwiftUnregisterItem( ::cId )
 return ::Super:End()
