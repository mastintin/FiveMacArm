# Impresión y Generación de PDF

FiveMac ofrece dos filosofías para la generación de documentos: una **nativa** orientada a la precisión de coordenadas (estilo reporteador clásico) y una **híbrida** basada en estándares web (HTML/CSS).

---

## TPrinter (Nativa Cocoa)

La clase `TPrinter` utiliza el motor de renderizado de macOS. Permite imprimir tanto en impresoras físicas como generar PDFs nativos directamente desde el sistema.

### Características Principales
- **Coordenadas Reales**: Control total sobre la posición de cada elemento.
- **Paginación Automática**: Soporta saltos de página inteligentes.
- **Exportación a PDF**: Sin herramientas externas, usando `PRNJOBRUNPDF`.

### Métodos Esenciales

| Método | Descripción |
|---------|-------------|
| `New(t, l, w, h, doc)` | Inicializa el trabajo de impresión. |
| `StartPage()` | Inicia una nueva página. |
| `Say(r, c, text, ...)` | Imprime texto en una fila/columna específica. |
| `SayImage(r, c, file, ...)` | Imprime una imagen. |
| `EndPage()` | Finaliza la página actual. |
| `EndToPDF(cFile)` | Finaliza el trabajo y lo guarda como un archivo PDF. |
| `Run()` | Envía el trabajo a la cola de impresión de macOS (Preview). |

### Ejemplo Nativo

```harbour
function ImprimirFicha()
   local oPrn := TPrinter():New( ,,,,"Informe de Ventas" )
   
   oPrn:StartPage()
   
   oPrn:SayImage( 2, 2, "logo.png", 100, 100 )
   oPrn:Say( 5,  10, "INFORME DE PRODUCTOS", CLR_BLACK, CLR_WHITE, "Helvetica-Bold", 18 )
   oPrn:Say( 7,  10, "Fecha: " + DToC( Date() ) )
   
   oPrn:EndPage()
   oPrn:EndToPDF( "informe.pdf" )
return nil
```

---

## TNicePrinter (Híbrida NiceGUI)

`TNicePrinter` es la solución moderna para informes altamente visuales. En lugar de posicionar elementos por coordenadas, se construye un documento usando **HTML/CSS**, aprovechando la potencia de los layouts modernos (Flexbox, Grid).

### Ventajas
- **Layout Responsivo**: Los informes se adaptan al contenido.
- **Estética Superior**: Uso de sombras, degradados y componentes Quasar.
- **Previsualización Web**: Se puede ver en un IFrame nativo antes de imprimir.

### Flujo de Trabajo
1. Se define una página (`NICE PRINT PAGE`).
2. Se añaden contenedores (`NICE DIV`) y textos (`NICE SAY`).
3. Se genera un HTML estático que se envía a un WebView "off-screen".
4. El WebView genera el PDF final preservando el diseño exacto.

### Ejemplo NicePrinter

```harbour
#include "Nice.ch"

function GenerarFactura()
   local oPrn, oPage, oDiv
   
   DEFINE NICE PRINTER oPrn
   
   NICE PRINT PAGE oPage OF oPrn
      
      DEFINE NICE DIV oDiv CLASS "bg-primary text-white q-pa-md" OF oPage
         NICE SAY PROMPT "FACTURA ELECTRÓNICA" SIZE "h4" BOLD OF oDiv
      END NICE DIV
      
      NICE SAY PROMPT "Cliente: Antonio Alcocer" CLASS "q-mt-md" OF oPage
      
   END NICE PRINT PAGE
   
   oPrn:NativoPreview( "factura.pdf" ) 
return nil
```

> [!IMPORTANT]
> Para la generación de PDFs estáticos mediante `TNicePrinter`, es recomendable usar concatenación manual de strings HTML (`cHtml += ...`) si se requiere máxima velocidad, o asegurarse de que los componentes no requieran una instancia de Vue activa (como es el caso de los reportes PDF generados en segundo plano).

---

## Diferencias Clave

| Característica | TPrinter (Nativo) | TNicePrinter (NiceGUI) |
|----------------|-------------------|------------------------|
| **Base** | Cocoa Core Graphics | WebKit / HTML5 |
| **Posicionamiento** | Coordenadas fijas | Flujo HTML / Flexbox |
| **Estilos** | FontName, FontSize | CSS Class, Inline Style |
| **Complejidad** | Alta (Tablas manuales) | Baja (Tablas HTML) |
| **Uso Ideal** | Listados, Etiquetas | Facturas, Dashboards |
