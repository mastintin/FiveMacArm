# TSwWebView

El componente **TSwWebView** integra el motor `WKWebView` de Apple para renderizar contenido web moderno, ejecutar JavaScript y generar documentos PDF de alta fidelidad.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> WEBVIEW [ <oWeb> ] ;
   [ URL <cUrl> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ON MESSAGE <uAction> ] // bAction
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `Url` | String | La dirección URL a cargar. |
| `lScroll` | Lógico | Habilita o deshabilita el desplazamiento. |
| `bAction` | Block | Acción a ejecutar cuando se recibe un mensaje desde JavaScript (`window.webkit.messageHandlers...`). |

## Métodos Especiales
- **LoadHtml( cHtml )**: Carga contenido HTML directamente desde una cadena.
- **LoadFile( cPath )**: Carga un archivo local.
- **Eval( cScript )**: Ejecuta código JavaScript en el contexto de la página.
- **SaveToPDF( cPath )**: Exporta el contenido actual de la web a un archivo PDF.
- **GoBack() / GoForward() / Reload()**: Control de navegación estándar.

## Ejemplo de uso

```harbour
@ 0, 0 WEBVIEW oWeb URL "https://www.google.com" OF oWnd SIZE 800, 500

// Ejecutar JS desde Harbour
oWeb:Eval( "document.body.style.backgroundColor = 'red'" )
```
