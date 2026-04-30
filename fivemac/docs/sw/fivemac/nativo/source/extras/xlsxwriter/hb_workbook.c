/* stdint MUST be first */
#include "xlsxwriter/hash_table.h"
#include "xlsxwriter/packager.h"
#include "xlsxwriter/utility.h"
#include "xlsxwriter/workbook.h"
#include "xlsxwriter/xmlwriter.h"
#include <stdint.h>

#include "hbapierr.h"
#include "hbapiitm.h"

void hb_XLSXWorksheet_ret(lxw_worksheet *);
void hb_XLSXChart_ret(lxw_chart *);

typedef struct {
  lxw_workbook *workbook;
} HB_WORKBOOK_GC, *PHB_WORKBOOK_GC;

static HB_GARBAGE_FUNC(XLSXWorkbook_release) {
  PHB_WORKBOOK_GC pGC = (PHB_WORKBOOK_GC)Cargo;
  if (pGC->workbook) {
    lxw_workbook_free(pGC->workbook);
    pGC->workbook = NULL;
  }
}

static HB_GARBAGE_FUNC(hb_workbook_mark) {
  PHB_WORKBOOK_GC pGC = (PHB_WORKBOOK_GC)Cargo;
  if (pGC->workbook)
    hb_gcMark(pGC->workbook);
}

static const HB_GC_FUNCS s_gcXLSXWorkbookFuncs = {XLSXWorkbook_release,
                                                  hb_workbook_mark};

void hb_XLSXWorkbook_ret(lxw_workbook *p) {
  if (p) {
    PHB_WORKBOOK_GC pGC = (PHB_WORKBOOK_GC)hb_gcAllocate(
        sizeof(HB_WORKBOOK_GC), &s_gcXLSXWorkbookFuncs);
    pGC->workbook = p;
    hb_retptrGC(pGC);
  } else
    hb_retptr(NULL);
}

lxw_workbook *hb_XLSXWorkbook_par(int iParam) {
  PHB_WORKBOOK_GC pGC =
      (PHB_WORKBOOK_GC)hb_parptrGC(&s_gcXLSXWorkbookFuncs, iParam);
  if (pGC && pGC->workbook)
    return pGC->workbook;
  else
    return NULL;
}

lxw_workbook *hb_XLSXWorkbook_item(PHB_ITEM pValue) {
  PHB_WORKBOOK_GC pGC =
      (PHB_WORKBOOK_GC)hb_itemGetPtrGC(pValue, &s_gcXLSXWorkbookFuncs);
  if (pGC && pGC->workbook)
    return pGC->workbook;
  else
    return NULL;
}

HB_FUNC(WORKBOOK_NEW) {
  const char *filename = hb_parcx(1);
  hb_XLSXWorkbook_ret(workbook_new(filename));
}

HB_FUNC(NEW_WORKBOOK) {
  const char *filename = hb_parcx(1);
  hb_XLSXWorkbook_ret(workbook_new_opt(filename, NULL));
}

HB_FUNC(WORKBOOK_NEW_OPT) {
  const char *filename = hb_parcx(1);
  lxw_workbook_options *options = hb_param(2, HB_IT_ANY);
  if (HB_ISNIL(2))
    hb_XLSXWorkbook_ret(workbook_new_opt(filename, NULL));
  else
    hb_XLSXWorkbook_ret(workbook_new_opt(filename, options));
}

HB_FUNC(WORKBOOK_ADD_WORKSHEET) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *sheetname = hb_parcx(2);
  if (HB_ISNIL(2) || strlen(sheetname) == 0)
    hb_XLSXWorksheet_ret(workbook_add_worksheet(self, NULL));
  else
    hb_XLSXWorksheet_ret(workbook_add_worksheet(self, sheetname));
}

HB_FUNC(WORKBOOK_ADD_CHARTSHEET) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *sheetname = hb_parcx(2);
  if (self)
    hb_retptr(workbook_add_chartsheet(self, sheetname));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_ADD_CHART) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  uint8_t type = hb_parni(2);
  if (self)
    hb_XLSXChart_ret(workbook_add_chart(self, type));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

void hb_XLSXFormat_ret(lxw_format *p);

