# 🏝️ Swift Island (SW): Arquitectura 2.0

> [!TIP]
> **Para una mejor experiencia y navegación, consulta esta documentación en nuestro [Portal Interactivo de La Isla](https://mastintin.github.io/FiveMacArm/)**

---

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

## 5. La Revolución Multihilo: Solucionando el conflicto del Hilo 0
Una vez aislados los mundos, nos enfrentamos al mayor obstáculo técnico: la "lucha de poder" por el **Hilo 0 (Main Thread)**. Apple exige que toda la interfaz gráfica resida en el Hilo 0, pero Harbour también tendía a secuestrar dicho hilo, provocando bloqueos.

La arquitectura de "La Isla" nos permitió dar el paso definitivo al multihilo:
- **SwiftUI en Hilo 0**: La gestión visual corre en el hilo principal, garantizando fluidez total.
- **Harbour en Hilo 1**: Desplazamos el motor de Harbour a un hilo secundario dedicado. La lógica procesa datos sin congelar la interfaz.
- **Swift Concurrency**: Gestión de múltiples hilos adicionales para procesos asíncronos pesados.

### De la complejidad a la simplicidad
Hemos pasado de un Fivemac monohilo, saturado de *callbacks*, *handleEvents* e infinitas funciones de control, a un sistema **Multihilo Limpio** que se basa en solo **3 llamadas maestras**:
1. **Harbour -> Swift**: Envío de estados y comandos iniciales.
2. **Swift -> Harbour**: Notificación reactiva de cambios de estado del usuario (vía JSON).
3. **Query de Estado**: Consultas síncronas/asíncronas para obtener información precisa entre mundos.

---

## 6. Arquitectura de Layout: ¿Posicional o Contenido?

El framework distingue automáticamente entre dos tipos de comportamiento según su contenedor:

### 6.1 Controles Posicionales (Coordenadas Absolutas)
Definidos directamente sobre la ventana principal o un panel.
- **Definición**: `@ nRow, nCol ... OF oWnd`

### 6.2 Controles Contenidos (Layout Fluido en Stacks)
Residen dentro de un contenedor de tipo Stack (`VStack`, `HStack`, `ZStack`).
- **Definición**: `@ 0, 0 ... OF oStack`

---

## 🗂️ Índice Maestro de Controles
Para una navegación más cómoda por todos los componentes disponibles, consulta nuestro:
[👉 **Ver Catálogo Completo de Controles con Sidebar**](CONTROLS_INDEX.md)

---

## 7. Catálogo de Controles de Layout
Contenedores para organizar la interfaz de forma reactiva y fluida.

- **[TSwVStack](controls/TSwVStack.md)**: Organización vertical.
- **[TSwCard](controls/TSwCard.md)**: Contenedor de tarjeta estilizada.
- **[TSwHStack](controls/TSwHStack.md)**: Organización horizontal.
- **[TSwZStack](controls/TSwZStack.md)**: Organización por capas (eje Z).
- **[TSwGrid](controls/TSwGrid.md)**: Cuadrículas adaptativas y flexibles.
- **[TSwTabView](controls/TSwTabView.md)**: Navegación por pestañas nativas.
- **[TSwSidebar](controls/TSwSidebar.md)**: Barra lateral de navegación macOS.

---

## 8. Catálogo de Controles de Contenido
Componentes individuales para interacción y visualización de datos.

- **[TSwWindow](controls/TSwWindow.md)**: La base de la interfaz (Dual-Thread).
- **[TSwLabel](controls/TSwLabel.md)**: Etiquetas de texto y símbolos.
- **[TSwButton](controls/TSwButton.md)**: Botones interactivos.
- **[TSwGet](controls/TSwGet.md)**: Campos de entrada de datos con validación.
- **[TSwToggle](controls/TSwToggle.md)**: Interruptores y botones de estado.
- **[TSwSlider](controls/TSwSlider.md)**: Selección de valores en rangos.
- **[TSwPicker](controls/TSwPicker.md)**: Listas desplegables y selectores.
- **[TSwDatePicker](controls/TSwDatePicker.md)**: Selectores de fecha nativos.
- **[TSwImage](controls/TSwImage.md)**: Visualización de imágenes, símbolos y QRs.
- **[TSwProgress](controls/TSwProgress.md)**: Indicadores de progreso y carga.
- **[TSwList](controls/TSwList.md)**: Contenedor de listas dinámicas con layouts.
- **[TSwWebView](controls/TSwWebView.md)**: Motor web, JS y exportación PDF.

---

## 9. Próximamente
Estamos trabajando en la integración de componentes de datos avanzados como el **TSwBrowse**, que permitirá la visualización de grandes volúmenes de información de forma nativa en SwiftUI.

---

## 10. Conclusión
La arquitectura **SW** permite que Harbour viva en su mundo de datos y Swift en su mundo visual, comunicándose solo cuando es estrictamente necesario.
