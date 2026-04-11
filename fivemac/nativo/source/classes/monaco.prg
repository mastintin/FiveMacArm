#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TMonaco FROM TWebView

   DATA cLanguage      INIT "harbour"
   DATA cTheme         INIT "vs-dark"
   DATA cExtensionFile INIT "harbour.js" 
   DATA bOnChange
   DATA bOnGetText      // Bloque que se ejecuta al recibir el texto de Monaco
   DATA bOnGetFunctions // Bloque que se ejecuta al recibir la lista de funciones
   DATA cFileName       // Almacena el nombre del archivo para el guardado
   DATA lModified       INIT .F.  // Indica si hay cambios sin guardar
   DATA lClosing        INIT .F.  // Indica si debemos cerrar al terminar de grabar
   DATA nLine           INIT 1
   DATA nCol            INIT 1

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd )
     
   METHOD SetText( cText, cFileName )
   METHOD GetText()            INLINE ::ScriptCallMethod( "getText()" )
   METHOD GetFunctions()       INLINE ( ::ScriptCallMethod( "getFunctions()" ) )
   METHOD Save( cFileName )    
   METHOD SaveAs()
   METHOD SetLanguage( cLang ) INLINE ( ::cLanguage := cLang, ::ScriptCallMethodArg( "setLanguage", cLang ) )
   METHOD SetTheme( cTheme )   INLINE ( ::cTheme := cTheme, ::ScriptCallMethodArg( "setTheme", cTheme ) )
   METHOD SetZoom( nFactor )   INLINE ::ScriptCallMethodArg( "setFontSize", AllTrim(Str( 14 * nFactor )) )
   METHOD SetLightTheme()      INLINE ::SetTheme( "vs" )
   METHOD ChooseTheme()

   // Navegación y Edición
   METHOD GoToLine( nLine ) INLINE ::ScriptCallMethod( "editor.revealLineInCenter(" + AllTrim( Str( nLine ) ) + ");" + ;
                                                    "editor.setPosition({lineNumber: " + AllTrim( Str( nLine ) ) + ", column: 1});" + ;
                                                    "editor.focus();" )
   METHOD Find()               INLINE ::ScriptCallMethod( "editor.getAction('actions.find').run()" )
   METHOD SetReadOnly( lOn )   INLINE ::ScriptCallMethod( "editor.updateOptions({ readOnly: " + Lower(CValToChar(lOn)) + " })" )
   METHOD SetFocus()           INLINE ::ScriptCallMethod( "editor.focus()" )

   // Sobrescribimos Undo/Redo porque Monaco tiene su propia gestion interna
   METHOD Undo()               INLINE ::ScriptCallMethod( "undo()" )
   METHOD Redo()               INLINE ::ScriptCallMethod( "redo()" )

   METHOD GetHtml()
   METHOD HandleEvent( cBody, cName )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd ) CLASS TMonaco

   ::super:New( nTop, nLeft, nWidth, nHeight, oWnd )
   ::SetHtml( ::GetHtml() )

   // ESTILO NICEGUI: Redirigir el mensaje nativo a nuestro gestor de eventos
   ::bOnMessage := { | cBody, cName | ::HandleEvent( cBody, cName ) }

return Self

//----------------------------------------------------------------------------//

METHOD SetText( cText, cFileName ) CLASS TMonaco

   if !Empty( cFileName )
      ::cFileName := cFileName
   endif
   if cText != nil
      ::ScriptCallMethodArg( "setTextB64", hb_base64Encode( cText ) )
   endif
   ::lModified := .F.

return nil

//----------------------------------------------------------------------------//

METHOD Save( cFileName ) CLASS TMonaco

   if !Empty( cFileName )
      ::cFileName := cFileName
   endif
   
   if Empty( ::cFileName )
      ::cFileName := SaveFile( "Save As...", "Untitled.prg" )
   endif

   if !Empty( ::cFileName )
      // MsgWait( "Solicitando texto a Monaco...", "Guardando" )
      ::GetText() // Esto disparara OnMessage con 'onValues'
   endif

return nil

