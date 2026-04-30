# TSwCard

El componente **TSwCard** es un contenedor avanzado diseñado para agrupar información en tarjetas visualmente atractivas. Se inspira en el control `TCard` nativo de Fivemac pero aprovecha la potencia de SwiftUI para ofrecer sombras, bordes redondeados y layouts reactivos de forma automática.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> CARD [ <oCard> ] ;
   [ TITLE <cTitle> ] ;
   [ SYMBOL <cSymbol> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `cTitle` | String | El título que aparece en la cabecera de la tarjeta. |
| `cIcon` | String | Nombre del SF Symbol que acompaña al título. |
| `nShadow` | Numérico | Radio de la sombra proyectada (Defecto: 5). |
| `nCorner` | Numérico | Radio de redondeo de las esquinas (Defecto: 12). |

## Comportamiento
Al heredar de **TSwVStack**, todo lo que se defina dentro de la tarjeta se organizará verticalmente. La tarjeta incluye un padding interno y una cabecera estilizada de forma automática.

## Ejemplo de uso

```harbour
@ 20, 20 CARD oCard TITLE "Perfil de Usuario" SYMBOL "person.crop.circle" ;
   OF oWnd SIZE 300, 200

   @ 0, 0 LABEL "Nombre: Manuel Alvarez" OF oCard
   @ 0, 0 LABEL "Cargo: Desarrollador" OF oCard
   
   @ 0, 0 BUTTON "Enviar Mensaje" OF oCard ;
      ACTION MsgInfo( "Hola!" )
```
