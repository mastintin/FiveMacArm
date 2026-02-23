# Controles Básicos

Esta sección cubrirá los controles fundamentales en FiveMac utilizados en la mayoría de diálogos y ventanas.

# Controles Básicos Nativo

FiveMac se basa en comandos de Harbour para crear interfaces Cocoa nativas. A diferencia de NiceGUI, aquí se utilizan coordenadas (fila, columna) o píxeles para posicionar los elementos.

---

## Ventanas y Diálogos

### TWindow
La ventana principal de la aplicación.
```harbour
DEFINE WINDOW oWnd TITLE "Mi App" SIZE 800, 600 [ FLIPPED ]
    // Controles aquí
ACTIVATE WINDOW oWnd [ CENTERED ]
```
*   **FLIPPED**: Invierte el eje Y para que (0,0) sea la esquina superior izquierda (estándar Windows/Web).

### TDialog
Ventana secundaria, ideal para formularios modales.
```harbour
DEFINE DIALOG oDlg TITLE "Aviso" SIZE 300, 200 FLIPPED
    // Controles aquí
ACTIVATE DIALOG oDlg CENTERED
```

---

## Controles de Texto y Salida

### TSay (Etiquetas)
Muestra texto estático.
```harbour
@ 20, 20 SAY "Nombre de usuario:" OF oWnd SIZE 150, 20
```

---

## Controles de Entrada (Inputs)

### TGet (Entradas de texto)
El control principal para captura de datos. Soporta **PICTURES** para formateo.
```harbour
@ 50, 20 GET oGet VAR cNombre OF oWnd SIZE 200, 25 PICTURE "@!"
@ 80, 20 GET oGet2 VAR nSueldo OF oWnd PICTURE "99,999.99"
```

### TMultiGet (Memo)
Para textos largos de varias líneas.
```harbour
@ 120, 20 GET oMemo VAR cDesc OF oWnd MULTILINE SIZE 300, 100
```

---

## Botones

### TButton
Botón estándar de macOS.
```harbour
@ 250, 100 BUTTON "Aceptar" ACTION MsgInfo( "Hola" ) OF oWnd SIZE 100, 30
```

### TBtnBmp
Botón con imagen gráfica.
```harbour
@ 250, 210 BTNBMP FILENAME "save.png" ACTION oWnd:End() OF oWnd
```

---

## Otros Controles Fundamentales

### TCheckBox
Interruptor lógico (.T./.F.).
```harbour
@ 180, 20 CHECKBOX lActivo PROMPT "Suscrito al boletín" OF oWnd [ SWITCH ]
```
*   **SWITCH**: Si se añade, el checkbox tendrá aspecto de interruptor deslizante.

### TRadio (Radio Menus)
Selección única entre varias opciones.
```harbour
@ 210, 20 RADIO oRad VAR nOp ITEMS {"Opción A", "Opción B"} OF oWnd
```

### TComboBox
Lista desplegable.
```harbour
@ 250, 20 COMBOBOX oCbx VAR cProd ITEMS {"A", "B", "C"} OF oWnd
```
