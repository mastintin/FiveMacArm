#include "FiveMac.ch"

function Main()

    local oWnd, oMap, oBtn
    local cFrom := "Apple Park, Cupertino, CA"
    local cTo := "San Francisco, CA"
    local oGetFrom, oGetTo
    local cInstructions := ""
    local oMemo
    local lTraffic := .F.
    local hPin
    local cPOI := "Pizza"
    local oGetPOI
    
    DEFINE WINDOW oWnd TITLE "MapKit Routing"  NOFLIPPED ;
        FROM 50, 50 TO 700, 1000 FLIPPED
      
    oMap = TNativeMap():New( 20, 20, 760, 360, oWnd )
    oMap:SetResizing( 18 ) // NSViewWidthSizable | NSViewHeightSizable
   
    // Apple Park
    oMap:SetCenter( 37.334900, -122.009020, 0.01 )
   
    
    // --- Routing Group (Left) ---
    @ 400, 20 SAY "From:" OF oWnd AUTORESIZE 8
    @ 400, 65 GET oGetFrom VAR cFrom SIZE 300, 24 OF oWnd AUTORESIZE 8
    
    @ 430, 20 SAY "To:" OF oWnd AUTORESIZE 8
    @ 430, 65 GET oGetTo VAR cTo SIZE 300, 24 OF oWnd AUTORESIZE 8
    
    @ 465, 65 BUTTON "Show Route" OF oWnd SIZE 145, 30 ;
        ACTION oMap:ShowRoute( cFrom, cTo, ;
        { | aInfo | ;
        cInstructions := "Distance: " + AllTrim( Str( aInfo[ 2 ] / 1000, 10, 2 ) ) + " Km" + CRLF + ;
        "Time: " + AllTrim( Str( aInfo[ 3 ] / 60, 10, 0 ) ) + " min" + CRLF + CRLF, ;
        AEval( aInfo[ 1 ], { | c | cInstructions += c + CRLF } ), ;
        oMemo:SetText( cInstructions ) } ) AUTORESIZE 8
        
    @ 465, 220 BUTTON "Clear Route" OF oWnd SIZE 145, 30 ;
        ACTION ( oMap:RemoveOverlays(), oMemo:SetText( "" ) ) AUTORESIZE 8

    // --- Control Group (Center) ---
    @ 400, 400 CHECKBOX lTraffic PROMPT "Show Traffic" OF oWnd ;
        ON CLICK oMap:ShowTraffic( lTraffic ) AUTORESIZE 8

    @ 435, 400 BUTTON "Drop Pin" OF oWnd SIZE 100, 30 ;
        ACTION ( hPin := oMap:AddAnnotation( 37.334900, -122.009020 + ( HB_Random() - 0.5 ) / 100, "Point", "Custom" ), ;
        If( HB_Random() > 0.5, ;
        oMap:SetAnnotationIcon( hPin, "NSActionTemplate" ), ;
        oMap:SetAnnotationColor( hPin, CLR_RED ) ) ) AUTORESIZE 8

    // --- POI Search Group ---
    @ 505, 20 SAY "Search POI:" OF oWnd AUTORESIZE 8
    @ 505, 100 GET oGetPOI VAR cPOI SIZE 200, 24 OF oWnd AUTORESIZE 8
    @ 505, 310 BUTTON "Search" OF oWnd SIZE 80, 24 ;
        ACTION oMap:SearchPOI( cPOI, { | aPOI | ;
        AEval( aPOI, { | a | oMap:AddAnnotation( a[ 2 ], a[ 3 ], a[ 1 ], "POI Found" ) } ) ;
        } ) AUTORESIZE 8

    // --- Camera Controls ---
    @ 400, 520 BUTTON "Pitch +" OF oWnd SIZE 70, 30 ;
        ACTION oMap:SetCamera( Min( oMap:GetPitch() + 10, 80 ), , , .T. ) AUTORESIZE 8
    @ 400, 600 BUTTON "Pitch -" OF oWnd SIZE 70, 30 ;
        ACTION oMap:SetCamera( Max( oMap:GetPitch() - 10, 0 ), , , .T. ) AUTORESIZE 8

    @ 435, 520 BUTTON "Rot +" OF oWnd SIZE 70, 30 ;
        ACTION oMap:SetCamera( , oMap:GetHeading() + 30, , .T. ) AUTORESIZE 8
    @ 435, 600 BUTTON "Rot -" OF oWnd SIZE 70, 30 ;
        ACTION oMap:SetCamera( , oMap:GetHeading() - 30, , .T. ) AUTORESIZE 8

    // --- Map Types (Bottom Row) ---
    @ 540, 20  BUTTON "Standard"  OF oWnd SIZE 90, 30 ACTION oMap:SetType( 0 ) AUTORESIZE 8
    @ 540, 115 BUTTON "Satellite" OF oWnd SIZE 90, 30 ACTION oMap:SetType( 1 ) AUTORESIZE 8
    @ 540, 210 BUTTON "Hybrid"    OF oWnd SIZE 90, 30 ACTION oMap:SetType( 2 ) AUTORESIZE 8
    @ 540, 305 BUTTON "Flyover"   OF oWnd SIZE 90, 30 ACTION oMap:SetType( 3 ) AUTORESIZE 8
    @ 540, 400 BUTTON "H-Flyover" OF oWnd SIZE 90, 30 ACTION oMap:SetType( 4 ) AUTORESIZE 8

    // --- Zoom Group (Bottom Right) ---
    @ 540, 540 BUTTON "Zoom In" OF oWnd SIZE 90, 30 ACTION oMap:Zoom( 0.5 ) AUTORESIZE 8
    @ 540, 640 BUTTON "Zoom Out" OF oWnd SIZE 90, 30 ACTION oMap:Zoom( 2.0 ) AUTORESIZE 8

    @ 20, 790 GET oMemo VAR cInstructions MULTILINE SIZE 200, 560 OF oWnd AUTORESIZE 17
   
    ACTIVATE WINDOW oWnd CENTERED
   
return nil
