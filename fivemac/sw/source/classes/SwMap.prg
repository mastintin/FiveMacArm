#include "swfive.ch"

#define SW_TYPE_MAP 29

CLASS TSwMap FROM TSwiftControl

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, nLat, nLon, nZoom, nStyle, nRes )
   
   METHOD SetCenter( nLat, nLon )
   METHOD SetZoom( nZoom )
   METHOD SetStyle( nStyle ) // 0: Standard, 1: Satellite, 2: Hybrid
   METHOD Search( cText )
   
   // Nuevos métodos para paridad con nativemap.prg
   METHOD AddAnnotation( nLat, nLon, cTitle, cSubtitle )
   METHOD RemoveAnnotations()
   METHOD ShowTraffic( lShow )
   METHOD SetCamera( nPitch, nHeading, nDistance ) 

ENDCLASS

//----------------------------------------------------------------------------//

METHOD AddAnnotation( nLat, nLon, cTitle, cSubtitle ) CLASS TSwMap
   ::Apply( "addannotation", { "lat" => nLat, "lon" => nLon, "title" => cTitle, "subtitle" => cSubtitle } )
return nil

//----------------------------------------------------------------------------//

METHOD RemoveAnnotations() CLASS TSwMap
   ::Apply( "removeannotations", .t. )
return nil

//----------------------------------------------------------------------------//

METHOD ShowTraffic( lShow ) CLASS TSwMap
   DEFAULT lShow := .T.
   ::Apply( "traffic", lShow )
return nil

//----------------------------------------------------------------------------//

METHOD SetCamera( nPitch, nHeading, nDistance ) CLASS TSwMap
   local hCam := {=>}
   if !hb_IsNil( nPitch )    ; hCam["pitch"]    := nPitch    ; endif
   if !hb_IsNil( nHeading )  ; hCam["heading"]  := nHeading  ; endif
   if !hb_IsNil( nDistance ) ; hCam["distance"] := nDistance ; endif
   ::Apply( "camera", hCam )
return nil

//----------------------------------------------------------------------------//

METHOD Search( cText ) CLASS TSwMap
   ::Apply( "search", cText )
return nil

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, nLat, nLon, nZoom, nStyle, nRes ) CLASS TSwMap

   DEFAULT nLat := 40.4167, nLon := -3.7037, nZoom := 0.05, nStyle := 0, nRes := 0
   
   ::Super:New( nTop, nLeft, nWidth, nHeight, , nRes )
   
   ::hState["type"]        := SW_TYPE_MAP
   ::hState["lat"]         := nLat
   ::hState["lon"]         := nLon
   ::hState["zoom"]        := nZoom
   ::hState["style"]       := nStyle
   
   ::oWnd     := oWnd
   
   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif

   ::Create()

return self

//----------------------------------------------------------------------------//

METHOD SetCenter( nLat, nLon ) CLASS TSwMap
   ::Apply( "lat", nLat )
   ::Apply( "lon", nLon )
return nil

//----------------------------------------------------------------------------//

METHOD SetZoom( nZoom ) CLASS TSwMap
   ::Apply( "zoom", nZoom )
return nil

//----------------------------------------------------------------------------//

METHOD SetStyle( nStyle ) CLASS TSwMap
   ::Apply( "style", nStyle )
return nil
