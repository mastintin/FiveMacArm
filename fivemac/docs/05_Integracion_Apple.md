# Integración Apple

FiveMac ofrece acceso directo a frameworks nativos de macOS:

## MusicKit
Integración completa con el reproductor de Apple Music mediante puentes híbridos Swift/Objective-C/AppleScript.
- Sincronización de metadatos de las canciones (Título, Artista, Portada).
- Accesos a estado de reproducción y acciones de control de la app (Pause, Play).

![Mando a distancia Apple Music (NiceGUI)](img/cap6.png)

## MapKit (`TNativeMap`)
Controles de mapas nativos soportando vistas híbridas, geocodificación (`MKMAPGOTOLOCATION`) y renderizado de rutas paso a paso con Puntos de Interés (POI).

## Visión OCR
Extracción rápida de texto de imágenes mediante los algoritmos de redes neuronales nativos de `Vision.framework`.

## Filtros de Imagen Avanzados (`TCIFilter` y Core Image)
Capacidad de apilar recursivamente efectos no destructivos (como Tonos Sepia, Cómic, Brillo, Contraste) controlados por un modelo 64-bit optimizado.
