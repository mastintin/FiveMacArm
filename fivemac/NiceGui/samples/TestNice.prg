#include "FiveMac.ch"

function Main()

  local oWnd, oWeb
  local cHtml, cPath
   
  // Get absolute path to the 'libs' folder
  cPath := "file://" + hb_DirBase() + "libs/"
   
  DEFINE WINDOW oWnd TITLE "Harbour NiceGUI (Vue + Quasar)" SIZE 1000, 700 FLIPPED
   
  @ 0, 0 WEBVIEW oWeb SIZE 1000, 700 OF oWnd
   
  // Bridge Handler
  oWeb:bOnMessage = { | cBody, cName, oSelf | HandleRequest( cBody, cName, oSelf ) }
   
  // Construimos el HTML apuntando a las librerías locales
  cHtml := GetNiceHtml()
   
  // Cargamos el HTML indicando la ruta base para que encuentre ./libs/...
  oWeb:SetHtml( cHtml, cPath )
   
  ACTIVATE WINDOW oWnd CENTERED

return nil

//----------------------------------------------------------------------------//

function HandleRequest( cBody, cName, oWeb )

  if cName == "fivemac"
    if cBody == "close"
      oWeb:oWnd:End()
    else
      MsgInfo( "Recibido desde Quasar: " + cBody )
    endif
  endif

return nil

//----------------------------------------------------------------------------//

function GetNiceHtml()

  local cHtml := ""
   
  #pragma __cstream | cHtml := %s
   <!DOCTYPE html>
   <html>
     <head>
       <!-- Local CSS from our libs folder -->
       <link href="quasar.prod.css" rel="stylesheet" type="text/css">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
     </head>
     <body>
       <div id="q-app">
         <q-layout view="hHh lpR fFf">
   
           <q-header elevated class="bg-primary text-white">
             <q-toolbar>
               <q-toolbar-title>
                 <q-avatar>
                   <img src="https://cdn.quasar.dev/logo-v2/svg/logo-mono-white.svg">
                 </q-avatar>
                 FiveMac + NiceGUI (Local)
               </q-toolbar-title>
             </q-toolbar>
           </q-header>
   
           <q-page-container>
             <q-page class="q-pa-md flex flex-center column">
               
               <div class="text-h4 q-mb-md">Hola desde Harbour + Vue 3</div>
               
               <q-card class="my-card q-pa-lg" style="width: 400px">
                 <q-card-section>
                   <div class="text-h6">Interacción Nativa</div>
                   <div class="text-subtitle2">Sin servidor web - Todo local</div>
                 </q-card-section>
                 
                 <q-separator></q-separator>
                 
                 <q-card-actions vertical>
                   <q-btn color="primary" label="Saludar a Harbour" icon="send" 
                          @click="sendToHarbour"></q-btn>
                   <q-btn flat color="secondary" label="Cerrar App" 
                          @click="closeApp"></q-btn>
                 </q-card-actions>
               </q-card>
               
             </q-page>
           </q-page-container>
   
         </q-layout>
       </div>
   
       <!-- Local JS from our libs folder -->
       <script src="vue.global.prod.js"></script>
       <script src="quasar.umd.prod.js"></script>
   
       <script>
         const { createApp, ref } = Vue
         const { useQuasar } = Quasar
   
         const app = createApp({
           setup () {
             return {
               sendToHarbour () {
                 if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.fivemac) {
                    window.webkit.messageHandlers.fivemac.postMessage('Click en Botón Quasar');
                 } else {
                    alert('No se detecta el puente FiveMac');
                 }
               },
               closeApp() {
                 if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.fivemac) {
                    window.webkit.messageHandlers.fivemac.postMessage('close');
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
   
return cHtml
