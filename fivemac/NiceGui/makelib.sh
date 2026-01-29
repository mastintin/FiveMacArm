#!/bin/bash

# makelib.sh - Create libnice.a static library

echo "Compiling NiceGUI Library (Unified)..."

# Compilamos Nice.prg que ya incluye al resto
mkdir -p obj
../../harbour/bin/harbour source/Nice.prg -n -oobj/Nice.c -Iinclude -I../nativo/include -I../../harbour/include
if [ $? -ne 0 ]; then echo "Error compiling Nice.prg"; exit 1; fi

clang -c obj/Nice.c -oobj/Nice.o -Iinclude -I../nativo/include -I../../harbour/include
if [ $? -ne 0 ]; then echo "Error compiling Nice.c"; exit 1; fi

echo "Creating libnice.a..."
mkdir -p lib
ar rcs lib/libnice.a obj/Nice.o

echo "Done! lib/libnice.a created."
ls -l lib/libnice.a
