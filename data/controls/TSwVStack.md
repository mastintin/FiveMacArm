# TSwVStack

El **TSwVStack** (Vertical Stack) es el contenedor principal para organizar controles de arriba hacia abajo. Es el bloque fundamental de la arquitectura de layout reactivo en SW.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> VSTACK [ <oStack> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ SPACING <nSpacing> ] ;
   [ ALIGN <nAlignment> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `nSpacing` | Numérico | Espacio en puntos entre cada hijo del stack. |
| `nAlignment`| Numérico | Alineación horizontal de los hijos: <br>0: Leading (Izquierda) <br>1: Center (Centro) <br>2: Trailing (Derecha) |

## Comportamiento
Los controles añadidos a un **VStack** ignoran sus propias coordenadas `@ nRow, nCol`. Su posición vertical viene determinada por el orden en que fueron creados dentro del stack.

## Ejemplo de uso

```harbour
@ 20, 20 VSTACK oVStack OF oWnd SIZE 300, 400
   oVStack:nSpacing := 15
   oVStack:nAlignment := 1 // Centrado horizontal
   
   @ 0, 0 LABEL "Usuario" OF oVStack
   @ 0, 0 GET cUser OF oVStack
   
   @ 0, 0 BUTTON "Entrar" OF oVStack ;
      ACTION Login()
ACTIVATE VSTACK oVStack
```
