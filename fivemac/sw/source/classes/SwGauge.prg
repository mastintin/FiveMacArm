#include "swfive.ch"

#define SW_TYPE_GAUGE 32

CLASS TSwGauge FROM TSwiftControl

   ACCESS Value          INLINE ::hState["value"]
   ASSIGN Value( n )     INLINE ( ::hState["value"] := n, ::Apply( { "value" => n } ) )

   ACCESS Min            INLINE ::hState["min"]
   ASSIGN Min( n )       INLINE ( ::hState["min"] := n, ::Apply( { "min" => n } ) )

   ACCESS Max            INLINE ::hState["max"]
   ASSIGN Max( n )       INLINE ( ::hState["max"] := n, ::Apply( { "max" => n } ) )

   ACCESS Prompt         INLINE hb_HGetDef( ::hState, "prompt", "" )
   ASSIGN Prompt( c )    INLINE ( ::hState["prompt"] := c, ::Apply( { "prompt" => c } ) )

   ACCESS Subtitle       INLINE hb_HGetDef( ::hState, "subtitle", "" )
   ASSIGN Subtitle( c )  INLINE ( ::hState["subtitle"] := c, ::Apply( { "subtitle" => c } ) )

   ACCESS Icon           INLINE hb_HGetDef( ::hState, "icon", "" )
   ASSIGN Icon( c )      INLINE ( ::hState["icon"] := c, ::Apply( { "icon" => c } ) )

   ACCESS TintColor      INLINE hb_HGetDef( ::hState, "tintcolor", "" )
   ASSIGN TintColor( c ) INLINE ( ::hState["tintcolor"] := c, ::Apply( { "tintcolor" => c } ) )

   ACCESS Style          INLINE hb_HGetDef( ::hState, "style", 0 )
   ASSIGN Style( n )     INLINE ( ::hState["style"] := n, ::Apply( { "style" => n } ) )

   ACCESS UnitText       INLINE hb_HGetDef( ::hState, "unittext", "" )
   ASSIGN UnitText( c )  INLINE ( ::hState["unittext"] := c, ::Apply( { "unittext" => c } ) )

   ACCESS lShowValueLabel  INLINE hb_HGetDef( ::hState, "showvaluelabel", .T. )
   ASSIGN lShowValueLabel( l ) INLINE ( ::hState["showvaluelabel"] := l, ::Apply( { "showvaluelabel" => l } ) )

   METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId,;
               cPrompt, cSubtitle, cIcon, cColor, nStyle, lDisabled, nAutoResize,;
               lShowValueLabel, cUnitText )

   METHOD SetValue( nVal, lSync )
   METHOD SetStyle( nStyle )
   METHOD SetEnabled( lEnabled ) INLINE If( lEnabled, ::Enable(), ::Disable() )
   METHOD IsEnabled()            INLINE ::Super:isEnabled
   METHOD SetVisible( lVisible ) INLINE If( lVisible, ::Show(), ::Hide() )
   METHOD IsVisible()            INLINE ::Super:isVisible

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, nValue, nMin, nMax, oWnd, cId,;
            cPrompt, cSubtitle, cIcon, cColor, nStyle, lDisabled, nAutoResize,;
            lShowValueLabel, cUnitText ) CLASS TSwGauge

   DEFAULT nWidth := 80, nHeight := 80, nValue := 0, nMin := 0, nMax := 100

   ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )

   ::hState["value"]         := hb_defaultValue( nValue, 0 )
   ::hState["min"]           := hb_defaultValue( nMin, 0 )
   ::hState["max"]           := hb_defaultValue( nMax, 100 )
   ::hState["type"]          := 32
   ::hState["prompt"]        := hb_defaultValue( cPrompt, "" )
   ::hState["subtitle"]      := hb_defaultValue( cSubtitle, "" )
   ::hState["icon"]          := hb_defaultValue( cIcon, "" )
   ::hState["tintcolor"]     := hb_defaultValue( cColor, "" )
   ::hState["style"]         := hb_defaultValue( nStyle, 0 )
   ::hState["showvaluelabel"] := hb_defaultValue( lShowValueLabel, .T. )
   ::hState["unittext"]      := hb_defaultValue( cUnitText, "" )
   ::hState["enabled"]       := ! hb_defaultValue( lDisabled, .F. )

   ::oWnd := oWnd

   ::Create()

return self

//----------------------------------------------------------------------------//

METHOD SetValue( nVal, lSync ) CLASS TSwGauge
   if hb_DefaultValue( lSync, .F. )
      ::hState["value"] := nVal
      ::Apply( { "value" => nVal } ):Sync()
   else
      ::Value := nVal
   endif
return nil

//----------------------------------------------------------------------------//

METHOD SetStyle( nStyle ) CLASS TSwGauge
   ::hState["style"] := nStyle
   ::Apply( { "style" => nStyle } )
return nil
