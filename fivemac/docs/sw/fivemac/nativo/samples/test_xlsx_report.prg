#include "FiveMac.ch"

//----------------------------------------------------------------------------//

function Main()

    local oWk, oSh, oFormat, oHeader
    local cFile := path()+"/report_ventas.xlsx"

    // 1. Crear el libro (usando comando de xlsxCmd.ch)
    CREATE XLS oWk FILE cFile
   
    if empty( oWk )
    MsgInfo( "Error al crear el archivo" )
    return nil
    endif

    // 2. Definir formatos
    DEFINE XLS FORMAT oHeader BOOK oWk
    SET XLS FORMAT oHeader BOLD .T.
    format_set_font_size( oHeader, 12 )
    format_set_bg_color( oHeader, 0xCECECE ) // Gris claro
    format_set_border( oHeader, 1 )

    DEFINE XLS FORMAT oFormat BOOK oWk
    format_set_num_format( oFormat, "#,##0.00 $" )

    // 3. Crear hoja y configurar columnas
    ADD SHEET oSh NAME "Reporte de Ventas" BOOK oWk
    SET XLS COLUMN "A" WIDTH 25 SHEET oSh
    SET XLS COLUMN "B" WIDTH 15 SHEET oSh
    SET XLS COLUMN "C" WIDTH 15 SHEET oSh
    SET XLS COLUMN "D" WIDTH 15 SHEET oSh

    // 4. Cabeceras
    @ 0, 0 XLS WRITE "PRODUCTO" FORMAT oHeader SHEET oSh
    @ 0, 1 XLS WRITE "CANTIDAD" FORMAT oHeader SHEET oSh
    @ 0, 2 XLS WRITE "PRECIO"   FORMAT oHeader SHEET oSh
    @ 0, 3 XLS WRITE "TOTAL"    FORMAT oHeader SHEET oSh

    // 5. Datos
    @ 1, 0 XLS WRITE "MacBook Pro M3" SHEET oSh
    @ 1, 1 XLS WRITE 2 SHEET oSh
    @ 1, 2 XLS WRITE 2500.00 FORMAT oFormat SHEET oSh
    @ 1, 3 XLS FORMULA "=B2*C2" FORMAT oFormat SHEET oSh

    @ 2, 0 XLS WRITE "iPhone 15 Pro" SHEET oSh
    @ 2, 1 XLS WRITE 5 SHEET oSh
    @ 2, 2 XLS WRITE 1200.00 FORMAT oFormat SHEET oSh
    @ 2, 3 XLS FORMULA "=B3*C3" FORMAT oFormat SHEET oSh

    @ 3, 0 XLS WRITE "iPad Air" SHEET oSh
    @ 3, 1 XLS WRITE 3 SHEET oSh
    @ 3, 2 XLS WRITE 700.00 FORMAT oFormat SHEET oSh
    @ 3, 3 XLS FORMULA "=B4*C4" FORMAT oFormat SHEET oSh

    // 6. Pie de reporte con suma total
    @ 5, 2 XLS WRITE "TOTAL GENERAL:" FORMAT oHeader SHEET oSh
    @ 5, 3 XLS FORMULA "=SUM(D2:D4)" FORMAT oFormat SHEET oSh

    // 7. Cerrar y guardar
    CLOSE XLS oWk

    MsgInfo( "Reporte '" + cFile + "' generado correctamente." + hb_eol() + ;
        "Ahora puedes abrirlo en Numbers o Excel.", "FiveMac Power" )

return nil

//----------------------------------------------------------------------------//
