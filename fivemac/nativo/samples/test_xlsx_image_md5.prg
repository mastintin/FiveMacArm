#include "FiveMac.ch"

function Main()
    local oXlsx, oSh
    local cImage := "/Users/manuel/Fivemac/bitmaps/test.png"
    Local cFile 

    if ! File( cImage )
        MsgInfo( "Image not found for test: " + cImage )
        return nil
    endif

    cFile := path() + "/"+ "test_images.xlsx"
    DEFINE XLSX oXlsx FILE cFile

    if empty( oXlsx )
        MsgInfo( "Error: Could not create XLSX workbook object" )
        return nil
    endif

    DEFINE WORKSHEET "MD5 Test" OF oXlsx

    @ 1, 1 XLSX WRITE "Testing MD5 Deduplication"
    @ 2, 1 XLSX WRITE "Image size: " + hb_ntos( fsize( cImage ) )

    @ 4, 1 XLSX WRITE "Inserting image first time..."
    XLSX INSERT IMAGE cImage ROW 5 COL 1

    @ 25, 1 XLSX WRITE "Inserting SAME image second time..."
    @ 26, 1 XLSX WRITE "MD5 should prevent duplication"
    XLSX INSERT IMAGE cImage ROW 27 COL 1

    END WORKSHEET

    END XLSX oXlsx

    if File( cFile )
        MsgInfo( "File test_md5.xlsx created!" + hb_eol() + ;
            "XLSX Final size: " + hb_ntos( fsize( cFile ) ) + hb_eol() + ;
            "Image size: " + hb_ntos( fsize( cImage ) ) + hb_eol() + ;
            "IF FINAL SIZE IS ALMOST SAME AS IMAGE SIZE -> MD5 WORKED!" )
    else
        MsgInfo( "Error: File not created" )
    endif

return nil
