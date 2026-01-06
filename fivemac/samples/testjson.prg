#include "FiveMac.ch"
// REQUEST HB_CODEPAGE_UTF8
// REQUEST HB_LANG_ES

function Main()
   local oDlg, oGet1, oGet2, oBtnSave, oBtnLoad, hData
   local cName := PadR( "Fivedit", 20 )
   local nVersion := 1.2
   local cFile := hb_dirBase() + "data.json"
   local cLang := "ES"
   local cCodePage := "UTF8"

  // hb_langSelect( cLang )
  // hb_cdpSelect( cCodePage )

   DEFINE DIALOG oDlg TITLE "Harbour JSON Demo" SIZE 420, 200

   @ 140, 20 SAY "Nombre:" OF oDlg
   @ 140, 100 GET oGet1 VAR cName SIZE 200, 24 OF oDlg

   @ 100, 20 SAY "Versión:" OF oDlg
   @ 100, 100 GET oGet2 VAR nVersion SIZE 100, 24 OF oDlg

   @ 20, 50 BUTTON oBtnSave PROMPT "Grabar" OF oDlg ;
      ACTION SaveData( cName, nVersion, cFile )

   @ 20, 200 BUTTON oBtnLoad PROMPT "Recuperar" OF oDlg ;
      ACTION ( LoadData( @cName, @nVersion, cFile ), oGet1:Refresh(), oGet2:Refresh() )

   @ 20, 320 BUTTON "Salir" OF oDlg ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED
   return nil

function SaveData( cName, nVersion, cFile )
   local hData := { "name" => AllTrim( cName ), "version" => nVersion, "date" => Date(), "time" => Time() }
   local cJson := hb_jsonEncode( hData, .T. )
   
   if hb_memoWrit( cFile, cJson )
      MsgInfo( "Datos codificados y guardados en:" + CRLF + cFile + CRLF + CRLF + cJson, "JSON Guardado" )
   else
      MsgAlert( "Error al escribir el archivo." + CRLF + ;
                "Ruta: " + cFile + CRLF + ;
                "FError: " + AllTrim( Str( FError() ) ) )
   endif
return nil

function LoadData( cName, nVersion, cFile )
   local cJson, hData := {=>}
   
   if File( cFile )
      cJson := hb_memoRead( cFile )
      if hb_jsonDecode( cJson, @hData ) > 0
         if ValType( hData ) == "H"
            cName := PadR( hData[ "name" ], 20 )
            nVersion := hData[ "version" ]
            MsgInfo( "Datos recuperados correctamente" )
         endif
      else
         MsgAlert( "Error al decodificar JSON" )
      endif
   else
      MsgAlert( "Archivo 'data.json' no encontrado. Graba algo primero." )
   endif
return nil
