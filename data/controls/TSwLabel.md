# TSwLabel

El componente **TSwLabel** es el control básico para mostrar texto estático o dinámico en la interfaz. A diferencia de las etiquetas clásicas, soporta alineaciones avanzadas, sombreados, iconos integrados y efectos de vibrancia nativos de macOS.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> LABEL [ <oLabel> ] ;
   [ <cText> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ID <cId> ] ;
   [ AUTORESIZE <nAutoResize> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `Caption` | String | El texto a mostrar. |
| `uFontSize`| Numérico/String | Tamaño de la fuente (Default: 13). Acepta nombres de sistema como ".title", ".headline". |
| `cFontStyle`| String | Estilo de fuente (".bold", ".italic", ".monospaced"). |
| `nAlignment`| Numérico | Alineación del texto (0: Lead, 1: Center, 2: Trail). |
| `cColor` | String | Color del texto (Hex o nombres estándar). |
| `cBackColor`| String | Color de fondo de la etiqueta. |
| `lScroll` | Lógico | Si es .T., el texto se coloca dentro de un ScrollView si excede el tamaño. |
| `nShadow` | Numérico | Radio de sombra del contenedor. |
| `nTextShadow`| Numérico | Radio de sombra aplicado directamente al texto. |
| `cVibrance` | String | Efecto de vibrancia de macOS (".titleBar", ".menu", ".popover"). |
| `cIcon` | String | Nombre de un SF Symbol para acompañar al texto. |
| `cIconColor`| String | Color del icono. |

## Ejemplo de uso

```harbour
@ 20, 20 LABEL oLabel "Título Principal" OF oWnd
oLabel:uFontSize := ".title"
oLabel:cFontStyle := ".bold"
oLabel:cColor := "SteelBlue"
oLabel:nAlignment := 1 // Center
```
