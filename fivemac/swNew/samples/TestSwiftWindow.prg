#include "FiveMac.ch"

function Main()

   local oWnd, oBtn, oChat, oLabel, oToggle
   
   // 1. Creamos la Ventana Primaria Nativa SwiftUI
   oWnd := TSwWindow():NewByTitle( "FiveMac SwiftUI PoC Island", 800, 600 )

   // 2. Añadimos un Label (Etiqueta básica)
   oLabel := SwLabel():New( 20, 20, 300, 30, "FiveMac Native SwiftUI Island", oWnd )

   // 3. Añadimos un Toggle (Interruptor reactivo)
   oToggle := SwToggle():New( 60, 20, 200, 30, "Activar Notificaciones", oWnd, ;
                               {|lOn| MsgInfo( "Toggle cambiado a: " + cValToChar( lOn ) ) }, , .t. )

   // 4. Añadimos un Botón con acción Harbour
   oBtn := SwButton():New( 100, 20, 120, 40, "Saludar", oWnd, ;
                             {|| MsgInfo( "¡Hola desde la Isla SwiftUI!" ) } )

   // 5. El componente de IA (Último control, como accesorio avanzado)
   oChat := SwAIChat():New( 160, 20, 760, 400, oWnd, ;
                               "TU_GROQ_API_KEY_AQUI", ;
                               "llama-3.3-70b-versatile", ;
                               "https://api.groq.com/openai/v1/chat/completions", ;
                               "Eres un genio de Harbour y SwiftUI." )

   oWnd:Activate()

return nil
