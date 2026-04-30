# TSwButton

El componente **TSwButton** representa un botón nativo de macOS con todas las capacidades reactivas de la arquitectura SW. Permite ejecutar tanto bloques de código de Harbour (`bAction`) como flujos de trabajo asíncronos (`bPipeline`).

## Sintaxis del Comando
El comando `@ ... BUTTON` está diseñado para ser familiar para los usuarios de Fivemac pero adaptado al motor SwiftUI.

```harbour
@ <nRow>, <nCol> BUTTON [ <oBtn> ] ;
   [ PROMPT <cPrompt> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ACTION <uAction> ] ;
   [ ID <cId> ] ;
   [ AUTORESIZE <nAutoResize> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `Caption` | String | El texto que se muestra en el botón. |
| `bAction` | Block | Codeblock que se ejecuta en Harbour al pulsar el botón. |
| `bPipeline`| Block/Hash| Flujo de trabajo asíncrono para procesos pesados. |
| `uFontSize`| Numérico | Tamaño de la fuente del botón (Default: 13). |
| `cFontStyle`| String | Estilo de fuente (".bold", ".italic", etc). |
| `cColor` | String | Color del texto. |
| `cBackColor`| String | Color de fondo del botón. |
| `cIcon` | String | Nombre del icono (SF Symbol) a mostrar. |
| `cIconColor`| String | Color del icono. |
| `nRole` | Numérico | Rol del botón (0: Normal, 1: Cancel, 2: Destructive). |
| `lRepeat` | Lógico | Si es .T., el botón repite la acción mientras se mantiene pulsado. |
| `cBorderShape`| String | Forma del borde (".rounded", ".capsule", ".rect"). |

## Eventos
- **OnAction()**: Se dispara automáticamente cuando el usuario hace clic en el botón. Si existe un `bPipeline`, se le da prioridad para ejecución asíncrona; de lo contrario, se evalúa el `bAction`.

## Ejemplo de uso

```harbour
#include "swfive.ch"

function Main()
   local oWnd, oBtn
   
   DEFINE WINDOW oWnd TITLE "Test Botón SW" SIZE 400, 300
   
   @ 50, 50 BUTTON oBtn PROMPT "Púlsame" OF oWnd ;
      ACTION msgInfo( "Has pulsado el botón nativo!" )
      
   // Cambiando propiedades en tiempo de ejecución
   oBtn:cColor := "White"
   oBtn:cBackColor := "Blue"
   oBtn:uFontSize := 16
   oBtn:cIcon := "star.fill"
   
   ACTIVATE WINDOW oWnd
return nil
```
