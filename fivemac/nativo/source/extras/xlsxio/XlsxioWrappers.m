#include "xlsxio_read.h"
#include <fivemac.h>
#include <hbapicls.h>
#include <hbapiitm.h>

/*
   XLSX I/O Wrappers for FiveMac
   (c) FiveTech Software 2026
*/

HB_FUNC(XLSXIOREADOPEN) {
  const char *filename = hb_parc(1);
  xlsxioreader handle = xlsxioread_open(filename);
  hb_retnll((HB_LONGLONG)handle);
}

HB_FUNC(XLSXIOREADCLOSE) {
  xlsxioreader handle = (xlsxioreader)hb_parnll(1);
  if (handle)
    xlsxioread_close(handle);
}

HB_FUNC(XLSXIOREADGETVERSIONSTRING) {
  hb_retc(xlsxioread_get_version_string());
}

HB_FUNC(XLSXIOREADSHEETLISTOPEN) {
  xlsxioreader handle = (xlsxioreader)hb_parnll(1);
  xlsxioreadersheetlist list = xlsxioread_sheetlist_open(handle);
  hb_retnll((HB_LONGLONG)list);
}

HB_FUNC(XLSXIOREADSHEETLISTNEXT) {
  xlsxioreadersheetlist list = (xlsxioreadersheetlist)hb_parnll(1);
  const char *sheetname = xlsxioread_sheetlist_next(list);
  if (sheetname)
    hb_retc(sheetname);
  else
    hb_ret();
}

HB_FUNC(XLSXIOREADSHEETLISTCLOSE) {
  xlsxioreadersheetlist list = (xlsxioreadersheetlist)hb_parnll(1);
  if (list)
    xlsxioread_sheetlist_close(list);
}

HB_FUNC(XLSXIOREADSHEETOPEN) {
  xlsxioreader handle = (xlsxioreader)hb_parnll(1);
  const char *sheetname = hb_parc(2);
  unsigned int flags = hb_parni(3);
  xlsxioreadersheet sheet = xlsxioread_sheet_open(handle, sheetname, flags);
  hb_retnll((HB_LONGLONG)sheet);
}

HB_FUNC(XLSXIOREADSHEETCLOSE) {
  xlsxioreadersheet sheet = (xlsxioreadersheet)hb_parnll(1);
  if (sheet)
    xlsxioread_sheet_close(sheet);
}

HB_FUNC(XLSXIOREADSHEETNEXTROW) {
  xlsxioreadersheet sheet = (xlsxioreadersheet)hb_parnll(1);
  hb_retl(xlsxioread_sheet_next_row(sheet) != 0);
}

HB_FUNC(XLSXIOREADSHEETNEXTCELL) {
  xlsxioreadersheet sheet = (xlsxioreadersheet)hb_parnll(1);
  char *value = xlsxioread_sheet_next_cell(sheet);
  if (value) {
    hb_retc(value);
    xlsxioread_free(value);
  } else
    hb_ret();
}

HB_FUNC(XLSXIOREADSHEETLASTROWINDEX) {
  xlsxioreadersheet sheet = (xlsxioreadersheet)hb_parnll(1);
  hb_retnll((HB_LONGLONG)xlsxioread_sheet_last_row_index(sheet));
}

HB_FUNC(XLSXIOREADSHEETLASTCOLUMNINDEX) {
  xlsxioreadersheet sheet = (xlsxioreadersheet)hb_parnll(1);
  hb_retnll((HB_LONGLONG)xlsxioread_sheet_last_column_index(sheet));
}
