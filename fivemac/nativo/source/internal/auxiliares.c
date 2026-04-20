#include <fivemac.h>
#include <hbapi.h>
#include <stdlib.h>
#include <time.h>

void generate_uuid_bytes(unsigned char *uuid) {
  for (int i = 0; i < 16; i++) {
    uuid[i] = rand() % 256;
  }
  // Ajustes para cumplir con UUID v4 (RFC 4122)
  uuid[6] = (uuid[6] & 0x0F) | 0x40;
  uuid[8] = (uuid[8] & 0x3F) | 0x80;
}

HB_FUNC(HB_UUID) {
  unsigned char uuid[16];
  char szUUID[37];

  // Inicializar semilla si es necesario
  static int seeded = 0;
  if (!seeded) {
    srand((unsigned int)time(NULL));
    seeded = 1;
  }

  generate_uuid_bytes(uuid);

  // Formatear a string: 8-4-4-4-12
  sprintf(
      szUUID,
      "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
      uuid[0], uuid[1], uuid[2], uuid[3], uuid[4], uuid[5], uuid[6], uuid[7],
      uuid[8], uuid[9], uuid[10], uuid[11], uuid[12], uuid[13], uuid[14],
      uuid[15]);

  hb_retc(szUUID);
}