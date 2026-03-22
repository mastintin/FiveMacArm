#include <fivemac.h>

HB_FUNC(DATEPICKCREATE) {
  // Añadimos autorelease al objeto recién creado
  NSDatePicker *datePicker = [[[NSDatePicker alloc]
      initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3),
                               hb_parnl(4))] autorelease];

  NSWindow *window = (NSWindow *)hb_parnll(5);

  [GetView(window) addSubview:datePicker];

  [datePicker setDateValue:[NSDate date]];
  [datePicker setDatePickerElements:NSDatePickerElementFlagYearMonth];
  [datePicker setDatePickerStyle:NSDatePickerStyleClockAndCalendar];

  hb_retnll((HB_LONGLONG)datePicker);
}

//--------------------------------------------------------------------------------//

HB_FUNC(DATEPICKRELEASE) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);

  if (datePicker) {
    [datePicker removeFromSuperview];
    // Al quitarlo de la vista padre, ésta le envía un 'release' interno.
    // Como ya estaba en el pool de 'autorelease', el objeto se destruirá
    // de forma segura cuando el contador llegue a cero.
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(DATEPICKGETTEXT) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];

  [formatter setDateStyle:NSDateFormatterShortStyle];
  [formatter setTimeStyle:NSDateFormatterNoStyle]; // Si solo quieres fecha

  // Usamos el formateador sobre la fecha, no sobre el control
  NSString *string = [formatter stringFromDate:[datePicker dateValue]];


  if (string) {
    hb_retc([string UTF8String]);
  } else {
    hb_retc("");
  }
}

//--------------------------------------------------------------------------------//

/* NSYearMonthDatePickerElementFlag
   NSYearMonthDayDatePickerElementFlag
   NSEraDatePickerElementFlag
   NSHourMinuteDatePickerElementFlag
   NSHourMinuteSecondDatePickerElementFlag
   NSTimeZoneDatePickerElementFlag */

HB_FUNC(DATEPICKSETDRAWBACK) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);
  if (datePicker) {
    [datePicker setDrawsBackground:hb_parl(2)];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(DATEPICKSETBACKCOLOR) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);
  NSColor *color = [NSColor colorWithCalibratedRed:(hb_parnl(2) / 255.0)
                                             green:(hb_parnl(3) / 255.0)
                                              blue:(hb_parnl(4) / 255.0)
                                             alpha:(hb_parnl(5) / 100.0)];

  [datePicker setBackgroundColor:color];
}

HB_FUNC(DATEPICKSETTEXTCOLOR) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);
  NSColor *color = [NSColor colorWithCalibratedRed:(hb_parnl(2) / 255.0)
                                             green:(hb_parnl(3) / 255.0)
                                              blue:(hb_parnl(4) / 255.0)
                                             alpha:(hb_parnl(5) / 100.0)];

  [datePicker setTextColor:color];
}

//--------------------------------------------------------------------------------//

HB_FUNC(DATEPICKSETTEXT) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  if (datePicker && string) {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterShortStyle];

    NSDate *newDate = [formatter dateFromString:string];
    if (newDate) {
      [datePicker setDateValue:newDate];
    }
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(DATEPICKSETBEZELED) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);
  if (datePicker) {
    [datePicker setBezeled:hb_parl(2)];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(DATEPICKSETSTYLE) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);
  if (datePicker) {
    [datePicker setDatePickerStyle:(NSDatePickerStyle)hb_parni(2)];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(DATEPICKSETMINDATE) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  if (datePicker) {
    NSDate *minDate = nil;

    if (string && [string length] > 0) {
      NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
      [formatter setDateStyle:NSDateFormatterShortStyle];
      minDate = [formatter dateFromString:string];
    }

    // Si minDate es nil, el DatePicker elimina la restricción de fecha mínima
    [datePicker setMinDate:minDate];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(DATEPICKSETMAXDATE) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2); // Harbour string

  if (datePicker) {
    NSDate *maxDate = nil;

    // Solo intentamos crear la fecha si el string no está vacío
    if (string && [string length] > 0) {
      NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
      [formatter setDateStyle:NSDateFormatterShortStyle];
      maxDate = [formatter dateFromString:string];
    }

    // Si maxDate es nil (porque el string estaba vacío o era inválido),
    // se limpia el límite del DatePicker.
    [datePicker setMaxDate:maxDate];
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(DATEPICKSETTODAY) {
  NSDatePicker *datePicker = (NSDatePicker *)hb_parnll(1);

  [datePicker setDateValue:[NSDate date]];
}

//--------------------------------------------------------------------------------//

HB_FUNC(CSHORTDATETONSDATE) {
  NSString *string = hb_NSSTRING_par(1);
  NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
  [formatter setDateStyle:NSDateFormatterShortStyle];

  NSDate *date = [formatter dateFromString:string];

  if (date) {
    [date retain]; // <--- CRÍTICO: Evita que el pool de autorelease lo destruya
  }
  hb_retnll((HB_LONGLONG)date);
}

//--------------------------------------------------------------------------------//

HB_FUNC(NSDATERELEASE) {
  NSDate *date = (NSDate *)hb_parnll(1);

  if (date) {
    [date release];
    // Esto compensa el [date retain] que hicimos al crear/convertir la fecha.
    // Si el contador llega a cero, el objeto se destruye inmediatamente.
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(NSDATETOCDATESHORT) {
  NSDate *date = (NSDate *)hb_parnll(1);
  if (date) {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    NSString *string = [formatter stringFromDate:date];
    if (string) {
      hb_retc([string UTF8String]);
      return;
    }
  }
  hb_retc(""); // Retorno vacío si algo falla
}

//--------------------------------------------------------------------------------//

HB_FUNC(NSDATETOCDATEMEDIUM) {
  NSDate *date = (NSDate *)hb_parnll(1);
  if (date) {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *string = [formatter stringFromDate:date];

    if (string) {
      hb_retc([string UTF8String]);
      return;
    }
  }
  hb_retc(""); // Retorno vacío si algo falla
}
