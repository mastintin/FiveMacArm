# TSwZStack

El **TSwZStack** (Depth Stack) permite superponer controles uno encima de otro en el eje Z. Es ideal para crear fondos personalizados, añadir etiquetas sobre imágenes o crear interfaces con capas complejas.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> ZSTACK [ <oStack> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ALIGN <nAlignment> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `nAlignment`| Numérico | Alineación combinada de los elementos superpuestos (Centro por defecto). |
| `cColor` | String | Color de fondo del contenedor. |
| `nCorner` | Numérico | Radio de las esquinas del contenedor. |

## Comportamiento
Los controles se apilan en el orden en que se crean: el primer control creado queda al fondo y el último encima de todos.

## Ejemplo de uso

```harbour
@ 20, 20 ZSTACK oZStack OF oWnd SIZE 200, 200
   @ 0, 0 IMAGE "user_avatar" OF oZStack SIZE 200, 200
   
   // Pone un círculo de estado en la esquina inferior derecha
   @ 0, 0 IMAGE "circle.fill" OF oZStack SIZE 20, 20 ;
      COLOR "Green"
ACTIVATE ZSTACK oZStack
```
