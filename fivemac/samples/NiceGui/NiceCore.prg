#include "FiveMac.ch"

//----------------------------------------------------------------------------//
// Clases Base del Framework "FiveMac NiceGUI"
//----------------------------------------------------------------------------//

CLASS TNicePage

  DATA oWnd
  DATA oWeb
  DATA aControls    INIT {} // Top level controls for Rendering
  DATA aAllControls INIT {} // All controls for Event Lookup (Flattened)
  DATA oHeader
  DATA oFooter
  DATA oDrawer
  DATA cPath        INIT ""
   
  METHOD New( oWnd )
  METHOD Add( oControl )
  METHOD SetHeader( oHeader ) INLINE ::oHeader := oHeader
  METHOD SetFooter( oFooter ) INLINE ::oFooter := oFooter
  METHOD SetDrawer( oDrawer ) INLINE ::oDrawer := oDrawer
  METHOD Register( oControl )
  METHOD Activate()
  METHOD HandleEvent( cBody, cName )
  METHOD GetHtml()

ENDCLASS

METHOD New( oWnd ) CLASS TNicePage
  local cResPath := hb_DirBase() + "libs/"
   
  ::oWnd  := oWnd
   
  // Si existe nicegui_dist (carpeta completa con fuentes), la preferimos
  if hb_DirExists( hb_DirBase() + "nicegui_dist" )
  cResPath := hb_DirBase() + "nicegui_dist/"
  endif

  // Si estamos en un bundle .app, los recursos están en Contents/Resources/nicegui
  if File( hb_DirBase() + "../Resources/nicegui/vue.global.prod.js" )
  cResPath := hb_DirBase() + "../Resources/nicegui/"
  endif
   
  // Para que el WebView lo entienda bien como URL de archivo
  ::cPath := "file://" + cResPath
   
  @ 0, 0 WEBVIEW ::oWeb SIZE oWnd:nWidth, oWnd:nHeight - 30 OF oWnd
   
  // Redimensionar con la ventana
  ::oWeb:_nAutoResize( 18 ) // Width + Height
   
  ::oWeb:bOnMessage = { | cBody, cName | ::HandleEvent( cBody, cName ) }
return Self

