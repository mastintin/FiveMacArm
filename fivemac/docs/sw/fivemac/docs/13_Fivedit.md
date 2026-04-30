# Fivedit: El IDE de FiveMac

Fivedit es el entorno de desarrollo integrado nativo diseñado específicamente para FiveMac. Facilita la escritura, depuración, diseño visual y construcción de aplicaciones macOS.

---

## Interfaz Principal

La interfaz de Fivedit se organiza en tres áreas principales mediante paneles ajustables (Splitters):

1.  **Panel Izquierdo**: Explorador de archivos abiertos y estructura de funciones del PRG actual.
2.  **Editor Central**: Basado en **Scintilla**, ofrece:
    *   **Resaltado de sintaxis** para Harbour y C.
    *   **Auto-completado Inteligente**: Integrado con la documentación oficial de Harbour (HbDocs).
    *   **Snippets**: Inserción rápida de bloques de código habituales.
3.  **Panel Inferior / Log**: Consola de salida de compilación para detectar errores en tiempo real.

---

## Diseñador de Diálogos (CreaForm)

FiveMac incluye un potente diseñador visual que permite crear interfaces mediante "drag & drop".

*   **Uso**: Accesible desde el menú o con la herramienta `CreaForm.prg`.
*   **Inspector de Objetos**: Permite modificar propiedades como colores, tamaños, variables y acciones (`bAction`) de cada control.
*   **Generación de Código**: El diseñador genera automáticamente código Harbour limpio y orientado a objetos que puedes pegar directamente en tu aplicación.

---

## Gestión de Proyectos (CreaBuilder)

Para proyectos que constan de múltiples archivos `.prg`, `.c`, imágenes y recursos, FiveMac utiliza archivos de proyecto `.hbp`.

### Tarea del Builder:
*   **Añadir archivos**: Gestiona la lista de fuentes del proyecto.
*   **Generar HBP**: Crea el archivo de proyecto con todas las flags de compilación y frameworks necesarios (Cocoa, WebKit, etc.).
*   **Crear App**: Automatiza el proceso de:
    1.  Compilación de PRG a C.
    2.  Compilación de C a Objetos.
    3.  Enlazado final.
    4.  **Bundling**: Creación de la estructura `.app` de macOS, incluyendo el archivo `Info.plist`, iconos y frameworks embebidos.

---

## Proceso de Construcción (Build.sh)

Fivedit utiliza el script `build.sh` para orquestar la compilación. Una característica clave es el **Smart Bundling**:
El script analiza automáticamente tu código fuente en busca de referencias a imágenes (ej. `"mac.png"`) y las copia automáticamente a la carpeta `Resources/bitmaps` dentro del `.app` final, optimizando el tamaño del paquete.

---

> [!TIP]
> Puedes usar la tecla **Cmd + R** (o el botón Run) para compilar y ejecutar tu script actual de forma instantánea sin necesidad de crear un proyecto completo, ideal para pruebas rápidas.
