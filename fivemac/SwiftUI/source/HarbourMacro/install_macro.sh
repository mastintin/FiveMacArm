#!/bin/bash

# Directorios
BASE_DIR="source/HarbourMacro"
BUILD_DIR="$BASE_DIR/.build/release"
BIN_DIR="$BASE_DIR/bin"

# Aseguramos que existe la carpeta bin
mkdir -p "$BIN_DIR"

echo "== Cosechando binarios de la Macro =="

# 1. Copiar el ejecutable del plugin
if [ -f "$BUILD_DIR/HarbourMacroImpl-tool" ]; then
    cp "$BUILD_DIR/HarbourMacroImpl-tool" "$BIN_DIR/HarbourMacroPlugin"
    echo "✔ Plugin copiado: $BIN_DIR/HarbourMacroPlugin"
else
    echo "✘ Error: No se encuentra el plugin en $BUILD_DIR"
    exit 1
fi

# 2. Copiar los archivos del módulo (Definición)
# Los módulos están en la carpeta Modules
MODULES_DIR="$BUILD_DIR/Modules"
if [ -d "$MODULES_DIR" ]; then
    cp "$MODULES_DIR"/HarbourMacro.* "$BIN_DIR/"
    echo "✔ Módulos copiados a $BIN_DIR"
else
    # Si no están en Modules, probamos en la raíz de release
    if ls "$BUILD_DIR"/HarbourMacro.swiftmodule >/dev/null 2>&1; then
        cp "$BUILD_DIR"/HarbourMacro.* "$BIN_DIR/"
        echo "✔ Módulos copiados (desde release) a $BIN_DIR"
    else
        echo "✘ Error: No se encuentran los archivos del módulo"
        exit 1
    fi
fi

echo "== Proceso completado. Binarios visibles en $BIN_DIR =="
ls -l "$BIN_DIR"
