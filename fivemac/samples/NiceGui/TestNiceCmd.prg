#include "FiveMac.ch"
#include "Nice.ch"

#include "Nice.prg" 

function Main()

    local oWnd, oPanel, oPage, oCard, oRow, oInput
    local oBtn1, oBtn2, oDlg, oTbl, oMainCol

    DEFINE WINDOW oWnd TITLE "NiceGUI Commands Demo" SIZE 900, 600 FLIPPED

    // Native Panel
    oPanel := TPanel():New( 120, 30, 840, 450, oWnd )
   
    // --- Using Nice.ch Commands ---

    DEFINE NICE PAGE oPage OF oPanel
   
    // --- DIALOGO (Oculto al inicio) ---
    DEFINE NICE DIALOG oDlg OF oPage
         
    NICE SAY PROMPT "Por favor, identifícate:" CLASS "text-h6" OF oDlg
         
    // Changed to NICE GET
    NICE GET oInput PROMPT "Usuario" VALUE "Guest" OF oDlg
         
    NICE BUTTON PROMPT "Cerrar" OF oDlg ACTION oDlg:Hide()
      
      
    // --- CONTENIDO PRINCIPAL ---
    DEFINE NICE VSTACK oMainCol OF oPage
      
    // TITULO (NiceSay)
    NICE SAY PROMPT "Gestión de Usuarios (DBF)" CLASS "text-h4 text-primary" OF oMainCol
      
    // TABLA
    DEFINE NICE TABLE oTbl TITLE "Datos del Sistema" OF oMainCol
         
    // Anchos definidos
    NICE ADD COL TO oTbl NAME "id"    LABEL "RecNo"    FIELD "id"    WIDTH "80px"
    NICE ADD COL TO oTbl NAME "first" LABEL "First"    FIELD "first" WIDTH "200px"
    NICE ADD COL TO oTbl NAME "last"  LABEL "Last"     FIELD "last"  WIDTH "250px"
         
    // Datos cargados desde DBF
    NICE SET DATA OF oTbl TO GetData()

    // BOTONERA
    DEFINE NICE HSTACK oRow OF oMainCol
    NICE BUTTON PROMPT "Ver Dialogo" OF oRow ACTION oDlg:Show()
    NICE BUTTON PROMPT "Salir"       OF oRow ACTION oWnd:End()
   
    ACTIVATE NICE PAGE oPage
   
    // ------------------------------

    ACTIVATE WINDOW oWnd CENTERED

return nil

function GetData()
    local aRows := {}
    local cdbfPath:= Path()+"/" 
    local cDbf := cdbfPath + "test.dbf"
    msginfo( cDbf) 
    if File( cDbf )
        USE ( cDbf) SHARED NEW
        while !Eof()
        AAdd( aRows, { RecNo(), Field->First, Field->Last } )
        Skip
        end
        CLOSE
    else
        // Fallback si no encuentra la DBF
        AAdd( aRows, { 1, "No DBF", "Found" } )
    endif

return aRows
