#include "FiveMac.ch"

#define MKMapTypeStandard          0
#define MKMapTypeSatellite         1
#define MKMapTypeHybrid            2
#define MKMapTypeSatelliteFlyover  3
#define MKMapTypeHybridFlyover     4

CLASS TNativeMap FROM TControl

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd )
   
    METHOD SetType( nType ) INLINE MKMapSetType( ::hWnd, nType )
   
    METHOD SetCenter( nLat, nLon, nZoom ) INLINE MKMapSetCenter( ::hWnd, nLat, nLon, nZoom )
   
    METHOD AddAnnotation( nLat, nLon, cTitle, cSubtitle ) INLINE ;
        MKMapAddAnnotation( ::hWnd, nLat, nLon, cTitle, cSubtitle )
          
    METHOD SelectAnnotation( hAnnotation ) INLINE MKMapSelectAnnotation( ::hWnd, hAnnotation )
   
    METHOD GoToAddress( cAddress ) INLINE MKMapGoToLocation( ::hWnd, cAddress )
   
    METHOD ShowRoute( cFrom, cTo, bAction ) INLINE MKMapShowRoute( ::hWnd, cFrom, cTo, bAction )

    METHOD ShowTraffic( lShow ) INLINE MKMapShowTraffic( ::hWnd, lShow )

    METHOD SetCamera( nPitch, nHeading, nAltitude, lAnimated ) INLINE ;
        MKMapSetCamera( ::hWnd, nPitch, nHeading, nAltitude, lAnimated )

    METHOD GetPitch() INLINE MKMapGetPitch( ::hWnd )
    METHOD GetHeading() INLINE MKMapGetHeading( ::hWnd )
    METHOD GetAltitude() INLINE MKMapGetAltitude( ::hWnd )

    METHOD SetAnnotationIcon( hAnnotation, cImageName ) INLINE ;
        MKMapSetAnnotationIcon( hAnnotation, cImageName )

    METHOD SetAnnotationColor( hAnnotation, nColor ) INLINE ;
        MKMapSetAnnotationColor( ::hWnd, hAnnotation, nColor )

    METHOD SearchPOI( cSearch, bCallback ) INLINE ;
        MKMapSearchPOI( ::hWnd, cSearch, bCallback )

    METHOD SetResizing( nMask ) INLINE MKMapSetResizing( ::hWnd, nMask )

    METHOD Zoom( nLevel ) INLINE MKMapZoom( ::hWnd, nLevel )
   
    METHOD RemoveOverlays() INLINE MKMapRemoveOverlays( ::hWnd )

    METHOD RemoveAnnotations() INLINE MKMapRemoveAnnotations( ::hWnd )

    METHOD Remove() INLINE ::oWnd:RemoveControl( Self )
   
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd ) CLASS TNativeMap

    DEFAULT nWidth := 300, nHeight := 300, oWnd := GetWndDefault()

    ::hWnd = MKMapCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )
    ::oWnd = oWnd
   
    oWnd:AddControl( Self )
   
return Self
