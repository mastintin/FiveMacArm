# Controles Avanzados

Esta sección documenta los controles de diseño de interfaz de usuario más potentes y modernos disponibles en FiveMac.

# Controles Avanzados Nativo

Esta sección documenta los controles de diseño de interfaz de usuario más potentes y modernos disponibles en FiveMac.

---

## TSplitBox (Divisores dinámicos)
El control `TSplitBox` es la implementación moderna (basada en `NSSplitView`) que permite dividir una ventana en varios paneles redimensionables.

```harbour
@ 20, 20 SPLITBOX oSplit OF oWnd SIZE 400, 300 VERTICAL VIEWS 2
@ 0, 0 SCINTILLA oEditor OF oSplit:aViews[1] SIZE 200, 300 
@ 0, 0 PANEL oPanel OF oSplit:aViews[2] SIZE 200, 300
```
*   **VIEWS n**: Crea automáticamente `n` contenedores (`aViews`) listos para albergar otros controles.

---

## TWBrowse (Rejillas y Listas)
El control `BROWSE` es fundamental para mostrar datos tabulares (Dbf, Arrays o SQL).

```harbour
@ 20, 20 BROWSE oBrw OF oWnd SIZE 400, 300 ;
   HEADERS "Código", "Descripción", "Precio" ;
   COLSIZES 80, 200, 100
```
*   **SetArray( aData )**: Para visualizar datos en memoria.
*   **ALIAS "dbf"**: Para visualización directa de bases de datos.

---

## TOutline (Vistas de Árbol)
Permite crear jerarquías de datos desplegables (TreeViews).

```harbour
DEFINE ROOTNODE oRoot
    DEFINE NODE oNode1 PROMPT "Carpeta A" OF oRoot GROUP
    DEFINE NODE oNode2 PROMPT "Archivo 1" OF oNode1
ACTIVATE ROOTNODE oRoot

@ 48, 20 OUTLINE oTree SIZE 300, 400 OF oWnd NODE oRoot
```
*   **GROUP**: Define si el nodo puede contener hijos.

---

## TTabs / TFolder (Pestañas)
Organiza la interfaz en múltiples páginas solapadas.

```harbour
@ 20, 20 TABS oTabs PROMPTS {"General", "Avanzado"} OF oWnd SIZE 400, 300
// Los controles se añaden al contenedor de cada pestaña:
@ 50, 20 SAY "ID:" OF oTabs:aControls[1]
```

---

## TMultiView (Navegación Lateral)
Implementa un patrón de diseño moderno con un selector lateral para cambiar entre vistas.

```harbour
DEFINE MULTIVIEW oMulti OF oWnd RESIZED
    @ 0, 0 MVIEW PROMPT "Dashboard" TITLE "Panel Principal" OF oMulti IMAGE "home"
    @ 0, 0 MVIEW PROMPT "Config" TITLE "Ajustes de Sistema" OF oMulti IMAGE "gear"
```

---

---

## TNativeAudio (Audio y Multimedia)
Integra el motor **AVFoundation** de Apple para reproducción de audio independiente, extracción de metadatos y arte de disco. Ofrece un control total sobre el playback mediante eventos nativos y codeblocks.

```harbour
oMusic := TNativeAudio():New( "song.mp3" )
oMusic:Play()

// Observador para actualizar la UI cada 0.5s de forma nativa
oMusic:SetObserver( { | o | MyUpdateFunc( o ) } )
```
*   **GetMetadata()**: Recupera Título, Artista y Álbum de forma automática.
*   **GetArtwork()**: Obtiene la imagen de la carátula vinculada al archivo.
*   **SetObserver( bAction )**: Ejecuta un codeblock periódicamente (cada 0.5s).
*   **bOnTrackEnd**: Codeblock que se ejecuta automáticamente cuando finaliza la reproducción.

---

## TScintilla (Editor de Código)
FiveMac integra el potente motor **Scintilla** para edición de texto con resaltado de sintaxis, numeración de líneas y autocompletado.

```harbour
@ 0, 0 SCINTILLA oEd SIZE 600, 400 OF oWnd
oEd:SetText( cSource )
oEd:SetLexer( SCLEX_HARBOUR ) // Ejemplo para Harbour
```

---

> [!TIP]
> Puedes encontrar ejemplos completos de estos controles en la carpeta `nativo/samples/`:
> - `testbrw.prg` (Browse)
> - `testoutline.prg` (Tree)
> - `testtab.prg` (Pestañas)
> - `testsplitbox.prg` (Splitters)
> - `testmultiview.prg` (MultiView)
> - `testscintilla.prg` (Editor de código)
> - `MusicPlayer.prg` (Reproductor de audio avanzado)
