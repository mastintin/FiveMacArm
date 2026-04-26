#include "hbclass.ch"

// Comando para que el usuario se sienta como en casa
#xcommand DEFINE WINDOW <oWnd> ;
             [ TITLE <cTitle> ] ;
             [ SIZE <nWidth>, <nHeight> ] ;
          => ;
          <oWnd> := HswWindow():New( <cTitle>, <nWidth>, <nHeight> )

#xcommand ACTIVATE WINDOW <oWnd> => <oWnd>:Activate()

CLASS HswWindow
   DATA cId
   DATA hState INIT {=>}

   ACCESS cTitle        INLINE ::hState["title"]
   ASSIGN cTitle(c)     INLINE ( ::hState["title"] := c, ::Apply( { "title" => c } ) )

   ACCESS nWidth        INLINE ::hState["width"]
   ASSIGN nWidth(n)     INLINE ( ::hState["width"] := n, ::Apply( { "width" => n } ) )

   ACCESS nHeight       INLINE ::hState["height"]
   ASSIGN nHeight(n)    INLINE ( ::hState["height"] := n, ::Apply( { "height" => n } ) )

   METHOD New( cTitle, nWidth, nHeight )
   METHOD Activate()
   METHOD Apply( hProps )
ENDCLASS

METHOD New( cTitle, nWidth, nHeight ) CLASS HswWindow
   ::cId := hb_uuid()
   
   ::hState["title"]  := hb_defaultValue( cTitle, "HSW Window" )
   ::hState["width"]  := hb_defaultValue( nWidth, 400 )
   ::hState["height"] := hb_defaultValue( nHeight, 300 )
   
return self

METHOD Activate() CLASS HswWindow
   Local hCommand := {=>}
   
   hCommand["cmd"]    := "create_window"
   hCommand["id"]     := ::cId
   hCommand["title"]  := ::cTitle
   hCommand["width"]  := ::nWidth
   hCommand["height"] := ::nHeight
   
   HSW_SEND_COMMAND( hb_jsonEncode( hCommand ) )
return nil

METHOD Apply( hProps ) CLASS HswWindow
   Local hCommand := {=>}
   hCommand["cmd"]   := "apply"
   hCommand["id"]    := ::cId
   hCommand["props"] := hProps
   HSW_SEND_COMMAND( hb_jsonEncode( hCommand ) )
return nil