//----------------------------------------------------------------------------//

METHOD SaveAs() CLASS TMonaco

   local cNewFile := SaveFile( "Save As...", ::cFileName )
   
   if !Empty( cNewFile )
      MsgInfo( "Ruta elegida: " + cNewFile )
      ::Save( cNewFile )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD HandleEvent( cBody, cName ) CLASS TMonaco

   local nPos
   local cEvent  := ""
   local cPayload := ""

   if cName == "fivemac" 
      nPos := hb_At( ":", cBody )
      if nPos > 0
         cEvent   := Left( cBody, nPos - 1 )
         cPayload := SubStr( cBody, nPos + 1 )
      else
         cEvent := cBody
      endif

      if cEvent == "onChange"
         ::lModified := .T.
         if ::bOnChange != nil
            Eval( ::bOnChange, cPayload, Self )
         endif
      endif

      if cEvent == "onValues"
         if !Empty( ::cFileName )
            if hb_MemoWrit( ::cFileName, cPayload )
               ::lModified := .F.
               if ::lClosing
                  ::oWnd:End()
               else
                  MsgInfo( "OK! Archivo guardado: " + hb_FNameName( ::cFileName ) )
               endif
            else
               MsgStop( "ERROR GRABANDO: " + ::cFileName )
            endif
         endif
         if ::bOnGetText != nil
            Eval( ::bOnGetText, cPayload, Self )
         endif
      endif

      if cEvent == "onFunctions"
         if ::bOnGetFunctions != nil
            // Para la lista de funciones decodificamos el JSON
            //MsgInfo( "DEBUG HARBOUR: Recibido JSON: " + cPayload )
            hb_jsonDecode( cPayload, @cPayload )
            Eval( ::bOnGetFunctions, cPayload, Self )
         endif
      endif

      if cEvent == "onCursor"
         // Para el cursor sí troceamos el payload que es pequeño: "line:col"
         nPos := hb_At( ":", cPayload )
         ::nLine := Val( Left( cPayload, nPos - 1 ) )
         ::nCol  := Val( SubStr( cPayload, nPos + 1 ) )
         if ::bOnChange != nil // Reutilizamos o podrías crear bOnCursor
            Eval( ::bOnChange, cPayload, Self )
         endif
      endif
   endif

return nil

//----------------------------------------------------------------------------//

