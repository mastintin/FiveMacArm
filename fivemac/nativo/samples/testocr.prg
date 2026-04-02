#include "FiveMac.ch"

function Main()

    local oWnd, oImg, oBtn1, oBtn2, oMemo
    local cText := ""
    local cFile := ""
   
    DEFINE WINDOW oWnd TITLE "Vision OCR Test"  NOFLIPPED ;
        FROM 50, 50 TO 600, 800
      
    @ 20, 20 IMAGE oImg SIZE 300, 400 OF oWnd
   
    @ 20, 340 GET oMemo VAR cText MULTILINE SIZE 440, 400 OF oWnd
   
    @ 440, 20 BUTTON oBtn1 PROMPT "Load Image..." OF oWnd ;
        ACTION ( cFile := cGetFile( "Select Image", "Image Files (*.png;*.jpg)|*.png;*.jpg;*.jpeg;*.tiff;*.bmp" ), ;
        If( ! Empty( cFile ), ( oImg:SetFile( cFile ), cText := "", oMemo:SetText( "" ) ), nil ) )

    @ 440, 160 BUTTON oBtn2 PROMPT "Recognize Text" OF oWnd ;
        ACTION ( cText := NSIMGTEXTOCR( oImg:GetImage() ), oMemo:SetText( cText ) )
   
    ACTIVATE WINDOW oWnd CENTERED
   
return nil
