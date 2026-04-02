#include "FiveMac.ch"

#define NSFontWeightThin        -0.6
#define NSFontWeightLight       -0.4
#define NSFontWeightRegular      0.0
#define NSFontWeightMedium       0.23
#define NSFontWeightSemibold     0.3
#define NSFontWeightBold         0.4
#define NSFontWeightHeavy        0.56
#define NSFontWeightBlack        0.62

function Main()

    local oWnd, oImg1, oImg2, oImg3, oImg4, oImg5, oImg6, oImg7, oImg8, oImg9
    local oSymbol
   
    DEFINE WINDOW oWnd TITLE "SF Symbols Final Test"  NOFLIPPED ;
        FROM 50, 50 TO 700, 950
      
    @ 20, 20 SAY "Regular (Black)" OF oWnd
    oSymbol := TSFSymbol():New( "wifi" )
    @ 40, 20 IMAGE oImg1 SIZE 64, 64 OF oWnd
    oImg1:SetImage( oSymbol:Handle() )
   
    @ 20, 150 SAY "Hierarchical (H-Red)" OF oWnd
    oSymbol := TSFSymbol():New( "square.and.arrow.up" ) // Fixed name
    oSymbol:SetPointSize( 48 )
    oSymbol:SetColor( CLR_HRED ) 
    @ 40, 150 IMAGE oImg4 SIZE 64, 64 OF oWnd
    oImg4:SetImage( oSymbol:Handle() )

    @ 150, 20 SAY "Multicolor Weather" OF oWnd
    oSymbol := TSFSymbol():New( "cloud.sun.rain.fill" )
    oSymbol:SetPointSize( 60 )
    oSymbol:SetMulticolor( .t. )
    @ 180, 20 IMAGE oImg5 SIZE 100, 100 OF oWnd
    oImg5:SetImage( oSymbol:Handle() )

    @ 150, 150 SAY "Hierarchical Weather (Blue)" OF oWnd
    oSymbol := TSFSymbol():New( "cloud.sun.rain.fill" )
    oSymbol:SetPointSize( 60 )
    oSymbol:SetColor( CLR_HBLUE )
    @ 180, 150 IMAGE oImg6 SIZE 100, 100 OF oWnd
    oImg6:SetImage( oSymbol:Handle() )

    @ 150, 350 SAY "Palette (R,G,B)" OF oWnd
    oSymbol := TSFSymbol():New( "person.3.sequence.fill" )
    oSymbol:SetPointSize( 50 )
    oSymbol:SetPalette( CLR_HRED, CLR_HGREEN, CLR_HBLUE )
    @ 180, 350 IMAGE oImg7 SIZE 250, 120 OF oWnd
    oImg7:SetImage( oSymbol:Handle() )

    @ 350, 20 SAY "Variable Battery (0.2)" OF oWnd
    oSymbol := TSFSymbol():New( "battery.100", 0.2 )
    oSymbol:SetPointSize( 60 )
    oSymbol:SetColor( CLR_RED )
    @ 380, 20 IMAGE oImg8 SIZE 120, 120 OF oWnd
    oImg8:SetImage( oSymbol:Handle() )
   
    @ 350, 200 SAY "Variable Wifi (0.5) Bold" OF oWnd
    oSymbol := TSFSymbol():New( "wifi", 0.5 )
    oSymbol:SetPointSize( 60 )
    oSymbol:SetWeight( NSFontWeightBold )
    @ 380, 200 IMAGE oImg9 SIZE 120, 120 OF oWnd
    oImg9:SetImage( oSymbol:Handle() )

    ACTIVATE WINDOW oWnd CENTERED
   
return nil
