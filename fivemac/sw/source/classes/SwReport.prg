#include "swfive.ch"

// -------------------------------------------------------------------------- //
// TSwReport: Generador de Reportes Moderno para Fivemac SW
// -------------------------------------------------------------------------- //

CLASS TSwReport
   DATA cId
   DATA cTitle
   DATA aElements    INIT {}
   DATA hConfig      INIT {=>}
   
   METHOD New( cTitle ) CONSTRUCTOR
   
   // Métodos de construcción del reporte
   METHOD AddHeader( cText, cColor, cIcon )
   METHOD AddText( cText, nSize, cColor )
   METHOD AddTable( aHeaders, aRows )
   METHOD AddImage( cPath, nWidth, nHeight )
   METHOD AddDivider()
   
   // Visualización
   METHOD Show()
   METHOD GetJSON()
   
ENDCLASS

// -------------------------------------------------------------------------- //

METHOD New( cTitle ) CLASS TSwReport
   ::cId    := "rpt_" + Lower( hb_uuid() )
   ::cTitle := hb_defaultValue( cTitle, "Report" )
   
   ::hConfig[ "paper" ]  := "A4"
   ::hConfig[ "margin" ] := 20
return self

// -------------------------------------------------------------------------- //

METHOD AddHeader( cText, cColor, cIcon ) CLASS TSwReport
   AAdd( ::aElements, { ;
      "type"  => "header", ;
      "text"  => cText, ;
      "color" => hb_defaultValue( cColor, ".blue" ), ;
      "icon"  => hb_defaultValue( cIcon, "doc.text.fill" ) ;
   } )
return nil

// -------------------------------------------------------------------------- //

METHOD AddText( cText, nSize, cColor ) CLASS TSwReport
   AAdd( ::aElements, { ;
      "type"  => "text", ;
      "text"  => cText, ;
      "size"  => hb_defaultValue( nSize, 14 ), ;
      "color" => hb_defaultValue( cColor, "primary" ) ;
   } )
return nil

// -------------------------------------------------------------------------- //

METHOD AddTable( aHeaders, aRows ) CLASS TSwReport
   AAdd( ::aElements, { ;
      "type"    => "table", ;
      "headers" => aHeaders, ;
      "rows"    => aRows ;
   } )
return nil

// -------------------------------------------------------------------------- //

METHOD AddImage( cPath, nWidth, nHeight ) CLASS TSwReport
   AAdd( ::aElements, { ;
      "type"   => "image", ;
      "path"   => cPath, ;
      "width"  => hb_defaultValue( nWidth, 100 ), ;
      "height" => hb_defaultValue( nHeight, 100 ) ;
   } )
return nil

// -------------------------------------------------------------------------- //

METHOD AddDivider() CLASS TSwReport
   AAdd( ::aElements, { "type" => "divider" } )
return nil

// -------------------------------------------------------------------------- //

METHOD GetJSON() CLASS TSwReport
   local hReport := { ;
      "id"       => ::cId, ;
      "title"    => ::cTitle, ;
      "config"   => ::hConfig, ;
      "elements" => ::aElements ;
   }
return hb_jsonEncode( hReport )

// -------------------------------------------------------------------------- //

METHOD Show() CLASS TSwReport
   SW_LOG( "TSwReport:Show -> " + ::GetJSON() )
   SW_HB_SEND_SW( hb_jsonEncode( { { "cmd" => "report_show", "data" => ::GetJSON() } } ) )
return nil
