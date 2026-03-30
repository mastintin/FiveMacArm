#include <fivemac.h>

//----------------------------------------------------------------------//

HB_FUNC(SLIDERCREATE) {
  NSRect frame = NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3), hb_parnl(4));

  // Aplicamos autorelease para evitar fugas bajo No-ARC (MRC)
  NSSlider *slider = [[[NSSlider alloc] initWithFrame:frame] autorelease];

  NSWindow *window = (NSWindow *)hb_parnll(5);
  NSView *vParent = GetView(window);

  if (vParent) {
    [vParent addSubview:slider];
    // Al añadirlo a la vista, esta le hace un 'retain' (incrementa el
    // contador). Así, el objeto vivirá mientras la ventana esté abierta.
  }

  [slider setMinValue:0];
  [slider setMaxValue:100];

  // Es fundamental asignar el Target para que el evento se dispare
  // correctamente
  [slider setTarget:vParent];
  [slider setAction:@selector(SliderChanged:)];

  hb_retnll((HB_LONGLONG)slider);
}

//----------------------------------------------------------------------//

HB_FUNC(SLIDERRESCREATE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSView *vParent = GetView(window);
  NSSlider *slider = (NSSlider *)[vParent viewWithTag:hb_parnl(2)];

  if (vParent && slider) {
    [slider setTarget:vParent];
    [slider setAction:@selector(SliderChanged:)];
  }

  hb_retnll((HB_LONGLONG)slider);
}

//----------------------------------------------------------------------//

HB_FUNC(SLIDERMINMAXVALUE) {
  NSSlider *slider = (NSSlider *)hb_parnll(1);

  if (slider) {
    // Si se pasó el 2º parámetro, actualizamos el Mínimo
    if (hb_pcount() >= 2 && !HB_ISNIL(2)) {
      [slider setMinValue:hb_parnd(2)];
    }

    // Si se pasó el 3º parámetro, actualizamos el Máximo
    if (hb_pcount() >= 3 && !HB_ISNIL(3)) {
      [slider setMaxValue:hb_parnd(3)];
    }

    [slider setNeedsDisplay:YES];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(SLIDERSETTICKMARKS) {
  NSSlider *slider = (NSSlider *)hb_parnll(1);

  if (slider) {
    // 1. Establecer el número de marcas
    NSInteger numTicks = hb_parni(2);
    [slider setNumberOfTickMarks:numTicks];

    // 2. Opcional: Posición de las marcas (abajo/derecha por defecto)
    // [slider setTickMarkPosition:NSTickMarkPositionBelow];

    // 3. ¿Quieres que el slider se "pegue" a las marcas?
    // Si se pasa un 3er parámetro .T., el slider solo se detendrá en los ticks.
    if (hb_pcount() >= 3 && !HB_ISNIL(3)) {
      [slider setAllowsTickMarkValuesOnly:hb_parl(3)];
    }

    [slider setNeedsDisplay:YES];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(SLIDER_SETFRAME) {
  NSSlider *slider = (NSSlider *)hb_parnll(1);

  if (slider) {
    // Parámetros desde Harbour:
    // 1: Puntero, 2: Top (Y), 3: Left (X), 4: Width, 5: Height
    // Nota: Invertimos 2 y 3 para seguir el orden estándar X, Y de macOS
    CGFloat x = (CGFloat)hb_parnd(3);
    CGFloat y = (CGFloat)hb_parnd(2);
    CGFloat width = (CGFloat)hb_parnd(4);
    CGFloat height = (CGFloat)hb_parnd(5);

    NSRect newFrame = NSMakeRect(x, y, width, height);

    [slider setFrame:newFrame];

    // Forzamos al sistema a redibujar el control en su nueva posición
    [slider setNeedsDisplay:YES];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(CIRCULARSLIDER) {
  NSSlider *slider = (NSSlider *)hb_parnll(1);

  if (slider) {
    // macOS moderno prefiere hacerlo directo al slider
    [slider setSliderType:NSSliderTypeCircular];

    // Si usas sistemas muy antiguos, la opción del cell (la tuya) también
    // funciona:
    // [[slider cell] setSliderType:NSSliderTypeCircular];

    // Forzamos redibujado
    [slider setNeedsDisplay:YES];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(SLIDERSETVALUE) {
  NSSlider *slider = (NSSlider *)hb_parnll(1);

  if (slider) {
    // Usamos hb_parnd para recibir decimales y setDoubleValue para el Slider
    [slider setDoubleValue:hb_parnd(2)];

    // Opcional: Forzar el redibujado
    [slider setNeedsDisplay:YES];
  }
}

//----------------------------------------------------------------------//

HB_FUNC(GETSLIDERVALUE) {
  NSSlider *slider = (NSSlider *)hb_parnll(1);

  if (slider) {
    // Usamos doubleValue para no perder decimales
    double sliderValue = [slider doubleValue];

    // Devolvemos como Double a Harbour para máxima precisión
    hb_retnd(sliderValue);
  } else {
    hb_retnd(0.0);
  }
}
