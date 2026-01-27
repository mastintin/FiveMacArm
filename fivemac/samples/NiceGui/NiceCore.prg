#include "FiveMac.ch"

//----------------------------------------------------------------------------//
// Clases Base del Framework "FiveMac NiceGUI"
//----------------------------------------------------------------------------//

CLASS TNicePage

  DATA oWnd
  DATA oWeb
  DATA aControls    INIT {} // Top level controls for Rendering
  DATA aAllControls INIT {} // All controls for Event Lookup (Flattened)
  DATA cPath        INIT ""
   
  METHOD New( oWnd )
  METHOD Add( oControl )
  METHOD Register( oControl )
  METHOD Activate()
  METHOD HandleEvent( cBody, cName )
  METHOD GetHtml()

ENDCLASS

METHOD New( oWnd ) CLASS TNicePage
  local cResPath := hb_DirBase() + "libs/"
   
  ::oWnd  := oWnd
   
  // Si estamos en un bundle .app, los recursos están en Contents/Resources/nicegui
  if File( hb_DirBase() + "../Resources/nicegui/vue.global.prod.js" )
    cResPath := hb_DirBase() + "../Resources/nicegui/"
  endif
   
  // Para que el WebView lo entienda bien como URL de archivo
  ::cPath := "file://" + cResPath
   
  @ 0, 0 WEBVIEW ::oWeb SIZE oWnd:nWidth, oWnd:nHeight OF oWnd
   
  // Redimensionar con la ventana
  ::oWeb:_nAutoResize( 18 ) // Width + Height
   
  ::oWeb:bOnMessage = { | cBody, cName | ::HandleEvent( cBody, cName ) }
return Self

METHOD Add( oControl ) CLASS TNicePage
  AAdd( ::aControls, oControl ) // Only add to render list if direct child
return nil

METHOD Register( oControl ) CLASS TNicePage
  AAdd( ::aAllControls, oControl )
return nil

METHOD Activate() CLASS TNicePage
  local cHtml := ::GetHtml()
  ::oWeb:SetHtml( cHtml, ::cPath )
return nil

METHOD HandleEvent( cBody, cName ) CLASS TNicePage
  local aTokens, cId, oCtrl
   
  if cName == "fivemac"
    aTokens := hb_ATokens( cBody, ":" )
    if Len( aTokens ) >= 1
      cId := aTokens[ 1 ]
         
      // Find control by ID in flat list
      for each oCtrl in ::aAllControls
      if oCtrl:cId == cId
             
        // Check if it's a value update (id:change:NEWVALUE)
        if Len( aTokens ) > 2 .and. aTokens[ 2 ] == "change"
          if __ObjHasData( oCtrl, "CVALUE" )
            // Reassemble value if it contained colons? For now simple logic.
            // aTokens[3] is the value.
            oCtrl:cValue := aTokens[ 3 ]
          endif
        ENDIF
             
        // Check if it's a click event
        if Len( aTokens ) > 1 .and. aTokens[ 2 ] == "click"
          if oCtrl:bAction != nil
            Eval( oCtrl:bAction, oCtrl )
          endif
        endif
        exit
      endif
      next
    endif
  endif
return nil

METHOD GetHtml() CLASS TNicePage
  local cHtml := ""
  local cControls := ""
  local cScriptVars := ""
  local oCtrl
   
  // Generate Controls HTML (Recursive)
  for each oCtrl in ::aControls
  cControls += oCtrl:GetHtml() + CRLF
  next

  // Generate Vue Reactive Variables
  for each oCtrl in ::aAllControls
  if !Empty( oCtrl:GetModelName() )
    // Ensure GetModelValue produces valid JS literal (quoted string, boolean, or array)
    cScriptVars += oCtrl:GetModelName() + ': Vue.ref(' + oCtrl:GetModelValue() + '),' + CRLF
  endif
  next

  #pragma __cstream | cHtml := %s
   <!DOCTYPE html>
   <html>
     <head>
       <link href="https://fonts.googleapis.com/css?family=Material+Icons" rel="stylesheet">
       <link href="quasar.prod.css" rel="stylesheet" type="text/css">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
     </head>
     <body>
       <div id="q-app">
         <q-layout view="hHh lpR fFf">
           <q-page-container>
             <q-page class="q-pa-md flex flex-center column">
               <div class="q-gutter-md">
                 %CONTROLS%
               </div>
             </q-page>
           </q-page-container>
         </q-layout>
       </div>
   
       <script src="vue.global.prod.js"></script>
       <script src="quasar.umd.prod.js"></script>
   
       <script>
         const { createApp, ref } = Vue
         const { useQuasar } = Quasar
   
         const app = createApp({
           setup () {
             const state = {
               %VARS%
             }
             
             // Expose updater for Harbour
             window.updateModel = ( id, val ) => {
                if ( state[id] ) state[id].value = val;
             }
             
             return {
               ...state,
               sendEvent( id, event ) {
                 if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.fivemac) {
                    window.webkit.messageHandlers.fivemac.postMessage( id + ':' + event );
                 }
               },
               updateVal( id, val ) {
                 if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.fivemac) {
                    window.webkit.messageHandlers.fivemac.postMessage( id + ':change:' + val );
                 }
               }
             }
           }
         })
   
         app.use(Quasar)
         app.mount('#q-app')
       </script>
     </body>
   </html>
  #pragma __endtext
   
  cHtml := StrTran( cHtml, "%CONTROLS%", cControls )
  cHtml := StrTran( cHtml, "%VARS%", cScriptVars )
   
return cHtml

//----------------------------------------------------------------------------//
// Control Base
//----------------------------------------------------------------------------//

CLASS TNiceControl
  DATA cId
  DATA oParent
  DATA bAction
   
  METHOD New( oParent )
  METHOD GetPage()
  METHOD GetHtml() VIRTUAL
  METHOD GetModelName()
  METHOD GetModelValue()
ENDCLASS

METHOD New( oParent ) CLASS TNiceControl
  local oPage
  ::oParent := oParent
   
  oPage := ::GetPage()
  ::cId := "ctrl_" + AllTrim( Str( Len( oPage:aAllControls ) + 1 ) )
   
  // Add to Parent Render List
  oParent:Add( Self ) 
   
  // Register in Page Flat List
  oPage:Register( Self )
return Self

METHOD GetPage() CLASS TNiceControl
  local oObj := ::oParent
  while oObj != nil .and. oObj:ClassName() != "TNICEPAGE"
  if __ObjHasMsg( oObj, "OPARENT" )
    oObj := oObj:oParent
  else
    exit
  endif
  end
return oObj

METHOD GetModelName() CLASS TNiceControl
return ""

METHOD GetModelValue() CLASS TNiceControl
return '"' + ::cValue + '"' // Default logic for Inputs
