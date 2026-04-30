/*
 * xlsxCmd.ch
 * Comandos simples para hbxlsxwriter
 */

#ifndef _XLSXCMD_CH
#define _XLSXCMD_CH

// Workbook
#command CREATE XLS <oWk> FILE <cFile> ;
    => ;
    <oWk> := workbook_new( <cFile> )

#command CLOSE XLS <oWk> ;
    => ;
    workbook_close( <oWk> )

// Worksheet
#command ADD SHEET <oSh> [ NAME <cName> ] BOOK <oWk> ;
    => ;
    <oSh> := workbook_add_worksheet( <oWk>, [<cName>] )

#command ADD WORKSHEET <oSh> [ NAME <cName> ] WORKBOOK <oWk> ;
    => ;
    <oSh> := workbook_add_worksheet( <oWk>, [<cName>] )

// Formatting
#command DEFINE XLS FORMAT <oFmt> BOOK <oWk> ;
    => ;
    <oFmt> := workbook_add_format( <oWk> )

#command DEFINE XLS FORMAT <oFmt> WORKBOOK <oWk> ;
    => ;
    <oFmt> := workbook_add_format( <oWk> )

#command SET XLS FORMAT <oFmt> NUMFORMAT <c> ;
    => ;
    format_set_num_format( <oFmt>, <c> )

#command SET XLS FORMAT <oFmt> BOLD <l> ;
    => ;
    format_set_bold( <oFmt> )

// Dimensions - Column (Simple)
#command SET XLS COLUMN <f> WIDTH <w> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    worksheet_set_column( <oSh>, XLS_COL(<f>), XLS_COL(<f>), <w>, [<fmt>] )

#command SET XLS COLUMN <f> WIDTH <w> [ FORMAT <fmt> ] WORKSHEET <oSh> ;
    => ;
    worksheet_set_column( <oSh>, XLS_COL(<f>), XLS_COL(<f>), <w>, [<fmt>] )

// Dimensions - Column (Range)
#command SET XLS COLUMN <f> TO <t> WIDTH <w> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    worksheet_set_column( <oSh>, XLS_COL(<f>), XLS_COL(<t>), <w>, [<fmt>] )

#command SET XLS COLUMN <f> TO <t> WIDTH <w> [ FORMAT <fmt> ] WORKSHEET <oSh> ;
    => ;
    worksheet_set_column( <oSh>, XLS_COL(<f>), XLS_COL(<t>), <w>, [<fmt>] )

// Dimensions - Column Pixels (Simple)
#command SET XLS COLUMN <f> PIXELS <w> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    worksheet_set_column_pixels( <oSh>, XLS_COL(<f>), XLS_COL(<f>), <w>, [<fmt>] )

#command SET XLS COLUMN <f> PIXELS <w> [ FORMAT <fmt> ] WORKSHEET <oSh> ;
    => ;
    worksheet_set_column_pixels( <oSh>, XLS_COL(<f>), XLS_COL(<f>), <w>, [<fmt>] )

// Dimensions - Column Pixels (Range)
#command SET XLS COLUMN <f> TO <t> PIXELS <w> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    worksheet_set_column_pixels( <oSh>, XLS_COL(<f>), XLS_COL(<t>), <w>, [<fmt>] )

#command SET XLS COLUMN <f> TO <t> PIXELS <w> [ FORMAT <fmt> ] WORKSHEET <oSh> ;
    => ;
    worksheet_set_column_pixels( <oSh>, XLS_COL(<f>), XLS_COL(<t>), <w>, [<fmt>] )

// Dimensions - Row
#command SET XLS ROW <r> HEIGHT <h> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    worksheet_set_row( <oSh>, <r>, <h>, [<fmt>] )

#command SET XLS ROW <r> HEIGHT <h> [ FORMAT <fmt> ] WORKSHEET <oSh> ;
    => ;
    worksheet_set_row( <oSh>, <r>, <h>, [<fmt>] )

// Dimensions - Row Pixels
#command SET XLS ROW <r> PIXELS <h> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    worksheet_set_row_pixels( <oSh>, <r>, <h>, [<fmt>] )

#command SET XLS ROW <r> PIXELS <h> [ FORMAT <fmt> ] WORKSHEET <oSh> ;
    => ;
    worksheet_set_row_pixels( <oSh>, <r>, <h>, [<fmt>] )

// Writing data (Primary syntax)
#command @ <row>, <col> XLS WRITE <val> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    XLSWrite( <oSh>, <row>, XLS_COL(<col>), <val>, [<fmt>] )

#command @ <row>, <col> XLS WRITE <val> [ FORMAT <fmt> ] WORKSHEET <oSh> ;
    => ;
    XLSWrite( <oSh>, <row>, XLS_COL(<col>), <val>, [<fmt>] )

// Formula writing
#command @ <row>, <col> XLS FORMULA <formula> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    worksheet_write_formula( <oSh>, <row>, XLS_COL(<col>), <formula>, [<fmt>] )

#command @ <row>, <col> XLS WRITE FUNC <formula> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    worksheet_write_formula( <oSh>, <row>, XLS_COL(<col>), <formula>, [<fmt>] )

// Alternative writing data syntax
#command XLS WRITE <val> AT <row>, <col> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    XLSWrite( <oSh>, <row>, XLS_COL(<col>), <val>, [<fmt>] )

#command XLS WRITE <val> AT <row>, <col> [ FORMAT <fmt> ] WORKSHEET <oSh> ;
    => ;
    XLSWrite( <oSh>, <row>, XLS_COL(<col>), <val>, [<fmt>] )

#command XLS FORMULA <formula> AT <row>, <col> [ FORMAT <fmt> ] SHEET <oSh> ;
    => ;
    worksheet_write_formula( <oSh>, <row>, XLS_COL(<col>), <formula>, [<fmt>] )

// Features
#command XLS COMMENT <msg> AT <row>, <col> SHEET <oSh> ;
    => ;
    worksheet_write_comment( <oSh>, <row>, XLS_COL(<col>), <msg> )

#command XLS COMMENT <msg> AT <row>, <col> WORKSHEET <oSh> ;
    => ;
    worksheet_write_comment( <oSh>, <row>, XLS_COL(<col>), <msg> )

#command XLS TABLE [ RANGE ] <r1>, <c1> TO <r2>, <c2> [ OPTIONS <opt> ] SHEET <oSh> ;
    => ;
    worksheet_add_table( <oSh>, <r1>, XLS_COL(<c1>), <r2>, XLS_COL(<c2>), [<opt>] )

#command XLS TABLE [ RANGE ] <r1>, <c1> TO <r2>, <c2> [ OPTIONS <opt> ] WORKSHEET <oSh> ;
    => ;
    worksheet_add_table( <oSh>, <r1>, XLS_COL(<c1>), <r2>, XLS_COL(<c2>), [<opt>] )

#endif
