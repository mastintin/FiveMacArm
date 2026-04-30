#include "FiveMac.ch"


//----------------------------------------------------------------------------//

function Main()

   local oWnd, oMonaco, oSayPos, oSayFile, oSld, nLine, nRes, oTbr
   local cFile := "Nuevo.prg"

   // Definimos la ventana (Estamos en FLIPPED: 0,0 es TOP-LEFT)
   DEFINE WINDOW oWnd TITLE "Monaco Professional Editor" ;
      FROM 50, 50 TO 750, 1150

   // --- Barra de Herramientas NATIVA con SF Symbols ---
   DEFINE TOOLBAR oTbr OF oWnd
   
   DEFINE BUTTON OF oTbr PROMPT "Abrir" ;
      ACTION ( cFile := ChooseFile(), ;
               if( !Empty( cFile ), ;
                   ( oMonaco:SetText( hb_memoRead( cFile ), cFile ), ;
                     oSayFile:SetText( "File: " + cFile ) ), ) ) ;
      TOOLTIP "Abrir archivo" ;
      IMAGE "folder"

   DEFINE BUTTON OF oTbr PROMPT "Grabar" ;
      ACTION ( oMonaco:SaveAs(), oSayFile:SetText( "File: " + oMonaco:cFileName ) ) ;
      TOOLTIP "Grabar como..." ;
      IMAGE "square.and.arrow.down"

   DEFINE BUTTON OF oTbr PROMPT "Símbolos" ;
      ACTION oMonaco:GetFunctions() ;
      TOOLTIP "Extraer funciones" ;
      IMAGE "list.bullet.indent"

   DEFINE BUTTON OF oTbr PROMPT "Temas" ;
      ACTION oMonaco:ChooseTheme() ;
      TOOLTIP "Cambiar tema" ;
      IMAGE "paintbrush"

   DEFINE BUTTON OF oTbr PROMPT "Buscar" ;
      ACTION oMonaco:Find() ;
      TOOLTIP "Buscar y reemplazar" ;
      IMAGE "magnifyingglass"

   DEFINE BUTTON OF oTbr PROMPT "Ir a..." ;
      ACTION ( nLine := 1, ;
               if( MsgGet( "Saltar a línea", "Número:", @nLine ), ;
                   oMonaco:GoToLine( nLine ), ) ) ;
      TOOLTIP "Saltar a línea" ;
      IMAGE "arrow.right.to.line"

   DEFINE BUTTON OF oTbr PROMPT "Salir" ;
      ACTION oWnd:End() ;
      TOOLTIP "Cerrar aplicación" ;
      IMAGE "xmark.circle"

   DEFINE BUTTON OF oTbr PROMPT "Chat IA" ;
      ACTION AICREATECHAT() ;
      TOOLTIP "Hablar con la IA" ;
      IMAGE "bubble.left.and.bubble.right"

   // --- El Editor (Cuerpo) ---
   oMonaco := TMonaco():New( 5, 5, 1080, 595, oWnd )
   
   // --- Barra Inferior (Estado + Slider) ---
   @ 615, 10  SAY oSayFile PROMPT "File: " + cFile SIZE 500, 20 OF oWnd
   
   @ 617, 730 SAY "Zoom:" SIZE 50, 20 OF oWnd
   @ 615, 780 SLIDER oSld VALUE 100 SIZE 150, 20 OF oWnd ;
      ON CHANGE oMonaco:SetZoom( oSld:GetValue() / 100 )
   
   SliderMinMaxValue( oSld:hWnd, 50, 300 ) 
   oSld:SetValue( 100 )

   @ 615, 960 SAY oSayPos PROMPT "Ln 1, Col 1" SIZE 120, 20 OF oWnd
   
   // Actualizamos la barra de estado cuando el usuario se mueve
   oMonaco:bOnChange := { || oSayPos:SetText( "Ln " + AllTrim(Str(oMonaco:nLine)) + ", Col " + AllTrim(Str(oMonaco:nCol)) ), ;
                             if( oMonaco:lModified, oWnd:SetTitle( "Monaco: " + cFile + " (Modificado)" ), oWnd:SetTitle( "Monaco: " + cFile ) ) }

   // Callback de Símbolos
   oMonaco:bOnGetFunctions := { |aList, oM| ViewFunctions( aList, oM ) }

   ACTIVATE WINDOW oWnd CENTERED ;
      VALID ! oMonaco:lModified .or. ;
            ( nRes := Alert( "¿Deseas grabar los cambios antes de salir?", { "Si", "No", "Cancelar" } ), ;
              if( nRes == 1, ( oMonaco:lClosing := .T., oMonaco:Save(), .f. ), ; 
              if( nRes == 2, .T., .F. ) ) )

return nil

//----------------------------------------------------------------------------//

function ViewFunctions( aList, oMonaco )
   
   local aNames := {}, x, nAt
   
   if Empty( aList )
      MsgInfo( "No hay funciones detectadas" )
      return nil
   endif

   // ORDEN ALFABETICO PARA QUE SEA FÁCIL BUSCAR
   ASort( aList,,, { |x, y| Upper( x["name"] ) < Upper( y["name"] ) } )

   // Preparamos los nombres para mostrar en la lista
   for each x in aList 
      AAdd( aNames, AllTrim(x["name"]) + "  (Ln: " + AllTrim(Str(x["line"])) + ")" )
   next

   // ¡LA MAGIA EN UNA SOLA LINEA! 
   nAt := MsgSelectList( "Symbol Navigator", aNames, 500, 400 )

   if nAt > 0
      oMonaco:GoToLine( aList[ nAt ]["line"] )
   endif
   
return nil
