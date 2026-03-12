#import "SwiftCommon.h"
/*
HB_FUNC(SWIFTPICKERCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);

  // Items array handling
  NSArray *itemsArray = nil;
  if (HB_ISARRAY(5)) {
    NSMutableArray *tempArray = [NSMutableArray array];
    PHB_ITEM pArray = hb_param(5, HB_IT_ARRAY);

    if (pArray) {
      HB_SIZE nLen = hb_arrayLen(pArray);
      for (HB_SIZE i = 1; i <= nLen; i++) {
        const char *cItem = hb_arrayGetCPtr(pArray, i);
        if (cItem)
          [tempArray addObject:[NSString stringWithUTF8String:cItem]];
      }
    }
    itemsArray = [NSArray arrayWithArray:tempArray];
  }

  id parent = (id)hb_parnll(6);
  NSInteger nIndex = (NSInteger)hb_parnll(7);
  NSString *cTitle = hb_NSSTRING_par(8);
  NSString *cId = hb_NSSTRING_par(9);

  // Callback
  void (^callbackBlock)(NSString *) = ^(NSString *msg) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTPICKERONCHANGE");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushNLL(nIndex);
        hb_vmPushString([msg UTF8String], [msg length]);
        hb_vmDo(2);
      }
    });
  };

  // Direct call to Swift Factory
  NSView *pickerView = [SwiftPickerLoader makePickerWithTitle:cTitle
                                                        items:itemsArray
                                                           id:cId
                                                        index:nIndex
                                                     callback:callbackBlock];

  if (pickerView) {
    setupSwiftView(pickerView, parent, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)pickerView);
  }
}

HB_FUNC(SWIFTPICKERSETITEMS) {
  NSArray *itemsArray = nil;
  if (HB_ISARRAY(1)) {
    NSMutableArray *tempArray = [NSMutableArray array];
    PHB_ITEM pArray = hb_param(1, HB_IT_ARRAY);

    if (pArray) {
      HB_SIZE nLen = hb_arrayLen(pArray);
      for (HB_SIZE i = 1; i <= nLen; i++) {
        const char *cItem = hb_arrayGetCPtr(pArray, i);
        if (cItem)
          [tempArray addObject:[NSString stringWithUTF8String:cItem]];
      }
    }
    itemsArray = [NSArray arrayWithArray:tempArray];
  }
  NSString *cId = hb_NSSTRING_par(2);
  [SwiftPickerActions setItemsWithId:cId items:itemsArray];
}

HB_FUNC(PKR_SET_SELECTION) {
  NSString *cId = hb_NSSTRING_par(1);
  NSString *sel = hb_NSSTRING_par(2);
  SW_PKR_SET_SELECTION((const int8_t *)[cId UTF8String],
                       (const int8_t *)[sel UTF8String]);
}

HB_FUNC(PKR_SET_GLASS) {
  NSString *cId = hb_NSSTRING_par(1);
  NSString *isGlass = hb_NSSTRING_par(2);
  SW_PKR_SET_GLASS((const int8_t *)[cId UTF8String],
                   (const int8_t *)[isGlass UTF8String]);
}

HB_FUNC(PKR_SET_SHOW_LABEL) {
  NSString *cId = hb_NSSTRING_par(1);
  NSString *show = hb_NSSTRING_par(2);
  SW_PKR_SET_SHOW_LABEL((const int8_t *)[cId UTF8String],
                        (const int8_t *)[show UTF8String]);
}

HB_FUNC(PKR_SET_TITLE) {
  NSString *cId = hb_NSSTRING_par(1);
  NSString *title = hb_NSSTRING_par(2);
  SW_PKR_SET_TITLE((const int8_t *)[cId UTF8String],
                   (const int8_t *)[title UTF8String]);
}

HB_FUNC(PKR_GET_SELECTION) {
  NSString *cId = hb_NSSTRING_par(1);
  const char *res =
      (const char *)SW_PKR_GET_SELECTION((const int8_t *)[cId UTF8String]);
  hb_retc(res ? res : "");
}

HB_FUNC(PKR_SET_COLORS) {
  NSString *cId = hb_NSSTRING_par(1);
  NSString *accent = hb_NSSTRING_par(2);
  NSString *text = hb_NSSTRING_par(3);
  SW_PKR_SET_COLORS((const int8_t *)[cId UTF8String],
                    (const int8_t *)[accent UTF8String],
                    (const int8_t *)[text UTF8String]);
}
*/