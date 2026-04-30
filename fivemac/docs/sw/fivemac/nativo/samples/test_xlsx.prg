#include "FiveMac.ch"
#include "hbxlsxwriter.ch"
#include "xlsxCmd.ch"

function Main()

    local oBook, oSheet
    local cFile := "test_absolute_refs.xlsx"

    CREATE XLS oBook FILE cFile
    ADD SHEET oSheet NAME "Referencias" BOOK oBook

    SET XLS COLUMN "A" TO "C" PIXELS 150 SHEET oSheet

    // Definimos un "valor fijo" en B5 (fila 4, col 1)
    XLS WRITE 1000 AT 4, "B" SHEET oSheet
    XLS WRITE "<- VALOR FIJO" AT 4, "C" SHEET oSheet

    // Datos variables en la columna A
    XLS WRITE "Datos" AT 0, "A" SHEET oSheet
    XLS WRITE 10 AT 1, "A" SHEET oSheet
    XLS WRITE 20 AT 2, "A" SHEET oSheet
    XLS WRITE 30 AT 3, "A" SHEET oSheet

    XLS WRITE "Resultado (+ Fijo)" AT 0, "B" SHEET oSheet

    // Fórmulas con referencia absoluta a $B$5
    // Fila 2: =A2 + $B$5
    @ 1, "B" XLS FORMULA "=A2 + $B$5" SHEET oSheet
    
    // Fila 3: =A3 + $B$5
    @ 2, "B" XLS FORMULA "=A3 + $B$5" SHEET oSheet
    
    // Fila 4: =A4 + $B$5
    @ 3, "B" XLS FORMULA "=A4 + $B$5" SHEET oSheet

    CLOSE XLS oBook

    MsgInfo( "Excel con referencias fijas ($B$5) creado: " + cFile )

return nil
