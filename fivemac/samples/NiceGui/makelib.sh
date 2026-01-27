#!/bin/bash

# makelib.sh - Create libnice.a static library

echo "Compiling NiceGUI Library (Unified)..."

# Compilamos Nice.prg que ya incluye al resto
../../../../harbour/bin/harbour Nice.prg -n -I../../include -I../../../../harbour/include
if [ $? -ne 0 ]; then echo "Error compiling Nice.prg"; exit 1; fi

clang -c Nice.c -I../../include -I../../../../harbour/include
if [ $? -ne 0 ]; then echo "Error compiling Nice.c"; exit 1; fi

echo "Creating libnice.a..."
ar rcs libnice.a Nice.o

echo "Cleaning up temporary files..."
rm Nice.c Nice.o

echo "Done! libnice.a created."
ls -l libnice.a
