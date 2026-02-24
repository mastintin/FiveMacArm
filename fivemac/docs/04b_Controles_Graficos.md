# Controles Gráficos e Interactivos

Esta sección detalla los controles que permiten una interacción rica y una visualización de datos dinámica en FiveMac.

---

## TSlider (Deslizadores)
Permite al usuario seleccionar un valor en un rango moviendo un indicador.

```harbour
@ 20, 20 SLIDER oSld VAR nVal OF oWnd SIZE 200, 20 ;
   RANGE 0, 100 ;
   ON CHANGE MsgInfo( "Valor: " + Str( nVal ) )
```
*   **SetMinMaxValue( nMin, nMax )**: Define los límites del control.
*   **SetTickMarks( nTicks )**: Añade marcas visuales de graduación.
*   **SetCircular()**: Cambia el aspecto a un dial circular (volumen, etc).
*   **GetValue() / SetValue( n )**: Acceso directo al valor numérico.

---

## TProgress (Barras de Progreso)
Visualización de avance de tareas o procesos.

```harbour
@ 50, 20 PROGRESS oPrg OF oWnd SIZE 200, 20 ;
   POSITION 30
```
*   **SetRange( nMin, nMax )**: Define los límites de la barra.
*   **Update( nPos )**: Actualiza la posición visual.
*   **SetIndeterminate( .T. )**: Cambia a modo "buscando" (animación infinita).
*   **StartAnime() / StopAnime()**: Controla la animación en modo indeterminado.

---

## TDatePicker (Selector de Fecha)
Entrada nativa de fechas con validación y diversos estilos.

```harbour
@ 80, 20 DATEPICKER oDate OF oWnd SIZE 120, 25
```
*   **GetDate()**: Retorna un objeto Date de Harbour.
*   **SetDate( dDate )**: Asigna la fecha actual.
*   **SetStyle( n )**: 
    - `0`: Texto y Stepper (Default).
    - `1`: Calendario gráfico.
    - `2`: Solo Texto.
*   **SetMinDate( d ) / SetMaxDate( d )**: Restringe el rango seleccionable.

---

## TColorWell (Selector de Color)
El control estándar de macOS para elegir colores.

```harbour
@ 110, 20 COLORWELL oClr OF oWnd SIZE 50, 30 ;
   COLOR CLR_RED ;
   ON CHANGE MsgInfo( "Color elegido: " + Str( oClr:GetColor() ) )
```

---

## TImage (Imágenes y QR)
Visualización avanzada de gráficos y generación dinámica.

```harbour
@ 150, 20 IMAGE oImg FILENAME "logo.png" OF oWnd SIZE 200, 200
```
*   **SetScaling( n )**: Define cómo se ajusta la imagen al marco (0: Proporcional, 1: Estirar, 2: Sin escalado).
*   **SetQr( cTexto, nScale )**: Genera y muestra un código QR nativamente.
*   **Save( cFile, w, h )**: Redimensiona y guarda la imagen actual a disco.

---

## TSegment (Controles Segmentados)
Muy útiles para filtros rápidos o barras de herramientas compactas.

```harbour
@ 360, 20 SEGMENT oSeg OF oWnd SIZE 300, 40 ;
   ITEMS {"Hoy", "Semana", "Mes"} ;
   ACTION { | nIndex | MiFiltro( nIndex ) }
```
*   **SelectedItem()**: Retorna el índice (base 1) del segmento pulsado.
*   **SetImg( cFile, nIdx )**: Permite poner iconos en segmentos específicos.

---

## TWebView (Navegador Embebido)
Motor WebKit completo integrado en la aplicación.

```harbour
@ 0, 0 WEBVIEW oWeb OF oWnd SIZE 800, 600 ;
   URL "https://www.google.com"
```
*   **SetHtml( cHMTL )**: Carga código HTML directamente desde una variable.
*   **ScriptCallMethod( cFunc )**: Invoca una función JavaScript dentro de la página.
*   **bOnMessage**: Codeblock para recibir datos desde JavaScript hacia Harbour.
*   **SaveToPDF( cPath )**: Exporta el contenido web actual a un archivo PDF.

---

> [!TIP]
> Consulta los ejemplos `testslid.prg`, `testprg.prg`, y `testweb.prg` en la carpeta de `samples` para ver implementaciones funcionales completas.
