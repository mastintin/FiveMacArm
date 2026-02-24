# Utilidades del Sistema

FiveMac ofrece acceso directo a los servicios esenciales de macOS de forma sencilla y orientada a objetos.

---

## TClipboard (Portapapeles)

Permite intercambiar texto e imágenes con otras aplicaciones.

```harbour
oClip := TClipboard():New()
oClip:SetText( "Hola desde Harbour" )

// Recuperar texto
cText := oClip:GetText()
```
*   **SetText( c ) / GetText()**: Gestión de texto plano.
*   **Clear()**: Vacía el contenido actual.
*   **ScreenShot()**: Captura la pantalla actual y la coloca en el portapapeles.
*   **SetPNGImage( hImg )**: Coloca un objeto de imagen nativo en el clipboard.

---

## TTimer (Temporizadores)

Ejecución periódica de tareas en segundo plano.

```harbour
DEFINE TIMER oTimer INTERVAL 1000 ;
   ACTION MyTask() OF oWnd

oTimer:Activate()
```
*   **Interval**: Tiempo en milisegundos.
*   **Activate() / DeActivate()**: Controla el inicio y fin del temporizador.
*   **End()**: Libera los recursos del sistema asociados.

---

## TNotification (Notificaciones locales)

Envío de avisos al Centro de Notificaciones de macOS.

```harbour
oNoti := TNotification():New( oWnd, "Copia de Seguridad", "Proceso finalizado con éxito" )
oNoti:Display()
```
*   **Display()**: Muestra la notificación inmediatamente.
*   **SetSubTitle( c )**: Añade una segunda línea de texto informativa.
*   **SetInfo( c )**: Añade una descripción larga.
*   **Schedule( nSecs )**: Programa la aparición de la notificación tras un retardo.

---

## TMail (Envío de Correos)

Interfaz con la aplicación Mail.app nativa.

```harbour
oMail := TMail():New( "cliente@ejemplo.com", "Asunto", "cuerpo del mensaje" )
oMail:AddAttach( "factura.pdf" )
oMail:Send()
```
*   **AddAttach( cFile )**: Adjunta un archivo local al correo.
*   **Send()**: Abre la ventana de composición de Mail.app con los datos cargados.

---

## Colores y Fuentes

FiveMac usa constantes y funciones heredadas de FiveWin pero adaptadas al motor Cocoa.

### Colores
Los colores se manejan habitualmente mediante valores numéricos (RGB) o constantes:
*   `CLR_HRED`, `CLR_HBLUE`, `CLR_HGREEN`, `CLR_HGRAY`.
*   Para transparencia: `SetColor( nClr, nAlpha )`.

### Fuentes (TFont)
```harbour
DEFINE FONT oFont NAME "Inter" SIZE 14 BOLD
oControl:SetFont( oFont )
```
*   Las fuentes se buscan automáticamente en el sistema de macOS.
*   Es recomendable usar nombres estándar como "System", "Helvetica" o "Inter".

---

> [!TIP]
> Para depuración rápida, puedes usar `MsgInfo( val )`, `MsgAlert( val )` o `MsgRun( "Esperando...", {|| MiProceso() } )`, que son diálogos nativos ya integrados en la librería.