HB_FUNC(WORKBOOK_ADD_FORMAT) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  if (self)
    hb_XLSXFormat_ret(workbook_add_format(self));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_CLOSE) {
  int i;
  PHB_WORKBOOK_GC pGC = (PHB_WORKBOOK_GC)hb_parptrGC(&s_gcXLSXWorkbookFuncs, 1);
  if (pGC && pGC->workbook) {
    i = workbook_close(pGC->workbook);
    pGC->workbook = NULL;
    hb_retni(i);
  } else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_DEFINE_NAME) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *name = hb_parcx(2);
  const char *formula = hb_parcx(3);
  if (self)
    hb_retni(workbook_define_name(self, name, formula));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_ADD_VBA_PROJECT) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *filename = hb_parcx(2);
  if (self)
    hb_retni(workbook_add_vba_project(self, filename));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

lxw_doc_properties *hash2properties(PHB_ITEM pHash) {
  if (HB_IS_HASH(pHash)) {
    lxw_doc_properties *properties =
        (lxw_doc_properties *)hb_xalloc(sizeof(lxw_doc_properties));
    memset(properties, 0, sizeof(lxw_doc_properties));
    HB_SIZE nLen = hb_hashLen(pHash), nPos = 0;
    while (++nPos <= nLen) {
      PHB_ITEM pKey = hb_hashGetKeyAt(pHash, nPos);
      PHB_ITEM pValue = hb_hashGetValueAt(pHash, nPos);
      if (pKey && pValue) {
        char *key = (char *)hb_itemGetC(pKey);
        if (HB_IS_STRING(pValue)) {
          char *value = (char *)hb_itemGetC(pValue);
          if (hb_stricmp(key, "title") == 0)
            properties->title = value;
          else if (hb_stricmp(key, "subject") == 0)
            properties->subject = value;
          else if (hb_stricmp(key, "author") == 0)
            properties->author = value;
          else if (hb_stricmp(key, "manager") == 0)
            properties->manager = value;
          else if (hb_stricmp(key, "company") == 0)
            properties->company = value;
          else if (hb_stricmp(key, "category") == 0)
            properties->category = value;
          else if (hb_stricmp(key, "keywords") == 0)
            properties->keywords = value;
          else if (hb_stricmp(key, "comments") == 0)
            properties->comments = value;
          else if (hb_stricmp(key, "status") == 0)
            properties->status = value;
          else if (hb_stricmp(key, "hyperlink_base") == 0)
            properties->hyperlink_base = value;
        }
      }
    }
    return properties;
  }
  return NULL;
}

HB_FUNC(WORKBOOK_SET_PROPERTIES) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  PHB_ITEM pHash = hb_param(2, HB_IT_HASH);
  if (self) {
    lxw_doc_properties *user_props = hash2properties(pHash);
    hb_retni(workbook_set_properties(self, user_props));
    hb_xfree(user_props);
  } else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_SET_CUSTOM_PROPERTY_STRING) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *name = hb_parcx(2);
  const char *value = hb_parcx(3);
  if (self)
    hb_retni(workbook_set_custom_property_string(self, name, value));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_SET_CUSTOM_PROPERTY_NUMBER) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *name = hb_parcx(2);
  double value = hb_parnd(3);
  if (self)
    hb_retni(workbook_set_custom_property_number(self, name, value));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_SET_CUSTOM_PROPERTY_INTEGER) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *name = hb_parcx(2);
  int32_t value = hb_parnl(3);
  if (self)
    hb_retni(workbook_set_custom_property_integer(self, name, value));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_SET_CUSTOM_PROPERTY_BOOLEAN) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *name = hb_parcx(2);
  uint8_t value = hb_parni(3);
  if (self)
    hb_retni(workbook_set_custom_property_boolean(self, name, value));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_SET_CUSTOM_PROPERTY_DATETIME) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *name = hb_parcx(2);
  lxw_datetime *datetime = hb_parptr(3);
  if (self)
    hb_retni(workbook_set_custom_property_datetime(self, name, datetime));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_GET_WORKSHEET_BY_NAME) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *name = hb_parcx(2);
  if (self)
    hb_retptr(workbook_get_worksheet_by_name(self, name));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

HB_FUNC(WORKBOOK_GET_CHARTSHEET_BY_NAME) {
  lxw_workbook *self = hb_XLSXWorkbook_par(1);
  const char *name = hb_parcx(2);
  if (self)
    hb_retptr(workbook_get_chartsheet_by_name(self, name));
  else
    hb_errRT_BASE(EG_ARG, 2020, NULL, HB_ERR_FUNCNAME, HB_ERR_ARGS_BASEPARAMS);
}

// eof