METHOD ChooseTheme() CLASS TMonaco

   local aThemes := { "vs-dark", "vs", "hc-black" }
   local aLabels := { "Dark", "Light", "High Contrast" }
   local nSel := MSGSELECTLIST( "Select Monaco Editor Theme", aLabels )

   if nSel > 0
      ::SetTheme( aThemes[ nSel ] )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD GetHtml() CLASS TMonaco

   local cHtml := ""
   local cJsExt := ""
   local cPath := ""

   // 1. Localizar el archivo de extensión
   cPath := ResPath( "monaco/" + ::cExtensionFile )

   if !File( cPath ) .and. !Empty( ResPath() )
      cPath := ResPath( ::cExtensionFile )
   endif

   if !File( cPath )
      cPath := "resources/monaco/" + ::cExtensionFile
      if !File( cPath )
         cPath := "../resources/monaco/" + ::cExtensionFile
      endif
   endif

   if File( cPath )
      cJsExt := hb_MemoRead( cPath )
   else
      cJsExt := "function registerHarbour(m) { console.log('Harbour fallback'); }"
   endif

   // 2. Construir el HTML
   cHtml += "<!DOCTYPE html><html><head>"
   cHtml += "<meta http-equiv='Content-Type' content='text/html;charset=utf-8' >"
   cHtml += "<style>html, body, #container { width: 100%; height: 100%; margin: 0; padding: 0; overflow: hidden; }</style>"
   cHtml += "</head><body><div id='container'></div>"
   cHtml += "<script src='https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs/loader.min.js'></script>"
   cHtml += "<script>"
   cHtml += " require.config({ paths: { 'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.44.0/min/vs' }});"
   cHtml += " let editor;"
   cHtml += " require(['vs/editor/editor.main'], function() {"
   cHtml += cJsExt 
   cHtml += " if(typeof registerHarbour === 'function') registerHarbour(monaco);"
   cHtml += "  editor = monaco.editor.create(document.getElementById('container'), {"
   cHtml += "   value: '', language: '" + ::cLanguage + "', theme: '" + ::cTheme + "',"
   cHtml += "   automaticLayout: true, tabSize: 3, insertSpaces: true,"
   cHtml += "   matchBrackets: 'always',"
   cHtml += "   bracketPairColorization: { enabled: true }"
   cHtml += "  });"
   cHtml += "  editor.focus();"
   cHtml += "  editor.onDidChangeModelContent(() => { window.webkit.messageHandlers.fivemac.postMessage( 'onChange:' ); });"
   cHtml += "  editor.onDidChangeCursorPosition((e) => { "
   cHtml += "     window.webkit.messageHandlers.fivemac.postMessage( 'onCursor:' + e.position.lineNumber + ':' + e.position.column ); "
   cHtml += "  });"
   cHtml += " });"
   cHtml += " function setTextB64(b64) { "
   cHtml += "    try { "
   cHtml += "       if (editor) { "
   cHtml += "          const binString = atob(b64); "
   cHtml += "          const bytes = Uint8Array.from(binString, (m) => m.codePointAt(0)); "
   cHtml += "          editor.setValue(new TextDecoder().decode(bytes)); "
   cHtml += "       } "
   cHtml += "    } catch(e) { alert('Error decoding B64: ' + e.message); } "
   cHtml += " } "
   cHtml += " function getText() { if (editor) window.webkit.messageHandlers.fivemac.postMessage( 'onValues:' + editor.getValue() ); }"
   cHtml += " function setLanguage(l) { if (editor) monaco.editor.setModelLanguage(editor.getModel(), l); }"
   cHtml += " function setTheme(t) { if (editor) monaco.editor.setTheme(t); }"
   cHtml += " function setFontSize(size) { if (editor) editor.updateOptions({ fontSize: parseInt(size) }); }"
   cHtml += " function undo() { if (editor) editor.trigger('keyboard', 'undo'); }"
   cHtml += " function redo() { if (editor) editor.trigger('keyboard', 'redo'); }"
   cHtml += " function cut() { if (editor) document.execCommand('cut'); }"
   cHtml += " function copy() { if (editor) document.execCommand('copy'); }"
   cHtml += " function paste() { if (editor) document.execCommand('paste'); }"
   cHtml += " function selectAll() { if (editor) editor.setSelection(editor.getModel().getFullModelRange()); }"
   cHtml += " function getFunctions() { "
   cHtml += "    if (!editor) return; "
   cHtml += "    const text = editor.getValue(); "
   cHtml += "    const regex = /(?:function|procedure|method|class) +([a-zA-Z0-9_]+)/gi; "
   cHtml += "    const matches = [...text.matchAll(regex)]; "
   cHtml += "    const symbols = matches.map(m => ({ "
   cHtml += "       name: m[1], "
   cHtml += "       type: 'SYMB', "
   cHtml += "       line: editor.getModel().getPositionAt(m.index).lineNumber "
   cHtml += "    })); "
   cHtml += "    window.webkit.messageHandlers.fivemac.postMessage( 'onFunctions:' + JSON.stringify(symbols) ); "
   cHtml += " } "
   cHtml += " window.addEventListener('keydown', function(e) { "
   cHtml += "    if (e.metaKey) { "
   cHtml += "       switch(e.key.toLowerCase()) { "
   cHtml += "          case 'z': if (e.shiftKey) redo(); else undo(); e.preventDefault(); break; "
   cHtml += "          case 'y': redo(); e.preventDefault(); break; "
   cHtml += "          case 'c': copy(); break; "
   cHtml += "          case 'v': paste(); break; "
   cHtml += "          case 'x': cut(); break; "
   cHtml += "          case 'a': selectAll(); e.preventDefault(); break; "
   cHtml += "       } "
   cHtml += "    } "
   cHtml += " }); "
   cHtml += "</script></body></html>"

return cHtml
