# Funciones del Sistema y macOS Interop

FiveMac proporciona una amplia gama de funciones para interactuar con el sistema operativo macOS, gestionar rutas de archivos, mostrar diálogos estándar y controlar el comportamiento de la aplicación en el entorno Apple.

---

## Gestión de Rutas (Paths)

Estas funciones permiten localizar archivos dentro y fuera del paquete de la aplicación (`.app`).

- **`AppPath()`**: Devuelve la ruta completa del bundle de la aplicación.
- **`ResPath([cFile])`**: Devuelve la ruta a la carpeta `Contents/Resources`. Si se pasa un nombre de archivo, busca su existencia (comprobando también en la subcarpeta `bitmaps/`) y devuelve la ruta completa.
- **`HomePath()`**: Devuelve el directorio personal del usuario actual (`~`).
- **`UserPath()`**: Alias de la carpeta de usuario.
- **`LibraryPath()`**: Devuelve el camino a `~/Library`.
- **`CurrentPath()` / `SetCurrentPath(cPath)`**: Obtiene o establece el directorio de trabajo actual.
- **`FileNoPath(cFullScript)`**: Extrae solo el nombre del archivo de una ruta completa.

---

## Alertas y Mensajes

Funciones para mostrar cuadros de diálogo estándar de macOS basados en `NSAlert`.

- **`MsgInfo(uMsg, [cTitle])`**: Muestra un mensaje informativo.
- **`MsgAlert(uMsg, [cTitle])`**: Muestra un mensaje de advertencia.
- **`MsgStop(uMsg)`**: Muestra un mensaje de error crítico.
- **`MsgYesNo(cMsg, [cTitle])`**: Pregunta de confirmación. Retorna `.T.` si se pulsa "Yes" y `.F.` si se pulsa "No".
- **`MsgWait(cMsg, [cTitle], [nSeconds])`**: Muestra un mensaje que se cierra automáticamente tras los segundos indicados.
- **`MsgBadge(cText)`**: Establece un texto o número en el icono de la aplicación en el Dock (por ejemplo, para indicar notificaciones pendientes).
- **`UserNotification(cTitle, cInfo)`**: Envía una notificación estándar al Centro de Notificaciones de macOS.

---

## Diálogos Estándar

- **`ChooseFile([cTitle], [cExts])`**: Abre el selector de archivos nativo. Se pueden filtrar extensiones separadas por comas (ej: `"png,jpg"`).
- **`ChooseFolder([cTitle])`**: Abre el selector de directorios nativo.
- **`SaveFile([cTitle], [cDefaultName])`**: Abre el diálogo nativo para guardar archivos.
- **`ChooseColor([nDefaultColor])`**: Abre el selector de colores de macOS. Retorna el color en formato numérico RGB.
- **`ChooseFont()`**: Abre el panel de fuentes nativo. Retorna el nombre de la fuente seleccionada.

---

## Interoperabilidad y Ejecución

- **`FM_OpenFile(cFile, [cAppName])`**: Abre cualquier archivo con su aplicación predeterminada o con la app indicada.
- **`MacExec(cApp, [cArgs])`**: Lanza una aplicación de macOS (por nombre o identificador de bundle) con argumentos opcionales.
- **`MoveToTrash(cPath)`**: Mueve de forma segura un archivo o carpeta a la Papelera.
- **`TaskExec(cCommand, aArgs)`**: Ejecuta un comando de la terminal de forma asíncrona y devuelve la salida (`stdout/stderr`) como cadena.
- **`CopyPasteboardString(cText)`**: Copia un texto al Portapapeles (Clipboard).
- **`PastePasteboardString()`**: Recupera el texto actual del Portapapeles.

---

## Información del Entorno

- **`ScreenWidth()` / `ScreenHeight()`**: Dimensiones totales de la pantalla principal.
- **`ScreenVisibleWidth()` / `ScreenVisibleHeight()`**: Dimensiones de la pantalla excluyendo el Dock y la barra de menús.
- **`GetDockPosition()`**: Retorna `"bottom"`, `"left"` o `"right"` según la ubicación del Dock.
- **`IsDockHidden()`**: Retorna `.T.` si el Dock está configurado para ocultarse automáticamente.
- **`MsgAbout(cVer, cName, cCopyright)`**: Muestra el panel estándar "Acerca de..." de la aplicación con los datos proporcionados.
