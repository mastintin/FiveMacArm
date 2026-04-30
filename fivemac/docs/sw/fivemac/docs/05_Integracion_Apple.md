# Integración Apple

FiveMac ofrece acceso directo a frameworks nativos de macOS:

## MusicKit
Integración completa con el reproductor de Apple Music mediante puentes híbridos Swift/Objective-C/AppleScript.
![Mando a distancia Apple Music (NiceGUI)](img/cap6.png)

> [!IMPORTANT]
> **Arquitectura de Tres Vías**: Este ejemplo (`TestMusicNice.prg`) es la demostración definitiva de la potencia de FiveMac al combinar tres tecnologías en tiempo real:
> 1.  **Cocoa Nativo**: Gestiona la ventana base y el contenedor Webview.
> 2.  **Swift**: Realiza el enlace de bajo nivel con **MusicKit** para el control de reproducción.
> 3.  **NiceGUI**: Proporciona la capa visual reactiva y moderna del mando.

## MapKit (`TNativeMap`)
Controles de mapas nativos soportando vistas híbridas, geocodificación (`MKMAPGOTOLOCATION`) y renderizado de rutas paso a paso con Puntos de Interés (POI).

## Visión OCR
Extracción rápida de texto de imágenes mediante los algoritmos de redes neuronales nativos de `Vision.framework`.

## Filtros de Imagen Avanzados (`TCIFilter` y Core Image)
Capacidad de apilar recursivamente efectos no destructivos (como Tonos Sepia, Cómic, Brillo, Contraste) controlados por un modelo 64-bit optimizado.

### Generación de Códigos QR
FiveMac aprovecha el filtro nativo `CIQRCodeGenerator` para generar códigos QR de alta calidad directamente desde el código Harbour, sin dependencias externas.

**Sintaxis:**
```harbour
// Usando el objeto TImage o TSimage
oImg:SetQr( "https://www.fivemac.com", 10.0 )

// Usando la función directa (retorna un handle NSImage)
hImage := SIMAGEGENQR( "Contenido del QR", 15.0 )
```
*El parámetro de escala (segundo argumento) determina el tamaño final del QR, ya que por defecto los filtros de Core Image generan 1 punto por módulo.*
