#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

   local oWnd, oMonaco
   local oBtnSet, oBtnGet

   DEFINE WINDOW oWnd TITLE "FiveMac: Monaco Editor Test" ;
      FROM 100, 100 TO 700, 900

   // Creamos el editor de VSCode (Monaco)
   oMonaco := TMonaco():New( 50, 20, 760, 530, oWnd )
   oMonaco:SetLanguage( "javascript" )
   oMonaco:SetTheme( "vs-dark" )
   
   // Callback de cambio (puedes ver si el usuario escribe)
   oMonaco:bOnChange := { || oWnd:SetTitle( "Monaco: Editando..." ) }

   @ 10, 20 BUTTON oBtnSet PROMPT "Poner Texto" OF oWnd ;
      ACTION oMonaco:SetText( "function HolaFiveMac() { \n   alert('Monaco rulez!'); \n}" )

   @ 10, 150 BUTTON oBtnGet PROMPT "Leer Texto" OF oWnd ;
      ACTION ( cText := oMonaco:GetText(), MsgInfo( "Texto de Monaco recibido en Harbour" ) )

   @ 10, 300 BUTTON oBtnLang PROMPT "Idioma: C++" OF oWnd ;
      ACTION oMonaco:SetLanguage( "cpp" )

   ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//
