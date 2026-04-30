# TSwGet

El componente **TSwGet** es el control de entrada de datos fundamental. Soporta validación en tiempo real, máscaras (Pictures), campos de contraseña (Secure) y una integración profunda con los temas de macOS.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> GET [ <oGet> ] ;
   VAR <uValue> ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ PICTURE <cPicture> ] ;
   [ VALID <bValid> ] ;
   [ ACTION <uAction> ] ;
   [ PASSWORD ] ; // lSecure
   [ PLACEHOLDER <cPlaceholder> ] ;
   [ PROMPT <cPrompt> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `Value` | Mixto | El valor actual del campo. |
| `cPicture` | String | Máscara de entrada (Picture). |
| `bValid` | Block | Codeblock de validación. Debe devolver .T. o .F. |
| `lSecure` | Lógico | Si es .T., oculta los caracteres (tipo Password). |
| `cPrompt` | String | Etiqueta superior integrada en el control. |
| `cPromptColor`| String | Color de la etiqueta superior. |
| `nPromptSize` | Numérico | Tamaño de la fuente de la etiqueta (Default: 12). |
| `cColor` | String | Color del texto de entrada. |
| `cBackColor`| String | Color de fondo del campo. |
| `nCornerRadius`| Numérico| Radio de las esquinas (Default: 10). |
| `lReadOnly` | Lógico | Si es .T., el usuario no puede editar el campo. |
| `lInvalid` | Lógico | Estado visual de error (pone el borde en rojo). |
| `nAlignment`| Numérico | Alineación (0: Left, 1: Center, 2: Right). |

## Métodos Especiales
- **SetFocus()**: Lleva el foco al control.
- **SelectAll()**: Selecciona todo el texto.
- **GoToStart() / GoToEnd()**: Mueve el cursor al inicio o al final.

## Ejemplo de uso

```harbour
@ 100, 50 GET oGet VAR cNombre OF oWnd ;
   PICTURE "@!" ; // Todo a mayúsculas
   VALID !Empty( oGet:Value ) ;
   PLACEHOLDER "Escribe tu nombre..." ;
   PROMPT "Nombre Completo"
```
