#include "swfive.ch"

// ---------------------------------------------------------
// El punto de entrada REAL (Thread 0)
// ---------------------------------------------------------
function Main()
   // Iniciamos Swift y le decimos que ejecute "AppMain" en un hilo de Harbour
   HSW_START_SWIFT( "AppMain" )
return nil

// ---------------------------------------------------------
// La lógica de tu aplicación (Ahora corre en Thread 1)
// ---------------------------------------------------------
function AppMain()
   local oWnd, oBtn, oChat
   local cApiKey := "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"
   
   oWnd := TSwWindow():New( "FiveMac SwiftUI - AI Chat Island", 800, 600 )
   
    oBtn := TSwButton():New( 20, 20, 150, 40, "Limpiar Chat", oWnd, ;
       { || oChat:Clear(), MsgInfo( "El chat ha sido vaciado localmente." ) } )
      
   // Creamos el Chat ocupando menos ancho
   oChat := TSwAIChat():New( 80, 20, 500, 480, oWnd, ;
                             cApiKey, ;
                             "llama-3.3-70b-versatile" )

   ACTIVATE WINDOW oWnd
   
return nil
