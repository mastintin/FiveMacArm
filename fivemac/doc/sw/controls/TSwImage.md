# TSwImage

El componente **TSwImage** es el control versátil para mostrar contenido visual, ya sea desde archivos locales, URLs remotas o iconos de sistema (SF Symbols).

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> IMAGE [ <oImg> ] ;
   [ <cResource> ] ; // Puede ser Símbolo, Archivo o URL
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ MODE <nMode> ] ;
   [ COLOR <nColor> ] ;
   [ ACTION <uAction> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `cSymbol` | String | Nombre de un SF Symbol de sistema. |
| `cFile` | String | Ruta a un archivo de imagen local. |
| `cUrl` | String | URL de una imagen remota. |
| `nMode` | Numérico | Modo de visualización (Fit, Fill, etc). |
| `nColor` | Numérico | Color de tintado para símbolos de sistema. |
| `nScaling` | Numérico | Factor de escala de la imagen. |
| `nFrame` | Numérico | Tipo de marco o borde. |
| `bAction` | Block | Acción al hacer clic en la imagen. |
| `bOnDrop` | Block | Acción al arrastrar y soltar archivos sobre la imagen. |

## Métodos Especiales
- **SetQr(cText, nScale)**: Genera y muestra automáticamente un código QR con el texto indicado.

## Ejemplo de uso

```harbour
// Imagen desde SF Symbol
@ 50, 50 IMAGE oImg "person.circle.fill" OF oWnd SIZE 64, 64
oImg:nColor := CLR_BLUE

// Imagen desde URL
@ 150, 50 IMAGE oImgUrl "https://miweb.com/foto.jpg" OF oWnd
```
