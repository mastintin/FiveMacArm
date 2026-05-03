#include "swfive.ch"
 
 #define SW_TYPE_SLIDER 11
 
 CLASS TSwSlider FROM TSwiftControl
 
     ACCESS Value      INLINE ::hState["value"]
     ASSIGN Value( n ) INLINE ( ::hState["value"] := n, ::Apply( { "value" => n } ), ::OnAction() )
 
     ACCESS Min        INLINE ::hState["min"]
     ASSIGN Min( n )   INLINE ( ::hState["min"] := n, ::Apply( { "min" => n } ) )
 
     ACCESS Max        INLINE ::hState["max"]
     ASSIGN Max( n )   INLINE ( ::hState["max"] := n, ::Apply( { "max" => n } ) )

     ACCESS Prompt        INLINE hb_HGetDef( ::hState, "prompt", "" )
     ASSIGN Prompt( c )   INLINE ( ::hState["prompt"] := c, ::Apply( { "prompt" => c } ) )

     ACCESS IconMin       INLINE hb_HGetDef( ::hState, "iconmin", "" )
     ASSIGN IconMin( c )  INLINE ( ::hState["iconmin"] := c, ::Apply( { "iconmin" => c } ) )

     ACCESS IconMax       INLINE hb_HGetDef( ::hState, "iconmax", "" )
     ASSIGN IconMax( c )  INLINE ( ::hState["iconmax"] := c, ::Apply( { "iconmax" => c } ) )

     ACCESS TintColor     INLINE hb_HGetDef( ::hState, "tintcolor", "" )
     ASSIGN TintColor( c ) INLINE ( ::hState["tintcolor"] := c, ::Apply( { "tintcolor" => c } ) )

     ACCESS Step          INLINE hb_HGetDef( ::hState, "step", 0 )
     ASSIGN Step( n )     INLINE ( ::hState["step"] := n, ::Apply( { "step" => n } ) )

     ACCESS lShowValue      INLINE hb_HGetDef( ::hState, "showvalue", .T. )
     ASSIGN lShowValue( l ) INLINE ( ::hState["showvalue"] := l, ::Apply( { "showvalue" => l } ) )
 
     ACCESS bAction          INLINE hb_HGetDef( ::hState, "action", nil )
     ASSIGN bAction( u )     INLINE ( ::hState["action"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bPipeline ),;
                                      ::Apply( { "interactive" => ::hState["interactive"] } ) )
   
     ACCESS bPipeline        INLINE hb_HGetDef( ::hState, "pipeline", nil )
     ASSIGN bPipeline( u )   INLINE ( ::hState["pipeline"] := u,;
                                      ::hState["interactive"] := !Empty( u ) .or. !Empty( ::bAction ),;
                                      ::Apply( { "interactive" => ::hState["interactive"] } ) )
 
     METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId, bAction,;
                 cPrompt, cIconMin, cIconMax, cColor, nStep, lDisabled, nAutoResize, lShowValue )
     METHOD SetValue( nVal, lSync )
     METHOD Update( hNewState )
     METHOD OnAction()
     METHOD SetEnabled( lEnabled ) INLINE If( lEnabled, ::Enable(), ::Disable() )
     METHOD IsEnabled()            INLINE ::Super:isEnabled
     METHOD SetVisible( lVisible ) INLINE If( lVisible, ::Show(), ::Hide() )
     METHOD IsVisible()            INLINE ::Super:isVisible
 
 ENDCLASS
 
 //----------------------------------------------------------------------------//
 
 METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId, bAction,;
             cPrompt, cIconMin, cIconMax, cColor, nStep, lDisabled, nAutoResize, lShowValue ) CLASS TSwSlider
    
    DEFAULT nWidth := 200, nHeight := 30
    
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
    
    ::hState["value"]       := hb_defaultValue( nValue, 0 )
    ::hState["min"]         := hb_defaultValue( nMin, 0 )
    ::hState["max"]         := hb_defaultValue( nMax, 100 )
    ::hState["showvalue"]   := hb_defaultValue( lShowValue, .T. )
    ::hState["type"]        := 11
    ::hState["interactive"] := .F.
    
    ::hState["prompt"]      := hb_defaultValue( cPrompt, "" )
    ::hState["iconmin"]     := hb_defaultValue( cIconMin, "" )
    ::hState["iconmax"]     := hb_defaultValue( cIconMax, "" )
    ::hState["tintcolor"]   := hb_defaultValue( cColor, "" )
    ::hState["step"]        := hb_defaultValue( nStep, 0 )
    ::hState["enabled"]     := ! hb_defaultValue( lDisabled, .F. )
 
    ::bAction     := bAction
    ::oWnd        := oWnd
 
    ::Create()
 
    return self
  
 //----------------------------------------------------------------------------//
 
 METHOD SetValue( nVal, lSync ) CLASS TSwSlider
     if hb_DefaultValue( lSync, .F. )
        ::hState["value"] := nVal
        ::Apply( { "value" => nVal } ):Sync()
        ::OnAction()
     else
        ::Value := nVal
     endif
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
