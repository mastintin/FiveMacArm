#import "SwiftCommon.h"

HB_FUNC(SWIFTTEXTFIELDCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cText = hb_NSSTRING_par(5);
  NSString *cPlaceholder = hb_NSSTRING_par(6);
  id parent = (id)hb_parnll(7);
  NSString *cId = hb_NSSTRING_par(9);

  NSString *className = @"SwiftTextFieldLoader";
  Class swiftClass = NSClassFromString(className);

  if (!swiftClass) {
    className = @"SwiftFive.SwiftTextFieldLoader";
    swiftClass = NSClassFromString(className);
  }

  if (!swiftClass) {
    return;
  }

  // Callback for text changes using String ID
  void (^callbackBlock)(NSString *) = ^(NSString *newText) {
    dispatch_async(dispatch_get_main_queue(), ^{
      PHB_DYNS pDynSym = hb_dynsymFindName("SWIFTTEXTFIELDONCHANGE");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushString([cId UTF8String], [cId length]);
        const char *utf8Text = [newText UTF8String];
        hb_vmPushString(utf8Text, strlen(utf8Text));
        hb_vmDo(2);
      }
    });
  };

  // Direct call to Swift Factory
  NSView *fieldView =
      [SwiftTextFieldLoader makeTextFieldWithText:cText
                                      placeholder:cPlaceholder
                                               id:cId
                                         callback:callbackBlock];

  if (fieldView) {
    setupSwiftView(fieldView, parent, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)fieldView);
  }
}
HB_FUNC(SWIFTTEXTEDITORCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cText = hb_NSSTRING_par(5);
  id parent = (id)hb_parnll(6);
  NSString *cId = hb_NSSTRING_par(7);

  NSView *editorView = [SwiftTextFieldLoader makeTextEditorWithText:cText
                                                                 id:cId];
  if (editorView) {
    setupSwiftView(editorView, parent, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)editorView);
  }
}

HB_FUNC(TF_SET_TEXT) {
  SW_TF_SET_TEXT((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                 sw_parc(2));
}

HB_FUNC(TF_GET_TEXT) {
  const char *res = (const char *)SW_TF_GET_TEXT(
      (const int8_t *)[GetRootIdFromParam(1) UTF8String]);
  hb_retc(res ? res : "");
}

HB_FUNC(TF_SET_COLORS) {
  SW_TF_SET_COLORS((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                   sw_parc(2), sw_parc(3));
}

HB_FUNC(TF_SET_FONT_SIZE) {
  SW_TF_SET_FONT_SIZE((const int8_t *)[GetRootIdFromParam(1) UTF8String],
                      sw_parc(2));
}
