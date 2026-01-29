#include "FiveMac.ch"
#include "Nice.ch"

function Main()

    local oWnd, oPanel, oPage, oCard, oRow, oInput
    local oBtn1, oBtn2, oMainCol
    local oSel, nSel := "Google", oDate, dDate := Date()
    local oProg, nProg := 0.2
    local oTbl
    local oDlg

    DEFINE WINDOW oWnd TITLE "NiceGUI Commands Demo" SIZE 1200, 800 FLIPPED

    // Native Panel
    oPanel := TPanel():New( 100, 30, 1140, 650, oWnd )
   
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
    
    // TITULO
    NICE SAY PROMPT "Gestión de Usuarios (DBF)" CLASS "text-h4 text-primary" OF oMainCol
    NICE BADGE PROMPT "3 Users" COLOR "orange" FLOATING OF oMainCol

    // --- TABS ---
    DEFINE NICE TABS oTabs VERTICAL OF oMainCol
    
    // TAB 1: DATOS
    DEFINE NICE TAB oTab1 TITLE "Datos" ICON "table_chart" OF oTabs
      
    // TABLA (Ahora hija de oTab1)
    DEFINE NICE TABLE oTbl TITLE "Datos del Sistema" OF oTab1
           
    // Anchos definidos
    NICE ADD COL TO oTbl NAME "id"    LABEL "RecNo"    FIELD "id"    WIDTH "80px"
    NICE ADD COL TO oTbl NAME "first" LABEL "First"    FIELD "first" WIDTH "200px"
    NICE ADD COL TO oTbl NAME "last"  LABEL "Last"     FIELD "last"  WIDTH "250px"
           
    // Datos cargados desde DBF
    NICE SET DATA OF oTbl TO GetData()

    // TAB 2: CONTROLES
    DEFINE NICE TAB oTab2 TITLE "Controles" ICON "settings" OF oTabs
      
    // EXPANSION ITEM
    DEFINE NICE EXPANSION oExp PROMPT "Opciones Avanzadas" ICON "tune" OF oTab2

    // BOTONERA (Ahora hija de oExp)
    DEFINE NICE HSTACK oRow OF oExp
      
    aItems := { "A", "B", "C" }
      
    // Test Combobox
    oSel := TNiceSelect():New( oRow, , "Elige Opción", "B", aItems )
      
    // Test Checkbox
    TNiceCheckbox():New( oRow, , "Activo", .T. )
      
    // Test Toggle
    TNiceToggle():New( oRow, , "Modo Oscuro", .F. )

    // Test Datepicker
    // NICE DATEPICKER PROMPT "Fecha Nac." VALUE dDate OF oRow
    TNiceDate():New( oRow, , "Fecha Nac.", dDate )
    
    // Chips
    NICE CHIP PROMPT "Admin" ICON "security" COLOR "teal" TEXT COLOR "white" OF oRow
    NICE CHIP PROMPT "Vip" ICON "star" COLOR "orange" OF oRow
    
    // Progress
    // NICE PROGRESS oProg VALUE nProg COLOR "purple" OF oRoW
    oProg := TNiceProgress():New( oRow, , nProg, "purple" )
    NICE BUTTON PROMPT "Inc Prog" OF oRow ACTION ( nProg += 0.1, oProg:Set( nProg ) )
    
    // Table
    oTbl := TNiceTable():New( oMainCol, "Usuarios" )
    oTbl:AddCol( "id", "ID", "id" )
    oTbl:AddCol( "name", "Nombre", "name", , .T. ) // Editable
    oTbl:AddCol( "age", "Edad", "age" )
    
    oTbl:SetData( { ;
        { "id" => 1, "name" => "Manuel", "age" => 30 }, ;
        { "id" => 2, "name" => "Juan", "age" => 25 } ;
        } )
    
    oTbl:bOnSave := { |o,id,col,val| MsgInfo("Updated Row " + Str(id) + ": " + val) }
      
    NICE BUTTON PROMPT "Ver Val"     OF oRow ACTION MsgInfo( oSel:cValue )
    NICE BUTTON PROMPT "Ver Dialogo" OF oRow ACTION oDlg:Show()
    NICE BUTTON PROMPT "Salir"       OF oRow ACTION oWnd:End()
    NICE BUTTON PROMPT "Dump HTML"   OF oRow ACTION MemoWrit( "debug_nice.html", oPage:GetHtml() )
   
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
