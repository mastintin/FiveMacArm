#include "SwFive.ch"
 
 static oProg1, oProg2, oProg3, oProg4, oProg5
 
 //----------------------------------------------------------------------------//
 
 function Main()
    HSW_START_SWIFT( "mainApp" )
 return nil
 
 //----------------------------------------------------------------------------//
 
 function mainApp()
    local oWnd
 
    DEFINE WINDOW oWnd TITLE "SwiftFive - Premium Progress Indicators" SIZE 400, 500
 
    @ 30, 20 SAY "Standard Linear" OF oWnd
    @ 50, 20 PROGRESS oProg1 VALUE 25 OF oWnd SIZE 350, 50 ;
             PROMPT "Downloading files..." ;
             SUBTITLE "Processing batch 1 of 4" ;
             ICON "arrow.down.circle.fill"
 
    @ 120, 20 SAY "Custom Color & Icon" OF oWnd
    @ 140, 20 PROGRESS oProg2 VALUE 60 OF oWnd SIZE 350, 50 ;
             PROMPT "Upload Status" ;
             ICON "cloud.upload.fill" ;
             COLOR "#FF5733" ;
             SHOWVALUE
 
    @ 210, 20 SAY "Indeterminate Linear" OF oWnd
    @ 230, 20 PROGRESS oProg3 OF oWnd SIZE 350, 20 ;
             INDETERMINATE
 
    @ 270, 20 SAY "Circular (Gauge Style)" OF oWnd
    @ 300, 20 PROGRESS oProg4 VALUE 75 OF oWnd SIZE 60, 60 ;
             STYLE SW_PROGRESS_CIRCULAR ;
             COLOR "#28A745"
 
    @ 300, 120 PROGRESS oProg5 OF oWnd SIZE 60, 60 ;
             STYLE SW_PROGRESS_CIRCULAR ;
             INDETERMINATE
 
    @ 420, 20 BUTTON "Update Progress" OF oWnd SIZE 150, 30 ;
             ACTION UpdateProgress()
 
    ACTIVATE WINDOW oWnd CENTER
 
 return nil
 
 //----------------------------------------------------------------------------//
 
 function UpdateProgress()
    static nVal := 25
    
    nVal += 10
    if nVal > 100
       nVal := 0
    endif
    
    oProg1:nValue := nVal
    oProg2:nValue := nVal
    oProg4:nValue := nVal
    
    if nVal > 80
       oProg1:cSubtitle := "¡Casi terminado!"
       oProg1:cIcon := "checkmark.circle.fill"
       oProg1:cColor := "#28A745"
    elseif nVal > 50
       oProg1:cSubtitle := "Más de la mitad..."
       oProg1:cColor := "#FFCC00"
    else
       oProg1:cSubtitle := "Descargando... " + AllTrim(Str(nVal)) + "%"
       oProg1:cIcon := "arrow.down.circle.fill"
       oProg1:cColor := "#007AFF"
    endif
 
 return nil
 
 //----------------------------------------------------------------------------//
