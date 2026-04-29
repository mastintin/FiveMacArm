# SW: La Evolución de Fivemac hacia el futuro (SwiftUI)

## 1. El Origen: Modernización y ARM64
El desarrollo de **SW** nace de la necesidad de modernizar el framework **Fivemac** original. El primer paso crítico fue adaptar el núcleo a la nueva arquitectura **Apple Silicon (ARM64)**, lo que implicó una reestructuración completa de las llamadas de Harbour y la puesta a punto de los controles existentes, eliminando APIs obsoletas (*deprecated*) y optimizando el motor nativo para los estándares actuales de macOS.

## 2. El Techo de Objective-C
A medida que el framework recuperaba estabilidad, nos encontramos con una realidad tecnológica: **Objective-C** está estancado. Las innovaciones visuales y de rendimiento de Apple se centran exclusivamente en **Swift** y **SwiftUI**. Seguir construyendo sobre Cocoa clásico era limitar el potencial del framework.

## 3. La Evolución del Puente (Bridge)
La transición no fue inmediata. Experimentamos con varios enfoques:
- **Puente Clásico**: Inicialmente, usamos archivos Objective-C como intermediarios ("wrappers") para que Harbour pudiera hablar con Swift. Era funcional pero pesado de mantener.
- **Macros de Swift**: Descubrimos que podíamos prescindir de esos archivos intermediarios aprovechando la potencia de las **Macros de Swift**. Esto nos permitió incrustar controles Swift dentro de vistas Objective-C clásicas de forma más directa.

## 4. El Salto Conceptual: "La Isla" (SW)
Llegados a este punto, surgió la pregunta definitiva: **¿Por qué seguir forzando a Swift a vivir dentro de vistas clásicas y complejas funciones de comunicación nativa?**

De esta reflexión nació la idea de **SW (La Isla)**. Decidimos aislar ambos mundos:
- **Harbour** gestiona la lógica de negocio y el estado de la aplicación.
- **Swift/SwiftUI** gestiona la interfaz de usuario de forma moderna y reactiva.
- **Comunicación**: Se eliminó la maraña de funciones específicas por una interfaz mínima de comunicación. Ambos mundos se hablan mediante mensajes **JSON** a través de un número limitado de funciones Swift que gestionan la sincronización de estado.

Este enfoque permite que Harbour viva en su mundo de datos y Swift en su mundo visual, comunicándose solo cuando es estrictamente necesario para actualizar el estado o notificar acciones del usuario.

---

## 5. Catálogo de Controles y Propiedades (SW)

A continuación, enumeramos los componentes actuales de la arquitectura SW, su sintaxis en Harbour y las propiedades que pueden gestionarse de forma reactiva.

## 5. Arquitectura de Layout: ¿Posicional o Contenido?

Una de las innovaciones más potentes de **SW** es la capacidad de mezclar dos filosofías de diseño en una misma interfaz. El framework distingue automáticamente entre dos tipos de comportamiento según su contenedor:

### 5.1 Controles Posicionales (Coordenadas Absolutas)
Son aquellos que se definen directamente sobre la ventana principal o un panel con dimensiones fijas.
- **Definición**: `@ nRow, nCol ... OF oWnd`
- **Comportamiento**: Se sitúan exactamente en las coordenadas indicadas. Son ideales para layouts tradicionales o para posicionar "Stacks" enteros como puntos de partida.

### 5.2 Controles Contenidos (Layout Fluido en Stacks)
Son aquellos que residen dentro de un contenedor de tipo Stack (`VStack`, `HStack`, `ZStack`).
- **Definición**: `@ 0, 0 ... OF oStack`
- **Comportamiento**: Las coordenadas `@ nRow, nCol` son ignoradas. La posición del control la decide el Stack padre basándose en el orden de creación, el `nSpacing` y el `nAlignment`. Esto permite que la interfaz sea dinámica, redimensionable y mucho más fácil de mantener.

---

## 6. Catálogo de Controles de Layout (Stacks)

Los contenedores de layout son los cimientos de "La Isla". A diferencia del modelo clásico de coordenadas absolutas, los Stacks utilizan un motor de diseño fluido y reactivo.

