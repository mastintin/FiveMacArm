# Arquitectura de FiveMac

## Core de 64 bits
FiveMac fue completamente modernizado en Enero de 2026 para garantizar estabilidad absoluta en arquitecturas modernas de macOS (Apple Silicon y procesadores Intel de 64 bits).

- **Handles e Intérpretes**: Las funciones 32-bit (`hb_parnl`, `hb_retnl`) han sido sustituidas internamente por versiones seguras `hb_parnll` y `hb_retnll` que no truncan los punteros nativos.

## Mensajería y Reflexión
El sistema de mensajería (a través de `OBJC_MSGSEND`) utiliza `NSMethodSignature` para inspeccionar en tiempo de ejecución los parámetros exigidos. Gracias a esto, la librería mapea automáticamente argumentos Harbour hacia objetos Cocoa (`id`) sin requerir conversiones manuales (`cast`).
