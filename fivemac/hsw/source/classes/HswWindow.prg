#include "hbclass.ch"

// Comando para que el usuario se sienta como en casa
#xcommand DEFINE WINDOW <oWnd> ;
             [ TITLE <cTitle> ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
          => ;
          <oWnd> := HswWindow():New( <cTitle>, <nWidth>, <nHeight> )

#xcommand ACTIVATE WINDOW <oWnd> => <oWnd>:Activate()

CLASS HswWindow
   DATA cTitle
   DATA nWidth, nHeight
   DATA bOnActivate

   METHOD New( cTitle, nWidth, nHeight )
   METHOD Activate()
ENDCLASS

METHOD New( cTitle, nWidth, nHeight ) CLASS HswWindow
   ::cTitle  := cTitle
   ::nWidth  := nWidth
   ::nHeight := nHeight
   
   if ::cTitle == nil ; ::cTitle := "HSW Window" ; endif
   if ::nWidth == nil ; ::nWidth := 400 ; endif
   if ::nHeight == nil ; ::nHeight := 300 ; endif
return self

METHOD Activate() CLASS HswWindow
   Local cJson
   
   // Construimos el mensaje para Swift de forma segura
   cJson := '{ "cmd": "create_window", ' 
   cJson += '  "title": "' + hb_valToStr(::cTitle) + '", ' 
   cJson += '  "width": ' + hb_valToStr(::nWidth) + ', ' 
   cJson += '  "height": ' + hb_valToStr(::nHeight) + ' }'
   
   // Enviamos al otro hilo
   HSW_SEND_COMMAND( cJson )
   
return nil
