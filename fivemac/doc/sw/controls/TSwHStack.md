# TSwHStack

El **TSwHStack** (Horizontal Stack) es el contenedor principal para organizar controles de izquierda a derecha. Es esencial para crear barras de herramientas personalizadas, filas de botones o cualquier disposición horizontal reactiva.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> HSTACK [ <oStack> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ SPACING <nSpacing> ] ;
   [ ALIGN <nAlignment> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `nSpacing` | Numérico | Espacio en puntos entre cada hijo del stack. |
| `nAlignment`| Numérico | Alineación vertical de los hijos: <br>0: Top <br>1: Center (Centro) <br>2: Bottom |

## Comportamiento
Los controles añadidos a un **HStack** ignoran sus propias coordenadas `@ nRow, nCol`. Su posición horizontal viene determinada por el orden en que fueron creados dentro del stack.

## Ejemplo de uso

```harbour
@ 20, 20 HSTACK oHStack OF oWnd SIZE 400, 50
   oHStack:nSpacing := 10
   
   @ 0, 0 IMAGE "person.fill" OF oHStack SIZE 32, 32
   @ 0, 0 LABEL "Nombre del Usuario" OF oHStack
   
   @ 0, 0 BUTTON "Editar" OF oHStack
ACTIVATE HSTACK oHStack
```
