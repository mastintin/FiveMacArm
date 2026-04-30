#include "swfive.ch"

function Main()
   local oWnd, oVStack, oCard1, oCard2
   
   DEFINE WINDOW oWnd TITLE "Test de TSwCard - La Isla" SIZE 500, 600
   
   @ 0, 0 VSTACK oVStack OF oWnd
      oVStack:nSpacing := 20
      
      @ 0, 0 LABEL "Dashboard de Usuario" OF oVStack ;
         SIZE 0, 40 // Título principal
      
      // Tarjeta de Perfil
      @ 0, 0 CARD oCard1 TITLE "Información Personal" SYMBOL "person.text.rectangle" ;
         OF oVStack SIZE 400, 150
         
         @ 0, 0 LABEL "Nombre: Manuel Alvarez" OF oCard1
         @ 0, 0 LABEL "Email: manuel@ejemplo.com" OF oCard1
         @ 0, 0 BUTTON "Editar Perfil" OF oCard1 ;
            ACTION MsgInfo( "Abriendo editor..." )
      
      // Tarjeta de Estadísticas
      @ 0, 0 CARD oCard2 TITLE "Actividad Reciente" SYMBOL "chart.bar.fill" ;
         OF oVStack SIZE 400, 150
         
         @ 0, 0 PROGRESS nVal VAR 75 RANGE 0, 100 ;
            PROMPT "Tareas Completadas" OF oCard2
            
         @ 0, 0 HSTACK oHStack OF oCard2
            @ 0, 0 BUTTON "Ver Detalles" OF oHStack
            @ 0, 0 BUTTON "Descargar PDF" OF oHStack ;
               ACTION MsgInfo( "Generando informe..." )
      
      @ 0, 0 BUTTON "Cerrar Aplicación" OF oVStack ;
         ACTION oWnd:End()
         
   ACTIVATE WINDOW oWnd
   
return nil