METHOD Add( oControl ) CLASS TNicePage
  local cClass := oControl:ClassName()
  if ! ( cClass $ "TNICEHEADER,TNICEFOOTER,TNICEDRAWER" )
  AAdd( ::aControls, oControl )
  endif
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
  // Improvement: Join tokens starting from 3 if payload has colons
  if Len( aTokens ) > 3
  oCtrl:cValue := ""
  for each cToken in aTokens
  if cToken:__enumIndex() >= 3
  oCtrl:cValue += cToken + ":"
  endif
  next
  oCtrl:cValue := Left( oCtrl:cValue, Len(oCtrl:cValue)-1 ) 
  else
  oCtrl:cValue := aTokens[ 3 ]
  endif
  
  if __ObjHasMsg( oCtrl, "ONCHANGE" )
  oCtrl:OnChange( oCtrl:cValue )
  endif
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
  local cControls := ""
  local cScriptVars := ""
  local oCtrl
  local cHtml
   
  // Generate Controls HTML (Recursive)
  for each oCtrl in ::aControls
  cControls += oCtrl:GetHtml() + hb_eol()
  next

  // Generate Vue Reactive Variables
  for each oCtrl in ::aAllControls
  if !Empty( oCtrl:GetModelName() )
  // Ensure GetModelValue produces valid JS literal (quoted string, boolean, or array)
  cScriptVars += oCtrl:GetModelName() + ": ref(" + oCtrl:GetModelValue() + ")," + hb_eol()
  endif
  if !Empty( oCtrl:GetAuxName() )
  cScriptVars += oCtrl:GetAuxName() + ": ref(" + oCtrl:GetAuxValue() + ")," + hb_eol()
  endif
  next

  #pragma __cstream | cHtml := %s
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
        <link href="quasar.prod.css" rel="stylesheet" type="text/css">
        <link href="material-icons.css" rel="stylesheet" type="text/css">
        <script src="https://cdn.tailwindcss.com"></script>
        <style>
          body { font-family: 'Roboto', sans-serif; }
          .q-page { background: transparent !important; }
        </style>
      </head>
      <body>
        <div id="q-app">
          <q-layout view="hHh Lpr lFf">
            %HEADER%
            %DRAWER%
            <q-page-container>
              <q-page class="q-pa-md">
                <div class="q-gutter-md w-full">
                  %CONTROLS%
                </div>
              </q-page>
            </q-page-container>
            %FOOTER%
          </q-layout>
        </div>
    
        <script src="vue.global.prod.js"></script>
        <script src="quasar.umd.prod.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.1/dist/echarts.min.js"></script>
    
        <script>
          const { createApp, ref, onMounted } = Vue
          const { useQuasar } = Quasar
          
          window.charts = {};

          const app = createApp({
            setup () {
              const state = {
                drawerOpen: ref(true),
                %VARS%
              }
              
              window.toggleDrawer = () => { 
                state.drawerOpen.value = !state.drawerOpen.value; 
              };
              
              window.updateModel = ( id, val ) => {
                 if ( state[id] ) state[id].value = val;
              }
              
              window.updateModelFromString = ( str ) => {
                  let parts = str.split(':');
                  if (parts.length >= 2) {
                      let id = parts[0];
                      let val = parts.slice(1).join(':'); 
                      if (val === "true") val = true;
                      else if (val === "false") val = false;
                      else if (!isNaN(val)) val = parseFloat(val);
                      
                      if ( state[id] ) state[id].value = val;
                  }
              }

              return {
                ...state,
                sendEvent( id, event ) {
                  // alert('Event: ' + id + ' -> ' + event);
                  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.fivemac) {
                     window.webkit.messageHandlers.fivemac.postMessage( id + ':' + event );
                  }
                },
                handleClick( id, js ) {
                  if ( js ) {
                     // Evaluate JS code string if it looks like a function call
                     try { eval(js); } catch(e) { console.error(e); }
                  }
                  this.sendEvent( id, 'click' );
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
   
  // Render Header/Footer
  if ::oHeader != nil
  cHtml := StrTran( cHtml, "%HEADER%", ::oHeader:GetHtml() )
  else
  cHtml := StrTran( cHtml, "%HEADER%", "" )
  endif
  
  if ::oDrawer != nil
  cHtml := StrTran( cHtml, "%DRAWER%", ::oDrawer:GetHtml() )
  else
  cHtml := StrTran( cHtml, "%DRAWER%", "" )
  endif

  if ::oFooter != nil
  cHtml := StrTran( cHtml, "%FOOTER%", ::oFooter:GetHtml() )
  else
  cHtml := StrTran( cHtml, "%FOOTER%", "" )
  endif

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
  DATA cClass   INIT ""
  DATA cStyle   INIT ""
  DATA cJs      INIT ""
   
  METHOD New( oParent, cClass, cStyle, cJs )
  METHOD GetPage()
  METHOD GetHtml() VIRTUAL
  METHOD GetModelName()
  METHOD GetModelValue()
  METHOD GetAuxName()
  METHOD GetAuxValue()
  METHOD Set( uVal )
  METHOD SetClass( cClass ) INLINE ::cClass := cClass
  METHOD SetStyle( cStyle ) INLINE ::cStyle := cStyle
ENDCLASS

METHOD New( oParent, cClass, cStyle, cJs ) CLASS TNiceControl
  local oPage
  ::oParent := oParent
   
  if ::oParent == nil
  MsgStop( "Control has no parent! " + ::ClassName() )
  return nil
  endif

  oPage := ::GetPage()
  if oPage == nil
  MsgStop( "Control has no page! " + ::ClassName() )
  return nil
  endif

  ::cId := "ctrl_" + AllTrim( Str( Len( oPage:aAllControls ) + 1 ) )
   
  // Add to Parent Render List
  oParent:Add( Self ) 
   
  // Register in Page Flat List
  oPage:Register( Self )
  
  ::cClass := cClass
  ::cStyle := cStyle
  ::cJs    := cJs
  DEFAULT ::cClass := ""
  DEFAULT ::cStyle := ""
  DEFAULT ::cJs    := ""
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

METHOD GetAuxName() CLASS TNiceControl
return ""

METHOD GetAuxValue() CLASS TNiceControl
return "[]"

METHOD Set( uVal ) CLASS TNiceControl
  local oPage := ::GetPage()
  local cCode := ""
   
  if ValType( uVal ) == "N"
  if __ObjHasData( Self, "nValue" )
  ::nValue := uVal
  endif
  else
  if __ObjHasData( Self, "cValue" )
  ::cValue := uVal
  endif
  endif
   
  if oPage != nil .and. oPage:oWeb != nil
  if ValType( uVal ) == "C"
  cCode := ::GetModelName() + ":" + uVal
  elseif ValType( uVal ) == "N"
  cCode := ::GetModelName() + ":" + AllTrim(Str(uVal))
  elseif ValType( uVal ) == "L"
  cCode := ::GetModelName() + ":" + If( uVal, "true", "false" )
  endif
      
  if !Empty( cCode )
  oPage:oWeb:ScriptCallMethodArg( "updateModelFromString", cCode )
  endif
  endif
return nil
