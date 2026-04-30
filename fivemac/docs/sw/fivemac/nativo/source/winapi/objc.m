#include <fivemac.h>
#include <hbapiitm.h>
#include <objc/runtime.h>

HB_FUNC(OBJC_OBJINSTANTIATE) // cClassName --> hObject
{
  Class cls = objc_getClass(hb_parc(1));

  if (cls != nil)
    hb_retnll((HB_LONGLONG)[[cls alloc] init]); // autorelease use ?
  else
    hb_ret();
}

HB_FUNC(OBJC_MSGSEND) {
  id hObj = (id)hb_parnll(1);
  SEL Selector = sel_registerName(hb_parc(2));

  if (!hObj || !Selector) {
    hb_retnll(0);
    return;
  }

  if (![hObj respondsToSelector:Selector]) {
    hb_retnll(0);
    return;
  }

  // Handle common types for 1 argument
  if (hb_pcount() >= 3) {
    id arg = nil;

    if (HB_ISARRAY(3)) {
      PHB_ITEM pArray = hb_param(3, HB_IT_ARRAY);
      unsigned long len = hb_arrayLen(pArray);
      NSMutableArray *arr = [NSMutableArray arrayWithCapacity:len];
      for (unsigned long i = 1; i <= len; i++) {
        HB_LONGLONG hPtr = hb_arrayGetNLL(pArray, i);
        if (hPtr) {
          [arr addObject:(id)hPtr];
        }
      }
      arg = arr;
    } else if (HB_ISNUM(3)) {
      // Dynamic check using Method Signature
      NSMethodSignature *signature = [hObj methodSignatureForSelector:Selector];
      if (signature && [signature numberOfArguments] > 2) {
        const char *argType =
            [signature getArgumentTypeAtIndex:2]; // 0=self, 1=_cmd, 2=arg
        if (argType &&
            (argType[0] == '@' || argType[0] == '#')) { // Object or Class
          arg = (id)hb_parnll(3);
        } else {
          arg = [NSNumber numberWithDouble:hb_parnd(3)];
        }
      } else {
        // Fallback
        arg = [NSNumber numberWithDouble:hb_parnd(3)];
      }
    } else if (HB_ISCHAR(3)) {
      arg = hb_NSSTRING_par(3);
    } else if (HB_ISLOG(3)) {
      // Special case for setWantsLayer: (BOOL)
      if ([hb_NSSTRING_par(2) isEqualToString:@"setWantsLayer:"]) {
        [hObj setWantsLayer:hb_parl(3)];
        hb_retnll(0);
        return;
      }
      arg = [NSNumber numberWithBool:hb_parl(3)];
    } else {
      arg = (id)hb_parnll(3);
    }

    // We use performSelector. Note: performSelector withObject: only works for
    // id-based args. Basic types like BOOL usually need NSInvocation or direct
    // msgSend for primitives. However, most Fivemac properties use objects or
    // we handle them specifically above.

    id result = [hObj performSelector:Selector withObject:arg];
    hb_retnll((HB_LONGLONG)result);
  } else {
    id result = [hObj performSelector:Selector];
    hb_retnll((HB_LONGLONG)result);
  }
}

HB_FUNC(OBJC_OBJSENDMSG) {
  // Alias for compatibility
  HB_FUNC_EXEC(OBJC_MSGSEND);
}

HB_FUNC(OBJC_GETCLASSNAME) {
  NSObject *hObj = (NSObject *)hb_parnll(1);

  hb_retc(object_getClassName(hObj));
}

HB_FUNC(OBJC_GETINSTANCEVARIABLE) {
  NSObject *hObj = (NSObject *)hb_parnll(1);
  void *outValue;
  void *ivar = object_getInstanceVariable(hObj, hb_parc(2), &outValue);
  // Ivar --> void *

  hb_retnll((HB_LONGLONG)ivar);
}

HB_FUNC(OBJC_GETCLASSLIST) {
  int numClasses = objc_getClassList(NULL, 0);
  Class *classes = NULL;

  if (numClasses > 0) {
    classes = (Class *)hb_xgrab(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);

    hb_reta(numClasses);

    while (numClasses)
      hb_storvc((char *)class_getName(*classes++), numClasses--, -1);

    // hb_xfree( classes );
  } else
    hb_reta(0);
}

HB_FUNC(OBJADDSUBVIEW) {
  NSView *parent = (NSView *)hb_parnll(1);
  NSView *child = (NSView *)hb_parnll(2);

  [parent addSubview:child];
}

HB_FUNC(OBJREMOVEFROMSUPERVIEW) {
  NSView *view = (NSView *)hb_parnll(1);

  [view removeFromSuperview];
}

HB_FUNC(OBJCDEALLOC) {
  NSView *view = (NSView *)hb_parnll(1);

  [view dealloc];
}
