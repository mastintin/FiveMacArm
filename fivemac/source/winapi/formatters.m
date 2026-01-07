#include <fivemac.h>

HB_FUNC(FORMATTERCREATE) {
  NSFormatter *formatter = [[[NSFormatter alloc] init] autorelease];
  hb_retnll((HB_LONGLONG)formatter);
}

HB_FUNC(FORMATTERDATECREATE) {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  hb_retnll((HB_LONGLONG)formatter);
}

HB_FUNC(FORMATTERNUMBERCREATE) {
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  hb_retnll((HB_LONGLONG)formatter);
}

HB_FUNC(FORMATTERSETDATESHORT) {
  NSDateFormatter *formatter = (NSDateFormatter *)hb_parnll(1);
  [formatter setDateStyle:NSDateFormatterShortStyle];
}

HB_FUNC(FORMATTERSETDATEMEDIUM) {
  NSDateFormatter *formatter = (NSDateFormatter *)hb_parnll(1);
  [formatter setDateStyle:NSDateFormatterMediumStyle];
}

HB_FUNC(FORMATTERSETTIMESHORT) {
  NSDateFormatter *formatter = (NSDateFormatter *)hb_parnll(1);
  [formatter setTimeStyle:NSDateFormatterShortStyle];
}

HB_FUNC(FORMATTERSETTIMEMEDIUM) {
  NSDateFormatter *formatter = (NSDateFormatter *)hb_parnll(1);
  [formatter setTimeStyle:NSDateFormatterMediumStyle];
}

HB_FUNC(FORMATTERNUMERICSETLOCALE) {
  NSNumberFormatter *formatter = (NSNumberFormatter *)hb_parnll(1);
  NSLocale *locale = (NSLocale *)hb_parnll(2);
  [formatter setLocale:locale];
}

HB_FUNC(FORMATTERSETNUMERIC) {
  NSNumberFormatter *formatter = (NSNumberFormatter *)hb_parnll(1);
  [formatter setNumberStyle:NSNumberFormatterNoStyle];
}

HB_FUNC(FORMATTERSETCURRENCY) {
  NSNumberFormatter *formatter = (NSNumberFormatter *)hb_parnll(1);
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}

HB_FUNC(LOCALECREATEFROMID) {
  NSString *string = hb_NSSTRING_par(1);
  NSLocale *locale = [NSLocale localeWithLocaleIdentifier:string];
  hb_retnll((HB_LONGLONG)locale);
}

HB_FUNC(LOCALECURRENT) {
  NSLocale *locale = [NSLocale currentLocale];
  hb_retnll((HB_LONGLONG)locale);
}

HB_FUNC(LOCALEGETNAME) {
  NSLocale *locale = (NSLocale *)hb_parnll(1);
  NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
  NSString *displayNameString = [locale displayNameForKey:NSLocaleIdentifier
                                                    value:language];
  hb_retc([displayNameString cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(LOCALEGETLANGUAGE) {
  NSLocale *locale = (NSLocale *)hb_parnll(1);
  NSString *code = locale.languageCode;
  NSString *language = [locale localizedStringForLanguageCode:code];

  hb_retc([language cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(LOCALESETLANGUAGE) {
  NSString *lang = hb_NSSTRING_par(1);
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:@[ lang ] forKey:@"AppleLanguages"];
  // setObject:@[@"de"] forKey:@"AppleLanguages"];
  [defaults synchronize];
}

HB_FUNC(LOCALEGETPREFID) {
  NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
  hb_retc([language cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(LOCALEGETMESURESYSTEM) {
  NSLocale *locale = (NSLocale *)hb_parnll(1);
  NSString *string = [locale objectForKey:NSLocaleMeasurementSystem];
  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(LOCALEMESUREISMETRIC) {
  NSLocale *locale = (NSLocale *)hb_parnll(1);
  bool isMetric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
  hb_retl((BOOL)isMetric);
}
