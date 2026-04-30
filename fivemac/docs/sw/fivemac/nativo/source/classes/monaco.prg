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
   DATA cAIKey          INIT ""

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
   METHOD AskAI( cSelectedText )
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
   local cEvent   := ""
   local cPayload := ""
   local aAI

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

      if cEvent == "onAIRequest"
         hb_jsonDecode( cPayload, @aAI )
         if ValType( aAI ) == "H"
            ::AskAI( aAI[ "selection" ], aAI[ "fullCode" ] )
         else
            ::AskAI( cPayload )
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

METHOD AskAI( cSelectedText, cFullCode ) CLASS TMonaco

   local cKey := ::cAIKey
   local cUrl, cJson, cResponse, oNet, aResp
   local cInstruction := ""
   local cContext := ""

   if Empty( cFullCode )
      cFullCode := ""
   endif

   if !Empty( cFullCode )
      cContext := "--- FULL FILE CONTENT ---" + hb_eol() + cFullCode + hb_eol()
   endif

   if !Empty( cSelectedText )
      cContext += "--- SELECTED PART TO MODIFY ---" + hb_eol() + cSelectedText + hb_eol()
   endif

   if Empty( cKey )
      cKey := GetPlistValue( ResPath( "monaco/monaco.plist" ), "AIKey" )
   endif

   cKey := AllTrim( cKey )
   cKey := StrTran( cKey, hb_eol(), "" )
   cKey := StrTran( cKey, Chr(13), "" )
   cKey := StrTran( cKey, Chr(10), "" )

   if Empty( cKey )
      MsgStop( "AI Key not set. Please assign oMonaco:cAIKey or set it in monaco.plist" )
      return nil
   endif

   cInstruction := MsgGetMultiline( "Instrucciones para la IA:", "Escriba aquí lo que desea que haga Gemma con el código seleccionado..." )
   
   if Empty( cInstruction )
      return nil
   endif

    // Groq API URL (Ultra-fast inference)
   cUrl := "https://api.groq.com/openai/v1/chat/completions"

   cJson := '{' + ;
            '"model": "llama-3.3-70b-versatile",' + ;
            '"messages": [' + ;
               '{"role": "system", "content": "You are the FiveMac Framework Expert. You ONLY write Harbour code using the official FiveMac.ch syntax. \n' + ;
               'OFFICIAL SYNTAX RULES: \n' + ;
               '- Window: DEFINE WINDOW <o> TITLE <t> FROM <r>,<c> TO <r>,<c> [SIZE <w>,<h>] [FLIPPED] \n' + ;
               '- Button: @ <r>, <c> BUTTON [ <o> PROMPT ] <p> OF <w> ACTION <a> [SIZE <w>,<h>] \n' + ;
               '- Get/Input: @ <r>, <c> GET [ <o> VAR ] <v> OF <w> [SIZE <w>,<h>] \n' + ;
               '- Checkbox: @ <r>, <c> CHECKBOX [ <o> VAR ] <l> PROMPT <p> OF <w> \n' + ;
               '- Say: @ <r>, <c> SAY [ <o> PROMPT ] <t> OF <w> \n' + ;
               '- Activation: ACTIVATE WINDOW <o> [CENTERED] [VALID <v>] \n' + ;
               '- ToolBar: DEFINE TOOLBAR <o> OF <w> / DEFINE BUTTON OF <t> PROMPT <p> ACTION <a> IMAGE <i> \n' + ;
               'ALWAYS return PURE Harbour code block. No explanations, no markdown. No C/ObjC."},' + ;
               '{"role": "user", "content": ' + hb_jsonEncode( "User Instruction: " + cInstruction + hb_eol() + "Current Code State:" + hb_eol() + cContext ) + '}' + ;
            '],' + ;
            '"temperature": 0}'

   MsgRun( "Groq is thinking...", { || ;
      oNet := TNetwork():New(), ;
      oNet:SetHeader( "Content-Type", "application/json" ), ;
      oNet:SetHeader( "Authorization", "Bearer " + cKey ), ;
      cResponse := oNet:Post( cUrl, cJson, 10 ) ;
   } )

   if Empty( cResponse )
      MsgStop( "No response from Groq. Check your internet or API Key." )
      return nil
   endif

   hb_jsonDecode( cResponse, @aResp )

   if ValType( aResp ) == "H" .and. hb_HHasKey( aResp, "choices" ) .and. ;
      Len( aResp[ "choices" ] ) > 0 .and. ;
      hb_HHasKey( aResp[ "choices" ][ 1 ], "message" )
      
      cResponse := aResp[ "choices" ][ 1 ][ "message" ][ "content" ]
      
      // Limpiamos posible markdown si Groq se pone creativo
      if Left( cResponse, 3 ) == "```"
         cResponse := SubStr( cResponse, At( hb_eol(), cResponse ) + Len( hb_eol() ) )
         if Right( cResponse, 3 ) == "```"
            cResponse := Left( cResponse, Len( cResponse ) - 3 )
         endif
      endif

      ::ScriptCallMethodArg( "insertAIResponseB64", hb_base64Encode( cResponse ) )
   else
      MsgStop( hb_jsonEncode( aResp, .t. ), "Groq Error" )
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

   local cHtml := "", cJsExt := ""
   local lAIActive := .f.
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
   cHtml += " require(['vs/editor/editor.main'], function(monaco) {" + hb_eol()
   cHtml += cJsExt + hb_eol()
   cHtml += " if(typeof registerHarbour === 'function') registerHarbour(monaco);" + hb_eol()
   cHtml += "  editor = monaco.editor.create(document.getElementById('container'), {" + hb_eol()
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
   lAIActive := !Empty( ::cAIKey ) .or. File( ResPath( "monaco/monaco.plist" ) )
   cHtml += "  if(typeof setupEditorIA === 'function') setupEditorIA(editor, " + iif(lAIActive, "true", "false") + ", monaco);" + hb_eol()
   cHtml += " });" + hb_eol()
   cHtml += " function setTextB64(b64) { "
   cHtml += "    try { "
   cHtml += "       if (editor) { "
   cHtml += "          const binString = atob(b64); "
   cHtml += "          const bytes = Uint8Array.from(binString, (m) => m.codePointAt(0)); "
   cHtml += "          editor.setValue(new TextDecoder().decode(bytes)); "
   cHtml += "       } "
   cHtml += "    } catch(e) { alert('Error decoding B64: ' + e.message); } "
   cHtml += " } "
   cHtml += " function insertAIResponseB64(b64) { "
   cHtml += "    try { "
   cHtml += "       if (editor) { "
   cHtml += "          const binString = atob(b64); "
   cHtml += "          const bytes = Uint8Array.from(binString, (m) => m.codePointAt(0)); "
   cHtml += "          const text = new TextDecoder().decode(bytes); "
   cHtml += "          const selection = editor.getSelection(); "
   cHtml += "          const op = { range: selection, text: text, forceMoveMarkers: true }; "
   cHtml += "          editor.executeEdits('ai-generation', [op]); "
   cHtml += "          editor.focus();"
   cHtml += "       } "
   cHtml += "    } catch(e) { alert('Error inserting AI B64: ' + e.message); } "
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