### 5.1 TSwVStack (Vertical Stack)
Organiza a sus hijos de arriba hacia abajo.

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `nSpacing` | Numérico | Espaciado entre elementos en puntos. |
| `nAlignment`| Numérico | Alineación horizontal (0: Lead, 1: Center, 2: Trail). |

**Sintaxis Harbour:**
```harbour
@ nRow, nCol VSTACK oVStack OF oWnd SIZE nW, nH
   oVStack:nSpacing := 10
   oVStack:nAlignment := 1 // Centrado
   
   @ 0, 0 LABEL "Elemento 1" OF oVStack
   @ 0, 0 LABEL "Elemento 2" OF oVStack
ACTIVATE VSTACK oVStack
```

### 5.2 TSwHStack (Horizontal Stack)
Organiza a sus hijos de izquierda a derecha.

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `nSpacing` | Numérico | Espaciado entre elementos en puntos. |
| `nAlignment`| Numérico | Alineación vertical (0: Top, 1: Center, 2: Bottom). |

**Sintaxis Harbour:**
```harbour
@ nRow, nCol HSTACK oHStack OF oWnd
   oHStack:nSpacing := 20
   
   @ 0, 0 IMAGE "logo" OF oHStack
   @ 0, 0 LABEL "Texto al lado" OF oHStack
ACTIVATE HSTACK oHStack
```

### 5.3 TSwZStack (Depth Stack)
Superpone elementos uno encima de otro (eje Z). Es ideal para crear fondos personalizados o capas de interfaz.

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `nAlignment`| Numérico | Alineación combinada de los elementos superpuestos. |

**Sintaxis Harbour:**
```harbour
@ nRow, nCol ZSTACK oZStack OF oWnd
   @ 0, 0 IMAGE "background" OF oZStack
   @ 0, 0 LABEL "Texto encima" OF oZStack
ACTIVATE ZSTACK oZStack
```

---

## 6. Controles de Contenido

### 6.1 TSwLabel
Componente de texto nativo con soporte para estilos modernos.

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `cText` | String | El contenido del texto. |
| `nSize` | Numérico | Tamaño de la fuente. |
| `lBold` | Lógico | Aplica peso negrita. |

### 6.2 TSwButton
Botón nativo con soporte para codeblocks en Harbour.

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `cText` | String | El texto del botón. |
| `bAction` | Block | El código Harbour que se ejecuta al pulsar. |

**Sintaxis Harbour:**
```harbour
@ 0, 0 BUTTON oBtn PROMPT "Enviar" OF oStack ;
   ACTION msgInfo( "Hola desde Swift!" )
```

### 6.3 TSwImage
Renderizado de imágenes nativas.

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `cImage` | String | Nombre del recurso o ruta de la imagen. |
| `nWidth` | Numérico | Ancho deseado. |
| `nHeight`| Numérico | Alto deseado. |

### 6.4 TSwToggle
Interruptor nativo (Switch).

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `cText` | String | Etiqueta descriptiva. |
| `lValue` | Lógico | Estado del interruptor. |

### 6.5 TSwSlider
Control de selección de rango.

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `nValue` | Numérico | Valor actual del slider. |
| `nMin` | Numérico | Valor mínimo. |
| `nMax` | Numérico | Valor máximo. |

---

## 7. Componentes de Datos

### 7.1 TSwBrowse (El Componente Estrella)
Un potente motor de tablas basado en `Table` de SwiftUI. 

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `aCols` | Array | Definición de columnas (`id`, `title`, `width`, `align`). |
| `aData` | Array | Datos en formato array multidimensional. |
| `bChange`| Block | Ejecutado al cambiar de fila. |
| `bAction`| Block | Ejecutado al hacer doble clic. |

**Sintaxis Harbour:**
```harbour
@ 20, 20 BROWSE oBrw OF oWnd SIZE 560, 460
oBrw:AddCol( "Nombre", "NAME", 150 )
oBrw:AddCol( "Precio", "PRICE", 100, 2 ) // Alineado derecha
oBrw:SetArray( aData )
```

---

## 8. Conclusión
La arquitectura **SW** no es solo un puente; es una nueva forma de entender el desarrollo con Harbour en macOS. Al delegar la complejidad visual a SwiftUI y mantener la lógica en Harbour, conseguimos aplicaciones con el rendimiento de Apple y la flexibilidad de xBase.
