# Multimedia Avanzada

FiveMac aprovecha los potentes frameworks de macOS (PDFKit y AVFoundation) para ofrecer una experiencia multimedia fluida y nativa.

---

## TPdfView (Visor de PDF)

Este control integra el motor oficial de macOS para mostrar documentos PDF con soporte para zoom, navegación y selección de texto.

```harbour
@ 0, 0 PDFVIEW oPdf FILENAME "manual.pdf" OF oWnd SIZE 600, 800
```
*   **SetPdf( cFile )**: Cambia el documento mostrado dinámicamente.
*   **ZoomIn() / ZoomOut()**: Controla el nivel de aumento.
*   **SetAutoScale( .T. )**: Ajusta automáticamente el PDF al tamaño del control.
*   **GoNext() / GoPrevious()**: Salta entre páginas.
*   **GoTop() / GoBottom()**: Navegación rápida al inicio o fin del archivo.

---

## TMovie (Reproductor de Vídeo)

Permite embeber un reproductor de vídeo completo con controles de transporte dentro de cualquier ventana.

```harbour
@ 20, 20 MOVIE oVideo FILENAME "promo.mp4" OF oWnd SIZE 480, 270
```
*   **Play() / Pause()**: Controla el flujo de reproducción.
*   **GoTime( nSeconds )**: Salta a un punto específico del vídeo.
*   **ControlStyle( nStyle )**: Cambia la apariencia de los mandos de control:
    - `1`: Estilo por defecto.
    - `2`: Controles flotantes (estilo QuickTime).
    - `3`: Estilo mínimo.
    - `4`: Sin controles (solo vídeo).

---

## TSound (Efectos de Sonido)

Diseñado para ráfagas cortas de audio o sonidos simples que no requieren la complejidad de un reproductor completo.

```harbour
oSound := TSound():New( "alert.wav" )
oSound:Play()
```
*   **Volumen( n )**: Ajusta el volumen del sonido (0-100).
*   **SetLoop( .T. )**: Repite el sonido indefinidamente.
*   **Stop() / Pause() / Resume()**: Control de estado básico.

---

## TMusic (Integración con Apple Music)

A diferencia de `TNativeAudio`, esta clase actúa como un mando a distancia para la aplicación **Música** (iTunes) de macOS.

```harbour
oiTunes := TMusic():New()
oiTunes:Run() // Abre la app Música si no está abierta
oiTunes:Play()
MsgInfo( "Escuchando: " + oiTunes:SongName() )
```
*   **NextTrack() / PreviousTrack()**: Salta de canción en la lista oficial.
*   **GetTracks( "Library" )**: Retorna un array con todas las canciones de la biblioteca de usuario.
*   **Quit()**: Cierra la aplicación Música.

---

> [!IMPORTANT]
> Para la reproducción de audio profesional e independiente sin necesidad de que la aplicación "Música" esté abierta, se recomienda encarecidamente el uso de **TNativeAudio** (documentado en el capítulo 4).
