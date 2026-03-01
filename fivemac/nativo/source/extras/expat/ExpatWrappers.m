#include "expat.h"
#include <fivemac.h>
#include <hbapicls.h>

/*
   Expat Wrappers for FiveMac
   (c) Manuel Alvarez 2026
*/

HB_FUNC(EXPATVERSION) { hb_retc(XML_ExpatVersion()); }

HB_FUNC(EXPATXMLPARSERCREATE) {
  XML_Parser parser = XML_ParserCreate(hb_pcount() > 0 ? hb_parc(1) : NULL);
  hb_retnll((HB_LONGLONG)parser);
}

HB_FUNC(EXPATXMLSETUSERDATA) {
  XML_Parser parser = (XML_Parser)hb_parnll(1);
  PHB_ITEM pObj = hb_param(2, HB_IT_OBJECT);

  if (parser && pObj)
    XML_SetUserData(parser, (void *)hb_itemNew(pObj));

  hb_retl(1);
}

HB_FUNC(EXPATXMLPARSERFREE) {
  XML_Parser parser = (XML_Parser)hb_parnll(1);
  if (parser) {
    PHB_ITEM pObj = (PHB_ITEM)XML_GetUserData(parser);
    if (pObj)
      hb_itemRelease(pObj);
    XML_ParserFree(parser);
  }
}

static void startElement(void *userData, const XML_Char *name,
                         const XML_Char **atts) {
  PHB_ITEM pParser = (PHB_ITEM)userData;

  if (pParser) {
    PHB_ITEM pStartBlock = hb_objSendMsg(pParser, "BSTARTELEMENT", 0);

    if (pStartBlock && (hb_itemType(pStartBlock) & HB_IT_BLOCK)) {
      PHB_ITEM pName = hb_itemPutC(NULL, (const char *)name);
      PHB_ITEM pAtts = hb_itemArrayNew(0);
      int i = 0;

      while (atts[i]) {
        hb_arrayAddForward(pAtts, hb_itemPutC(NULL, (const char *)atts[i]));
        hb_arrayAddForward(pAtts, hb_itemPutC(NULL, (const char *)atts[i + 1]));
        i += 2;
      }

      hb_vmEvalBlockV(pStartBlock, 2, pName, pAtts);
      hb_itemRelease(pName);
      hb_itemRelease(pAtts);
    }
  }
}

static void endElement(void *userData, const XML_Char *name) {
  PHB_ITEM pParser = (PHB_ITEM)userData;

  if (pParser) {
    PHB_ITEM pEndBlock = hb_objSendMsg(pParser, "BENDELEMENT", 0);

    if (pEndBlock && (hb_itemType(pEndBlock) & HB_IT_BLOCK)) {
      PHB_ITEM pName = hb_itemPutC(NULL, (const char *)name);
      hb_vmEvalBlockV(pEndBlock, 1, pName);
      hb_itemRelease(pName);
    }
  }
}

static void charData(void *userData, const XML_Char *s, int len) {
  PHB_ITEM pParser = (PHB_ITEM)userData;

  if (pParser) {
    PHB_ITEM pCharBlock = hb_objSendMsg(pParser, "BCHARDATA", 0);

    if (pCharBlock && (hb_itemType(pCharBlock) & HB_IT_BLOCK)) {
      PHB_ITEM pData = hb_itemPutCL(NULL, (const char *)s, len);
      hb_vmEvalBlockV(pCharBlock, 1, pData);
      hb_itemRelease(pData);
    }
  }
}

HB_FUNC(EXPATXMLSETELEMENTHANDLER) {
  XML_Parser parser = (XML_Parser)hb_parnll(1);
  XML_SetElementHandler(parser, startElement, endElement);
  hb_retl(1);
}

HB_FUNC(EXPATXMLSETCHARACTERDATAHANDLER) {
  XML_Parser parser = (XML_Parser)hb_parnll(1);
  XML_SetCharacterDataHandler(parser, charData);
  hb_retl(1);
}

HB_FUNC(EXPATXMLPARSE) {
  XML_Parser parser = (XML_Parser)hb_parnll(1);
  const char *xml = hb_parc(2);
  int len = hb_parclen(2);
  int isFinal = hb_parl(3);

  hb_retni(XML_Parse(parser, xml, len, isFinal));
}
