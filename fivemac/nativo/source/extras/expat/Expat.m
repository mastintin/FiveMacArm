/* fab937ab8b186d7d296013669c332e6dfce2f99567882cff1f8eb24223c524a7 (2.7.4+)
                            __  __            _
                         ___\ \/ /_ __   __ _| |_
                        / _ \\  /| '_ \ / _` | __|
                       |  __//  \| |_) | (_| | |_
                        \___/_/\_\ .__/ \__,_|\__|
                                 |_| XML parser

   Copyright (c) 1997-2000 Thai Open Source Software Center Ltd
   Copyright (c) 2000      Clark Cooper <coopercc@users.sourceforge.net>
   Copyright (c) 2000-2006 Fred L. Drake, Jr. <fdrake@users.sourceforge.net>
   Copyright (c) 2001-2002 Greg Stein <gstein@users.sourceforge.net>
   Copyright (c) 2002-2016 Karl Waclawek <karl@waclawek.net>
   Copyright (c) 2005-2009 Steven Solie <steven@solie.ca>
   Copyright (c) 2016      Eric Rahm <erahm@mozilla.com>
   Copyright (c) 2016-2026 Sebastian Pipping <sebastian@pipping.org>
   Copyright (c) 2016      Gaurav <g.gupta@samsung.com>
   Copyright (c) 2016      Thomas Beutlich <tc@tbeu.de>
   Copyright (c) 2016      Gustavo Grieco <gustavo.grieco@imag.fr>
   Copyright (c) 2016      Pascal Cuoq <cuoq@trust-in-soft.com>
   Copyright (c) 2016      Ed Schouten <ed@nuxi.nl>
   Copyright (c) 2017-2022 Rhodri James <rhodri@wildebeest.org.uk>
   Copyright (c) 2017      Václav Slavík <vaclav@slavik.io>
   Copyright (c) 2017      Viktor Szakats <commit@vsz.me>
   Copyright (c) 2017      Chanho Park <chanho61.park@samsung.com>
   Copyright (c) 2017      Rolf Eike Beer <eike@sf-mail.de>
   Copyright (c) 2017      Hans Wennborg <hans@chromium.org>
   Copyright (c) 2018      Anton Maklakov <antmak.pub@gmail.com>
   Copyright (c) 2018      Benjamin Peterson <benjamin@python.org>
   Copyright (c) 2018      Marco Maggi <marco.maggi-ipsu@poste.it>
   Copyright (c) 2018      Mariusz Zaborski <oshogbo@vexillium.org>
   Copyright (c) 2019      David Loffredo <loffredo@steptools.com>
   Copyright (c) 2019-2020 Ben Wagner <bungeman@chromium.org>
   Copyright (c) 2019      Vadim Zeitlin <vadim@zeitlins.org>
   Copyright (c) 2021      Donghee Na <donghee.na@python.org>
   Copyright (c) 2022      Samanta Navarro <ferivoz@riseup.net>
   Copyright (c) 2022      Jeffrey Walton <noloader@gmail.com>
   Copyright (c) 2022      Jann Horn <jannh@google.com>
   Copyright (c) 2022      Sean McBride <sean@rogue-research.com>
   Copyright (c) 2023      Owain Davies <owaind@bath.edu>
   Copyright (c) 2023-2024 Sony Corporation / Snild Dolkow <snild@sony.com>
   Copyright (c) 2024-2025 Berkay Eren Ürün <berkay.ueruen@siemens.com>
   Copyright (c) 2024      Hanno Böck <hanno@gentoo.org>
   Copyright (c) 2025      Matthew Fernandez <matthew.fernandez@gmail.com>
   Copyright (c) 2025      Atrem Borovik <polzovatellllk@gmail.com>
   Copyright (c) 2025      Alfonso Gregory <gfunni234@gmail.com>
   Copyright (c) 2026      Rosen Penev <rosenp@gmail.com>
   Licensed under the MIT license:

   Permission is  hereby granted,  free of charge,  to any  person obtaining
   a  copy  of  this  software   and  associated  documentation  files  (the
   "Software"),  to  deal in  the  Software  without restriction,  including
   without  limitation the  rights  to use,  copy,  modify, merge,  publish,
   distribute, sublicense, and/or sell copies of the Software, and to permit
   persons  to whom  the Software  is  furnished to  do so,  subject to  the
   following conditions:

   The above copyright  notice and this permission notice  shall be included
   in all copies or substantial portions of the Software.

   THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT  WARRANTY  OF  ANY  KIND,
   EXPRESS  OR IMPLIED,  INCLUDING  BUT  NOT LIMITED  TO  THE WARRANTIES  OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
   NO EVENT SHALL THE AUTHORS OR  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
*/
/* --- EXPAT CONSOLIDATION FOR FIVEMAC --- */

#define XML_BUILDING_EXPAT 1
#define HAVE_EXPAT_CONFIG_H 1

/* Expat configuration for macOS (Darwin) */
#define BYTEORDER 1234
#define HAVE_ARC4RANDOM_BUF 1
#define HAVE_DLFCN_H 1
#define HAVE_FCNTL_H 1
#define HAVE_GETPAGESIZE 1
#define HAVE_INTTYPES_H 1
#define HAVE_MMAP 1
#define HAVE_STDINT_H 1
#define HAVE_STDIO_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRING_H 1
#define HAVE_SYS_PARAM_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_UNISTD_H 1
#define XML_CONTEXT_BYTES 1024
#define XML_DEV_URANDOM 1
#define XML_DTD 1
#define XML_GE 1
#define XML_NS 1

#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <math.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

/* Use local headers - Assumes -I./include flag in compiler */
#include "ascii.h"
#include "expat.h"
#include "internal.h"
#include "siphash.h"
#include "xmlrole.h"
#include "xmltok.h"
#include "xmltok_impl.h"

/* --- xmlrole.c --- */

#include <stddef.h>

#include "ascii.h"
#include "internal.h"
#include "xmlrole.h"

/* Doesn't check:

 that ,| are not mixed in a model group
 content of literals

*/

static const char KW_ANY[] = {ASCII_A, ASCII_N, ASCII_Y, '\0'};
static const char KW_ATTLIST[] = {ASCII_A, ASCII_T, ASCII_T, ASCII_L,
                                  ASCII_I, ASCII_S, ASCII_T, '\0'};
static const char KW_CDATA[] = {ASCII_C, ASCII_D, ASCII_A,
                                ASCII_T, ASCII_A, '\0'};
static const char KW_DOCTYPE[] = {ASCII_D, ASCII_O, ASCII_C, ASCII_T,
                                  ASCII_Y, ASCII_P, ASCII_E, '\0'};
static const char KW_ELEMENT[] = {ASCII_E, ASCII_L, ASCII_E, ASCII_M,
                                  ASCII_E, ASCII_N, ASCII_T, '\0'};
static const char KW_EMPTY[] = {ASCII_E, ASCII_M, ASCII_P,
                                ASCII_T, ASCII_Y, '\0'};
static const char KW_ENTITIES[] = {ASCII_E, ASCII_N, ASCII_T, ASCII_I, ASCII_T,
                                   ASCII_I, ASCII_E, ASCII_S, '\0'};
static const char KW_ENTITY[] = {ASCII_E, ASCII_N, ASCII_T, ASCII_I,
                                 ASCII_T, ASCII_Y, '\0'};
static const char KW_FIXED[] = {ASCII_F, ASCII_I, ASCII_X,
                                ASCII_E, ASCII_D, '\0'};
static const char KW_ID[] = {ASCII_I, ASCII_D, '\0'};
static const char KW_IDREF[] = {ASCII_I, ASCII_D, ASCII_R,
                                ASCII_E, ASCII_F, '\0'};
static const char KW_IDREFS[] = {ASCII_I, ASCII_D, ASCII_R, ASCII_E,
                                 ASCII_F, ASCII_S, '\0'};
#ifdef XML_DTD
static const char KW_IGNORE[] = {ASCII_I, ASCII_G, ASCII_N, ASCII_O,
                                 ASCII_R, ASCII_E, '\0'};
#endif
static const char KW_IMPLIED[] = {ASCII_I, ASCII_M, ASCII_P, ASCII_L,
                                  ASCII_I, ASCII_E, ASCII_D, '\0'};
#ifdef XML_DTD
static const char KW_INCLUDE[] = {ASCII_I, ASCII_N, ASCII_C, ASCII_L,
                                  ASCII_U, ASCII_D, ASCII_E, '\0'};
#endif
static const char KW_NDATA[] = {ASCII_N, ASCII_D, ASCII_A,
                                ASCII_T, ASCII_A, '\0'};
static const char KW_NMTOKEN[] = {ASCII_N, ASCII_M, ASCII_T, ASCII_O,
                                  ASCII_K, ASCII_E, ASCII_N, '\0'};
static const char KW_NMTOKENS[] = {ASCII_N, ASCII_M, ASCII_T, ASCII_O, ASCII_K,
                                   ASCII_E, ASCII_N, ASCII_S, '\0'};
static const char KW_NOTATION[] = {ASCII_N, ASCII_O, ASCII_T, ASCII_A, ASCII_T,
                                   ASCII_I, ASCII_O, ASCII_N, '\0'};
static const char KW_PCDATA[] = {ASCII_P, ASCII_C, ASCII_D, ASCII_A,
                                 ASCII_T, ASCII_A, '\0'};
static const char KW_PUBLIC[] = {ASCII_P, ASCII_U, ASCII_B, ASCII_L,
                                 ASCII_I, ASCII_C, '\0'};
static const char KW_REQUIRED[] = {ASCII_R, ASCII_E, ASCII_Q, ASCII_U, ASCII_I,
                                   ASCII_R, ASCII_E, ASCII_D, '\0'};
static const char KW_SYSTEM[] = {ASCII_S, ASCII_Y, ASCII_S, ASCII_T,
                                 ASCII_E, ASCII_M, '\0'};

#ifndef MIN_BYTES_PER_CHAR
#define MIN_BYTES_PER_CHAR(enc) ((enc)->minBytesPerChar)
#endif

#ifdef XML_DTD
#define setTopLevel(state)                                                     \
  ((state)->handler =                                                          \
       ((state)->documentEntity ? internalSubset : externalSubset1))
#else /* not XML_DTD */
#define setTopLevel(state) ((state)->handler = internalSubset)
#endif /* not XML_DTD */

typedef int PTRCALL PROLOG_HANDLER(PROLOG_STATE *state, int tok,
                                   const char *ptr, const char *end,
                                   const ENCODING *enc);

static PROLOG_HANDLER prolog0, prolog1, prolog2, doctype0, doctype1, doctype2,
    doctype3, doctype4, doctype5, internalSubset, entity0, entity1, entity2,
    entity3, entity4, entity5, entity6, entity7, entity8, entity9, entity10,
    notation0, notation1, notation2, notation3, notation4, attlist0, attlist1,
    attlist2, attlist3, attlist4, attlist5, attlist6, attlist7, attlist8,
    attlist9, element0, element1, element2, element3, element4, element5,
    element6, element7,
#ifdef XML_DTD
    externalSubset0, externalSubset1, condSect0, condSect1, condSect2,
#endif /* XML_DTD */
    declClose, error;

static int FASTCALL common(PROLOG_STATE *state, int tok);

static int PTRCALL prolog0(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    state->handler = prolog1;
    return XML_ROLE_NONE;
  case XML_TOK_XML_DECL:
    state->handler = prolog1;
    return XML_ROLE_XML_DECL;
  case XML_TOK_PI:
    state->handler = prolog1;
    return XML_ROLE_PI;
  case XML_TOK_COMMENT:
    state->handler = prolog1;
    return XML_ROLE_COMMENT;
  case XML_TOK_BOM:
    return XML_ROLE_NONE;
  case XML_TOK_DECL_OPEN:
    if (!XmlNameMatchesAscii(enc, ptr + 2 * MIN_BYTES_PER_CHAR(enc), end,
                             KW_DOCTYPE))
      break;
    state->handler = doctype0;
    return XML_ROLE_DOCTYPE_NONE;
  case XML_TOK_INSTANCE_START:
    state->handler = error;
    return XML_ROLE_INSTANCE_START;
  }
  return common(state, tok);
}

static int PTRCALL prolog1(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NONE;
  case XML_TOK_PI:
    return XML_ROLE_PI;
  case XML_TOK_COMMENT:
    return XML_ROLE_COMMENT;
  case XML_TOK_BOM:
    /* This case can never arise.  To reach this role function, the
     * parse must have passed through prolog0 and therefore have had
     * some form of input, even if only a space.  At that point, a
     * byte order mark is no longer a valid character (though
     * technically it should be interpreted as a non-breaking space),
     * so will be rejected by the tokenizing stages.
     */
    return XML_ROLE_NONE; /* LCOV_EXCL_LINE */
  case XML_TOK_DECL_OPEN:
    if (!XmlNameMatchesAscii(enc, ptr + 2 * MIN_BYTES_PER_CHAR(enc), end,
                             KW_DOCTYPE))
      break;
    state->handler = doctype0;
    return XML_ROLE_DOCTYPE_NONE;
  case XML_TOK_INSTANCE_START:
    state->handler = error;
    return XML_ROLE_INSTANCE_START;
  }
  return common(state, tok);
}

static int PTRCALL prolog2(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NONE;
  case XML_TOK_PI:
    return XML_ROLE_PI;
  case XML_TOK_COMMENT:
    return XML_ROLE_COMMENT;
  case XML_TOK_INSTANCE_START:
    state->handler = error;
    return XML_ROLE_INSTANCE_START;
  }
  return common(state, tok);
}

static int PTRCALL doctype0(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_DOCTYPE_NONE;
  case XML_TOK_NAME:
  case XML_TOK_PREFIXED_NAME:
    state->handler = doctype1;
    return XML_ROLE_DOCTYPE_NAME;
  }
  return common(state, tok);
}

static int PTRCALL doctype1(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_DOCTYPE_NONE;
  case XML_TOK_OPEN_BRACKET:
    state->handler = internalSubset;
    return XML_ROLE_DOCTYPE_INTERNAL_SUBSET;
  case XML_TOK_DECL_CLOSE:
    state->handler = prolog2;
    return XML_ROLE_DOCTYPE_CLOSE;
  case XML_TOK_NAME:
    if (XmlNameMatchesAscii(enc, ptr, end, KW_SYSTEM)) {
      state->handler = doctype3;
      return XML_ROLE_DOCTYPE_NONE;
    }
    if (XmlNameMatchesAscii(enc, ptr, end, KW_PUBLIC)) {
      state->handler = doctype2;
      return XML_ROLE_DOCTYPE_NONE;
    }
    break;
  }
  return common(state, tok);
}

static int PTRCALL doctype2(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_DOCTYPE_NONE;
  case XML_TOK_LITERAL:
    state->handler = doctype3;
    return XML_ROLE_DOCTYPE_PUBLIC_ID;
  }
  return common(state, tok);
}

static int PTRCALL doctype3(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_DOCTYPE_NONE;
  case XML_TOK_LITERAL:
    state->handler = doctype4;
    return XML_ROLE_DOCTYPE_SYSTEM_ID;
  }
  return common(state, tok);
}

static int PTRCALL doctype4(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_DOCTYPE_NONE;
  case XML_TOK_OPEN_BRACKET:
    state->handler = internalSubset;
    return XML_ROLE_DOCTYPE_INTERNAL_SUBSET;
  case XML_TOK_DECL_CLOSE:
    state->handler = prolog2;
    return XML_ROLE_DOCTYPE_CLOSE;
  }
  return common(state, tok);
}

static int PTRCALL doctype5(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_DOCTYPE_NONE;
  case XML_TOK_DECL_CLOSE:
    state->handler = prolog2;
    return XML_ROLE_DOCTYPE_CLOSE;
  }
  return common(state, tok);
}

static int PTRCALL internalSubset(PROLOG_STATE *state, int tok, const char *ptr,
                                  const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NONE;
  case XML_TOK_DECL_OPEN:
    if (XmlNameMatchesAscii(enc, ptr + 2 * MIN_BYTES_PER_CHAR(enc), end,
                            KW_ENTITY)) {
      state->handler = entity0;
      return XML_ROLE_ENTITY_NONE;
    }
    if (XmlNameMatchesAscii(enc, ptr + 2 * MIN_BYTES_PER_CHAR(enc), end,
                            KW_ATTLIST)) {
      state->handler = attlist0;
      return XML_ROLE_ATTLIST_NONE;
    }
    if (XmlNameMatchesAscii(enc, ptr + 2 * MIN_BYTES_PER_CHAR(enc), end,
                            KW_ELEMENT)) {
      state->handler = element0;
      return XML_ROLE_ELEMENT_NONE;
    }
    if (XmlNameMatchesAscii(enc, ptr + 2 * MIN_BYTES_PER_CHAR(enc), end,
                            KW_NOTATION)) {
      state->handler = notation0;
      return XML_ROLE_NOTATION_NONE;
    }
    break;
  case XML_TOK_PI:
    return XML_ROLE_PI;
  case XML_TOK_COMMENT:
    return XML_ROLE_COMMENT;
  case XML_TOK_PARAM_ENTITY_REF:
    return XML_ROLE_PARAM_ENTITY_REF;
  case XML_TOK_CLOSE_BRACKET:
    state->handler = doctype5;
    return XML_ROLE_DOCTYPE_NONE;
  case XML_TOK_NONE:
    return XML_ROLE_NONE;
  }
  return common(state, tok);
}

#ifdef XML_DTD

static int PTRCALL externalSubset0(PROLOG_STATE *state, int tok,
                                   const char *ptr, const char *end,
                                   const ENCODING *enc) {
  state->handler = externalSubset1;
  if (tok == XML_TOK_XML_DECL)
    return XML_ROLE_TEXT_DECL;
  return externalSubset1(state, tok, ptr, end, enc);
}

static int PTRCALL externalSubset1(PROLOG_STATE *state, int tok,
                                   const char *ptr, const char *end,
                                   const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_COND_SECT_OPEN:
    state->handler = condSect0;
    return XML_ROLE_NONE;
  case XML_TOK_COND_SECT_CLOSE:
    if (state->includeLevel == 0)
      break;
    state->includeLevel -= 1;
    return XML_ROLE_NONE;
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NONE;
  case XML_TOK_CLOSE_BRACKET:
    break;
  case XML_TOK_NONE:
    if (state->includeLevel)
      break;
    return XML_ROLE_NONE;
  default:
    return internalSubset(state, tok, ptr, end, enc);
  }
  return common(state, tok);
}

#endif /* XML_DTD */

static int PTRCALL entity0(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_PERCENT:
    state->handler = entity1;
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_NAME:
    state->handler = entity2;
    return XML_ROLE_GENERAL_ENTITY_NAME;
  }
  return common(state, tok);
}

static int PTRCALL entity1(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_NAME:
    state->handler = entity7;
    return XML_ROLE_PARAM_ENTITY_NAME;
  }
  return common(state, tok);
}

static int PTRCALL entity2(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_NAME:
    if (XmlNameMatchesAscii(enc, ptr, end, KW_SYSTEM)) {
      state->handler = entity4;
      return XML_ROLE_ENTITY_NONE;
    }
    if (XmlNameMatchesAscii(enc, ptr, end, KW_PUBLIC)) {
      state->handler = entity3;
      return XML_ROLE_ENTITY_NONE;
    }
    break;
  case XML_TOK_LITERAL:
    state->handler = declClose;
    state->role_none = XML_ROLE_ENTITY_NONE;
    return XML_ROLE_ENTITY_VALUE;
  }
  return common(state, tok);
}

static int PTRCALL entity3(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_LITERAL:
    state->handler = entity4;
    return XML_ROLE_ENTITY_PUBLIC_ID;
  }
  return common(state, tok);
}

static int PTRCALL entity4(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_LITERAL:
    state->handler = entity5;
    return XML_ROLE_ENTITY_SYSTEM_ID;
  }
  return common(state, tok);
}

static int PTRCALL entity5(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_DECL_CLOSE:
    setTopLevel(state);
    return XML_ROLE_ENTITY_COMPLETE;
  case XML_TOK_NAME:
    if (XmlNameMatchesAscii(enc, ptr, end, KW_NDATA)) {
      state->handler = entity6;
      return XML_ROLE_ENTITY_NONE;
    }
    break;
  }
  return common(state, tok);
}

static int PTRCALL entity6(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_NAME:
    state->handler = declClose;
    state->role_none = XML_ROLE_ENTITY_NONE;
    return XML_ROLE_ENTITY_NOTATION_NAME;
  }
  return common(state, tok);
}

static int PTRCALL entity7(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_NAME:
    if (XmlNameMatchesAscii(enc, ptr, end, KW_SYSTEM)) {
      state->handler = entity9;
      return XML_ROLE_ENTITY_NONE;
    }
    if (XmlNameMatchesAscii(enc, ptr, end, KW_PUBLIC)) {
      state->handler = entity8;
      return XML_ROLE_ENTITY_NONE;
    }
    break;
  case XML_TOK_LITERAL:
    state->handler = declClose;
    state->role_none = XML_ROLE_ENTITY_NONE;
    return XML_ROLE_ENTITY_VALUE;
  }
  return common(state, tok);
}

static int PTRCALL entity8(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_LITERAL:
    state->handler = entity9;
    return XML_ROLE_ENTITY_PUBLIC_ID;
  }
  return common(state, tok);
}

static int PTRCALL entity9(PROLOG_STATE *state, int tok, const char *ptr,
                           const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_LITERAL:
    state->handler = entity10;
    return XML_ROLE_ENTITY_SYSTEM_ID;
  }
  return common(state, tok);
}

static int PTRCALL entity10(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ENTITY_NONE;
  case XML_TOK_DECL_CLOSE:
    setTopLevel(state);
    return XML_ROLE_ENTITY_COMPLETE;
  }
  return common(state, tok);
}

static int PTRCALL notation0(PROLOG_STATE *state, int tok, const char *ptr,
                             const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NOTATION_NONE;
  case XML_TOK_NAME:
    state->handler = notation1;
    return XML_ROLE_NOTATION_NAME;
  }
  return common(state, tok);
}

static int PTRCALL notation1(PROLOG_STATE *state, int tok, const char *ptr,
                             const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NOTATION_NONE;
  case XML_TOK_NAME:
    if (XmlNameMatchesAscii(enc, ptr, end, KW_SYSTEM)) {
      state->handler = notation3;
      return XML_ROLE_NOTATION_NONE;
    }
    if (XmlNameMatchesAscii(enc, ptr, end, KW_PUBLIC)) {
      state->handler = notation2;
      return XML_ROLE_NOTATION_NONE;
    }
    break;
  }
  return common(state, tok);
}

static int PTRCALL notation2(PROLOG_STATE *state, int tok, const char *ptr,
                             const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NOTATION_NONE;
  case XML_TOK_LITERAL:
    state->handler = notation4;
    return XML_ROLE_NOTATION_PUBLIC_ID;
  }
  return common(state, tok);
}

static int PTRCALL notation3(PROLOG_STATE *state, int tok, const char *ptr,
                             const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NOTATION_NONE;
  case XML_TOK_LITERAL:
    state->handler = declClose;
    state->role_none = XML_ROLE_NOTATION_NONE;
    return XML_ROLE_NOTATION_SYSTEM_ID;
  }
  return common(state, tok);
}

static int PTRCALL notation4(PROLOG_STATE *state, int tok, const char *ptr,
                             const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NOTATION_NONE;
  case XML_TOK_LITERAL:
    state->handler = declClose;
    state->role_none = XML_ROLE_NOTATION_NONE;
    return XML_ROLE_NOTATION_SYSTEM_ID;
  case XML_TOK_DECL_CLOSE:
    setTopLevel(state);
    return XML_ROLE_NOTATION_NO_SYSTEM_ID;
  }
  return common(state, tok);
}

static int PTRCALL attlist0(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_NAME:
  case XML_TOK_PREFIXED_NAME:
    state->handler = attlist1;
    return XML_ROLE_ATTLIST_ELEMENT_NAME;
  }
  return common(state, tok);
}

static int PTRCALL attlist1(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_DECL_CLOSE:
    setTopLevel(state);
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_NAME:
  case XML_TOK_PREFIXED_NAME:
    state->handler = attlist2;
    return XML_ROLE_ATTRIBUTE_NAME;
  }
  return common(state, tok);
}

static int PTRCALL attlist2(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_NAME: {
    static const char *const types[] = {
        KW_CDATA,  KW_ID,       KW_IDREF,   KW_IDREFS,
        KW_ENTITY, KW_ENTITIES, KW_NMTOKEN, KW_NMTOKENS,
    };
    int i;
    for (i = 0; i < (int)(sizeof(types) / sizeof(types[0])); i++)
      if (XmlNameMatchesAscii(enc, ptr, end, types[i])) {
        state->handler = attlist8;
        return XML_ROLE_ATTRIBUTE_TYPE_CDATA + i;
      }
  }
    if (XmlNameMatchesAscii(enc, ptr, end, KW_NOTATION)) {
      state->handler = attlist5;
      return XML_ROLE_ATTLIST_NONE;
    }
    break;
  case XML_TOK_OPEN_PAREN:
    state->handler = attlist3;
    return XML_ROLE_ATTLIST_NONE;
  }
  return common(state, tok);
}

static int PTRCALL attlist3(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_NMTOKEN:
  case XML_TOK_NAME:
  case XML_TOK_PREFIXED_NAME:
    state->handler = attlist4;
    return XML_ROLE_ATTRIBUTE_ENUM_VALUE;
  }
  return common(state, tok);
}

static int PTRCALL attlist4(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_CLOSE_PAREN:
    state->handler = attlist8;
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_OR:
    state->handler = attlist3;
    return XML_ROLE_ATTLIST_NONE;
  }
  return common(state, tok);
}

static int PTRCALL attlist5(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_OPEN_PAREN:
    state->handler = attlist6;
    return XML_ROLE_ATTLIST_NONE;
  }
  return common(state, tok);
}

static int PTRCALL attlist6(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_NAME:
    state->handler = attlist7;
    return XML_ROLE_ATTRIBUTE_NOTATION_VALUE;
  }
  return common(state, tok);
}

static int PTRCALL attlist7(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_CLOSE_PAREN:
    state->handler = attlist8;
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_OR:
    state->handler = attlist6;
    return XML_ROLE_ATTLIST_NONE;
  }
  return common(state, tok);
}

/* default value */
static int PTRCALL attlist8(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_POUND_NAME:
    if (XmlNameMatchesAscii(enc, ptr + MIN_BYTES_PER_CHAR(enc), end,
                            KW_IMPLIED)) {
      state->handler = attlist1;
      return XML_ROLE_IMPLIED_ATTRIBUTE_VALUE;
    }
    if (XmlNameMatchesAscii(enc, ptr + MIN_BYTES_PER_CHAR(enc), end,
                            KW_REQUIRED)) {
      state->handler = attlist1;
      return XML_ROLE_REQUIRED_ATTRIBUTE_VALUE;
    }
    if (XmlNameMatchesAscii(enc, ptr + MIN_BYTES_PER_CHAR(enc), end,
                            KW_FIXED)) {
      state->handler = attlist9;
      return XML_ROLE_ATTLIST_NONE;
    }
    break;
  case XML_TOK_LITERAL:
    state->handler = attlist1;
    return XML_ROLE_DEFAULT_ATTRIBUTE_VALUE;
  }
  return common(state, tok);
}

static int PTRCALL attlist9(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ATTLIST_NONE;
  case XML_TOK_LITERAL:
    state->handler = attlist1;
    return XML_ROLE_FIXED_ATTRIBUTE_VALUE;
  }
  return common(state, tok);
}

static int PTRCALL element0(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ELEMENT_NONE;
  case XML_TOK_NAME:
  case XML_TOK_PREFIXED_NAME:
    state->handler = element1;
    return XML_ROLE_ELEMENT_NAME;
  }
  return common(state, tok);
}

static int PTRCALL element1(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ELEMENT_NONE;
  case XML_TOK_NAME:
    if (XmlNameMatchesAscii(enc, ptr, end, KW_EMPTY)) {
      state->handler = declClose;
      state->role_none = XML_ROLE_ELEMENT_NONE;
      return XML_ROLE_CONTENT_EMPTY;
    }
    if (XmlNameMatchesAscii(enc, ptr, end, KW_ANY)) {
      state->handler = declClose;
      state->role_none = XML_ROLE_ELEMENT_NONE;
      return XML_ROLE_CONTENT_ANY;
    }
    break;
  case XML_TOK_OPEN_PAREN:
    state->handler = element2;
    state->level = 1;
    return XML_ROLE_GROUP_OPEN;
  }
  return common(state, tok);
}

static int PTRCALL element2(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ELEMENT_NONE;
  case XML_TOK_POUND_NAME:
    if (XmlNameMatchesAscii(enc, ptr + MIN_BYTES_PER_CHAR(enc), end,
                            KW_PCDATA)) {
      state->handler = element3;
      return XML_ROLE_CONTENT_PCDATA;
    }
    break;
  case XML_TOK_OPEN_PAREN:
    state->level = 2;
    state->handler = element6;
    return XML_ROLE_GROUP_OPEN;
  case XML_TOK_NAME:
  case XML_TOK_PREFIXED_NAME:
    state->handler = element7;
    return XML_ROLE_CONTENT_ELEMENT;
  case XML_TOK_NAME_QUESTION:
    state->handler = element7;
    return XML_ROLE_CONTENT_ELEMENT_OPT;
  case XML_TOK_NAME_ASTERISK:
    state->handler = element7;
    return XML_ROLE_CONTENT_ELEMENT_REP;
  case XML_TOK_NAME_PLUS:
    state->handler = element7;
    return XML_ROLE_CONTENT_ELEMENT_PLUS;
  }
  return common(state, tok);
}

static int PTRCALL element3(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ELEMENT_NONE;
  case XML_TOK_CLOSE_PAREN:
    state->handler = declClose;
    state->role_none = XML_ROLE_ELEMENT_NONE;
    return XML_ROLE_GROUP_CLOSE;
  case XML_TOK_CLOSE_PAREN_ASTERISK:
    state->handler = declClose;
    state->role_none = XML_ROLE_ELEMENT_NONE;
    return XML_ROLE_GROUP_CLOSE_REP;
  case XML_TOK_OR:
    state->handler = element4;
    return XML_ROLE_ELEMENT_NONE;
  }
  return common(state, tok);
}

static int PTRCALL element4(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ELEMENT_NONE;
  case XML_TOK_NAME:
  case XML_TOK_PREFIXED_NAME:
    state->handler = element5;
    return XML_ROLE_CONTENT_ELEMENT;
  }
  return common(state, tok);
}

static int PTRCALL element5(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ELEMENT_NONE;
  case XML_TOK_CLOSE_PAREN_ASTERISK:
    state->handler = declClose;
    state->role_none = XML_ROLE_ELEMENT_NONE;
    return XML_ROLE_GROUP_CLOSE_REP;
  case XML_TOK_OR:
    state->handler = element4;
    return XML_ROLE_ELEMENT_NONE;
  }
  return common(state, tok);
}

static int PTRCALL element6(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ELEMENT_NONE;
  case XML_TOK_OPEN_PAREN:
    state->level += 1;
    return XML_ROLE_GROUP_OPEN;
  case XML_TOK_NAME:
  case XML_TOK_PREFIXED_NAME:
    state->handler = element7;
    return XML_ROLE_CONTENT_ELEMENT;
  case XML_TOK_NAME_QUESTION:
    state->handler = element7;
    return XML_ROLE_CONTENT_ELEMENT_OPT;
  case XML_TOK_NAME_ASTERISK:
    state->handler = element7;
    return XML_ROLE_CONTENT_ELEMENT_REP;
  case XML_TOK_NAME_PLUS:
    state->handler = element7;
    return XML_ROLE_CONTENT_ELEMENT_PLUS;
  }
  return common(state, tok);
}

static int PTRCALL element7(PROLOG_STATE *state, int tok, const char *ptr,
                            const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_ELEMENT_NONE;
  case XML_TOK_CLOSE_PAREN:
    state->level -= 1;
    if (state->level == 0) {
      state->handler = declClose;
      state->role_none = XML_ROLE_ELEMENT_NONE;
    }
    return XML_ROLE_GROUP_CLOSE;
  case XML_TOK_CLOSE_PAREN_ASTERISK:
    state->level -= 1;
    if (state->level == 0) {
      state->handler = declClose;
      state->role_none = XML_ROLE_ELEMENT_NONE;
    }
    return XML_ROLE_GROUP_CLOSE_REP;
  case XML_TOK_CLOSE_PAREN_QUESTION:
    state->level -= 1;
    if (state->level == 0) {
      state->handler = declClose;
      state->role_none = XML_ROLE_ELEMENT_NONE;
    }
    return XML_ROLE_GROUP_CLOSE_OPT;
  case XML_TOK_CLOSE_PAREN_PLUS:
    state->level -= 1;
    if (state->level == 0) {
      state->handler = declClose;
      state->role_none = XML_ROLE_ELEMENT_NONE;
    }
    return XML_ROLE_GROUP_CLOSE_PLUS;
  case XML_TOK_COMMA:
    state->handler = element6;
    return XML_ROLE_GROUP_SEQUENCE;
  case XML_TOK_OR:
    state->handler = element6;
    return XML_ROLE_GROUP_CHOICE;
  }
  return common(state, tok);
}

#ifdef XML_DTD

static int PTRCALL condSect0(PROLOG_STATE *state, int tok, const char *ptr,
                             const char *end, const ENCODING *enc) {
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NONE;
  case XML_TOK_NAME:
    if (XmlNameMatchesAscii(enc, ptr, end, KW_INCLUDE)) {
      state->handler = condSect1;
      return XML_ROLE_NONE;
    }
    if (XmlNameMatchesAscii(enc, ptr, end, KW_IGNORE)) {
      state->handler = condSect2;
      return XML_ROLE_NONE;
    }
    break;
  }
  return common(state, tok);
}

static int PTRCALL condSect1(PROLOG_STATE *state, int tok, const char *ptr,
                             const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NONE;
  case XML_TOK_OPEN_BRACKET:
    state->handler = externalSubset1;
    state->includeLevel += 1;
    return XML_ROLE_NONE;
  }
  return common(state, tok);
}

static int PTRCALL condSect2(PROLOG_STATE *state, int tok, const char *ptr,
                             const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return XML_ROLE_NONE;
  case XML_TOK_OPEN_BRACKET:
    state->handler = externalSubset1;
    return XML_ROLE_IGNORE_SECT;
  }
  return common(state, tok);
}

#endif /* XML_DTD */

static int PTRCALL declClose(PROLOG_STATE *state, int tok, const char *ptr,
                             const char *end, const ENCODING *enc) {
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  switch (tok) {
  case XML_TOK_PROLOG_S:
    return state->role_none;
  case XML_TOK_DECL_CLOSE:
    setTopLevel(state);
    return state->role_none;
  }
  return common(state, tok);
}

/* This function will only be invoked if the internal logic of the
 * parser has broken down.  It is used in two cases:
 *
 * 1: When the XML prolog has been finished.  At this point the
 * processor (the parser level above these role handlers) should
 * switch from prologProcessor to contentProcessor and reinitialise
 * the handler function.
 *
 * 2: When an error has been detected (via common() below).  At this
 * point again the processor should be switched to errorProcessor,
 * which will never call a handler.
 *
 * The result of this is that error() can only be called if the
 * processor switch failed to happen, which is an internal error and
 * therefore we shouldn't be able to provoke it simply by using the
 * library.  It is a necessary backstop, however, so we merely exclude
 * it from the coverage statistics.
 *
 * LCOV_EXCL_START
 */
static int PTRCALL error(PROLOG_STATE *state, int tok, const char *ptr,
                         const char *end, const ENCODING *enc) {
  UNUSED_P(state);
  UNUSED_P(tok);
  UNUSED_P(ptr);
  UNUSED_P(end);
  UNUSED_P(enc);
  return XML_ROLE_NONE;
}
/* LCOV_EXCL_STOP */

static int FASTCALL common(PROLOG_STATE *state, int tok) {
#ifdef XML_DTD
  if (!state->documentEntity && tok == XML_TOK_PARAM_ENTITY_REF)
    return XML_ROLE_INNER_PARAM_ENTITY_REF;
#else
  UNUSED_P(tok);
#endif
  state->handler = error;
  return XML_ROLE_ERROR;
}

void XmlPrologStateInit(PROLOG_STATE *state) {
  state->handler = prolog0;
#ifdef XML_DTD
  state->documentEntity = 1;
  state->includeLevel = 0;
  state->inEntityValue = 0;
#endif /* XML_DTD */
}

#ifdef XML_DTD

void XmlPrologStateInitExternalEntity(PROLOG_STATE *state) {
  state->handler = externalSubset0;
  state->documentEntity = 0;
  state->includeLevel = 0;
}

#endif /* XML_DTD */
/* --- xmltok.c --- */

#include <stdbool.h>
#include <stddef.h>
#include <string.h> /* memcpy */

#include "internal.h"
#include "nametab.h"
#include "xmltok.h"

#ifdef XML_DTD
#define IGNORE_SECTION_TOK_VTABLE , PREFIX(ignoreSectionTok)
#else
#define IGNORE_SECTION_TOK_VTABLE /* as nothing */
#endif

#define VTABLE1                                                                \
  {PREFIX(prologTok), PREFIX(contentTok),                                      \
   PREFIX(cdataSectionTok) IGNORE_SECTION_TOK_VTABLE},                         \
      {PREFIX(attributeValueTok), PREFIX(entityValueTok)},                     \
      PREFIX(nameMatchesAscii), PREFIX(nameLength), PREFIX(skipS),             \
      PREFIX(getAtts), PREFIX(charRefNumber), PREFIX(predefinedEntityName),    \
      PREFIX(updatePosition), PREFIX(isPublicId)

#define VTABLE VTABLE1, PREFIX(toUtf8), PREFIX(toUtf16)

#define UCS2_GET_NAMING(pages, hi, lo)                                         \
  (namingBitmap[(pages[hi] << 3) + ((lo) >> 5)] & (1u << ((lo) & 0x1F)))

/* A 2 byte UTF-8 representation splits the characters 11 bits between
   the bottom 5 and 6 bits of the bytes.  We need 8 bits to index into
   pages, 3 bits to add to that index and 5 bits to generate the mask.
*/
#define UTF8_GET_NAMING2(pages, byte)                                          \
  (namingBitmap[((pages)[(((byte)[0]) >> 2) & 7] << 3) +                       \
                ((((byte)[0]) & 3) << 1) + ((((byte)[1]) >> 5) & 1)] &         \
   (1u << (((byte)[1]) & 0x1F)))

/* A 3 byte UTF-8 representation splits the characters 16 bits between
   the bottom 4, 6 and 6 bits of the bytes.  We need 8 bits to index
   into pages, 3 bits to add to that index and 5 bits to generate the
   mask.
*/
#define UTF8_GET_NAMING3(pages, byte)                                          \
  (namingBitmap                                                                \
       [((pages)[((((byte)[0]) & 0xF) << 4) + ((((byte)[1]) >> 2) & 0xF)]      \
         << 3) +                                                               \
        ((((byte)[1]) & 3) << 1) + ((((byte)[2]) >> 5) & 1)] &                 \
   (1u << (((byte)[2]) & 0x1F)))

/* Detection of invalid UTF-8 sequences is based on Table 3.1B
   of Unicode 3.2: https://www.unicode.org/unicode/reports/tr28/
   with the additional restriction of not allowing the Unicode
   code points 0xFFFF and 0xFFFE (sequences EF,BF,BF and EF,BF,BE).
   Implementation details:
     (A & 0x80) == 0     means A < 0x80
   and
     (A & 0xC0) == 0xC0  means A > 0xBF
*/

#define UTF8_INVALID2(p)                                                       \
  ((*p) < 0xC2 || ((p)[1] & 0x80) == 0 || ((p)[1] & 0xC0) == 0xC0)

#define UTF8_INVALID3(p)                                                       \
  (((p)[2] & 0x80) == 0 ||                                                     \
   ((*p) == 0xEF && (p)[1] == 0xBF ? (p)[2] > 0xBD                             \
                                   : ((p)[2] & 0xC0) == 0xC0) ||               \
   ((*p) == 0xE0                                                               \
        ? (p)[1] < 0xA0 || ((p)[1] & 0xC0) == 0xC0                             \
        : ((p)[1] & 0x80) == 0 ||                                              \
              ((*p) == 0xED ? (p)[1] > 0x9F : ((p)[1] & 0xC0) == 0xC0)))

#define UTF8_INVALID4(p)                                                       \
  (((p)[3] & 0x80) == 0 || ((p)[3] & 0xC0) == 0xC0 || ((p)[2] & 0x80) == 0 ||  \
   ((p)[2] & 0xC0) == 0xC0 ||                                                  \
   ((*p) == 0xF0                                                               \
        ? (p)[1] < 0x90 || ((p)[1] & 0xC0) == 0xC0                             \
        : ((p)[1] & 0x80) == 0 ||                                              \
              ((*p) == 0xF4 ? (p)[1] > 0x8F : ((p)[1] & 0xC0) == 0xC0)))

static int PTRFASTCALL isNever(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  UNUSED_P(p);
  return 0;
}

static int PTRFASTCALL utf8_isName2(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return UTF8_GET_NAMING2(namePages, (const unsigned char *)p);
}

static int PTRFASTCALL utf8_isName3(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return UTF8_GET_NAMING3(namePages, (const unsigned char *)p);
}

#define utf8_isName4 isNever

static int PTRFASTCALL utf8_isNmstrt2(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return UTF8_GET_NAMING2(nmstrtPages, (const unsigned char *)p);
}

static int PTRFASTCALL utf8_isNmstrt3(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return UTF8_GET_NAMING3(nmstrtPages, (const unsigned char *)p);
}

#define utf8_isNmstrt4 isNever

static int PTRFASTCALL utf8_isInvalid2(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return UTF8_INVALID2((const unsigned char *)p);
}

static int PTRFASTCALL utf8_isInvalid3(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return UTF8_INVALID3((const unsigned char *)p);
}

static int PTRFASTCALL utf8_isInvalid4(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return UTF8_INVALID4((const unsigned char *)p);
}

struct normal_encoding {
  ENCODING enc;
  unsigned char type[256];
#ifdef XML_MIN_SIZE
  int(PTRFASTCALL *byteType)(const ENCODING *, const char *);
  int(PTRFASTCALL *isNameMin)(const ENCODING *, const char *);
  int(PTRFASTCALL *isNmstrtMin)(const ENCODING *, const char *);
  int(PTRFASTCALL *byteToAscii)(const ENCODING *, const char *);
  int(PTRCALL *charMatches)(const ENCODING *, const char *, int);
#endif /* XML_MIN_SIZE */
  int(PTRFASTCALL *isName2)(const ENCODING *, const char *);
  int(PTRFASTCALL *isName3)(const ENCODING *, const char *);
  int(PTRFASTCALL *isName4)(const ENCODING *, const char *);
  int(PTRFASTCALL *isNmstrt2)(const ENCODING *, const char *);
  int(PTRFASTCALL *isNmstrt3)(const ENCODING *, const char *);
  int(PTRFASTCALL *isNmstrt4)(const ENCODING *, const char *);
  int(PTRFASTCALL *isInvalid2)(const ENCODING *, const char *);
  int(PTRFASTCALL *isInvalid3)(const ENCODING *, const char *);
  int(PTRFASTCALL *isInvalid4)(const ENCODING *, const char *);
};

#define AS_NORMAL_ENCODING(enc) ((const struct normal_encoding *)(enc))

#ifdef XML_MIN_SIZE

#define STANDARD_VTABLE(E)                                                     \
  E##byteType, E##isNameMin, E##isNmstrtMin, E##byteToAscii, E##charMatches,

#else

#define STANDARD_VTABLE(E) /* as nothing */

#endif

#define NORMAL_VTABLE(E)                                                       \
  E##isName2, E##isName3, E##isName4, E##isNmstrt2, E##isNmstrt3,              \
      E##isNmstrt4, E##isInvalid2, E##isInvalid3, E##isInvalid4

#define NULL_VTABLE                                                            \
  /* isName2 */ NULL, /* isName3 */ NULL, /* isName4 */ NULL,                  \
      /* isNmstrt2 */ NULL, /* isNmstrt3 */ NULL, /* isNmstrt4 */ NULL,        \
      /* isInvalid2 */ NULL, /* isInvalid3 */ NULL, /* isInvalid4 */ NULL

static int FASTCALL checkCharRefNumber(int result);

#include "ascii.h"
#include "xmltok_impl.h"

#ifdef XML_MIN_SIZE
#define sb_isNameMin isNever
#define sb_isNmstrtMin isNever
#endif

#ifdef XML_MIN_SIZE
#define MINBPC(enc) ((enc)->minBytesPerChar)
#else
/* minimum bytes per character */
#define MINBPC(enc) 1
#endif

#define SB_BYTE_TYPE(enc, p)                                                   \
  (((const struct normal_encoding *)(enc))->type[(unsigned char)*(p)])

#ifdef XML_MIN_SIZE
static int PTRFASTCALL sb_byteType(const ENCODING *enc, const char *p) {
  return SB_BYTE_TYPE(enc, p);
}
#define BYTE_TYPE(enc, p) (AS_NORMAL_ENCODING(enc)->byteType(enc, p))
#else
#define BYTE_TYPE(enc, p) SB_BYTE_TYPE(enc, p)
#endif

#ifdef XML_MIN_SIZE
#define BYTE_TO_ASCII(enc, p) (AS_NORMAL_ENCODING(enc)->byteToAscii(enc, p))
static int PTRFASTCALL sb_byteToAscii(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return *p;
}
#else
#define BYTE_TO_ASCII(enc, p) (*(p))
#endif

#define IS_NAME_CHAR(enc, p, n) (AS_NORMAL_ENCODING(enc)->isName##n(enc, p))
#define IS_NMSTRT_CHAR(enc, p, n) (AS_NORMAL_ENCODING(enc)->isNmstrt##n(enc, p))
#ifdef XML_MIN_SIZE
#define IS_INVALID_CHAR(enc, p, n)                                             \
  (AS_NORMAL_ENCODING(enc)->isInvalid##n &&                                    \
   AS_NORMAL_ENCODING(enc)->isInvalid##n(enc, p))
#else
#define IS_INVALID_CHAR(enc, p, n)                                             \
  (AS_NORMAL_ENCODING(enc)->isInvalid##n(enc, p))
#endif

#ifdef XML_MIN_SIZE
#define IS_NAME_CHAR_MINBPC(enc, p) (AS_NORMAL_ENCODING(enc)->isNameMin(enc, p))
#define IS_NMSTRT_CHAR_MINBPC(enc, p)                                          \
  (AS_NORMAL_ENCODING(enc)->isNmstrtMin(enc, p))
#else
#define IS_NAME_CHAR_MINBPC(enc, p) (0)
#define IS_NMSTRT_CHAR_MINBPC(enc, p) (0)
#endif

#ifdef XML_MIN_SIZE
#define CHAR_MATCHES(enc, p, c)                                                \
  (AS_NORMAL_ENCODING(enc)->charMatches(enc, p, c))
static int PTRCALL sb_charMatches(const ENCODING *enc, const char *p, int c) {
  UNUSED_P(enc);
  return *p == c;
}
#else
/* c is an ASCII character */
#define CHAR_MATCHES(enc, p, c) (*(p) == (c))
#endif

#define PREFIX(ident) normal_##ident
#define XML_TOK_IMPL_C
/* --- INLINED xmltok_impl.c --- */

#ifdef XML_TOK_IMPL_C

#ifndef IS_INVALID_CHAR // i.e. for UTF-16 and XML_MIN_SIZE not defined
#define IS_INVALID_CHAR(enc, ptr, n) (0)
#endif

#define INVALID_LEAD_CASE(n, ptr, nextTokPtr)                                  \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n)                                                         \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n)) {                                        \
      *(nextTokPtr) = (ptr);                                                   \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    ptr += n;                                                                  \
    break;

#define INVALID_CASES(ptr, nextTokPtr)                                         \
  INVALID_LEAD_CASE(2, ptr, nextTokPtr)                                        \
  INVALID_LEAD_CASE(3, ptr, nextTokPtr)                                        \
  INVALID_LEAD_CASE(4, ptr, nextTokPtr)                                        \
  case BT_NONXML:                                                              \
  case BT_MALFORM:                                                             \
  case BT_TRAIL:                                                               \
    *(nextTokPtr) = (ptr);                                                     \
    return XML_TOK_INVALID;

#define CHECK_NAME_CASE(n, enc, ptr, end, nextTokPtr)                          \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n)                                                         \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n) || !IS_NAME_CHAR(enc, ptr, n)) {          \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    ptr += n;                                                                  \
    break;

#define CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)                            \
  case BT_NONASCII:                                                            \
    if (!IS_NAME_CHAR_MINBPC(enc, ptr)) {                                      \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    /* fall through */                                                         \
  case BT_NMSTRT:                                                              \
  case BT_HEX:                                                                 \
  case BT_DIGIT:                                                               \
  case BT_NAME:                                                                \
  case BT_MINUS:                                                               \
    ptr += MINBPC(enc);                                                        \
    break;                                                                     \
    CHECK_NAME_CASE(2, enc, ptr, end, nextTokPtr)                              \
    CHECK_NAME_CASE(3, enc, ptr, end, nextTokPtr)                              \
    CHECK_NAME_CASE(4, enc, ptr, end, nextTokPtr)

#define CHECK_NMSTRT_CASE(n, enc, ptr, end, nextTokPtr)                        \
  case BT_LEAD##n:                                                             \
    if ((end) - (ptr) < (n))                                                   \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n) || !IS_NMSTRT_CHAR(enc, ptr, n)) {        \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    ptr += n;                                                                  \
    break;

#define CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)                          \
  case BT_NONASCII:                                                            \
    if (!IS_NMSTRT_CHAR_MINBPC(enc, ptr)) {                                    \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    /* fall through */                                                         \
  case BT_NMSTRT:                                                              \
  case BT_HEX:                                                                 \
    ptr += MINBPC(enc);                                                        \
    break;                                                                     \
    CHECK_NMSTRT_CASE(2, enc, ptr, end, nextTokPtr)                            \
    CHECK_NMSTRT_CASE(3, enc, ptr, end, nextTokPtr)                            \
    CHECK_NMSTRT_CASE(4, enc, ptr, end, nextTokPtr)

#ifndef PREFIX
#define PREFIX(ident) ident
#endif

#define HAS_CHARS(enc, ptr, end, count)                                        \
  ((end) - (ptr) >= ((count) * MINBPC(enc)))

#define HAS_CHAR(enc, ptr, end) HAS_CHARS(enc, ptr, end, 1)

#define REQUIRE_CHARS(enc, ptr, end, count)                                    \
  {                                                                            \
    if (!HAS_CHARS(enc, ptr, end, count)) {                                    \
      return XML_TOK_PARTIAL;                                                  \
    }                                                                          \
  }

#define REQUIRE_CHAR(enc, ptr, end) REQUIRE_CHARS(enc, ptr, end, 1)

/* ptr points to character following "<!-" */

static int PTRCALL PREFIX(scanComment)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  if (HAS_CHAR(enc, ptr, end)) {
    if (!CHAR_MATCHES(enc, ptr, ASCII_MINUS)) {
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
    ptr += MINBPC(enc);
    while (HAS_CHAR(enc, ptr, end)) {
      switch (BYTE_TYPE(enc, ptr)) {
        INVALID_CASES(ptr, nextTokPtr)
      case BT_MINUS:
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        if (CHAR_MATCHES(enc, ptr, ASCII_MINUS)) {
          ptr += MINBPC(enc);
          REQUIRE_CHAR(enc, ptr, end);
          if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
            *nextTokPtr = ptr;
            return XML_TOK_INVALID;
          }
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_COMMENT;
        }
        break;
      default:
        ptr += MINBPC(enc);
        break;
      }
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "<!" */

static int PTRCALL PREFIX(scanDecl)(const ENCODING *enc, const char *ptr,
                                    const char *end, const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_MINUS:
    return PREFIX(scanComment)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_LSQB:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_COND_SECT_OPEN;
  case BT_NMSTRT:
  case BT_HEX:
    ptr += MINBPC(enc);
    break;
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_PERCNT:
      REQUIRE_CHARS(enc, ptr, end, 2);
      /* don't allow <!ENTITY% foo "whatever"> */
      switch (BYTE_TYPE(enc, ptr + MINBPC(enc))) {
      case BT_S:
      case BT_CR:
      case BT_LF:
      case BT_PERCNT:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      /* fall through */
    case BT_S:
    case BT_CR:
    case BT_LF:
      *nextTokPtr = ptr;
      return XML_TOK_DECL_OPEN;
    case BT_NMSTRT:
    case BT_HEX:
      ptr += MINBPC(enc);
      break;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(checkPiTarget)(const ENCODING *enc, const char *ptr,
                                         const char *end, int *tokPtr) {
  int upper = 0;
  UNUSED_P(enc);
  *tokPtr = XML_TOK_PI;
  if (end - ptr != MINBPC(enc) * 3)
    return 1;
  switch (BYTE_TO_ASCII(enc, ptr)) {
  case ASCII_x:
    break;
  case ASCII_X:
    upper = 1;
    break;
  default:
    return 1;
  }
  ptr += MINBPC(enc);
  switch (BYTE_TO_ASCII(enc, ptr)) {
  case ASCII_m:
    break;
  case ASCII_M:
    upper = 1;
    break;
  default:
    return 1;
  }
  ptr += MINBPC(enc);
  switch (BYTE_TO_ASCII(enc, ptr)) {
  case ASCII_l:
    break;
  case ASCII_L:
    upper = 1;
    break;
  default:
    return 1;
  }
  if (upper)
    return 0;
  *tokPtr = XML_TOK_XML_DECL;
  return 1;
}

/* ptr points to character following "<?" */

static int PTRCALL PREFIX(scanPi)(const ENCODING *enc, const char *ptr,
                                  const char *end, const char **nextTokPtr) {
  int tok;
  const char *target = ptr;
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_S:
    case BT_CR:
    case BT_LF:
      if (!PREFIX(checkPiTarget)(enc, target, ptr, &tok)) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      ptr += MINBPC(enc);
      while (HAS_CHAR(enc, ptr, end)) {
        switch (BYTE_TYPE(enc, ptr)) {
          INVALID_CASES(ptr, nextTokPtr)
        case BT_QUEST:
          ptr += MINBPC(enc);
          REQUIRE_CHAR(enc, ptr, end);
          if (CHAR_MATCHES(enc, ptr, ASCII_GT)) {
            *nextTokPtr = ptr + MINBPC(enc);
            return tok;
          }
          break;
        default:
          ptr += MINBPC(enc);
          break;
        }
      }
      return XML_TOK_PARTIAL;
    case BT_QUEST:
      if (!PREFIX(checkPiTarget)(enc, target, ptr, &tok)) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (CHAR_MATCHES(enc, ptr, ASCII_GT)) {
        *nextTokPtr = ptr + MINBPC(enc);
        return tok;
      }
      /* fall through */
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(scanCdataSection)(const ENCODING *enc,
                                            const char *ptr, const char *end,
                                            const char **nextTokPtr) {
  static const char CDATA_LSQB[] = {ASCII_C, ASCII_D, ASCII_A,
                                    ASCII_T, ASCII_A, ASCII_LSQB};
  int i;
  UNUSED_P(enc);
  /* CDATA[ */
  REQUIRE_CHARS(enc, ptr, end, 6);
  for (i = 0; i < 6; i++, ptr += MINBPC(enc)) {
    if (!CHAR_MATCHES(enc, ptr, CDATA_LSQB[i])) {
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_CDATA_SECT_OPEN;
}

static int PTRCALL PREFIX(cdataSectionTok)(const ENCODING *enc, const char *ptr,
                                           const char *end,
                                           const char **nextTokPtr) {
  if (ptr >= end)
    return XML_TOK_NONE;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      if (n == 0)
        return XML_TOK_PARTIAL;
      end = ptr + n;
    }
  }
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_RSQB:
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    if (!CHAR_MATCHES(enc, ptr, ASCII_RSQB))
      break;
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
      ptr -= MINBPC(enc);
      break;
    }
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_CDATA_SECT_CLOSE;
  case BT_CR:
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    if (BYTE_TYPE(enc, ptr) == BT_LF)
      ptr += MINBPC(enc);
    *nextTokPtr = ptr;
    return XML_TOK_DATA_NEWLINE;
  case BT_LF:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_DATA_NEWLINE;
    INVALID_CASES(ptr, nextTokPtr)
  default:
    ptr += MINBPC(enc);
    break;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n || IS_INVALID_CHAR(enc, ptr, n)) {                       \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_DATA_CHARS;                                               \
    }                                                                          \
    ptr += n;                                                                  \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_NONXML:
    case BT_MALFORM:
    case BT_TRAIL:
    case BT_CR:
    case BT_LF:
    case BT_RSQB:
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

/* ptr points to character following "</" */

static int PTRCALL PREFIX(scanEndTag)(const ENCODING *enc, const char *ptr,
                                      const char *end,
                                      const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_S:
    case BT_CR:
    case BT_LF:
      for (ptr += MINBPC(enc); HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
        switch (BYTE_TYPE(enc, ptr)) {
        case BT_S:
        case BT_CR:
        case BT_LF:
          break;
        case BT_GT:
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_END_TAG;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
      }
      return XML_TOK_PARTIAL;
#ifdef XML_NS
    case BT_COLON:
      /* no need to check qname syntax here,
         since end-tag must match exactly */
      ptr += MINBPC(enc);
      break;
#endif
    case BT_GT:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_END_TAG;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "&#X" */

static int PTRCALL PREFIX(scanHexCharRef)(const ENCODING *enc, const char *ptr,
                                          const char *end,
                                          const char **nextTokPtr) {
  if (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_DIGIT:
    case BT_HEX:
      break;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
    for (ptr += MINBPC(enc); HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_DIGIT:
      case BT_HEX:
        break;
      case BT_SEMI:
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_CHAR_REF;
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "&#" */

static int PTRCALL PREFIX(scanCharRef)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  if (HAS_CHAR(enc, ptr, end)) {
    if (CHAR_MATCHES(enc, ptr, ASCII_x))
      return PREFIX(scanHexCharRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_DIGIT:
      break;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
    for (ptr += MINBPC(enc); HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_DIGIT:
        break;
      case BT_SEMI:
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_CHAR_REF;
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "&" */

static int PTRCALL PREFIX(scanRef)(const ENCODING *enc, const char *ptr,
                                   const char *end, const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  case BT_NUM:
    return PREFIX(scanCharRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_SEMI:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_ENTITY_REF;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following first character of attribute name */

static int PTRCALL PREFIX(scanAtts)(const ENCODING *enc, const char *ptr,
                                    const char *end, const char **nextTokPtr) {
#ifdef XML_NS
  int hadColon = 0;
#endif
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
#ifdef XML_NS
    case BT_COLON:
      if (hadColon) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      hadColon = 1;
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      switch (BYTE_TYPE(enc, ptr)) {
        CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      break;
#endif
    case BT_S:
    case BT_CR:
    case BT_LF:
      for (;;) {
        int t;

        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        t = BYTE_TYPE(enc, ptr);
        if (t == BT_EQUALS)
          break;
        switch (t) {
        case BT_S:
        case BT_LF:
        case BT_CR:
          break;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
      }
      /* fall through */
    case BT_EQUALS: {
      int open;
#ifdef XML_NS
      hadColon = 0;
#endif
      for (;;) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        open = BYTE_TYPE(enc, ptr);
        if (open == BT_QUOT || open == BT_APOS)
          break;
        switch (open) {
        case BT_S:
        case BT_LF:
        case BT_CR:
          break;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
      }
      ptr += MINBPC(enc);
      /* in attribute value */
      for (;;) {
        int t;
        REQUIRE_CHAR(enc, ptr, end);
        t = BYTE_TYPE(enc, ptr);
        if (t == open)
          break;
        switch (t) {
          INVALID_CASES(ptr, nextTokPtr)
        case BT_AMP: {
          int tok = PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, &ptr);
          if (tok <= 0) {
            if (tok == XML_TOK_INVALID)
              *nextTokPtr = ptr;
            return tok;
          }
          break;
        }
        case BT_LT:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        default:
          ptr += MINBPC(enc);
          break;
        }
      }
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_S:
      case BT_CR:
      case BT_LF:
        break;
      case BT_SOL:
        goto sol;
      case BT_GT:
        goto gt;
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      /* ptr points to closing quote */
      for (;;) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        switch (BYTE_TYPE(enc, ptr)) {
          CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
        case BT_S:
        case BT_CR:
        case BT_LF:
          continue;
        case BT_GT:
        gt:
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_START_TAG_WITH_ATTS;
        case BT_SOL:
        sol:
          ptr += MINBPC(enc);
          REQUIRE_CHAR(enc, ptr, end);
          if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
            *nextTokPtr = ptr;
            return XML_TOK_INVALID;
          }
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_EMPTY_ELEMENT_WITH_ATTS;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
        break;
      }
      break;
    }
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "<" */

static int PTRCALL PREFIX(scanLt)(const ENCODING *enc, const char *ptr,
                                  const char *end, const char **nextTokPtr) {
#ifdef XML_NS
  int hadColon;
#endif
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  case BT_EXCL:
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_MINUS:
      return PREFIX(scanComment)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    case BT_LSQB:
      return PREFIX(scanCdataSection)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  case BT_QUEST:
    return PREFIX(scanPi)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_SOL:
    return PREFIX(scanEndTag)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
#ifdef XML_NS
  hadColon = 0;
#endif
  /* we have a start-tag */
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
#ifdef XML_NS
    case BT_COLON:
      if (hadColon) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      hadColon = 1;
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      switch (BYTE_TYPE(enc, ptr)) {
        CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      break;
#endif
    case BT_S:
    case BT_CR:
    case BT_LF: {
      ptr += MINBPC(enc);
      while (HAS_CHAR(enc, ptr, end)) {
        switch (BYTE_TYPE(enc, ptr)) {
          CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
        case BT_GT:
          goto gt;
        case BT_SOL:
          goto sol;
        case BT_S:
        case BT_CR:
        case BT_LF:
          ptr += MINBPC(enc);
          continue;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
        return PREFIX(scanAtts)(enc, ptr, end, nextTokPtr);
      }
      return XML_TOK_PARTIAL;
    }
    case BT_GT:
    gt:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_START_TAG_NO_ATTS;
    case BT_SOL:
    sol:
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_EMPTY_ELEMENT_NO_ATTS;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(contentTok)(const ENCODING *enc, const char *ptr,
                                      const char *end,
                                      const char **nextTokPtr) {
  if (ptr >= end)
    return XML_TOK_NONE;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      if (n == 0)
        return XML_TOK_PARTIAL;
      end = ptr + n;
    }
  }
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_LT:
    return PREFIX(scanLt)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_AMP:
    return PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_CR:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return XML_TOK_TRAILING_CR;
    if (BYTE_TYPE(enc, ptr) == BT_LF)
      ptr += MINBPC(enc);
    *nextTokPtr = ptr;
    return XML_TOK_DATA_NEWLINE;
  case BT_LF:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_DATA_NEWLINE;
  case BT_RSQB:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return XML_TOK_TRAILING_RSQB;
    if (!CHAR_MATCHES(enc, ptr, ASCII_RSQB))
      break;
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return XML_TOK_TRAILING_RSQB;
    if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
      ptr -= MINBPC(enc);
      break;
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
    INVALID_CASES(ptr, nextTokPtr)
  default:
    ptr += MINBPC(enc);
    break;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n || IS_INVALID_CHAR(enc, ptr, n)) {                       \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_DATA_CHARS;                                               \
    }                                                                          \
    ptr += n;                                                                  \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_RSQB:
      if (HAS_CHARS(enc, ptr, end, 2)) {
        if (!CHAR_MATCHES(enc, ptr + MINBPC(enc), ASCII_RSQB)) {
          ptr += MINBPC(enc);
          break;
        }
        if (HAS_CHARS(enc, ptr, end, 3)) {
          if (!CHAR_MATCHES(enc, ptr + 2 * MINBPC(enc), ASCII_GT)) {
            ptr += MINBPC(enc);
            break;
          }
          *nextTokPtr = ptr + 2 * MINBPC(enc);
          return XML_TOK_INVALID;
        }
      }
      /* fall through */
    case BT_AMP:
    case BT_LT:
    case BT_NONXML:
    case BT_MALFORM:
    case BT_TRAIL:
    case BT_CR:
    case BT_LF:
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

/* ptr points to character following "%" */

static int PTRCALL PREFIX(scanPercent)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  case BT_S:
  case BT_LF:
  case BT_CR:
  case BT_PERCNT:
    *nextTokPtr = ptr;
    return XML_TOK_PERCENT;
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_SEMI:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_PARAM_ENTITY_REF;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(scanPoundName)(const ENCODING *enc, const char *ptr,
                                         const char *end,
                                         const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_CR:
    case BT_LF:
    case BT_S:
    case BT_RPAR:
    case BT_GT:
    case BT_PERCNT:
    case BT_VERBAR:
      *nextTokPtr = ptr;
      return XML_TOK_POUND_NAME;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return -XML_TOK_POUND_NAME;
}

static int PTRCALL PREFIX(scanLit)(int open, const ENCODING *enc,
                                   const char *ptr, const char *end,
                                   const char **nextTokPtr) {
  while (HAS_CHAR(enc, ptr, end)) {
    int t = BYTE_TYPE(enc, ptr);
    switch (t) {
      INVALID_CASES(ptr, nextTokPtr)
    case BT_QUOT:
    case BT_APOS:
      ptr += MINBPC(enc);
      if (t != open)
        break;
      if (!HAS_CHAR(enc, ptr, end))
        return -XML_TOK_LITERAL;
      *nextTokPtr = ptr;
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_S:
      case BT_CR:
      case BT_LF:
      case BT_GT:
      case BT_PERCNT:
      case BT_LSQB:
        return XML_TOK_LITERAL;
      default:
        return XML_TOK_INVALID;
      }
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(prologTok)(const ENCODING *enc, const char *ptr,
                                     const char *end, const char **nextTokPtr) {
  int tok;
  if (ptr >= end)
    return XML_TOK_NONE;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      if (n == 0)
        return XML_TOK_PARTIAL;
      end = ptr + n;
    }
  }
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_QUOT:
    return PREFIX(scanLit)(BT_QUOT, enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_APOS:
    return PREFIX(scanLit)(BT_APOS, enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_LT: {
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_EXCL:
      return PREFIX(scanDecl)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    case BT_QUEST:
      return PREFIX(scanPi)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    case BT_NMSTRT:
    case BT_HEX:
    case BT_NONASCII:
    case BT_LEAD2:
    case BT_LEAD3:
    case BT_LEAD4:
      *nextTokPtr = ptr - MINBPC(enc);
      return XML_TOK_INSTANCE_START;
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  case BT_CR:
    if (ptr + MINBPC(enc) == end) {
      *nextTokPtr = end;
      /* indicate that this might be part of a CR/LF pair */
      return -XML_TOK_PROLOG_S;
    }
    /* fall through */
  case BT_S:
  case BT_LF:
    for (;;) {
      ptr += MINBPC(enc);
      if (!HAS_CHAR(enc, ptr, end))
        break;
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_S:
      case BT_LF:
        break;
      case BT_CR:
        /* don't split CR/LF pair */
        if (ptr + MINBPC(enc) != end)
          break;
        /* fall through */
      default:
        *nextTokPtr = ptr;
        return XML_TOK_PROLOG_S;
      }
    }
    *nextTokPtr = ptr;
    return XML_TOK_PROLOG_S;
  case BT_PERCNT:
    return PREFIX(scanPercent)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_COMMA:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_COMMA;
  case BT_LSQB:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_OPEN_BRACKET;
  case BT_RSQB:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return -XML_TOK_CLOSE_BRACKET;
    if (CHAR_MATCHES(enc, ptr, ASCII_RSQB)) {
      REQUIRE_CHARS(enc, ptr, end, 2);
      if (CHAR_MATCHES(enc, ptr + MINBPC(enc), ASCII_GT)) {
        *nextTokPtr = ptr + 2 * MINBPC(enc);
        return XML_TOK_COND_SECT_CLOSE;
      }
    }
    *nextTokPtr = ptr;
    return XML_TOK_CLOSE_BRACKET;
  case BT_LPAR:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_OPEN_PAREN;
  case BT_RPAR:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return -XML_TOK_CLOSE_PAREN;
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_AST:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_CLOSE_PAREN_ASTERISK;
    case BT_QUEST:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_CLOSE_PAREN_QUESTION;
    case BT_PLUS:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_CLOSE_PAREN_PLUS;
    case BT_CR:
    case BT_LF:
    case BT_S:
    case BT_GT:
    case BT_COMMA:
    case BT_VERBAR:
    case BT_RPAR:
      *nextTokPtr = ptr;
      return XML_TOK_CLOSE_PAREN;
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  case BT_VERBAR:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_OR;
  case BT_GT:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_DECL_CLOSE;
  case BT_NUM:
    return PREFIX(scanPoundName)(enc, ptr + MINBPC(enc), end, nextTokPtr);
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n)                                                         \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n)) {                                        \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    if (IS_NMSTRT_CHAR(enc, ptr, n)) {                                         \
      ptr += n;                                                                \
      tok = XML_TOK_NAME;                                                      \
      break;                                                                   \
    }                                                                          \
    if (IS_NAME_CHAR(enc, ptr, n)) {                                           \
      ptr += n;                                                                \
      tok = XML_TOK_NMTOKEN;                                                   \
      break;                                                                   \
    }                                                                          \
    *nextTokPtr = ptr;                                                         \
    return XML_TOK_INVALID;
    LEAD_CASE(2)
    LEAD_CASE(3)
    LEAD_CASE(4)
#undef LEAD_CASE
  case BT_NMSTRT:
  case BT_HEX:
    tok = XML_TOK_NAME;
    ptr += MINBPC(enc);
    break;
  case BT_DIGIT:
  case BT_NAME:
  case BT_MINUS:
#ifdef XML_NS
  case BT_COLON:
#endif
    tok = XML_TOK_NMTOKEN;
    ptr += MINBPC(enc);
    break;
  case BT_NONASCII:
    if (IS_NMSTRT_CHAR_MINBPC(enc, ptr)) {
      ptr += MINBPC(enc);
      tok = XML_TOK_NAME;
      break;
    }
    if (IS_NAME_CHAR_MINBPC(enc, ptr)) {
      ptr += MINBPC(enc);
      tok = XML_TOK_NMTOKEN;
      break;
    }
    /* fall through */
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_GT:
    case BT_RPAR:
    case BT_COMMA:
    case BT_VERBAR:
    case BT_LSQB:
    case BT_PERCNT:
    case BT_S:
    case BT_CR:
    case BT_LF:
      *nextTokPtr = ptr;
      return tok;
#ifdef XML_NS
    case BT_COLON:
      ptr += MINBPC(enc);
      switch (tok) {
      case XML_TOK_NAME:
        REQUIRE_CHAR(enc, ptr, end);
        tok = XML_TOK_PREFIXED_NAME;
        switch (BYTE_TYPE(enc, ptr)) {
          CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
        default:
          tok = XML_TOK_NMTOKEN;
          break;
        }
        break;
      case XML_TOK_PREFIXED_NAME:
        tok = XML_TOK_NMTOKEN;
        break;
      }
      break;
#endif
    case BT_PLUS:
      if (tok == XML_TOK_NMTOKEN) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_NAME_PLUS;
    case BT_AST:
      if (tok == XML_TOK_NMTOKEN) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_NAME_ASTERISK;
    case BT_QUEST:
      if (tok == XML_TOK_NMTOKEN) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_NAME_QUESTION;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return -tok;
}

static int PTRCALL PREFIX(attributeValueTok)(const ENCODING *enc,
                                             const char *ptr, const char *end,
                                             const char **nextTokPtr) {
  const char *start;
  if (ptr >= end)
    return XML_TOK_NONE;
  else if (!HAS_CHAR(enc, ptr, end)) {
    /* This line cannot be executed.  The incoming data has already
     * been tokenized once, so incomplete characters like this have
     * already been eliminated from the input.  Retaining the paranoia
     * check is still valuable, however.
     */
    return XML_TOK_PARTIAL; /* LCOV_EXCL_LINE */
  }
  start = ptr;
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_AMP:
      if (ptr == start)
        return PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_LT:
      /* this is for inside entity references */
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    case BT_LF:
      if (ptr == start) {
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_CR:
      if (ptr == start) {
        ptr += MINBPC(enc);
        if (!HAS_CHAR(enc, ptr, end))
          return XML_TOK_TRAILING_CR;
        if (BYTE_TYPE(enc, ptr) == BT_LF)
          ptr += MINBPC(enc);
        *nextTokPtr = ptr;
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_S:
      if (ptr == start) {
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_ATTRIBUTE_VALUE_S;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

static int PTRCALL PREFIX(entityValueTok)(const ENCODING *enc, const char *ptr,
                                          const char *end,
                                          const char **nextTokPtr) {
  const char *start;
  if (ptr >= end)
    return XML_TOK_NONE;
  else if (!HAS_CHAR(enc, ptr, end)) {
    /* This line cannot be executed.  The incoming data has already
     * been tokenized once, so incomplete characters like this have
     * already been eliminated from the input.  Retaining the paranoia
     * check is still valuable, however.
     */
    return XML_TOK_PARTIAL; /* LCOV_EXCL_LINE */
  }
  start = ptr;
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_AMP:
      if (ptr == start)
        return PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_PERCNT:
      if (ptr == start) {
        int tok = PREFIX(scanPercent)(enc, ptr + MINBPC(enc), end, nextTokPtr);
        return (tok == XML_TOK_PERCENT) ? XML_TOK_INVALID : tok;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_LF:
      if (ptr == start) {
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_CR:
      if (ptr == start) {
        ptr += MINBPC(enc);
        if (!HAS_CHAR(enc, ptr, end))
          return XML_TOK_TRAILING_CR;
        if (BYTE_TYPE(enc, ptr) == BT_LF)
          ptr += MINBPC(enc);
        *nextTokPtr = ptr;
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

#ifdef XML_DTD

static int PTRCALL PREFIX(ignoreSectionTok)(const ENCODING *enc,
                                            const char *ptr, const char *end,
                                            const char **nextTokPtr) {
  int level = 0;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      end = ptr + n;
    }
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      INVALID_CASES(ptr, nextTokPtr)
    case BT_LT:
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (CHAR_MATCHES(enc, ptr, ASCII_EXCL)) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        if (CHAR_MATCHES(enc, ptr, ASCII_LSQB)) {
          ++level;
          ptr += MINBPC(enc);
        }
      }
      break;
    case BT_RSQB:
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (CHAR_MATCHES(enc, ptr, ASCII_RSQB)) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        if (CHAR_MATCHES(enc, ptr, ASCII_GT)) {
          ptr += MINBPC(enc);
          if (level == 0) {
            *nextTokPtr = ptr;
            return XML_TOK_IGNORE_SECT;
          }
          --level;
        }
      }
      break;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  return XML_TOK_PARTIAL;
}

#endif /* XML_DTD */

static int PTRCALL PREFIX(isPublicId)(const ENCODING *enc, const char *ptr,
                                      const char *end, const char **badPtr) {
  ptr += MINBPC(enc);
  end -= MINBPC(enc);
  for (; HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_DIGIT:
    case BT_HEX:
    case BT_MINUS:
    case BT_APOS:
    case BT_LPAR:
    case BT_RPAR:
    case BT_PLUS:
    case BT_COMMA:
    case BT_SOL:
    case BT_EQUALS:
    case BT_QUEST:
    case BT_CR:
    case BT_LF:
    case BT_SEMI:
    case BT_EXCL:
    case BT_AST:
    case BT_PERCNT:
    case BT_NUM:
#ifdef XML_NS
    case BT_COLON:
#endif
      break;
    case BT_S:
      if (CHAR_MATCHES(enc, ptr, ASCII_TAB)) {
        *badPtr = ptr;
        return 0;
      }
      break;
    case BT_NAME:
    case BT_NMSTRT:
      if (!(BYTE_TO_ASCII(enc, ptr) & ~0x7f))
        break;
      /* fall through */
    default:
      switch (BYTE_TO_ASCII(enc, ptr)) {
      case 0x24: /* $ */
      case 0x40: /* @ */
        break;
      default:
        *badPtr = ptr;
        return 0;
      }
      break;
    }
  }
  return 1;
}

/* This must only be called for a well-formed start-tag or empty
   element tag.  Returns the number of attributes.  Pointers to the
   first attsMax attributes are stored in atts.
*/

static int PTRCALL PREFIX(getAtts)(const ENCODING *enc, const char *ptr,
                                   int attsMax, ATTRIBUTE *atts) {
  enum { other, inName, inValue } state = inName;
  int nAtts = 0;
  int open = 0; /* defined when state == inValue;
                   initialization just to shut up compilers */

  for (ptr += MINBPC(enc);; ptr += MINBPC(enc)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define START_NAME                                                             \
  if (state == other) {                                                        \
    if (nAtts < attsMax) {                                                     \
      atts[nAtts].name = ptr;                                                  \
      atts[nAtts].normalized = 1;                                              \
    }                                                                          \
    state = inName;                                                            \
  }
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n: /* NOTE: The encoding has already been validated. */        \
    START_NAME ptr += (n - MINBPC(enc));                                       \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_NONASCII:
    case BT_NMSTRT:
    case BT_HEX:
      START_NAME
      break;
#undef START_NAME
    case BT_QUOT:
      if (state != inValue) {
        if (nAtts < attsMax)
          atts[nAtts].valuePtr = ptr + MINBPC(enc);
        state = inValue;
        open = BT_QUOT;
      } else if (open == BT_QUOT) {
        state = other;
        if (nAtts < attsMax)
          atts[nAtts].valueEnd = ptr;
        nAtts++;
      }
      break;
    case BT_APOS:
      if (state != inValue) {
        if (nAtts < attsMax)
          atts[nAtts].valuePtr = ptr + MINBPC(enc);
        state = inValue;
        open = BT_APOS;
      } else if (open == BT_APOS) {
        state = other;
        if (nAtts < attsMax)
          atts[nAtts].valueEnd = ptr;
        nAtts++;
      }
      break;
    case BT_AMP:
      if (nAtts < attsMax)
        atts[nAtts].normalized = 0;
      break;
    case BT_S:
      if (state == inName)
        state = other;
      else if (state == inValue && nAtts < attsMax && atts[nAtts].normalized &&
               (ptr == atts[nAtts].valuePtr ||
                BYTE_TO_ASCII(enc, ptr) != ASCII_SPACE ||
                BYTE_TO_ASCII(enc, ptr + MINBPC(enc)) == ASCII_SPACE ||
                BYTE_TYPE(enc, ptr + MINBPC(enc)) == open))
        atts[nAtts].normalized = 0;
      break;
    case BT_CR:
    case BT_LF:
      /* This case ensures that the first attribute name is counted
         Apart from that we could just change state on the quote. */
      if (state == inName)
        state = other;
      else if (state == inValue && nAtts < attsMax)
        atts[nAtts].normalized = 0;
      break;
    case BT_GT:
    case BT_SOL:
      if (state != inValue)
        return nAtts;
      break;
    default:
      break;
    }
  }
  /* not reached */
}

static int PTRFASTCALL PREFIX(charRefNumber)(const ENCODING *enc,
                                             const char *ptr) {
  int result = 0;
  /* skip &# */
  UNUSED_P(enc);
  ptr += 2 * MINBPC(enc);
  if (CHAR_MATCHES(enc, ptr, ASCII_x)) {
    for (ptr += MINBPC(enc); !CHAR_MATCHES(enc, ptr, ASCII_SEMI);
         ptr += MINBPC(enc)) {
      int c = BYTE_TO_ASCII(enc, ptr);
      switch (c) {
      case ASCII_0:
      case ASCII_1:
      case ASCII_2:
      case ASCII_3:
      case ASCII_4:
      case ASCII_5:
      case ASCII_6:
      case ASCII_7:
      case ASCII_8:
      case ASCII_9:
        result <<= 4;
        result |= (c - ASCII_0);
        break;
      case ASCII_A:
      case ASCII_B:
      case ASCII_C:
      case ASCII_D:
      case ASCII_E:
      case ASCII_F:
        result <<= 4;
        result += 10 + (c - ASCII_A);
        break;
      case ASCII_a:
      case ASCII_b:
      case ASCII_c:
      case ASCII_d:
      case ASCII_e:
      case ASCII_f:
        result <<= 4;
        result += 10 + (c - ASCII_a);
        break;
      }
      if (result >= 0x110000)
        return -1;
    }
  } else {
    for (; !CHAR_MATCHES(enc, ptr, ASCII_SEMI); ptr += MINBPC(enc)) {
      int c = BYTE_TO_ASCII(enc, ptr);
      result *= 10;
      result += (c - ASCII_0);
      if (result >= 0x110000)
        return -1;
    }
  }
  return checkCharRefNumber(result);
}

static int PTRCALL PREFIX(predefinedEntityName)(const ENCODING *enc,
                                                const char *ptr,
                                                const char *end) {
  UNUSED_P(enc);
  switch ((end - ptr) / MINBPC(enc)) {
  case 2:
    if (CHAR_MATCHES(enc, ptr + MINBPC(enc), ASCII_t)) {
      switch (BYTE_TO_ASCII(enc, ptr)) {
      case ASCII_l:
        return ASCII_LT;
      case ASCII_g:
        return ASCII_GT;
      }
    }
    break;
  case 3:
    if (CHAR_MATCHES(enc, ptr, ASCII_a)) {
      ptr += MINBPC(enc);
      if (CHAR_MATCHES(enc, ptr, ASCII_m)) {
        ptr += MINBPC(enc);
        if (CHAR_MATCHES(enc, ptr, ASCII_p))
          return ASCII_AMP;
      }
    }
    break;
  case 4:
    switch (BYTE_TO_ASCII(enc, ptr)) {
    case ASCII_q:
      ptr += MINBPC(enc);
      if (CHAR_MATCHES(enc, ptr, ASCII_u)) {
        ptr += MINBPC(enc);
        if (CHAR_MATCHES(enc, ptr, ASCII_o)) {
          ptr += MINBPC(enc);
          if (CHAR_MATCHES(enc, ptr, ASCII_t))
            return ASCII_QUOT;
        }
      }
      break;
    case ASCII_a:
      ptr += MINBPC(enc);
      if (CHAR_MATCHES(enc, ptr, ASCII_p)) {
        ptr += MINBPC(enc);
        if (CHAR_MATCHES(enc, ptr, ASCII_o)) {
          ptr += MINBPC(enc);
          if (CHAR_MATCHES(enc, ptr, ASCII_s))
            return ASCII_APOS;
        }
      }
      break;
    }
  }
  return 0;
}

static int PTRCALL PREFIX(nameMatchesAscii)(const ENCODING *enc,
                                            const char *ptr1, const char *end1,
                                            const char *ptr2) {
  UNUSED_P(enc);
  for (; *ptr2; ptr1 += MINBPC(enc), ptr2++) {
    if (end1 - ptr1 < MINBPC(enc)) {
      /* This line cannot be executed.  The incoming data has already
       * been tokenized once, so incomplete characters like this have
       * already been eliminated from the input.  Retaining the
       * paranoia check is still valuable, however.
       */
      return 0; /* LCOV_EXCL_LINE */
    }
    if (!CHAR_MATCHES(enc, ptr1, *ptr2))
      return 0;
  }
  return ptr1 == end1;
}

static int PTRFASTCALL PREFIX(nameLength)(const ENCODING *enc,
                                          const char *ptr) {
  const char *start = ptr;
  for (;;) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_NONASCII:
    case BT_NMSTRT:
#ifdef XML_NS
    case BT_COLON:
#endif
    case BT_HEX:
    case BT_DIGIT:
    case BT_NAME:
    case BT_MINUS:
      ptr += MINBPC(enc);
      break;
    default:
      return (int)(ptr - start);
    }
  }
}

static const char *PTRFASTCALL PREFIX(skipS)(const ENCODING *enc,
                                             const char *ptr) {
  for (;;) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_LF:
    case BT_CR:
    case BT_S:
      ptr += MINBPC(enc);
      break;
    default:
      return ptr;
    }
  }
}

static void PTRCALL PREFIX(updatePosition)(const ENCODING *enc, const char *ptr,
                                           const char *end, POSITION *pos) {
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    pos->columnNumber++;                                                       \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_LF:
      pos->columnNumber = 0;
      pos->lineNumber++;
      ptr += MINBPC(enc);
      break;
    case BT_CR:
      pos->lineNumber++;
      ptr += MINBPC(enc);
      if (HAS_CHAR(enc, ptr, end) && BYTE_TYPE(enc, ptr) == BT_LF)
        ptr += MINBPC(enc);
      pos->columnNumber = 0;
      break;
    default:
      ptr += MINBPC(enc);
      pos->columnNumber++;
      break;
    }
  }
}

#undef DO_LEAD_CASE
#undef MULTIBYTE_CASES
#undef INVALID_CASES
#undef CHECK_NAME_CASE
#undef CHECK_NAME_CASES
#undef CHECK_NMSTRT_CASE
#undef CHECK_NMSTRT_CASES

#endif /* XML_TOK_IMPL_C */
#undef XML_TOK_IMPL_C

#undef MINBPC
#undef BYTE_TYPE
#undef BYTE_TO_ASCII
#undef CHAR_MATCHES
#undef IS_NAME_CHAR
#undef IS_NAME_CHAR_MINBPC
#undef IS_NMSTRT_CHAR
#undef IS_NMSTRT_CHAR_MINBPC
#undef IS_INVALID_CHAR

enum { /* UTF8_cvalN is value of masked first byte of N byte sequence */
       UTF8_cval1 = 0x00,
       UTF8_cval2 = 0xc0,
       UTF8_cval3 = 0xe0,
       UTF8_cval4 = 0xf0
};

void _INTERNAL_trim_to_complete_utf8_characters(const char *from,
                                                const char **fromLimRef) {
  const char *fromLim = *fromLimRef;
  size_t walked = 0;
  for (; fromLim > from; fromLim--, walked++) {
    const unsigned char prev = (unsigned char)fromLim[-1];
    if ((prev & 0xf8u) ==
        0xf0u) { /* 4-byte character, lead by 0b11110xxx byte */
      if (walked + 1 >= 4) {
        fromLim += 4 - 1;
        break;
      } else {
        walked = 0;
      }
    } else if ((prev & 0xf0u) ==
               0xe0u) { /* 3-byte character, lead by 0b1110xxxx byte */
      if (walked + 1 >= 3) {
        fromLim += 3 - 1;
        break;
      } else {
        walked = 0;
      }
    } else if ((prev & 0xe0u) ==
               0xc0u) { /* 2-byte character, lead by 0b110xxxxx byte */
      if (walked + 1 >= 2) {
        fromLim += 2 - 1;
        break;
      } else {
        walked = 0;
      }
    } else if ((prev & 0x80u) ==
               0x00u) { /* 1-byte character, matching 0b0xxxxxxx */
      break;
    }
  }
  *fromLimRef = fromLim;
}

static enum XML_Convert_Result PTRCALL utf8_toUtf8(const ENCODING *enc,
                                                   const char **fromP,
                                                   const char *fromLim,
                                                   char **toP,
                                                   const char *toLim) {
  bool input_incomplete = false;
  bool output_exhausted = false;

  /* Avoid copying partial characters (due to limited space). */
  const ptrdiff_t bytesAvailable = fromLim - *fromP;
  const ptrdiff_t bytesStorable = toLim - *toP;
  UNUSED_P(enc);
  if (bytesAvailable > bytesStorable) {
    fromLim = *fromP + bytesStorable;
    output_exhausted = true;
  }

  /* Avoid copying partial characters (from incomplete input). */
  {
    const char *const fromLimBefore = fromLim;
    _INTERNAL_trim_to_complete_utf8_characters(*fromP, &fromLim);
    if (fromLim < fromLimBefore) {
      input_incomplete = true;
    }
  }

  {
    const ptrdiff_t bytesToCopy = fromLim - *fromP;
    memcpy(*toP, *fromP, bytesToCopy);
    *fromP += bytesToCopy;
    *toP += bytesToCopy;
  }

  if (output_exhausted) /* needs to go first */
    return XML_CONVERT_OUTPUT_EXHAUSTED;
  else if (input_incomplete)
    return XML_CONVERT_INPUT_INCOMPLETE;
  else
    return XML_CONVERT_COMPLETED;
}

static enum XML_Convert_Result PTRCALL
utf8_toUtf16(const ENCODING *enc, const char **fromP, const char *fromLim,
             unsigned short **toP, const unsigned short *toLim) {
  enum XML_Convert_Result res = XML_CONVERT_COMPLETED;
  unsigned short *to = *toP;
  const char *from = *fromP;
  while (from < fromLim && to < toLim) {
    switch (SB_BYTE_TYPE(enc, from)) {
    case BT_LEAD2:
      if (fromLim - from < 2) {
        res = XML_CONVERT_INPUT_INCOMPLETE;
        goto after;
      }
      *to++ = (unsigned short)(((from[0] & 0x1f) << 6) | (from[1] & 0x3f));
      from += 2;
      break;
    case BT_LEAD3:
      if (fromLim - from < 3) {
        res = XML_CONVERT_INPUT_INCOMPLETE;
        goto after;
      }
      *to++ = (unsigned short)(((from[0] & 0xf) << 12) |
                               ((from[1] & 0x3f) << 6) | (from[2] & 0x3f));
      from += 3;
      break;
    case BT_LEAD4: {
      unsigned long n;
      if (toLim - to < 2) {
        res = XML_CONVERT_OUTPUT_EXHAUSTED;
        goto after;
      }
      if (fromLim - from < 4) {
        res = XML_CONVERT_INPUT_INCOMPLETE;
        goto after;
      }
      n = ((from[0] & 0x7) << 18) | ((from[1] & 0x3f) << 12) |
          ((from[2] & 0x3f) << 6) | (from[3] & 0x3f);
      n -= 0x10000;
      to[0] = (unsigned short)((n >> 10) | 0xD800);
      to[1] = (unsigned short)((n & 0x3FF) | 0xDC00);
      to += 2;
      from += 4;
    } break;
    default:
      *to++ = *from++;
      break;
    }
  }
  if (from < fromLim)
    res = XML_CONVERT_OUTPUT_EXHAUSTED;
after:
  *fromP = from;
  *toP = to;
  return res;
}

#ifdef XML_NS
static const struct normal_encoding utf8_encoding_ns = {
    {VTABLE1, utf8_toUtf8, utf8_toUtf16, 1, 1, 0},
    {
#include "asciitab.h"
#include "utf8tab.h"
    },
    STANDARD_VTABLE(sb_) NORMAL_VTABLE(utf8_)};
#endif

static const struct normal_encoding utf8_encoding = {
    {VTABLE1, utf8_toUtf8, utf8_toUtf16, 1, 1, 0},
    {
#define BT_COLON BT_NMSTRT
#include "asciitab.h"
#undef BT_COLON
#include "utf8tab.h"
    },
    STANDARD_VTABLE(sb_) NORMAL_VTABLE(utf8_)};

#ifdef XML_NS

static const struct normal_encoding internal_utf8_encoding_ns = {
    {VTABLE1, utf8_toUtf8, utf8_toUtf16, 1, 1, 0},
    {
#include "iasciitab.h"
#include "utf8tab.h"
    },
    STANDARD_VTABLE(sb_) NORMAL_VTABLE(utf8_)};

#endif

static const struct normal_encoding internal_utf8_encoding = {
    {VTABLE1, utf8_toUtf8, utf8_toUtf16, 1, 1, 0},
    {
#define BT_COLON BT_NMSTRT
#include "iasciitab.h"
#undef BT_COLON
#include "utf8tab.h"
    },
    STANDARD_VTABLE(sb_) NORMAL_VTABLE(utf8_)};

static enum XML_Convert_Result PTRCALL latin1_toUtf8(const ENCODING *enc,
                                                     const char **fromP,
                                                     const char *fromLim,
                                                     char **toP,
                                                     const char *toLim) {
  UNUSED_P(enc);
  for (;;) {
    unsigned char c;
    if (*fromP == fromLim)
      return XML_CONVERT_COMPLETED;
    c = (unsigned char)**fromP;
    if (c & 0x80) {
      if (toLim - *toP < 2)
        return XML_CONVERT_OUTPUT_EXHAUSTED;
      *(*toP)++ = (char)((c >> 6) | UTF8_cval2);
      *(*toP)++ = (char)((c & 0x3f) | 0x80);
      (*fromP)++;
    } else {
      if (*toP == toLim)
        return XML_CONVERT_OUTPUT_EXHAUSTED;
      *(*toP)++ = *(*fromP)++;
    }
  }
}

static enum XML_Convert_Result PTRCALL
latin1_toUtf16(const ENCODING *enc, const char **fromP, const char *fromLim,
               unsigned short **toP, const unsigned short *toLim) {
  UNUSED_P(enc);
  while (*fromP < fromLim && *toP < toLim)
    *(*toP)++ = (unsigned char)*(*fromP)++;

  if ((*toP == toLim) && (*fromP < fromLim))
    return XML_CONVERT_OUTPUT_EXHAUSTED;
  else
    return XML_CONVERT_COMPLETED;
}

#ifdef XML_NS

static const struct normal_encoding latin1_encoding_ns = {
    {VTABLE1, latin1_toUtf8, latin1_toUtf16, 1, 0, 0},
    {
#include "asciitab.h"
#include "latin1tab.h"
    },
    STANDARD_VTABLE(sb_) NULL_VTABLE};

#endif

static const struct normal_encoding latin1_encoding = {
    {VTABLE1, latin1_toUtf8, latin1_toUtf16, 1, 0, 0},
    {
#define BT_COLON BT_NMSTRT
#include "asciitab.h"
#undef BT_COLON
#include "latin1tab.h"
    },
    STANDARD_VTABLE(sb_) NULL_VTABLE};

static enum XML_Convert_Result PTRCALL ascii_toUtf8(const ENCODING *enc,
                                                    const char **fromP,
                                                    const char *fromLim,
                                                    char **toP,
                                                    const char *toLim) {
  UNUSED_P(enc);
  while (*fromP < fromLim && *toP < toLim)
    *(*toP)++ = *(*fromP)++;

  if ((*toP == toLim) && (*fromP < fromLim))
    return XML_CONVERT_OUTPUT_EXHAUSTED;
  else
    return XML_CONVERT_COMPLETED;
}

#ifdef XML_NS

static const struct normal_encoding ascii_encoding_ns = {
    {VTABLE1, ascii_toUtf8, latin1_toUtf16, 1, 1, 0},
    {
#include "asciitab.h"
        /* BT_NONXML == 0 */
    },
    STANDARD_VTABLE(sb_) NULL_VTABLE};

#endif

static const struct normal_encoding ascii_encoding = {
    {VTABLE1, ascii_toUtf8, latin1_toUtf16, 1, 1, 0},
    {
#define BT_COLON BT_NMSTRT
#include "asciitab.h"
#undef BT_COLON
        /* BT_NONXML == 0 */
    },
    STANDARD_VTABLE(sb_) NULL_VTABLE};

static int PTRFASTCALL unicode_byte_type(char hi, char lo) {
  switch ((unsigned char)hi) {
  /* 0xD800-0xDBFF first 16-bit code unit or high surrogate (W1) */
  case 0xD8:
  case 0xD9:
  case 0xDA:
  case 0xDB:
    return BT_LEAD4;
  /* 0xDC00-0xDFFF second 16-bit code unit or low surrogate (W2) */
  case 0xDC:
  case 0xDD:
  case 0xDE:
  case 0xDF:
    return BT_TRAIL;
  case 0xFF:
    switch ((unsigned char)lo) {
    case 0xFF: /* noncharacter-FFFF */
    case 0xFE: /* noncharacter-FFFE */
      return BT_NONXML;
    }
    break;
  }
  return BT_NONASCII;
}

#define DEFINE_UTF16_TO_UTF8(E)                                                \
  static enum XML_Convert_Result PTRCALL E##toUtf8(                            \
      const ENCODING *enc, const char **fromP, const char *fromLim,            \
      char **toP, const char *toLim) {                                         \
    const char *from = *fromP;                                                 \
    UNUSED_P(enc);                                                             \
    fromLim = from + (((fromLim - from) >> 1) << 1); /* shrink to even */      \
    for (; from < fromLim; from += 2) {                                        \
      int plane;                                                               \
      unsigned char lo2;                                                       \
      unsigned char lo = GET_LO(from);                                         \
      unsigned char hi = GET_HI(from);                                         \
      switch (hi) {                                                            \
      case 0:                                                                  \
        if (lo < 0x80) {                                                       \
          if (*toP == toLim) {                                                 \
            *fromP = from;                                                     \
            return XML_CONVERT_OUTPUT_EXHAUSTED;                               \
          }                                                                    \
          *(*toP)++ = lo;                                                      \
          break;                                                               \
        }                                                                      \
        /* fall through */                                                     \
      case 0x1:                                                                \
      case 0x2:                                                                \
      case 0x3:                                                                \
      case 0x4:                                                                \
      case 0x5:                                                                \
      case 0x6:                                                                \
      case 0x7:                                                                \
        if (toLim - *toP < 2) {                                                \
          *fromP = from;                                                       \
          return XML_CONVERT_OUTPUT_EXHAUSTED;                                 \
        }                                                                      \
        *(*toP)++ = ((lo >> 6) | (hi << 2) | UTF8_cval2);                      \
        *(*toP)++ = ((lo & 0x3f) | 0x80);                                      \
        break;                                                                 \
      default:                                                                 \
        if (toLim - *toP < 3) {                                                \
          *fromP = from;                                                       \
          return XML_CONVERT_OUTPUT_EXHAUSTED;                                 \
        }                                                                      \
        /* 16 bits divided 4, 6, 6 amongst 3 bytes */                          \
        *(*toP)++ = ((hi >> 4) | UTF8_cval3);                                  \
        *(*toP)++ = (((hi & 0xf) << 2) | (lo >> 6) | 0x80);                    \
        *(*toP)++ = ((lo & 0x3f) | 0x80);                                      \
        break;                                                                 \
      case 0xD8:                                                               \
      case 0xD9:                                                               \
      case 0xDA:                                                               \
      case 0xDB:                                                               \
        if (toLim - *toP < 4) {                                                \
          *fromP = from;                                                       \
          return XML_CONVERT_OUTPUT_EXHAUSTED;                                 \
        }                                                                      \
        if (fromLim - from < 4) {                                              \
          *fromP = from;                                                       \
          return XML_CONVERT_INPUT_INCOMPLETE;                                 \
        }                                                                      \
        plane = (((hi & 0x3) << 2) | ((lo >> 6) & 0x3)) + 1;                   \
        *(*toP)++ = (char)((plane >> 2) | UTF8_cval4);                         \
        *(*toP)++ = (((lo >> 2) & 0xF) | ((plane & 0x3) << 4) | 0x80);         \
        from += 2;                                                             \
        lo2 = GET_LO(from);                                                    \
        *(*toP)++ = (((lo & 0x3) << 4) | ((GET_HI(from) & 0x3) << 2) |         \
                     (lo2 >> 6) | 0x80);                                       \
        *(*toP)++ = ((lo2 & 0x3f) | 0x80);                                     \
        break;                                                                 \
      }                                                                        \
    }                                                                          \
    *fromP = from;                                                             \
    if (from < fromLim)                                                        \
      return XML_CONVERT_INPUT_INCOMPLETE;                                     \
    else                                                                       \
      return XML_CONVERT_COMPLETED;                                            \
  }

#define DEFINE_UTF16_TO_UTF16(E)                                               \
  static enum XML_Convert_Result PTRCALL E##toUtf16(                           \
      const ENCODING *enc, const char **fromP, const char *fromLim,            \
      unsigned short **toP, const unsigned short *toLim) {                     \
    enum XML_Convert_Result res = XML_CONVERT_COMPLETED;                       \
    UNUSED_P(enc);                                                             \
    fromLim = *fromP + (((fromLim - *fromP) >> 1) << 1); /* shrink to even */  \
    /* Avoid copying first half only of surrogate */                           \
    if (fromLim - *fromP > ((toLim - *toP) << 1) &&                            \
        (GET_HI(fromLim - 2) & 0xF8) == 0xD8) {                                \
      fromLim -= 2;                                                            \
      res = XML_CONVERT_INPUT_INCOMPLETE;                                      \
    }                                                                          \
    for (; *fromP < fromLim && *toP < toLim; *fromP += 2)                      \
      *(*toP)++ = (GET_HI(*fromP) << 8) | GET_LO(*fromP);                      \
    if ((*toP == toLim) && (*fromP < fromLim))                                 \
      return XML_CONVERT_OUTPUT_EXHAUSTED;                                     \
    else                                                                       \
      return res;                                                              \
  }

#define GET_LO(ptr) ((unsigned char)(ptr)[0])
#define GET_HI(ptr) ((unsigned char)(ptr)[1])

DEFINE_UTF16_TO_UTF8(little2_)
DEFINE_UTF16_TO_UTF16(little2_)

#undef GET_LO
#undef GET_HI

#define GET_LO(ptr) ((unsigned char)(ptr)[1])
#define GET_HI(ptr) ((unsigned char)(ptr)[0])

DEFINE_UTF16_TO_UTF8(big2_)
DEFINE_UTF16_TO_UTF16(big2_)

#undef GET_LO
#undef GET_HI

#define LITTLE2_BYTE_TYPE(enc, p)                                              \
  ((p)[1] == 0 ? SB_BYTE_TYPE(enc, p) : unicode_byte_type((p)[1], (p)[0]))
#define LITTLE2_BYTE_TO_ASCII(p) ((p)[1] == 0 ? (p)[0] : -1)
#define LITTLE2_CHAR_MATCHES(p, c) ((p)[1] == 0 && (p)[0] == (c))
#define LITTLE2_IS_NAME_CHAR_MINBPC(p)                                         \
  UCS2_GET_NAMING(namePages, (unsigned char)p[1], (unsigned char)p[0])
#define LITTLE2_IS_NMSTRT_CHAR_MINBPC(p)                                       \
  UCS2_GET_NAMING(nmstrtPages, (unsigned char)p[1], (unsigned char)p[0])

#ifdef XML_MIN_SIZE

static int PTRFASTCALL little2_byteType(const ENCODING *enc, const char *p) {
  return LITTLE2_BYTE_TYPE(enc, p);
}

static int PTRFASTCALL little2_byteToAscii(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return LITTLE2_BYTE_TO_ASCII(p);
}

static int PTRCALL little2_charMatches(const ENCODING *enc, const char *p,
                                       int c) {
  UNUSED_P(enc);
  return LITTLE2_CHAR_MATCHES(p, c);
}

static int PTRFASTCALL little2_isNameMin(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return LITTLE2_IS_NAME_CHAR_MINBPC(p);
}

static int PTRFASTCALL little2_isNmstrtMin(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return LITTLE2_IS_NMSTRT_CHAR_MINBPC(p);
}

#undef VTABLE
#define VTABLE VTABLE1, little2_toUtf8, little2_toUtf16

#else /* not XML_MIN_SIZE */

#undef PREFIX
#define PREFIX(ident) little2_##ident
#define MINBPC(enc) 2
/* CHAR_MATCHES is guaranteed to have MINBPC bytes available. */
#define BYTE_TYPE(enc, p) LITTLE2_BYTE_TYPE(enc, p)
#define BYTE_TO_ASCII(enc, p) LITTLE2_BYTE_TO_ASCII(p)
#define CHAR_MATCHES(enc, p, c) LITTLE2_CHAR_MATCHES(p, c)
#define IS_NAME_CHAR(enc, p, n) 0
#define IS_NAME_CHAR_MINBPC(enc, p) LITTLE2_IS_NAME_CHAR_MINBPC(p)
#define IS_NMSTRT_CHAR(enc, p, n) (0)
#define IS_NMSTRT_CHAR_MINBPC(enc, p) LITTLE2_IS_NMSTRT_CHAR_MINBPC(p)

#define XML_TOK_IMPL_C
/* --- INLINED xmltok_impl.c --- */

#ifdef XML_TOK_IMPL_C

#ifndef IS_INVALID_CHAR // i.e. for UTF-16 and XML_MIN_SIZE not defined
#define IS_INVALID_CHAR(enc, ptr, n) (0)
#endif

#define INVALID_LEAD_CASE(n, ptr, nextTokPtr)                                  \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n)                                                         \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n)) {                                        \
      *(nextTokPtr) = (ptr);                                                   \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    ptr += n;                                                                  \
    break;

#define INVALID_CASES(ptr, nextTokPtr)                                         \
  INVALID_LEAD_CASE(2, ptr, nextTokPtr)                                        \
  INVALID_LEAD_CASE(3, ptr, nextTokPtr)                                        \
  INVALID_LEAD_CASE(4, ptr, nextTokPtr)                                        \
  case BT_NONXML:                                                              \
  case BT_MALFORM:                                                             \
  case BT_TRAIL:                                                               \
    *(nextTokPtr) = (ptr);                                                     \
    return XML_TOK_INVALID;

#define CHECK_NAME_CASE(n, enc, ptr, end, nextTokPtr)                          \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n)                                                         \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n) || !IS_NAME_CHAR(enc, ptr, n)) {          \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    ptr += n;                                                                  \
    break;

#define CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)                            \
  case BT_NONASCII:                                                            \
    if (!IS_NAME_CHAR_MINBPC(enc, ptr)) {                                      \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    /* fall through */                                                         \
  case BT_NMSTRT:                                                              \
  case BT_HEX:                                                                 \
  case BT_DIGIT:                                                               \
  case BT_NAME:                                                                \
  case BT_MINUS:                                                               \
    ptr += MINBPC(enc);                                                        \
    break;                                                                     \
    CHECK_NAME_CASE(2, enc, ptr, end, nextTokPtr)                              \
    CHECK_NAME_CASE(3, enc, ptr, end, nextTokPtr)                              \
    CHECK_NAME_CASE(4, enc, ptr, end, nextTokPtr)

#define CHECK_NMSTRT_CASE(n, enc, ptr, end, nextTokPtr)                        \
  case BT_LEAD##n:                                                             \
    if ((end) - (ptr) < (n))                                                   \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n) || !IS_NMSTRT_CHAR(enc, ptr, n)) {        \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    ptr += n;                                                                  \
    break;

#define CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)                          \
  case BT_NONASCII:                                                            \
    if (!IS_NMSTRT_CHAR_MINBPC(enc, ptr)) {                                    \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    /* fall through */                                                         \
  case BT_NMSTRT:                                                              \
  case BT_HEX:                                                                 \
    ptr += MINBPC(enc);                                                        \
    break;                                                                     \
    CHECK_NMSTRT_CASE(2, enc, ptr, end, nextTokPtr)                            \
    CHECK_NMSTRT_CASE(3, enc, ptr, end, nextTokPtr)                            \
    CHECK_NMSTRT_CASE(4, enc, ptr, end, nextTokPtr)

#ifndef PREFIX
#define PREFIX(ident) ident
#endif

#define HAS_CHARS(enc, ptr, end, count)                                        \
  ((end) - (ptr) >= ((count) * MINBPC(enc)))

#define HAS_CHAR(enc, ptr, end) HAS_CHARS(enc, ptr, end, 1)

#define REQUIRE_CHARS(enc, ptr, end, count)                                    \
  {                                                                            \
    if (!HAS_CHARS(enc, ptr, end, count)) {                                    \
      return XML_TOK_PARTIAL;                                                  \
    }                                                                          \
  }

#define REQUIRE_CHAR(enc, ptr, end) REQUIRE_CHARS(enc, ptr, end, 1)

/* ptr points to character following "<!-" */

static int PTRCALL PREFIX(scanComment)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  if (HAS_CHAR(enc, ptr, end)) {
    if (!CHAR_MATCHES(enc, ptr, ASCII_MINUS)) {
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
    ptr += MINBPC(enc);
    while (HAS_CHAR(enc, ptr, end)) {
      switch (BYTE_TYPE(enc, ptr)) {
        INVALID_CASES(ptr, nextTokPtr)
      case BT_MINUS:
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        if (CHAR_MATCHES(enc, ptr, ASCII_MINUS)) {
          ptr += MINBPC(enc);
          REQUIRE_CHAR(enc, ptr, end);
          if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
            *nextTokPtr = ptr;
            return XML_TOK_INVALID;
          }
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_COMMENT;
        }
        break;
      default:
        ptr += MINBPC(enc);
        break;
      }
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "<!" */

static int PTRCALL PREFIX(scanDecl)(const ENCODING *enc, const char *ptr,
                                    const char *end, const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_MINUS:
    return PREFIX(scanComment)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_LSQB:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_COND_SECT_OPEN;
  case BT_NMSTRT:
  case BT_HEX:
    ptr += MINBPC(enc);
    break;
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_PERCNT:
      REQUIRE_CHARS(enc, ptr, end, 2);
      /* don't allow <!ENTITY% foo "whatever"> */
      switch (BYTE_TYPE(enc, ptr + MINBPC(enc))) {
      case BT_S:
      case BT_CR:
      case BT_LF:
      case BT_PERCNT:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      /* fall through */
    case BT_S:
    case BT_CR:
    case BT_LF:
      *nextTokPtr = ptr;
      return XML_TOK_DECL_OPEN;
    case BT_NMSTRT:
    case BT_HEX:
      ptr += MINBPC(enc);
      break;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(checkPiTarget)(const ENCODING *enc, const char *ptr,
                                         const char *end, int *tokPtr) {
  int upper = 0;
  UNUSED_P(enc);
  *tokPtr = XML_TOK_PI;
  if (end - ptr != MINBPC(enc) * 3)
    return 1;
  switch (BYTE_TO_ASCII(enc, ptr)) {
  case ASCII_x:
    break;
  case ASCII_X:
    upper = 1;
    break;
  default:
    return 1;
  }
  ptr += MINBPC(enc);
  switch (BYTE_TO_ASCII(enc, ptr)) {
  case ASCII_m:
    break;
  case ASCII_M:
    upper = 1;
    break;
  default:
    return 1;
  }
  ptr += MINBPC(enc);
  switch (BYTE_TO_ASCII(enc, ptr)) {
  case ASCII_l:
    break;
  case ASCII_L:
    upper = 1;
    break;
  default:
    return 1;
  }
  if (upper)
    return 0;
  *tokPtr = XML_TOK_XML_DECL;
  return 1;
}

/* ptr points to character following "<?" */

static int PTRCALL PREFIX(scanPi)(const ENCODING *enc, const char *ptr,
                                  const char *end, const char **nextTokPtr) {
  int tok;
  const char *target = ptr;
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_S:
    case BT_CR:
    case BT_LF:
      if (!PREFIX(checkPiTarget)(enc, target, ptr, &tok)) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      ptr += MINBPC(enc);
      while (HAS_CHAR(enc, ptr, end)) {
        switch (BYTE_TYPE(enc, ptr)) {
          INVALID_CASES(ptr, nextTokPtr)
        case BT_QUEST:
          ptr += MINBPC(enc);
          REQUIRE_CHAR(enc, ptr, end);
          if (CHAR_MATCHES(enc, ptr, ASCII_GT)) {
            *nextTokPtr = ptr + MINBPC(enc);
            return tok;
          }
          break;
        default:
          ptr += MINBPC(enc);
          break;
        }
      }
      return XML_TOK_PARTIAL;
    case BT_QUEST:
      if (!PREFIX(checkPiTarget)(enc, target, ptr, &tok)) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (CHAR_MATCHES(enc, ptr, ASCII_GT)) {
        *nextTokPtr = ptr + MINBPC(enc);
        return tok;
      }
      /* fall through */
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(scanCdataSection)(const ENCODING *enc,
                                            const char *ptr, const char *end,
                                            const char **nextTokPtr) {
  static const char CDATA_LSQB[] = {ASCII_C, ASCII_D, ASCII_A,
                                    ASCII_T, ASCII_A, ASCII_LSQB};
  int i;
  UNUSED_P(enc);
  /* CDATA[ */
  REQUIRE_CHARS(enc, ptr, end, 6);
  for (i = 0; i < 6; i++, ptr += MINBPC(enc)) {
    if (!CHAR_MATCHES(enc, ptr, CDATA_LSQB[i])) {
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_CDATA_SECT_OPEN;
}

static int PTRCALL PREFIX(cdataSectionTok)(const ENCODING *enc, const char *ptr,
                                           const char *end,
                                           const char **nextTokPtr) {
  if (ptr >= end)
    return XML_TOK_NONE;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      if (n == 0)
        return XML_TOK_PARTIAL;
      end = ptr + n;
    }
  }
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_RSQB:
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    if (!CHAR_MATCHES(enc, ptr, ASCII_RSQB))
      break;
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
      ptr -= MINBPC(enc);
      break;
    }
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_CDATA_SECT_CLOSE;
  case BT_CR:
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    if (BYTE_TYPE(enc, ptr) == BT_LF)
      ptr += MINBPC(enc);
    *nextTokPtr = ptr;
    return XML_TOK_DATA_NEWLINE;
  case BT_LF:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_DATA_NEWLINE;
    INVALID_CASES(ptr, nextTokPtr)
  default:
    ptr += MINBPC(enc);
    break;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n || IS_INVALID_CHAR(enc, ptr, n)) {                       \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_DATA_CHARS;                                               \
    }                                                                          \
    ptr += n;                                                                  \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_NONXML:
    case BT_MALFORM:
    case BT_TRAIL:
    case BT_CR:
    case BT_LF:
    case BT_RSQB:
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

/* ptr points to character following "</" */

static int PTRCALL PREFIX(scanEndTag)(const ENCODING *enc, const char *ptr,
                                      const char *end,
                                      const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_S:
    case BT_CR:
    case BT_LF:
      for (ptr += MINBPC(enc); HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
        switch (BYTE_TYPE(enc, ptr)) {
        case BT_S:
        case BT_CR:
        case BT_LF:
          break;
        case BT_GT:
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_END_TAG;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
      }
      return XML_TOK_PARTIAL;
#ifdef XML_NS
    case BT_COLON:
      /* no need to check qname syntax here,
         since end-tag must match exactly */
      ptr += MINBPC(enc);
      break;
#endif
    case BT_GT:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_END_TAG;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "&#X" */

static int PTRCALL PREFIX(scanHexCharRef)(const ENCODING *enc, const char *ptr,
                                          const char *end,
                                          const char **nextTokPtr) {
  if (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_DIGIT:
    case BT_HEX:
      break;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
    for (ptr += MINBPC(enc); HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_DIGIT:
      case BT_HEX:
        break;
      case BT_SEMI:
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_CHAR_REF;
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "&#" */

static int PTRCALL PREFIX(scanCharRef)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  if (HAS_CHAR(enc, ptr, end)) {
    if (CHAR_MATCHES(enc, ptr, ASCII_x))
      return PREFIX(scanHexCharRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_DIGIT:
      break;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
    for (ptr += MINBPC(enc); HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_DIGIT:
        break;
      case BT_SEMI:
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_CHAR_REF;
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "&" */

static int PTRCALL PREFIX(scanRef)(const ENCODING *enc, const char *ptr,
                                   const char *end, const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  case BT_NUM:
    return PREFIX(scanCharRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_SEMI:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_ENTITY_REF;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following first character of attribute name */

static int PTRCALL PREFIX(scanAtts)(const ENCODING *enc, const char *ptr,
                                    const char *end, const char **nextTokPtr) {
#ifdef XML_NS
  int hadColon = 0;
#endif
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
#ifdef XML_NS
    case BT_COLON:
      if (hadColon) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      hadColon = 1;
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      switch (BYTE_TYPE(enc, ptr)) {
        CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      break;
#endif
    case BT_S:
    case BT_CR:
    case BT_LF:
      for (;;) {
        int t;

        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        t = BYTE_TYPE(enc, ptr);
        if (t == BT_EQUALS)
          break;
        switch (t) {
        case BT_S:
        case BT_LF:
        case BT_CR:
          break;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
      }
      /* fall through */
    case BT_EQUALS: {
      int open;
#ifdef XML_NS
      hadColon = 0;
#endif
      for (;;) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        open = BYTE_TYPE(enc, ptr);
        if (open == BT_QUOT || open == BT_APOS)
          break;
        switch (open) {
        case BT_S:
        case BT_LF:
        case BT_CR:
          break;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
      }
      ptr += MINBPC(enc);
      /* in attribute value */
      for (;;) {
        int t;
        REQUIRE_CHAR(enc, ptr, end);
        t = BYTE_TYPE(enc, ptr);
        if (t == open)
          break;
        switch (t) {
          INVALID_CASES(ptr, nextTokPtr)
        case BT_AMP: {
          int tok = PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, &ptr);
          if (tok <= 0) {
            if (tok == XML_TOK_INVALID)
              *nextTokPtr = ptr;
            return tok;
          }
          break;
        }
        case BT_LT:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        default:
          ptr += MINBPC(enc);
          break;
        }
      }
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_S:
      case BT_CR:
      case BT_LF:
        break;
      case BT_SOL:
        goto sol;
      case BT_GT:
        goto gt;
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      /* ptr points to closing quote */
      for (;;) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        switch (BYTE_TYPE(enc, ptr)) {
          CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
        case BT_S:
        case BT_CR:
        case BT_LF:
          continue;
        case BT_GT:
        gt:
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_START_TAG_WITH_ATTS;
        case BT_SOL:
        sol:
          ptr += MINBPC(enc);
          REQUIRE_CHAR(enc, ptr, end);
          if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
            *nextTokPtr = ptr;
            return XML_TOK_INVALID;
          }
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_EMPTY_ELEMENT_WITH_ATTS;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
        break;
      }
      break;
    }
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "<" */

static int PTRCALL PREFIX(scanLt)(const ENCODING *enc, const char *ptr,
                                  const char *end, const char **nextTokPtr) {
#ifdef XML_NS
  int hadColon;
#endif
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  case BT_EXCL:
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_MINUS:
      return PREFIX(scanComment)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    case BT_LSQB:
      return PREFIX(scanCdataSection)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  case BT_QUEST:
    return PREFIX(scanPi)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_SOL:
    return PREFIX(scanEndTag)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
#ifdef XML_NS
  hadColon = 0;
#endif
  /* we have a start-tag */
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
#ifdef XML_NS
    case BT_COLON:
      if (hadColon) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      hadColon = 1;
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      switch (BYTE_TYPE(enc, ptr)) {
        CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      break;
#endif
    case BT_S:
    case BT_CR:
    case BT_LF: {
      ptr += MINBPC(enc);
      while (HAS_CHAR(enc, ptr, end)) {
        switch (BYTE_TYPE(enc, ptr)) {
          CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
        case BT_GT:
          goto gt;
        case BT_SOL:
          goto sol;
        case BT_S:
        case BT_CR:
        case BT_LF:
          ptr += MINBPC(enc);
          continue;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
        return PREFIX(scanAtts)(enc, ptr, end, nextTokPtr);
      }
      return XML_TOK_PARTIAL;
    }
    case BT_GT:
    gt:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_START_TAG_NO_ATTS;
    case BT_SOL:
    sol:
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_EMPTY_ELEMENT_NO_ATTS;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(contentTok)(const ENCODING *enc, const char *ptr,
                                      const char *end,
                                      const char **nextTokPtr) {
  if (ptr >= end)
    return XML_TOK_NONE;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      if (n == 0)
        return XML_TOK_PARTIAL;
      end = ptr + n;
    }
  }
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_LT:
    return PREFIX(scanLt)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_AMP:
    return PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_CR:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return XML_TOK_TRAILING_CR;
    if (BYTE_TYPE(enc, ptr) == BT_LF)
      ptr += MINBPC(enc);
    *nextTokPtr = ptr;
    return XML_TOK_DATA_NEWLINE;
  case BT_LF:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_DATA_NEWLINE;
  case BT_RSQB:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return XML_TOK_TRAILING_RSQB;
    if (!CHAR_MATCHES(enc, ptr, ASCII_RSQB))
      break;
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return XML_TOK_TRAILING_RSQB;
    if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
      ptr -= MINBPC(enc);
      break;
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
    INVALID_CASES(ptr, nextTokPtr)
  default:
    ptr += MINBPC(enc);
    break;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n || IS_INVALID_CHAR(enc, ptr, n)) {                       \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_DATA_CHARS;                                               \
    }                                                                          \
    ptr += n;                                                                  \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_RSQB:
      if (HAS_CHARS(enc, ptr, end, 2)) {
        if (!CHAR_MATCHES(enc, ptr + MINBPC(enc), ASCII_RSQB)) {
          ptr += MINBPC(enc);
          break;
        }
        if (HAS_CHARS(enc, ptr, end, 3)) {
          if (!CHAR_MATCHES(enc, ptr + 2 * MINBPC(enc), ASCII_GT)) {
            ptr += MINBPC(enc);
            break;
          }
          *nextTokPtr = ptr + 2 * MINBPC(enc);
          return XML_TOK_INVALID;
        }
      }
      /* fall through */
    case BT_AMP:
    case BT_LT:
    case BT_NONXML:
    case BT_MALFORM:
    case BT_TRAIL:
    case BT_CR:
    case BT_LF:
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

/* ptr points to character following "%" */

static int PTRCALL PREFIX(scanPercent)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  case BT_S:
  case BT_LF:
  case BT_CR:
  case BT_PERCNT:
    *nextTokPtr = ptr;
    return XML_TOK_PERCENT;
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_SEMI:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_PARAM_ENTITY_REF;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(scanPoundName)(const ENCODING *enc, const char *ptr,
                                         const char *end,
                                         const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_CR:
    case BT_LF:
    case BT_S:
    case BT_RPAR:
    case BT_GT:
    case BT_PERCNT:
    case BT_VERBAR:
      *nextTokPtr = ptr;
      return XML_TOK_POUND_NAME;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return -XML_TOK_POUND_NAME;
}

static int PTRCALL PREFIX(scanLit)(int open, const ENCODING *enc,
                                   const char *ptr, const char *end,
                                   const char **nextTokPtr) {
  while (HAS_CHAR(enc, ptr, end)) {
    int t = BYTE_TYPE(enc, ptr);
    switch (t) {
      INVALID_CASES(ptr, nextTokPtr)
    case BT_QUOT:
    case BT_APOS:
      ptr += MINBPC(enc);
      if (t != open)
        break;
      if (!HAS_CHAR(enc, ptr, end))
        return -XML_TOK_LITERAL;
      *nextTokPtr = ptr;
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_S:
      case BT_CR:
      case BT_LF:
      case BT_GT:
      case BT_PERCNT:
      case BT_LSQB:
        return XML_TOK_LITERAL;
      default:
        return XML_TOK_INVALID;
      }
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(prologTok)(const ENCODING *enc, const char *ptr,
                                     const char *end, const char **nextTokPtr) {
  int tok;
  if (ptr >= end)
    return XML_TOK_NONE;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      if (n == 0)
        return XML_TOK_PARTIAL;
      end = ptr + n;
    }
  }
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_QUOT:
    return PREFIX(scanLit)(BT_QUOT, enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_APOS:
    return PREFIX(scanLit)(BT_APOS, enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_LT: {
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_EXCL:
      return PREFIX(scanDecl)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    case BT_QUEST:
      return PREFIX(scanPi)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    case BT_NMSTRT:
    case BT_HEX:
    case BT_NONASCII:
    case BT_LEAD2:
    case BT_LEAD3:
    case BT_LEAD4:
      *nextTokPtr = ptr - MINBPC(enc);
      return XML_TOK_INSTANCE_START;
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  case BT_CR:
    if (ptr + MINBPC(enc) == end) {
      *nextTokPtr = end;
      /* indicate that this might be part of a CR/LF pair */
      return -XML_TOK_PROLOG_S;
    }
    /* fall through */
  case BT_S:
  case BT_LF:
    for (;;) {
      ptr += MINBPC(enc);
      if (!HAS_CHAR(enc, ptr, end))
        break;
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_S:
      case BT_LF:
        break;
      case BT_CR:
        /* don't split CR/LF pair */
        if (ptr + MINBPC(enc) != end)
          break;
        /* fall through */
      default:
        *nextTokPtr = ptr;
        return XML_TOK_PROLOG_S;
      }
    }
    *nextTokPtr = ptr;
    return XML_TOK_PROLOG_S;
  case BT_PERCNT:
    return PREFIX(scanPercent)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_COMMA:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_COMMA;
  case BT_LSQB:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_OPEN_BRACKET;
  case BT_RSQB:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return -XML_TOK_CLOSE_BRACKET;
    if (CHAR_MATCHES(enc, ptr, ASCII_RSQB)) {
      REQUIRE_CHARS(enc, ptr, end, 2);
      if (CHAR_MATCHES(enc, ptr + MINBPC(enc), ASCII_GT)) {
        *nextTokPtr = ptr + 2 * MINBPC(enc);
        return XML_TOK_COND_SECT_CLOSE;
      }
    }
    *nextTokPtr = ptr;
    return XML_TOK_CLOSE_BRACKET;
  case BT_LPAR:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_OPEN_PAREN;
  case BT_RPAR:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return -XML_TOK_CLOSE_PAREN;
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_AST:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_CLOSE_PAREN_ASTERISK;
    case BT_QUEST:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_CLOSE_PAREN_QUESTION;
    case BT_PLUS:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_CLOSE_PAREN_PLUS;
    case BT_CR:
    case BT_LF:
    case BT_S:
    case BT_GT:
    case BT_COMMA:
    case BT_VERBAR:
    case BT_RPAR:
      *nextTokPtr = ptr;
      return XML_TOK_CLOSE_PAREN;
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  case BT_VERBAR:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_OR;
  case BT_GT:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_DECL_CLOSE;
  case BT_NUM:
    return PREFIX(scanPoundName)(enc, ptr + MINBPC(enc), end, nextTokPtr);
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n)                                                         \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n)) {                                        \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    if (IS_NMSTRT_CHAR(enc, ptr, n)) {                                         \
      ptr += n;                                                                \
      tok = XML_TOK_NAME;                                                      \
      break;                                                                   \
    }                                                                          \
    if (IS_NAME_CHAR(enc, ptr, n)) {                                           \
      ptr += n;                                                                \
      tok = XML_TOK_NMTOKEN;                                                   \
      break;                                                                   \
    }                                                                          \
    *nextTokPtr = ptr;                                                         \
    return XML_TOK_INVALID;
    LEAD_CASE(2)
    LEAD_CASE(3)
    LEAD_CASE(4)
#undef LEAD_CASE
  case BT_NMSTRT:
  case BT_HEX:
    tok = XML_TOK_NAME;
    ptr += MINBPC(enc);
    break;
  case BT_DIGIT:
  case BT_NAME:
  case BT_MINUS:
#ifdef XML_NS
  case BT_COLON:
#endif
    tok = XML_TOK_NMTOKEN;
    ptr += MINBPC(enc);
    break;
  case BT_NONASCII:
    if (IS_NMSTRT_CHAR_MINBPC(enc, ptr)) {
      ptr += MINBPC(enc);
      tok = XML_TOK_NAME;
      break;
    }
    if (IS_NAME_CHAR_MINBPC(enc, ptr)) {
      ptr += MINBPC(enc);
      tok = XML_TOK_NMTOKEN;
      break;
    }
    /* fall through */
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_GT:
    case BT_RPAR:
    case BT_COMMA:
    case BT_VERBAR:
    case BT_LSQB:
    case BT_PERCNT:
    case BT_S:
    case BT_CR:
    case BT_LF:
      *nextTokPtr = ptr;
      return tok;
#ifdef XML_NS
    case BT_COLON:
      ptr += MINBPC(enc);
      switch (tok) {
      case XML_TOK_NAME:
        REQUIRE_CHAR(enc, ptr, end);
        tok = XML_TOK_PREFIXED_NAME;
        switch (BYTE_TYPE(enc, ptr)) {
          CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
        default:
          tok = XML_TOK_NMTOKEN;
          break;
        }
        break;
      case XML_TOK_PREFIXED_NAME:
        tok = XML_TOK_NMTOKEN;
        break;
      }
      break;
#endif
    case BT_PLUS:
      if (tok == XML_TOK_NMTOKEN) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_NAME_PLUS;
    case BT_AST:
      if (tok == XML_TOK_NMTOKEN) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_NAME_ASTERISK;
    case BT_QUEST:
      if (tok == XML_TOK_NMTOKEN) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_NAME_QUESTION;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return -tok;
}

static int PTRCALL PREFIX(attributeValueTok)(const ENCODING *enc,
                                             const char *ptr, const char *end,
                                             const char **nextTokPtr) {
  const char *start;
  if (ptr >= end)
    return XML_TOK_NONE;
  else if (!HAS_CHAR(enc, ptr, end)) {
    /* This line cannot be executed.  The incoming data has already
     * been tokenized once, so incomplete characters like this have
     * already been eliminated from the input.  Retaining the paranoia
     * check is still valuable, however.
     */
    return XML_TOK_PARTIAL; /* LCOV_EXCL_LINE */
  }
  start = ptr;
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_AMP:
      if (ptr == start)
        return PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_LT:
      /* this is for inside entity references */
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    case BT_LF:
      if (ptr == start) {
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_CR:
      if (ptr == start) {
        ptr += MINBPC(enc);
        if (!HAS_CHAR(enc, ptr, end))
          return XML_TOK_TRAILING_CR;
        if (BYTE_TYPE(enc, ptr) == BT_LF)
          ptr += MINBPC(enc);
        *nextTokPtr = ptr;
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_S:
      if (ptr == start) {
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_ATTRIBUTE_VALUE_S;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

static int PTRCALL PREFIX(entityValueTok)(const ENCODING *enc, const char *ptr,
                                          const char *end,
                                          const char **nextTokPtr) {
  const char *start;
  if (ptr >= end)
    return XML_TOK_NONE;
  else if (!HAS_CHAR(enc, ptr, end)) {
    /* This line cannot be executed.  The incoming data has already
     * been tokenized once, so incomplete characters like this have
     * already been eliminated from the input.  Retaining the paranoia
     * check is still valuable, however.
     */
    return XML_TOK_PARTIAL; /* LCOV_EXCL_LINE */
  }
  start = ptr;
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_AMP:
      if (ptr == start)
        return PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_PERCNT:
      if (ptr == start) {
        int tok = PREFIX(scanPercent)(enc, ptr + MINBPC(enc), end, nextTokPtr);
        return (tok == XML_TOK_PERCENT) ? XML_TOK_INVALID : tok;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_LF:
      if (ptr == start) {
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_CR:
      if (ptr == start) {
        ptr += MINBPC(enc);
        if (!HAS_CHAR(enc, ptr, end))
          return XML_TOK_TRAILING_CR;
        if (BYTE_TYPE(enc, ptr) == BT_LF)
          ptr += MINBPC(enc);
        *nextTokPtr = ptr;
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

#ifdef XML_DTD

static int PTRCALL PREFIX(ignoreSectionTok)(const ENCODING *enc,
                                            const char *ptr, const char *end,
                                            const char **nextTokPtr) {
  int level = 0;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      end = ptr + n;
    }
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      INVALID_CASES(ptr, nextTokPtr)
    case BT_LT:
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (CHAR_MATCHES(enc, ptr, ASCII_EXCL)) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        if (CHAR_MATCHES(enc, ptr, ASCII_LSQB)) {
          ++level;
          ptr += MINBPC(enc);
        }
      }
      break;
    case BT_RSQB:
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (CHAR_MATCHES(enc, ptr, ASCII_RSQB)) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        if (CHAR_MATCHES(enc, ptr, ASCII_GT)) {
          ptr += MINBPC(enc);
          if (level == 0) {
            *nextTokPtr = ptr;
            return XML_TOK_IGNORE_SECT;
          }
          --level;
        }
      }
      break;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  return XML_TOK_PARTIAL;
}

#endif /* XML_DTD */

static int PTRCALL PREFIX(isPublicId)(const ENCODING *enc, const char *ptr,
                                      const char *end, const char **badPtr) {
  ptr += MINBPC(enc);
  end -= MINBPC(enc);
  for (; HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_DIGIT:
    case BT_HEX:
    case BT_MINUS:
    case BT_APOS:
    case BT_LPAR:
    case BT_RPAR:
    case BT_PLUS:
    case BT_COMMA:
    case BT_SOL:
    case BT_EQUALS:
    case BT_QUEST:
    case BT_CR:
    case BT_LF:
    case BT_SEMI:
    case BT_EXCL:
    case BT_AST:
    case BT_PERCNT:
    case BT_NUM:
#ifdef XML_NS
    case BT_COLON:
#endif
      break;
    case BT_S:
      if (CHAR_MATCHES(enc, ptr, ASCII_TAB)) {
        *badPtr = ptr;
        return 0;
      }
      break;
    case BT_NAME:
    case BT_NMSTRT:
      if (!(BYTE_TO_ASCII(enc, ptr) & ~0x7f))
        break;
      /* fall through */
    default:
      switch (BYTE_TO_ASCII(enc, ptr)) {
      case 0x24: /* $ */
      case 0x40: /* @ */
        break;
      default:
        *badPtr = ptr;
        return 0;
      }
      break;
    }
  }
  return 1;
}

/* This must only be called for a well-formed start-tag or empty
   element tag.  Returns the number of attributes.  Pointers to the
   first attsMax attributes are stored in atts.
*/

static int PTRCALL PREFIX(getAtts)(const ENCODING *enc, const char *ptr,
                                   int attsMax, ATTRIBUTE *atts) {
  enum { other, inName, inValue } state = inName;
  int nAtts = 0;
  int open = 0; /* defined when state == inValue;
                   initialization just to shut up compilers */

  for (ptr += MINBPC(enc);; ptr += MINBPC(enc)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define START_NAME                                                             \
  if (state == other) {                                                        \
    if (nAtts < attsMax) {                                                     \
      atts[nAtts].name = ptr;                                                  \
      atts[nAtts].normalized = 1;                                              \
    }                                                                          \
    state = inName;                                                            \
  }
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n: /* NOTE: The encoding has already been validated. */        \
    START_NAME ptr += (n - MINBPC(enc));                                       \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_NONASCII:
    case BT_NMSTRT:
    case BT_HEX:
      START_NAME
      break;
#undef START_NAME
    case BT_QUOT:
      if (state != inValue) {
        if (nAtts < attsMax)
          atts[nAtts].valuePtr = ptr + MINBPC(enc);
        state = inValue;
        open = BT_QUOT;
      } else if (open == BT_QUOT) {
        state = other;
        if (nAtts < attsMax)
          atts[nAtts].valueEnd = ptr;
        nAtts++;
      }
      break;
    case BT_APOS:
      if (state != inValue) {
        if (nAtts < attsMax)
          atts[nAtts].valuePtr = ptr + MINBPC(enc);
        state = inValue;
        open = BT_APOS;
      } else if (open == BT_APOS) {
        state = other;
        if (nAtts < attsMax)
          atts[nAtts].valueEnd = ptr;
        nAtts++;
      }
      break;
    case BT_AMP:
      if (nAtts < attsMax)
        atts[nAtts].normalized = 0;
      break;
    case BT_S:
      if (state == inName)
        state = other;
      else if (state == inValue && nAtts < attsMax && atts[nAtts].normalized &&
               (ptr == atts[nAtts].valuePtr ||
                BYTE_TO_ASCII(enc, ptr) != ASCII_SPACE ||
                BYTE_TO_ASCII(enc, ptr + MINBPC(enc)) == ASCII_SPACE ||
                BYTE_TYPE(enc, ptr + MINBPC(enc)) == open))
        atts[nAtts].normalized = 0;
      break;
    case BT_CR:
    case BT_LF:
      /* This case ensures that the first attribute name is counted
         Apart from that we could just change state on the quote. */
      if (state == inName)
        state = other;
      else if (state == inValue && nAtts < attsMax)
        atts[nAtts].normalized = 0;
      break;
    case BT_GT:
    case BT_SOL:
      if (state != inValue)
        return nAtts;
      break;
    default:
      break;
    }
  }
  /* not reached */
}

static int PTRFASTCALL PREFIX(charRefNumber)(const ENCODING *enc,
                                             const char *ptr) {
  int result = 0;
  /* skip &# */
  UNUSED_P(enc);
  ptr += 2 * MINBPC(enc);
  if (CHAR_MATCHES(enc, ptr, ASCII_x)) {
    for (ptr += MINBPC(enc); !CHAR_MATCHES(enc, ptr, ASCII_SEMI);
         ptr += MINBPC(enc)) {
      int c = BYTE_TO_ASCII(enc, ptr);
      switch (c) {
      case ASCII_0:
      case ASCII_1:
      case ASCII_2:
      case ASCII_3:
      case ASCII_4:
      case ASCII_5:
      case ASCII_6:
      case ASCII_7:
      case ASCII_8:
      case ASCII_9:
        result <<= 4;
        result |= (c - ASCII_0);
        break;
      case ASCII_A:
      case ASCII_B:
      case ASCII_C:
      case ASCII_D:
      case ASCII_E:
      case ASCII_F:
        result <<= 4;
        result += 10 + (c - ASCII_A);
        break;
      case ASCII_a:
      case ASCII_b:
      case ASCII_c:
      case ASCII_d:
      case ASCII_e:
      case ASCII_f:
        result <<= 4;
        result += 10 + (c - ASCII_a);
        break;
      }
      if (result >= 0x110000)
        return -1;
    }
  } else {
    for (; !CHAR_MATCHES(enc, ptr, ASCII_SEMI); ptr += MINBPC(enc)) {
      int c = BYTE_TO_ASCII(enc, ptr);
      result *= 10;
      result += (c - ASCII_0);
      if (result >= 0x110000)
        return -1;
    }
  }
  return checkCharRefNumber(result);
}

static int PTRCALL PREFIX(predefinedEntityName)(const ENCODING *enc,
                                                const char *ptr,
                                                const char *end) {
  UNUSED_P(enc);
  switch ((end - ptr) / MINBPC(enc)) {
  case 2:
    if (CHAR_MATCHES(enc, ptr + MINBPC(enc), ASCII_t)) {
      switch (BYTE_TO_ASCII(enc, ptr)) {
      case ASCII_l:
        return ASCII_LT;
      case ASCII_g:
        return ASCII_GT;
      }
    }
    break;
  case 3:
    if (CHAR_MATCHES(enc, ptr, ASCII_a)) {
      ptr += MINBPC(enc);
      if (CHAR_MATCHES(enc, ptr, ASCII_m)) {
        ptr += MINBPC(enc);
        if (CHAR_MATCHES(enc, ptr, ASCII_p))
          return ASCII_AMP;
      }
    }
    break;
  case 4:
    switch (BYTE_TO_ASCII(enc, ptr)) {
    case ASCII_q:
      ptr += MINBPC(enc);
      if (CHAR_MATCHES(enc, ptr, ASCII_u)) {
        ptr += MINBPC(enc);
        if (CHAR_MATCHES(enc, ptr, ASCII_o)) {
          ptr += MINBPC(enc);
          if (CHAR_MATCHES(enc, ptr, ASCII_t))
            return ASCII_QUOT;
        }
      }
      break;
    case ASCII_a:
      ptr += MINBPC(enc);
      if (CHAR_MATCHES(enc, ptr, ASCII_p)) {
        ptr += MINBPC(enc);
        if (CHAR_MATCHES(enc, ptr, ASCII_o)) {
          ptr += MINBPC(enc);
          if (CHAR_MATCHES(enc, ptr, ASCII_s))
            return ASCII_APOS;
        }
      }
      break;
    }
  }
  return 0;
}

static int PTRCALL PREFIX(nameMatchesAscii)(const ENCODING *enc,
                                            const char *ptr1, const char *end1,
                                            const char *ptr2) {
  UNUSED_P(enc);
  for (; *ptr2; ptr1 += MINBPC(enc), ptr2++) {
    if (end1 - ptr1 < MINBPC(enc)) {
      /* This line cannot be executed.  The incoming data has already
       * been tokenized once, so incomplete characters like this have
       * already been eliminated from the input.  Retaining the
       * paranoia check is still valuable, however.
       */
      return 0; /* LCOV_EXCL_LINE */
    }
    if (!CHAR_MATCHES(enc, ptr1, *ptr2))
      return 0;
  }
  return ptr1 == end1;
}

static int PTRFASTCALL PREFIX(nameLength)(const ENCODING *enc,
                                          const char *ptr) {
  const char *start = ptr;
  for (;;) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_NONASCII:
    case BT_NMSTRT:
#ifdef XML_NS
    case BT_COLON:
#endif
    case BT_HEX:
    case BT_DIGIT:
    case BT_NAME:
    case BT_MINUS:
      ptr += MINBPC(enc);
      break;
    default:
      return (int)(ptr - start);
    }
  }
}

static const char *PTRFASTCALL PREFIX(skipS)(const ENCODING *enc,
                                             const char *ptr) {
  for (;;) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_LF:
    case BT_CR:
    case BT_S:
      ptr += MINBPC(enc);
      break;
    default:
      return ptr;
    }
  }
}

static void PTRCALL PREFIX(updatePosition)(const ENCODING *enc, const char *ptr,
                                           const char *end, POSITION *pos) {
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    pos->columnNumber++;                                                       \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_LF:
      pos->columnNumber = 0;
      pos->lineNumber++;
      ptr += MINBPC(enc);
      break;
    case BT_CR:
      pos->lineNumber++;
      ptr += MINBPC(enc);
      if (HAS_CHAR(enc, ptr, end) && BYTE_TYPE(enc, ptr) == BT_LF)
        ptr += MINBPC(enc);
      pos->columnNumber = 0;
      break;
    default:
      ptr += MINBPC(enc);
      pos->columnNumber++;
      break;
    }
  }
}

#undef DO_LEAD_CASE
#undef MULTIBYTE_CASES
#undef INVALID_CASES
#undef CHECK_NAME_CASE
#undef CHECK_NAME_CASES
#undef CHECK_NMSTRT_CASE
#undef CHECK_NMSTRT_CASES

#endif /* XML_TOK_IMPL_C */
#undef XML_TOK_IMPL_C

#undef MINBPC
#undef BYTE_TYPE
#undef BYTE_TO_ASCII
#undef CHAR_MATCHES
#undef IS_NAME_CHAR
#undef IS_NAME_CHAR_MINBPC
#undef IS_NMSTRT_CHAR
#undef IS_NMSTRT_CHAR_MINBPC
#undef IS_INVALID_CHAR

#endif /* not XML_MIN_SIZE */

#ifdef XML_NS

static const struct normal_encoding little2_encoding_ns = {
    {VTABLE, 2, 0,
#if BYTEORDER == 1234
     1
#else
     0
#endif
    },
    {
#include "asciitab.h"
#include "latin1tab.h"
    },
    STANDARD_VTABLE(little2_) NULL_VTABLE};

#endif

static const struct normal_encoding little2_encoding = {
    {VTABLE, 2, 0,
#if BYTEORDER == 1234
     1
#else
     0
#endif
    },
    {
#define BT_COLON BT_NMSTRT
#include "asciitab.h"
#undef BT_COLON
#include "latin1tab.h"
    },
    STANDARD_VTABLE(little2_) NULL_VTABLE};

#if BYTEORDER != 4321

#ifdef XML_NS

static const struct normal_encoding internal_little2_encoding_ns = {
    {VTABLE, 2, 0, 1},
    {
#include "iasciitab.h"
#include "latin1tab.h"
    },
    STANDARD_VTABLE(little2_) NULL_VTABLE};

#endif

static const struct normal_encoding internal_little2_encoding = {
    {VTABLE, 2, 0, 1},
    {
#define BT_COLON BT_NMSTRT
#include "iasciitab.h"
#undef BT_COLON
#include "latin1tab.h"
    },
    STANDARD_VTABLE(little2_) NULL_VTABLE};

#endif

#define BIG2_BYTE_TYPE(enc, p)                                                 \
  ((p)[0] == 0 ? SB_BYTE_TYPE(enc, p + 1) : unicode_byte_type((p)[0], (p)[1]))
#define BIG2_BYTE_TO_ASCII(p) ((p)[0] == 0 ? (p)[1] : -1)
#define BIG2_CHAR_MATCHES(p, c) ((p)[0] == 0 && (p)[1] == (c))
#define BIG2_IS_NAME_CHAR_MINBPC(p)                                            \
  UCS2_GET_NAMING(namePages, (unsigned char)p[0], (unsigned char)p[1])
#define BIG2_IS_NMSTRT_CHAR_MINBPC(p)                                          \
  UCS2_GET_NAMING(nmstrtPages, (unsigned char)p[0], (unsigned char)p[1])

#ifdef XML_MIN_SIZE

static int PTRFASTCALL big2_byteType(const ENCODING *enc, const char *p) {
  return BIG2_BYTE_TYPE(enc, p);
}

static int PTRFASTCALL big2_byteToAscii(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return BIG2_BYTE_TO_ASCII(p);
}

static int PTRCALL big2_charMatches(const ENCODING *enc, const char *p, int c) {
  UNUSED_P(enc);
  return BIG2_CHAR_MATCHES(p, c);
}

static int PTRFASTCALL big2_isNameMin(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return BIG2_IS_NAME_CHAR_MINBPC(p);
}

static int PTRFASTCALL big2_isNmstrtMin(const ENCODING *enc, const char *p) {
  UNUSED_P(enc);
  return BIG2_IS_NMSTRT_CHAR_MINBPC(p);
}

#undef VTABLE
#define VTABLE VTABLE1, big2_toUtf8, big2_toUtf16

#else /* not XML_MIN_SIZE */

#undef PREFIX
#define PREFIX(ident) big2_##ident
#define MINBPC(enc) 2
/* CHAR_MATCHES is guaranteed to have MINBPC bytes available. */
#define BYTE_TYPE(enc, p) BIG2_BYTE_TYPE(enc, p)
#define BYTE_TO_ASCII(enc, p) BIG2_BYTE_TO_ASCII(p)
#define CHAR_MATCHES(enc, p, c) BIG2_CHAR_MATCHES(p, c)
#define IS_NAME_CHAR(enc, p, n) 0
#define IS_NAME_CHAR_MINBPC(enc, p) BIG2_IS_NAME_CHAR_MINBPC(p)
#define IS_NMSTRT_CHAR(enc, p, n) (0)
#define IS_NMSTRT_CHAR_MINBPC(enc, p) BIG2_IS_NMSTRT_CHAR_MINBPC(p)

#define XML_TOK_IMPL_C
/* --- INLINED xmltok_impl.c --- */

#ifdef XML_TOK_IMPL_C

#ifndef IS_INVALID_CHAR // i.e. for UTF-16 and XML_MIN_SIZE not defined
#define IS_INVALID_CHAR(enc, ptr, n) (0)
#endif

#define INVALID_LEAD_CASE(n, ptr, nextTokPtr)                                  \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n)                                                         \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n)) {                                        \
      *(nextTokPtr) = (ptr);                                                   \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    ptr += n;                                                                  \
    break;

#define INVALID_CASES(ptr, nextTokPtr)                                         \
  INVALID_LEAD_CASE(2, ptr, nextTokPtr)                                        \
  INVALID_LEAD_CASE(3, ptr, nextTokPtr)                                        \
  INVALID_LEAD_CASE(4, ptr, nextTokPtr)                                        \
  case BT_NONXML:                                                              \
  case BT_MALFORM:                                                             \
  case BT_TRAIL:                                                               \
    *(nextTokPtr) = (ptr);                                                     \
    return XML_TOK_INVALID;

#define CHECK_NAME_CASE(n, enc, ptr, end, nextTokPtr)                          \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n)                                                         \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n) || !IS_NAME_CHAR(enc, ptr, n)) {          \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    ptr += n;                                                                  \
    break;

#define CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)                            \
  case BT_NONASCII:                                                            \
    if (!IS_NAME_CHAR_MINBPC(enc, ptr)) {                                      \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    /* fall through */                                                         \
  case BT_NMSTRT:                                                              \
  case BT_HEX:                                                                 \
  case BT_DIGIT:                                                               \
  case BT_NAME:                                                                \
  case BT_MINUS:                                                               \
    ptr += MINBPC(enc);                                                        \
    break;                                                                     \
    CHECK_NAME_CASE(2, enc, ptr, end, nextTokPtr)                              \
    CHECK_NAME_CASE(3, enc, ptr, end, nextTokPtr)                              \
    CHECK_NAME_CASE(4, enc, ptr, end, nextTokPtr)

#define CHECK_NMSTRT_CASE(n, enc, ptr, end, nextTokPtr)                        \
  case BT_LEAD##n:                                                             \
    if ((end) - (ptr) < (n))                                                   \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n) || !IS_NMSTRT_CHAR(enc, ptr, n)) {        \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    ptr += n;                                                                  \
    break;

#define CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)                          \
  case BT_NONASCII:                                                            \
    if (!IS_NMSTRT_CHAR_MINBPC(enc, ptr)) {                                    \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    /* fall through */                                                         \
  case BT_NMSTRT:                                                              \
  case BT_HEX:                                                                 \
    ptr += MINBPC(enc);                                                        \
    break;                                                                     \
    CHECK_NMSTRT_CASE(2, enc, ptr, end, nextTokPtr)                            \
    CHECK_NMSTRT_CASE(3, enc, ptr, end, nextTokPtr)                            \
    CHECK_NMSTRT_CASE(4, enc, ptr, end, nextTokPtr)

#ifndef PREFIX
#define PREFIX(ident) ident
#endif

#define HAS_CHARS(enc, ptr, end, count)                                        \
  ((end) - (ptr) >= ((count) * MINBPC(enc)))

#define HAS_CHAR(enc, ptr, end) HAS_CHARS(enc, ptr, end, 1)

#define REQUIRE_CHARS(enc, ptr, end, count)                                    \
  {                                                                            \
    if (!HAS_CHARS(enc, ptr, end, count)) {                                    \
      return XML_TOK_PARTIAL;                                                  \
    }                                                                          \
  }

#define REQUIRE_CHAR(enc, ptr, end) REQUIRE_CHARS(enc, ptr, end, 1)

/* ptr points to character following "<!-" */

static int PTRCALL PREFIX(scanComment)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  if (HAS_CHAR(enc, ptr, end)) {
    if (!CHAR_MATCHES(enc, ptr, ASCII_MINUS)) {
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
    ptr += MINBPC(enc);
    while (HAS_CHAR(enc, ptr, end)) {
      switch (BYTE_TYPE(enc, ptr)) {
        INVALID_CASES(ptr, nextTokPtr)
      case BT_MINUS:
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        if (CHAR_MATCHES(enc, ptr, ASCII_MINUS)) {
          ptr += MINBPC(enc);
          REQUIRE_CHAR(enc, ptr, end);
          if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
            *nextTokPtr = ptr;
            return XML_TOK_INVALID;
          }
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_COMMENT;
        }
        break;
      default:
        ptr += MINBPC(enc);
        break;
      }
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "<!" */

static int PTRCALL PREFIX(scanDecl)(const ENCODING *enc, const char *ptr,
                                    const char *end, const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_MINUS:
    return PREFIX(scanComment)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_LSQB:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_COND_SECT_OPEN;
  case BT_NMSTRT:
  case BT_HEX:
    ptr += MINBPC(enc);
    break;
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_PERCNT:
      REQUIRE_CHARS(enc, ptr, end, 2);
      /* don't allow <!ENTITY% foo "whatever"> */
      switch (BYTE_TYPE(enc, ptr + MINBPC(enc))) {
      case BT_S:
      case BT_CR:
      case BT_LF:
      case BT_PERCNT:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      /* fall through */
    case BT_S:
    case BT_CR:
    case BT_LF:
      *nextTokPtr = ptr;
      return XML_TOK_DECL_OPEN;
    case BT_NMSTRT:
    case BT_HEX:
      ptr += MINBPC(enc);
      break;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(checkPiTarget)(const ENCODING *enc, const char *ptr,
                                         const char *end, int *tokPtr) {
  int upper = 0;
  UNUSED_P(enc);
  *tokPtr = XML_TOK_PI;
  if (end - ptr != MINBPC(enc) * 3)
    return 1;
  switch (BYTE_TO_ASCII(enc, ptr)) {
  case ASCII_x:
    break;
  case ASCII_X:
    upper = 1;
    break;
  default:
    return 1;
  }
  ptr += MINBPC(enc);
  switch (BYTE_TO_ASCII(enc, ptr)) {
  case ASCII_m:
    break;
  case ASCII_M:
    upper = 1;
    break;
  default:
    return 1;
  }
  ptr += MINBPC(enc);
  switch (BYTE_TO_ASCII(enc, ptr)) {
  case ASCII_l:
    break;
  case ASCII_L:
    upper = 1;
    break;
  default:
    return 1;
  }
  if (upper)
    return 0;
  *tokPtr = XML_TOK_XML_DECL;
  return 1;
}

/* ptr points to character following "<?" */

static int PTRCALL PREFIX(scanPi)(const ENCODING *enc, const char *ptr,
                                  const char *end, const char **nextTokPtr) {
  int tok;
  const char *target = ptr;
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_S:
    case BT_CR:
    case BT_LF:
      if (!PREFIX(checkPiTarget)(enc, target, ptr, &tok)) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      ptr += MINBPC(enc);
      while (HAS_CHAR(enc, ptr, end)) {
        switch (BYTE_TYPE(enc, ptr)) {
          INVALID_CASES(ptr, nextTokPtr)
        case BT_QUEST:
          ptr += MINBPC(enc);
          REQUIRE_CHAR(enc, ptr, end);
          if (CHAR_MATCHES(enc, ptr, ASCII_GT)) {
            *nextTokPtr = ptr + MINBPC(enc);
            return tok;
          }
          break;
        default:
          ptr += MINBPC(enc);
          break;
        }
      }
      return XML_TOK_PARTIAL;
    case BT_QUEST:
      if (!PREFIX(checkPiTarget)(enc, target, ptr, &tok)) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (CHAR_MATCHES(enc, ptr, ASCII_GT)) {
        *nextTokPtr = ptr + MINBPC(enc);
        return tok;
      }
      /* fall through */
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(scanCdataSection)(const ENCODING *enc,
                                            const char *ptr, const char *end,
                                            const char **nextTokPtr) {
  static const char CDATA_LSQB[] = {ASCII_C, ASCII_D, ASCII_A,
                                    ASCII_T, ASCII_A, ASCII_LSQB};
  int i;
  UNUSED_P(enc);
  /* CDATA[ */
  REQUIRE_CHARS(enc, ptr, end, 6);
  for (i = 0; i < 6; i++, ptr += MINBPC(enc)) {
    if (!CHAR_MATCHES(enc, ptr, CDATA_LSQB[i])) {
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_CDATA_SECT_OPEN;
}

static int PTRCALL PREFIX(cdataSectionTok)(const ENCODING *enc, const char *ptr,
                                           const char *end,
                                           const char **nextTokPtr) {
  if (ptr >= end)
    return XML_TOK_NONE;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      if (n == 0)
        return XML_TOK_PARTIAL;
      end = ptr + n;
    }
  }
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_RSQB:
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    if (!CHAR_MATCHES(enc, ptr, ASCII_RSQB))
      break;
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
      ptr -= MINBPC(enc);
      break;
    }
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_CDATA_SECT_CLOSE;
  case BT_CR:
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    if (BYTE_TYPE(enc, ptr) == BT_LF)
      ptr += MINBPC(enc);
    *nextTokPtr = ptr;
    return XML_TOK_DATA_NEWLINE;
  case BT_LF:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_DATA_NEWLINE;
    INVALID_CASES(ptr, nextTokPtr)
  default:
    ptr += MINBPC(enc);
    break;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n || IS_INVALID_CHAR(enc, ptr, n)) {                       \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_DATA_CHARS;                                               \
    }                                                                          \
    ptr += n;                                                                  \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_NONXML:
    case BT_MALFORM:
    case BT_TRAIL:
    case BT_CR:
    case BT_LF:
    case BT_RSQB:
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

/* ptr points to character following "</" */

static int PTRCALL PREFIX(scanEndTag)(const ENCODING *enc, const char *ptr,
                                      const char *end,
                                      const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_S:
    case BT_CR:
    case BT_LF:
      for (ptr += MINBPC(enc); HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
        switch (BYTE_TYPE(enc, ptr)) {
        case BT_S:
        case BT_CR:
        case BT_LF:
          break;
        case BT_GT:
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_END_TAG;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
      }
      return XML_TOK_PARTIAL;
#ifdef XML_NS
    case BT_COLON:
      /* no need to check qname syntax here,
         since end-tag must match exactly */
      ptr += MINBPC(enc);
      break;
#endif
    case BT_GT:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_END_TAG;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "&#X" */

static int PTRCALL PREFIX(scanHexCharRef)(const ENCODING *enc, const char *ptr,
                                          const char *end,
                                          const char **nextTokPtr) {
  if (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_DIGIT:
    case BT_HEX:
      break;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
    for (ptr += MINBPC(enc); HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_DIGIT:
      case BT_HEX:
        break;
      case BT_SEMI:
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_CHAR_REF;
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "&#" */

static int PTRCALL PREFIX(scanCharRef)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  if (HAS_CHAR(enc, ptr, end)) {
    if (CHAR_MATCHES(enc, ptr, ASCII_x))
      return PREFIX(scanHexCharRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_DIGIT:
      break;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
    for (ptr += MINBPC(enc); HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_DIGIT:
        break;
      case BT_SEMI:
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_CHAR_REF;
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "&" */

static int PTRCALL PREFIX(scanRef)(const ENCODING *enc, const char *ptr,
                                   const char *end, const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  case BT_NUM:
    return PREFIX(scanCharRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_SEMI:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_ENTITY_REF;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following first character of attribute name */

static int PTRCALL PREFIX(scanAtts)(const ENCODING *enc, const char *ptr,
                                    const char *end, const char **nextTokPtr) {
#ifdef XML_NS
  int hadColon = 0;
#endif
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
#ifdef XML_NS
    case BT_COLON:
      if (hadColon) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      hadColon = 1;
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      switch (BYTE_TYPE(enc, ptr)) {
        CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      break;
#endif
    case BT_S:
    case BT_CR:
    case BT_LF:
      for (;;) {
        int t;

        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        t = BYTE_TYPE(enc, ptr);
        if (t == BT_EQUALS)
          break;
        switch (t) {
        case BT_S:
        case BT_LF:
        case BT_CR:
          break;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
      }
      /* fall through */
    case BT_EQUALS: {
      int open;
#ifdef XML_NS
      hadColon = 0;
#endif
      for (;;) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        open = BYTE_TYPE(enc, ptr);
        if (open == BT_QUOT || open == BT_APOS)
          break;
        switch (open) {
        case BT_S:
        case BT_LF:
        case BT_CR:
          break;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
      }
      ptr += MINBPC(enc);
      /* in attribute value */
      for (;;) {
        int t;
        REQUIRE_CHAR(enc, ptr, end);
        t = BYTE_TYPE(enc, ptr);
        if (t == open)
          break;
        switch (t) {
          INVALID_CASES(ptr, nextTokPtr)
        case BT_AMP: {
          int tok = PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, &ptr);
          if (tok <= 0) {
            if (tok == XML_TOK_INVALID)
              *nextTokPtr = ptr;
            return tok;
          }
          break;
        }
        case BT_LT:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        default:
          ptr += MINBPC(enc);
          break;
        }
      }
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_S:
      case BT_CR:
      case BT_LF:
        break;
      case BT_SOL:
        goto sol;
      case BT_GT:
        goto gt;
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      /* ptr points to closing quote */
      for (;;) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        switch (BYTE_TYPE(enc, ptr)) {
          CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
        case BT_S:
        case BT_CR:
        case BT_LF:
          continue;
        case BT_GT:
        gt:
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_START_TAG_WITH_ATTS;
        case BT_SOL:
        sol:
          ptr += MINBPC(enc);
          REQUIRE_CHAR(enc, ptr, end);
          if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
            *nextTokPtr = ptr;
            return XML_TOK_INVALID;
          }
          *nextTokPtr = ptr + MINBPC(enc);
          return XML_TOK_EMPTY_ELEMENT_WITH_ATTS;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
        break;
      }
      break;
    }
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

/* ptr points to character following "<" */

static int PTRCALL PREFIX(scanLt)(const ENCODING *enc, const char *ptr,
                                  const char *end, const char **nextTokPtr) {
#ifdef XML_NS
  int hadColon;
#endif
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  case BT_EXCL:
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_MINUS:
      return PREFIX(scanComment)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    case BT_LSQB:
      return PREFIX(scanCdataSection)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  case BT_QUEST:
    return PREFIX(scanPi)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_SOL:
    return PREFIX(scanEndTag)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
#ifdef XML_NS
  hadColon = 0;
#endif
  /* we have a start-tag */
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
#ifdef XML_NS
    case BT_COLON:
      if (hadColon) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      hadColon = 1;
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      switch (BYTE_TYPE(enc, ptr)) {
        CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
      default:
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      break;
#endif
    case BT_S:
    case BT_CR:
    case BT_LF: {
      ptr += MINBPC(enc);
      while (HAS_CHAR(enc, ptr, end)) {
        switch (BYTE_TYPE(enc, ptr)) {
          CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
        case BT_GT:
          goto gt;
        case BT_SOL:
          goto sol;
        case BT_S:
        case BT_CR:
        case BT_LF:
          ptr += MINBPC(enc);
          continue;
        default:
          *nextTokPtr = ptr;
          return XML_TOK_INVALID;
        }
        return PREFIX(scanAtts)(enc, ptr, end, nextTokPtr);
      }
      return XML_TOK_PARTIAL;
    }
    case BT_GT:
    gt:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_START_TAG_NO_ATTS;
    case BT_SOL:
    sol:
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_EMPTY_ELEMENT_NO_ATTS;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(contentTok)(const ENCODING *enc, const char *ptr,
                                      const char *end,
                                      const char **nextTokPtr) {
  if (ptr >= end)
    return XML_TOK_NONE;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      if (n == 0)
        return XML_TOK_PARTIAL;
      end = ptr + n;
    }
  }
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_LT:
    return PREFIX(scanLt)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_AMP:
    return PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_CR:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return XML_TOK_TRAILING_CR;
    if (BYTE_TYPE(enc, ptr) == BT_LF)
      ptr += MINBPC(enc);
    *nextTokPtr = ptr;
    return XML_TOK_DATA_NEWLINE;
  case BT_LF:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_DATA_NEWLINE;
  case BT_RSQB:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return XML_TOK_TRAILING_RSQB;
    if (!CHAR_MATCHES(enc, ptr, ASCII_RSQB))
      break;
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return XML_TOK_TRAILING_RSQB;
    if (!CHAR_MATCHES(enc, ptr, ASCII_GT)) {
      ptr -= MINBPC(enc);
      break;
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
    INVALID_CASES(ptr, nextTokPtr)
  default:
    ptr += MINBPC(enc);
    break;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n || IS_INVALID_CHAR(enc, ptr, n)) {                       \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_DATA_CHARS;                                               \
    }                                                                          \
    ptr += n;                                                                  \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_RSQB:
      if (HAS_CHARS(enc, ptr, end, 2)) {
        if (!CHAR_MATCHES(enc, ptr + MINBPC(enc), ASCII_RSQB)) {
          ptr += MINBPC(enc);
          break;
        }
        if (HAS_CHARS(enc, ptr, end, 3)) {
          if (!CHAR_MATCHES(enc, ptr + 2 * MINBPC(enc), ASCII_GT)) {
            ptr += MINBPC(enc);
            break;
          }
          *nextTokPtr = ptr + 2 * MINBPC(enc);
          return XML_TOK_INVALID;
        }
      }
      /* fall through */
    case BT_AMP:
    case BT_LT:
    case BT_NONXML:
    case BT_MALFORM:
    case BT_TRAIL:
    case BT_CR:
    case BT_LF:
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

/* ptr points to character following "%" */

static int PTRCALL PREFIX(scanPercent)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  case BT_S:
  case BT_LF:
  case BT_CR:
  case BT_PERCNT:
    *nextTokPtr = ptr;
    return XML_TOK_PERCENT;
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_SEMI:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_PARAM_ENTITY_REF;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(scanPoundName)(const ENCODING *enc, const char *ptr,
                                         const char *end,
                                         const char **nextTokPtr) {
  REQUIRE_CHAR(enc, ptr, end);
  switch (BYTE_TYPE(enc, ptr)) {
    CHECK_NMSTRT_CASES(enc, ptr, end, nextTokPtr)
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_CR:
    case BT_LF:
    case BT_S:
    case BT_RPAR:
    case BT_GT:
    case BT_PERCNT:
    case BT_VERBAR:
      *nextTokPtr = ptr;
      return XML_TOK_POUND_NAME;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return -XML_TOK_POUND_NAME;
}

static int PTRCALL PREFIX(scanLit)(int open, const ENCODING *enc,
                                   const char *ptr, const char *end,
                                   const char **nextTokPtr) {
  while (HAS_CHAR(enc, ptr, end)) {
    int t = BYTE_TYPE(enc, ptr);
    switch (t) {
      INVALID_CASES(ptr, nextTokPtr)
    case BT_QUOT:
    case BT_APOS:
      ptr += MINBPC(enc);
      if (t != open)
        break;
      if (!HAS_CHAR(enc, ptr, end))
        return -XML_TOK_LITERAL;
      *nextTokPtr = ptr;
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_S:
      case BT_CR:
      case BT_LF:
      case BT_GT:
      case BT_PERCNT:
      case BT_LSQB:
        return XML_TOK_LITERAL;
      default:
        return XML_TOK_INVALID;
      }
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  return XML_TOK_PARTIAL;
}

static int PTRCALL PREFIX(prologTok)(const ENCODING *enc, const char *ptr,
                                     const char *end, const char **nextTokPtr) {
  int tok;
  if (ptr >= end)
    return XML_TOK_NONE;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      if (n == 0)
        return XML_TOK_PARTIAL;
      end = ptr + n;
    }
  }
  switch (BYTE_TYPE(enc, ptr)) {
  case BT_QUOT:
    return PREFIX(scanLit)(BT_QUOT, enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_APOS:
    return PREFIX(scanLit)(BT_APOS, enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_LT: {
    ptr += MINBPC(enc);
    REQUIRE_CHAR(enc, ptr, end);
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_EXCL:
      return PREFIX(scanDecl)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    case BT_QUEST:
      return PREFIX(scanPi)(enc, ptr + MINBPC(enc), end, nextTokPtr);
    case BT_NMSTRT:
    case BT_HEX:
    case BT_NONASCII:
    case BT_LEAD2:
    case BT_LEAD3:
    case BT_LEAD4:
      *nextTokPtr = ptr - MINBPC(enc);
      return XML_TOK_INSTANCE_START;
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  case BT_CR:
    if (ptr + MINBPC(enc) == end) {
      *nextTokPtr = end;
      /* indicate that this might be part of a CR/LF pair */
      return -XML_TOK_PROLOG_S;
    }
    /* fall through */
  case BT_S:
  case BT_LF:
    for (;;) {
      ptr += MINBPC(enc);
      if (!HAS_CHAR(enc, ptr, end))
        break;
      switch (BYTE_TYPE(enc, ptr)) {
      case BT_S:
      case BT_LF:
        break;
      case BT_CR:
        /* don't split CR/LF pair */
        if (ptr + MINBPC(enc) != end)
          break;
        /* fall through */
      default:
        *nextTokPtr = ptr;
        return XML_TOK_PROLOG_S;
      }
    }
    *nextTokPtr = ptr;
    return XML_TOK_PROLOG_S;
  case BT_PERCNT:
    return PREFIX(scanPercent)(enc, ptr + MINBPC(enc), end, nextTokPtr);
  case BT_COMMA:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_COMMA;
  case BT_LSQB:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_OPEN_BRACKET;
  case BT_RSQB:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return -XML_TOK_CLOSE_BRACKET;
    if (CHAR_MATCHES(enc, ptr, ASCII_RSQB)) {
      REQUIRE_CHARS(enc, ptr, end, 2);
      if (CHAR_MATCHES(enc, ptr + MINBPC(enc), ASCII_GT)) {
        *nextTokPtr = ptr + 2 * MINBPC(enc);
        return XML_TOK_COND_SECT_CLOSE;
      }
    }
    *nextTokPtr = ptr;
    return XML_TOK_CLOSE_BRACKET;
  case BT_LPAR:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_OPEN_PAREN;
  case BT_RPAR:
    ptr += MINBPC(enc);
    if (!HAS_CHAR(enc, ptr, end))
      return -XML_TOK_CLOSE_PAREN;
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_AST:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_CLOSE_PAREN_ASTERISK;
    case BT_QUEST:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_CLOSE_PAREN_QUESTION;
    case BT_PLUS:
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_CLOSE_PAREN_PLUS;
    case BT_CR:
    case BT_LF:
    case BT_S:
    case BT_GT:
    case BT_COMMA:
    case BT_VERBAR:
    case BT_RPAR:
      *nextTokPtr = ptr;
      return XML_TOK_CLOSE_PAREN;
    }
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  case BT_VERBAR:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_OR;
  case BT_GT:
    *nextTokPtr = ptr + MINBPC(enc);
    return XML_TOK_DECL_CLOSE;
  case BT_NUM:
    return PREFIX(scanPoundName)(enc, ptr + MINBPC(enc), end, nextTokPtr);
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    if (end - ptr < n)                                                         \
      return XML_TOK_PARTIAL_CHAR;                                             \
    if (IS_INVALID_CHAR(enc, ptr, n)) {                                        \
      *nextTokPtr = ptr;                                                       \
      return XML_TOK_INVALID;                                                  \
    }                                                                          \
    if (IS_NMSTRT_CHAR(enc, ptr, n)) {                                         \
      ptr += n;                                                                \
      tok = XML_TOK_NAME;                                                      \
      break;                                                                   \
    }                                                                          \
    if (IS_NAME_CHAR(enc, ptr, n)) {                                           \
      ptr += n;                                                                \
      tok = XML_TOK_NMTOKEN;                                                   \
      break;                                                                   \
    }                                                                          \
    *nextTokPtr = ptr;                                                         \
    return XML_TOK_INVALID;
    LEAD_CASE(2)
    LEAD_CASE(3)
    LEAD_CASE(4)
#undef LEAD_CASE
  case BT_NMSTRT:
  case BT_HEX:
    tok = XML_TOK_NAME;
    ptr += MINBPC(enc);
    break;
  case BT_DIGIT:
  case BT_NAME:
  case BT_MINUS:
#ifdef XML_NS
  case BT_COLON:
#endif
    tok = XML_TOK_NMTOKEN;
    ptr += MINBPC(enc);
    break;
  case BT_NONASCII:
    if (IS_NMSTRT_CHAR_MINBPC(enc, ptr)) {
      ptr += MINBPC(enc);
      tok = XML_TOK_NAME;
      break;
    }
    if (IS_NAME_CHAR_MINBPC(enc, ptr)) {
      ptr += MINBPC(enc);
      tok = XML_TOK_NMTOKEN;
      break;
    }
    /* fall through */
  default:
    *nextTokPtr = ptr;
    return XML_TOK_INVALID;
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
    case BT_GT:
    case BT_RPAR:
    case BT_COMMA:
    case BT_VERBAR:
    case BT_LSQB:
    case BT_PERCNT:
    case BT_S:
    case BT_CR:
    case BT_LF:
      *nextTokPtr = ptr;
      return tok;
#ifdef XML_NS
    case BT_COLON:
      ptr += MINBPC(enc);
      switch (tok) {
      case XML_TOK_NAME:
        REQUIRE_CHAR(enc, ptr, end);
        tok = XML_TOK_PREFIXED_NAME;
        switch (BYTE_TYPE(enc, ptr)) {
          CHECK_NAME_CASES(enc, ptr, end, nextTokPtr)
        default:
          tok = XML_TOK_NMTOKEN;
          break;
        }
        break;
      case XML_TOK_PREFIXED_NAME:
        tok = XML_TOK_NMTOKEN;
        break;
      }
      break;
#endif
    case BT_PLUS:
      if (tok == XML_TOK_NMTOKEN) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_NAME_PLUS;
    case BT_AST:
      if (tok == XML_TOK_NMTOKEN) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_NAME_ASTERISK;
    case BT_QUEST:
      if (tok == XML_TOK_NMTOKEN) {
        *nextTokPtr = ptr;
        return XML_TOK_INVALID;
      }
      *nextTokPtr = ptr + MINBPC(enc);
      return XML_TOK_NAME_QUESTION;
    default:
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    }
  }
  return -tok;
}

static int PTRCALL PREFIX(attributeValueTok)(const ENCODING *enc,
                                             const char *ptr, const char *end,
                                             const char **nextTokPtr) {
  const char *start;
  if (ptr >= end)
    return XML_TOK_NONE;
  else if (!HAS_CHAR(enc, ptr, end)) {
    /* This line cannot be executed.  The incoming data has already
     * been tokenized once, so incomplete characters like this have
     * already been eliminated from the input.  Retaining the paranoia
     * check is still valuable, however.
     */
    return XML_TOK_PARTIAL; /* LCOV_EXCL_LINE */
  }
  start = ptr;
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_AMP:
      if (ptr == start)
        return PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_LT:
      /* this is for inside entity references */
      *nextTokPtr = ptr;
      return XML_TOK_INVALID;
    case BT_LF:
      if (ptr == start) {
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_CR:
      if (ptr == start) {
        ptr += MINBPC(enc);
        if (!HAS_CHAR(enc, ptr, end))
          return XML_TOK_TRAILING_CR;
        if (BYTE_TYPE(enc, ptr) == BT_LF)
          ptr += MINBPC(enc);
        *nextTokPtr = ptr;
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_S:
      if (ptr == start) {
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_ATTRIBUTE_VALUE_S;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

static int PTRCALL PREFIX(entityValueTok)(const ENCODING *enc, const char *ptr,
                                          const char *end,
                                          const char **nextTokPtr) {
  const char *start;
  if (ptr >= end)
    return XML_TOK_NONE;
  else if (!HAS_CHAR(enc, ptr, end)) {
    /* This line cannot be executed.  The incoming data has already
     * been tokenized once, so incomplete characters like this have
     * already been eliminated from the input.  Retaining the paranoia
     * check is still valuable, however.
     */
    return XML_TOK_PARTIAL; /* LCOV_EXCL_LINE */
  }
  start = ptr;
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_AMP:
      if (ptr == start)
        return PREFIX(scanRef)(enc, ptr + MINBPC(enc), end, nextTokPtr);
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_PERCNT:
      if (ptr == start) {
        int tok = PREFIX(scanPercent)(enc, ptr + MINBPC(enc), end, nextTokPtr);
        return (tok == XML_TOK_PERCENT) ? XML_TOK_INVALID : tok;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_LF:
      if (ptr == start) {
        *nextTokPtr = ptr + MINBPC(enc);
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    case BT_CR:
      if (ptr == start) {
        ptr += MINBPC(enc);
        if (!HAS_CHAR(enc, ptr, end))
          return XML_TOK_TRAILING_CR;
        if (BYTE_TYPE(enc, ptr) == BT_LF)
          ptr += MINBPC(enc);
        *nextTokPtr = ptr;
        return XML_TOK_DATA_NEWLINE;
      }
      *nextTokPtr = ptr;
      return XML_TOK_DATA_CHARS;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  *nextTokPtr = ptr;
  return XML_TOK_DATA_CHARS;
}

#ifdef XML_DTD

static int PTRCALL PREFIX(ignoreSectionTok)(const ENCODING *enc,
                                            const char *ptr, const char *end,
                                            const char **nextTokPtr) {
  int level = 0;
  if (MINBPC(enc) > 1) {
    size_t n = end - ptr;
    if (n & (MINBPC(enc) - 1)) {
      n &= ~(MINBPC(enc) - 1);
      end = ptr + n;
    }
  }
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
      INVALID_CASES(ptr, nextTokPtr)
    case BT_LT:
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (CHAR_MATCHES(enc, ptr, ASCII_EXCL)) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        if (CHAR_MATCHES(enc, ptr, ASCII_LSQB)) {
          ++level;
          ptr += MINBPC(enc);
        }
      }
      break;
    case BT_RSQB:
      ptr += MINBPC(enc);
      REQUIRE_CHAR(enc, ptr, end);
      if (CHAR_MATCHES(enc, ptr, ASCII_RSQB)) {
        ptr += MINBPC(enc);
        REQUIRE_CHAR(enc, ptr, end);
        if (CHAR_MATCHES(enc, ptr, ASCII_GT)) {
          ptr += MINBPC(enc);
          if (level == 0) {
            *nextTokPtr = ptr;
            return XML_TOK_IGNORE_SECT;
          }
          --level;
        }
      }
      break;
    default:
      ptr += MINBPC(enc);
      break;
    }
  }
  return XML_TOK_PARTIAL;
}

#endif /* XML_DTD */

static int PTRCALL PREFIX(isPublicId)(const ENCODING *enc, const char *ptr,
                                      const char *end, const char **badPtr) {
  ptr += MINBPC(enc);
  end -= MINBPC(enc);
  for (; HAS_CHAR(enc, ptr, end); ptr += MINBPC(enc)) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_DIGIT:
    case BT_HEX:
    case BT_MINUS:
    case BT_APOS:
    case BT_LPAR:
    case BT_RPAR:
    case BT_PLUS:
    case BT_COMMA:
    case BT_SOL:
    case BT_EQUALS:
    case BT_QUEST:
    case BT_CR:
    case BT_LF:
    case BT_SEMI:
    case BT_EXCL:
    case BT_AST:
    case BT_PERCNT:
    case BT_NUM:
#ifdef XML_NS
    case BT_COLON:
#endif
      break;
    case BT_S:
      if (CHAR_MATCHES(enc, ptr, ASCII_TAB)) {
        *badPtr = ptr;
        return 0;
      }
      break;
    case BT_NAME:
    case BT_NMSTRT:
      if (!(BYTE_TO_ASCII(enc, ptr) & ~0x7f))
        break;
      /* fall through */
    default:
      switch (BYTE_TO_ASCII(enc, ptr)) {
      case 0x24: /* $ */
      case 0x40: /* @ */
        break;
      default:
        *badPtr = ptr;
        return 0;
      }
      break;
    }
  }
  return 1;
}

/* This must only be called for a well-formed start-tag or empty
   element tag.  Returns the number of attributes.  Pointers to the
   first attsMax attributes are stored in atts.
*/

static int PTRCALL PREFIX(getAtts)(const ENCODING *enc, const char *ptr,
                                   int attsMax, ATTRIBUTE *atts) {
  enum { other, inName, inValue } state = inName;
  int nAtts = 0;
  int open = 0; /* defined when state == inValue;
                   initialization just to shut up compilers */

  for (ptr += MINBPC(enc);; ptr += MINBPC(enc)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define START_NAME                                                             \
  if (state == other) {                                                        \
    if (nAtts < attsMax) {                                                     \
      atts[nAtts].name = ptr;                                                  \
      atts[nAtts].normalized = 1;                                              \
    }                                                                          \
    state = inName;                                                            \
  }
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n: /* NOTE: The encoding has already been validated. */        \
    START_NAME ptr += (n - MINBPC(enc));                                       \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_NONASCII:
    case BT_NMSTRT:
    case BT_HEX:
      START_NAME
      break;
#undef START_NAME
    case BT_QUOT:
      if (state != inValue) {
        if (nAtts < attsMax)
          atts[nAtts].valuePtr = ptr + MINBPC(enc);
        state = inValue;
        open = BT_QUOT;
      } else if (open == BT_QUOT) {
        state = other;
        if (nAtts < attsMax)
          atts[nAtts].valueEnd = ptr;
        nAtts++;
      }
      break;
    case BT_APOS:
      if (state != inValue) {
        if (nAtts < attsMax)
          atts[nAtts].valuePtr = ptr + MINBPC(enc);
        state = inValue;
        open = BT_APOS;
      } else if (open == BT_APOS) {
        state = other;
        if (nAtts < attsMax)
          atts[nAtts].valueEnd = ptr;
        nAtts++;
      }
      break;
    case BT_AMP:
      if (nAtts < attsMax)
        atts[nAtts].normalized = 0;
      break;
    case BT_S:
      if (state == inName)
        state = other;
      else if (state == inValue && nAtts < attsMax && atts[nAtts].normalized &&
               (ptr == atts[nAtts].valuePtr ||
                BYTE_TO_ASCII(enc, ptr) != ASCII_SPACE ||
                BYTE_TO_ASCII(enc, ptr + MINBPC(enc)) == ASCII_SPACE ||
                BYTE_TYPE(enc, ptr + MINBPC(enc)) == open))
        atts[nAtts].normalized = 0;
      break;
    case BT_CR:
    case BT_LF:
      /* This case ensures that the first attribute name is counted
         Apart from that we could just change state on the quote. */
      if (state == inName)
        state = other;
      else if (state == inValue && nAtts < attsMax)
        atts[nAtts].normalized = 0;
      break;
    case BT_GT:
    case BT_SOL:
      if (state != inValue)
        return nAtts;
      break;
    default:
      break;
    }
  }
  /* not reached */
}

static int PTRFASTCALL PREFIX(charRefNumber)(const ENCODING *enc,
                                             const char *ptr) {
  int result = 0;
  /* skip &# */
  UNUSED_P(enc);
  ptr += 2 * MINBPC(enc);
  if (CHAR_MATCHES(enc, ptr, ASCII_x)) {
    for (ptr += MINBPC(enc); !CHAR_MATCHES(enc, ptr, ASCII_SEMI);
         ptr += MINBPC(enc)) {
      int c = BYTE_TO_ASCII(enc, ptr);
      switch (c) {
      case ASCII_0:
      case ASCII_1:
      case ASCII_2:
      case ASCII_3:
      case ASCII_4:
      case ASCII_5:
      case ASCII_6:
      case ASCII_7:
      case ASCII_8:
      case ASCII_9:
        result <<= 4;
        result |= (c - ASCII_0);
        break;
      case ASCII_A:
      case ASCII_B:
      case ASCII_C:
      case ASCII_D:
      case ASCII_E:
      case ASCII_F:
        result <<= 4;
        result += 10 + (c - ASCII_A);
        break;
      case ASCII_a:
      case ASCII_b:
      case ASCII_c:
      case ASCII_d:
      case ASCII_e:
      case ASCII_f:
        result <<= 4;
        result += 10 + (c - ASCII_a);
        break;
      }
      if (result >= 0x110000)
        return -1;
    }
  } else {
    for (; !CHAR_MATCHES(enc, ptr, ASCII_SEMI); ptr += MINBPC(enc)) {
      int c = BYTE_TO_ASCII(enc, ptr);
      result *= 10;
      result += (c - ASCII_0);
      if (result >= 0x110000)
        return -1;
    }
  }
  return checkCharRefNumber(result);
}

static int PTRCALL PREFIX(predefinedEntityName)(const ENCODING *enc,
                                                const char *ptr,
                                                const char *end) {
  UNUSED_P(enc);
  switch ((end - ptr) / MINBPC(enc)) {
  case 2:
    if (CHAR_MATCHES(enc, ptr + MINBPC(enc), ASCII_t)) {
      switch (BYTE_TO_ASCII(enc, ptr)) {
      case ASCII_l:
        return ASCII_LT;
      case ASCII_g:
        return ASCII_GT;
      }
    }
    break;
  case 3:
    if (CHAR_MATCHES(enc, ptr, ASCII_a)) {
      ptr += MINBPC(enc);
      if (CHAR_MATCHES(enc, ptr, ASCII_m)) {
        ptr += MINBPC(enc);
        if (CHAR_MATCHES(enc, ptr, ASCII_p))
          return ASCII_AMP;
      }
    }
    break;
  case 4:
    switch (BYTE_TO_ASCII(enc, ptr)) {
    case ASCII_q:
      ptr += MINBPC(enc);
      if (CHAR_MATCHES(enc, ptr, ASCII_u)) {
        ptr += MINBPC(enc);
        if (CHAR_MATCHES(enc, ptr, ASCII_o)) {
          ptr += MINBPC(enc);
          if (CHAR_MATCHES(enc, ptr, ASCII_t))
            return ASCII_QUOT;
        }
      }
      break;
    case ASCII_a:
      ptr += MINBPC(enc);
      if (CHAR_MATCHES(enc, ptr, ASCII_p)) {
        ptr += MINBPC(enc);
        if (CHAR_MATCHES(enc, ptr, ASCII_o)) {
          ptr += MINBPC(enc);
          if (CHAR_MATCHES(enc, ptr, ASCII_s))
            return ASCII_APOS;
        }
      }
      break;
    }
  }
  return 0;
}

static int PTRCALL PREFIX(nameMatchesAscii)(const ENCODING *enc,
                                            const char *ptr1, const char *end1,
                                            const char *ptr2) {
  UNUSED_P(enc);
  for (; *ptr2; ptr1 += MINBPC(enc), ptr2++) {
    if (end1 - ptr1 < MINBPC(enc)) {
      /* This line cannot be executed.  The incoming data has already
       * been tokenized once, so incomplete characters like this have
       * already been eliminated from the input.  Retaining the
       * paranoia check is still valuable, however.
       */
      return 0; /* LCOV_EXCL_LINE */
    }
    if (!CHAR_MATCHES(enc, ptr1, *ptr2))
      return 0;
  }
  return ptr1 == end1;
}

static int PTRFASTCALL PREFIX(nameLength)(const ENCODING *enc,
                                          const char *ptr) {
  const char *start = ptr;
  for (;;) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_NONASCII:
    case BT_NMSTRT:
#ifdef XML_NS
    case BT_COLON:
#endif
    case BT_HEX:
    case BT_DIGIT:
    case BT_NAME:
    case BT_MINUS:
      ptr += MINBPC(enc);
      break;
    default:
      return (int)(ptr - start);
    }
  }
}

static const char *PTRFASTCALL PREFIX(skipS)(const ENCODING *enc,
                                             const char *ptr) {
  for (;;) {
    switch (BYTE_TYPE(enc, ptr)) {
    case BT_LF:
    case BT_CR:
    case BT_S:
      ptr += MINBPC(enc);
      break;
    default:
      return ptr;
    }
  }
}

static void PTRCALL PREFIX(updatePosition)(const ENCODING *enc, const char *ptr,
                                           const char *end, POSITION *pos) {
  while (HAS_CHAR(enc, ptr, end)) {
    switch (BYTE_TYPE(enc, ptr)) {
#define LEAD_CASE(n)                                                           \
  case BT_LEAD##n:                                                             \
    ptr += n; /* NOTE: The encoding has already been validated. */             \
    pos->columnNumber++;                                                       \
    break;
      LEAD_CASE(2)
      LEAD_CASE(3)
      LEAD_CASE(4)
#undef LEAD_CASE
    case BT_LF:
      pos->columnNumber = 0;
      pos->lineNumber++;
      ptr += MINBPC(enc);
      break;
    case BT_CR:
      pos->lineNumber++;
      ptr += MINBPC(enc);
      if (HAS_CHAR(enc, ptr, end) && BYTE_TYPE(enc, ptr) == BT_LF)
        ptr += MINBPC(enc);
      pos->columnNumber = 0;
      break;
    default:
      ptr += MINBPC(enc);
      pos->columnNumber++;
      break;
    }
  }
}

#undef DO_LEAD_CASE
#undef MULTIBYTE_CASES
#undef INVALID_CASES
#undef CHECK_NAME_CASE
#undef CHECK_NAME_CASES
#undef CHECK_NMSTRT_CASE
#undef CHECK_NMSTRT_CASES

#endif /* XML_TOK_IMPL_C */
#undef XML_TOK_IMPL_C

#undef MINBPC
#undef BYTE_TYPE
#undef BYTE_TO_ASCII
#undef CHAR_MATCHES
#undef IS_NAME_CHAR
#undef IS_NAME_CHAR_MINBPC
#undef IS_NMSTRT_CHAR
#undef IS_NMSTRT_CHAR_MINBPC
#undef IS_INVALID_CHAR

#endif /* not XML_MIN_SIZE */

#ifdef XML_NS

static const struct normal_encoding big2_encoding_ns = {{VTABLE, 2, 0,
#if BYTEORDER == 4321
                                                         1
#else
                                                         0
#endif
                                                        },
                                                        {
#include "asciitab.h"
#include "latin1tab.h"
                                                        },
                                                        STANDARD_VTABLE(big2_)
                                                            NULL_VTABLE};

#endif

static const struct normal_encoding big2_encoding = {{VTABLE, 2, 0,
#if BYTEORDER == 4321
                                                      1
#else
                                                      0
#endif
                                                     },
                                                     {
#define BT_COLON BT_NMSTRT
#include "asciitab.h"
#undef BT_COLON
#include "latin1tab.h"
                                                     },
                                                     STANDARD_VTABLE(big2_)
                                                         NULL_VTABLE};

#if BYTEORDER != 1234

#ifdef XML_NS

static const struct normal_encoding internal_big2_encoding_ns = {
    {VTABLE, 2, 0, 1},
    {
#include "iasciitab.h"
#include "latin1tab.h"
    },
    STANDARD_VTABLE(big2_) NULL_VTABLE};

#endif

static const struct normal_encoding internal_big2_encoding = {
    {VTABLE, 2, 0, 1},
    {
#define BT_COLON BT_NMSTRT
#include "iasciitab.h"
#undef BT_COLON
#include "latin1tab.h"
    },
    STANDARD_VTABLE(big2_) NULL_VTABLE};

#endif

#undef PREFIX

static int FASTCALL streqci(const char *s1, const char *s2) {
  for (;;) {
    char c1 = *s1++;
    char c2 = *s2++;
    if (ASCII_a <= c1 && c1 <= ASCII_z)
      c1 += ASCII_A - ASCII_a;
    if (ASCII_a <= c2 && c2 <= ASCII_z)
      /* The following line will never get executed.  streqci() is
       * only called from two places, both of which guarantee to put
       * upper-case strings into s2.
       */
      c2 += ASCII_A - ASCII_a; /* LCOV_EXCL_LINE */
    if (c1 != c2)
      return 0;
    if (!c1)
      break;
  }
  return 1;
}

static void PTRCALL initUpdatePosition(const ENCODING *enc, const char *ptr,
                                       const char *end, POSITION *pos) {
  UNUSED_P(enc);
  normal_updatePosition(&utf8_encoding.enc, ptr, end, pos);
}

static int toAscii(const ENCODING *enc, const char *ptr, const char *end) {
  char buf[1];
  char *p = buf;
  XmlUtf8Convert(enc, &ptr, end, &p, p + 1);
  if (p == buf)
    return -1;
  else
    return buf[0];
}

static int FASTCALL isSpace(int c) {
  switch (c) {
  case 0x20:
  case 0xD:
  case 0xA:
  case 0x9:
    return 1;
  }
  return 0;
}

/* Return 1 if there's just optional white space or there's an S
   followed by name=val.
*/
static int parsePseudoAttribute(const ENCODING *enc, const char *ptr,
                                const char *end, const char **namePtr,
                                const char **nameEndPtr, const char **valPtr,
                                const char **nextTokPtr) {
  int c;
  char open;
  if (ptr == end) {
    *namePtr = NULL;
    return 1;
  }
  if (!isSpace(toAscii(enc, ptr, end))) {
    *nextTokPtr = ptr;
    return 0;
  }
  do {
    ptr += enc->minBytesPerChar;
  } while (isSpace(toAscii(enc, ptr, end)));
  if (ptr == end) {
    *namePtr = NULL;
    return 1;
  }
  *namePtr = ptr;
  for (;;) {
    c = toAscii(enc, ptr, end);
    if (c == -1) {
      *nextTokPtr = ptr;
      return 0;
    }
    if (c == ASCII_EQUALS) {
      *nameEndPtr = ptr;
      break;
    }
    if (isSpace(c)) {
      *nameEndPtr = ptr;
      do {
        ptr += enc->minBytesPerChar;
      } while (isSpace(c = toAscii(enc, ptr, end)));
      if (c != ASCII_EQUALS) {
        *nextTokPtr = ptr;
        return 0;
      }
      break;
    }
    ptr += enc->minBytesPerChar;
  }
  if (ptr == *namePtr) {
    *nextTokPtr = ptr;
    return 0;
  }
  ptr += enc->minBytesPerChar;
  c = toAscii(enc, ptr, end);
  while (isSpace(c)) {
    ptr += enc->minBytesPerChar;
    c = toAscii(enc, ptr, end);
  }
  if (c != ASCII_QUOT && c != ASCII_APOS) {
    *nextTokPtr = ptr;
    return 0;
  }
  open = (char)c;
  ptr += enc->minBytesPerChar;
  *valPtr = ptr;
  for (;; ptr += enc->minBytesPerChar) {
    c = toAscii(enc, ptr, end);
    if (c == open)
      break;
    if (!(ASCII_a <= c && c <= ASCII_z) && !(ASCII_A <= c && c <= ASCII_Z) &&
        !(ASCII_0 <= c && c <= ASCII_9) && c != ASCII_PERIOD &&
        c != ASCII_MINUS && c != ASCII_UNDERSCORE) {
      *nextTokPtr = ptr;
      return 0;
    }
  }
  *nextTokPtr = ptr + enc->minBytesPerChar;
  return 1;
}

static const char KW_version[] = {ASCII_v, ASCII_e, ASCII_r, ASCII_s,
                                  ASCII_i, ASCII_o, ASCII_n, '\0'};

static const char KW_encoding[] = {ASCII_e, ASCII_n, ASCII_c, ASCII_o, ASCII_d,
                                   ASCII_i, ASCII_n, ASCII_g, '\0'};

static const char KW_standalone[] = {ASCII_s, ASCII_t, ASCII_a, ASCII_n,
                                     ASCII_d, ASCII_a, ASCII_l, ASCII_o,
                                     ASCII_n, ASCII_e, '\0'};

static const char KW_yes[] = {ASCII_y, ASCII_e, ASCII_s, '\0'};

static const char KW_no[] = {ASCII_n, ASCII_o, '\0'};

static int
doParseXmlDecl(const ENCODING *(*encodingFinder)(const ENCODING *, const char *,
                                                 const char *),
               int isGeneralTextEntity, const ENCODING *enc, const char *ptr,
               const char *end, const char **badPtr, const char **versionPtr,
               const char **versionEndPtr, const char **encodingName,
               const ENCODING **encoding, int *standalone) {
  const char *val = NULL;
  const char *name = NULL;
  const char *nameEnd = NULL;
  ptr += 5 * enc->minBytesPerChar;
  end -= 2 * enc->minBytesPerChar;
  if (!parsePseudoAttribute(enc, ptr, end, &name, &nameEnd, &val, &ptr) ||
      !name) {
    *badPtr = ptr;
    return 0;
  }
  if (!XmlNameMatchesAscii(enc, name, nameEnd, KW_version)) {
    if (!isGeneralTextEntity) {
      *badPtr = name;
      return 0;
    }
  } else {
    if (versionPtr)
      *versionPtr = val;
    if (versionEndPtr)
      *versionEndPtr = ptr;
    if (!parsePseudoAttribute(enc, ptr, end, &name, &nameEnd, &val, &ptr)) {
      *badPtr = ptr;
      return 0;
    }
    if (!name) {
      if (isGeneralTextEntity) {
        /* a TextDecl must have an EncodingDecl */
        *badPtr = ptr;
        return 0;
      }
      return 1;
    }
  }
  if (XmlNameMatchesAscii(enc, name, nameEnd, KW_encoding)) {
    int c = toAscii(enc, val, end);
    if (!(ASCII_a <= c && c <= ASCII_z) && !(ASCII_A <= c && c <= ASCII_Z)) {
      *badPtr = val;
      return 0;
    }
    if (encodingName)
      *encodingName = val;
    if (encoding)
      *encoding = encodingFinder(enc, val, ptr - enc->minBytesPerChar);
    if (!parsePseudoAttribute(enc, ptr, end, &name, &nameEnd, &val, &ptr)) {
      *badPtr = ptr;
      return 0;
    }
    if (!name)
      return 1;
  }
  if (!XmlNameMatchesAscii(enc, name, nameEnd, KW_standalone) ||
      isGeneralTextEntity) {
    *badPtr = name;
    return 0;
  }
  if (XmlNameMatchesAscii(enc, val, ptr - enc->minBytesPerChar, KW_yes)) {
    if (standalone)
      *standalone = 1;
  } else if (XmlNameMatchesAscii(enc, val, ptr - enc->minBytesPerChar, KW_no)) {
    if (standalone)
      *standalone = 0;
  } else {
    *badPtr = val;
    return 0;
  }
  while (isSpace(toAscii(enc, ptr, end)))
    ptr += enc->minBytesPerChar;
  if (ptr != end) {
    *badPtr = ptr;
    return 0;
  }
  return 1;
}

static int FASTCALL checkCharRefNumber(int result) {
  switch (result >> 8) {
  case 0xD8:
  case 0xD9:
  case 0xDA:
  case 0xDB:
  case 0xDC:
  case 0xDD:
  case 0xDE:
  case 0xDF:
    return -1;
  case 0:
    if (latin1_encoding.type[result] == BT_NONXML)
      return -1;
    break;
  case 0xFF:
    if (result == 0xFFFE || result == 0xFFFF)
      return -1;
    break;
  }
  return result;
}

int FASTCALL XmlUtf8Encode(int c, char *buf) {
  enum {
    /* minN is minimum legal resulting value for N byte sequence */
    min2 = 0x80,
    min3 = 0x800,
    min4 = 0x10000
  };

  if (c < 0)
    return 0; /* LCOV_EXCL_LINE: this case is always eliminated beforehand */
  if (c < min2) {
    buf[0] = (char)(c | UTF8_cval1);
    return 1;
  }
  if (c < min3) {
    buf[0] = (char)((c >> 6) | UTF8_cval2);
    buf[1] = (char)((c & 0x3f) | 0x80);
    return 2;
  }
  if (c < min4) {
    buf[0] = (char)((c >> 12) | UTF8_cval3);
    buf[1] = (char)(((c >> 6) & 0x3f) | 0x80);
    buf[2] = (char)((c & 0x3f) | 0x80);
    return 3;
  }
  if (c < 0x110000) {
    buf[0] = (char)((c >> 18) | UTF8_cval4);
    buf[1] = (char)(((c >> 12) & 0x3f) | 0x80);
    buf[2] = (char)(((c >> 6) & 0x3f) | 0x80);
    buf[3] = (char)((c & 0x3f) | 0x80);
    return 4;
  }
  return 0; /* LCOV_EXCL_LINE: this case too is eliminated before calling */
}

int FASTCALL XmlUtf16Encode(int charNum, unsigned short *buf) {
  if (charNum < 0)
    return 0;
  if (charNum < 0x10000) {
    buf[0] = (unsigned short)charNum;
    return 1;
  }
  if (charNum < 0x110000) {
    charNum -= 0x10000;
    buf[0] = (unsigned short)((charNum >> 10) + 0xD800);
    buf[1] = (unsigned short)((charNum & 0x3FF) + 0xDC00);
    return 2;
  }
  return 0;
}

struct unknown_encoding {
  struct normal_encoding normal;
  CONVERTER convert;
  void *userData;
  unsigned short utf16[256];
  char utf8[256][4];
};

#define AS_UNKNOWN_ENCODING(enc) ((const struct unknown_encoding *)(enc))

int XmlSizeOfUnknownEncoding(void) { return sizeof(struct unknown_encoding); }

static int PTRFASTCALL unknown_isName(const ENCODING *enc, const char *p) {
  const struct unknown_encoding *uenc = AS_UNKNOWN_ENCODING(enc);
  int c = uenc->convert(uenc->userData, p);
  if (c & ~0xFFFF)
    return 0;
  return UCS2_GET_NAMING(namePages, c >> 8, c & 0xFF);
}

static int PTRFASTCALL unknown_isNmstrt(const ENCODING *enc, const char *p) {
  const struct unknown_encoding *uenc = AS_UNKNOWN_ENCODING(enc);
  int c = uenc->convert(uenc->userData, p);
  if (c & ~0xFFFF)
    return 0;
  return UCS2_GET_NAMING(nmstrtPages, c >> 8, c & 0xFF);
}

static int PTRFASTCALL unknown_isInvalid(const ENCODING *enc, const char *p) {
  const struct unknown_encoding *uenc = AS_UNKNOWN_ENCODING(enc);
  int c = uenc->convert(uenc->userData, p);
  return (c & ~0xFFFF) || checkCharRefNumber(c) < 0;
}

static enum XML_Convert_Result PTRCALL unknown_toUtf8(const ENCODING *enc,
                                                      const char **fromP,
                                                      const char *fromLim,
                                                      char **toP,
                                                      const char *toLim) {
  const struct unknown_encoding *uenc = AS_UNKNOWN_ENCODING(enc);
  char buf[XML_UTF8_ENCODE_MAX];
  for (;;) {
    const char *utf8;
    int n;
    if (*fromP == fromLim)
      return XML_CONVERT_COMPLETED;
    utf8 = uenc->utf8[(unsigned char)**fromP];
    n = *utf8++;
    if (n == 0) {
      int c = uenc->convert(uenc->userData, *fromP);
      n = XmlUtf8Encode(c, buf);
      if (n > toLim - *toP)
        return XML_CONVERT_OUTPUT_EXHAUSTED;
      utf8 = buf;
      *fromP += (AS_NORMAL_ENCODING(enc)->type[(unsigned char)**fromP] -
                 (BT_LEAD2 - 2));
    } else {
      if (n > toLim - *toP)
        return XML_CONVERT_OUTPUT_EXHAUSTED;
      (*fromP)++;
    }
    memcpy(*toP, utf8, n);
    *toP += n;
  }
}

static enum XML_Convert_Result PTRCALL
unknown_toUtf16(const ENCODING *enc, const char **fromP, const char *fromLim,
                unsigned short **toP, const unsigned short *toLim) {
  const struct unknown_encoding *uenc = AS_UNKNOWN_ENCODING(enc);
  while (*fromP < fromLim && *toP < toLim) {
    unsigned short c = uenc->utf16[(unsigned char)**fromP];
    if (c == 0) {
      c = (unsigned short)uenc->convert(uenc->userData, *fromP);
      *fromP += (AS_NORMAL_ENCODING(enc)->type[(unsigned char)**fromP] -
                 (BT_LEAD2 - 2));
    } else
      (*fromP)++;
    *(*toP)++ = c;
  }

  if ((*toP == toLim) && (*fromP < fromLim))
    return XML_CONVERT_OUTPUT_EXHAUSTED;
  else
    return XML_CONVERT_COMPLETED;
}

ENCODING *XmlInitUnknownEncoding(void *mem, const int *table, CONVERTER convert,
                                 void *userData) {
  int i;
  struct unknown_encoding *e = (struct unknown_encoding *)mem;
  memcpy(mem, &latin1_encoding, sizeof(struct normal_encoding));
  for (i = 0; i < 128; i++)
    if (latin1_encoding.type[i] != BT_OTHER &&
        latin1_encoding.type[i] != BT_NONXML && table[i] != i)
      return 0;
  for (i = 0; i < 256; i++) {
    int c = table[i];
    if (c == -1) {
      e->normal.type[i] = BT_MALFORM;
      /* This shouldn't really get used. */
      e->utf16[i] = 0xFFFF;
      e->utf8[i][0] = 1;
      e->utf8[i][1] = 0;
    } else if (c < 0) {
      if (c < -4)
        return 0;
      /* Multi-byte sequences need a converter function */
      if (!convert)
        return 0;
      e->normal.type[i] = (unsigned char)(BT_LEAD2 - (c + 2));
      e->utf8[i][0] = 0;
      e->utf16[i] = 0;
    } else if (c < 0x80) {
      if (latin1_encoding.type[c] != BT_OTHER &&
          latin1_encoding.type[c] != BT_NONXML && c != i)
        return 0;
      e->normal.type[i] = latin1_encoding.type[c];
      e->utf8[i][0] = 1;
      e->utf8[i][1] = (char)c;
      e->utf16[i] = (unsigned short)(c == 0 ? 0xFFFF : c);
    } else if (checkCharRefNumber(c) < 0) {
      e->normal.type[i] = BT_NONXML;
      /* This shouldn't really get used. */
      e->utf16[i] = 0xFFFF;
      e->utf8[i][0] = 1;
      e->utf8[i][1] = 0;
    } else {
      if (c > 0xFFFF)
        return 0;
      if (UCS2_GET_NAMING(nmstrtPages, c >> 8, c & 0xff))
        e->normal.type[i] = BT_NMSTRT;
      else if (UCS2_GET_NAMING(namePages, c >> 8, c & 0xff))
        e->normal.type[i] = BT_NAME;
      else
        e->normal.type[i] = BT_OTHER;
      e->utf8[i][0] = (char)XmlUtf8Encode(c, e->utf8[i] + 1);
      e->utf16[i] = (unsigned short)c;
    }
  }
  e->userData = userData;
  e->convert = convert;
  if (convert) {
    e->normal.isName2 = unknown_isName;
    e->normal.isName3 = unknown_isName;
    e->normal.isName4 = unknown_isName;
    e->normal.isNmstrt2 = unknown_isNmstrt;
    e->normal.isNmstrt3 = unknown_isNmstrt;
    e->normal.isNmstrt4 = unknown_isNmstrt;
    e->normal.isInvalid2 = unknown_isInvalid;
    e->normal.isInvalid3 = unknown_isInvalid;
    e->normal.isInvalid4 = unknown_isInvalid;
  }
  e->normal.enc.utf8Convert = unknown_toUtf8;
  e->normal.enc.utf16Convert = unknown_toUtf16;
  return &(e->normal.enc);
}

/* If this enumeration is changed, getEncodingIndex and encodings
must also be changed. */
enum {
  UNKNOWN_ENC = -1,
  ISO_8859_1_ENC = 0,
  US_ASCII_ENC,
  UTF_8_ENC,
  UTF_16_ENC,
  UTF_16BE_ENC,
  UTF_16LE_ENC,
  /* must match encodingNames up to here */
  NO_ENC
};

static const char KW_ISO_8859_1[] = {ASCII_I,     ASCII_S, ASCII_O, ASCII_MINUS,
                                     ASCII_8,     ASCII_8, ASCII_5, ASCII_9,
                                     ASCII_MINUS, ASCII_1, '\0'};
static const char KW_US_ASCII[] = {ASCII_U, ASCII_S, ASCII_MINUS,
                                   ASCII_A, ASCII_S, ASCII_C,
                                   ASCII_I, ASCII_I, '\0'};
static const char KW_UTF_8[] = {ASCII_U,     ASCII_T, ASCII_F,
                                ASCII_MINUS, ASCII_8, '\0'};
static const char KW_UTF_16[] = {ASCII_U, ASCII_T, ASCII_F, ASCII_MINUS,
                                 ASCII_1, ASCII_6, '\0'};
static const char KW_UTF_16BE[] = {ASCII_U,     ASCII_T, ASCII_F,
                                   ASCII_MINUS, ASCII_1, ASCII_6,
                                   ASCII_B,     ASCII_E, '\0'};
static const char KW_UTF_16LE[] = {ASCII_U,     ASCII_T, ASCII_F,
                                   ASCII_MINUS, ASCII_1, ASCII_6,
                                   ASCII_L,     ASCII_E, '\0'};

static int FASTCALL getEncodingIndex(const char *name) {
  static const char *const encodingNames[] = {
      KW_ISO_8859_1, KW_US_ASCII, KW_UTF_8, KW_UTF_16, KW_UTF_16BE, KW_UTF_16LE,
  };
  int i;
  if (name == NULL)
    return NO_ENC;
  for (i = 0; i < (int)(sizeof(encodingNames) / sizeof(encodingNames[0])); i++)
    if (streqci(name, encodingNames[i]))
      return i;
  return UNKNOWN_ENC;
}

/* For binary compatibility, we store the index of the encoding
   specified at initialization in the isUtf16 member.
*/

#define INIT_ENC_INDEX(enc) ((int)(enc)->initEnc.isUtf16)
#define SET_INIT_ENC_INDEX(enc, i) ((enc)->initEnc.isUtf16 = (char)i)

/* This is what detects the encoding.  encodingTable maps from
   encoding indices to encodings; INIT_ENC_INDEX(enc) is the index of
   the external (protocol) specified encoding; state is
   XML_CONTENT_STATE if we're parsing an external text entity, and
   XML_PROLOG_STATE otherwise.
*/

static int initScan(const ENCODING *const *encodingTable,
                    const INIT_ENCODING *enc, int state, const char *ptr,
                    const char *end, const char **nextTokPtr) {
  const ENCODING **encPtr;

  if (ptr >= end)
    return XML_TOK_NONE;
  encPtr = enc->encPtr;
  if (ptr + 1 == end) {
    /* only a single byte available for auto-detection */
#ifndef XML_DTD /* FIXME */
    /* a well-formed document entity must have more than one byte */
    if (state != XML_CONTENT_STATE)
      return XML_TOK_PARTIAL;
#endif
    /* so we're parsing an external text entity... */
    /* if UTF-16 was externally specified, then we need at least 2 bytes */
    switch (INIT_ENC_INDEX(enc)) {
    case UTF_16_ENC:
    case UTF_16LE_ENC:
    case UTF_16BE_ENC:
      return XML_TOK_PARTIAL;
    }
    switch ((unsigned char)*ptr) {
    case 0xFE:
    case 0xFF:
    case 0xEF: /* possibly first byte of UTF-8 BOM */
      if (INIT_ENC_INDEX(enc) == ISO_8859_1_ENC && state == XML_CONTENT_STATE)
        break;
      /* fall through */
    case 0x00:
    case 0x3C:
      return XML_TOK_PARTIAL;
    }
  } else {
    switch (((unsigned char)ptr[0] << 8) | (unsigned char)ptr[1]) {
    case 0xFEFF:
      if (INIT_ENC_INDEX(enc) == ISO_8859_1_ENC && state == XML_CONTENT_STATE)
        break;
      *nextTokPtr = ptr + 2;
      *encPtr = encodingTable[UTF_16BE_ENC];
      return XML_TOK_BOM;
    /* 00 3C is handled in the default case */
    case 0x3C00:
      if ((INIT_ENC_INDEX(enc) == UTF_16BE_ENC ||
           INIT_ENC_INDEX(enc) == UTF_16_ENC) &&
          state == XML_CONTENT_STATE)
        break;
      *encPtr = encodingTable[UTF_16LE_ENC];
      return XmlTok(*encPtr, state, ptr, end, nextTokPtr);
    case 0xFFFE:
      if (INIT_ENC_INDEX(enc) == ISO_8859_1_ENC && state == XML_CONTENT_STATE)
        break;
      *nextTokPtr = ptr + 2;
      *encPtr = encodingTable[UTF_16LE_ENC];
      return XML_TOK_BOM;
    case 0xEFBB:
      /* Maybe a UTF-8 BOM (EF BB BF) */
      /* If there's an explicitly specified (external) encoding
         of ISO-8859-1 or some flavour of UTF-16
         and this is an external text entity,
         don't look for the BOM,
         because it might be a legal data.
      */
      if (state == XML_CONTENT_STATE) {
        int e = INIT_ENC_INDEX(enc);
        if (e == ISO_8859_1_ENC || e == UTF_16BE_ENC || e == UTF_16LE_ENC ||
            e == UTF_16_ENC)
          break;
      }
      if (ptr + 2 == end)
        return XML_TOK_PARTIAL;
      if ((unsigned char)ptr[2] == 0xBF) {
        *nextTokPtr = ptr + 3;
        *encPtr = encodingTable[UTF_8_ENC];
        return XML_TOK_BOM;
      }
      break;
    default:
      if (ptr[0] == '\0') {
        /* 0 isn't a legal data character. Furthermore a document
           entity can only start with ASCII characters.  So the only
           way this can fail to be big-endian UTF-16 if it it's an
           external parsed general entity that's labelled as
           UTF-16LE.
        */
        if (state == XML_CONTENT_STATE && INIT_ENC_INDEX(enc) == UTF_16LE_ENC)
          break;
        *encPtr = encodingTable[UTF_16BE_ENC];
        return XmlTok(*encPtr, state, ptr, end, nextTokPtr);
      } else if (ptr[1] == '\0') {
        /* We could recover here in the case:
            - parsing an external entity
            - second byte is 0
            - no externally specified encoding
            - no encoding declaration
           by assuming UTF-16LE.  But we don't, because this would mean when
           presented just with a single byte, we couldn't reliably determine
           whether we needed further bytes.
        */
        if (state == XML_CONTENT_STATE)
          break;
        *encPtr = encodingTable[UTF_16LE_ENC];
        return XmlTok(*encPtr, state, ptr, end, nextTokPtr);
      }
      break;
    }
  }
  *encPtr = encodingTable[INIT_ENC_INDEX(enc)];
  return XmlTok(*encPtr, state, ptr, end, nextTokPtr);
}

#define NS(x) x
#define ns(x) x
#define XML_TOK_NS_C
/* --- INLINED xmltok_ns.c --- */

#ifdef XML_TOK_NS_C

const ENCODING *NS(XmlGetUtf8InternalEncoding)(void) {
  return &ns(internal_utf8_encoding).enc;
}

const ENCODING *NS(XmlGetUtf16InternalEncoding)(void) {
#if BYTEORDER == 1234
  return &ns(internal_little2_encoding).enc;
#elif BYTEORDER == 4321
  return &ns(internal_big2_encoding).enc;
#else
  const short n = 1;
  return (*(const char *)&n ? &ns(internal_little2_encoding).enc
                            : &ns(internal_big2_encoding).enc);
#endif
}

static const ENCODING *const NS(encodings)[] = {
    &ns(latin1_encoding).enc, &ns(ascii_encoding).enc,
    &ns(utf8_encoding).enc,   &ns(big2_encoding).enc,
    &ns(big2_encoding).enc,   &ns(little2_encoding).enc,
    &ns(utf8_encoding).enc /* NO_ENC */
};

static int PTRCALL NS(initScanProlog)(const ENCODING *enc, const char *ptr,
                                      const char *end,
                                      const char **nextTokPtr) {
  return initScan(NS(encodings), (const INIT_ENCODING *)enc, XML_PROLOG_STATE,
                  ptr, end, nextTokPtr);
}

static int PTRCALL NS(initScanContent)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  return initScan(NS(encodings), (const INIT_ENCODING *)enc, XML_CONTENT_STATE,
                  ptr, end, nextTokPtr);
}

int NS(XmlInitEncoding)(INIT_ENCODING *p, const ENCODING **encPtr,
                        const char *name) {
  int i = getEncodingIndex(name);
  if (i == UNKNOWN_ENC)
    return 0;
  SET_INIT_ENC_INDEX(p, i);
  p->initEnc.scanners[XML_PROLOG_STATE] = NS(initScanProlog);
  p->initEnc.scanners[XML_CONTENT_STATE] = NS(initScanContent);
  p->initEnc.updatePosition = initUpdatePosition;
  p->encPtr = encPtr;
  *encPtr = &(p->initEnc);
  return 1;
}

static const ENCODING *NS(findEncoding)(const ENCODING *enc, const char *ptr,
                                        const char *end) {
#define ENCODING_MAX 128
  char buf[ENCODING_MAX] = "";
  char *p = buf;
  int i;
  XmlUtf8Convert(enc, &ptr, end, &p, p + ENCODING_MAX - 1);
  if (ptr != end)
    return NULL;
  *p = 0;
  if (streqci(buf, KW_UTF_16) && enc->minBytesPerChar == 2)
    return enc;
  i = getEncodingIndex(buf);
  if (i == UNKNOWN_ENC)
    return NULL;
  return NS(encodings)[i];
}

int NS(XmlParseXmlDecl)(int isGeneralTextEntity, const ENCODING *enc,
                        const char *ptr, const char *end, const char **badPtr,
                        const char **versionPtr, const char **versionEndPtr,
                        const char **encodingName, const ENCODING **encoding,
                        int *standalone) {
  return doParseXmlDecl(NS(findEncoding), isGeneralTextEntity, enc, ptr, end,
                        badPtr, versionPtr, versionEndPtr, encodingName,
                        encoding, standalone);
}

#endif /* XML_TOK_NS_C */
#undef XML_TOK_NS_C
#undef NS
#undef ns

#ifdef XML_NS

#define NS(x) x##NS
#define ns(x) x##_ns

#define XML_TOK_NS_C
/* --- INLINED xmltok_ns.c --- */

#ifdef XML_TOK_NS_C

const ENCODING *NS(XmlGetUtf8InternalEncoding)(void) {
  return &ns(internal_utf8_encoding).enc;
}

const ENCODING *NS(XmlGetUtf16InternalEncoding)(void) {
#if BYTEORDER == 1234
  return &ns(internal_little2_encoding).enc;
#elif BYTEORDER == 4321
  return &ns(internal_big2_encoding).enc;
#else
  const short n = 1;
  return (*(const char *)&n ? &ns(internal_little2_encoding).enc
                            : &ns(internal_big2_encoding).enc);
#endif
}

static const ENCODING *const NS(encodings)[] = {
    &ns(latin1_encoding).enc, &ns(ascii_encoding).enc,
    &ns(utf8_encoding).enc,   &ns(big2_encoding).enc,
    &ns(big2_encoding).enc,   &ns(little2_encoding).enc,
    &ns(utf8_encoding).enc /* NO_ENC */
};

static int PTRCALL NS(initScanProlog)(const ENCODING *enc, const char *ptr,
                                      const char *end,
                                      const char **nextTokPtr) {
  return initScan(NS(encodings), (const INIT_ENCODING *)enc, XML_PROLOG_STATE,
                  ptr, end, nextTokPtr);
}

static int PTRCALL NS(initScanContent)(const ENCODING *enc, const char *ptr,
                                       const char *end,
                                       const char **nextTokPtr) {
  return initScan(NS(encodings), (const INIT_ENCODING *)enc, XML_CONTENT_STATE,
                  ptr, end, nextTokPtr);
}

int NS(XmlInitEncoding)(INIT_ENCODING *p, const ENCODING **encPtr,
                        const char *name) {
  int i = getEncodingIndex(name);
  if (i == UNKNOWN_ENC)
    return 0;
  SET_INIT_ENC_INDEX(p, i);
  p->initEnc.scanners[XML_PROLOG_STATE] = NS(initScanProlog);
  p->initEnc.scanners[XML_CONTENT_STATE] = NS(initScanContent);
  p->initEnc.updatePosition = initUpdatePosition;
  p->encPtr = encPtr;
  *encPtr = &(p->initEnc);
  return 1;
}

static const ENCODING *NS(findEncoding)(const ENCODING *enc, const char *ptr,
                                        const char *end) {
#define ENCODING_MAX 128
  char buf[ENCODING_MAX] = "";
  char *p = buf;
  int i;
  XmlUtf8Convert(enc, &ptr, end, &p, p + ENCODING_MAX - 1);
  if (ptr != end)
    return NULL;
  *p = 0;
  if (streqci(buf, KW_UTF_16) && enc->minBytesPerChar == 2)
    return enc;
  i = getEncodingIndex(buf);
  if (i == UNKNOWN_ENC)
    return NULL;
  return NS(encodings)[i];
}

int NS(XmlParseXmlDecl)(int isGeneralTextEntity, const ENCODING *enc,
                        const char *ptr, const char *end, const char **badPtr,
                        const char **versionPtr, const char **versionEndPtr,
                        const char **encodingName, const ENCODING **encoding,
                        int *standalone) {
  return doParseXmlDecl(NS(findEncoding), isGeneralTextEntity, enc, ptr, end,
                        badPtr, versionPtr, versionEndPtr, encodingName,
                        encoding, standalone);
}

#endif /* XML_TOK_NS_C */
#undef XML_TOK_NS_C

#undef NS
#undef ns

ENCODING *XmlInitUnknownEncodingNS(void *mem, const int *table,
                                   CONVERTER convert, void *userData) {
  ENCODING *enc = XmlInitUnknownEncoding(mem, table, convert, userData);
  if (enc)
    ((struct normal_encoding *)enc)->type[ASCII_COLON] = BT_COLON;
  return enc;
}

#endif /* XML_NS */
/* --- xmlparse.c --- */

#if !defined(XML_GE) || (1 - XML_GE - 1 == 2) || (XML_GE < 0) || (XML_GE > 1)
#error XML_GE (for general entities) must be defined, non-empty, either 1 or 0 (0 to disable, 1 to enable; 1 is a common default)
#endif

#if defined(XML_DTD) && XML_GE == 0
#error Either undefine XML_DTD or define XML_GE to 1.
#endif

#if !defined(XML_CONTEXT_BYTES) || (1 - XML_CONTEXT_BYTES - 1 == 2) ||         \
    (XML_CONTEXT_BYTES + 0 < 0)
#error XML_CONTEXT_BYTES must be defined, non-empty and >=0 (0 to disable, >=1 to enable; 1024 is a common default)
#endif

#if defined(HAVE_SYSCALL_GETRANDOM)
#if !defined(_GNU_SOURCE)
#define _GNU_SOURCE 1 /* syscall prototype */
#endif
#endif

#include <assert.h>
#include <limits.h> /* INT_MAX, UINT_MAX */
#include <math.h>   /* isnan */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h> /* SIZE_MAX, uintptr_t */
#include <stdio.h>  /* fprintf */
#include <stdlib.h> /* getenv, rand_s */
#include <string.h> /* memset(), memcpy() */

#include <errno.h>
#include <fcntl.h>     /* O_RDONLY */
#include <sys/time.h>  /* gettimeofday() */
#include <sys/types.h> /* getpid() */
#include <unistd.h>    /* getpid() */

#include "ascii.h"
#include "expat.h"
#include "siphash.h"

#if defined(HAVE_GETRANDOM) || defined(HAVE_SYSCALL_GETRANDOM)
#if defined(HAVE_GETRANDOM)
#include <sys/random.h> /* getrandom */
#else
#include <sys/syscall.h> /* SYS_getrandom */
#include <unistd.h>      /* syscall */
#endif
#if !defined(GRND_NONBLOCK)
#define GRND_NONBLOCK 0x0001
#endif /* defined(GRND_NONBLOCK) */
#endif /* defined(HAVE_GETRANDOM) || defined(HAVE_SYSCALL_GETRANDOM) */

#if !defined(HAVE_GETRANDOM) && !defined(HAVE_SYSCALL_GETRANDOM) &&            \
    !defined(HAVE_ARC4RANDOM_BUF) && !defined(HAVE_ARC4RANDOM) &&              \
    !defined(XML_DEV_URANDOM) && !defined(_WIN32) &&                           \
    !defined(XML_POOR_ENTROPY)
#error You do not have support for any sources of high quality entropy \
    enabled.  For end user security, that is probably not what you want. \
    \
    Your options include: \
      * Linux >=3.17 + glibc >=2.25 (getrandom): HAVE_GETRANDOM, \
      * Linux >=3.17 + glibc (including <2.25) (syscall SYS_getrandom): HAVE_SYSCALL_GETRANDOM, \
      * BSD / macOS >=10.7 / glibc >=2.36 (arc4random_buf): HAVE_ARC4RANDOM_BUF, \
      * BSD / macOS (including <10.7) / glibc >=2.36 (arc4random): HAVE_ARC4RANDOM, \
      * Linux (including <3.17) / BSD / macOS (including <10.7) / Solaris >=8 (/dev/urandom): XML_DEV_URANDOM, \
      * Windows >=Vista (rand_s): _WIN32. \
    \
    If insist on not using any of these, bypass this error by defining \
    XML_POOR_ENTROPY; you have been warned. \
    \
    If you have reasons to patch this detection code away or need changes \
    to the build system, please open a bug.  Thank you!
#endif

#ifdef XML_UNICODE
#define XML_ENCODE_MAX XML_UTF16_ENCODE_MAX
#define XmlConvert XmlUtf16Convert
#define XmlGetInternalEncoding XmlGetUtf16InternalEncoding
#define XmlGetInternalEncodingNS XmlGetUtf16InternalEncodingNS
#define XmlEncode XmlUtf16Encode
#define MUST_CONVERT(enc, s) (!(enc)->isUtf16 || (((uintptr_t)(s)) & 1))
typedef unsigned short ICHAR;
#else
#define XML_ENCODE_MAX XML_UTF8_ENCODE_MAX
#define XmlConvert XmlUtf8Convert
#define XmlGetInternalEncoding XmlGetUtf8InternalEncoding
#define XmlGetInternalEncodingNS XmlGetUtf8InternalEncodingNS
#define XmlEncode XmlUtf8Encode
#define MUST_CONVERT(enc, s) (!(enc)->isUtf8)
typedef char ICHAR;
#endif

#ifndef XML_NS

#define XmlInitEncodingNS XmlInitEncoding
#define XmlInitUnknownEncodingNS XmlInitUnknownEncoding
#undef XmlGetInternalEncodingNS
#define XmlGetInternalEncodingNS XmlGetInternalEncoding
#define XmlParseXmlDeclNS XmlParseXmlDecl

#endif

#ifdef XML_UNICODE

#ifdef XML_UNICODE_WCHAR_T
#define XML_T(x) (const wchar_t) x
#define XML_L(x) L##x
#else
#define XML_T(x) (const unsigned short)x
#define XML_L(x) x
#endif

#else

#define XML_T(x) x
#define XML_L(x) x

#endif

/* Round up n to be a multiple of sz, where sz is a power of 2. */
#define ROUND_UP(n, sz) (((n) + ((sz) - 1)) & ~((sz) - 1))

/* Do safe (NULL-aware) pointer arithmetic */
#define EXPAT_SAFE_PTR_DIFF(p, q) (((p) && (q)) ? ((p) - (q)) : 0)

#define EXPAT_MIN(a, b) (((a) < (b)) ? (a) : (b))

#include "internal.h"
#include "xmlrole.h"
#include "xmltok.h"

typedef const XML_Char *KEY;

typedef struct {
  KEY name;
} NAMED;

typedef struct {
  NAMED **v;
  unsigned char power;
  size_t size;
  size_t used;
  XML_Parser parser;
} HASH_TABLE;

static size_t keylen(KEY s);

static void copy_salt_to_sipkey(XML_Parser parser, struct sipkey *key);

/* For probing (after a collision) we need a step size relative prime
   to the hash table size, which is a power of 2. We use double-hashing,
   since we can calculate a second hash value cheaply by taking those bits
   of the first hash value that were discarded (masked out) when the table
   index was calculated: index = hash & mask, where mask = table->size - 1.
   We limit the maximum step size to table->size / 4 (mask >> 2) and make
   it odd, since odd numbers are always relative prime to a power of 2.
*/
#define SECOND_HASH(hash, mask, power)                                         \
  ((((hash) & ~(mask)) >> ((power) - 1)) & ((mask) >> 2))
#define PROBE_STEP(hash, mask, power)                                          \
  ((unsigned char)((SECOND_HASH(hash, mask, power)) | 1))

typedef struct {
  NAMED **p;
  NAMED **end;
} HASH_TABLE_ITER;

#define INIT_TAG_BUF_SIZE 32 /* must be a multiple of sizeof(XML_Char) */
#define INIT_DATA_BUF_SIZE 1024
#define INIT_ATTS_SIZE 16
#define INIT_ATTS_VERSION 0xFFFFFFFF
#define INIT_BLOCK_SIZE 1024
#define INIT_BUFFER_SIZE 1024

#define EXPAND_SPARE 24

typedef struct binding {
  struct prefix *prefix;
  struct binding *nextTagBinding;
  struct binding *prevPrefixBinding;
  const struct attribute_id *attId;
  XML_Char *uri;
  int uriLen;
  int uriAlloc;
} BINDING;

typedef struct prefix {
  const XML_Char *name;
  BINDING *binding;
} PREFIX;

typedef struct {
  const XML_Char *str;
  const XML_Char *localPart;
  const XML_Char *prefix;
  int strLen;
  int uriLen;
  int prefixLen;
} TAG_NAME;

/* TAG represents an open element.
   The name of the element is stored in both the document and API
   encodings.  The memory buffer 'buf' is a separately-allocated
   memory area which stores the name.  During the XML_Parse()/
   XML_ParseBuffer() when the element is open, the memory for the 'raw'
   version of the name (in the document encoding) is shared with the
   document buffer.  If the element is open across calls to
   XML_Parse()/XML_ParseBuffer(), the buffer is re-allocated to
   contain the 'raw' name as well.

   A parser reuses these structures, maintaining a list of allocated
   TAG objects in a free list.
*/
typedef struct tag {
  struct tag *parent;  /* parent of this element */
  const char *rawName; /* tagName in the original encoding */
  int rawNameLength;
  TAG_NAME name; /* tagName in the API encoding */
  union {
    char *raw;     /* for byte-level access (rawName storage) */
    XML_Char *str; /* for character-level access (converted name) */
  } buf;           /* buffer for name components */
  char *bufEnd;    /* end of the buffer */
  BINDING *bindings;
} TAG;

typedef struct {
  const XML_Char *name;
  const XML_Char *textPtr;
  int textLen;   /* length in XML_Chars */
  int processed; /* # of processed bytes - when suspended */
  const XML_Char *systemId;
  const XML_Char *base;
  const XML_Char *publicId;
  const XML_Char *notation;
  XML_Bool open;
  XML_Bool hasMore; /* true if entity has not been completely processed */
  /* An entity can be open while being already completely processed (hasMore ==
    XML_FALSE). The reason is the delayed closing of entities until their inner
    entities are processed and closed */
  XML_Bool is_param;
  XML_Bool is_internal; /* true if declared in internal subset outside PE */
} ENTITY;

typedef struct {
  enum XML_Content_Type type;
  enum XML_Content_Quant quant;
  const XML_Char *name;
  int firstchild;
  int lastchild;
  int childcnt;
  int nextsib;
} CONTENT_SCAFFOLD;

#define INIT_SCAFFOLD_ELEMENTS 32

typedef struct block {
  struct block *next;
  int size;
  XML_Char s[];
} BLOCK;

typedef struct {
  BLOCK *blocks;
  BLOCK *freeBlocks;
  const XML_Char *end;
  XML_Char *ptr;
  XML_Char *start;
  XML_Parser parser;
} STRING_POOL;

/* The XML_Char before the name is used to determine whether
   an attribute has been specified. */
typedef struct attribute_id {
  XML_Char *name;
  PREFIX *prefix;
  XML_Bool maybeTokenized;
  XML_Bool xmlns;
} ATTRIBUTE_ID;

typedef struct {
  const ATTRIBUTE_ID *id;
  XML_Bool isCdata;
  const XML_Char *value;
} DEFAULT_ATTRIBUTE;

typedef struct {
  unsigned long version;
  unsigned long hash;
  const XML_Char *uriName;
} NS_ATT;

typedef struct {
  const XML_Char *name;
  PREFIX *prefix;
  const ATTRIBUTE_ID *idAtt;
  int nDefaultAtts;
  int allocDefaultAtts;
  DEFAULT_ATTRIBUTE *defaultAtts;
} ELEMENT_TYPE;

typedef struct {
  HASH_TABLE generalEntities;
  HASH_TABLE elementTypes;
  HASH_TABLE attributeIds;
  HASH_TABLE prefixes;
  STRING_POOL pool;
  STRING_POOL entityValuePool;
  /* false once a parameter entity reference has been skipped */
  XML_Bool keepProcessing;
  /* true once an internal or external PE reference has been encountered;
     this includes the reference to an external subset */
  XML_Bool hasParamEntityRefs;
  XML_Bool standalone;
#ifdef XML_DTD
  /* indicates if external PE has been read */
  XML_Bool paramEntityRead;
  HASH_TABLE paramEntities;
#endif /* XML_DTD */
  PREFIX defaultPrefix;
  /* === scaffolding for building content model === */
  XML_Bool in_eldecl;
  CONTENT_SCAFFOLD *scaffold;
  unsigned contentStringLen;
  unsigned scaffSize;
  unsigned scaffCount;
  int scaffLevel;
  int *scaffIndex;
} DTD;

enum EntityType {
  ENTITY_INTERNAL,
  ENTITY_ATTRIBUTE,
  ENTITY_VALUE,
};

typedef struct open_internal_entity {
  const char *internalEventPtr;
  const char *internalEventEndPtr;
  struct open_internal_entity *next;
  ENTITY *entity;
  int startTagLevel;
  XML_Bool betweenDecl; /* WFC: PE Between Declarations */
  enum EntityType type;
} OPEN_INTERNAL_ENTITY;

enum XML_Account {
  XML_ACCOUNT_DIRECT,           /* bytes directly passed to the Expat parser */
  XML_ACCOUNT_ENTITY_EXPANSION, /* intermediate bytes produced during entity
                                   expansion */
  XML_ACCOUNT_NONE              /* i.e. do not account, was accounted already */
};

#if XML_GE == 1
typedef unsigned long long XmlBigCount;
typedef struct accounting {
  XmlBigCount countBytesDirect;
  XmlBigCount countBytesIndirect;
  unsigned long debugLevel;
  float maximumAmplificationFactor; // >=1.0
  unsigned long long activationThresholdBytes;
} ACCOUNTING;

typedef struct MALLOC_TRACKER {
  XmlBigCount bytesAllocated;
  XmlBigCount peakBytesAllocated; // updated live only for debug level >=2
  unsigned long debugLevel;
  float maximumAmplificationFactor; // >=1.0
  XmlBigCount activationThresholdBytes;
} MALLOC_TRACKER;

typedef struct entity_stats {
  unsigned int countEverOpened;
  unsigned int currentDepth;
  unsigned int maximumDepthSeen;
  unsigned long debugLevel;
} ENTITY_STATS;
#endif /* XML_GE == 1 */

typedef enum XML_Error PTRCALL Processor(XML_Parser parser, const char *start,
                                         const char *end, const char **endPtr);

static Processor prologProcessor;
static Processor prologInitProcessor;
static Processor contentProcessor;
static Processor cdataSectionProcessor;
#ifdef XML_DTD
static Processor ignoreSectionProcessor;
static Processor externalParEntProcessor;
static Processor externalParEntInitProcessor;
static Processor entityValueProcessor;
static Processor entityValueInitProcessor;
#endif /* XML_DTD */
static Processor epilogProcessor;
static Processor errorProcessor;
static Processor externalEntityInitProcessor;
static Processor externalEntityInitProcessor2;
static Processor externalEntityInitProcessor3;
static Processor externalEntityContentProcessor;
static Processor internalEntityProcessor;

static enum XML_Error handleUnknownEncoding(XML_Parser parser,
                                            const XML_Char *encodingName);
static enum XML_Error processXmlDecl(XML_Parser parser, int isGeneralTextEntity,
                                     const char *s, const char *next);
static enum XML_Error initializeEncoding(XML_Parser parser);
static enum XML_Error doProlog(XML_Parser parser, const ENCODING *enc,
                               const char *s, const char *end, int tok,
                               const char *next, const char **nextPtr,
                               XML_Bool haveMore, XML_Bool allowClosingDoctype,
                               enum XML_Account account);
static enum XML_Error processEntity(XML_Parser parser, ENTITY *entity,
                                    XML_Bool betweenDecl, enum EntityType type);
static enum XML_Error doContent(XML_Parser parser, int startTagLevel,
                                const ENCODING *enc, const char *start,
                                const char *end, const char **endPtr,
                                XML_Bool haveMore, enum XML_Account account);
static enum XML_Error doCdataSection(XML_Parser parser, const ENCODING *enc,
                                     const char **startPtr, const char *end,
                                     const char **nextPtr, XML_Bool haveMore,
                                     enum XML_Account account);
#ifdef XML_DTD
static enum XML_Error doIgnoreSection(XML_Parser parser, const ENCODING *enc,
                                      const char **startPtr, const char *end,
                                      const char **nextPtr, XML_Bool haveMore);
#endif /* XML_DTD */

static void freeBindings(XML_Parser parser, BINDING *bindings);
static enum XML_Error storeAtts(XML_Parser parser, const ENCODING *enc,
                                const char *attStr, TAG_NAME *tagNamePtr,
                                BINDING **bindingsPtr,
                                enum XML_Account account);
static enum XML_Error addBinding(XML_Parser parser, PREFIX *prefix,
                                 const ATTRIBUTE_ID *attId, const XML_Char *uri,
                                 BINDING **bindingsPtr);
static int defineAttribute(ELEMENT_TYPE *type, ATTRIBUTE_ID *attId,
                           XML_Bool isCdata, XML_Bool isId,
                           const XML_Char *value, XML_Parser parser);
static enum XML_Error storeAttributeValue(XML_Parser parser,
                                          const ENCODING *enc, XML_Bool isCdata,
                                          const char *ptr, const char *end,
                                          STRING_POOL *pool,
                                          enum XML_Account account);
static enum XML_Error
appendAttributeValue(XML_Parser parser, const ENCODING *enc, XML_Bool isCdata,
                     const char *ptr, const char *end, STRING_POOL *pool,
                     enum XML_Account account, const char **nextPtr);
static ATTRIBUTE_ID *getAttributeId(XML_Parser parser, const ENCODING *enc,
                                    const char *start, const char *end);
static int setElementTypePrefix(XML_Parser parser, ELEMENT_TYPE *elementType);
#if XML_GE == 1
static enum XML_Error storeEntityValue(XML_Parser parser, const ENCODING *enc,
                                       const char *start, const char *end,
                                       enum XML_Account account,
                                       const char **nextPtr);
static enum XML_Error callStoreEntityValue(XML_Parser parser,
                                           const ENCODING *enc,
                                           const char *start, const char *end,
                                           enum XML_Account account);
#else
static enum XML_Error storeSelfEntityValue(XML_Parser parser, ENTITY *entity);
#endif
static int reportProcessingInstruction(XML_Parser parser, const ENCODING *enc,
                                       const char *start, const char *end);
static int reportComment(XML_Parser parser, const ENCODING *enc,
                         const char *start, const char *end);
static void reportDefault(XML_Parser parser, const ENCODING *enc,
                          const char *start, const char *end);

static const XML_Char *getContext(XML_Parser parser);
static XML_Bool setContext(XML_Parser parser, const XML_Char *context);

static void FASTCALL normalizePublicId(XML_Char *s);

static DTD *dtdCreate(XML_Parser parser);
/* do not call if m_parentParser != NULL */
static void dtdReset(DTD *p, XML_Parser parser);
static void dtdDestroy(DTD *p, XML_Bool isDocEntity, XML_Parser parser);
static int dtdCopy(XML_Parser oldParser, DTD *newDtd, const DTD *oldDtd,
                   XML_Parser parser);
static int copyEntityTable(XML_Parser oldParser, HASH_TABLE *newTable,
                           STRING_POOL *newPool, const HASH_TABLE *oldTable);
static NAMED *lookup(XML_Parser parser, HASH_TABLE *table, KEY name,
                     size_t createSize);
static void FASTCALL hashTableInit(HASH_TABLE *table, XML_Parser parser);
static void FASTCALL hashTableClear(HASH_TABLE *table);
static void FASTCALL hashTableDestroy(HASH_TABLE *table);
static void FASTCALL hashTableIterInit(HASH_TABLE_ITER *iter,
                                       const HASH_TABLE *table);
static NAMED *FASTCALL hashTableIterNext(HASH_TABLE_ITER *iter);

static void FASTCALL poolInit(STRING_POOL *pool, XML_Parser parser);
static void FASTCALL poolClear(STRING_POOL *pool);
static void FASTCALL poolDestroy(STRING_POOL *pool);
static XML_Char *poolAppend(STRING_POOL *pool, const ENCODING *enc,
                            const char *ptr, const char *end);
static XML_Char *poolStoreString(STRING_POOL *pool, const ENCODING *enc,
                                 const char *ptr, const char *end);
static XML_Bool FASTCALL poolGrow(STRING_POOL *pool);
static const XML_Char *FASTCALL poolCopyString(STRING_POOL *pool,
                                               const XML_Char *s);
static const XML_Char *poolCopyStringN(STRING_POOL *pool, const XML_Char *s,
                                       int n);
static const XML_Char *FASTCALL poolAppendString(STRING_POOL *pool,
                                                 const XML_Char *s);

static int FASTCALL nextScaffoldPart(XML_Parser parser);
static XML_Content *build_model(XML_Parser parser);
static ELEMENT_TYPE *getElementType(XML_Parser parser, const ENCODING *enc,
                                    const char *ptr, const char *end);

static XML_Char *copyString(const XML_Char *s, XML_Parser parser);

static unsigned long generate_hash_secret_salt(XML_Parser parser);
static XML_Bool startParsing(XML_Parser parser);

static XML_Parser parserCreate(const XML_Char *encodingName,
                               const XML_Memory_Handling_Suite *memsuite,
                               const XML_Char *nameSep, DTD *dtd,
                               XML_Parser parentParser);

static void parserInit(XML_Parser parser, const XML_Char *encodingName);

#if XML_GE == 1
static float accountingGetCurrentAmplification(XML_Parser rootParser);
static void accountingReportStats(XML_Parser originParser, const char *epilog);
static void accountingOnAbort(XML_Parser originParser);
static void accountingReportDiff(XML_Parser rootParser,
                                 unsigned int levelsAwayFromRootParser,
                                 const char *before, const char *after,
                                 ptrdiff_t bytesMore, int source_line,
                                 enum XML_Account account);
static XML_Bool accountingDiffTolerated(XML_Parser originParser, int tok,
                                        const char *before, const char *after,
                                        int source_line,
                                        enum XML_Account account);

static void entityTrackingReportStats(XML_Parser parser, ENTITY *entity,
                                      const char *action, int sourceLine);
static void entityTrackingOnOpen(XML_Parser parser, ENTITY *entity,
                                 int sourceLine);
static void entityTrackingOnClose(XML_Parser parser, ENTITY *entity,
                                  int sourceLine);
#endif /* XML_GE == 1 */

static XML_Parser getRootParserOf(XML_Parser parser,
                                  unsigned int *outLevelDiff);

static unsigned long getDebugLevel(const char *variableName,
                                   unsigned long defaultDebugLevel);

#define poolStart(pool) ((pool)->start)
#define poolLength(pool) ((pool)->ptr - (pool)->start)
#define poolChop(pool) ((void)--(pool->ptr))
#define poolLastChar(pool) (((pool)->ptr)[-1])
#define poolDiscard(pool) ((pool)->ptr = (pool)->start)
#define poolFinish(pool) ((pool)->start = (pool)->ptr)
#define poolAppendChar(pool, c)                                                \
  (((pool)->ptr == (pool)->end && !poolGrow(pool))                             \
       ? 0                                                                     \
       : ((*((pool)->ptr)++ = c), 1))

#if !defined(XML_TESTING)
const
#endif
    XML_Bool g_reparseDeferralEnabledDefault =
        XML_TRUE; // write ONLY in runtests.c
#if defined(XML_TESTING)
unsigned int g_bytesScanned = 0; // used for testing only
#endif

struct XML_ParserStruct {
  /* The first member must be m_userData so that the XML_GetUserData
     macro works. */
  void *m_userData;
  void *m_handlerArg;

  // How the four parse buffer pointers below relate in time and space:
  //
  //   m_buffer <= m_bufferPtr <= m_bufferEnd  <= m_bufferLim
  //   |           |              |               |
  //   <--parsed-->|              |               |
  //               <---parsing--->|               |
  //                              <--unoccupied-->|
  //   <---------total-malloced/realloced-------->|

  char *m_buffer; // malloc/realloc base pointer of parse buffer
  const XML_Memory_Handling_Suite m_mem;
  const char *m_bufferPtr; // first character to be parsed
  char *m_bufferEnd;       // past last character to be parsed
  const char *m_bufferLim; // allocated end of m_buffer

  XML_Index m_parseEndByteIndex;
  const char *m_parseEndPtr;
  size_t m_partialTokenBytesBefore; /* used in heuristic to avoid O(n^2) */
  XML_Bool m_reparseDeferralEnabled;
  int m_lastBufferRequestSize;
  XML_Char *m_dataBuf;
  XML_Char *m_dataBufEnd;
  XML_StartElementHandler m_startElementHandler;
  XML_EndElementHandler m_endElementHandler;
  XML_CharacterDataHandler m_characterDataHandler;
  XML_ProcessingInstructionHandler m_processingInstructionHandler;
  XML_CommentHandler m_commentHandler;
  XML_StartCdataSectionHandler m_startCdataSectionHandler;
  XML_EndCdataSectionHandler m_endCdataSectionHandler;
  XML_DefaultHandler m_defaultHandler;
  XML_StartDoctypeDeclHandler m_startDoctypeDeclHandler;
  XML_EndDoctypeDeclHandler m_endDoctypeDeclHandler;
  XML_UnparsedEntityDeclHandler m_unparsedEntityDeclHandler;
  XML_NotationDeclHandler m_notationDeclHandler;
  XML_StartNamespaceDeclHandler m_startNamespaceDeclHandler;
  XML_EndNamespaceDeclHandler m_endNamespaceDeclHandler;
  XML_NotStandaloneHandler m_notStandaloneHandler;
  XML_ExternalEntityRefHandler m_externalEntityRefHandler;
  XML_Parser m_externalEntityRefHandlerArg;
  XML_SkippedEntityHandler m_skippedEntityHandler;
  XML_UnknownEncodingHandler m_unknownEncodingHandler;
  XML_ElementDeclHandler m_elementDeclHandler;
  XML_AttlistDeclHandler m_attlistDeclHandler;
  XML_EntityDeclHandler m_entityDeclHandler;
  XML_XmlDeclHandler m_xmlDeclHandler;
  const ENCODING *m_encoding;
  INIT_ENCODING m_initEncoding;
  const ENCODING *m_internalEncoding;
  const XML_Char *m_protocolEncodingName;
  XML_Bool m_ns;
  XML_Bool m_ns_triplets;
  void *m_unknownEncodingMem;
  void *m_unknownEncodingData;
  void *m_unknownEncodingHandlerData;
  void(XMLCALL *m_unknownEncodingRelease)(void *);
  PROLOG_STATE m_prologState;
  Processor *m_processor;
  enum XML_Error m_errorCode;
  const char *m_eventPtr;
  const char *m_eventEndPtr;
  const char *m_positionPtr;
  OPEN_INTERNAL_ENTITY *m_openInternalEntities;
  OPEN_INTERNAL_ENTITY *m_freeInternalEntities;
  OPEN_INTERNAL_ENTITY *m_openAttributeEntities;
  OPEN_INTERNAL_ENTITY *m_freeAttributeEntities;
  OPEN_INTERNAL_ENTITY *m_openValueEntities;
  OPEN_INTERNAL_ENTITY *m_freeValueEntities;
  XML_Bool m_defaultExpandInternalEntities;
  int m_tagLevel;
  ENTITY *m_declEntity;
  const XML_Char *m_doctypeName;
  const XML_Char *m_doctypeSysid;
  const XML_Char *m_doctypePubid;
  const XML_Char *m_declAttributeType;
  const XML_Char *m_declNotationName;
  const XML_Char *m_declNotationPublicId;
  ELEMENT_TYPE *m_declElementType;
  ATTRIBUTE_ID *m_declAttributeId;
  XML_Bool m_declAttributeIsCdata;
  XML_Bool m_declAttributeIsId;
  DTD *m_dtd;
  const XML_Char *m_curBase;
  TAG *m_tagStack;
  TAG *m_freeTagList;
  BINDING *m_inheritedBindings;
  BINDING *m_freeBindingList;
  int m_attsSize;
  int m_nSpecifiedAtts;
  int m_idAttIndex;
  ATTRIBUTE *m_atts;
  NS_ATT *m_nsAtts;
  unsigned long m_nsAttsVersion;
  unsigned char m_nsAttsPower;
#ifdef XML_ATTR_INFO
  XML_AttrInfo *m_attInfo;
#endif
  POSITION m_position;
  STRING_POOL m_tempPool;
  STRING_POOL m_temp2Pool;
  char *m_groupConnector;
  unsigned int m_groupSize;
  XML_Char m_namespaceSeparator;
  XML_Parser m_parentParser;
  XML_ParsingStatus m_parsingStatus;
#ifdef XML_DTD
  XML_Bool m_isParamEntity;
  XML_Bool m_useForeignDTD;
  enum XML_ParamEntityParsing m_paramEntityParsing;
#endif
  unsigned long m_hash_secret_salt;
#if XML_GE == 1
  ACCOUNTING m_accounting;
  MALLOC_TRACKER m_alloc_tracker;
  ENTITY_STATS m_entity_stats;
#endif
  XML_Bool m_reenter;
};

#if XML_GE == 1
#define MALLOC(parser, s) (expat_malloc((parser), (s), __LINE__))
#define REALLOC(parser, p, s) (expat_realloc((parser), (p), (s), __LINE__))
#define FREE(parser, p) (expat_free((parser), (p), __LINE__))
#else
#define MALLOC(parser, s) (parser->m_mem.malloc_fcn((s)))
#define REALLOC(parser, p, s) (parser->m_mem.realloc_fcn((p), (s)))
#define FREE(parser, p) (parser->m_mem.free_fcn((p)))
#endif

#if XML_GE == 1
static void expat_heap_stat(XML_Parser rootParser, char operator,
                            XmlBigCount absDiff, XmlBigCount newTotal,
                            XmlBigCount peakTotal, int sourceLine) {
  // NOTE: This can be +infinity or -nan
  const float amplification =
      (float)newTotal / (float)rootParser->m_accounting.countBytesDirect;
  fprintf(stderr,
          "expat: Allocations(%p): Direct " EXPAT_FMT_ULL(
              "10") ", allocated "
                    "%c" EXPAT_FMT_ULL("10") " to " EXPAT_FMT_ULL(
                        "10") " "
                              "(" EXPAT_FMT_ULL("10") " peak), amplification "
                                                      "%8.2f (xmlparse.c:%d)\n",
          (void *)rootParser,
          rootParser->m_accounting.countBytesDirect, operator, absDiff,
          newTotal, peakTotal, (double)amplification, sourceLine);
}

static bool expat_heap_increase_tolerable(XML_Parser rootParser,
                                          XmlBigCount increase,
                                          int sourceLine) {
  assert(rootParser != NULL);
  assert(increase > 0);

  XmlBigCount newTotal = 0;
  bool tolerable = true;

  // Detect integer overflow
  if ((XmlBigCount)-1 - rootParser->m_alloc_tracker.bytesAllocated < increase) {
    tolerable = false;
  } else {
    newTotal = rootParser->m_alloc_tracker.bytesAllocated + increase;

    if (newTotal >= rootParser->m_alloc_tracker.activationThresholdBytes) {
      assert(newTotal > 0);
      // NOTE: This can be +infinity when dividing by zero but not -nan
      const float amplification =
          (float)newTotal / (float)rootParser->m_accounting.countBytesDirect;
      if (amplification >
          rootParser->m_alloc_tracker.maximumAmplificationFactor) {
        tolerable = false;
      }
    }
  }

  if (!tolerable && (rootParser->m_alloc_tracker.debugLevel >= 1)) {
    expat_heap_stat(rootParser, '+', increase, newTotal, newTotal, sourceLine);
  }

  return tolerable;
}

#if defined(XML_TESTING)
void *
#else
static void *
#endif
expat_malloc(XML_Parser parser, size_t size, int sourceLine) {
  // Detect integer overflow
  if (SIZE_MAX - size < sizeof(size_t) + EXPAT_MALLOC_PADDING) {
    return NULL;
  }

  const XML_Parser rootParser = getRootParserOf(parser, NULL);
  assert(rootParser->m_parentParser == NULL);

  const size_t bytesToAllocate = sizeof(size_t) + EXPAT_MALLOC_PADDING + size;

  if ((XmlBigCount)-1 - rootParser->m_alloc_tracker.bytesAllocated <
      bytesToAllocate) {
    return NULL; // i.e. signal integer overflow as out-of-memory
  }

  if (!expat_heap_increase_tolerable(rootParser, bytesToAllocate, sourceLine)) {
    return NULL; // i.e. signal violation as out-of-memory
  }

  // Actually allocate
  void *const mallocedPtr = parser->m_mem.malloc_fcn(bytesToAllocate);

  if (mallocedPtr == NULL) {
    return NULL;
  }

  // Update in-block recorded size
  *(size_t *)mallocedPtr = size;

  // Update accounting
  rootParser->m_alloc_tracker.bytesAllocated += bytesToAllocate;

  // Report as needed
  if (rootParser->m_alloc_tracker.debugLevel >= 2) {
    if (rootParser->m_alloc_tracker.bytesAllocated >
        rootParser->m_alloc_tracker.peakBytesAllocated) {
      rootParser->m_alloc_tracker.peakBytesAllocated =
          rootParser->m_alloc_tracker.bytesAllocated;
    }
    expat_heap_stat(rootParser, '+', bytesToAllocate,
                    rootParser->m_alloc_tracker.bytesAllocated,
                    rootParser->m_alloc_tracker.peakBytesAllocated, sourceLine);
  }

  return (char *)mallocedPtr + sizeof(size_t) + EXPAT_MALLOC_PADDING;
}

#if defined(XML_TESTING)
void
#else
static void
#endif
expat_free(XML_Parser parser, void *ptr, int sourceLine) {
  assert(parser != NULL);

  if (ptr == NULL) {
    return;
  }

  const XML_Parser rootParser = getRootParserOf(parser, NULL);
  assert(rootParser->m_parentParser == NULL);

  // Extract size (to the eyes of malloc_fcn/realloc_fcn) and
  // the original pointer returned by malloc/realloc
  void *const mallocedPtr = (char *)ptr - EXPAT_MALLOC_PADDING - sizeof(size_t);
  const size_t bytesAllocated =
      sizeof(size_t) + EXPAT_MALLOC_PADDING + *(size_t *)mallocedPtr;

  // Update accounting
  assert(rootParser->m_alloc_tracker.bytesAllocated >= bytesAllocated);
  rootParser->m_alloc_tracker.bytesAllocated -= bytesAllocated;

  // Report as needed
  if (rootParser->m_alloc_tracker.debugLevel >= 2) {
    expat_heap_stat(rootParser, '-', bytesAllocated,
                    rootParser->m_alloc_tracker.bytesAllocated,
                    rootParser->m_alloc_tracker.peakBytesAllocated, sourceLine);
  }

  // NOTE: This may be freeing rootParser, so freeing has to come last
  parser->m_mem.free_fcn(mallocedPtr);
}

#if defined(XML_TESTING)
void *
#else
static void *
#endif
expat_realloc(XML_Parser parser, void *ptr, size_t size, int sourceLine) {
  assert(parser != NULL);

  if (ptr == NULL) {
    return expat_malloc(parser, size, sourceLine);
  }

  if (size == 0) {
    expat_free(parser, ptr, sourceLine);
    return NULL;
  }

  const XML_Parser rootParser = getRootParserOf(parser, NULL);
  assert(rootParser->m_parentParser == NULL);

  // Extract original size (to the eyes of the caller) and the original
  // pointer returned by malloc/realloc
  void *mallocedPtr = (char *)ptr - EXPAT_MALLOC_PADDING - sizeof(size_t);
  const size_t prevSize = *(size_t *)mallocedPtr;

  // Classify upcoming change
  const bool isIncrease = (size > prevSize);
  const size_t absDiff =
      (size > prevSize) ? (size - prevSize) : (prevSize - size);

  // Ask for permission from accounting
  if (isIncrease) {
    if (!expat_heap_increase_tolerable(rootParser, absDiff, sourceLine)) {
      return NULL; // i.e. signal violation as out-of-memory
    }
  }

  // NOTE: Integer overflow detection has already been done for us
  //       by expat_heap_increase_tolerable(..) above
  assert(SIZE_MAX - sizeof(size_t) - EXPAT_MALLOC_PADDING >= size);

  // Actually allocate
  mallocedPtr = parser->m_mem.realloc_fcn(
      mallocedPtr, sizeof(size_t) + EXPAT_MALLOC_PADDING + size);

  if (mallocedPtr == NULL) {
    return NULL;
  }

  // Update accounting
  if (isIncrease) {
    assert((XmlBigCount)-1 - rootParser->m_alloc_tracker.bytesAllocated >=
           absDiff);
    rootParser->m_alloc_tracker.bytesAllocated += absDiff;
  } else { // i.e. decrease
    assert(rootParser->m_alloc_tracker.bytesAllocated >= absDiff);
    rootParser->m_alloc_tracker.bytesAllocated -= absDiff;
  }

  // Report as needed
  if (rootParser->m_alloc_tracker.debugLevel >= 2) {
    if (rootParser->m_alloc_tracker.bytesAllocated >
        rootParser->m_alloc_tracker.peakBytesAllocated) {
      rootParser->m_alloc_tracker.peakBytesAllocated =
          rootParser->m_alloc_tracker.bytesAllocated;
    }
    expat_heap_stat(rootParser, isIncrease ? '+' : '-', absDiff,
                    rootParser->m_alloc_tracker.bytesAllocated,
                    rootParser->m_alloc_tracker.peakBytesAllocated, sourceLine);
  }

  // Update in-block recorded size
  *(size_t *)mallocedPtr = size;

  return (char *)mallocedPtr + sizeof(size_t) + EXPAT_MALLOC_PADDING;
}
#endif // XML_GE == 1

XML_Parser XMLCALL XML_ParserCreate(const XML_Char *encodingName) {
  return XML_ParserCreate_MM(encodingName, NULL, NULL);
}

XML_Parser XMLCALL XML_ParserCreateNS(const XML_Char *encodingName,
                                      XML_Char nsSep) {
  XML_Char tmp[2] = {nsSep, 0};
  return XML_ParserCreate_MM(encodingName, NULL, tmp);
}

// "xml=http://www.w3.org/XML/1998/namespace"
static const XML_Char implicitContext[] = {
    ASCII_x,     ASCII_m,     ASCII_l,      ASCII_EQUALS, ASCII_h,
    ASCII_t,     ASCII_t,     ASCII_p,      ASCII_COLON,  ASCII_SLASH,
    ASCII_SLASH, ASCII_w,     ASCII_w,      ASCII_w,      ASCII_PERIOD,
    ASCII_w,     ASCII_3,     ASCII_PERIOD, ASCII_o,      ASCII_r,
    ASCII_g,     ASCII_SLASH, ASCII_X,      ASCII_M,      ASCII_L,
    ASCII_SLASH, ASCII_1,     ASCII_9,      ASCII_9,      ASCII_8,
    ASCII_SLASH, ASCII_n,     ASCII_a,      ASCII_m,      ASCII_e,
    ASCII_s,     ASCII_p,     ASCII_a,      ASCII_c,      ASCII_e,
    '\0'};

/* To avoid warnings about unused functions: */
#if !defined(HAVE_ARC4RANDOM_BUF) && !defined(HAVE_ARC4RANDOM)

#if defined(HAVE_GETRANDOM) || defined(HAVE_SYSCALL_GETRANDOM)

/* Obtain entropy on Linux 3.17+ */
static int writeRandomBytes_getrandom_nonblock(void *target, size_t count) {
  int success = 0; /* full count bytes written? */
  size_t bytesWrittenTotal = 0;
  const unsigned int getrandomFlags = GRND_NONBLOCK;

  do {
    void *const currentTarget = (void *)((char *)target + bytesWrittenTotal);
    const size_t bytesToWrite = count - bytesWrittenTotal;

    assert(bytesToWrite <= INT_MAX);

    const int bytesWrittenMore =
#if defined(HAVE_GETRANDOM)
        (int)getrandom(currentTarget, bytesToWrite, getrandomFlags);
#else
        (int)syscall(SYS_getrandom, currentTarget, bytesToWrite,
                     getrandomFlags);
#endif

    if (bytesWrittenMore > 0) {
      bytesWrittenTotal += bytesWrittenMore;
      if (bytesWrittenTotal >= count)
        success = 1;
    }
  } while (!success && (errno == EINTR));

  return success;
}

#endif /* defined(HAVE_GETRANDOM) || defined(HAVE_SYSCALL_GETRANDOM) */

#if defined(XML_DEV_URANDOM)

/* Extract entropy from /dev/urandom */
static int writeRandomBytes_dev_urandom(void *target, size_t count) {
  int success = 0; /* full count bytes written? */
  size_t bytesWrittenTotal = 0;

  const int fd = open("/dev/urandom", O_RDONLY);
  if (fd < 0) {
    return 0;
  }

  do {
    void *const currentTarget = (void *)((char *)target + bytesWrittenTotal);
    const size_t bytesToWrite = count - bytesWrittenTotal;

    const ssize_t bytesWrittenMore = read(fd, currentTarget, bytesToWrite);

    if (bytesWrittenMore > 0) {
      bytesWrittenTotal += bytesWrittenMore;
      if (bytesWrittenTotal >= count)
        success = 1;
    }
  } while (!success && (errno == EINTR));

  close(fd);
  return success;
}

#endif /* defined(XML_DEV_URANDOM) */

#endif /* ! defined(HAVE_ARC4RANDOM_BUF) && ! defined(HAVE_ARC4RANDOM) */

#if defined(HAVE_ARC4RANDOM) && !defined(HAVE_ARC4RANDOM_BUF)

static void writeRandomBytes_arc4random(void *target, size_t count) {
  size_t bytesWrittenTotal = 0;

  while (bytesWrittenTotal < count) {
    const uint32_t random32 = arc4random();
    size_t i = 0;

    for (; (i < sizeof(random32)) && (bytesWrittenTotal < count);
         i++, bytesWrittenTotal++) {
      const uint8_t random8 = (uint8_t)(random32 >> (i * 8));
      ((uint8_t *)target)[bytesWrittenTotal] = random8;
    }
  }
}

#endif /* defined(HAVE_ARC4RANDOM) && ! defined(HAVE_ARC4RANDOM_BUF) */

#if !defined(HAVE_ARC4RANDOM_BUF) && !defined(HAVE_ARC4RANDOM)

static unsigned long gather_time_entropy(void) {

  struct timeval tv;
  int gettimeofday_res;

  gettimeofday_res = gettimeofday(&tv, NULL);

#if defined(NDEBUG)
  (void)gettimeofday_res;
#else
  assert(gettimeofday_res == 0);
#endif /* defined(NDEBUG) */

  /* Microseconds time is <20 bits entropy */
  return tv.tv_usec;
}

#endif /* ! defined(HAVE_ARC4RANDOM_BUF) && ! defined(HAVE_ARC4RANDOM) */

static unsigned long ENTROPY_DEBUG(const char *label, unsigned long entropy) {
  if (getDebugLevel("EXPAT_ENTROPY_DEBUG", 0) >= 1u) {
    fprintf(stderr, "expat: Entropy: %s --> 0x%0*lx (%lu bytes)\n", label,
            (int)sizeof(entropy) * 2, entropy, (unsigned long)sizeof(entropy));
  }
  return entropy;
}

static unsigned long generate_hash_secret_salt(XML_Parser parser) {
  unsigned long entropy;
  (void)parser;

  /* "Failproof" high quality providers: */
#if defined(HAVE_ARC4RANDOM_BUF)
  arc4random_buf(&entropy, sizeof(entropy));
  return ENTROPY_DEBUG("arc4random_buf", entropy);
#elif defined(HAVE_ARC4RANDOM)
  writeRandomBytes_arc4random((void *)&entropy, sizeof(entropy));
  return ENTROPY_DEBUG("arc4random", entropy);
#else
/* Try high quality providers first .. */
#if defined(HAVE_GETRANDOM) || defined(HAVE_SYSCALL_GETRANDOM)
  if (writeRandomBytes_getrandom_nonblock((void *)&entropy, sizeof(entropy))) {
    return ENTROPY_DEBUG("getrandom", entropy);
  }
#endif

#if defined(XML_DEV_URANDOM)
  if (writeRandomBytes_dev_urandom((void *)&entropy, sizeof(entropy))) {
    return ENTROPY_DEBUG("/dev/urandom", entropy);
  }
#endif /* defined(XML_DEV_URANDOM) */
  /* .. and self-made low quality for backup: */

  entropy = gather_time_entropy();
#if !defined(__wasi__)
  /* Process ID is 0 bits entropy if attacker has local access */
  entropy ^= getpid();
#endif

  /* Factors are 2^31-1 and 2^61-1 (Mersenne primes M31 and M61) */
  if (sizeof(unsigned long) == 4) {
    return ENTROPY_DEBUG("fallback(4)", entropy * 2147483647);
  } else {
    return ENTROPY_DEBUG("fallback(8)",
                         entropy * (unsigned long)2305843009213693951ULL);
  }
#endif
}

static unsigned long get_hash_secret_salt(XML_Parser parser) {
  const XML_Parser rootParser = getRootParserOf(parser, NULL);
  assert(!rootParser->m_parentParser);

  return rootParser->m_hash_secret_salt;
}

static enum XML_Error callProcessor(XML_Parser parser, const char *start,
                                    const char *end, const char **endPtr) {
  const size_t have_now = EXPAT_SAFE_PTR_DIFF(end, start);

  if (parser->m_reparseDeferralEnabled &&
      !parser->m_parsingStatus.finalBuffer) {
    // Heuristic: don't try to parse a partial token again until the amount of
    // available data has increased significantly.
    const size_t had_before = parser->m_partialTokenBytesBefore;
    // ...but *do* try anyway if we're close to causing a reallocation.
    size_t available_buffer =
        EXPAT_SAFE_PTR_DIFF(parser->m_bufferPtr, parser->m_buffer);
#if XML_CONTEXT_BYTES > 0
    available_buffer -= EXPAT_MIN(available_buffer, XML_CONTEXT_BYTES);
#endif
    available_buffer +=
        EXPAT_SAFE_PTR_DIFF(parser->m_bufferLim, parser->m_bufferEnd);
    // m_lastBufferRequestSize is never assigned a value < 0, so the cast is ok
    const bool enough =
        (have_now >= 2 * had_before) ||
        ((size_t)parser->m_lastBufferRequestSize > available_buffer);

    if (!enough) {
      *endPtr = start; // callers may expect this to be set
      return XML_ERROR_NONE;
    }
  }
#if defined(XML_TESTING)
  g_bytesScanned += (unsigned)have_now;
#endif
  // Run in a loop to eliminate dangerous recursion depths
  enum XML_Error ret;
  *endPtr = start;
  while (1) {
    // Use endPtr as the new start in each iteration, since it will
    // be set to the next start point by m_processor.
    ret = parser->m_processor(parser, *endPtr, end, endPtr);

    // Make parsing status (and in particular XML_SUSPENDED) take
    // precedence over re-enter flag when they disagree
    if (parser->m_parsingStatus.parsing != XML_PARSING) {
      parser->m_reenter = XML_FALSE;
    }

    if (!parser->m_reenter) {
      break;
    }

    parser->m_reenter = XML_FALSE;
    if (ret != XML_ERROR_NONE)
      return ret;
  }

  if (ret == XML_ERROR_NONE) {
    // if we consumed nothing, remember what we had on this parse attempt.
    if (*endPtr == start) {
      parser->m_partialTokenBytesBefore = have_now;
    } else {
      parser->m_partialTokenBytesBefore = 0;
    }
  }
  return ret;
}

static XML_Bool /* only valid for root parser */
startParsing(XML_Parser parser) {
  /* hash functions must be initialized before setContext() is called */
  if (parser->m_hash_secret_salt == 0)
    parser->m_hash_secret_salt = generate_hash_secret_salt(parser);
  if (parser->m_ns) {
    /* implicit context only set for root parser, since child
       parsers (i.e. external entity parsers) will inherit it
    */
    return setContext(parser, implicitContext);
  }
  return XML_TRUE;
}

XML_Parser XMLCALL XML_ParserCreate_MM(
    const XML_Char *encodingName, const XML_Memory_Handling_Suite *memsuite,
    const XML_Char *nameSep) {
  return parserCreate(encodingName, memsuite, nameSep, NULL, NULL);
}

static XML_Parser parserCreate(const XML_Char *encodingName,
                               const XML_Memory_Handling_Suite *memsuite,
                               const XML_Char *nameSep, DTD *dtd,
                               XML_Parser parentParser) {
  XML_Parser parser = NULL;

#if XML_GE == 1
  const size_t increase =
      sizeof(size_t) + EXPAT_MALLOC_PADDING + sizeof(struct XML_ParserStruct);

  if (parentParser != NULL) {
    const XML_Parser rootParser = getRootParserOf(parentParser, NULL);
    if (!expat_heap_increase_tolerable(rootParser, increase, __LINE__)) {
      return NULL;
    }
  }
#else
  UNUSED_P(parentParser);
#endif

  if (memsuite) {
    XML_Memory_Handling_Suite *mtemp;
#if XML_GE == 1
    void *const sizeAndParser =
        memsuite->malloc_fcn(sizeof(size_t) + EXPAT_MALLOC_PADDING +
                             sizeof(struct XML_ParserStruct));
    if (sizeAndParser != NULL) {
      *(size_t *)sizeAndParser = sizeof(struct XML_ParserStruct);
      parser = (XML_Parser)((char *)sizeAndParser + sizeof(size_t) +
                            EXPAT_MALLOC_PADDING);
#else
    parser = memsuite->malloc_fcn(sizeof(struct XML_ParserStruct));
    if (parser != NULL) {
#endif
      mtemp = (XML_Memory_Handling_Suite *)&(parser->m_mem);
      mtemp->malloc_fcn = memsuite->malloc_fcn;
      mtemp->realloc_fcn = memsuite->realloc_fcn;
      mtemp->free_fcn = memsuite->free_fcn;
    }
  } else {
    XML_Memory_Handling_Suite *mtemp;
#if XML_GE == 1
    void *const sizeAndParser = malloc(sizeof(size_t) + EXPAT_MALLOC_PADDING +
                                       sizeof(struct XML_ParserStruct));
    if (sizeAndParser != NULL) {
      *(size_t *)sizeAndParser = sizeof(struct XML_ParserStruct);
      parser = (XML_Parser)((char *)sizeAndParser + sizeof(size_t) +
                            EXPAT_MALLOC_PADDING);
#else
    parser = malloc(sizeof(struct XML_ParserStruct));
    if (parser != NULL) {
#endif
      mtemp = (XML_Memory_Handling_Suite *)&(parser->m_mem);
      mtemp->malloc_fcn = malloc;
      mtemp->realloc_fcn = realloc;
      mtemp->free_fcn = free;
    }
  } // cppcheck-suppress[memleak symbolName=sizeAndParser] // Cppcheck >=2.18.0

  if (!parser)
    return parser;

#if XML_GE == 1
  // Initialize .m_alloc_tracker
  memset(&parser->m_alloc_tracker, 0, sizeof(MALLOC_TRACKER));
  if (parentParser == NULL) {
    parser->m_alloc_tracker.debugLevel =
        getDebugLevel("EXPAT_MALLOC_DEBUG", 0u);
    parser->m_alloc_tracker.maximumAmplificationFactor =
        EXPAT_ALLOC_TRACKER_MAXIMUM_AMPLIFICATION_DEFAULT;
    parser->m_alloc_tracker.activationThresholdBytes =
        EXPAT_ALLOC_TRACKER_ACTIVATION_THRESHOLD_DEFAULT;

    // NOTE: This initialization needs to come this early because these fields
    //       are read by allocation tracking code
    parser->m_parentParser = NULL;
    parser->m_accounting.countBytesDirect = 0;
  } else {
    parser->m_parentParser = parentParser;
  }

  // Record XML_ParserStruct allocation we did a few lines up before
  const XML_Parser rootParser = getRootParserOf(parser, NULL);
  assert(rootParser->m_parentParser == NULL);
  assert(SIZE_MAX - rootParser->m_alloc_tracker.bytesAllocated >= increase);
  rootParser->m_alloc_tracker.bytesAllocated += increase;

  // Report on allocation
  if (rootParser->m_alloc_tracker.debugLevel >= 2) {
    if (rootParser->m_alloc_tracker.bytesAllocated >
        rootParser->m_alloc_tracker.peakBytesAllocated) {
      rootParser->m_alloc_tracker.peakBytesAllocated =
          rootParser->m_alloc_tracker.bytesAllocated;
    }

    expat_heap_stat(rootParser, '+', increase,
                    rootParser->m_alloc_tracker.bytesAllocated,
                    rootParser->m_alloc_tracker.peakBytesAllocated, __LINE__);
  }
#else
  parser->m_parentParser = NULL;
#endif // XML_GE == 1

  parser->m_buffer = NULL;
  parser->m_bufferLim = NULL;

  parser->m_attsSize = INIT_ATTS_SIZE;
  parser->m_atts = MALLOC(parser, parser->m_attsSize * sizeof(ATTRIBUTE));
  if (parser->m_atts == NULL) {
    FREE(parser, parser);
    return NULL;
  }
#ifdef XML_ATTR_INFO
  parser->m_attInfo = MALLOC(parser, parser->m_attsSize * sizeof(XML_AttrInfo));
  if (parser->m_attInfo == NULL) {
    FREE(parser, parser->m_atts);
    FREE(parser, parser);
    return NULL;
  }
#endif
  parser->m_dataBuf = MALLOC(parser, INIT_DATA_BUF_SIZE * sizeof(XML_Char));
  if (parser->m_dataBuf == NULL) {
    FREE(parser, parser->m_atts);
#ifdef XML_ATTR_INFO
    FREE(parser, parser->m_attInfo);
#endif
    FREE(parser, parser);
    return NULL;
  }
  parser->m_dataBufEnd = parser->m_dataBuf + INIT_DATA_BUF_SIZE;

  if (dtd)
    parser->m_dtd = dtd;
  else {
    parser->m_dtd = dtdCreate(parser);
    if (parser->m_dtd == NULL) {
      FREE(parser, parser->m_dataBuf);
      FREE(parser, parser->m_atts);
#ifdef XML_ATTR_INFO
      FREE(parser, parser->m_attInfo);
#endif
      FREE(parser, parser);
      return NULL;
    }
  }

  parser->m_freeBindingList = NULL;
  parser->m_freeTagList = NULL;
  parser->m_freeInternalEntities = NULL;
  parser->m_freeAttributeEntities = NULL;
  parser->m_freeValueEntities = NULL;

  parser->m_groupSize = 0;
  parser->m_groupConnector = NULL;

  parser->m_unknownEncodingHandler = NULL;
  parser->m_unknownEncodingHandlerData = NULL;

  parser->m_namespaceSeparator = ASCII_EXCL;
  parser->m_ns = XML_FALSE;
  parser->m_ns_triplets = XML_FALSE;

  parser->m_nsAtts = NULL;
  parser->m_nsAttsVersion = 0;
  parser->m_nsAttsPower = 0;

  parser->m_protocolEncodingName = NULL;

  poolInit(&parser->m_tempPool, parser);
  poolInit(&parser->m_temp2Pool, parser);
  parserInit(parser, encodingName);

  if (encodingName && !parser->m_protocolEncodingName) {
    if (dtd) {
      // We need to stop the upcoming call to XML_ParserFree from happily
      // destroying parser->m_dtd because the DTD is shared with the parent
      // parser and the only guard that keeps XML_ParserFree from destroying
      // parser->m_dtd is parser->m_isParamEntity but it will be set to
      // XML_TRUE only later in XML_ExternalEntityParserCreate (or not at all).
      parser->m_dtd = NULL;
    }
    XML_ParserFree(parser);
    return NULL;
  }

  if (nameSep) {
    parser->m_ns = XML_TRUE;
    parser->m_internalEncoding = XmlGetInternalEncodingNS();
    parser->m_namespaceSeparator = *nameSep;
  } else {
    parser->m_internalEncoding = XmlGetInternalEncoding();
  }

  return parser;
}

static void parserInit(XML_Parser parser, const XML_Char *encodingName) {
  parser->m_processor = prologInitProcessor;
  XmlPrologStateInit(&parser->m_prologState);
  if (encodingName != NULL) {
    parser->m_protocolEncodingName = copyString(encodingName, parser);
  }
  parser->m_curBase = NULL;
  XmlInitEncoding(&parser->m_initEncoding, &parser->m_encoding, 0);
  parser->m_userData = NULL;
  parser->m_handlerArg = NULL;
  parser->m_startElementHandler = NULL;
  parser->m_endElementHandler = NULL;
  parser->m_characterDataHandler = NULL;
  parser->m_processingInstructionHandler = NULL;
  parser->m_commentHandler = NULL;
  parser->m_startCdataSectionHandler = NULL;
  parser->m_endCdataSectionHandler = NULL;
  parser->m_defaultHandler = NULL;
  parser->m_startDoctypeDeclHandler = NULL;
  parser->m_endDoctypeDeclHandler = NULL;
  parser->m_unparsedEntityDeclHandler = NULL;
  parser->m_notationDeclHandler = NULL;
  parser->m_startNamespaceDeclHandler = NULL;
  parser->m_endNamespaceDeclHandler = NULL;
  parser->m_notStandaloneHandler = NULL;
  parser->m_externalEntityRefHandler = NULL;
  parser->m_externalEntityRefHandlerArg = parser;
  parser->m_skippedEntityHandler = NULL;
  parser->m_elementDeclHandler = NULL;
  parser->m_attlistDeclHandler = NULL;
  parser->m_entityDeclHandler = NULL;
  parser->m_xmlDeclHandler = NULL;
  parser->m_bufferPtr = parser->m_buffer;
  parser->m_bufferEnd = parser->m_buffer;
  parser->m_parseEndByteIndex = 0;
  parser->m_parseEndPtr = NULL;
  parser->m_partialTokenBytesBefore = 0;
  parser->m_reparseDeferralEnabled = g_reparseDeferralEnabledDefault;
  parser->m_lastBufferRequestSize = 0;
  parser->m_declElementType = NULL;
  parser->m_declAttributeId = NULL;
  parser->m_declEntity = NULL;
  parser->m_doctypeName = NULL;
  parser->m_doctypeSysid = NULL;
  parser->m_doctypePubid = NULL;
  parser->m_declAttributeType = NULL;
  parser->m_declNotationName = NULL;
  parser->m_declNotationPublicId = NULL;
  parser->m_declAttributeIsCdata = XML_FALSE;
  parser->m_declAttributeIsId = XML_FALSE;
  memset(&parser->m_position, 0, sizeof(POSITION));
  parser->m_errorCode = XML_ERROR_NONE;
  parser->m_eventPtr = NULL;
  parser->m_eventEndPtr = NULL;
  parser->m_positionPtr = NULL;
  parser->m_openInternalEntities = NULL;
  parser->m_openAttributeEntities = NULL;
  parser->m_openValueEntities = NULL;
  parser->m_defaultExpandInternalEntities = XML_TRUE;
  parser->m_tagLevel = 0;
  parser->m_tagStack = NULL;
  parser->m_inheritedBindings = NULL;
  parser->m_nSpecifiedAtts = 0;
  parser->m_unknownEncodingMem = NULL;
  parser->m_unknownEncodingRelease = NULL;
  parser->m_unknownEncodingData = NULL;
  parser->m_parsingStatus.parsing = XML_INITIALIZED;
  // Reentry can only be triggered inside m_processor calls
  parser->m_reenter = XML_FALSE;
#ifdef XML_DTD
  parser->m_isParamEntity = XML_FALSE;
  parser->m_useForeignDTD = XML_FALSE;
  parser->m_paramEntityParsing = XML_PARAM_ENTITY_PARSING_NEVER;
#endif
  parser->m_hash_secret_salt = 0;

#if XML_GE == 1
  memset(&parser->m_accounting, 0, sizeof(ACCOUNTING));
  parser->m_accounting.debugLevel = getDebugLevel("EXPAT_ACCOUNTING_DEBUG", 0u);
  parser->m_accounting.maximumAmplificationFactor =
      EXPAT_BILLION_LAUGHS_ATTACK_PROTECTION_MAXIMUM_AMPLIFICATION_DEFAULT;
  parser->m_accounting.activationThresholdBytes =
      EXPAT_BILLION_LAUGHS_ATTACK_PROTECTION_ACTIVATION_THRESHOLD_DEFAULT;

  memset(&parser->m_entity_stats, 0, sizeof(ENTITY_STATS));
  parser->m_entity_stats.debugLevel = getDebugLevel("EXPAT_ENTITY_DEBUG", 0u);
#endif
}

/* moves list of bindings to m_freeBindingList */
static void FASTCALL moveToFreeBindingList(XML_Parser parser,
                                           BINDING *bindings) {
  while (bindings) {
    BINDING *b = bindings;
    bindings = bindings->nextTagBinding;
    b->nextTagBinding = parser->m_freeBindingList;
    parser->m_freeBindingList = b;
  }
}

XML_Bool XMLCALL XML_ParserReset(XML_Parser parser,
                                 const XML_Char *encodingName) {
  TAG *tStk;
  OPEN_INTERNAL_ENTITY *openEntityList;

  if (parser == NULL)
    return XML_FALSE;

  if (parser->m_parentParser)
    return XML_FALSE;
  /* move m_tagStack to m_freeTagList */
  tStk = parser->m_tagStack;
  while (tStk) {
    TAG *tag = tStk;
    tStk = tStk->parent;
    tag->parent = parser->m_freeTagList;
    moveToFreeBindingList(parser, tag->bindings);
    tag->bindings = NULL;
    parser->m_freeTagList = tag;
  }
  /* move m_openInternalEntities to m_freeInternalEntities */
  openEntityList = parser->m_openInternalEntities;
  while (openEntityList) {
    OPEN_INTERNAL_ENTITY *openEntity = openEntityList;
    openEntityList = openEntity->next;
    openEntity->next = parser->m_freeInternalEntities;
    parser->m_freeInternalEntities = openEntity;
  }
  /* move m_openAttributeEntities to m_freeAttributeEntities (i.e. same task but
   * for attributes) */
  openEntityList = parser->m_openAttributeEntities;
  while (openEntityList) {
    OPEN_INTERNAL_ENTITY *openEntity = openEntityList;
    openEntityList = openEntity->next;
    openEntity->next = parser->m_freeAttributeEntities;
    parser->m_freeAttributeEntities = openEntity;
  }
  /* move m_openValueEntities to m_freeValueEntities (i.e. same task but
   * for value entities) */
  openEntityList = parser->m_openValueEntities;
  while (openEntityList) {
    OPEN_INTERNAL_ENTITY *openEntity = openEntityList;
    openEntityList = openEntity->next;
    openEntity->next = parser->m_freeValueEntities;
    parser->m_freeValueEntities = openEntity;
  }
  moveToFreeBindingList(parser, parser->m_inheritedBindings);
  FREE(parser, parser->m_unknownEncodingMem);
  if (parser->m_unknownEncodingRelease)
    parser->m_unknownEncodingRelease(parser->m_unknownEncodingData);
  poolClear(&parser->m_tempPool);
  poolClear(&parser->m_temp2Pool);
  FREE(parser, (void *)parser->m_protocolEncodingName);
  parser->m_protocolEncodingName = NULL;
  parserInit(parser, encodingName);
  dtdReset(parser->m_dtd, parser);
  return XML_TRUE;
}

static XML_Bool parserBusy(XML_Parser parser) {
  switch (parser->m_parsingStatus.parsing) {
  case XML_PARSING:
  case XML_SUSPENDED:
    return XML_TRUE;
  case XML_INITIALIZED:
  case XML_FINISHED:
  default:
    return XML_FALSE;
  }
}

enum XML_Status XMLCALL XML_SetEncoding(XML_Parser parser,
                                        const XML_Char *encodingName) {
  if (parser == NULL)
    return XML_STATUS_ERROR;
  /* Block after XML_Parse()/XML_ParseBuffer() has been called.
     XXX There's no way for the caller to determine which of the
     XXX possible error cases caused the XML_STATUS_ERROR return.
  */
  if (parserBusy(parser))
    return XML_STATUS_ERROR;

  /* Get rid of any previous encoding name */
  FREE(parser, (void *)parser->m_protocolEncodingName);

  if (encodingName == NULL)
    /* No new encoding name */
    parser->m_protocolEncodingName = NULL;
  else {
    /* Copy the new encoding name into allocated memory */
    parser->m_protocolEncodingName = copyString(encodingName, parser);
    if (!parser->m_protocolEncodingName)
      return XML_STATUS_ERROR;
  }
  return XML_STATUS_OK;
}

XML_Parser XMLCALL
XML_ExternalEntityParserCreate(XML_Parser oldParser, const XML_Char *context,
                               const XML_Char *encodingName) {
  XML_Parser parser = oldParser;
  DTD *newDtd = NULL;
  DTD *oldDtd;
  XML_StartElementHandler oldStartElementHandler;
  XML_EndElementHandler oldEndElementHandler;
  XML_CharacterDataHandler oldCharacterDataHandler;
  XML_ProcessingInstructionHandler oldProcessingInstructionHandler;
  XML_CommentHandler oldCommentHandler;
  XML_StartCdataSectionHandler oldStartCdataSectionHandler;
  XML_EndCdataSectionHandler oldEndCdataSectionHandler;
  XML_DefaultHandler oldDefaultHandler;
  XML_UnparsedEntityDeclHandler oldUnparsedEntityDeclHandler;
  XML_NotationDeclHandler oldNotationDeclHandler;
  XML_StartNamespaceDeclHandler oldStartNamespaceDeclHandler;
  XML_EndNamespaceDeclHandler oldEndNamespaceDeclHandler;
  XML_NotStandaloneHandler oldNotStandaloneHandler;
  XML_ExternalEntityRefHandler oldExternalEntityRefHandler;
  XML_SkippedEntityHandler oldSkippedEntityHandler;
  XML_UnknownEncodingHandler oldUnknownEncodingHandler;
  void *oldUnknownEncodingHandlerData;
  XML_ElementDeclHandler oldElementDeclHandler;
  XML_AttlistDeclHandler oldAttlistDeclHandler;
  XML_EntityDeclHandler oldEntityDeclHandler;
  XML_XmlDeclHandler oldXmlDeclHandler;
  ELEMENT_TYPE *oldDeclElementType;

  void *oldUserData;
  void *oldHandlerArg;
  XML_Bool oldDefaultExpandInternalEntities;
  XML_Parser oldExternalEntityRefHandlerArg;
#ifdef XML_DTD
  enum XML_ParamEntityParsing oldParamEntityParsing;
  int oldInEntityValue;
#endif
  XML_Bool oldns_triplets;
  /* Note that the new parser shares the same hash secret as the old
     parser, so that dtdCopy and copyEntityTable can lookup values
     from hash tables associated with either parser without us having
     to worry which hash secrets each table has.
  */
  unsigned long oldhash_secret_salt;
  XML_Bool oldReparseDeferralEnabled;

  /* Validate the oldParser parameter before we pull everything out of it */
  if (oldParser == NULL)
    return NULL;

  /* Stash the original parser contents on the stack */
  oldDtd = parser->m_dtd;
  oldStartElementHandler = parser->m_startElementHandler;
  oldEndElementHandler = parser->m_endElementHandler;
  oldCharacterDataHandler = parser->m_characterDataHandler;
  oldProcessingInstructionHandler = parser->m_processingInstructionHandler;
  oldCommentHandler = parser->m_commentHandler;
  oldStartCdataSectionHandler = parser->m_startCdataSectionHandler;
  oldEndCdataSectionHandler = parser->m_endCdataSectionHandler;
  oldDefaultHandler = parser->m_defaultHandler;
  oldUnparsedEntityDeclHandler = parser->m_unparsedEntityDeclHandler;
  oldNotationDeclHandler = parser->m_notationDeclHandler;
  oldStartNamespaceDeclHandler = parser->m_startNamespaceDeclHandler;
  oldEndNamespaceDeclHandler = parser->m_endNamespaceDeclHandler;
  oldNotStandaloneHandler = parser->m_notStandaloneHandler;
  oldExternalEntityRefHandler = parser->m_externalEntityRefHandler;
  oldSkippedEntityHandler = parser->m_skippedEntityHandler;
  oldUnknownEncodingHandler = parser->m_unknownEncodingHandler;
  oldUnknownEncodingHandlerData = parser->m_unknownEncodingHandlerData;
  oldElementDeclHandler = parser->m_elementDeclHandler;
  oldAttlistDeclHandler = parser->m_attlistDeclHandler;
  oldEntityDeclHandler = parser->m_entityDeclHandler;
  oldXmlDeclHandler = parser->m_xmlDeclHandler;
  oldDeclElementType = parser->m_declElementType;

  oldUserData = parser->m_userData;
  oldHandlerArg = parser->m_handlerArg;
  oldDefaultExpandInternalEntities = parser->m_defaultExpandInternalEntities;
  oldExternalEntityRefHandlerArg = parser->m_externalEntityRefHandlerArg;
#ifdef XML_DTD
  oldParamEntityParsing = parser->m_paramEntityParsing;
  oldInEntityValue = parser->m_prologState.inEntityValue;
#endif
  oldns_triplets = parser->m_ns_triplets;
  /* Note that the new parser shares the same hash secret as the old
     parser, so that dtdCopy and copyEntityTable can lookup values
     from hash tables associated with either parser without us having
     to worry which hash secrets each table has.
  */
  oldhash_secret_salt = parser->m_hash_secret_salt;
  oldReparseDeferralEnabled = parser->m_reparseDeferralEnabled;

#ifdef XML_DTD
  if (!context)
    newDtd = oldDtd;
#endif /* XML_DTD */

  /* Note that the magical uses of the pre-processor to make field
     access look more like C++ require that `parser' be overwritten
     here.  This makes this function more painful to follow than it
     would be otherwise.
  */
  if (parser->m_ns) {
    XML_Char tmp[2] = {parser->m_namespaceSeparator, 0};
    parser = parserCreate(encodingName, &parser->m_mem, tmp, newDtd, oldParser);
  } else {
    parser =
        parserCreate(encodingName, &parser->m_mem, NULL, newDtd, oldParser);
  }

  if (!parser)
    return NULL;

  parser->m_startElementHandler = oldStartElementHandler;
  parser->m_endElementHandler = oldEndElementHandler;
  parser->m_characterDataHandler = oldCharacterDataHandler;
  parser->m_processingInstructionHandler = oldProcessingInstructionHandler;
  parser->m_commentHandler = oldCommentHandler;
  parser->m_startCdataSectionHandler = oldStartCdataSectionHandler;
  parser->m_endCdataSectionHandler = oldEndCdataSectionHandler;
  parser->m_defaultHandler = oldDefaultHandler;
  parser->m_unparsedEntityDeclHandler = oldUnparsedEntityDeclHandler;
  parser->m_notationDeclHandler = oldNotationDeclHandler;
  parser->m_startNamespaceDeclHandler = oldStartNamespaceDeclHandler;
  parser->m_endNamespaceDeclHandler = oldEndNamespaceDeclHandler;
  parser->m_notStandaloneHandler = oldNotStandaloneHandler;
  parser->m_externalEntityRefHandler = oldExternalEntityRefHandler;
  parser->m_skippedEntityHandler = oldSkippedEntityHandler;
  parser->m_unknownEncodingHandler = oldUnknownEncodingHandler;
  parser->m_unknownEncodingHandlerData = oldUnknownEncodingHandlerData;
  parser->m_elementDeclHandler = oldElementDeclHandler;
  parser->m_attlistDeclHandler = oldAttlistDeclHandler;
  parser->m_entityDeclHandler = oldEntityDeclHandler;
  parser->m_xmlDeclHandler = oldXmlDeclHandler;
  parser->m_declElementType = oldDeclElementType;
  parser->m_userData = oldUserData;
  if (oldUserData == oldHandlerArg)
    parser->m_handlerArg = parser->m_userData;
  else
    parser->m_handlerArg = parser;
  if (oldExternalEntityRefHandlerArg != oldParser)
    parser->m_externalEntityRefHandlerArg = oldExternalEntityRefHandlerArg;
  parser->m_defaultExpandInternalEntities = oldDefaultExpandInternalEntities;
  parser->m_ns_triplets = oldns_triplets;
  parser->m_hash_secret_salt = oldhash_secret_salt;
  parser->m_reparseDeferralEnabled = oldReparseDeferralEnabled;
  parser->m_parentParser = oldParser;
#ifdef XML_DTD
  parser->m_paramEntityParsing = oldParamEntityParsing;
  parser->m_prologState.inEntityValue = oldInEntityValue;
  if (context) {
#endif /* XML_DTD */
    if (!dtdCopy(oldParser, parser->m_dtd, oldDtd, parser) ||
        !setContext(parser, context)) {
      XML_ParserFree(parser);
      return NULL;
    }
    parser->m_processor = externalEntityInitProcessor;
#ifdef XML_DTD
  } else {
    /* The DTD instance referenced by parser->m_dtd is shared between the
       document's root parser and external PE parsers, therefore one does not
       need to call setContext. In addition, one also *must* not call
       setContext, because this would overwrite existing prefix->binding
       pointers in parser->m_dtd with ones that get destroyed with the external
       PE parser. This would leave those prefixes with dangling pointers.
    */
    parser->m_isParamEntity = XML_TRUE;
    XmlPrologStateInitExternalEntity(&parser->m_prologState);
    parser->m_processor = externalParEntInitProcessor;
  }
#endif /* XML_DTD */
  return parser;
}

static void FASTCALL destroyBindings(BINDING *bindings, XML_Parser parser) {
  for (;;) {
    BINDING *b = bindings;
    if (!b)
      break;
    bindings = b->nextTagBinding;
    FREE(parser, b->uri);
    FREE(parser, b);
  }
}

void XMLCALL XML_ParserFree(XML_Parser parser) {
  TAG *tagList;
  OPEN_INTERNAL_ENTITY *entityList;
  if (parser == NULL)
    return;
  /* free m_tagStack and m_freeTagList */
  tagList = parser->m_tagStack;
  for (;;) {
    TAG *p;
    if (tagList == NULL) {
      if (parser->m_freeTagList == NULL)
        break;
      tagList = parser->m_freeTagList;
      parser->m_freeTagList = NULL;
    }
    p = tagList;
    tagList = tagList->parent;
    FREE(parser, p->buf.raw);
    destroyBindings(p->bindings, parser);
    FREE(parser, p);
  }
  /* free m_openInternalEntities and m_freeInternalEntities */
  entityList = parser->m_openInternalEntities;
  for (;;) {
    OPEN_INTERNAL_ENTITY *openEntity;
    if (entityList == NULL) {
      if (parser->m_freeInternalEntities == NULL)
        break;
      entityList = parser->m_freeInternalEntities;
      parser->m_freeInternalEntities = NULL;
    }
    openEntity = entityList;
    entityList = entityList->next;
    FREE(parser, openEntity);
  }
  /* free m_openAttributeEntities and m_freeAttributeEntities */
  entityList = parser->m_openAttributeEntities;
  for (;;) {
    OPEN_INTERNAL_ENTITY *openEntity;
    if (entityList == NULL) {
      if (parser->m_freeAttributeEntities == NULL)
        break;
      entityList = parser->m_freeAttributeEntities;
      parser->m_freeAttributeEntities = NULL;
    }
    openEntity = entityList;
    entityList = entityList->next;
    FREE(parser, openEntity);
  }
  /* free m_openValueEntities and m_freeValueEntities */
  entityList = parser->m_openValueEntities;
  for (;;) {
    OPEN_INTERNAL_ENTITY *openEntity;
    if (entityList == NULL) {
      if (parser->m_freeValueEntities == NULL)
        break;
      entityList = parser->m_freeValueEntities;
      parser->m_freeValueEntities = NULL;
    }
    openEntity = entityList;
    entityList = entityList->next;
    FREE(parser, openEntity);
  }
  destroyBindings(parser->m_freeBindingList, parser);
  destroyBindings(parser->m_inheritedBindings, parser);
  poolDestroy(&parser->m_tempPool);
  poolDestroy(&parser->m_temp2Pool);
  FREE(parser, (void *)parser->m_protocolEncodingName);
#ifdef XML_DTD
  /* external parameter entity parsers share the DTD structure
     parser->m_dtd with the root parser, so we must not destroy it
  */
  if (!parser->m_isParamEntity && parser->m_dtd)
#else
  if (parser->m_dtd)
#endif /* XML_DTD */
    dtdDestroy(parser->m_dtd, (XML_Bool)!parser->m_parentParser, parser);
  FREE(parser, parser->m_atts);
#ifdef XML_ATTR_INFO
  FREE(parser, parser->m_attInfo);
#endif
  FREE(parser, parser->m_groupConnector);
  // NOTE: We are avoiding FREE(..) here because parser->m_buffer
  //       is not being allocated with MALLOC(..) but with plain
  //       .malloc_fcn(..).
  parser->m_mem.free_fcn(parser->m_buffer);
  FREE(parser, parser->m_dataBuf);
  FREE(parser, parser->m_nsAtts);
  FREE(parser, parser->m_unknownEncodingMem);
  if (parser->m_unknownEncodingRelease)
    parser->m_unknownEncodingRelease(parser->m_unknownEncodingData);
  FREE(parser, parser);
}

void XMLCALL XML_UseParserAsHandlerArg(XML_Parser parser) {
  if (parser != NULL)
    parser->m_handlerArg = parser;
}

enum XML_Error XMLCALL XML_UseForeignDTD(XML_Parser parser, XML_Bool useDTD) {
  if (parser == NULL)
    return XML_ERROR_INVALID_ARGUMENT;
#ifdef XML_DTD
  /* block after XML_Parse()/XML_ParseBuffer() has been called */
  if (parserBusy(parser))
    return XML_ERROR_CANT_CHANGE_FEATURE_ONCE_PARSING;
  parser->m_useForeignDTD = useDTD;
  return XML_ERROR_NONE;
#else
  UNUSED_P(useDTD);
  return XML_ERROR_FEATURE_REQUIRES_XML_DTD;
#endif
}

void XMLCALL XML_SetReturnNSTriplet(XML_Parser parser, int do_nst) {
  if (parser == NULL)
    return;
  /* block after XML_Parse()/XML_ParseBuffer() has been called */
  if (parserBusy(parser))
    return;
  parser->m_ns_triplets = do_nst ? XML_TRUE : XML_FALSE;
}

void XMLCALL XML_SetUserData(XML_Parser parser, void *p) {
  if (parser == NULL)
    return;
  if (parser->m_handlerArg == parser->m_userData)
    parser->m_handlerArg = parser->m_userData = p;
  else
    parser->m_userData = p;
}

enum XML_Status XMLCALL XML_SetBase(XML_Parser parser, const XML_Char *p) {
  if (parser == NULL)
    return XML_STATUS_ERROR;
  if (p) {
    p = poolCopyString(&parser->m_dtd->pool, p);
    if (!p)
      return XML_STATUS_ERROR;
    parser->m_curBase = p;
  } else
    parser->m_curBase = NULL;
  return XML_STATUS_OK;
}

const XML_Char *XMLCALL XML_GetBase(XML_Parser parser) {
  if (parser == NULL)
    return NULL;
  return parser->m_curBase;
}

int XMLCALL XML_GetSpecifiedAttributeCount(XML_Parser parser) {
  if (parser == NULL)
    return -1;
  return parser->m_nSpecifiedAtts;
}

int XMLCALL XML_GetIdAttributeIndex(XML_Parser parser) {
  if (parser == NULL)
    return -1;
  return parser->m_idAttIndex;
}

#ifdef XML_ATTR_INFO
const XML_AttrInfo *XMLCALL XML_GetAttributeInfo(XML_Parser parser) {
  if (parser == NULL)
    return NULL;
  return parser->m_attInfo;
}
#endif

void XMLCALL XML_SetElementHandler(XML_Parser parser,
                                   XML_StartElementHandler start,
                                   XML_EndElementHandler end) {
  if (parser == NULL)
    return;
  parser->m_startElementHandler = start;
  parser->m_endElementHandler = end;
}

void XMLCALL XML_SetStartElementHandler(XML_Parser parser,
                                        XML_StartElementHandler start) {
  if (parser != NULL)
    parser->m_startElementHandler = start;
}

void XMLCALL XML_SetEndElementHandler(XML_Parser parser,
                                      XML_EndElementHandler end) {
  if (parser != NULL)
    parser->m_endElementHandler = end;
}

void XMLCALL XML_SetCharacterDataHandler(XML_Parser parser,
                                         XML_CharacterDataHandler handler) {
  if (parser != NULL)
    parser->m_characterDataHandler = handler;
}

void XMLCALL XML_SetProcessingInstructionHandler(
    XML_Parser parser, XML_ProcessingInstructionHandler handler) {
  if (parser != NULL)
    parser->m_processingInstructionHandler = handler;
}

void XMLCALL XML_SetCommentHandler(XML_Parser parser,
                                   XML_CommentHandler handler) {
  if (parser != NULL)
    parser->m_commentHandler = handler;
}

void XMLCALL XML_SetCdataSectionHandler(XML_Parser parser,
                                        XML_StartCdataSectionHandler start,
                                        XML_EndCdataSectionHandler end) {
  if (parser == NULL)
    return;
  parser->m_startCdataSectionHandler = start;
  parser->m_endCdataSectionHandler = end;
}

void XMLCALL XML_SetStartCdataSectionHandler(
    XML_Parser parser, XML_StartCdataSectionHandler start) {
  if (parser != NULL)
    parser->m_startCdataSectionHandler = start;
}

void XMLCALL XML_SetEndCdataSectionHandler(XML_Parser parser,
                                           XML_EndCdataSectionHandler end) {
  if (parser != NULL)
    parser->m_endCdataSectionHandler = end;
}

void XMLCALL XML_SetDefaultHandler(XML_Parser parser,
                                   XML_DefaultHandler handler) {
  if (parser == NULL)
    return;
  parser->m_defaultHandler = handler;
  parser->m_defaultExpandInternalEntities = XML_FALSE;
}

void XMLCALL XML_SetDefaultHandlerExpand(XML_Parser parser,
                                         XML_DefaultHandler handler) {
  if (parser == NULL)
    return;
  parser->m_defaultHandler = handler;
  parser->m_defaultExpandInternalEntities = XML_TRUE;
}

void XMLCALL XML_SetDoctypeDeclHandler(XML_Parser parser,
                                       XML_StartDoctypeDeclHandler start,
                                       XML_EndDoctypeDeclHandler end) {
  if (parser == NULL)
    return;
  parser->m_startDoctypeDeclHandler = start;
  parser->m_endDoctypeDeclHandler = end;
}

void XMLCALL XML_SetStartDoctypeDeclHandler(XML_Parser parser,
                                            XML_StartDoctypeDeclHandler start) {
  if (parser != NULL)
    parser->m_startDoctypeDeclHandler = start;
}

void XMLCALL XML_SetEndDoctypeDeclHandler(XML_Parser parser,
                                          XML_EndDoctypeDeclHandler end) {
  if (parser != NULL)
    parser->m_endDoctypeDeclHandler = end;
}

void XMLCALL XML_SetUnparsedEntityDeclHandler(
    XML_Parser parser, XML_UnparsedEntityDeclHandler handler) {
  if (parser != NULL)
    parser->m_unparsedEntityDeclHandler = handler;
}

void XMLCALL XML_SetNotationDeclHandler(XML_Parser parser,
                                        XML_NotationDeclHandler handler) {
  if (parser != NULL)
    parser->m_notationDeclHandler = handler;
}

void XMLCALL XML_SetNamespaceDeclHandler(XML_Parser parser,
                                         XML_StartNamespaceDeclHandler start,
                                         XML_EndNamespaceDeclHandler end) {
  if (parser == NULL)
    return;
  parser->m_startNamespaceDeclHandler = start;
  parser->m_endNamespaceDeclHandler = end;
}

void XMLCALL XML_SetStartNamespaceDeclHandler(
    XML_Parser parser, XML_StartNamespaceDeclHandler start) {
  if (parser != NULL)
    parser->m_startNamespaceDeclHandler = start;
}

void XMLCALL XML_SetEndNamespaceDeclHandler(XML_Parser parser,
                                            XML_EndNamespaceDeclHandler end) {
  if (parser != NULL)
    parser->m_endNamespaceDeclHandler = end;
}

void XMLCALL XML_SetNotStandaloneHandler(XML_Parser parser,
                                         XML_NotStandaloneHandler handler) {
  if (parser != NULL)
    parser->m_notStandaloneHandler = handler;
}

void XMLCALL XML_SetExternalEntityRefHandler(
    XML_Parser parser, XML_ExternalEntityRefHandler handler) {
  if (parser != NULL)
    parser->m_externalEntityRefHandler = handler;
}

void XMLCALL XML_SetExternalEntityRefHandlerArg(XML_Parser parser, void *arg) {
  if (parser == NULL)
    return;
  if (arg)
    parser->m_externalEntityRefHandlerArg = (XML_Parser)arg;
  else
    parser->m_externalEntityRefHandlerArg = parser;
}

void XMLCALL XML_SetSkippedEntityHandler(XML_Parser parser,
                                         XML_SkippedEntityHandler handler) {
  if (parser != NULL)
    parser->m_skippedEntityHandler = handler;
}

void XMLCALL XML_SetUnknownEncodingHandler(XML_Parser parser,
                                           XML_UnknownEncodingHandler handler,
                                           void *data) {
  if (parser == NULL)
    return;
  parser->m_unknownEncodingHandler = handler;
  parser->m_unknownEncodingHandlerData = data;
}

void XMLCALL XML_SetElementDeclHandler(XML_Parser parser,
                                       XML_ElementDeclHandler eldecl) {
  if (parser != NULL)
    parser->m_elementDeclHandler = eldecl;
}

void XMLCALL XML_SetAttlistDeclHandler(XML_Parser parser,
                                       XML_AttlistDeclHandler attdecl) {
  if (parser != NULL)
    parser->m_attlistDeclHandler = attdecl;
}

void XMLCALL XML_SetEntityDeclHandler(XML_Parser parser,
                                      XML_EntityDeclHandler handler) {
  if (parser != NULL)
    parser->m_entityDeclHandler = handler;
}

void XMLCALL XML_SetXmlDeclHandler(XML_Parser parser,
                                   XML_XmlDeclHandler handler) {
  if (parser != NULL)
    parser->m_xmlDeclHandler = handler;
}

int XMLCALL XML_SetParamEntityParsing(XML_Parser parser,
                                      enum XML_ParamEntityParsing peParsing) {
  if (parser == NULL)
    return 0;
  /* block after XML_Parse()/XML_ParseBuffer() has been called */
  if (parserBusy(parser))
    return 0;
#ifdef XML_DTD
  parser->m_paramEntityParsing = peParsing;
  return 1;
#else
  return peParsing == XML_PARAM_ENTITY_PARSING_NEVER;
#endif
}

int XMLCALL XML_SetHashSalt(XML_Parser parser, unsigned long hash_salt) {
  if (parser == NULL)
    return 0;

  const XML_Parser rootParser = getRootParserOf(parser, NULL);
  assert(!rootParser->m_parentParser);

  /* block after XML_Parse()/XML_ParseBuffer() has been called */
  if (parserBusy(rootParser))
    return 0;
  rootParser->m_hash_secret_salt = hash_salt;
  return 1;
}

enum XML_Status XMLCALL XML_Parse(XML_Parser parser, const char *s, int len,
                                  int isFinal) {
  if ((parser == NULL) || (len < 0) || ((s == NULL) && (len != 0))) {
    if (parser != NULL)
      parser->m_errorCode = XML_ERROR_INVALID_ARGUMENT;
    return XML_STATUS_ERROR;
  }
  switch (parser->m_parsingStatus.parsing) {
  case XML_SUSPENDED:
    parser->m_errorCode = XML_ERROR_SUSPENDED;
    return XML_STATUS_ERROR;
  case XML_FINISHED:
    parser->m_errorCode = XML_ERROR_FINISHED;
    return XML_STATUS_ERROR;
  case XML_INITIALIZED:
    if (parser->m_parentParser == NULL && !startParsing(parser)) {
      parser->m_errorCode = XML_ERROR_NO_MEMORY;
      return XML_STATUS_ERROR;
    }
    /* fall through */
  default:
    parser->m_parsingStatus.parsing = XML_PARSING;
  }

#if XML_CONTEXT_BYTES == 0
  if (parser->m_bufferPtr == parser->m_bufferEnd) {
    const char *end;
    int nLeftOver;
    enum XML_Status result;
    /* Detect overflow (a+b > MAX <==> b > MAX-a) */
    if ((XML_Size)len > ((XML_Size)-1) / 2 - parser->m_parseEndByteIndex) {
      parser->m_errorCode = XML_ERROR_NO_MEMORY;
      parser->m_eventPtr = parser->m_eventEndPtr = NULL;
      parser->m_processor = errorProcessor;
      return XML_STATUS_ERROR;
    }
    // though this isn't a buffer request, we assume that `len` is the app's
    // preferred buffer fill size, and therefore save it here.
    parser->m_lastBufferRequestSize = len;
    parser->m_parseEndByteIndex += len;
    parser->m_positionPtr = s;
    parser->m_parsingStatus.finalBuffer = (XML_Bool)isFinal;

    parser->m_errorCode =
        callProcessor(parser, s, parser->m_parseEndPtr = s + len, &end);

    if (parser->m_errorCode != XML_ERROR_NONE) {
      parser->m_eventEndPtr = parser->m_eventPtr;
      parser->m_processor = errorProcessor;
      return XML_STATUS_ERROR;
    } else {
      switch (parser->m_parsingStatus.parsing) {
      case XML_SUSPENDED:
        result = XML_STATUS_SUSPENDED;
        break;
      case XML_INITIALIZED:
      case XML_PARSING:
        if (isFinal) {
          parser->m_parsingStatus.parsing = XML_FINISHED;
          return XML_STATUS_OK;
        }
      /* fall through */
      default:
        result = XML_STATUS_OK;
      }
    }

    XmlUpdatePosition(parser->m_encoding, parser->m_positionPtr, end,
                      &parser->m_position);
    nLeftOver = s + len - end;
    if (nLeftOver) {
      // Back up and restore the parsing status to avoid XML_ERROR_SUSPENDED
      // (and XML_ERROR_FINISHED) from XML_GetBuffer.
      const enum XML_Parsing originalStatus = parser->m_parsingStatus.parsing;
      parser->m_parsingStatus.parsing = XML_PARSING;
      void *const temp = XML_GetBuffer(parser, nLeftOver);
      parser->m_parsingStatus.parsing = originalStatus;
      // GetBuffer may have overwritten this, but we want to remember what the
      // app requested, not how many bytes were left over after parsing.
      parser->m_lastBufferRequestSize = len;
      if (temp == NULL) {
        // NOTE: parser->m_errorCode has already been set by XML_GetBuffer().
        parser->m_eventPtr = parser->m_eventEndPtr = NULL;
        parser->m_processor = errorProcessor;
        return XML_STATUS_ERROR;
      }
      // Since we know that the buffer was empty and XML_CONTEXT_BYTES is 0, we
      // don't have any data to preserve, and can copy straight into the start
      // of the buffer rather than the GetBuffer return pointer (which may be
      // pointing further into the allocated buffer).
      memcpy(parser->m_buffer, end, nLeftOver);
    }
    parser->m_bufferPtr = parser->m_buffer;
    parser->m_bufferEnd = parser->m_buffer + nLeftOver;
    parser->m_positionPtr = parser->m_bufferPtr;
    parser->m_parseEndPtr = parser->m_bufferEnd;
    parser->m_eventPtr = parser->m_bufferPtr;
    parser->m_eventEndPtr = parser->m_bufferPtr;
    return result;
  }
#endif /* XML_CONTEXT_BYTES == 0 */
  void *buff = XML_GetBuffer(parser, len);
  if (buff == NULL)
    return XML_STATUS_ERROR;
  if (len > 0) {
    assert(s != NULL); // make sure s==NULL && len!=0 was rejected above
    memcpy(buff, s, len);
  }
  return XML_ParseBuffer(parser, len, isFinal);
}

enum XML_Status XMLCALL XML_ParseBuffer(XML_Parser parser, int len,
                                        int isFinal) {
  const char *start;
  enum XML_Status result = XML_STATUS_OK;

  if (parser == NULL)
    return XML_STATUS_ERROR;

  if (len < 0) {
    parser->m_errorCode = XML_ERROR_INVALID_ARGUMENT;
    return XML_STATUS_ERROR;
  }

  switch (parser->m_parsingStatus.parsing) {
  case XML_SUSPENDED:
    parser->m_errorCode = XML_ERROR_SUSPENDED;
    return XML_STATUS_ERROR;
  case XML_FINISHED:
    parser->m_errorCode = XML_ERROR_FINISHED;
    return XML_STATUS_ERROR;
  case XML_INITIALIZED:
    /* Has someone called XML_GetBuffer successfully before? */
    if (!parser->m_bufferPtr) {
      parser->m_errorCode = XML_ERROR_NO_BUFFER;
      return XML_STATUS_ERROR;
    }

    if (parser->m_parentParser == NULL && !startParsing(parser)) {
      parser->m_errorCode = XML_ERROR_NO_MEMORY;
      return XML_STATUS_ERROR;
    }
    /* fall through */
  default:
    parser->m_parsingStatus.parsing = XML_PARSING;
  }

  start = parser->m_bufferPtr;
  parser->m_positionPtr = start;
  parser->m_bufferEnd += len;
  parser->m_parseEndPtr = parser->m_bufferEnd;
  parser->m_parseEndByteIndex += len;
  parser->m_parsingStatus.finalBuffer = (XML_Bool)isFinal;

  parser->m_errorCode =
      callProcessor(parser, start, parser->m_parseEndPtr, &parser->m_bufferPtr);

  if (parser->m_errorCode != XML_ERROR_NONE) {
    parser->m_eventEndPtr = parser->m_eventPtr;
    parser->m_processor = errorProcessor;
    return XML_STATUS_ERROR;
  } else {
    switch (parser->m_parsingStatus.parsing) {
    case XML_SUSPENDED:
      result = XML_STATUS_SUSPENDED;
      break;
    case XML_INITIALIZED:
    case XML_PARSING:
      if (isFinal) {
        parser->m_parsingStatus.parsing = XML_FINISHED;
        return result;
      }
    default:; /* should not happen */
    }
  }

  XmlUpdatePosition(parser->m_encoding, parser->m_positionPtr,
                    parser->m_bufferPtr, &parser->m_position);
  parser->m_positionPtr = parser->m_bufferPtr;
  return result;
}

void *XMLCALL XML_GetBuffer(XML_Parser parser, int len) {
  if (parser == NULL)
    return NULL;
  if (len < 0) {
    parser->m_errorCode = XML_ERROR_NO_MEMORY;
    return NULL;
  }
  switch (parser->m_parsingStatus.parsing) {
  case XML_SUSPENDED:
    parser->m_errorCode = XML_ERROR_SUSPENDED;
    return NULL;
  case XML_FINISHED:
    parser->m_errorCode = XML_ERROR_FINISHED;
    return NULL;
  default:;
  }

  // whether or not the request succeeds, `len` seems to be the app's preferred
  // buffer fill size; remember it.
  parser->m_lastBufferRequestSize = len;
  if (len > EXPAT_SAFE_PTR_DIFF(parser->m_bufferLim, parser->m_bufferEnd) ||
      parser->m_buffer == NULL) {
#if XML_CONTEXT_BYTES > 0
    int keep;
#endif /* XML_CONTEXT_BYTES > 0 */
    /* Do not invoke signed arithmetic overflow: */
    int neededSize =
        (int)((unsigned)len + (unsigned)EXPAT_SAFE_PTR_DIFF(
                                  parser->m_bufferEnd, parser->m_bufferPtr));
    if (neededSize < 0) {
      parser->m_errorCode = XML_ERROR_NO_MEMORY;
      return NULL;
    }
#if XML_CONTEXT_BYTES > 0
    keep = (int)EXPAT_SAFE_PTR_DIFF(parser->m_bufferPtr, parser->m_buffer);
    if (keep > XML_CONTEXT_BYTES)
      keep = XML_CONTEXT_BYTES;
    /* Detect and prevent integer overflow */
    if (keep > INT_MAX - neededSize) {
      parser->m_errorCode = XML_ERROR_NO_MEMORY;
      return NULL;
    }
    neededSize += keep;
#endif /* XML_CONTEXT_BYTES > 0 */
    if (parser->m_buffer && parser->m_bufferPtr &&
        neededSize <=
            EXPAT_SAFE_PTR_DIFF(parser->m_bufferLim, parser->m_buffer)) {
#if XML_CONTEXT_BYTES > 0
      if (keep < EXPAT_SAFE_PTR_DIFF(parser->m_bufferPtr, parser->m_buffer)) {
        int offset =
            (int)EXPAT_SAFE_PTR_DIFF(parser->m_bufferPtr, parser->m_buffer) -
            keep;
        /* The buffer pointers cannot be NULL here; we have at least some bytes
         * in the buffer */
        memmove(parser->m_buffer, &parser->m_buffer[offset],
                parser->m_bufferEnd - parser->m_bufferPtr + keep);
        parser->m_bufferEnd -= offset;
        parser->m_bufferPtr -= offset;
      }
#else
      memmove(parser->m_buffer, parser->m_bufferPtr,
              EXPAT_SAFE_PTR_DIFF(parser->m_bufferEnd, parser->m_bufferPtr));
      parser->m_bufferEnd =
          parser->m_buffer +
          EXPAT_SAFE_PTR_DIFF(parser->m_bufferEnd, parser->m_bufferPtr);
      parser->m_bufferPtr = parser->m_buffer;
#endif /* XML_CONTEXT_BYTES > 0 */
    } else {
      char *newBuf;
      int bufferSize =
          (int)EXPAT_SAFE_PTR_DIFF(parser->m_bufferLim, parser->m_buffer);
      if (bufferSize == 0)
        bufferSize = INIT_BUFFER_SIZE;
      do {
        /* Do not invoke signed arithmetic overflow: */
        bufferSize = (int)(2U * (unsigned)bufferSize);
      } while (bufferSize < neededSize && bufferSize > 0);
      if (bufferSize <= 0) {
        parser->m_errorCode = XML_ERROR_NO_MEMORY;
        return NULL;
      }
      // NOTE: We are avoiding MALLOC(..) here to leave limiting
      //       the input size to the application using Expat.
      newBuf = parser->m_mem.malloc_fcn(bufferSize);
      if (newBuf == NULL) {
        parser->m_errorCode = XML_ERROR_NO_MEMORY;
        return NULL;
      }
      parser->m_bufferLim = newBuf + bufferSize;
#if XML_CONTEXT_BYTES > 0
      if (parser->m_bufferPtr) {
        memcpy(newBuf, &parser->m_bufferPtr[-keep],
               EXPAT_SAFE_PTR_DIFF(parser->m_bufferEnd, parser->m_bufferPtr) +
                   keep);
        // NOTE: We are avoiding FREE(..) here because parser->m_buffer
        //       is not being allocated with MALLOC(..) but with plain
        //       .malloc_fcn(..).
        parser->m_mem.free_fcn(parser->m_buffer);
        parser->m_buffer = newBuf;
        parser->m_bufferEnd =
            parser->m_buffer +
            EXPAT_SAFE_PTR_DIFF(parser->m_bufferEnd, parser->m_bufferPtr) +
            keep;
        parser->m_bufferPtr = parser->m_buffer + keep;
      } else {
        /* This must be a brand new buffer with no data in it yet */
        parser->m_bufferEnd = newBuf;
        parser->m_bufferPtr = parser->m_buffer = newBuf;
      }
#else
      if (parser->m_bufferPtr) {
        memcpy(newBuf, parser->m_bufferPtr,
               EXPAT_SAFE_PTR_DIFF(parser->m_bufferEnd, parser->m_bufferPtr));
        // NOTE: We are avoiding FREE(..) here because parser->m_buffer
        //       is not being allocated with MALLOC(..) but with plain
        //       .malloc_fcn(..).
        parser->m_mem.free_fcn(parser->m_buffer);
        parser->m_bufferEnd = newBuf + EXPAT_SAFE_PTR_DIFF(parser->m_bufferEnd,
                                                           parser->m_bufferPtr);
      } else {
        /* This must be a brand new buffer with no data in it yet */
        parser->m_bufferEnd = newBuf;
      }
      parser->m_bufferPtr = parser->m_buffer = newBuf;
#endif /* XML_CONTEXT_BYTES > 0 */
    }
    parser->m_eventPtr = parser->m_eventEndPtr = NULL;
    parser->m_positionPtr = NULL;
  }
  return parser->m_bufferEnd;
}

static void triggerReenter(XML_Parser parser) { parser->m_reenter = XML_TRUE; }

enum XML_Status XMLCALL XML_StopParser(XML_Parser parser, XML_Bool resumable) {
  if (parser == NULL)
    return XML_STATUS_ERROR;
  switch (parser->m_parsingStatus.parsing) {
  case XML_INITIALIZED:
    parser->m_errorCode = XML_ERROR_NOT_STARTED;
    return XML_STATUS_ERROR;
  case XML_SUSPENDED:
    if (resumable) {
      parser->m_errorCode = XML_ERROR_SUSPENDED;
      return XML_STATUS_ERROR;
    }
    parser->m_parsingStatus.parsing = XML_FINISHED;
    break;
  case XML_FINISHED:
    parser->m_errorCode = XML_ERROR_FINISHED;
    return XML_STATUS_ERROR;
  case XML_PARSING:
    if (resumable) {
#ifdef XML_DTD
      if (parser->m_isParamEntity) {
        parser->m_errorCode = XML_ERROR_SUSPEND_PE;
        return XML_STATUS_ERROR;
      }
#endif
      parser->m_parsingStatus.parsing = XML_SUSPENDED;
    } else
      parser->m_parsingStatus.parsing = XML_FINISHED;
    break;
  default:
    assert(0);
  }
  return XML_STATUS_OK;
}

enum XML_Status XMLCALL XML_ResumeParser(XML_Parser parser) {
  enum XML_Status result = XML_STATUS_OK;

  if (parser == NULL)
    return XML_STATUS_ERROR;
  if (parser->m_parsingStatus.parsing != XML_SUSPENDED) {
    parser->m_errorCode = XML_ERROR_NOT_SUSPENDED;
    return XML_STATUS_ERROR;
  }
  parser->m_parsingStatus.parsing = XML_PARSING;

  parser->m_errorCode = callProcessor(
      parser, parser->m_bufferPtr, parser->m_parseEndPtr, &parser->m_bufferPtr);

  if (parser->m_errorCode != XML_ERROR_NONE) {
    parser->m_eventEndPtr = parser->m_eventPtr;
    parser->m_processor = errorProcessor;
    return XML_STATUS_ERROR;
  } else {
    switch (parser->m_parsingStatus.parsing) {
    case XML_SUSPENDED:
      result = XML_STATUS_SUSPENDED;
      break;
    case XML_INITIALIZED:
    case XML_PARSING:
      if (parser->m_parsingStatus.finalBuffer) {
        parser->m_parsingStatus.parsing = XML_FINISHED;
        return result;
      }
    default:;
    }
  }

  XmlUpdatePosition(parser->m_encoding, parser->m_positionPtr,
                    parser->m_bufferPtr, &parser->m_position);
  parser->m_positionPtr = parser->m_bufferPtr;
  return result;
}

void XMLCALL XML_GetParsingStatus(XML_Parser parser,
                                  XML_ParsingStatus *status) {
  if (parser == NULL)
    return;
  assert(status != NULL);
  *status = parser->m_parsingStatus;
}

enum XML_Error XMLCALL XML_GetErrorCode(XML_Parser parser) {
  if (parser == NULL)
    return XML_ERROR_INVALID_ARGUMENT;
  return parser->m_errorCode;
}

XML_Index XMLCALL XML_GetCurrentByteIndex(XML_Parser parser) {
  if (parser == NULL)
    return -1;
  if (parser->m_eventPtr)
    return (XML_Index)(parser->m_parseEndByteIndex -
                       (parser->m_parseEndPtr - parser->m_eventPtr));
  return -1;
}

int XMLCALL XML_GetCurrentByteCount(XML_Parser parser) {
  if (parser == NULL)
    return 0;
  if (parser->m_eventEndPtr && parser->m_eventPtr)
    return (int)(parser->m_eventEndPtr - parser->m_eventPtr);
  return 0;
}

const char *XMLCALL XML_GetInputContext(XML_Parser parser, int *offset,
                                        int *size) {
#if XML_CONTEXT_BYTES > 0
  if (parser == NULL)
    return NULL;
  if (parser->m_eventPtr && parser->m_buffer) {
    if (offset != NULL)
      *offset = (int)(parser->m_eventPtr - parser->m_buffer);
    if (size != NULL)
      *size = (int)(parser->m_bufferEnd - parser->m_buffer);
    return parser->m_buffer;
  }
#else
  (void)parser;
  (void)offset;
  (void)size;
#endif /* XML_CONTEXT_BYTES > 0 */
  return (const char *)0;
}

XML_Size XMLCALL XML_GetCurrentLineNumber(XML_Parser parser) {
  if (parser == NULL)
    return 0;
  if (parser->m_eventPtr && parser->m_eventPtr >= parser->m_positionPtr) {
    XmlUpdatePosition(parser->m_encoding, parser->m_positionPtr,
                      parser->m_eventPtr, &parser->m_position);
    parser->m_positionPtr = parser->m_eventPtr;
  }
  return parser->m_position.lineNumber + 1;
}

XML_Size XMLCALL XML_GetCurrentColumnNumber(XML_Parser parser) {
  if (parser == NULL)
    return 0;
  if (parser->m_eventPtr && parser->m_eventPtr >= parser->m_positionPtr) {
    XmlUpdatePosition(parser->m_encoding, parser->m_positionPtr,
                      parser->m_eventPtr, &parser->m_position);
    parser->m_positionPtr = parser->m_eventPtr;
  }
  return parser->m_position.columnNumber;
}

void XMLCALL XML_FreeContentModel(XML_Parser parser, XML_Content *model) {
  if (parser == NULL)
    return;

  // NOTE: We are avoiding FREE(..) here because the content model
  //       has been created using plain .malloc_fcn(..) rather than MALLOC(..).
  parser->m_mem.free_fcn(model);
}

void *XMLCALL XML_MemMalloc(XML_Parser parser, size_t size) {
  if (parser == NULL)
    return NULL;

  // NOTE: We are avoiding MALLOC(..) here to not include
  //       user allocations with allocation tracking and limiting.
  return parser->m_mem.malloc_fcn(size);
}

void *XMLCALL XML_MemRealloc(XML_Parser parser, void *ptr, size_t size) {
  if (parser == NULL)
    return NULL;

  // NOTE: We are avoiding REALLOC(..) here to not include
  //       user allocations with allocation tracking and limiting.
  return parser->m_mem.realloc_fcn(ptr, size);
}

void XMLCALL XML_MemFree(XML_Parser parser, void *ptr) {
  if (parser == NULL)
    return;

  // NOTE: We are avoiding FREE(..) here because XML_MemMalloc and
  //       XML_MemRealloc are not using MALLOC(..) and REALLOC(..)
  //       but plain .malloc_fcn(..) and .realloc_fcn(..), internally.
  parser->m_mem.free_fcn(ptr);
}

void XMLCALL XML_DefaultCurrent(XML_Parser parser) {
  if (parser == NULL)
    return;
  if (parser->m_defaultHandler) {
    if (parser->m_openInternalEntities)
      reportDefault(parser, parser->m_internalEncoding,
                    parser->m_openInternalEntities->internalEventPtr,
                    parser->m_openInternalEntities->internalEventEndPtr);
    else
      reportDefault(parser, parser->m_encoding, parser->m_eventPtr,
                    parser->m_eventEndPtr);
  }
}

const XML_LChar *XMLCALL XML_ErrorString(enum XML_Error code) {
  switch (code) {
  case XML_ERROR_NONE:
    return NULL;
  case XML_ERROR_NO_MEMORY:
    return XML_L("out of memory");
  case XML_ERROR_SYNTAX:
    return XML_L("syntax error");
  case XML_ERROR_NO_ELEMENTS:
    return XML_L("no element found");
  case XML_ERROR_INVALID_TOKEN:
    return XML_L("not well-formed (invalid token)");
  case XML_ERROR_UNCLOSED_TOKEN:
    return XML_L("unclosed token");
  case XML_ERROR_PARTIAL_CHAR:
    return XML_L("partial character");
  case XML_ERROR_TAG_MISMATCH:
    return XML_L("mismatched tag");
  case XML_ERROR_DUPLICATE_ATTRIBUTE:
    return XML_L("duplicate attribute");
  case XML_ERROR_JUNK_AFTER_DOC_ELEMENT:
    return XML_L("junk after document element");
  case XML_ERROR_PARAM_ENTITY_REF:
    return XML_L("illegal parameter entity reference");
  case XML_ERROR_UNDEFINED_ENTITY:
    return XML_L("undefined entity");
  case XML_ERROR_RECURSIVE_ENTITY_REF:
    return XML_L("recursive entity reference");
  case XML_ERROR_ASYNC_ENTITY:
    return XML_L("asynchronous entity");
  case XML_ERROR_BAD_CHAR_REF:
    return XML_L("reference to invalid character number");
  case XML_ERROR_BINARY_ENTITY_REF:
    return XML_L("reference to binary entity");
  case XML_ERROR_ATTRIBUTE_EXTERNAL_ENTITY_REF:
    return XML_L("reference to external entity in attribute");
  case XML_ERROR_MISPLACED_XML_PI:
    return XML_L("XML or text declaration not at start of entity");
  case XML_ERROR_UNKNOWN_ENCODING:
    return XML_L("unknown encoding");
  case XML_ERROR_INCORRECT_ENCODING:
    return XML_L("encoding specified in XML declaration is incorrect");
  case XML_ERROR_UNCLOSED_CDATA_SECTION:
    return XML_L("unclosed CDATA section");
  case XML_ERROR_EXTERNAL_ENTITY_HANDLING:
    return XML_L("error in processing external entity reference");
  case XML_ERROR_NOT_STANDALONE:
    return XML_L("document is not standalone");
  case XML_ERROR_UNEXPECTED_STATE:
    return XML_L("unexpected parser state - please send a bug report");
  case XML_ERROR_ENTITY_DECLARED_IN_PE:
    return XML_L("entity declared in parameter entity");
  case XML_ERROR_FEATURE_REQUIRES_XML_DTD:
    return XML_L("requested feature requires XML_DTD support in Expat");
  case XML_ERROR_CANT_CHANGE_FEATURE_ONCE_PARSING:
    return XML_L("cannot change setting once parsing has begun");
  /* Added in 1.95.7. */
  case XML_ERROR_UNBOUND_PREFIX:
    return XML_L("unbound prefix");
  /* Added in 1.95.8. */
  case XML_ERROR_UNDECLARING_PREFIX:
    return XML_L("must not undeclare prefix");
  case XML_ERROR_INCOMPLETE_PE:
    return XML_L("incomplete markup in parameter entity");
  case XML_ERROR_XML_DECL:
    return XML_L("XML declaration not well-formed");
  case XML_ERROR_TEXT_DECL:
    return XML_L("text declaration not well-formed");
  case XML_ERROR_PUBLICID:
    return XML_L("illegal character(s) in public id");
  case XML_ERROR_SUSPENDED:
    return XML_L("parser suspended");
  case XML_ERROR_NOT_SUSPENDED:
    return XML_L("parser not suspended");
  case XML_ERROR_ABORTED:
    return XML_L("parsing aborted");
  case XML_ERROR_FINISHED:
    return XML_L("parsing finished");
  case XML_ERROR_SUSPEND_PE:
    return XML_L("cannot suspend in external parameter entity");
  /* Added in 2.0.0. */
  case XML_ERROR_RESERVED_PREFIX_XML:
    return XML_L("reserved prefix (xml) must not be undeclared or bound to "
                 "another namespace name");
  case XML_ERROR_RESERVED_PREFIX_XMLNS:
    return XML_L("reserved prefix (xmlns) must not be declared or undeclared");
  case XML_ERROR_RESERVED_NAMESPACE_URI:
    return XML_L(
        "prefix must not be bound to one of the reserved namespace names");
  /* Added in 2.2.5. */
  case XML_ERROR_INVALID_ARGUMENT: /* Constant added in 2.2.1, already */
    return XML_L("invalid argument");
    /* Added in 2.3.0. */
  case XML_ERROR_NO_BUFFER:
    return XML_L(
        "a successful prior call to function XML_GetBuffer is required");
  /* Added in 2.4.0. */
  case XML_ERROR_AMPLIFICATION_LIMIT_BREACH:
    return XML_L(
        "limit on input amplification factor (from DTD and entities) breached");
  /* Added in 2.6.4. */
  case XML_ERROR_NOT_STARTED:
    return XML_L("parser not started");
  }
  return NULL;
}

const XML_LChar *XMLCALL XML_ExpatVersion(void) {
  /* V1 is used to string-ize the version number. However, it would
     string-ize the actual version macro *names* unless we get them
     substituted before being passed to V1. CPP is defined to expand
     a macro, then rescan for more expansions. Thus, we use V2 to expand
     the version macros, then CPP will expand the resulting V1() macro
     with the correct numerals. */
  /* ### I'm assuming cpp is portable in this respect... */

#define V1(a, b, c) XML_L(#a) XML_L(".") XML_L(#b) XML_L(".") XML_L(#c)
#define V2(a, b, c) XML_L("expat_") V1(a, b, c)

  return V2(XML_MAJOR_VERSION, XML_MINOR_VERSION, XML_MICRO_VERSION);

#undef V1
#undef V2
}

XML_Expat_Version XMLCALL XML_ExpatVersionInfo(void) {
  XML_Expat_Version version;

  version.major = XML_MAJOR_VERSION;
  version.minor = XML_MINOR_VERSION;
  version.micro = XML_MICRO_VERSION;

  return version;
}

const XML_Feature *XMLCALL XML_GetFeatureList(void) {
  static const XML_Feature features[] = {
      {XML_FEATURE_SIZEOF_XML_CHAR, XML_L("sizeof(XML_Char)"),
       sizeof(XML_Char)},
      {XML_FEATURE_SIZEOF_XML_LCHAR, XML_L("sizeof(XML_LChar)"),
       sizeof(XML_LChar)},
#ifdef XML_UNICODE
      {XML_FEATURE_UNICODE, XML_L("XML_UNICODE"), 0},
#endif
#ifdef XML_UNICODE_WCHAR_T
      {XML_FEATURE_UNICODE_WCHAR_T, XML_L("XML_UNICODE_WCHAR_T"), 0},
#endif
#ifdef XML_DTD
      {XML_FEATURE_DTD, XML_L("XML_DTD"), 0},
#endif
#if XML_CONTEXT_BYTES > 0
      {XML_FEATURE_CONTEXT_BYTES, XML_L("XML_CONTEXT_BYTES"),
       XML_CONTEXT_BYTES},
#endif
#ifdef XML_MIN_SIZE
      {XML_FEATURE_MIN_SIZE, XML_L("XML_MIN_SIZE"), 0},
#endif
#ifdef XML_NS
      {XML_FEATURE_NS, XML_L("XML_NS"), 0},
#endif
#ifdef XML_LARGE_SIZE
      {XML_FEATURE_LARGE_SIZE, XML_L("XML_LARGE_SIZE"), 0},
#endif
#ifdef XML_ATTR_INFO
      {XML_FEATURE_ATTR_INFO, XML_L("XML_ATTR_INFO"), 0},
#endif
#if XML_GE == 1
      /* Added in Expat 2.4.0 for XML_DTD defined and
       * added in Expat 2.6.0 for XML_GE == 1. */
      {XML_FEATURE_BILLION_LAUGHS_ATTACK_PROTECTION_MAXIMUM_AMPLIFICATION_DEFAULT,
       XML_L("XML_BLAP_MAX_AMP"),
       (long int)
           EXPAT_BILLION_LAUGHS_ATTACK_PROTECTION_MAXIMUM_AMPLIFICATION_DEFAULT},
      {XML_FEATURE_BILLION_LAUGHS_ATTACK_PROTECTION_ACTIVATION_THRESHOLD_DEFAULT,
       XML_L("XML_BLAP_ACT_THRES"),
       EXPAT_BILLION_LAUGHS_ATTACK_PROTECTION_ACTIVATION_THRESHOLD_DEFAULT},
      /* Added in Expat 2.6.0. */
      {XML_FEATURE_GE, XML_L("XML_GE"), 0},
      /* Added in Expat 2.7.2. */
      {XML_FEATURE_ALLOC_TRACKER_MAXIMUM_AMPLIFICATION_DEFAULT,
       XML_L("XML_AT_MAX_AMP"),
       (long int)EXPAT_ALLOC_TRACKER_MAXIMUM_AMPLIFICATION_DEFAULT},
      {XML_FEATURE_ALLOC_TRACKER_ACTIVATION_THRESHOLD_DEFAULT,
       XML_L("XML_AT_ACT_THRES"),
       (long int)EXPAT_ALLOC_TRACKER_ACTIVATION_THRESHOLD_DEFAULT},
#endif
      {XML_FEATURE_END, NULL, 0}};

  return features;
}

#if XML_GE == 1
XML_Bool XMLCALL XML_SetBillionLaughsAttackProtectionMaximumAmplification(
    XML_Parser parser, float maximumAmplificationFactor) {
  if ((parser == NULL) || (parser->m_parentParser != NULL) ||
      isnan(maximumAmplificationFactor) ||
      (maximumAmplificationFactor < 1.0f)) {
    return XML_FALSE;
  }
  parser->m_accounting.maximumAmplificationFactor = maximumAmplificationFactor;
  return XML_TRUE;
}

XML_Bool XMLCALL XML_SetBillionLaughsAttackProtectionActivationThreshold(
    XML_Parser parser, unsigned long long activationThresholdBytes) {
  if ((parser == NULL) || (parser->m_parentParser != NULL)) {
    return XML_FALSE;
  }
  parser->m_accounting.activationThresholdBytes = activationThresholdBytes;
  return XML_TRUE;
}

XML_Bool XMLCALL XML_SetAllocTrackerMaximumAmplification(
    XML_Parser parser, float maximumAmplificationFactor) {
  if ((parser == NULL) || (parser->m_parentParser != NULL) ||
      isnan(maximumAmplificationFactor) ||
      (maximumAmplificationFactor < 1.0f)) {
    return XML_FALSE;
  }
  parser->m_alloc_tracker.maximumAmplificationFactor =
      maximumAmplificationFactor;
  return XML_TRUE;
}

XML_Bool XMLCALL XML_SetAllocTrackerActivationThreshold(
    XML_Parser parser, unsigned long long activationThresholdBytes) {
  if ((parser == NULL) || (parser->m_parentParser != NULL)) {
    return XML_FALSE;
  }
  parser->m_alloc_tracker.activationThresholdBytes = activationThresholdBytes;
  return XML_TRUE;
}
#endif /* XML_GE == 1 */

XML_Bool XMLCALL XML_SetReparseDeferralEnabled(XML_Parser parser,
                                               XML_Bool enabled) {
  if (parser != NULL && (enabled == XML_TRUE || enabled == XML_FALSE)) {
    parser->m_reparseDeferralEnabled = enabled;
    return XML_TRUE;
  }
  return XML_FALSE;
}

/* Initially tag->rawName always points into the parse buffer;
   for those TAG instances opened while the current parse buffer was
   processed, and not yet closed, we need to store tag->rawName in a more
   permanent location, since the parse buffer is about to be discarded.
*/
static XML_Bool storeRawNames(XML_Parser parser) {
  TAG *tag = parser->m_tagStack;
  while (tag) {
    size_t bufSize;
    size_t nameLen = sizeof(XML_Char) * (tag->name.strLen + 1);
    size_t rawNameLen;
    char *rawNameBuf = tag->buf.raw + nameLen;
    /* Stop if already stored.  Since m_tagStack is a stack, we can stop
       at the first entry that has already been copied; everything
       below it in the stack is already been accounted for in a
       previous call to this function.
    */
    if (tag->rawName == rawNameBuf)
      break;
    /* For reuse purposes we need to ensure that the
       size of tag->buf is a multiple of sizeof(XML_Char).
    */
    rawNameLen = ROUND_UP(tag->rawNameLength, sizeof(XML_Char));
    /* Detect and prevent integer overflow. */
    if (rawNameLen > (size_t)INT_MAX - nameLen)
      return XML_FALSE;
    bufSize = nameLen + rawNameLen;
    if (bufSize > (size_t)(tag->bufEnd - tag->buf.raw)) {
      char *temp = REALLOC(parser, tag->buf.raw, bufSize);
      if (temp == NULL)
        return XML_FALSE;
      /* if tag->name.str points to tag->buf.str (only when namespace
         processing is off) then we have to update it
      */
      if (tag->name.str == tag->buf.str)
        tag->name.str = (XML_Char *)temp;
      /* if tag->name.localPart is set (when namespace processing is on)
         then update it as well, since it will always point into tag->buf
      */
      if (tag->name.localPart)
        tag->name.localPart =
            (XML_Char *)temp + (tag->name.localPart - tag->buf.str);
      tag->buf.raw = temp;
      tag->bufEnd = temp + bufSize;
      rawNameBuf = temp + nameLen;
    }
    memcpy(rawNameBuf, tag->rawName, tag->rawNameLength);
    tag->rawName = rawNameBuf;
    tag = tag->parent;
  }
  return XML_TRUE;
}

static enum XML_Error PTRCALL contentProcessor(XML_Parser parser,
                                               const char *start,
                                               const char *end,
                                               const char **endPtr) {
  enum XML_Error result = doContent(
      parser, parser->m_parentParser ? 1 : 0, parser->m_encoding, start, end,
      endPtr, (XML_Bool)!parser->m_parsingStatus.finalBuffer,
      XML_ACCOUNT_DIRECT);
  if (result == XML_ERROR_NONE) {
    if (!storeRawNames(parser))
      return XML_ERROR_NO_MEMORY;
  }
  return result;
}

static enum XML_Error PTRCALL externalEntityInitProcessor(XML_Parser parser,
                                                          const char *start,
                                                          const char *end,
                                                          const char **endPtr) {
  enum XML_Error result = initializeEncoding(parser);
  if (result != XML_ERROR_NONE)
    return result;
  parser->m_processor = externalEntityInitProcessor2;
  return externalEntityInitProcessor2(parser, start, end, endPtr);
}

static enum XML_Error PTRCALL
externalEntityInitProcessor2(XML_Parser parser, const char *start,
                             const char *end, const char **endPtr) {
  const char *next = start; /* XmlContentTok doesn't always set the last arg */
  int tok = XmlContentTok(parser->m_encoding, start, end, &next);
  switch (tok) {
  case XML_TOK_BOM:
#if XML_GE == 1
    if (!accountingDiffTolerated(parser, tok, start, next, __LINE__,
                                 XML_ACCOUNT_DIRECT)) {
      accountingOnAbort(parser);
      return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
    }
#endif /* XML_GE == 1 */

    /* If we are at the end of the buffer, this would cause the next stage,
       i.e. externalEntityInitProcessor3, to pass control directly to
       doContent (by detecting XML_TOK_NONE) without processing any xml text
       declaration - causing the error XML_ERROR_MISPLACED_XML_PI in doContent.
    */
    if (next == end && !parser->m_parsingStatus.finalBuffer) {
      *endPtr = next;
      return XML_ERROR_NONE;
    }
    start = next;
    break;
  case XML_TOK_PARTIAL:
    if (!parser->m_parsingStatus.finalBuffer) {
      *endPtr = start;
      return XML_ERROR_NONE;
    }
    parser->m_eventPtr = start;
    return XML_ERROR_UNCLOSED_TOKEN;
  case XML_TOK_PARTIAL_CHAR:
    if (!parser->m_parsingStatus.finalBuffer) {
      *endPtr = start;
      return XML_ERROR_NONE;
    }
    parser->m_eventPtr = start;
    return XML_ERROR_PARTIAL_CHAR;
  }
  parser->m_processor = externalEntityInitProcessor3;
  return externalEntityInitProcessor3(parser, start, end, endPtr);
}

static enum XML_Error PTRCALL
externalEntityInitProcessor3(XML_Parser parser, const char *start,
                             const char *end, const char **endPtr) {
  int tok;
  const char *next = start; /* XmlContentTok doesn't always set the last arg */
  parser->m_eventPtr = start;
  tok = XmlContentTok(parser->m_encoding, start, end, &next);
  /* Note: These bytes are accounted later in:
           - processXmlDecl
           - externalEntityContentProcessor
  */
  parser->m_eventEndPtr = next;

  switch (tok) {
  case XML_TOK_XML_DECL: {
    enum XML_Error result;
    result = processXmlDecl(parser, 1, start, next);
    if (result != XML_ERROR_NONE)
      return result;
    switch (parser->m_parsingStatus.parsing) {
    case XML_SUSPENDED:
      *endPtr = next;
      return XML_ERROR_NONE;
    case XML_FINISHED:
      return XML_ERROR_ABORTED;
    case XML_PARSING:
      if (parser->m_reenter) {
        return XML_ERROR_UNEXPECTED_STATE; // LCOV_EXCL_LINE
      }
      /* Fall through */
    default:
      start = next;
    }
  } break;
  case XML_TOK_PARTIAL:
    if (!parser->m_parsingStatus.finalBuffer) {
      *endPtr = start;
      return XML_ERROR_NONE;
    }
    return XML_ERROR_UNCLOSED_TOKEN;
  case XML_TOK_PARTIAL_CHAR:
    if (!parser->m_parsingStatus.finalBuffer) {
      *endPtr = start;
      return XML_ERROR_NONE;
    }
    return XML_ERROR_PARTIAL_CHAR;
  }
  parser->m_processor = externalEntityContentProcessor;
  parser->m_tagLevel = 1;
  return externalEntityContentProcessor(parser, start, end, endPtr);
}

static enum XML_Error PTRCALL
externalEntityContentProcessor(XML_Parser parser, const char *start,
                               const char *end, const char **endPtr) {
  enum XML_Error result =
      doContent(parser, 1, parser->m_encoding, start, end, endPtr,
                (XML_Bool)!parser->m_parsingStatus.finalBuffer,
                XML_ACCOUNT_ENTITY_EXPANSION);
  if (result == XML_ERROR_NONE) {
    if (!storeRawNames(parser))
      return XML_ERROR_NO_MEMORY;
  }
  return result;
}

static enum XML_Error doContent(XML_Parser parser, int startTagLevel,
                                const ENCODING *enc, const char *s,
                                const char *end, const char **nextPtr,
                                XML_Bool haveMore, enum XML_Account account) {
  /* save one level of indirection */
  DTD *const dtd = parser->m_dtd;

  const char **eventPP;
  const char **eventEndPP;
  if (enc == parser->m_encoding) {
    eventPP = &parser->m_eventPtr;
    eventEndPP = &parser->m_eventEndPtr;
  } else {
    eventPP = &(parser->m_openInternalEntities->internalEventPtr);
    eventEndPP = &(parser->m_openInternalEntities->internalEventEndPtr);
  }
  *eventPP = s;

  for (;;) {
    const char *next = s; /* XmlContentTok doesn't always set the last arg */
    int tok = XmlContentTok(enc, s, end, &next);
#if XML_GE == 1
    const char *accountAfter =
        ((tok == XML_TOK_TRAILING_RSQB) || (tok == XML_TOK_TRAILING_CR))
            ? (haveMore ? s /* i.e. 0 bytes */ : end)
            : next;
    if (!accountingDiffTolerated(parser, tok, s, accountAfter, __LINE__,
                                 account)) {
      accountingOnAbort(parser);
      return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
    }
#endif
    *eventEndPP = next;
    switch (tok) {
    case XML_TOK_TRAILING_CR:
      if (haveMore) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      *eventEndPP = end;
      if (parser->m_characterDataHandler) {
        XML_Char c = 0xA;
        parser->m_characterDataHandler(parser->m_handlerArg, &c, 1);
      } else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, end);
      /* We are at the end of the final buffer, should we check for
         XML_SUSPENDED, XML_FINISHED?
      */
      if (startTagLevel == 0)
        return XML_ERROR_NO_ELEMENTS;
      if (parser->m_tagLevel != startTagLevel)
        return XML_ERROR_ASYNC_ENTITY;
      *nextPtr = end;
      return XML_ERROR_NONE;
    case XML_TOK_NONE:
      if (haveMore) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      if (startTagLevel > 0) {
        if (parser->m_tagLevel != startTagLevel)
          return XML_ERROR_ASYNC_ENTITY;
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      return XML_ERROR_NO_ELEMENTS;
    case XML_TOK_INVALID:
      *eventPP = next;
      return XML_ERROR_INVALID_TOKEN;
    case XML_TOK_PARTIAL:
      if (haveMore) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      return XML_ERROR_UNCLOSED_TOKEN;
    case XML_TOK_PARTIAL_CHAR:
      if (haveMore) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      return XML_ERROR_PARTIAL_CHAR;
    case XML_TOK_ENTITY_REF: {
      const XML_Char *name;
      ENTITY *entity;
      XML_Char ch = (XML_Char)XmlPredefinedEntityName(
          enc, s + enc->minBytesPerChar, next - enc->minBytesPerChar);
      if (ch) {
#if XML_GE == 1
        /* NOTE: We are replacing 4-6 characters original input for 1 character
         *       so there is no amplification and hence recording without
         *       protection. */
        accountingDiffTolerated(parser, tok, (char *)&ch,
                                ((char *)&ch) + sizeof(XML_Char), __LINE__,
                                XML_ACCOUNT_ENTITY_EXPANSION);
#endif /* XML_GE == 1 */
        if (parser->m_characterDataHandler)
          parser->m_characterDataHandler(parser->m_handlerArg, &ch, 1);
        else if (parser->m_defaultHandler)
          reportDefault(parser, enc, s, next);
        break;
      }
      name = poolStoreString(&dtd->pool, enc, s + enc->minBytesPerChar,
                             next - enc->minBytesPerChar);
      if (!name)
        return XML_ERROR_NO_MEMORY;
      entity = (ENTITY *)lookup(parser, &dtd->generalEntities, name, 0);
      poolDiscard(&dtd->pool);
      /* First, determine if a check for an existing declaration is needed;
         if yes, check that the entity exists, and that it is internal,
         otherwise call the skipped entity or default handler.
      */
      if (!dtd->hasParamEntityRefs || dtd->standalone) {
        if (!entity)
          return XML_ERROR_UNDEFINED_ENTITY;
        else if (!entity->is_internal)
          return XML_ERROR_ENTITY_DECLARED_IN_PE;
      } else if (!entity) {
        if (parser->m_skippedEntityHandler)
          parser->m_skippedEntityHandler(parser->m_handlerArg, name, 0);
        else if (parser->m_defaultHandler)
          reportDefault(parser, enc, s, next);
        break;
      }
      if (entity->open)
        return XML_ERROR_RECURSIVE_ENTITY_REF;
      if (entity->notation)
        return XML_ERROR_BINARY_ENTITY_REF;
      if (entity->textPtr) {
        enum XML_Error result;
        if (!parser->m_defaultExpandInternalEntities) {
          if (parser->m_skippedEntityHandler)
            parser->m_skippedEntityHandler(parser->m_handlerArg, entity->name,
                                           0);
          else if (parser->m_defaultHandler)
            reportDefault(parser, enc, s, next);
          break;
        }
        result = processEntity(parser, entity, XML_FALSE, ENTITY_INTERNAL);
        if (result != XML_ERROR_NONE)
          return result;
      } else if (parser->m_externalEntityRefHandler) {
        const XML_Char *context;
        entity->open = XML_TRUE;
        context = getContext(parser);
        entity->open = XML_FALSE;
        if (!context)
          return XML_ERROR_NO_MEMORY;
        if (!parser->m_externalEntityRefHandler(
                parser->m_externalEntityRefHandlerArg, context, entity->base,
                entity->systemId, entity->publicId))
          return XML_ERROR_EXTERNAL_ENTITY_HANDLING;
        poolDiscard(&parser->m_tempPool);
      } else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
      break;
    }
    case XML_TOK_START_TAG_NO_ATTS:
      /* fall through */
    case XML_TOK_START_TAG_WITH_ATTS: {
      TAG *tag;
      enum XML_Error result;
      XML_Char *toPtr;
      if (parser->m_freeTagList) {
        tag = parser->m_freeTagList;
        parser->m_freeTagList = parser->m_freeTagList->parent;
      } else {
        tag = MALLOC(parser, sizeof(TAG));
        if (!tag)
          return XML_ERROR_NO_MEMORY;
        tag->buf.raw = MALLOC(parser, INIT_TAG_BUF_SIZE);
        if (!tag->buf.raw) {
          FREE(parser, tag);
          return XML_ERROR_NO_MEMORY;
        }
        tag->bufEnd = tag->buf.raw + INIT_TAG_BUF_SIZE;
      }
      tag->bindings = NULL;
      tag->parent = parser->m_tagStack;
      parser->m_tagStack = tag;
      tag->name.localPart = NULL;
      tag->name.prefix = NULL;
      tag->rawName = s + enc->minBytesPerChar;
      tag->rawNameLength = XmlNameLength(enc, tag->rawName);
      ++parser->m_tagLevel;
      {
        const char *rawNameEnd = tag->rawName + tag->rawNameLength;
        const char *fromPtr = tag->rawName;
        toPtr = tag->buf.str;
        for (;;) {
          int convLen;
          const enum XML_Convert_Result convert_res =
              XmlConvert(enc, &fromPtr, rawNameEnd, (ICHAR **)&toPtr,
                         (ICHAR *)tag->bufEnd - 1);
          convLen = (int)(toPtr - tag->buf.str);
          if ((fromPtr >= rawNameEnd) ||
              (convert_res == XML_CONVERT_INPUT_INCOMPLETE)) {
            tag->name.strLen = convLen;
            break;
          }
          if (SIZE_MAX / 2 < (size_t)(tag->bufEnd - tag->buf.raw))
            return XML_ERROR_NO_MEMORY;
          const size_t bufSize = (size_t)(tag->bufEnd - tag->buf.raw) * 2;
          {
            char *temp = REALLOC(parser, tag->buf.raw, bufSize);
            if (temp == NULL)
              return XML_ERROR_NO_MEMORY;
            tag->buf.raw = temp;
            tag->bufEnd = temp + bufSize;
            toPtr = (XML_Char *)temp + convLen;
          }
        }
      }
      tag->name.str = tag->buf.str;
      *toPtr = XML_T('\0');
      result =
          storeAtts(parser, enc, s, &(tag->name), &(tag->bindings), account);
      if (result)
        return result;
      if (parser->m_startElementHandler)
        parser->m_startElementHandler(parser->m_handlerArg, tag->name.str,
                                      (const XML_Char **)parser->m_atts);
      else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
      poolClear(&parser->m_tempPool);
      break;
    }
    case XML_TOK_EMPTY_ELEMENT_NO_ATTS:
      /* fall through */
    case XML_TOK_EMPTY_ELEMENT_WITH_ATTS: {
      const char *rawName = s + enc->minBytesPerChar;
      enum XML_Error result;
      BINDING *bindings = NULL;
      XML_Bool noElmHandlers = XML_TRUE;
      TAG_NAME name;
      name.str = poolStoreString(&parser->m_tempPool, enc, rawName,
                                 rawName + XmlNameLength(enc, rawName));
      if (!name.str)
        return XML_ERROR_NO_MEMORY;
      poolFinish(&parser->m_tempPool);
      result = storeAtts(parser, enc, s, &name, &bindings,
                         XML_ACCOUNT_NONE /* token spans whole start tag */);
      if (result != XML_ERROR_NONE) {
        freeBindings(parser, bindings);
        return result;
      }
      poolFinish(&parser->m_tempPool);
      if (parser->m_startElementHandler) {
        parser->m_startElementHandler(parser->m_handlerArg, name.str,
                                      (const XML_Char **)parser->m_atts);
        noElmHandlers = XML_FALSE;
      }
      if (parser->m_endElementHandler) {
        if (parser->m_startElementHandler)
          *eventPP = *eventEndPP;
        parser->m_endElementHandler(parser->m_handlerArg, name.str);
        noElmHandlers = XML_FALSE;
      }
      if (noElmHandlers && parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
      poolClear(&parser->m_tempPool);
      freeBindings(parser, bindings);
    }
      if ((parser->m_tagLevel == 0) &&
          (parser->m_parsingStatus.parsing != XML_FINISHED)) {
        if (parser->m_parsingStatus.parsing == XML_SUSPENDED ||
            (parser->m_parsingStatus.parsing == XML_PARSING &&
             parser->m_reenter))
          parser->m_processor = epilogProcessor;
        else
          return epilogProcessor(parser, next, end, nextPtr);
      }
      break;
    case XML_TOK_END_TAG:
      if (parser->m_tagLevel == startTagLevel)
        return XML_ERROR_ASYNC_ENTITY;
      else {
        int len;
        const char *rawName;
        TAG *tag = parser->m_tagStack;
        rawName = s + enc->minBytesPerChar * 2;
        len = XmlNameLength(enc, rawName);
        if (len != tag->rawNameLength ||
            memcmp(tag->rawName, rawName, len) != 0) {
          *eventPP = rawName;
          return XML_ERROR_TAG_MISMATCH;
        }
        parser->m_tagStack = tag->parent;
        tag->parent = parser->m_freeTagList;
        parser->m_freeTagList = tag;
        --parser->m_tagLevel;
        if (parser->m_endElementHandler) {
          const XML_Char *localPart;
          const XML_Char *prefix;
          XML_Char *uri;
          localPart = tag->name.localPart;
          if (parser->m_ns && localPart) {
            /* localPart and prefix may have been overwritten in
               tag->name.str, since this points to the binding->uri
               buffer which gets reused; so we have to add them again
            */
            uri = (XML_Char *)tag->name.str + tag->name.uriLen;
            /* don't need to check for space - already done in storeAtts() */
            while (*localPart)
              *uri++ = *localPart++;
            prefix = tag->name.prefix;
            if (parser->m_ns_triplets && prefix) {
              *uri++ = parser->m_namespaceSeparator;
              while (*prefix)
                *uri++ = *prefix++;
            }
            *uri = XML_T('\0');
          }
          parser->m_endElementHandler(parser->m_handlerArg, tag->name.str);
        } else if (parser->m_defaultHandler)
          reportDefault(parser, enc, s, next);
        while (tag->bindings) {
          BINDING *b = tag->bindings;
          if (parser->m_endNamespaceDeclHandler)
            parser->m_endNamespaceDeclHandler(parser->m_handlerArg,
                                              b->prefix->name);
          tag->bindings = tag->bindings->nextTagBinding;
          b->nextTagBinding = parser->m_freeBindingList;
          parser->m_freeBindingList = b;
          b->prefix->binding = b->prevPrefixBinding;
        }
        if ((parser->m_tagLevel == 0) &&
            (parser->m_parsingStatus.parsing != XML_FINISHED)) {
          if (parser->m_parsingStatus.parsing == XML_SUSPENDED ||
              (parser->m_parsingStatus.parsing == XML_PARSING &&
               parser->m_reenter))
            parser->m_processor = epilogProcessor;
          else
            return epilogProcessor(parser, next, end, nextPtr);
        }
      }
      break;
    case XML_TOK_CHAR_REF: {
      int n = XmlCharRefNumber(enc, s);
      if (n < 0)
        return XML_ERROR_BAD_CHAR_REF;
      if (parser->m_characterDataHandler) {
        XML_Char buf[XML_ENCODE_MAX];
        parser->m_characterDataHandler(parser->m_handlerArg, buf,
                                       XmlEncode(n, (ICHAR *)buf));
      } else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
    } break;
    case XML_TOK_XML_DECL:
      return XML_ERROR_MISPLACED_XML_PI;
    case XML_TOK_DATA_NEWLINE:
      if (parser->m_characterDataHandler) {
        XML_Char c = 0xA;
        parser->m_characterDataHandler(parser->m_handlerArg, &c, 1);
      } else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
      break;
    case XML_TOK_CDATA_SECT_OPEN: {
      enum XML_Error result;
      if (parser->m_startCdataSectionHandler)
        parser->m_startCdataSectionHandler(parser->m_handlerArg);
      /* BEGIN disabled code */
      /* Suppose you doing a transformation on a document that involves
         changing only the character data.  You set up a defaultHandler
         and a characterDataHandler.  The defaultHandler simply copies
         characters through.  The characterDataHandler does the
         transformation and writes the characters out escaping them as
         necessary.  This case will fail to work if we leave out the
         following two lines (because & and < inside CDATA sections will
         be incorrectly escaped).

         However, now we have a start/endCdataSectionHandler, so it seems
         easier to let the user deal with this.
      */
      else if ((0) && parser->m_characterDataHandler)
        parser->m_characterDataHandler(parser->m_handlerArg, parser->m_dataBuf,
                                       0);
      /* END disabled code */
      else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
      result =
          doCdataSection(parser, enc, &next, end, nextPtr, haveMore, account);
      if (result != XML_ERROR_NONE)
        return result;
      else if (!next) {
        parser->m_processor = cdataSectionProcessor;
        return result;
      }
    } break;
    case XML_TOK_TRAILING_RSQB:
      if (haveMore) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      if (parser->m_characterDataHandler) {
        if (MUST_CONVERT(enc, s)) {
          ICHAR *dataPtr = (ICHAR *)parser->m_dataBuf;
          XmlConvert(enc, &s, end, &dataPtr, (ICHAR *)parser->m_dataBufEnd);
          parser->m_characterDataHandler(
              parser->m_handlerArg, parser->m_dataBuf,
              (int)(dataPtr - (ICHAR *)parser->m_dataBuf));
        } else
          parser->m_characterDataHandler(
              parser->m_handlerArg, (const XML_Char *)s,
              (int)((const XML_Char *)end - (const XML_Char *)s));
      } else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, end);
      /* We are at the end of the final buffer, should we check for
         XML_SUSPENDED, XML_FINISHED?
      */
      if (startTagLevel == 0) {
        *eventPP = end;
        return XML_ERROR_NO_ELEMENTS;
      }
      if (parser->m_tagLevel != startTagLevel) {
        *eventPP = end;
        return XML_ERROR_ASYNC_ENTITY;
      }
      *nextPtr = end;
      return XML_ERROR_NONE;
    case XML_TOK_DATA_CHARS: {
      XML_CharacterDataHandler charDataHandler = parser->m_characterDataHandler;
      if (charDataHandler) {
        if (MUST_CONVERT(enc, s)) {
          for (;;) {
            ICHAR *dataPtr = (ICHAR *)parser->m_dataBuf;
            const enum XML_Convert_Result convert_res = XmlConvert(
                enc, &s, next, &dataPtr, (ICHAR *)parser->m_dataBufEnd);
            *eventEndPP = s;
            charDataHandler(parser->m_handlerArg, parser->m_dataBuf,
                            (int)(dataPtr - (ICHAR *)parser->m_dataBuf));
            if ((convert_res == XML_CONVERT_COMPLETED) ||
                (convert_res == XML_CONVERT_INPUT_INCOMPLETE))
              break;
            *eventPP = s;
          }
        } else
          charDataHandler(parser->m_handlerArg, (const XML_Char *)s,
                          (int)((const XML_Char *)next - (const XML_Char *)s));
      } else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
    } break;
    case XML_TOK_PI:
      if (!reportProcessingInstruction(parser, enc, s, next))
        return XML_ERROR_NO_MEMORY;
      break;
    case XML_TOK_COMMENT:
      if (!reportComment(parser, enc, s, next))
        return XML_ERROR_NO_MEMORY;
      break;
    default:
      /* All of the tokens produced by XmlContentTok() have their own
       * explicit cases, so this default is not strictly necessary.
       * However it is a useful safety net, so we retain the code and
       * simply exclude it from the coverage tests.
       *
       * LCOV_EXCL_START
       */
      if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
      break;
      /* LCOV_EXCL_STOP */
    }
    switch (parser->m_parsingStatus.parsing) {
    case XML_SUSPENDED:
      *eventPP = next;
      *nextPtr = next;
      return XML_ERROR_NONE;
    case XML_FINISHED:
      *eventPP = next;
      return XML_ERROR_ABORTED;
    case XML_PARSING:
      if (parser->m_reenter) {
        *nextPtr = next;
        return XML_ERROR_NONE;
      }
      /* Fall through */
    default:;
      *eventPP = s = next;
    }
  }
  /* not reached */
}

/* This function does not call free() on the allocated memory, merely
 * moving it to the parser's m_freeBindingList where it can be freed or
 * reused as appropriate.
 */
static void freeBindings(XML_Parser parser, BINDING *bindings) {
  while (bindings) {
    BINDING *b = bindings;

    /* m_startNamespaceDeclHandler will have been called for this
     * binding in addBindings(), so call the end handler now.
     */
    if (parser->m_endNamespaceDeclHandler)
      parser->m_endNamespaceDeclHandler(parser->m_handlerArg, b->prefix->name);

    bindings = bindings->nextTagBinding;
    b->nextTagBinding = parser->m_freeBindingList;
    parser->m_freeBindingList = b;
    b->prefix->binding = b->prevPrefixBinding;
  }
}

/* Precondition: all arguments must be non-NULL;
   Purpose:
   - normalize attributes
   - check attributes for well-formedness
   - generate namespace aware attribute names (URI, prefix)
   - build list of attributes for startElementHandler
   - default attributes
   - process namespace declarations (check and report them)
   - generate namespace aware element name (URI, prefix)
*/
static enum XML_Error storeAtts(XML_Parser parser, const ENCODING *enc,
                                const char *attStr, TAG_NAME *tagNamePtr,
                                BINDING **bindingsPtr,
                                enum XML_Account account) {
  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
  ELEMENT_TYPE *elementType;
  int nDefaultAtts;
  const XML_Char **appAtts; /* the attribute list for the application */
  int attIndex = 0;
  int prefixLen;
  int i;
  int n;
  XML_Char *uri;
  int nPrefixes = 0;
  BINDING *binding;
  const XML_Char *localPart;

  /* lookup the element type name */
  elementType =
      (ELEMENT_TYPE *)lookup(parser, &dtd->elementTypes, tagNamePtr->str, 0);
  if (!elementType) {
    const XML_Char *name = poolCopyString(&dtd->pool, tagNamePtr->str);
    if (!name)
      return XML_ERROR_NO_MEMORY;
    elementType = (ELEMENT_TYPE *)lookup(parser, &dtd->elementTypes, name,
                                         sizeof(ELEMENT_TYPE));
    if (!elementType)
      return XML_ERROR_NO_MEMORY;
    if (parser->m_ns && !setElementTypePrefix(parser, elementType))
      return XML_ERROR_NO_MEMORY;
  }
  nDefaultAtts = elementType->nDefaultAtts;

  /* get the attributes from the tokenizer */
  n = XmlGetAttributes(enc, attStr, parser->m_attsSize, parser->m_atts);

  /* Detect and prevent integer overflow */
  if (n > INT_MAX - nDefaultAtts) {
    return XML_ERROR_NO_MEMORY;
  }

  if (n + nDefaultAtts > parser->m_attsSize) {
    int oldAttsSize = parser->m_attsSize;
    ATTRIBUTE *temp;
#ifdef XML_ATTR_INFO
    XML_AttrInfo *temp2;
#endif

    /* Detect and prevent integer overflow */
    if ((nDefaultAtts > INT_MAX - INIT_ATTS_SIZE) ||
        (n > INT_MAX - (nDefaultAtts + INIT_ATTS_SIZE))) {
      return XML_ERROR_NO_MEMORY;
    }

    parser->m_attsSize = n + nDefaultAtts + INIT_ATTS_SIZE;

    /* Detect and prevent integer overflow.
     * The preprocessor guard addresses the "always false" warning
     * from -Wtype-limits on platforms where
     * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
    if ((unsigned)parser->m_attsSize > SIZE_MAX / sizeof(ATTRIBUTE)) {
      parser->m_attsSize = oldAttsSize;
      return XML_ERROR_NO_MEMORY;
    }
#endif

    temp =
        REALLOC(parser, parser->m_atts, parser->m_attsSize * sizeof(ATTRIBUTE));
    if (temp == NULL) {
      parser->m_attsSize = oldAttsSize;
      return XML_ERROR_NO_MEMORY;
    }
    parser->m_atts = temp;
#ifdef XML_ATTR_INFO
    /* Detect and prevent integer overflow.
     * The preprocessor guard addresses the "always false" warning
     * from -Wtype-limits on platforms where
     * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
    if ((unsigned)parser->m_attsSize > SIZE_MAX / sizeof(XML_AttrInfo)) {
      parser->m_attsSize = oldAttsSize;
      return XML_ERROR_NO_MEMORY;
    }
#endif

    temp2 = REALLOC(parser, parser->m_attInfo,
                    parser->m_attsSize * sizeof(XML_AttrInfo));
    if (temp2 == NULL) {
      parser->m_attsSize = oldAttsSize;
      return XML_ERROR_NO_MEMORY;
    }
    parser->m_attInfo = temp2;
#endif
    if (n > oldAttsSize)
      XmlGetAttributes(enc, attStr, n, parser->m_atts);
  }

  appAtts = (const XML_Char **)parser->m_atts;
  for (i = 0; i < n; i++) {
    ATTRIBUTE *currAtt = &parser->m_atts[i];
#ifdef XML_ATTR_INFO
    XML_AttrInfo *currAttInfo = &parser->m_attInfo[i];
#endif
    /* add the name and value to the attribute list */
    ATTRIBUTE_ID *attId =
        getAttributeId(parser, enc, currAtt->name,
                       currAtt->name + XmlNameLength(enc, currAtt->name));
    if (!attId)
      return XML_ERROR_NO_MEMORY;
#ifdef XML_ATTR_INFO
    currAttInfo->nameStart =
        parser->m_parseEndByteIndex - (parser->m_parseEndPtr - currAtt->name);
    currAttInfo->nameEnd =
        currAttInfo->nameStart + XmlNameLength(enc, currAtt->name);
    currAttInfo->valueStart = parser->m_parseEndByteIndex -
                              (parser->m_parseEndPtr - currAtt->valuePtr);
    currAttInfo->valueEnd = parser->m_parseEndByteIndex -
                            (parser->m_parseEndPtr - currAtt->valueEnd);
#endif
    /* Detect duplicate attributes by their QNames. This does not work when
       namespace processing is turned on and different prefixes for the same
       namespace are used. For this case we have a check further down.
    */
    if ((attId->name)[-1]) {
      if (enc == parser->m_encoding)
        parser->m_eventPtr = parser->m_atts[i].name;
      return XML_ERROR_DUPLICATE_ATTRIBUTE;
    }
    (attId->name)[-1] = 1;
    appAtts[attIndex++] = attId->name;
    if (!parser->m_atts[i].normalized) {
      enum XML_Error result;
      XML_Bool isCdata = XML_TRUE;

      /* figure out whether declared as other than CDATA */
      if (attId->maybeTokenized) {
        int j;
        for (j = 0; j < nDefaultAtts; j++) {
          if (attId == elementType->defaultAtts[j].id) {
            isCdata = elementType->defaultAtts[j].isCdata;
            break;
          }
        }
      }

      /* normalize the attribute value */
      result = storeAttributeValue(
          parser, enc, isCdata, parser->m_atts[i].valuePtr,
          parser->m_atts[i].valueEnd, &parser->m_tempPool, account);
      if (result)
        return result;
      appAtts[attIndex] = poolStart(&parser->m_tempPool);
      poolFinish(&parser->m_tempPool);
    } else {
      /* the value did not need normalizing */
      appAtts[attIndex] =
          poolStoreString(&parser->m_tempPool, enc, parser->m_atts[i].valuePtr,
                          parser->m_atts[i].valueEnd);
      if (appAtts[attIndex] == 0)
        return XML_ERROR_NO_MEMORY;
      poolFinish(&parser->m_tempPool);
    }
    /* handle prefixed attribute names */
    if (attId->prefix) {
      if (attId->xmlns) {
        /* deal with namespace declarations here */
        enum XML_Error result = addBinding(parser, attId->prefix, attId,
                                           appAtts[attIndex], bindingsPtr);
        if (result)
          return result;
        --attIndex;
      } else {
        /* deal with other prefixed names later */
        attIndex++;
        nPrefixes++;
        (attId->name)[-1] = 2;
      }
    } else
      attIndex++;
  }

  /* set-up for XML_GetSpecifiedAttributeCount and XML_GetIdAttributeIndex */
  parser->m_nSpecifiedAtts = attIndex;
  if (elementType->idAtt && (elementType->idAtt->name)[-1]) {
    for (i = 0; i < attIndex; i += 2)
      if (appAtts[i] == elementType->idAtt->name) {
        parser->m_idAttIndex = i;
        break;
      }
  } else
    parser->m_idAttIndex = -1;

  /* do attribute defaulting */
  for (i = 0; i < nDefaultAtts; i++) {
    const DEFAULT_ATTRIBUTE *da = elementType->defaultAtts + i;
    if (!(da->id->name)[-1] && da->value) {
      if (da->id->prefix) {
        if (da->id->xmlns) {
          enum XML_Error result = addBinding(parser, da->id->prefix, da->id,
                                             da->value, bindingsPtr);
          if (result)
            return result;
        } else {
          (da->id->name)[-1] = 2;
          nPrefixes++;
          appAtts[attIndex++] = da->id->name;
          appAtts[attIndex++] = da->value;
        }
      } else {
        (da->id->name)[-1] = 1;
        appAtts[attIndex++] = da->id->name;
        appAtts[attIndex++] = da->value;
      }
    }
  }
  appAtts[attIndex] = 0;

  /* expand prefixed attribute names, check for duplicates,
     and clear flags that say whether attributes were specified */
  i = 0;
  if (nPrefixes) {
    unsigned int j; /* hash table index */
    unsigned long version = parser->m_nsAttsVersion;

    /* Detect and prevent invalid shift */
    if (parser->m_nsAttsPower >= sizeof(unsigned int) * 8 /* bits per byte */) {
      return XML_ERROR_NO_MEMORY;
    }

    unsigned int nsAttsSize = 1u << parser->m_nsAttsPower;
    unsigned char oldNsAttsPower = parser->m_nsAttsPower;
    /* size of hash table must be at least 2 * (# of prefixed attributes) */
    if ((nPrefixes << 1) >>
        parser->m_nsAttsPower) { /* true for m_nsAttsPower = 0 */
      NS_ATT *temp;
      /* hash table size must also be a power of 2 and >= 8 */
      while (nPrefixes >> parser->m_nsAttsPower++)
        ;
      if (parser->m_nsAttsPower < 3)
        parser->m_nsAttsPower = 3;

      /* Detect and prevent invalid shift */
      if (parser->m_nsAttsPower >= sizeof(nsAttsSize) * 8 /* bits per byte */) {
        /* Restore actual size of memory in m_nsAtts */
        parser->m_nsAttsPower = oldNsAttsPower;
        return XML_ERROR_NO_MEMORY;
      }

      nsAttsSize = 1u << parser->m_nsAttsPower;

      /* Detect and prevent integer overflow.
       * The preprocessor guard addresses the "always false" warning
       * from -Wtype-limits on platforms where
       * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
      if (nsAttsSize > SIZE_MAX / sizeof(NS_ATT)) {
        /* Restore actual size of memory in m_nsAtts */
        parser->m_nsAttsPower = oldNsAttsPower;
        return XML_ERROR_NO_MEMORY;
      }
#endif

      temp = REALLOC(parser, parser->m_nsAtts, nsAttsSize * sizeof(NS_ATT));
      if (!temp) {
        /* Restore actual size of memory in m_nsAtts */
        parser->m_nsAttsPower = oldNsAttsPower;
        return XML_ERROR_NO_MEMORY;
      }
      parser->m_nsAtts = temp;
      version = 0; /* force re-initialization of m_nsAtts hash table */
    }
    /* using a version flag saves us from initializing m_nsAtts every time */
    if (!version) { /* initialize version flags when version wraps around */
      version = INIT_ATTS_VERSION;
      for (j = nsAttsSize; j != 0;)
        parser->m_nsAtts[--j].version = version;
    }
    parser->m_nsAttsVersion = --version;

    /* expand prefixed names and check for duplicates */
    for (; i < attIndex; i += 2) {
      const XML_Char *s = appAtts[i];
      if (s[-1] == 2) { /* prefixed */
        ATTRIBUTE_ID *id;
        const BINDING *b;
        unsigned long uriHash;
        struct siphash sip_state;
        struct sipkey sip_key;

        copy_salt_to_sipkey(parser, &sip_key);
        sip24_init(&sip_state, &sip_key);

        ((XML_Char *)s)[-1] = 0; /* clear flag */
        id = (ATTRIBUTE_ID *)lookup(parser, &dtd->attributeIds, s, 0);
        if (!id || !id->prefix) {
          /* This code is walking through the appAtts array, dealing
           * with (in this case) a prefixed attribute name.  To be in
           * the array, the attribute must have already been bound, so
           * has to have passed through the hash table lookup once
           * already.  That implies that an entry for it already
           * exists, so the lookup above will return a pointer to
           * already allocated memory.  There is no opportunaity for
           * the allocator to fail, so the condition above cannot be
           * fulfilled.
           *
           * Since it is difficult to be certain that the above
           * analysis is complete, we retain the test and merely
           * remove the code from coverage tests.
           */
          return XML_ERROR_NO_MEMORY; /* LCOV_EXCL_LINE */
        }
        b = id->prefix->binding;
        if (!b)
          return XML_ERROR_UNBOUND_PREFIX;

        for (j = 0; j < (unsigned int)b->uriLen; j++) {
          const XML_Char c = b->uri[j];
          if (!poolAppendChar(&parser->m_tempPool, c))
            return XML_ERROR_NO_MEMORY;
        }

        sip24_update(&sip_state, b->uri, b->uriLen * sizeof(XML_Char));

        while (*s++ != XML_T(ASCII_COLON))
          ;

        sip24_update(&sip_state, s, keylen(s) * sizeof(XML_Char));

        do { /* copies null terminator */
          if (!poolAppendChar(&parser->m_tempPool, *s))
            return XML_ERROR_NO_MEMORY;
        } while (*s++);

        uriHash = (unsigned long)sip24_final(&sip_state);

        { /* Check hash table for duplicate of expanded name (uriName).
             Derived from code in lookup(parser, HASH_TABLE *table, ...).
          */
          unsigned char step = 0;
          unsigned long mask = nsAttsSize - 1;
          j = uriHash & mask; /* index into hash table */
          while (parser->m_nsAtts[j].version == version) {
            /* for speed we compare stored hash values first */
            if (uriHash == parser->m_nsAtts[j].hash) {
              const XML_Char *s1 = poolStart(&parser->m_tempPool);
              const XML_Char *s2 = parser->m_nsAtts[j].uriName;
              /* s1 is null terminated, but not s2 */
              for (; *s1 == *s2 && *s1 != 0; s1++, s2++)
                ;
              if (*s1 == 0)
                return XML_ERROR_DUPLICATE_ATTRIBUTE;
            }
            if (!step)
              step = PROBE_STEP(uriHash, mask, parser->m_nsAttsPower);
            j < step ? (j += nsAttsSize - step) : (j -= step);
          }
        }

        if (parser->m_ns_triplets) { /* append namespace separator and prefix */
          parser->m_tempPool.ptr[-1] = parser->m_namespaceSeparator;
          s = b->prefix->name;
          do {
            if (!poolAppendChar(&parser->m_tempPool, *s))
              return XML_ERROR_NO_MEMORY;
          } while (*s++);
        }

        /* store expanded name in attribute list */
        s = poolStart(&parser->m_tempPool);
        poolFinish(&parser->m_tempPool);
        appAtts[i] = s;

        /* fill empty slot with new version, uriName and hash value */
        parser->m_nsAtts[j].version = version;
        parser->m_nsAtts[j].hash = uriHash;
        parser->m_nsAtts[j].uriName = s;

        if (!--nPrefixes) {
          i += 2;
          break;
        }
      } else                     /* not prefixed */
        ((XML_Char *)s)[-1] = 0; /* clear flag */
    }
  }
  /* clear flags for the remaining attributes */
  for (; i < attIndex; i += 2)
    ((XML_Char *)(appAtts[i]))[-1] = 0;
  for (binding = *bindingsPtr; binding; binding = binding->nextTagBinding)
    binding->attId->name[-1] = 0;

  if (!parser->m_ns)
    return XML_ERROR_NONE;

  /* expand the element type name */
  if (elementType->prefix) {
    binding = elementType->prefix->binding;
    if (!binding)
      return XML_ERROR_UNBOUND_PREFIX;
    localPart = tagNamePtr->str;
    while (*localPart++ != XML_T(ASCII_COLON))
      ;
  } else if (dtd->defaultPrefix.binding) {
    binding = dtd->defaultPrefix.binding;
    localPart = tagNamePtr->str;
  } else
    return XML_ERROR_NONE;
  prefixLen = 0;
  if (parser->m_ns_triplets && binding->prefix->name) {
    while (binding->prefix->name[prefixLen++])
      ; /* prefixLen includes null terminator */
  }
  tagNamePtr->localPart = localPart;
  tagNamePtr->uriLen = binding->uriLen;
  tagNamePtr->prefix = binding->prefix->name;
  tagNamePtr->prefixLen = prefixLen;
  for (i = 0; localPart[i++];)
    ; /* i includes null terminator */

  /* Detect and prevent integer overflow */
  if (binding->uriLen > INT_MAX - prefixLen ||
      i > INT_MAX - (binding->uriLen + prefixLen)) {
    return XML_ERROR_NO_MEMORY;
  }

  n = i + binding->uriLen + prefixLen;
  if (n > binding->uriAlloc) {
    TAG *p;

    /* Detect and prevent integer overflow */
    if (n > INT_MAX - EXPAND_SPARE) {
      return XML_ERROR_NO_MEMORY;
    }
    /* Detect and prevent integer overflow.
     * The preprocessor guard addresses the "always false" warning
     * from -Wtype-limits on platforms where
     * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
    if ((unsigned)(n + EXPAND_SPARE) > SIZE_MAX / sizeof(XML_Char)) {
      return XML_ERROR_NO_MEMORY;
    }
#endif

    uri = MALLOC(parser, (n + EXPAND_SPARE) * sizeof(XML_Char));
    if (!uri)
      return XML_ERROR_NO_MEMORY;
    binding->uriAlloc = n + EXPAND_SPARE;
    memcpy(uri, binding->uri, binding->uriLen * sizeof(XML_Char));
    for (p = parser->m_tagStack; p; p = p->parent)
      if (p->name.str == binding->uri)
        p->name.str = uri;
    FREE(parser, binding->uri);
    binding->uri = uri;
  }
  /* if m_namespaceSeparator != '\0' then uri includes it already */
  uri = binding->uri + binding->uriLen;
  memcpy(uri, localPart, i * sizeof(XML_Char));
  /* we always have a namespace separator between localPart and prefix */
  if (prefixLen) {
    uri += i - 1;
    *uri = parser->m_namespaceSeparator; /* replace null terminator */
    memcpy(uri + 1, binding->prefix->name, prefixLen * sizeof(XML_Char));
  }
  tagNamePtr->str = binding->uri;
  return XML_ERROR_NONE;
}

static XML_Bool is_rfc3986_uri_char(XML_Char candidate) {
  // For the RFC 3986 ANBF grammar see
  // https://datatracker.ietf.org/doc/html/rfc3986#appendix-A

  switch (candidate) {
  // From rule "ALPHA" (uppercase half)
  case 'A':
  case 'B':
  case 'C':
  case 'D':
  case 'E':
  case 'F':
  case 'G':
  case 'H':
  case 'I':
  case 'J':
  case 'K':
  case 'L':
  case 'M':
  case 'N':
  case 'O':
  case 'P':
  case 'Q':
  case 'R':
  case 'S':
  case 'T':
  case 'U':
  case 'V':
  case 'W':
  case 'X':
  case 'Y':
  case 'Z':

  // From rule "ALPHA" (lowercase half)
  case 'a':
  case 'b':
  case 'c':
  case 'd':
  case 'e':
  case 'f':
  case 'g':
  case 'h':
  case 'i':
  case 'j':
  case 'k':
  case 'l':
  case 'm':
  case 'n':
  case 'o':
  case 'p':
  case 'q':
  case 'r':
  case 's':
  case 't':
  case 'u':
  case 'v':
  case 'w':
  case 'x':
  case 'y':
  case 'z':

  // From rule "DIGIT"
  case '0':
  case '1':
  case '2':
  case '3':
  case '4':
  case '5':
  case '6':
  case '7':
  case '8':
  case '9':

  // From rule "pct-encoded"
  case '%':

  // From rule "unreserved"
  case '-':
  case '.':
  case '_':
  case '~':

  // From rule "gen-delims"
  case ':':
  case '/':
  case '?':
  case '#':
  case '[':
  case ']':
  case '@':

  // From rule "sub-delims"
  case '!':
  case '$':
  case '&':
  case '\'':
  case '(':
  case ')':
  case '*':
  case '+':
  case ',':
  case ';':
  case '=':
    return XML_TRUE;

  default:
    return XML_FALSE;
  }
}

/* addBinding() overwrites the value of prefix->binding without checking.
   Therefore one must keep track of the old value outside of addBinding().
*/
static enum XML_Error addBinding(XML_Parser parser, PREFIX *prefix,
                                 const ATTRIBUTE_ID *attId, const XML_Char *uri,
                                 BINDING **bindingsPtr) {
  // "http://www.w3.org/XML/1998/namespace"
  static const XML_Char xmlNamespace[] = {
      ASCII_h,      ASCII_t,     ASCII_t,     ASCII_p,      ASCII_COLON,
      ASCII_SLASH,  ASCII_SLASH, ASCII_w,     ASCII_w,      ASCII_w,
      ASCII_PERIOD, ASCII_w,     ASCII_3,     ASCII_PERIOD, ASCII_o,
      ASCII_r,      ASCII_g,     ASCII_SLASH, ASCII_X,      ASCII_M,
      ASCII_L,      ASCII_SLASH, ASCII_1,     ASCII_9,      ASCII_9,
      ASCII_8,      ASCII_SLASH, ASCII_n,     ASCII_a,      ASCII_m,
      ASCII_e,      ASCII_s,     ASCII_p,     ASCII_a,      ASCII_c,
      ASCII_e,      '\0'};
  static const int xmlLen = (int)sizeof(xmlNamespace) / sizeof(XML_Char) - 1;
  // "http://www.w3.org/2000/xmlns/"
  static const XML_Char xmlnsNamespace[] = {
      ASCII_h,     ASCII_t,      ASCII_t, ASCII_p, ASCII_COLON,  ASCII_SLASH,
      ASCII_SLASH, ASCII_w,      ASCII_w, ASCII_w, ASCII_PERIOD, ASCII_w,
      ASCII_3,     ASCII_PERIOD, ASCII_o, ASCII_r, ASCII_g,      ASCII_SLASH,
      ASCII_2,     ASCII_0,      ASCII_0, ASCII_0, ASCII_SLASH,  ASCII_x,
      ASCII_m,     ASCII_l,      ASCII_n, ASCII_s, ASCII_SLASH,  '\0'};
  static const int xmlnsLen =
      (int)sizeof(xmlnsNamespace) / sizeof(XML_Char) - 1;

  XML_Bool mustBeXML = XML_FALSE;
  XML_Bool isXML = XML_TRUE;
  XML_Bool isXMLNS = XML_TRUE;

  BINDING *b;
  int len;

  /* empty URI is only valid for default namespace per XML NS 1.0 (not 1.1) */
  if (*uri == XML_T('\0') && prefix->name)
    return XML_ERROR_UNDECLARING_PREFIX;

  if (prefix->name && prefix->name[0] == XML_T(ASCII_x) &&
      prefix->name[1] == XML_T(ASCII_m) && prefix->name[2] == XML_T(ASCII_l)) {
    /* Not allowed to bind xmlns */
    if (prefix->name[3] == XML_T(ASCII_n) &&
        prefix->name[4] == XML_T(ASCII_s) && prefix->name[5] == XML_T('\0'))
      return XML_ERROR_RESERVED_PREFIX_XMLNS;

    if (prefix->name[3] == XML_T('\0'))
      mustBeXML = XML_TRUE;
  }

  for (len = 0; uri[len]; len++) {
    if (isXML && (len > xmlLen || uri[len] != xmlNamespace[len]))
      isXML = XML_FALSE;

    if (!mustBeXML && isXMLNS &&
        (len > xmlnsLen || uri[len] != xmlnsNamespace[len]))
      isXMLNS = XML_FALSE;

    // NOTE: While Expat does not validate namespace URIs against RFC 3986
    //       today (and is not REQUIRED to do so with regard to the XML 1.0
    //       namespaces specification) we have to at least make sure, that
    //       the application on top of Expat (that is likely splitting expanded
    //       element names ("qualified names") of form
    //       "[uri sep] local [sep prefix] '\0'" back into 1, 2 or 3 pieces
    //       in its element handler code) cannot be confused by an attacker
    //       putting additional namespace separator characters into namespace
    //       declarations.  That would be ambiguous and not to be expected.
    //
    //       While the HTML API docs of function XML_ParserCreateNS have been
    //       advising against use of a namespace separator character that can
    //       appear in a URI for >20 years now, some widespread applications
    //       are using URI characters (':' (colon) in particular) for a
    //       namespace separator, in practice.  To keep these applications
    //       functional, we only reject namespaces URIs containing the
    //       application-chosen namespace separator if the chosen separator
    //       is a non-URI character with regard to RFC 3986.
    if (parser->m_ns && (uri[len] == parser->m_namespaceSeparator) &&
        !is_rfc3986_uri_char(uri[len])) {
      return XML_ERROR_SYNTAX;
    }
  }
  isXML = isXML && len == xmlLen;
  isXMLNS = isXMLNS && len == xmlnsLen;

  if (mustBeXML != isXML)
    return mustBeXML ? XML_ERROR_RESERVED_PREFIX_XML
                     : XML_ERROR_RESERVED_NAMESPACE_URI;

  if (isXMLNS)
    return XML_ERROR_RESERVED_NAMESPACE_URI;

  if (parser->m_namespaceSeparator)
    len++;
  if (parser->m_freeBindingList) {
    b = parser->m_freeBindingList;
    if (len > b->uriAlloc) {
      /* Detect and prevent integer overflow */
      if (len > INT_MAX - EXPAND_SPARE) {
        return XML_ERROR_NO_MEMORY;
      }

      /* Detect and prevent integer overflow.
       * The preprocessor guard addresses the "always false" warning
       * from -Wtype-limits on platforms where
       * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
      if ((unsigned)(len + EXPAND_SPARE) > SIZE_MAX / sizeof(XML_Char)) {
        return XML_ERROR_NO_MEMORY;
      }
#endif

      XML_Char *temp =
          REALLOC(parser, b->uri, sizeof(XML_Char) * (len + EXPAND_SPARE));
      if (temp == NULL)
        return XML_ERROR_NO_MEMORY;
      b->uri = temp;
      b->uriAlloc = len + EXPAND_SPARE;
    }
    parser->m_freeBindingList = b->nextTagBinding;
  } else {
    b = MALLOC(parser, sizeof(BINDING));
    if (!b)
      return XML_ERROR_NO_MEMORY;

    /* Detect and prevent integer overflow */
    if (len > INT_MAX - EXPAND_SPARE) {
      return XML_ERROR_NO_MEMORY;
    }
    /* Detect and prevent integer overflow.
     * The preprocessor guard addresses the "always false" warning
     * from -Wtype-limits on platforms where
     * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
    if ((unsigned)(len + EXPAND_SPARE) > SIZE_MAX / sizeof(XML_Char)) {
      return XML_ERROR_NO_MEMORY;
    }
#endif

    b->uri = MALLOC(parser, sizeof(XML_Char) * (len + EXPAND_SPARE));
    if (!b->uri) {
      FREE(parser, b);
      return XML_ERROR_NO_MEMORY;
    }
    b->uriAlloc = len + EXPAND_SPARE;
  }
  b->uriLen = len;
  memcpy(b->uri, uri, len * sizeof(XML_Char));
  if (parser->m_namespaceSeparator)
    b->uri[len - 1] = parser->m_namespaceSeparator;
  b->prefix = prefix;
  b->attId = attId;
  b->prevPrefixBinding = prefix->binding;
  /* NULL binding when default namespace undeclared */
  if (*uri == XML_T('\0') && prefix == &parser->m_dtd->defaultPrefix)
    prefix->binding = NULL;
  else
    prefix->binding = b;
  b->nextTagBinding = *bindingsPtr;
  *bindingsPtr = b;
  /* if attId == NULL then we are not starting a namespace scope */
  if (attId && parser->m_startNamespaceDeclHandler)
    parser->m_startNamespaceDeclHandler(parser->m_handlerArg, prefix->name,
                                        prefix->binding ? uri : 0);
  return XML_ERROR_NONE;
}

/* The idea here is to avoid using stack for each CDATA section when
   the whole file is parsed with one call.
*/
static enum XML_Error PTRCALL cdataSectionProcessor(XML_Parser parser,
                                                    const char *start,
                                                    const char *end,
                                                    const char **endPtr) {
  enum XML_Error result = doCdataSection(
      parser, parser->m_encoding, &start, end, endPtr,
      (XML_Bool)!parser->m_parsingStatus.finalBuffer, XML_ACCOUNT_DIRECT);
  if (result != XML_ERROR_NONE)
    return result;
  if (start) {
    if (parser->m_parentParser) { /* we are parsing an external entity */
      parser->m_processor = externalEntityContentProcessor;
      return externalEntityContentProcessor(parser, start, end, endPtr);
    } else {
      parser->m_processor = contentProcessor;
      return contentProcessor(parser, start, end, endPtr);
    }
  }
  return result;
}

/* startPtr gets set to non-null if the section is closed, and to null if
   the section is not yet closed.
*/
static enum XML_Error doCdataSection(XML_Parser parser, const ENCODING *enc,
                                     const char **startPtr, const char *end,
                                     const char **nextPtr, XML_Bool haveMore,
                                     enum XML_Account account) {
  const char *s = *startPtr;
  const char **eventPP;
  const char **eventEndPP;
  if (enc == parser->m_encoding) {
    eventPP = &parser->m_eventPtr;
    *eventPP = s;
    eventEndPP = &parser->m_eventEndPtr;
  } else {
    eventPP = &(parser->m_openInternalEntities->internalEventPtr);
    eventEndPP = &(parser->m_openInternalEntities->internalEventEndPtr);
  }
  *eventPP = s;
  *startPtr = NULL;

  for (;;) {
    const char *next = s; /* in case of XML_TOK_NONE or XML_TOK_PARTIAL */
    int tok = XmlCdataSectionTok(enc, s, end, &next);
#if XML_GE == 1
    if (!accountingDiffTolerated(parser, tok, s, next, __LINE__, account)) {
      accountingOnAbort(parser);
      return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
    }
#else
    UNUSED_P(account);
#endif
    *eventEndPP = next;
    switch (tok) {
    case XML_TOK_CDATA_SECT_CLOSE:
      if (parser->m_endCdataSectionHandler)
        parser->m_endCdataSectionHandler(parser->m_handlerArg);
      /* BEGIN disabled code */
      /* see comment under XML_TOK_CDATA_SECT_OPEN */
      else if ((0) && parser->m_characterDataHandler)
        parser->m_characterDataHandler(parser->m_handlerArg, parser->m_dataBuf,
                                       0);
      /* END disabled code */
      else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
      *startPtr = next;
      *nextPtr = next;
      if (parser->m_parsingStatus.parsing == XML_FINISHED)
        return XML_ERROR_ABORTED;
      else
        return XML_ERROR_NONE;
    case XML_TOK_DATA_NEWLINE:
      if (parser->m_characterDataHandler) {
        XML_Char c = 0xA;
        parser->m_characterDataHandler(parser->m_handlerArg, &c, 1);
      } else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
      break;
    case XML_TOK_DATA_CHARS: {
      XML_CharacterDataHandler charDataHandler = parser->m_characterDataHandler;
      if (charDataHandler) {
        if (MUST_CONVERT(enc, s)) {
          for (;;) {
            ICHAR *dataPtr = (ICHAR *)parser->m_dataBuf;
            const enum XML_Convert_Result convert_res = XmlConvert(
                enc, &s, next, &dataPtr, (ICHAR *)parser->m_dataBufEnd);
            *eventEndPP = next;
            charDataHandler(parser->m_handlerArg, parser->m_dataBuf,
                            (int)(dataPtr - (ICHAR *)parser->m_dataBuf));
            if ((convert_res == XML_CONVERT_COMPLETED) ||
                (convert_res == XML_CONVERT_INPUT_INCOMPLETE))
              break;
            *eventPP = s;
          }
        } else
          charDataHandler(parser->m_handlerArg, (const XML_Char *)s,
                          (int)((const XML_Char *)next - (const XML_Char *)s));
      } else if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
    } break;
    case XML_TOK_INVALID:
      *eventPP = next;
      return XML_ERROR_INVALID_TOKEN;
    case XML_TOK_PARTIAL_CHAR:
      if (haveMore) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      return XML_ERROR_PARTIAL_CHAR;
    case XML_TOK_PARTIAL:
    case XML_TOK_NONE:
      if (haveMore) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      return XML_ERROR_UNCLOSED_CDATA_SECTION;
    default:
      /* Every token returned by XmlCdataSectionTok() has its own
       * explicit case, so this default case will never be executed.
       * We retain it as a safety net and exclude it from the coverage
       * statistics.
       *
       * LCOV_EXCL_START
       */
      *eventPP = next;
      return XML_ERROR_UNEXPECTED_STATE;
      /* LCOV_EXCL_STOP */
    }

    switch (parser->m_parsingStatus.parsing) {
    case XML_SUSPENDED:
      *eventPP = next;
      *nextPtr = next;
      return XML_ERROR_NONE;
    case XML_FINISHED:
      *eventPP = next;
      return XML_ERROR_ABORTED;
    case XML_PARSING:
      if (parser->m_reenter) {
        return XML_ERROR_UNEXPECTED_STATE; // LCOV_EXCL_LINE
      }
      /* Fall through */
    default:;
      *eventPP = s = next;
    }
  }
  /* not reached */
}

#ifdef XML_DTD

/* The idea here is to avoid using stack for each IGNORE section when
   the whole file is parsed with one call.
*/
static enum XML_Error PTRCALL ignoreSectionProcessor(XML_Parser parser,
                                                     const char *start,
                                                     const char *end,
                                                     const char **endPtr) {
  enum XML_Error result =
      doIgnoreSection(parser, parser->m_encoding, &start, end, endPtr,
                      (XML_Bool)!parser->m_parsingStatus.finalBuffer);
  if (result != XML_ERROR_NONE)
    return result;
  if (start) {
    parser->m_processor = prologProcessor;
    return prologProcessor(parser, start, end, endPtr);
  }
  return result;
}

/* startPtr gets set to non-null is the section is closed, and to null
   if the section is not yet closed.
*/
static enum XML_Error doIgnoreSection(XML_Parser parser, const ENCODING *enc,
                                      const char **startPtr, const char *end,
                                      const char **nextPtr, XML_Bool haveMore) {
  const char *next = *startPtr; /* in case of XML_TOK_NONE or XML_TOK_PARTIAL */
  int tok;
  const char *s = *startPtr;
  const char **eventPP;
  const char **eventEndPP;
  if (enc == parser->m_encoding) {
    eventPP = &parser->m_eventPtr;
    *eventPP = s;
    eventEndPP = &parser->m_eventEndPtr;
  } else {
    /* It's not entirely clear, but it seems the following two lines
     * of code cannot be executed.  The only occasions on which 'enc'
     * is not 'encoding' are when this function is called
     * from the internal entity processing, and IGNORE sections are an
     * error in internal entities.
     *
     * Since it really isn't clear that this is true, we keep the code
     * and just remove it from our coverage tests.
     *
     * LCOV_EXCL_START
     */
    eventPP = &(parser->m_openInternalEntities->internalEventPtr);
    eventEndPP = &(parser->m_openInternalEntities->internalEventEndPtr);
    /* LCOV_EXCL_STOP */
  }
  *eventPP = s;
  *startPtr = NULL;
  tok = XmlIgnoreSectionTok(enc, s, end, &next);
#if XML_GE == 1
  if (!accountingDiffTolerated(parser, tok, s, next, __LINE__,
                               XML_ACCOUNT_DIRECT)) {
    accountingOnAbort(parser);
    return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
  }
#endif
  *eventEndPP = next;
  switch (tok) {
  case XML_TOK_IGNORE_SECT:
    if (parser->m_defaultHandler)
      reportDefault(parser, enc, s, next);
    *startPtr = next;
    *nextPtr = next;
    if (parser->m_parsingStatus.parsing == XML_FINISHED)
      return XML_ERROR_ABORTED;
    else
      return XML_ERROR_NONE;
  case XML_TOK_INVALID:
    *eventPP = next;
    return XML_ERROR_INVALID_TOKEN;
  case XML_TOK_PARTIAL_CHAR:
    if (haveMore) {
      *nextPtr = s;
      return XML_ERROR_NONE;
    }
    return XML_ERROR_PARTIAL_CHAR;
  case XML_TOK_PARTIAL:
  case XML_TOK_NONE:
    if (haveMore) {
      *nextPtr = s;
      return XML_ERROR_NONE;
    }
    return XML_ERROR_SYNTAX; /* XML_ERROR_UNCLOSED_IGNORE_SECTION */
  default:
    /* All of the tokens that XmlIgnoreSectionTok() returns have
     * explicit cases to handle them, so this default case is never
     * executed.  We keep it as a safety net anyway, and remove it
     * from our test coverage statistics.
     *
     * LCOV_EXCL_START
     */
    *eventPP = next;
    return XML_ERROR_UNEXPECTED_STATE;
    /* LCOV_EXCL_STOP */
  }
  /* not reached */
}

#endif /* XML_DTD */

static enum XML_Error initializeEncoding(XML_Parser parser) {
  const char *s;
#ifdef XML_UNICODE
  char encodingBuf[128];
  /* See comments about `protocolEncodingName` in parserInit() */
  if (!parser->m_protocolEncodingName)
    s = NULL;
  else {
    int i;
    for (i = 0; parser->m_protocolEncodingName[i]; i++) {
      if (i == sizeof(encodingBuf) - 1 ||
          (parser->m_protocolEncodingName[i] & ~0x7f) != 0) {
        encodingBuf[0] = '\0';
        break;
      }
      encodingBuf[i] = (char)parser->m_protocolEncodingName[i];
    }
    encodingBuf[i] = '\0';
    s = encodingBuf;
  }
#else
  s = parser->m_protocolEncodingName;
#endif
  if ((parser->m_ns ? XmlInitEncodingNS : XmlInitEncoding)(
          &parser->m_initEncoding, &parser->m_encoding, s))
    return XML_ERROR_NONE;
  return handleUnknownEncoding(parser, parser->m_protocolEncodingName);
}

static enum XML_Error processXmlDecl(XML_Parser parser, int isGeneralTextEntity,
                                     const char *s, const char *next) {
  const char *encodingName = NULL;
  const XML_Char *storedEncName = NULL;
  const ENCODING *newEncoding = NULL;
  const char *version = NULL;
  const char *versionend = NULL;
  const XML_Char *storedversion = NULL;
  int standalone = -1;

#if XML_GE == 1
  if (!accountingDiffTolerated(parser, XML_TOK_XML_DECL, s, next, __LINE__,
                               XML_ACCOUNT_DIRECT)) {
    accountingOnAbort(parser);
    return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
  }
#endif

  if (!(parser->m_ns ? XmlParseXmlDeclNS : XmlParseXmlDecl)(
          isGeneralTextEntity, parser->m_encoding, s, next, &parser->m_eventPtr,
          &version, &versionend, &encodingName, &newEncoding, &standalone)) {
    if (isGeneralTextEntity)
      return XML_ERROR_TEXT_DECL;
    else
      return XML_ERROR_XML_DECL;
  }
  if (!isGeneralTextEntity && standalone == 1) {
    parser->m_dtd->standalone = XML_TRUE;
#ifdef XML_DTD
    if (parser->m_paramEntityParsing ==
        XML_PARAM_ENTITY_PARSING_UNLESS_STANDALONE)
      parser->m_paramEntityParsing = XML_PARAM_ENTITY_PARSING_NEVER;
#endif /* XML_DTD */
  }
  if (parser->m_xmlDeclHandler) {
    if (encodingName != NULL) {
      storedEncName = poolStoreString(
          &parser->m_temp2Pool, parser->m_encoding, encodingName,
          encodingName + XmlNameLength(parser->m_encoding, encodingName));
      if (!storedEncName)
        return XML_ERROR_NO_MEMORY;
      poolFinish(&parser->m_temp2Pool);
    }
    if (version) {
      storedversion =
          poolStoreString(&parser->m_temp2Pool, parser->m_encoding, version,
                          versionend - parser->m_encoding->minBytesPerChar);
      if (!storedversion)
        return XML_ERROR_NO_MEMORY;
    }
    parser->m_xmlDeclHandler(parser->m_handlerArg, storedversion, storedEncName,
                             standalone);
  } else if (parser->m_defaultHandler)
    reportDefault(parser, parser->m_encoding, s, next);
  if (parser->m_protocolEncodingName == NULL) {
    if (newEncoding) {
      /* Check that the specified encoding does not conflict with what
       * the parser has already deduced.  Do we have the same number
       * of bytes in the smallest representation of a character?  If
       * this is UTF-16, is it the same endianness?
       */
      if (newEncoding->minBytesPerChar != parser->m_encoding->minBytesPerChar ||
          (newEncoding->minBytesPerChar == 2 &&
           newEncoding != parser->m_encoding)) {
        parser->m_eventPtr = encodingName;
        return XML_ERROR_INCORRECT_ENCODING;
      }
      parser->m_encoding = newEncoding;
    } else if (encodingName) {
      enum XML_Error result;
      if (!storedEncName) {
        storedEncName = poolStoreString(
            &parser->m_temp2Pool, parser->m_encoding, encodingName,
            encodingName + XmlNameLength(parser->m_encoding, encodingName));
        if (!storedEncName)
          return XML_ERROR_NO_MEMORY;
      }
      result = handleUnknownEncoding(parser, storedEncName);
      poolClear(&parser->m_temp2Pool);
      if (result == XML_ERROR_UNKNOWN_ENCODING)
        parser->m_eventPtr = encodingName;
      return result;
    }
  }

  if (storedEncName || storedversion)
    poolClear(&parser->m_temp2Pool);

  return XML_ERROR_NONE;
}

static enum XML_Error handleUnknownEncoding(XML_Parser parser,
                                            const XML_Char *encodingName) {
  if (parser->m_unknownEncodingHandler) {
    XML_Encoding info;
    int i;
    for (i = 0; i < 256; i++)
      info.map[i] = -1;
    info.convert = NULL;
    info.data = NULL;
    info.release = NULL;
    if (parser->m_unknownEncodingHandler(parser->m_unknownEncodingHandlerData,
                                         encodingName, &info)) {
      ENCODING *enc;
      parser->m_unknownEncodingMem = MALLOC(parser, XmlSizeOfUnknownEncoding());
      if (!parser->m_unknownEncodingMem) {
        if (info.release)
          info.release(info.data);
        return XML_ERROR_NO_MEMORY;
      }
      enc = (parser->m_ns ? XmlInitUnknownEncodingNS : XmlInitUnknownEncoding)(
          parser->m_unknownEncodingMem, info.map, info.convert, info.data);
      if (enc) {
        parser->m_unknownEncodingData = info.data;
        parser->m_unknownEncodingRelease = info.release;
        parser->m_encoding = enc;
        return XML_ERROR_NONE;
      }
    }
    if (info.release != NULL)
      info.release(info.data);
  }
  return XML_ERROR_UNKNOWN_ENCODING;
}

static enum XML_Error PTRCALL prologInitProcessor(XML_Parser parser,
                                                  const char *s,
                                                  const char *end,
                                                  const char **nextPtr) {
  enum XML_Error result = initializeEncoding(parser);
  if (result != XML_ERROR_NONE)
    return result;
  parser->m_processor = prologProcessor;
  return prologProcessor(parser, s, end, nextPtr);
}

#ifdef XML_DTD

static enum XML_Error PTRCALL externalParEntInitProcessor(
    XML_Parser parser, const char *s, const char *end, const char **nextPtr) {
  enum XML_Error result = initializeEncoding(parser);
  if (result != XML_ERROR_NONE)
    return result;

  /* we know now that XML_Parse(Buffer) has been called,
     so we consider the external parameter entity read */
  parser->m_dtd->paramEntityRead = XML_TRUE;

  if (parser->m_prologState.inEntityValue) {
    parser->m_processor = entityValueInitProcessor;
    return entityValueInitProcessor(parser, s, end, nextPtr);
  } else {
    parser->m_processor = externalParEntProcessor;
    return externalParEntProcessor(parser, s, end, nextPtr);
  }
}

static enum XML_Error PTRCALL entityValueInitProcessor(XML_Parser parser,
                                                       const char *s,
                                                       const char *end,
                                                       const char **nextPtr) {
  int tok;
  const char *start = s;
  const char *next = start;
  parser->m_eventPtr = start;

  for (;;) {
    tok = XmlPrologTok(parser->m_encoding, start, end, &next);
    /* Note: Except for XML_TOK_BOM below, these bytes are accounted later in:
             - storeEntityValue
             - processXmlDecl
    */
    parser->m_eventEndPtr = next;
    if (tok <= 0) {
      if (!parser->m_parsingStatus.finalBuffer && tok != XML_TOK_INVALID) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      switch (tok) {
      case XML_TOK_INVALID:
        return XML_ERROR_INVALID_TOKEN;
      case XML_TOK_PARTIAL:
        return XML_ERROR_UNCLOSED_TOKEN;
      case XML_TOK_PARTIAL_CHAR:
        return XML_ERROR_PARTIAL_CHAR;
      case XML_TOK_NONE: /* start == end */
      default:
        break;
      }
      /* found end of entity value - can store it now */
      return storeEntityValue(parser, parser->m_encoding, s, end,
                              XML_ACCOUNT_DIRECT, NULL);
    } else if (tok == XML_TOK_XML_DECL) {
      enum XML_Error result;
      result = processXmlDecl(parser, 0, start, next);
      if (result != XML_ERROR_NONE)
        return result;
      /* At this point, m_parsingStatus.parsing cannot be XML_SUSPENDED.  For
       * that to happen, a parameter entity parsing handler must have attempted
       * to suspend the parser, which fails and raises an error.  The parser can
       * be aborted, but can't be suspended.
       */
      if (parser->m_parsingStatus.parsing == XML_FINISHED)
        return XML_ERROR_ABORTED;
      *nextPtr = next;
      /* stop scanning for text declaration - we found one */
      parser->m_processor = entityValueProcessor;
      return entityValueProcessor(parser, next, end, nextPtr);
    }
    /* XmlPrologTok has now set the encoding based on the BOM it found, and we
       must move s and nextPtr forward to consume the BOM.

       If we didn't, and got XML_TOK_NONE from the next XmlPrologTok call, we
       would leave the BOM in the buffer and return. On the next call to this
       function, our XmlPrologTok call would return XML_TOK_INVALID, since it
       is not valid to have multiple BOMs.
    */
    else if (tok == XML_TOK_BOM) {
#if XML_GE == 1
      if (!accountingDiffTolerated(parser, tok, s, next, __LINE__,
                                   XML_ACCOUNT_DIRECT)) {
        accountingOnAbort(parser);
        return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
      }
#endif

      *nextPtr = next;
      s = next;
    }
    /* If we get this token, we have the start of what might be a
       normal tag, but not a declaration (i.e. it doesn't begin with
       "<!").  In a DTD context, that isn't legal.
    */
    else if (tok == XML_TOK_INSTANCE_START) {
      *nextPtr = next;
      return XML_ERROR_SYNTAX;
    }
    start = next;
    parser->m_eventPtr = start;
  }
}

static enum XML_Error PTRCALL externalParEntProcessor(XML_Parser parser,
                                                      const char *s,
                                                      const char *end,
                                                      const char **nextPtr) {
  const char *next = s;
  int tok;

  tok = XmlPrologTok(parser->m_encoding, s, end, &next);
  if (tok <= 0) {
    if (!parser->m_parsingStatus.finalBuffer && tok != XML_TOK_INVALID) {
      *nextPtr = s;
      return XML_ERROR_NONE;
    }
    switch (tok) {
    case XML_TOK_INVALID:
      return XML_ERROR_INVALID_TOKEN;
    case XML_TOK_PARTIAL:
      return XML_ERROR_UNCLOSED_TOKEN;
    case XML_TOK_PARTIAL_CHAR:
      return XML_ERROR_PARTIAL_CHAR;
    case XML_TOK_NONE: /* start == end */
    default:
      break;
    }
  }
  /* This would cause the next stage, i.e. doProlog to be passed XML_TOK_BOM.
     However, when parsing an external subset, doProlog will not accept a BOM
     as valid, and report a syntax error, so we have to skip the BOM, and
     account for the BOM bytes.
  */
  else if (tok == XML_TOK_BOM) {
    if (!accountingDiffTolerated(parser, tok, s, next, __LINE__,
                                 XML_ACCOUNT_DIRECT)) {
      accountingOnAbort(parser);
      return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
    }

    s = next;
    tok = XmlPrologTok(parser->m_encoding, s, end, &next);
  }

  parser->m_processor = prologProcessor;
  return doProlog(parser, parser->m_encoding, s, end, tok, next, nextPtr,
                  (XML_Bool)!parser->m_parsingStatus.finalBuffer, XML_TRUE,
                  XML_ACCOUNT_DIRECT);
}

static enum XML_Error PTRCALL entityValueProcessor(XML_Parser parser,
                                                   const char *s,
                                                   const char *end,
                                                   const char **nextPtr) {
  const char *start = s;
  const char *next = s;
  const ENCODING *enc = parser->m_encoding;
  int tok;

  for (;;) {
    tok = XmlPrologTok(enc, start, end, &next);
    /* Note: These bytes are accounted later in:
             - storeEntityValue
    */
    if (tok <= 0) {
      if (!parser->m_parsingStatus.finalBuffer && tok != XML_TOK_INVALID) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      switch (tok) {
      case XML_TOK_INVALID:
        return XML_ERROR_INVALID_TOKEN;
      case XML_TOK_PARTIAL:
        return XML_ERROR_UNCLOSED_TOKEN;
      case XML_TOK_PARTIAL_CHAR:
        return XML_ERROR_PARTIAL_CHAR;
      case XML_TOK_NONE: /* start == end */
      default:
        break;
      }
      /* found end of entity value - can store it now */
      return storeEntityValue(parser, enc, s, end, XML_ACCOUNT_DIRECT, NULL);
    }
    start = next;
  }
}

#endif /* XML_DTD */

static enum XML_Error PTRCALL prologProcessor(XML_Parser parser, const char *s,
                                              const char *end,
                                              const char **nextPtr) {
  const char *next = s;
  int tok = XmlPrologTok(parser->m_encoding, s, end, &next);
  return doProlog(parser, parser->m_encoding, s, end, tok, next, nextPtr,
                  (XML_Bool)!parser->m_parsingStatus.finalBuffer, XML_TRUE,
                  XML_ACCOUNT_DIRECT);
}

static enum XML_Error doProlog(XML_Parser parser, const ENCODING *enc,
                               const char *s, const char *end, int tok,
                               const char *next, const char **nextPtr,
                               XML_Bool haveMore, XML_Bool allowClosingDoctype,
                               enum XML_Account account) {
#ifdef XML_DTD
  static const XML_Char externalSubsetName[] = {ASCII_HASH, '\0'};
#endif /* XML_DTD */
  static const XML_Char atypeCDATA[] = {ASCII_C, ASCII_D, ASCII_A,
                                        ASCII_T, ASCII_A, '\0'};
  static const XML_Char atypeID[] = {ASCII_I, ASCII_D, '\0'};
  static const XML_Char atypeIDREF[] = {ASCII_I, ASCII_D, ASCII_R,
                                        ASCII_E, ASCII_F, '\0'};
  static const XML_Char atypeIDREFS[] = {ASCII_I, ASCII_D, ASCII_R, ASCII_E,
                                         ASCII_F, ASCII_S, '\0'};
  static const XML_Char atypeENTITY[] = {ASCII_E, ASCII_N, ASCII_T, ASCII_I,
                                         ASCII_T, ASCII_Y, '\0'};
  static const XML_Char atypeENTITIES[] = {ASCII_E, ASCII_N, ASCII_T,
                                           ASCII_I, ASCII_T, ASCII_I,
                                           ASCII_E, ASCII_S, '\0'};
  static const XML_Char atypeNMTOKEN[] = {ASCII_N, ASCII_M, ASCII_T, ASCII_O,
                                          ASCII_K, ASCII_E, ASCII_N, '\0'};
  static const XML_Char atypeNMTOKENS[] = {ASCII_N, ASCII_M, ASCII_T,
                                           ASCII_O, ASCII_K, ASCII_E,
                                           ASCII_N, ASCII_S, '\0'};
  static const XML_Char notationPrefix[] = {
      ASCII_N, ASCII_O, ASCII_T, ASCII_A,      ASCII_T,
      ASCII_I, ASCII_O, ASCII_N, ASCII_LPAREN, '\0'};
  static const XML_Char enumValueSep[] = {ASCII_PIPE, '\0'};
  static const XML_Char enumValueStart[] = {ASCII_LPAREN, '\0'};

#ifndef XML_DTD
  UNUSED_P(account);
#endif

  /* save one level of indirection */
  DTD *const dtd = parser->m_dtd;

  const char **eventPP;
  const char **eventEndPP;
  enum XML_Content_Quant quant;

  if (enc == parser->m_encoding) {
    eventPP = &parser->m_eventPtr;
    eventEndPP = &parser->m_eventEndPtr;
  } else {
    eventPP = &(parser->m_openInternalEntities->internalEventPtr);
    eventEndPP = &(parser->m_openInternalEntities->internalEventEndPtr);
  }

  for (;;) {
    int role;
    XML_Bool handleDefault = XML_TRUE;
    *eventPP = s;
    *eventEndPP = next;
    if (tok <= 0) {
      if (haveMore && tok != XML_TOK_INVALID) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      switch (tok) {
      case XML_TOK_INVALID:
        *eventPP = next;
        return XML_ERROR_INVALID_TOKEN;
      case XML_TOK_PARTIAL:
        return XML_ERROR_UNCLOSED_TOKEN;
      case XML_TOK_PARTIAL_CHAR:
        return XML_ERROR_PARTIAL_CHAR;
      case -XML_TOK_PROLOG_S:
        tok = -tok;
        break;
      case XML_TOK_NONE:
#ifdef XML_DTD
        /* for internal PE NOT referenced between declarations */
        if (enc != parser->m_encoding &&
            !parser->m_openInternalEntities->betweenDecl) {
          *nextPtr = s;
          return XML_ERROR_NONE;
        }
        /* WFC: PE Between Declarations - must check that PE contains
           complete markup, not only for external PEs, but also for
           internal PEs if the reference occurs between declarations.
        */
        if (parser->m_isParamEntity || enc != parser->m_encoding) {
          if (XmlTokenRole(&parser->m_prologState, XML_TOK_NONE, end, end,
                           enc) == XML_ROLE_ERROR)
            return XML_ERROR_INCOMPLETE_PE;
          *nextPtr = s;
          return XML_ERROR_NONE;
        }
#endif /* XML_DTD */
        return XML_ERROR_NO_ELEMENTS;
      default:
        tok = -tok;
        next = end;
        break;
      }
    }
    role = XmlTokenRole(&parser->m_prologState, tok, s, next, enc);
#if XML_GE == 1
    switch (role) {
    case XML_ROLE_INSTANCE_START: // bytes accounted in contentProcessor
    case XML_ROLE_XML_DECL:       // bytes accounted in processXmlDecl
#ifdef XML_DTD
    case XML_ROLE_TEXT_DECL: // bytes accounted in processXmlDecl
#endif
      break;
    default:
      if (!accountingDiffTolerated(parser, tok, s, next, __LINE__, account)) {
        accountingOnAbort(parser);
        return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
      }
    }
#endif
    switch (role) {
    case XML_ROLE_XML_DECL: {
      enum XML_Error result = processXmlDecl(parser, 0, s, next);
      if (result != XML_ERROR_NONE)
        return result;
      enc = parser->m_encoding;
      handleDefault = XML_FALSE;
    } break;
    case XML_ROLE_DOCTYPE_NAME:
      if (parser->m_startDoctypeDeclHandler) {
        parser->m_doctypeName =
            poolStoreString(&parser->m_tempPool, enc, s, next);
        if (!parser->m_doctypeName)
          return XML_ERROR_NO_MEMORY;
        poolFinish(&parser->m_tempPool);
        parser->m_doctypePubid = NULL;
        handleDefault = XML_FALSE;
      }
      parser->m_doctypeSysid = NULL; /* always initialize to NULL */
      break;
    case XML_ROLE_DOCTYPE_INTERNAL_SUBSET:
      if (parser->m_startDoctypeDeclHandler) {
        parser->m_startDoctypeDeclHandler(
            parser->m_handlerArg, parser->m_doctypeName, parser->m_doctypeSysid,
            parser->m_doctypePubid, 1);
        parser->m_doctypeName = NULL;
        poolClear(&parser->m_tempPool);
        handleDefault = XML_FALSE;
      }
      break;
#ifdef XML_DTD
    case XML_ROLE_TEXT_DECL: {
      enum XML_Error result = processXmlDecl(parser, 1, s, next);
      if (result != XML_ERROR_NONE)
        return result;
      enc = parser->m_encoding;
      handleDefault = XML_FALSE;
    } break;
#endif /* XML_DTD */
    case XML_ROLE_DOCTYPE_PUBLIC_ID:
#ifdef XML_DTD
      parser->m_useForeignDTD = XML_FALSE;
      parser->m_declEntity = (ENTITY *)lookup(
          parser, &dtd->paramEntities, externalSubsetName, sizeof(ENTITY));
      if (!parser->m_declEntity)
        return XML_ERROR_NO_MEMORY;
#endif /* XML_DTD */
      dtd->hasParamEntityRefs = XML_TRUE;
      if (parser->m_startDoctypeDeclHandler) {
        XML_Char *pubId;
        if (!XmlIsPublicId(enc, s, next, eventPP))
          return XML_ERROR_PUBLICID;
        pubId =
            poolStoreString(&parser->m_tempPool, enc, s + enc->minBytesPerChar,
                            next - enc->minBytesPerChar);
        if (!pubId)
          return XML_ERROR_NO_MEMORY;
        normalizePublicId(pubId);
        poolFinish(&parser->m_tempPool);
        parser->m_doctypePubid = pubId;
        handleDefault = XML_FALSE;
        goto alreadyChecked;
      }
      /* fall through */
    case XML_ROLE_ENTITY_PUBLIC_ID:
      if (!XmlIsPublicId(enc, s, next, eventPP))
        return XML_ERROR_PUBLICID;
    alreadyChecked:
      if (dtd->keepProcessing && parser->m_declEntity) {
        XML_Char *tem =
            poolStoreString(&dtd->pool, enc, s + enc->minBytesPerChar,
                            next - enc->minBytesPerChar);
        if (!tem)
          return XML_ERROR_NO_MEMORY;
        normalizePublicId(tem);
        parser->m_declEntity->publicId = tem;
        poolFinish(&dtd->pool);
        /* Don't suppress the default handler if we fell through from
         * the XML_ROLE_DOCTYPE_PUBLIC_ID case.
         */
        if (parser->m_entityDeclHandler && role == XML_ROLE_ENTITY_PUBLIC_ID)
          handleDefault = XML_FALSE;
      }
      break;
    case XML_ROLE_DOCTYPE_CLOSE:
      if (allowClosingDoctype != XML_TRUE) {
        /* Must not close doctype from within expanded parameter entities */
        return XML_ERROR_INVALID_TOKEN;
      }

      if (parser->m_doctypeName) {
        parser->m_startDoctypeDeclHandler(
            parser->m_handlerArg, parser->m_doctypeName, parser->m_doctypeSysid,
            parser->m_doctypePubid, 0);
        poolClear(&parser->m_tempPool);
        handleDefault = XML_FALSE;
      }
      /* parser->m_doctypeSysid will be non-NULL in the case of a previous
         XML_ROLE_DOCTYPE_SYSTEM_ID, even if parser->m_startDoctypeDeclHandler
         was not set, indicating an external subset
      */
#ifdef XML_DTD
      if (parser->m_doctypeSysid || parser->m_useForeignDTD) {
        XML_Bool hadParamEntityRefs = dtd->hasParamEntityRefs;
        dtd->hasParamEntityRefs = XML_TRUE;
        if (parser->m_paramEntityParsing &&
            parser->m_externalEntityRefHandler) {
          ENTITY *entity = (ENTITY *)lookup(parser, &dtd->paramEntities,
                                            externalSubsetName, sizeof(ENTITY));
          if (!entity) {
            /* The external subset name "#" will have already been
             * inserted into the hash table at the start of the
             * external entity parsing, so no allocation will happen
             * and lookup() cannot fail.
             */
            return XML_ERROR_NO_MEMORY; /* LCOV_EXCL_LINE */
          }
          if (parser->m_useForeignDTD)
            entity->base = parser->m_curBase;
          dtd->paramEntityRead = XML_FALSE;
          if (!parser->m_externalEntityRefHandler(
                  parser->m_externalEntityRefHandlerArg, 0, entity->base,
                  entity->systemId, entity->publicId))
            return XML_ERROR_EXTERNAL_ENTITY_HANDLING;
          if (dtd->paramEntityRead) {
            if (!dtd->standalone && parser->m_notStandaloneHandler &&
                !parser->m_notStandaloneHandler(parser->m_handlerArg))
              return XML_ERROR_NOT_STANDALONE;
          }
          /* if we didn't read the foreign DTD then this means that there
             is no external subset and we must reset dtd->hasParamEntityRefs
          */
          else if (!parser->m_doctypeSysid)
            dtd->hasParamEntityRefs = hadParamEntityRefs;
          /* end of DTD - no need to update dtd->keepProcessing */
        }
        parser->m_useForeignDTD = XML_FALSE;
      }
#endif /* XML_DTD */
      if (parser->m_endDoctypeDeclHandler) {
        parser->m_endDoctypeDeclHandler(parser->m_handlerArg);
        handleDefault = XML_FALSE;
      }
      break;
    case XML_ROLE_INSTANCE_START:
#ifdef XML_DTD
      /* if there is no DOCTYPE declaration then now is the
         last chance to read the foreign DTD
      */
      if (parser->m_useForeignDTD) {
        XML_Bool hadParamEntityRefs = dtd->hasParamEntityRefs;
        dtd->hasParamEntityRefs = XML_TRUE;
        if (parser->m_paramEntityParsing &&
            parser->m_externalEntityRefHandler) {
          ENTITY *entity = (ENTITY *)lookup(parser, &dtd->paramEntities,
                                            externalSubsetName, sizeof(ENTITY));
          if (!entity)
            return XML_ERROR_NO_MEMORY;
          entity->base = parser->m_curBase;
          dtd->paramEntityRead = XML_FALSE;
          if (!parser->m_externalEntityRefHandler(
                  parser->m_externalEntityRefHandlerArg, 0, entity->base,
                  entity->systemId, entity->publicId))
            return XML_ERROR_EXTERNAL_ENTITY_HANDLING;
          if (dtd->paramEntityRead) {
            if (!dtd->standalone && parser->m_notStandaloneHandler &&
                !parser->m_notStandaloneHandler(parser->m_handlerArg))
              return XML_ERROR_NOT_STANDALONE;
          }
          /* if we didn't read the foreign DTD then this means that there
             is no external subset and we must reset dtd->hasParamEntityRefs
          */
          else
            dtd->hasParamEntityRefs = hadParamEntityRefs;
          /* end of DTD - no need to update dtd->keepProcessing */
        }
      }
#endif /* XML_DTD */
      parser->m_processor = contentProcessor;
      return contentProcessor(parser, s, end, nextPtr);
    case XML_ROLE_ATTLIST_ELEMENT_NAME:
      parser->m_declElementType = getElementType(parser, enc, s, next);
      if (!parser->m_declElementType)
        return XML_ERROR_NO_MEMORY;
      goto checkAttListDeclHandler;
    case XML_ROLE_ATTRIBUTE_NAME:
      parser->m_declAttributeId = getAttributeId(parser, enc, s, next);
      if (!parser->m_declAttributeId)
        return XML_ERROR_NO_MEMORY;
      parser->m_declAttributeIsCdata = XML_FALSE;
      parser->m_declAttributeType = NULL;
      parser->m_declAttributeIsId = XML_FALSE;
      goto checkAttListDeclHandler;
    case XML_ROLE_ATTRIBUTE_TYPE_CDATA:
      parser->m_declAttributeIsCdata = XML_TRUE;
      parser->m_declAttributeType = atypeCDATA;
      goto checkAttListDeclHandler;
    case XML_ROLE_ATTRIBUTE_TYPE_ID:
      parser->m_declAttributeIsId = XML_TRUE;
      parser->m_declAttributeType = atypeID;
      goto checkAttListDeclHandler;
    case XML_ROLE_ATTRIBUTE_TYPE_IDREF:
      parser->m_declAttributeType = atypeIDREF;
      goto checkAttListDeclHandler;
    case XML_ROLE_ATTRIBUTE_TYPE_IDREFS:
      parser->m_declAttributeType = atypeIDREFS;
      goto checkAttListDeclHandler;
    case XML_ROLE_ATTRIBUTE_TYPE_ENTITY:
      parser->m_declAttributeType = atypeENTITY;
      goto checkAttListDeclHandler;
    case XML_ROLE_ATTRIBUTE_TYPE_ENTITIES:
      parser->m_declAttributeType = atypeENTITIES;
      goto checkAttListDeclHandler;
    case XML_ROLE_ATTRIBUTE_TYPE_NMTOKEN:
      parser->m_declAttributeType = atypeNMTOKEN;
      goto checkAttListDeclHandler;
    case XML_ROLE_ATTRIBUTE_TYPE_NMTOKENS:
      parser->m_declAttributeType = atypeNMTOKENS;
    checkAttListDeclHandler:
      if (dtd->keepProcessing && parser->m_attlistDeclHandler)
        handleDefault = XML_FALSE;
      break;
    case XML_ROLE_ATTRIBUTE_ENUM_VALUE:
    case XML_ROLE_ATTRIBUTE_NOTATION_VALUE:
      if (dtd->keepProcessing && parser->m_attlistDeclHandler) {
        const XML_Char *prefix;
        if (parser->m_declAttributeType) {
          prefix = enumValueSep;
        } else {
          prefix = (role == XML_ROLE_ATTRIBUTE_NOTATION_VALUE ? notationPrefix
                                                              : enumValueStart);
        }
        if (!poolAppendString(&parser->m_tempPool, prefix))
          return XML_ERROR_NO_MEMORY;
        if (!poolAppend(&parser->m_tempPool, enc, s, next))
          return XML_ERROR_NO_MEMORY;
        parser->m_declAttributeType = parser->m_tempPool.start;
        handleDefault = XML_FALSE;
      }
      break;
    case XML_ROLE_IMPLIED_ATTRIBUTE_VALUE:
    case XML_ROLE_REQUIRED_ATTRIBUTE_VALUE:
      if (dtd->keepProcessing) {
        if (!defineAttribute(parser->m_declElementType,
                             parser->m_declAttributeId,
                             parser->m_declAttributeIsCdata,
                             parser->m_declAttributeIsId, 0, parser))
          return XML_ERROR_NO_MEMORY;
        if (parser->m_attlistDeclHandler && parser->m_declAttributeType) {
          if (*parser->m_declAttributeType == XML_T(ASCII_LPAREN) ||
              (*parser->m_declAttributeType == XML_T(ASCII_N) &&
               parser->m_declAttributeType[1] == XML_T(ASCII_O))) {
            /* Enumerated or Notation type */
            if (!poolAppendChar(&parser->m_tempPool, XML_T(ASCII_RPAREN)) ||
                !poolAppendChar(&parser->m_tempPool, XML_T('\0')))
              return XML_ERROR_NO_MEMORY;
            parser->m_declAttributeType = parser->m_tempPool.start;
            poolFinish(&parser->m_tempPool);
          }
          *eventEndPP = s;
          parser->m_attlistDeclHandler(
              parser->m_handlerArg, parser->m_declElementType->name,
              parser->m_declAttributeId->name, parser->m_declAttributeType, 0,
              role == XML_ROLE_REQUIRED_ATTRIBUTE_VALUE);
          handleDefault = XML_FALSE;
        }
      }
      poolClear(&parser->m_tempPool);
      break;
    case XML_ROLE_DEFAULT_ATTRIBUTE_VALUE:
    case XML_ROLE_FIXED_ATTRIBUTE_VALUE:
      if (dtd->keepProcessing) {
        const XML_Char *attVal;
        enum XML_Error result = storeAttributeValue(
            parser, enc, parser->m_declAttributeIsCdata,
            s + enc->minBytesPerChar, next - enc->minBytesPerChar, &dtd->pool,
            XML_ACCOUNT_NONE);
        if (result)
          return result;
        attVal = poolStart(&dtd->pool);
        poolFinish(&dtd->pool);
        /* ID attributes aren't allowed to have a default */
        if (!defineAttribute(
                parser->m_declElementType, parser->m_declAttributeId,
                parser->m_declAttributeIsCdata, XML_FALSE, attVal, parser))
          return XML_ERROR_NO_MEMORY;
        if (parser->m_attlistDeclHandler && parser->m_declAttributeType) {
          if (*parser->m_declAttributeType == XML_T(ASCII_LPAREN) ||
              (*parser->m_declAttributeType == XML_T(ASCII_N) &&
               parser->m_declAttributeType[1] == XML_T(ASCII_O))) {
            /* Enumerated or Notation type */
            if (!poolAppendChar(&parser->m_tempPool, XML_T(ASCII_RPAREN)) ||
                !poolAppendChar(&parser->m_tempPool, XML_T('\0')))
              return XML_ERROR_NO_MEMORY;
            parser->m_declAttributeType = parser->m_tempPool.start;
            poolFinish(&parser->m_tempPool);
          }
          *eventEndPP = s;
          parser->m_attlistDeclHandler(
              parser->m_handlerArg, parser->m_declElementType->name,
              parser->m_declAttributeId->name, parser->m_declAttributeType,
              attVal, role == XML_ROLE_FIXED_ATTRIBUTE_VALUE);
          poolClear(&parser->m_tempPool);
          handleDefault = XML_FALSE;
        }
      }
      break;
    case XML_ROLE_ENTITY_VALUE:
      if (dtd->keepProcessing) {
#if XML_GE == 1
        // This will store the given replacement text in
        // parser->m_declEntity->textPtr.
        enum XML_Error result =
            callStoreEntityValue(parser, enc, s + enc->minBytesPerChar,
                                 next - enc->minBytesPerChar, XML_ACCOUNT_NONE);
        if (parser->m_declEntity) {
          parser->m_declEntity->textPtr = poolStart(&dtd->entityValuePool);
          parser->m_declEntity->textLen =
              (int)(poolLength(&dtd->entityValuePool));
          poolFinish(&dtd->entityValuePool);
          if (parser->m_entityDeclHandler) {
            *eventEndPP = s;
            parser->m_entityDeclHandler(
                parser->m_handlerArg, parser->m_declEntity->name,
                parser->m_declEntity->is_param, parser->m_declEntity->textPtr,
                parser->m_declEntity->textLen, parser->m_curBase, 0, 0, 0);
            handleDefault = XML_FALSE;
          }
        } else
          poolDiscard(&dtd->entityValuePool);
        if (result != XML_ERROR_NONE)
          return result;
#else
        // This will store "&amp;entity123;" in parser->m_declEntity->textPtr
        // to end up as "&entity123;" in the handler.
        if (parser->m_declEntity != NULL) {
          const enum XML_Error result =
              storeSelfEntityValue(parser, parser->m_declEntity);
          if (result != XML_ERROR_NONE)
            return result;

          if (parser->m_entityDeclHandler) {
            *eventEndPP = s;
            parser->m_entityDeclHandler(
                parser->m_handlerArg, parser->m_declEntity->name,
                parser->m_declEntity->is_param, parser->m_declEntity->textPtr,
                parser->m_declEntity->textLen, parser->m_curBase, 0, 0, 0);
            handleDefault = XML_FALSE;
          }
        }
#endif
      }
      break;
    case XML_ROLE_DOCTYPE_SYSTEM_ID:
#ifdef XML_DTD
      parser->m_useForeignDTD = XML_FALSE;
#endif /* XML_DTD */
      dtd->hasParamEntityRefs = XML_TRUE;
      if (parser->m_startDoctypeDeclHandler) {
        parser->m_doctypeSysid =
            poolStoreString(&parser->m_tempPool, enc, s + enc->minBytesPerChar,
                            next - enc->minBytesPerChar);
        if (parser->m_doctypeSysid == NULL)
          return XML_ERROR_NO_MEMORY;
        poolFinish(&parser->m_tempPool);
        handleDefault = XML_FALSE;
      }
#ifdef XML_DTD
      else
        /* use externalSubsetName to make parser->m_doctypeSysid non-NULL
           for the case where no parser->m_startDoctypeDeclHandler is set */
        parser->m_doctypeSysid = externalSubsetName;
#endif /* XML_DTD */
      if (!dtd->standalone
#ifdef XML_DTD
          && !parser->m_paramEntityParsing
#endif /* XML_DTD */
          && parser->m_notStandaloneHandler &&
          !parser->m_notStandaloneHandler(parser->m_handlerArg))
        return XML_ERROR_NOT_STANDALONE;
#ifndef XML_DTD
      break;
#else  /* XML_DTD */
      if (!parser->m_declEntity) {
        parser->m_declEntity = (ENTITY *)lookup(
            parser, &dtd->paramEntities, externalSubsetName, sizeof(ENTITY));
        if (!parser->m_declEntity)
          return XML_ERROR_NO_MEMORY;
        parser->m_declEntity->publicId = NULL;
      }
#endif /* XML_DTD */
      /* fall through */
    case XML_ROLE_ENTITY_SYSTEM_ID:
      if (dtd->keepProcessing && parser->m_declEntity) {
        parser->m_declEntity->systemId =
            poolStoreString(&dtd->pool, enc, s + enc->minBytesPerChar,
                            next - enc->minBytesPerChar);
        if (!parser->m_declEntity->systemId)
          return XML_ERROR_NO_MEMORY;
        parser->m_declEntity->base = parser->m_curBase;
        poolFinish(&dtd->pool);
        /* Don't suppress the default handler if we fell through from
         * the XML_ROLE_DOCTYPE_SYSTEM_ID case.
         */
        if (parser->m_entityDeclHandler && role == XML_ROLE_ENTITY_SYSTEM_ID)
          handleDefault = XML_FALSE;
      }
      break;
    case XML_ROLE_ENTITY_COMPLETE:
#if XML_GE == 0
      // This will store "&amp;entity123;" in entity->textPtr
      // to end up as "&entity123;" in the handler.
      if (parser->m_declEntity != NULL) {
        const enum XML_Error result =
            storeSelfEntityValue(parser, parser->m_declEntity);
        if (result != XML_ERROR_NONE)
          return result;
      }
#endif
      if (dtd->keepProcessing && parser->m_declEntity &&
          parser->m_entityDeclHandler) {
        *eventEndPP = s;
        parser->m_entityDeclHandler(
            parser->m_handlerArg, parser->m_declEntity->name,
            parser->m_declEntity->is_param, 0, 0, parser->m_declEntity->base,
            parser->m_declEntity->systemId, parser->m_declEntity->publicId, 0);
        handleDefault = XML_FALSE;
      }
      break;
    case XML_ROLE_ENTITY_NOTATION_NAME:
      if (dtd->keepProcessing && parser->m_declEntity) {
        parser->m_declEntity->notation =
            poolStoreString(&dtd->pool, enc, s, next);
        if (!parser->m_declEntity->notation)
          return XML_ERROR_NO_MEMORY;
        poolFinish(&dtd->pool);
        if (parser->m_unparsedEntityDeclHandler) {
          *eventEndPP = s;
          parser->m_unparsedEntityDeclHandler(
              parser->m_handlerArg, parser->m_declEntity->name,
              parser->m_declEntity->base, parser->m_declEntity->systemId,
              parser->m_declEntity->publicId, parser->m_declEntity->notation);
          handleDefault = XML_FALSE;
        } else if (parser->m_entityDeclHandler) {
          *eventEndPP = s;
          parser->m_entityDeclHandler(
              parser->m_handlerArg, parser->m_declEntity->name, 0, 0, 0,
              parser->m_declEntity->base, parser->m_declEntity->systemId,
              parser->m_declEntity->publicId, parser->m_declEntity->notation);
          handleDefault = XML_FALSE;
        }
      }
      break;
    case XML_ROLE_GENERAL_ENTITY_NAME: {
      if (XmlPredefinedEntityName(enc, s, next)) {
        parser->m_declEntity = NULL;
        break;
      }
      if (dtd->keepProcessing) {
        const XML_Char *name = poolStoreString(&dtd->pool, enc, s, next);
        if (!name)
          return XML_ERROR_NO_MEMORY;
        parser->m_declEntity = (ENTITY *)lookup(parser, &dtd->generalEntities,
                                                name, sizeof(ENTITY));
        if (!parser->m_declEntity)
          return XML_ERROR_NO_MEMORY;
        if (parser->m_declEntity->name != name) {
          poolDiscard(&dtd->pool);
          parser->m_declEntity = NULL;
        } else {
          poolFinish(&dtd->pool);
          parser->m_declEntity->publicId = NULL;
          parser->m_declEntity->is_param = XML_FALSE;
          /* if we have a parent parser or are reading an internal parameter
             entity, then the entity declaration is not considered "internal"
          */
          parser->m_declEntity->is_internal =
              !(parser->m_parentParser || parser->m_openInternalEntities);
          if (parser->m_entityDeclHandler)
            handleDefault = XML_FALSE;
        }
      } else {
        poolDiscard(&dtd->pool);
        parser->m_declEntity = NULL;
      }
    } break;
    case XML_ROLE_PARAM_ENTITY_NAME:
#ifdef XML_DTD
      if (dtd->keepProcessing) {
        const XML_Char *name = poolStoreString(&dtd->pool, enc, s, next);
        if (!name)
          return XML_ERROR_NO_MEMORY;
        parser->m_declEntity =
            (ENTITY *)lookup(parser, &dtd->paramEntities, name, sizeof(ENTITY));
        if (!parser->m_declEntity)
          return XML_ERROR_NO_MEMORY;
        if (parser->m_declEntity->name != name) {
          poolDiscard(&dtd->pool);
          parser->m_declEntity = NULL;
        } else {
          poolFinish(&dtd->pool);
          parser->m_declEntity->publicId = NULL;
          parser->m_declEntity->is_param = XML_TRUE;
          /* if we have a parent parser or are reading an internal parameter
             entity, then the entity declaration is not considered "internal"
          */
          parser->m_declEntity->is_internal =
              !(parser->m_parentParser || parser->m_openInternalEntities);
          if (parser->m_entityDeclHandler)
            handleDefault = XML_FALSE;
        }
      } else {
        poolDiscard(&dtd->pool);
        parser->m_declEntity = NULL;
      }
#else  /* not XML_DTD */
      parser->m_declEntity = NULL;
#endif /* XML_DTD */
      break;
    case XML_ROLE_NOTATION_NAME:
      parser->m_declNotationPublicId = NULL;
      parser->m_declNotationName = NULL;
      if (parser->m_notationDeclHandler) {
        parser->m_declNotationName =
            poolStoreString(&parser->m_tempPool, enc, s, next);
        if (!parser->m_declNotationName)
          return XML_ERROR_NO_MEMORY;
        poolFinish(&parser->m_tempPool);
        handleDefault = XML_FALSE;
      }
      break;
    case XML_ROLE_NOTATION_PUBLIC_ID:
      if (!XmlIsPublicId(enc, s, next, eventPP))
        return XML_ERROR_PUBLICID;
      if (parser
              ->m_declNotationName) { /* means m_notationDeclHandler != NULL */
        XML_Char *tem =
            poolStoreString(&parser->m_tempPool, enc, s + enc->minBytesPerChar,
                            next - enc->minBytesPerChar);
        if (!tem)
          return XML_ERROR_NO_MEMORY;
        normalizePublicId(tem);
        parser->m_declNotationPublicId = tem;
        poolFinish(&parser->m_tempPool);
        handleDefault = XML_FALSE;
      }
      break;
    case XML_ROLE_NOTATION_SYSTEM_ID:
      if (parser->m_declNotationName && parser->m_notationDeclHandler) {
        const XML_Char *systemId =
            poolStoreString(&parser->m_tempPool, enc, s + enc->minBytesPerChar,
                            next - enc->minBytesPerChar);
        if (!systemId)
          return XML_ERROR_NO_MEMORY;
        *eventEndPP = s;
        parser->m_notationDeclHandler(
            parser->m_handlerArg, parser->m_declNotationName, parser->m_curBase,
            systemId, parser->m_declNotationPublicId);
        handleDefault = XML_FALSE;
      }
      poolClear(&parser->m_tempPool);
      break;
    case XML_ROLE_NOTATION_NO_SYSTEM_ID:
      if (parser->m_declNotationPublicId && parser->m_notationDeclHandler) {
        *eventEndPP = s;
        parser->m_notationDeclHandler(
            parser->m_handlerArg, parser->m_declNotationName, parser->m_curBase,
            0, parser->m_declNotationPublicId);
        handleDefault = XML_FALSE;
      }
      poolClear(&parser->m_tempPool);
      break;
    case XML_ROLE_ERROR:
      switch (tok) {
      case XML_TOK_PARAM_ENTITY_REF:
        /* PE references in internal subset are
           not allowed within declarations. */
        return XML_ERROR_PARAM_ENTITY_REF;
      case XML_TOK_XML_DECL:
        return XML_ERROR_MISPLACED_XML_PI;
      default:
        return XML_ERROR_SYNTAX;
      }
#ifdef XML_DTD
    case XML_ROLE_IGNORE_SECT: {
      enum XML_Error result;
      if (parser->m_defaultHandler)
        reportDefault(parser, enc, s, next);
      handleDefault = XML_FALSE;
      result = doIgnoreSection(parser, enc, &next, end, nextPtr, haveMore);
      if (result != XML_ERROR_NONE)
        return result;
      else if (!next) {
        parser->m_processor = ignoreSectionProcessor;
        return result;
      }
    } break;
#endif /* XML_DTD */
    case XML_ROLE_GROUP_OPEN:
      if (parser->m_prologState.level >= parser->m_groupSize) {
        if (parser->m_groupSize) {
          {
            /* Detect and prevent integer overflow */
            if (parser->m_groupSize > (unsigned int)(-1) / 2u) {
              return XML_ERROR_NO_MEMORY;
            }

            char *const new_connector = REALLOC(
                parser, parser->m_groupConnector, parser->m_groupSize *= 2);
            if (new_connector == NULL) {
              parser->m_groupSize /= 2;
              return XML_ERROR_NO_MEMORY;
            }
            parser->m_groupConnector = new_connector;
          }

          if (dtd->scaffIndex) {
            /* Detect and prevent integer overflow.
             * The preprocessor guard addresses the "always false" warning
             * from -Wtype-limits on platforms where
             * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
            if (parser->m_groupSize > SIZE_MAX / sizeof(int)) {
              parser->m_groupSize /= 2;
              return XML_ERROR_NO_MEMORY;
            }
#endif

            int *const new_scaff_index = REALLOC(
                parser, dtd->scaffIndex, parser->m_groupSize * sizeof(int));
            if (new_scaff_index == NULL) {
              parser->m_groupSize /= 2;
              return XML_ERROR_NO_MEMORY;
            }
            dtd->scaffIndex = new_scaff_index;
          }
        } else {
          parser->m_groupConnector = MALLOC(parser, parser->m_groupSize = 32);
          if (!parser->m_groupConnector) {
            parser->m_groupSize = 0;
            return XML_ERROR_NO_MEMORY;
          }
        }
      }
      parser->m_groupConnector[parser->m_prologState.level] = 0;
      if (dtd->in_eldecl) {
        int myindex = nextScaffoldPart(parser);
        if (myindex < 0)
          return XML_ERROR_NO_MEMORY;
        assert(dtd->scaffIndex != NULL);
        dtd->scaffIndex[dtd->scaffLevel] = myindex;
        dtd->scaffLevel++;
        dtd->scaffold[myindex].type = XML_CTYPE_SEQ;
        if (parser->m_elementDeclHandler)
          handleDefault = XML_FALSE;
      }
      break;
    case XML_ROLE_GROUP_SEQUENCE:
      if (parser->m_groupConnector[parser->m_prologState.level] == ASCII_PIPE)
        return XML_ERROR_SYNTAX;
      parser->m_groupConnector[parser->m_prologState.level] = ASCII_COMMA;
      if (dtd->in_eldecl && parser->m_elementDeclHandler)
        handleDefault = XML_FALSE;
      break;
    case XML_ROLE_GROUP_CHOICE:
      if (parser->m_groupConnector[parser->m_prologState.level] == ASCII_COMMA)
        return XML_ERROR_SYNTAX;
      if (dtd->in_eldecl &&
          !parser->m_groupConnector[parser->m_prologState.level] &&
          (dtd->scaffold[dtd->scaffIndex[dtd->scaffLevel - 1]].type !=
           XML_CTYPE_MIXED)) {
        dtd->scaffold[dtd->scaffIndex[dtd->scaffLevel - 1]].type =
            XML_CTYPE_CHOICE;
        if (parser->m_elementDeclHandler)
          handleDefault = XML_FALSE;
      }
      parser->m_groupConnector[parser->m_prologState.level] = ASCII_PIPE;
      break;
    case XML_ROLE_PARAM_ENTITY_REF:
#ifdef XML_DTD
    case XML_ROLE_INNER_PARAM_ENTITY_REF:
      dtd->hasParamEntityRefs = XML_TRUE;
      if (!parser->m_paramEntityParsing)
        dtd->keepProcessing = dtd->standalone;
      else {
        const XML_Char *name;
        ENTITY *entity;
        name = poolStoreString(&dtd->pool, enc, s + enc->minBytesPerChar,
                               next - enc->minBytesPerChar);
        if (!name)
          return XML_ERROR_NO_MEMORY;
        entity = (ENTITY *)lookup(parser, &dtd->paramEntities, name, 0);
        poolDiscard(&dtd->pool);
        /* first, determine if a check for an existing declaration is needed;
           if yes, check that the entity exists, and that it is internal,
           otherwise call the skipped entity handler
        */
        if (parser->m_prologState.documentEntity &&
            (dtd->standalone ? !parser->m_openInternalEntities
                             : !dtd->hasParamEntityRefs)) {
          if (!entity)
            return XML_ERROR_UNDEFINED_ENTITY;
          else if (!entity->is_internal) {
            /* It's hard to exhaustively search the code to be sure,
             * but there doesn't seem to be a way of executing the
             * following line.  There are two cases:
             *
             * If 'standalone' is false, the DTD must have no
             * parameter entities or we wouldn't have passed the outer
             * 'if' statement.  That means the only entity in the hash
             * table is the external subset name "#" which cannot be
             * given as a parameter entity name in XML syntax, so the
             * lookup must have returned NULL and we don't even reach
             * the test for an internal entity.
             *
             * If 'standalone' is true, it does not seem to be
             * possible to create entities taking this code path that
             * are not internal entities, so fail the test above.
             *
             * Because this analysis is very uncertain, the code is
             * being left in place and merely removed from the
             * coverage test statistics.
             */
            return XML_ERROR_ENTITY_DECLARED_IN_PE; /* LCOV_EXCL_LINE */
          }
        } else if (!entity) {
          dtd->keepProcessing = dtd->standalone;
          /* cannot report skipped entities in declarations */
          if ((role == XML_ROLE_PARAM_ENTITY_REF) &&
              parser->m_skippedEntityHandler) {
            parser->m_skippedEntityHandler(parser->m_handlerArg, name, 1);
            handleDefault = XML_FALSE;
          }
          break;
        }
        if (entity->open)
          return XML_ERROR_RECURSIVE_ENTITY_REF;
        if (entity->textPtr) {
          enum XML_Error result;
          XML_Bool betweenDecl =
              (role == XML_ROLE_PARAM_ENTITY_REF ? XML_TRUE : XML_FALSE);
          result = processEntity(parser, entity, betweenDecl, ENTITY_INTERNAL);
          if (result != XML_ERROR_NONE)
            return result;
          handleDefault = XML_FALSE;
          break;
        }
        if (parser->m_externalEntityRefHandler) {
          dtd->paramEntityRead = XML_FALSE;
          entity->open = XML_TRUE;
          entityTrackingOnOpen(parser, entity, __LINE__);
          if (!parser->m_externalEntityRefHandler(
                  parser->m_externalEntityRefHandlerArg, 0, entity->base,
                  entity->systemId, entity->publicId)) {
            entityTrackingOnClose(parser, entity, __LINE__);
            entity->open = XML_FALSE;
            return XML_ERROR_EXTERNAL_ENTITY_HANDLING;
          }
          entityTrackingOnClose(parser, entity, __LINE__);
          entity->open = XML_FALSE;
          handleDefault = XML_FALSE;
          if (!dtd->paramEntityRead) {
            dtd->keepProcessing = dtd->standalone;
            break;
          }
        } else {
          dtd->keepProcessing = dtd->standalone;
          break;
        }
      }
#endif /* XML_DTD */
      if (!dtd->standalone && parser->m_notStandaloneHandler &&
          !parser->m_notStandaloneHandler(parser->m_handlerArg))
        return XML_ERROR_NOT_STANDALONE;
      break;

      /* Element declaration stuff */

    case XML_ROLE_ELEMENT_NAME:
      if (parser->m_elementDeclHandler) {
        parser->m_declElementType = getElementType(parser, enc, s, next);
        if (!parser->m_declElementType)
          return XML_ERROR_NO_MEMORY;
        dtd->scaffLevel = 0;
        dtd->scaffCount = 0;
        dtd->in_eldecl = XML_TRUE;
        handleDefault = XML_FALSE;
      }
      break;

    case XML_ROLE_CONTENT_ANY:
    case XML_ROLE_CONTENT_EMPTY:
      if (dtd->in_eldecl) {
        if (parser->m_elementDeclHandler) {
          // NOTE: We are avoiding MALLOC(..) here to so that
          //       applications that are not using XML_FreeContentModel but
          //       plain free(..) or .free_fcn() to free the content model's
          //       memory are safe.
          XML_Content *content = parser->m_mem.malloc_fcn(sizeof(XML_Content));
          if (!content)
            return XML_ERROR_NO_MEMORY;
          content->quant = XML_CQUANT_NONE;
          content->name = NULL;
          content->numchildren = 0;
          content->children = NULL;
          content->type = ((role == XML_ROLE_CONTENT_ANY) ? XML_CTYPE_ANY
                                                          : XML_CTYPE_EMPTY);
          *eventEndPP = s;
          parser->m_elementDeclHandler(
              parser->m_handlerArg, parser->m_declElementType->name, content);
          handleDefault = XML_FALSE;
        }
        dtd->in_eldecl = XML_FALSE;
      }
      break;

    case XML_ROLE_CONTENT_PCDATA:
      if (dtd->in_eldecl) {
        dtd->scaffold[dtd->scaffIndex[dtd->scaffLevel - 1]].type =
            XML_CTYPE_MIXED;
        if (parser->m_elementDeclHandler)
          handleDefault = XML_FALSE;
      }
      break;

    case XML_ROLE_CONTENT_ELEMENT:
      quant = XML_CQUANT_NONE;
      goto elementContent;
    case XML_ROLE_CONTENT_ELEMENT_OPT:
      quant = XML_CQUANT_OPT;
      goto elementContent;
    case XML_ROLE_CONTENT_ELEMENT_REP:
      quant = XML_CQUANT_REP;
      goto elementContent;
    case XML_ROLE_CONTENT_ELEMENT_PLUS:
      quant = XML_CQUANT_PLUS;
    elementContent:
      if (dtd->in_eldecl) {
        ELEMENT_TYPE *el;
        const XML_Char *name;
        size_t nameLen;
        const char *nxt =
            (quant == XML_CQUANT_NONE ? next : next - enc->minBytesPerChar);
        int myindex = nextScaffoldPart(parser);
        if (myindex < 0)
          return XML_ERROR_NO_MEMORY;
        dtd->scaffold[myindex].type = XML_CTYPE_NAME;
        dtd->scaffold[myindex].quant = quant;
        el = getElementType(parser, enc, s, nxt);
        if (!el)
          return XML_ERROR_NO_MEMORY;
        name = el->name;
        dtd->scaffold[myindex].name = name;
        nameLen = 0;
        while (name[nameLen++])
          ;

        /* Detect and prevent integer overflow */
        if (nameLen > UINT_MAX - dtd->contentStringLen) {
          return XML_ERROR_NO_MEMORY;
        }

        dtd->contentStringLen += (unsigned)nameLen;
        if (parser->m_elementDeclHandler)
          handleDefault = XML_FALSE;
      }
      break;

    case XML_ROLE_GROUP_CLOSE:
      quant = XML_CQUANT_NONE;
      goto closeGroup;
    case XML_ROLE_GROUP_CLOSE_OPT:
      quant = XML_CQUANT_OPT;
      goto closeGroup;
    case XML_ROLE_GROUP_CLOSE_REP:
      quant = XML_CQUANT_REP;
      goto closeGroup;
    case XML_ROLE_GROUP_CLOSE_PLUS:
      quant = XML_CQUANT_PLUS;
    closeGroup:
      if (dtd->in_eldecl) {
        if (parser->m_elementDeclHandler)
          handleDefault = XML_FALSE;
        dtd->scaffLevel--;
        dtd->scaffold[dtd->scaffIndex[dtd->scaffLevel]].quant = quant;
        if (dtd->scaffLevel == 0) {
          if (!handleDefault) {
            XML_Content *model = build_model(parser);
            if (!model)
              return XML_ERROR_NO_MEMORY;
            *eventEndPP = s;
            parser->m_elementDeclHandler(
                parser->m_handlerArg, parser->m_declElementType->name, model);
          }
          dtd->in_eldecl = XML_FALSE;
          dtd->contentStringLen = 0;
        }
      }
      break;
      /* End element declaration stuff */

    case XML_ROLE_PI:
      if (!reportProcessingInstruction(parser, enc, s, next))
        return XML_ERROR_NO_MEMORY;
      handleDefault = XML_FALSE;
      break;
    case XML_ROLE_COMMENT:
      if (!reportComment(parser, enc, s, next))
        return XML_ERROR_NO_MEMORY;
      handleDefault = XML_FALSE;
      break;
    case XML_ROLE_NONE:
      switch (tok) {
      case XML_TOK_BOM:
        handleDefault = XML_FALSE;
        break;
      }
      break;
    case XML_ROLE_DOCTYPE_NONE:
      if (parser->m_startDoctypeDeclHandler)
        handleDefault = XML_FALSE;
      break;
    case XML_ROLE_ENTITY_NONE:
      if (dtd->keepProcessing && parser->m_entityDeclHandler)
        handleDefault = XML_FALSE;
      break;
    case XML_ROLE_NOTATION_NONE:
      if (parser->m_notationDeclHandler)
        handleDefault = XML_FALSE;
      break;
    case XML_ROLE_ATTLIST_NONE:
      if (dtd->keepProcessing && parser->m_attlistDeclHandler)
        handleDefault = XML_FALSE;
      break;
    case XML_ROLE_ELEMENT_NONE:
      if (parser->m_elementDeclHandler)
        handleDefault = XML_FALSE;
      break;
    } /* end of big switch */

    if (handleDefault && parser->m_defaultHandler)
      reportDefault(parser, enc, s, next);

    switch (parser->m_parsingStatus.parsing) {
    case XML_SUSPENDED:
      *nextPtr = next;
      return XML_ERROR_NONE;
    case XML_FINISHED:
      return XML_ERROR_ABORTED;
    case XML_PARSING:
      if (parser->m_reenter) {
        *nextPtr = next;
        return XML_ERROR_NONE;
      }
    /* Fall through */
    default:
      s = next;
      tok = XmlPrologTok(enc, s, end, &next);
    }
  }
  /* not reached */
}

static enum XML_Error PTRCALL epilogProcessor(XML_Parser parser, const char *s,
                                              const char *end,
                                              const char **nextPtr) {
  parser->m_processor = epilogProcessor;
  parser->m_eventPtr = s;
  for (;;) {
    const char *next = NULL;
    int tok = XmlPrologTok(parser->m_encoding, s, end, &next);
#if XML_GE == 1
    if (!accountingDiffTolerated(parser, tok, s, next, __LINE__,
                                 XML_ACCOUNT_DIRECT)) {
      accountingOnAbort(parser);
      return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
    }
#endif
    parser->m_eventEndPtr = next;
    switch (tok) {
    /* report partial linebreak - it might be the last token */
    case -XML_TOK_PROLOG_S:
      if (parser->m_defaultHandler) {
        reportDefault(parser, parser->m_encoding, s, next);
        if (parser->m_parsingStatus.parsing == XML_FINISHED)
          return XML_ERROR_ABORTED;
      }
      *nextPtr = next;
      return XML_ERROR_NONE;
    case XML_TOK_NONE:
      *nextPtr = s;
      return XML_ERROR_NONE;
    case XML_TOK_PROLOG_S:
      if (parser->m_defaultHandler)
        reportDefault(parser, parser->m_encoding, s, next);
      break;
    case XML_TOK_PI:
      if (!reportProcessingInstruction(parser, parser->m_encoding, s, next))
        return XML_ERROR_NO_MEMORY;
      break;
    case XML_TOK_COMMENT:
      if (!reportComment(parser, parser->m_encoding, s, next))
        return XML_ERROR_NO_MEMORY;
      break;
    case XML_TOK_INVALID:
      parser->m_eventPtr = next;
      return XML_ERROR_INVALID_TOKEN;
    case XML_TOK_PARTIAL:
      if (!parser->m_parsingStatus.finalBuffer) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      return XML_ERROR_UNCLOSED_TOKEN;
    case XML_TOK_PARTIAL_CHAR:
      if (!parser->m_parsingStatus.finalBuffer) {
        *nextPtr = s;
        return XML_ERROR_NONE;
      }
      return XML_ERROR_PARTIAL_CHAR;
    default:
      return XML_ERROR_JUNK_AFTER_DOC_ELEMENT;
    }
    switch (parser->m_parsingStatus.parsing) {
    case XML_SUSPENDED:
      parser->m_eventPtr = next;
      *nextPtr = next;
      return XML_ERROR_NONE;
    case XML_FINISHED:
      parser->m_eventPtr = next;
      return XML_ERROR_ABORTED;
    case XML_PARSING:
      if (parser->m_reenter) {
        return XML_ERROR_UNEXPECTED_STATE; // LCOV_EXCL_LINE
      }
    /* Fall through */
    default:;
      parser->m_eventPtr = s = next;
    }
  }
}

static enum XML_Error processEntity(XML_Parser parser, ENTITY *entity,
                                    XML_Bool betweenDecl,
                                    enum EntityType type) {
  OPEN_INTERNAL_ENTITY *openEntity, **openEntityList, **freeEntityList;
  switch (type) {
  case ENTITY_INTERNAL:
    parser->m_processor = internalEntityProcessor;
    openEntityList = &parser->m_openInternalEntities;
    freeEntityList = &parser->m_freeInternalEntities;
    break;
  case ENTITY_ATTRIBUTE:
    openEntityList = &parser->m_openAttributeEntities;
    freeEntityList = &parser->m_freeAttributeEntities;
    break;
  case ENTITY_VALUE:
    openEntityList = &parser->m_openValueEntities;
    freeEntityList = &parser->m_freeValueEntities;
    break;
    /* default case serves merely as a safety net in case of a
     * wrong entityType. Therefore we exclude the following lines
     * from the test coverage.
     *
     * LCOV_EXCL_START
     */
  default:
    // Should not reach here
    assert(0);
    /* LCOV_EXCL_STOP */
  }

  if (*freeEntityList) {
    openEntity = *freeEntityList;
    *freeEntityList = openEntity->next;
  } else {
    openEntity = MALLOC(parser, sizeof(OPEN_INTERNAL_ENTITY));
    if (!openEntity)
      return XML_ERROR_NO_MEMORY;
  }
  entity->open = XML_TRUE;
  entity->hasMore = XML_TRUE;
#if XML_GE == 1
  entityTrackingOnOpen(parser, entity, __LINE__);
#endif
  entity->processed = 0;
  openEntity->next = *openEntityList;
  *openEntityList = openEntity;
  openEntity->entity = entity;
  openEntity->type = type;
  openEntity->startTagLevel = parser->m_tagLevel;
  openEntity->betweenDecl = betweenDecl;
  openEntity->internalEventPtr = NULL;
  openEntity->internalEventEndPtr = NULL;

  // Only internal entities make use of the reenter flag
  // therefore no need to set it for other entity types
  if (type == ENTITY_INTERNAL) {
    triggerReenter(parser);
  }
  return XML_ERROR_NONE;
}

static enum XML_Error PTRCALL internalEntityProcessor(XML_Parser parser,
                                                      const char *s,
                                                      const char *end,
                                                      const char **nextPtr) {
  UNUSED_P(s);
  UNUSED_P(end);
  UNUSED_P(nextPtr);
  ENTITY *entity;
  const char *textStart, *textEnd;
  const char *next;
  enum XML_Error result;
  OPEN_INTERNAL_ENTITY *openEntity = parser->m_openInternalEntities;
  if (!openEntity)
    return XML_ERROR_UNEXPECTED_STATE;

  entity = openEntity->entity;

  // This will return early
  if (entity->hasMore) {
    textStart = ((const char *)entity->textPtr) + entity->processed;
    textEnd = (const char *)(entity->textPtr + entity->textLen);
    /* Set a safe default value in case 'next' does not get set */
    next = textStart;

    if (entity->is_param) {
      int tok =
          XmlPrologTok(parser->m_internalEncoding, textStart, textEnd, &next);
      result = doProlog(parser, parser->m_internalEncoding, textStart, textEnd,
                        tok, next, &next, XML_FALSE, XML_FALSE,
                        XML_ACCOUNT_ENTITY_EXPANSION);
    } else {
      result = doContent(parser, openEntity->startTagLevel,
                         parser->m_internalEncoding, textStart, textEnd, &next,
                         XML_FALSE, XML_ACCOUNT_ENTITY_EXPANSION);
    }

    if (result != XML_ERROR_NONE)
      return result;
    // Check if entity is complete, if not, mark down how much of it is
    // processed
    if (textEnd != next && (parser->m_parsingStatus.parsing == XML_SUSPENDED ||
                            (parser->m_parsingStatus.parsing == XML_PARSING &&
                             parser->m_reenter))) {
      entity->processed = (int)(next - (const char *)entity->textPtr);
      return result;
    }

    // Entity is complete. We cannot close it here since we need to first
    // process its possible inner entities (which are added to the
    // m_openInternalEntities during doProlog or doContent calls above)
    entity->hasMore = XML_FALSE;
    if (!entity->is_param &&
        (openEntity->startTagLevel != parser->m_tagLevel)) {
      return XML_ERROR_ASYNC_ENTITY;
    }
    triggerReenter(parser);
    return result;
  } // End of entity processing, "if" block will return here

  // Remove fully processed openEntity from open entity list.
#if XML_GE == 1
  entityTrackingOnClose(parser, entity, __LINE__);
#endif
  // openEntity is m_openInternalEntities' head, as we set it at the start of
  // this function and we skipped doProlog and doContent calls with hasMore set
  // to false. This means we can directly remove the head of
  // m_openInternalEntities
  assert(parser->m_openInternalEntities == openEntity);
  entity->open = XML_FALSE;
  parser->m_openInternalEntities = parser->m_openInternalEntities->next;

  /* put openEntity back in list of free instances */
  openEntity->next = parser->m_freeInternalEntities;
  parser->m_freeInternalEntities = openEntity;

  if (parser->m_openInternalEntities == NULL) {
    parser->m_processor = entity->is_param ? prologProcessor : contentProcessor;
  }
  triggerReenter(parser);
  return XML_ERROR_NONE;
}

static enum XML_Error PTRCALL errorProcessor(XML_Parser parser, const char *s,
                                             const char *end,
                                             const char **nextPtr) {
  UNUSED_P(s);
  UNUSED_P(end);
  UNUSED_P(nextPtr);
  return parser->m_errorCode;
}

static enum XML_Error storeAttributeValue(XML_Parser parser,
                                          const ENCODING *enc, XML_Bool isCdata,
                                          const char *ptr, const char *end,
                                          STRING_POOL *pool,
                                          enum XML_Account account) {
  const char *next = ptr;
  enum XML_Error result = XML_ERROR_NONE;

  while (1) {
    if (!parser->m_openAttributeEntities) {
      result = appendAttributeValue(parser, enc, isCdata, next, end, pool,
                                    account, &next);
    } else {
      OPEN_INTERNAL_ENTITY *const openEntity = parser->m_openAttributeEntities;
      if (!openEntity)
        return XML_ERROR_UNEXPECTED_STATE;

      ENTITY *const entity = openEntity->entity;
      const char *const textStart =
          ((const char *)entity->textPtr) + entity->processed;
      const char *const textEnd =
          (const char *)(entity->textPtr + entity->textLen);
      /* Set a safe default value in case 'next' does not get set */
      const char *nextInEntity = textStart;
      if (entity->hasMore) {
        result = appendAttributeValue(
            parser, parser->m_internalEncoding, isCdata, textStart, textEnd,
            pool, XML_ACCOUNT_ENTITY_EXPANSION, &nextInEntity);
        if (result != XML_ERROR_NONE)
          break;
        // Check if entity is complete, if not, mark down how much of it is
        // processed. A XML_SUSPENDED check here is not required as
        // appendAttributeValue will never suspend the parser.
        if (textEnd != nextInEntity) {
          entity->processed =
              (int)(nextInEntity - (const char *)entity->textPtr);
          continue;
        }

        // Entity is complete. We cannot close it here since we need to first
        // process its possible inner entities (which are added to the
        // m_openAttributeEntities during appendAttributeValue)
        entity->hasMore = XML_FALSE;
        continue;
      } // End of entity processing, "if" block skips the rest

      // Remove fully processed openEntity from open entity list.
#if XML_GE == 1
      entityTrackingOnClose(parser, entity, __LINE__);
#endif
      // openEntity is m_openAttributeEntities' head, since we set it at the
      // start of this function and because we skipped appendAttributeValue call
      // with hasMore set to false. This means we can directly remove the head
      // of m_openAttributeEntities
      assert(parser->m_openAttributeEntities == openEntity);
      entity->open = XML_FALSE;
      parser->m_openAttributeEntities = parser->m_openAttributeEntities->next;

      /* put openEntity back in list of free instances */
      openEntity->next = parser->m_freeAttributeEntities;
      parser->m_freeAttributeEntities = openEntity;
    }

    // Break if an error occurred or there is nothing left to process
    if (result || (parser->m_openAttributeEntities == NULL && end == next)) {
      break;
    }
  }

  if (result)
    return result;
  if (!isCdata && poolLength(pool) && poolLastChar(pool) == 0x20)
    poolChop(pool);
  if (!poolAppendChar(pool, XML_T('\0')))
    return XML_ERROR_NO_MEMORY;
  return XML_ERROR_NONE;
}

static enum XML_Error
appendAttributeValue(XML_Parser parser, const ENCODING *enc, XML_Bool isCdata,
                     const char *ptr, const char *end, STRING_POOL *pool,
                     enum XML_Account account, const char **nextPtr) {
  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
#ifndef XML_DTD
  UNUSED_P(account);
#endif

  for (;;) {
    const char *next =
        ptr; /* XmlAttributeValueTok doesn't always set the last arg */
    int tok = XmlAttributeValueTok(enc, ptr, end, &next);
#if XML_GE == 1
    if (!accountingDiffTolerated(parser, tok, ptr, next, __LINE__, account)) {
      accountingOnAbort(parser);
      return XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
    }
#endif
    switch (tok) {
    case XML_TOK_NONE:
      if (nextPtr) {
        *nextPtr = next;
      }
      return XML_ERROR_NONE;
    case XML_TOK_INVALID:
      if (enc == parser->m_encoding)
        parser->m_eventPtr = next;
      return XML_ERROR_INVALID_TOKEN;
    case XML_TOK_PARTIAL:
      if (enc == parser->m_encoding)
        parser->m_eventPtr = ptr;
      return XML_ERROR_INVALID_TOKEN;
    case XML_TOK_CHAR_REF: {
      XML_Char buf[XML_ENCODE_MAX];
      int i;
      int n = XmlCharRefNumber(enc, ptr);
      if (n < 0) {
        if (enc == parser->m_encoding)
          parser->m_eventPtr = ptr;
        return XML_ERROR_BAD_CHAR_REF;
      }
      if (!isCdata && n == 0x20 /* space */
          && (poolLength(pool) == 0 || poolLastChar(pool) == 0x20))
        break;
      n = XmlEncode(n, (ICHAR *)buf);
      /* The XmlEncode() functions can never return 0 here.  That
       * error return happens if the code point passed in is either
       * negative or greater than or equal to 0x110000.  The
       * XmlCharRefNumber() functions will all return a number
       * strictly less than 0x110000 or a negative value if an error
       * occurred.  The negative value is intercepted above, so
       * XmlEncode() is never passed a value it might return an
       * error for.
       */
      for (i = 0; i < n; i++) {
        if (!poolAppendChar(pool, buf[i]))
          return XML_ERROR_NO_MEMORY;
      }
    } break;
    case XML_TOK_DATA_CHARS:
      if (!poolAppend(pool, enc, ptr, next))
        return XML_ERROR_NO_MEMORY;
      break;
    case XML_TOK_TRAILING_CR:
      next = ptr + enc->minBytesPerChar;
      /* fall through */
    case XML_TOK_ATTRIBUTE_VALUE_S:
    case XML_TOK_DATA_NEWLINE:
      if (!isCdata && (poolLength(pool) == 0 || poolLastChar(pool) == 0x20))
        break;
      if (!poolAppendChar(pool, 0x20))
        return XML_ERROR_NO_MEMORY;
      break;
    case XML_TOK_ENTITY_REF: {
      const XML_Char *name;
      ENTITY *entity;
      bool checkEntityDecl;
      XML_Char ch = (XML_Char)XmlPredefinedEntityName(
          enc, ptr + enc->minBytesPerChar, next - enc->minBytesPerChar);
      if (ch) {
#if XML_GE == 1
        /* NOTE: We are replacing 4-6 characters original input for 1 character
         *       so there is no amplification and hence recording without
         *       protection. */
        accountingDiffTolerated(parser, tok, (char *)&ch,
                                ((char *)&ch) + sizeof(XML_Char), __LINE__,
                                XML_ACCOUNT_ENTITY_EXPANSION);
#endif /* XML_GE == 1 */
        if (!poolAppendChar(pool, ch))
          return XML_ERROR_NO_MEMORY;
        break;
      }
      name =
          poolStoreString(&parser->m_temp2Pool, enc, ptr + enc->minBytesPerChar,
                          next - enc->minBytesPerChar);
      if (!name)
        return XML_ERROR_NO_MEMORY;
      entity = (ENTITY *)lookup(parser, &dtd->generalEntities, name, 0);
      poolDiscard(&parser->m_temp2Pool);
      /* First, determine if a check for an existing declaration is needed;
         if yes, check that the entity exists, and that it is internal.
      */
      if (pool == &dtd->pool) /* are we called from prolog? */
        checkEntityDecl =
#ifdef XML_DTD
            parser->m_prologState.documentEntity &&
#endif /* XML_DTD */
            (dtd->standalone ? !parser->m_openInternalEntities
                             : !dtd->hasParamEntityRefs);
      else /* if (pool == &parser->m_tempPool): we are called from content */
        checkEntityDecl = !dtd->hasParamEntityRefs || dtd->standalone;
      if (checkEntityDecl) {
        if (!entity)
          return XML_ERROR_UNDEFINED_ENTITY;
        else if (!entity->is_internal)
          return XML_ERROR_ENTITY_DECLARED_IN_PE;
      } else if (!entity) {
        /* Cannot report skipped entity here - see comments on
           parser->m_skippedEntityHandler.
        if (parser->m_skippedEntityHandler)
          parser->m_skippedEntityHandler(parser->m_handlerArg, name, 0);
        */
        /* Cannot call the default handler because this would be
           out of sync with the call to the startElementHandler.
        if ((pool == &parser->m_tempPool) && parser->m_defaultHandler)
          reportDefault(parser, enc, ptr, next);
        */
        break;
      }
      if (entity->open) {
        if (enc == parser->m_encoding) {
          /* It does not appear that this line can be executed.
           *
           * The "if (entity->open)" check catches recursive entity
           * definitions.  In order to be called with an open
           * entity, it must have gone through this code before and
           * been through the recursive call to
           * appendAttributeValue() some lines below.  That call
           * sets the local encoding ("enc") to the parser's
           * internal encoding (internal_utf8 or internal_utf16),
           * which can never be the same as the principle encoding.
           * It doesn't appear there is another code path that gets
           * here with entity->open being TRUE.
           *
           * Since it is not certain that this logic is watertight,
           * we keep the line and merely exclude it from coverage
           * tests.
           */
          parser->m_eventPtr = ptr; /* LCOV_EXCL_LINE */
        }
        return XML_ERROR_RECURSIVE_ENTITY_REF;
      }
      if (entity->notation) {
        if (enc == parser->m_encoding)
          parser->m_eventPtr = ptr;
        return XML_ERROR_BINARY_ENTITY_REF;
      }
      if (!entity->textPtr) {
        if (enc == parser->m_encoding)
          parser->m_eventPtr = ptr;
        return XML_ERROR_ATTRIBUTE_EXTERNAL_ENTITY_REF;
      } else {
        enum XML_Error result;
        result = processEntity(parser, entity, XML_FALSE, ENTITY_ATTRIBUTE);
        if ((result == XML_ERROR_NONE) && (nextPtr != NULL)) {
          *nextPtr = next;
        }
        return result;
      }
    } break;
    default:
      /* The only token returned by XmlAttributeValueTok() that does
       * not have an explicit case here is XML_TOK_PARTIAL_CHAR.
       * Getting that would require an entity name to contain an
       * incomplete XML character (e.g. \xE2\x82); however previous
       * tokenisers will have already recognised and rejected such
       * names before XmlAttributeValueTok() gets a look-in.  This
       * default case should be retained as a safety net, but the code
       * excluded from coverage tests.
       *
       * LCOV_EXCL_START
       */
      if (enc == parser->m_encoding)
        parser->m_eventPtr = ptr;
      return XML_ERROR_UNEXPECTED_STATE;
      /* LCOV_EXCL_STOP */
    }
    ptr = next;
  }
  /* not reached */
}

#if XML_GE == 1
static enum XML_Error storeEntityValue(XML_Parser parser, const ENCODING *enc,
                                       const char *entityTextPtr,
                                       const char *entityTextEnd,
                                       enum XML_Account account,
                                       const char **nextPtr) {
  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
  STRING_POOL *pool = &(dtd->entityValuePool);
  enum XML_Error result = XML_ERROR_NONE;
#ifdef XML_DTD
  int oldInEntityValue = parser->m_prologState.inEntityValue;
  parser->m_prologState.inEntityValue = 1;
#else
  UNUSED_P(account);
#endif /* XML_DTD */
  /* never return Null for the value argument in EntityDeclHandler,
     since this would indicate an external entity; therefore we
     have to make sure that entityValuePool.start is not null */
  if (!pool->blocks) {
    if (!poolGrow(pool))
      return XML_ERROR_NO_MEMORY;
  }

  const char *next;
  for (;;) {
    next =
        entityTextPtr; /* XmlEntityValueTok doesn't always set the last arg */
    int tok = XmlEntityValueTok(enc, entityTextPtr, entityTextEnd, &next);

    if (!accountingDiffTolerated(parser, tok, entityTextPtr, next, __LINE__,
                                 account)) {
      accountingOnAbort(parser);
      result = XML_ERROR_AMPLIFICATION_LIMIT_BREACH;
      goto endEntityValue;
    }

    switch (tok) {
    case XML_TOK_PARAM_ENTITY_REF:
#ifdef XML_DTD
      if (parser->m_isParamEntity || enc != parser->m_encoding) {
        const XML_Char *name;
        ENTITY *entity;
        name = poolStoreString(&parser->m_tempPool, enc,
                               entityTextPtr + enc->minBytesPerChar,
                               next - enc->minBytesPerChar);
        if (!name) {
          result = XML_ERROR_NO_MEMORY;
          goto endEntityValue;
        }
        entity = (ENTITY *)lookup(parser, &dtd->paramEntities, name, 0);
        poolDiscard(&parser->m_tempPool);
        if (!entity) {
          /* not a well-formedness error - see XML 1.0: WFC Entity Declared */
          /* cannot report skipped entity here - see comments on
             parser->m_skippedEntityHandler
          if (parser->m_skippedEntityHandler)
            parser->m_skippedEntityHandler(parser->m_handlerArg, name, 0);
          */
          dtd->keepProcessing = dtd->standalone;
          goto endEntityValue;
        }
        if (entity->open || (entity == parser->m_declEntity)) {
          if (enc == parser->m_encoding)
            parser->m_eventPtr = entityTextPtr;
          result = XML_ERROR_RECURSIVE_ENTITY_REF;
          goto endEntityValue;
        }
        if (entity->systemId) {
          if (parser->m_externalEntityRefHandler) {
            dtd->paramEntityRead = XML_FALSE;
            entity->open = XML_TRUE;
            entityTrackingOnOpen(parser, entity, __LINE__);
            if (!parser->m_externalEntityRefHandler(
                    parser->m_externalEntityRefHandlerArg, 0, entity->base,
                    entity->systemId, entity->publicId)) {
              entityTrackingOnClose(parser, entity, __LINE__);
              entity->open = XML_FALSE;
              result = XML_ERROR_EXTERNAL_ENTITY_HANDLING;
              goto endEntityValue;
            }
            entityTrackingOnClose(parser, entity, __LINE__);
            entity->open = XML_FALSE;
            if (!dtd->paramEntityRead)
              dtd->keepProcessing = dtd->standalone;
          } else
            dtd->keepProcessing = dtd->standalone;
        } else {
          result = processEntity(parser, entity, XML_FALSE, ENTITY_VALUE);
          goto endEntityValue;
        }
        break;
      }
#endif /* XML_DTD */
      /* In the internal subset, PE references are not legal
         within markup declarations, e.g entity values in this case. */
      parser->m_eventPtr = entityTextPtr;
      result = XML_ERROR_PARAM_ENTITY_REF;
      goto endEntityValue;
    case XML_TOK_NONE:
      result = XML_ERROR_NONE;
      goto endEntityValue;
    case XML_TOK_ENTITY_REF:
    case XML_TOK_DATA_CHARS:
      if (!poolAppend(pool, enc, entityTextPtr, next)) {
        result = XML_ERROR_NO_MEMORY;
        goto endEntityValue;
      }
      break;
    case XML_TOK_TRAILING_CR:
      next = entityTextPtr + enc->minBytesPerChar;
      /* fall through */
    case XML_TOK_DATA_NEWLINE:
      if (pool->end == pool->ptr && !poolGrow(pool)) {
        result = XML_ERROR_NO_MEMORY;
        goto endEntityValue;
      }
      *(pool->ptr)++ = 0xA;
      break;
    case XML_TOK_CHAR_REF: {
      XML_Char buf[XML_ENCODE_MAX];
      int i;
      int n = XmlCharRefNumber(enc, entityTextPtr);
      if (n < 0) {
        if (enc == parser->m_encoding)
          parser->m_eventPtr = entityTextPtr;
        result = XML_ERROR_BAD_CHAR_REF;
        goto endEntityValue;
      }
      n = XmlEncode(n, (ICHAR *)buf);
      /* The XmlEncode() functions can never return 0 here.  That
       * error return happens if the code point passed in is either
       * negative or greater than or equal to 0x110000.  The
       * XmlCharRefNumber() functions will all return a number
       * strictly less than 0x110000 or a negative value if an error
       * occurred.  The negative value is intercepted above, so
       * XmlEncode() is never passed a value it might return an
       * error for.
       */
      for (i = 0; i < n; i++) {
        if (pool->end == pool->ptr && !poolGrow(pool)) {
          result = XML_ERROR_NO_MEMORY;
          goto endEntityValue;
        }
        *(pool->ptr)++ = buf[i];
      }
    } break;
    case XML_TOK_PARTIAL:
      if (enc == parser->m_encoding)
        parser->m_eventPtr = entityTextPtr;
      result = XML_ERROR_INVALID_TOKEN;
      goto endEntityValue;
    case XML_TOK_INVALID:
      if (enc == parser->m_encoding)
        parser->m_eventPtr = next;
      result = XML_ERROR_INVALID_TOKEN;
      goto endEntityValue;
    default:
      /* This default case should be unnecessary -- all the tokens
       * that XmlEntityValueTok() can return have their own explicit
       * cases -- but should be retained for safety.  We do however
       * exclude it from the coverage statistics.
       *
       * LCOV_EXCL_START
       */
      if (enc == parser->m_encoding)
        parser->m_eventPtr = entityTextPtr;
      result = XML_ERROR_UNEXPECTED_STATE;
      goto endEntityValue;
      /* LCOV_EXCL_STOP */
    }
    entityTextPtr = next;
  }
endEntityValue:
#ifdef XML_DTD
  parser->m_prologState.inEntityValue = oldInEntityValue;
#endif /* XML_DTD */
  // If 'nextPtr' is given, it should be updated during the processing
  if (nextPtr != NULL) {
    *nextPtr = next;
  }
  return result;
}

static enum XML_Error callStoreEntityValue(XML_Parser parser,
                                           const ENCODING *enc,
                                           const char *entityTextPtr,
                                           const char *entityTextEnd,
                                           enum XML_Account account) {
  const char *next = entityTextPtr;
  enum XML_Error result = XML_ERROR_NONE;
  while (1) {
    if (!parser->m_openValueEntities) {
      result =
          storeEntityValue(parser, enc, next, entityTextEnd, account, &next);
    } else {
      OPEN_INTERNAL_ENTITY *const openEntity = parser->m_openValueEntities;
      if (!openEntity)
        return XML_ERROR_UNEXPECTED_STATE;

      ENTITY *const entity = openEntity->entity;
      const char *const textStart =
          ((const char *)entity->textPtr) + entity->processed;
      const char *const textEnd =
          (const char *)(entity->textPtr + entity->textLen);
      /* Set a safe default value in case 'next' does not get set */
      const char *nextInEntity = textStart;
      if (entity->hasMore) {
        result = storeEntityValue(parser, parser->m_internalEncoding, textStart,
                                  textEnd, XML_ACCOUNT_ENTITY_EXPANSION,
                                  &nextInEntity);
        if (result != XML_ERROR_NONE)
          break;
        // Check if entity is complete, if not, mark down how much of it is
        // processed. A XML_SUSPENDED check here is not required as
        // appendAttributeValue will never suspend the parser.
        if (textEnd != nextInEntity) {
          entity->processed =
              (int)(nextInEntity - (const char *)entity->textPtr);
          continue;
        }

        // Entity is complete. We cannot close it here since we need to first
        // process its possible inner entities (which are added to the
        // m_openValueEntities during storeEntityValue)
        entity->hasMore = XML_FALSE;
        continue;
      } // End of entity processing, "if" block skips the rest

      // Remove fully processed openEntity from open entity list.
#if XML_GE == 1
      entityTrackingOnClose(parser, entity, __LINE__);
#endif
      // openEntity is m_openValueEntities' head, since we set it at the
      // start of this function and because we skipped storeEntityValue call
      // with hasMore set to false. This means we can directly remove the head
      // of m_openValueEntities
      assert(parser->m_openValueEntities == openEntity);
      entity->open = XML_FALSE;
      parser->m_openValueEntities = parser->m_openValueEntities->next;

      /* put openEntity back in list of free instances */
      openEntity->next = parser->m_freeValueEntities;
      parser->m_freeValueEntities = openEntity;
    }

    // Break if an error occurred or there is nothing left to process
    if (result ||
        (parser->m_openValueEntities == NULL && entityTextEnd == next)) {
      break;
    }
  }

  return result;
}

#else /* XML_GE == 0 */

static enum XML_Error storeSelfEntityValue(XML_Parser parser, ENTITY *entity) {
  // This will store "&amp;entity123;" in entity->textPtr
  // to end up as "&entity123;" in the handler.
  const char *const entity_start = "&amp;";
  const char *const entity_end = ";";

  STRING_POOL *const pool = &(parser->m_dtd->entityValuePool);
  if (!poolAppendString(pool, entity_start) ||
      !poolAppendString(pool, entity->name) ||
      !poolAppendString(pool, entity_end)) {
    poolDiscard(pool);
    return XML_ERROR_NO_MEMORY;
  }

  entity->textPtr = poolStart(pool);
  entity->textLen = (int)(poolLength(pool));
  poolFinish(pool);

  return XML_ERROR_NONE;
}

#endif /* XML_GE == 0 */

static void FASTCALL normalizeLines(XML_Char *s) {
  XML_Char *p;
  for (;; s++) {
    if (*s == XML_T('\0'))
      return;
    if (*s == 0xD)
      break;
  }
  p = s;
  do {
    if (*s == 0xD) {
      *p++ = 0xA;
      if (*++s == 0xA)
        s++;
    } else
      *p++ = *s++;
  } while (*s);
  *p = XML_T('\0');
}

static int reportProcessingInstruction(XML_Parser parser, const ENCODING *enc,
                                       const char *start, const char *end) {
  const XML_Char *target;
  XML_Char *data;
  const char *tem;
  if (!parser->m_processingInstructionHandler) {
    if (parser->m_defaultHandler)
      reportDefault(parser, enc, start, end);
    return 1;
  }
  start += enc->minBytesPerChar * 2;
  tem = start + XmlNameLength(enc, start);
  target = poolStoreString(&parser->m_tempPool, enc, start, tem);
  if (!target)
    return 0;
  poolFinish(&parser->m_tempPool);
  data = poolStoreString(&parser->m_tempPool, enc, XmlSkipS(enc, tem),
                         end - enc->minBytesPerChar * 2);
  if (!data)
    return 0;
  normalizeLines(data);
  parser->m_processingInstructionHandler(parser->m_handlerArg, target, data);
  poolClear(&parser->m_tempPool);
  return 1;
}

static int reportComment(XML_Parser parser, const ENCODING *enc,
                         const char *start, const char *end) {
  XML_Char *data;
  if (!parser->m_commentHandler) {
    if (parser->m_defaultHandler)
      reportDefault(parser, enc, start, end);
    return 1;
  }
  data = poolStoreString(&parser->m_tempPool, enc,
                         start + enc->minBytesPerChar * 4,
                         end - enc->minBytesPerChar * 3);
  if (!data)
    return 0;
  normalizeLines(data);
  parser->m_commentHandler(parser->m_handlerArg, data);
  poolClear(&parser->m_tempPool);
  return 1;
}

static void reportDefault(XML_Parser parser, const ENCODING *enc, const char *s,
                          const char *end) {
  if (MUST_CONVERT(enc, s)) {
    enum XML_Convert_Result convert_res;
    const char **eventPP;
    const char **eventEndPP;
    if (enc == parser->m_encoding) {
      eventPP = &parser->m_eventPtr;
      eventEndPP = &parser->m_eventEndPtr;
    } else {
      /* To get here, two things must be true; the parser must be
       * using a character encoding that is not the same as the
       * encoding passed in, and the encoding passed in must need
       * conversion to the internal format (UTF-8 unless XML_UNICODE
       * is defined).  The only occasions on which the encoding passed
       * in is not the same as the parser's encoding are when it is
       * the internal encoding (e.g. a previously defined parameter
       * entity, already converted to internal format).  This by
       * definition doesn't need conversion, so the whole branch never
       * gets executed.
       *
       * For safety's sake we don't delete these lines and merely
       * exclude them from coverage statistics.
       *
       * LCOV_EXCL_START
       */
      eventPP = &(parser->m_openInternalEntities->internalEventPtr);
      eventEndPP = &(parser->m_openInternalEntities->internalEventEndPtr);
      /* LCOV_EXCL_STOP */
    }
    do {
      ICHAR *dataPtr = (ICHAR *)parser->m_dataBuf;
      convert_res =
          XmlConvert(enc, &s, end, &dataPtr, (ICHAR *)parser->m_dataBufEnd);
      *eventEndPP = s;
      parser->m_defaultHandler(parser->m_handlerArg, parser->m_dataBuf,
                               (int)(dataPtr - (ICHAR *)parser->m_dataBuf));
      *eventPP = s;
    } while ((convert_res != XML_CONVERT_COMPLETED) &&
             (convert_res != XML_CONVERT_INPUT_INCOMPLETE));
  } else
    parser->m_defaultHandler(
        parser->m_handlerArg, (const XML_Char *)s,
        (int)((const XML_Char *)end - (const XML_Char *)s));
}

static int defineAttribute(ELEMENT_TYPE *type, ATTRIBUTE_ID *attId,
                           XML_Bool isCdata, XML_Bool isId,
                           const XML_Char *value, XML_Parser parser) {
  DEFAULT_ATTRIBUTE *att;
  if (value || isId) {
    /* The handling of default attributes gets messed up if we have
       a default which duplicates a non-default. */
    int i;
    for (i = 0; i < type->nDefaultAtts; i++)
      if (attId == type->defaultAtts[i].id)
        return 1;
    if (isId && !type->idAtt && !attId->xmlns)
      type->idAtt = attId;
  }
  if (type->nDefaultAtts == type->allocDefaultAtts) {
    if (type->allocDefaultAtts == 0) {
      type->allocDefaultAtts = 8;
      type->defaultAtts =
          MALLOC(parser, type->allocDefaultAtts * sizeof(DEFAULT_ATTRIBUTE));
      if (!type->defaultAtts) {
        type->allocDefaultAtts = 0;
        return 0;
      }
    } else {
      DEFAULT_ATTRIBUTE *temp;

      /* Detect and prevent integer overflow */
      if (type->allocDefaultAtts > INT_MAX / 2) {
        return 0;
      }

      int count = type->allocDefaultAtts * 2;

      /* Detect and prevent integer overflow.
       * The preprocessor guard addresses the "always false" warning
       * from -Wtype-limits on platforms where
       * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
      if ((unsigned)count > SIZE_MAX / sizeof(DEFAULT_ATTRIBUTE)) {
        return 0;
      }
#endif

      temp = REALLOC(parser, type->defaultAtts,
                     (count * sizeof(DEFAULT_ATTRIBUTE)));
      if (temp == NULL)
        return 0;
      type->allocDefaultAtts = count;
      type->defaultAtts = temp;
    }
  }
  att = type->defaultAtts + type->nDefaultAtts;
  att->id = attId;
  att->value = value;
  att->isCdata = isCdata;
  if (!isCdata)
    attId->maybeTokenized = XML_TRUE;
  type->nDefaultAtts += 1;
  return 1;
}

static int setElementTypePrefix(XML_Parser parser, ELEMENT_TYPE *elementType) {
  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
  const XML_Char *name;
  for (name = elementType->name; *name; name++) {
    if (*name == XML_T(ASCII_COLON)) {
      PREFIX *prefix;
      const XML_Char *s;
      for (s = elementType->name; s != name; s++) {
        if (!poolAppendChar(&dtd->pool, *s))
          return 0;
      }
      if (!poolAppendChar(&dtd->pool, XML_T('\0')))
        return 0;
      prefix = (PREFIX *)lookup(parser, &dtd->prefixes, poolStart(&dtd->pool),
                                sizeof(PREFIX));
      if (!prefix)
        return 0;
      if (prefix->name == poolStart(&dtd->pool))
        poolFinish(&dtd->pool);
      else
        poolDiscard(&dtd->pool);
      elementType->prefix = prefix;
      break;
    }
  }
  return 1;
}

static ATTRIBUTE_ID *getAttributeId(XML_Parser parser, const ENCODING *enc,
                                    const char *start, const char *end) {
  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
  ATTRIBUTE_ID *id;
  const XML_Char *name;
  if (!poolAppendChar(&dtd->pool, XML_T('\0')))
    return NULL;
  name = poolStoreString(&dtd->pool, enc, start, end);
  if (!name)
    return NULL;
  /* skip quotation mark - its storage will be reused (like in name[-1]) */
  ++name;
  id = (ATTRIBUTE_ID *)lookup(parser, &dtd->attributeIds, name,
                              sizeof(ATTRIBUTE_ID));
  if (!id)
    return NULL;
  if (id->name != name)
    poolDiscard(&dtd->pool);
  else {
    poolFinish(&dtd->pool);
    if (!parser->m_ns)
      ;
    else if (name[0] == XML_T(ASCII_x) && name[1] == XML_T(ASCII_m) &&
             name[2] == XML_T(ASCII_l) && name[3] == XML_T(ASCII_n) &&
             name[4] == XML_T(ASCII_s) &&
             (name[5] == XML_T('\0') || name[5] == XML_T(ASCII_COLON))) {
      if (name[5] == XML_T('\0'))
        id->prefix = &dtd->defaultPrefix;
      else
        id->prefix =
            (PREFIX *)lookup(parser, &dtd->prefixes, name + 6, sizeof(PREFIX));
      id->xmlns = XML_TRUE;
    } else {
      int i;
      for (i = 0; name[i]; i++) {
        /* attributes without prefix are *not* in the default namespace */
        if (name[i] == XML_T(ASCII_COLON)) {
          int j;
          for (j = 0; j < i; j++) {
            if (!poolAppendChar(&dtd->pool, name[j]))
              return NULL;
          }
          if (!poolAppendChar(&dtd->pool, XML_T('\0')))
            return NULL;
          id->prefix = (PREFIX *)lookup(parser, &dtd->prefixes,
                                        poolStart(&dtd->pool), sizeof(PREFIX));
          if (!id->prefix)
            return NULL;
          if (id->prefix->name == poolStart(&dtd->pool))
            poolFinish(&dtd->pool);
          else
            poolDiscard(&dtd->pool);
          break;
        }
      }
    }
  }
  return id;
}

#define CONTEXT_SEP XML_T(ASCII_FF)

static const XML_Char *getContext(XML_Parser parser) {
  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
  HASH_TABLE_ITER iter;
  XML_Bool needSep = XML_FALSE;

  if (dtd->defaultPrefix.binding) {
    int i;
    int len;
    if (!poolAppendChar(&parser->m_tempPool, XML_T(ASCII_EQUALS)))
      return NULL;
    len = dtd->defaultPrefix.binding->uriLen;
    if (parser->m_namespaceSeparator)
      len--;
    for (i = 0; i < len; i++) {
      if (!poolAppendChar(&parser->m_tempPool,
                          dtd->defaultPrefix.binding->uri[i])) {
        /* Because of memory caching, I don't believe this line can be
         * executed.
         *
         * This is part of a loop copying the default prefix binding
         * URI into the parser's temporary string pool.  Previously,
         * that URI was copied into the same string pool, with a
         * terminating NUL character, as part of setContext().  When
         * the pool was cleared, that leaves a block definitely big
         * enough to hold the URI on the free block list of the pool.
         * The URI copy in getContext() therefore cannot run out of
         * memory.
         *
         * If the pool is used between the setContext() and
         * getContext() calls, the worst it can do is leave a bigger
         * block on the front of the free list.  Given that this is
         * all somewhat inobvious and program logic can be changed, we
         * don't delete the line but we do exclude it from the test
         * coverage statistics.
         */
        return NULL; /* LCOV_EXCL_LINE */
      }
    }
    needSep = XML_TRUE;
  }

  hashTableIterInit(&iter, &(dtd->prefixes));
  for (;;) {
    int i;
    int len;
    const XML_Char *s;
    PREFIX *prefix = (PREFIX *)hashTableIterNext(&iter);
    if (!prefix)
      break;
    if (!prefix->binding) {
      /* This test appears to be (justifiable) paranoia.  There does
       * not seem to be a way of injecting a prefix without a binding
       * that doesn't get errored long before this function is called.
       * The test should remain for safety's sake, so we instead
       * exclude the following line from the coverage statistics.
       */
      continue; /* LCOV_EXCL_LINE */
    }
    if (needSep && !poolAppendChar(&parser->m_tempPool, CONTEXT_SEP))
      return NULL;
    for (s = prefix->name; *s; s++)
      if (!poolAppendChar(&parser->m_tempPool, *s))
        return NULL;
    if (!poolAppendChar(&parser->m_tempPool, XML_T(ASCII_EQUALS)))
      return NULL;
    len = prefix->binding->uriLen;
    if (parser->m_namespaceSeparator)
      len--;
    for (i = 0; i < len; i++)
      if (!poolAppendChar(&parser->m_tempPool, prefix->binding->uri[i]))
        return NULL;
    needSep = XML_TRUE;
  }

  hashTableIterInit(&iter, &(dtd->generalEntities));
  for (;;) {
    const XML_Char *s;
    ENTITY *e = (ENTITY *)hashTableIterNext(&iter);
    if (!e)
      break;
    if (!e->open)
      continue;
    if (needSep && !poolAppendChar(&parser->m_tempPool, CONTEXT_SEP))
      return NULL;
    for (s = e->name; *s; s++)
      if (!poolAppendChar(&parser->m_tempPool, *s))
        return 0;
    needSep = XML_TRUE;
  }

  if (!poolAppendChar(&parser->m_tempPool, XML_T('\0')))
    return NULL;
  return parser->m_tempPool.start;
}

static XML_Bool setContext(XML_Parser parser, const XML_Char *context) {
  if (context == NULL) {
    return XML_FALSE;
  }

  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
  const XML_Char *s = context;

  while (*context != XML_T('\0')) {
    if (*s == CONTEXT_SEP || *s == XML_T('\0')) {
      ENTITY *e;
      if (!poolAppendChar(&parser->m_tempPool, XML_T('\0')))
        return XML_FALSE;
      e = (ENTITY *)lookup(parser, &dtd->generalEntities,
                           poolStart(&parser->m_tempPool), 0);
      if (e)
        e->open = XML_TRUE;
      if (*s != XML_T('\0'))
        s++;
      context = s;
      poolDiscard(&parser->m_tempPool);
    } else if (*s == XML_T(ASCII_EQUALS)) {
      PREFIX *prefix;
      if (poolLength(&parser->m_tempPool) == 0)
        prefix = &dtd->defaultPrefix;
      else {
        if (!poolAppendChar(&parser->m_tempPool, XML_T('\0')))
          return XML_FALSE;
        prefix =
            (PREFIX *)lookup(parser, &dtd->prefixes,
                             poolStart(&parser->m_tempPool), sizeof(PREFIX));
        if (!prefix)
          return XML_FALSE;
        if (prefix->name == poolStart(&parser->m_tempPool)) {
          prefix->name = poolCopyString(&dtd->pool, prefix->name);
          if (!prefix->name)
            return XML_FALSE;
        }
        poolDiscard(&parser->m_tempPool);
      }
      for (context = s + 1; *context != CONTEXT_SEP && *context != XML_T('\0');
           context++)
        if (!poolAppendChar(&parser->m_tempPool, *context))
          return XML_FALSE;
      if (!poolAppendChar(&parser->m_tempPool, XML_T('\0')))
        return XML_FALSE;
      if (addBinding(parser, prefix, NULL, poolStart(&parser->m_tempPool),
                     &parser->m_inheritedBindings) != XML_ERROR_NONE)
        return XML_FALSE;
      poolDiscard(&parser->m_tempPool);
      if (*context != XML_T('\0'))
        ++context;
      s = context;
    } else {
      if (!poolAppendChar(&parser->m_tempPool, *s))
        return XML_FALSE;
      s++;
    }
  }
  return XML_TRUE;
}

static void FASTCALL normalizePublicId(XML_Char *publicId) {
  XML_Char *p = publicId;
  XML_Char *s;
  for (s = publicId; *s; s++) {
    switch (*s) {
    case 0x20:
    case 0xD:
    case 0xA:
      if (p != publicId && p[-1] != 0x20)
        *p++ = 0x20;
      break;
    default:
      *p++ = *s;
    }
  }
  if (p != publicId && p[-1] == 0x20)
    --p;
  *p = XML_T('\0');
}

static DTD *dtdCreate(XML_Parser parser) {
  DTD *p = MALLOC(parser, sizeof(DTD));
  if (p == NULL)
    return p;
  poolInit(&(p->pool), parser);
  poolInit(&(p->entityValuePool), parser);
  hashTableInit(&(p->generalEntities), parser);
  hashTableInit(&(p->elementTypes), parser);
  hashTableInit(&(p->attributeIds), parser);
  hashTableInit(&(p->prefixes), parser);
#ifdef XML_DTD
  p->paramEntityRead = XML_FALSE;
  hashTableInit(&(p->paramEntities), parser);
#endif /* XML_DTD */
  p->defaultPrefix.name = NULL;
  p->defaultPrefix.binding = NULL;

  p->in_eldecl = XML_FALSE;
  p->scaffIndex = NULL;
  p->scaffold = NULL;
  p->scaffLevel = 0;
  p->scaffSize = 0;
  p->scaffCount = 0;
  p->contentStringLen = 0;

  p->keepProcessing = XML_TRUE;
  p->hasParamEntityRefs = XML_FALSE;
  p->standalone = XML_FALSE;
  return p;
}

static void dtdReset(DTD *p, XML_Parser parser) {
  HASH_TABLE_ITER iter;
  hashTableIterInit(&iter, &(p->elementTypes));
  for (;;) {
    ELEMENT_TYPE *e = (ELEMENT_TYPE *)hashTableIterNext(&iter);
    if (!e)
      break;
    if (e->allocDefaultAtts != 0)
      FREE(parser, e->defaultAtts);
  }
  hashTableClear(&(p->generalEntities));
#ifdef XML_DTD
  p->paramEntityRead = XML_FALSE;
  hashTableClear(&(p->paramEntities));
#endif /* XML_DTD */
  hashTableClear(&(p->elementTypes));
  hashTableClear(&(p->attributeIds));
  hashTableClear(&(p->prefixes));
  poolClear(&(p->pool));
  poolClear(&(p->entityValuePool));
  p->defaultPrefix.name = NULL;
  p->defaultPrefix.binding = NULL;

  p->in_eldecl = XML_FALSE;

  FREE(parser, p->scaffIndex);
  p->scaffIndex = NULL;
  FREE(parser, p->scaffold);
  p->scaffold = NULL;

  p->scaffLevel = 0;
  p->scaffSize = 0;
  p->scaffCount = 0;
  p->contentStringLen = 0;

  p->keepProcessing = XML_TRUE;
  p->hasParamEntityRefs = XML_FALSE;
  p->standalone = XML_FALSE;
}

static void dtdDestroy(DTD *p, XML_Bool isDocEntity, XML_Parser parser) {
  HASH_TABLE_ITER iter;
  hashTableIterInit(&iter, &(p->elementTypes));
  for (;;) {
    ELEMENT_TYPE *e = (ELEMENT_TYPE *)hashTableIterNext(&iter);
    if (!e)
      break;
    if (e->allocDefaultAtts != 0)
      FREE(parser, e->defaultAtts);
  }
  hashTableDestroy(&(p->generalEntities));
#ifdef XML_DTD
  hashTableDestroy(&(p->paramEntities));
#endif /* XML_DTD */
  hashTableDestroy(&(p->elementTypes));
  hashTableDestroy(&(p->attributeIds));
  hashTableDestroy(&(p->prefixes));
  poolDestroy(&(p->pool));
  poolDestroy(&(p->entityValuePool));
  if (isDocEntity) {
    FREE(parser, p->scaffIndex);
    FREE(parser, p->scaffold);
  }
  FREE(parser, p);
}

/* Do a deep copy of the DTD. Return 0 for out of memory, non-zero otherwise.
   The new DTD has already been initialized.
*/
static int dtdCopy(XML_Parser oldParser, DTD *newDtd, const DTD *oldDtd,
                   XML_Parser parser) {
  HASH_TABLE_ITER iter;

  /* Copy the prefix table. */

  hashTableIterInit(&iter, &(oldDtd->prefixes));
  for (;;) {
    const XML_Char *name;
    const PREFIX *oldP = (PREFIX *)hashTableIterNext(&iter);
    if (!oldP)
      break;
    name = poolCopyString(&(newDtd->pool), oldP->name);
    if (!name)
      return 0;
    if (!lookup(oldParser, &(newDtd->prefixes), name, sizeof(PREFIX)))
      return 0;
  }

  hashTableIterInit(&iter, &(oldDtd->attributeIds));

  /* Copy the attribute id table. */

  for (;;) {
    ATTRIBUTE_ID *newA;
    const XML_Char *name;
    const ATTRIBUTE_ID *oldA = (ATTRIBUTE_ID *)hashTableIterNext(&iter);

    if (!oldA)
      break;
    /* Remember to allocate the scratch byte before the name. */
    if (!poolAppendChar(&(newDtd->pool), XML_T('\0')))
      return 0;
    name = poolCopyString(&(newDtd->pool), oldA->name);
    if (!name)
      return 0;
    ++name;
    newA = (ATTRIBUTE_ID *)lookup(oldParser, &(newDtd->attributeIds), name,
                                  sizeof(ATTRIBUTE_ID));
    if (!newA)
      return 0;
    newA->maybeTokenized = oldA->maybeTokenized;
    if (oldA->prefix) {
      newA->xmlns = oldA->xmlns;
      if (oldA->prefix == &oldDtd->defaultPrefix)
        newA->prefix = &newDtd->defaultPrefix;
      else
        newA->prefix = (PREFIX *)lookup(oldParser, &(newDtd->prefixes),
                                        oldA->prefix->name, 0);
    }
  }

  /* Copy the element type table. */

  hashTableIterInit(&iter, &(oldDtd->elementTypes));

  for (;;) {
    int i;
    ELEMENT_TYPE *newE;
    const XML_Char *name;
    const ELEMENT_TYPE *oldE = (ELEMENT_TYPE *)hashTableIterNext(&iter);
    if (!oldE)
      break;
    name = poolCopyString(&(newDtd->pool), oldE->name);
    if (!name)
      return 0;
    newE = (ELEMENT_TYPE *)lookup(oldParser, &(newDtd->elementTypes), name,
                                  sizeof(ELEMENT_TYPE));
    if (!newE)
      return 0;
    if (oldE->nDefaultAtts) {
      /* Detect and prevent integer overflow.
       * The preprocessor guard addresses the "always false" warning
       * from -Wtype-limits on platforms where
       * sizeof(int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
      if ((size_t)oldE->nDefaultAtts > SIZE_MAX / sizeof(DEFAULT_ATTRIBUTE)) {
        return 0;
      }
#endif
      newE->defaultAtts =
          MALLOC(parser, oldE->nDefaultAtts * sizeof(DEFAULT_ATTRIBUTE));
      if (!newE->defaultAtts) {
        return 0;
      }
    }
    if (oldE->idAtt)
      newE->idAtt = (ATTRIBUTE_ID *)lookup(oldParser, &(newDtd->attributeIds),
                                           oldE->idAtt->name, 0);
    newE->allocDefaultAtts = newE->nDefaultAtts = oldE->nDefaultAtts;
    if (oldE->prefix)
      newE->prefix = (PREFIX *)lookup(oldParser, &(newDtd->prefixes),
                                      oldE->prefix->name, 0);
    for (i = 0; i < newE->nDefaultAtts; i++) {
      newE->defaultAtts[i].id = (ATTRIBUTE_ID *)lookup(
          oldParser, &(newDtd->attributeIds), oldE->defaultAtts[i].id->name, 0);
      newE->defaultAtts[i].isCdata = oldE->defaultAtts[i].isCdata;
      if (oldE->defaultAtts[i].value) {
        newE->defaultAtts[i].value =
            poolCopyString(&(newDtd->pool), oldE->defaultAtts[i].value);
        if (!newE->defaultAtts[i].value)
          return 0;
      } else
        newE->defaultAtts[i].value = NULL;
    }
  }

  /* Copy the entity tables. */
  if (!copyEntityTable(oldParser, &(newDtd->generalEntities), &(newDtd->pool),
                       &(oldDtd->generalEntities)))
    return 0;

#ifdef XML_DTD
  if (!copyEntityTable(oldParser, &(newDtd->paramEntities), &(newDtd->pool),
                       &(oldDtd->paramEntities)))
    return 0;
  newDtd->paramEntityRead = oldDtd->paramEntityRead;
#endif /* XML_DTD */

  newDtd->keepProcessing = oldDtd->keepProcessing;
  newDtd->hasParamEntityRefs = oldDtd->hasParamEntityRefs;
  newDtd->standalone = oldDtd->standalone;

  /* Don't want deep copying for scaffolding */
  newDtd->in_eldecl = oldDtd->in_eldecl;
  newDtd->scaffold = oldDtd->scaffold;
  newDtd->contentStringLen = oldDtd->contentStringLen;
  newDtd->scaffSize = oldDtd->scaffSize;
  newDtd->scaffLevel = oldDtd->scaffLevel;
  newDtd->scaffIndex = oldDtd->scaffIndex;

  return 1;
} /* End dtdCopy */

static int copyEntityTable(XML_Parser oldParser, HASH_TABLE *newTable,
                           STRING_POOL *newPool, const HASH_TABLE *oldTable) {
  HASH_TABLE_ITER iter;
  const XML_Char *cachedOldBase = NULL;
  const XML_Char *cachedNewBase = NULL;

  hashTableIterInit(&iter, oldTable);

  for (;;) {
    ENTITY *newE;
    const XML_Char *name;
    const ENTITY *oldE = (ENTITY *)hashTableIterNext(&iter);
    if (!oldE)
      break;
    name = poolCopyString(newPool, oldE->name);
    if (!name)
      return 0;
    newE = (ENTITY *)lookup(oldParser, newTable, name, sizeof(ENTITY));
    if (!newE)
      return 0;
    if (oldE->systemId) {
      const XML_Char *tem = poolCopyString(newPool, oldE->systemId);
      if (!tem)
        return 0;
      newE->systemId = tem;
      if (oldE->base) {
        if (oldE->base == cachedOldBase)
          newE->base = cachedNewBase;
        else {
          cachedOldBase = oldE->base;
          tem = poolCopyString(newPool, cachedOldBase);
          if (!tem)
            return 0;
          cachedNewBase = newE->base = tem;
        }
      }
      if (oldE->publicId) {
        tem = poolCopyString(newPool, oldE->publicId);
        if (!tem)
          return 0;
        newE->publicId = tem;
      }
    } else {
      const XML_Char *tem =
          poolCopyStringN(newPool, oldE->textPtr, oldE->textLen);
      if (!tem)
        return 0;
      newE->textPtr = tem;
      newE->textLen = oldE->textLen;
    }
    if (oldE->notation) {
      const XML_Char *tem = poolCopyString(newPool, oldE->notation);
      if (!tem)
        return 0;
      newE->notation = tem;
    }
    newE->is_param = oldE->is_param;
    newE->is_internal = oldE->is_internal;
  }
  return 1;
}

#define INIT_POWER 6

static XML_Bool FASTCALL keyeq(KEY s1, KEY s2) {
  for (; *s1 == *s2; s1++, s2++)
    if (*s1 == 0)
      return XML_TRUE;
  return XML_FALSE;
}

static size_t keylen(KEY s) {
  size_t len = 0;
  for (; *s; s++, len++)
    ;
  return len;
}

static void copy_salt_to_sipkey(XML_Parser parser, struct sipkey *key) {
  key->k[0] = 0;
  key->k[1] = get_hash_secret_salt(parser);
}

static unsigned long FASTCALL hash(XML_Parser parser, KEY s) {
  struct siphash state;
  struct sipkey key;
  (void)sip24_valid;
  copy_salt_to_sipkey(parser, &key);
  sip24_init(&state, &key);
  sip24_update(&state, s, keylen(s) * sizeof(XML_Char));
  return (unsigned long)sip24_final(&state);
}

static NAMED *lookup(XML_Parser parser, HASH_TABLE *table, KEY name,
                     size_t createSize) {
  size_t i;
  if (table->size == 0) {
    size_t tsize;
    if (!createSize)
      return NULL;
    table->power = INIT_POWER;
    /* table->size is a power of 2 */
    table->size = (size_t)1 << INIT_POWER;
    tsize = table->size * sizeof(NAMED *);
    table->v = MALLOC(table->parser, tsize);
    if (!table->v) {
      table->size = 0;
      return NULL;
    }
    memset(table->v, 0, tsize);
    i = hash(parser, name) & ((unsigned long)table->size - 1);
  } else {
    unsigned long h = hash(parser, name);
    unsigned long mask = (unsigned long)table->size - 1;
    unsigned char step = 0;
    i = h & mask;
    while (table->v[i]) {
      if (keyeq(name, table->v[i]->name))
        return table->v[i];
      if (!step)
        step = PROBE_STEP(h, mask, table->power);
      i < step ? (i += table->size - step) : (i -= step);
    }
    if (!createSize)
      return NULL;

    /* check for overflow (table is half full) */
    if (table->used >> (table->power - 1)) {
      unsigned char newPower = table->power + 1;

      /* Detect and prevent invalid shift */
      if (newPower >= sizeof(unsigned long) * 8 /* bits per byte */) {
        return NULL;
      }

      size_t newSize = (size_t)1 << newPower;
      unsigned long newMask = (unsigned long)newSize - 1;

      /* Detect and prevent integer overflow */
      if (newSize > SIZE_MAX / sizeof(NAMED *)) {
        return NULL;
      }

      size_t tsize = newSize * sizeof(NAMED *);
      NAMED **newV = MALLOC(table->parser, tsize);
      if (!newV)
        return NULL;
      memset(newV, 0, tsize);
      for (i = 0; i < table->size; i++)
        if (table->v[i]) {
          unsigned long newHash = hash(parser, table->v[i]->name);
          size_t j = newHash & newMask;
          step = 0;
          while (newV[j]) {
            if (!step)
              step = PROBE_STEP(newHash, newMask, newPower);
            j < step ? (j += newSize - step) : (j -= step);
          }
          newV[j] = table->v[i];
        }
      FREE(table->parser, table->v);
      table->v = newV;
      table->power = newPower;
      table->size = newSize;
      i = h & newMask;
      step = 0;
      while (table->v[i]) {
        if (!step)
          step = PROBE_STEP(h, newMask, newPower);
        i < step ? (i += newSize - step) : (i -= step);
      }
    }
  }
  table->v[i] = MALLOC(table->parser, createSize);
  if (!table->v[i])
    return NULL;
  memset(table->v[i], 0, createSize);
  table->v[i]->name = name;
  (table->used)++;
  return table->v[i];
}

static void FASTCALL hashTableClear(HASH_TABLE *table) {
  size_t i;
  for (i = 0; i < table->size; i++) {
    FREE(table->parser, table->v[i]);
    table->v[i] = NULL;
  }
  table->used = 0;
}

static void FASTCALL hashTableDestroy(HASH_TABLE *table) {
  size_t i;
  for (i = 0; i < table->size; i++)
    FREE(table->parser, table->v[i]);
  FREE(table->parser, table->v);
}

static void FASTCALL hashTableInit(HASH_TABLE *p, XML_Parser parser) {
  p->power = 0;
  p->size = 0;
  p->used = 0;
  p->v = NULL;
  p->parser = parser;
}

static void FASTCALL hashTableIterInit(HASH_TABLE_ITER *iter,
                                       const HASH_TABLE *table) {
  iter->p = table->v;
  iter->end = iter->p ? iter->p + table->size : NULL;
}

static NAMED *FASTCALL hashTableIterNext(HASH_TABLE_ITER *iter) {
  while (iter->p != iter->end) {
    NAMED *tem = *(iter->p)++;
    if (tem)
      return tem;
  }
  return NULL;
}

static void FASTCALL poolInit(STRING_POOL *pool, XML_Parser parser) {
  pool->blocks = NULL;
  pool->freeBlocks = NULL;
  pool->start = NULL;
  pool->ptr = NULL;
  pool->end = NULL;
  pool->parser = parser;
}

static void FASTCALL poolClear(STRING_POOL *pool) {
  if (!pool->freeBlocks)
    pool->freeBlocks = pool->blocks;
  else {
    BLOCK *p = pool->blocks;
    while (p) {
      BLOCK *tem = p->next;
      p->next = pool->freeBlocks;
      pool->freeBlocks = p;
      p = tem;
    }
  }
  pool->blocks = NULL;
  pool->start = NULL;
  pool->ptr = NULL;
  pool->end = NULL;
}

static void FASTCALL poolDestroy(STRING_POOL *pool) {
  BLOCK *p = pool->blocks;
  while (p) {
    BLOCK *tem = p->next;
    FREE(pool->parser, p);
    p = tem;
  }
  p = pool->freeBlocks;
  while (p) {
    BLOCK *tem = p->next;
    FREE(pool->parser, p);
    p = tem;
  }
}

static XML_Char *poolAppend(STRING_POOL *pool, const ENCODING *enc,
                            const char *ptr, const char *end) {
  if (!pool->ptr && !poolGrow(pool))
    return NULL;
  for (;;) {
    const enum XML_Convert_Result convert_res = XmlConvert(
        enc, &ptr, end, (ICHAR **)&(pool->ptr), (const ICHAR *)pool->end);
    if ((convert_res == XML_CONVERT_COMPLETED) ||
        (convert_res == XML_CONVERT_INPUT_INCOMPLETE))
      break;
    if (!poolGrow(pool))
      return NULL;
  }
  return pool->start;
}

static const XML_Char *FASTCALL poolCopyString(STRING_POOL *pool,
                                               const XML_Char *s) {
  do {
    if (!poolAppendChar(pool, *s))
      return NULL;
  } while (*s++);
  s = pool->start;
  poolFinish(pool);
  return s;
}

static const XML_Char *poolCopyStringN(STRING_POOL *pool, const XML_Char *s,
                                       int n) {
  if (!pool->ptr && !poolGrow(pool)) {
    /* The following line is unreachable given the current usage of
     * poolCopyStringN().  Currently it is called from exactly one
     * place to copy the text of a simple general entity.  By that
     * point, the name of the entity is already stored in the pool, so
     * pool->ptr cannot be NULL.
     *
     * If poolCopyStringN() is used elsewhere as it well might be,
     * this line may well become executable again.  Regardless, this
     * sort of check shouldn't be removed lightly, so we just exclude
     * it from the coverage statistics.
     */
    return NULL; /* LCOV_EXCL_LINE */
  }
  for (; n > 0; --n, s++) {
    if (!poolAppendChar(pool, *s))
      return NULL;
  }
  s = pool->start;
  poolFinish(pool);
  return s;
}

static const XML_Char *FASTCALL poolAppendString(STRING_POOL *pool,
                                                 const XML_Char *s) {
  while (*s) {
    if (!poolAppendChar(pool, *s))
      return NULL;
    s++;
  }
  return pool->start;
}

static XML_Char *poolStoreString(STRING_POOL *pool, const ENCODING *enc,
                                 const char *ptr, const char *end) {
  if (!poolAppend(pool, enc, ptr, end))
    return NULL;
  if (pool->ptr == pool->end && !poolGrow(pool))
    return NULL;
  *(pool->ptr)++ = 0;
  return pool->start;
}

static size_t poolBytesToAllocateFor(int blockSize) {
  /* Unprotected math would be:
  ** return offsetof(BLOCK, s) + blockSize * sizeof(XML_Char);
  **
  ** Detect overflow, avoiding _signed_ overflow undefined behavior
  ** For a + b * c we check b * c in isolation first, so that addition of a
  ** on top has no chance of making us accept a small non-negative number
  */
  const size_t stretch = sizeof(XML_Char); /* can be 4 bytes */

  if (blockSize <= 0)
    return 0;

  if (blockSize > (int)(INT_MAX / stretch))
    return 0;

  {
    const int stretchedBlockSize = blockSize * (int)stretch;
    const int bytesToAllocate =
        (int)(offsetof(BLOCK, s) + (unsigned)stretchedBlockSize);
    if (bytesToAllocate < 0)
      return 0;

    return (size_t)bytesToAllocate;
  }
}

static XML_Bool FASTCALL poolGrow(STRING_POOL *pool) {
  if (pool->freeBlocks) {
    if (pool->start == NULL) {
      pool->blocks = pool->freeBlocks;
      pool->freeBlocks = pool->freeBlocks->next;
      pool->blocks->next = NULL;
      pool->start = pool->blocks->s;
      pool->end = pool->start + pool->blocks->size;
      pool->ptr = pool->start;
      return XML_TRUE;
    }
    if (pool->end - pool->start < pool->freeBlocks->size) {
      BLOCK *tem = pool->freeBlocks->next;
      pool->freeBlocks->next = pool->blocks;
      pool->blocks = pool->freeBlocks;
      pool->freeBlocks = tem;
      memcpy(pool->blocks->s, pool->start,
             (pool->end - pool->start) * sizeof(XML_Char));
      pool->ptr = pool->blocks->s + (pool->ptr - pool->start);
      pool->start = pool->blocks->s;
      pool->end = pool->start + pool->blocks->size;
      return XML_TRUE;
    }
  }
  if (pool->blocks && pool->start == pool->blocks->s) {
    BLOCK *temp;
    int blockSize = (int)((unsigned)(pool->end - pool->start) * 2U);
    size_t bytesToAllocate;

    /* NOTE: Needs to be calculated prior to calling `realloc`
             to avoid dangling pointers: */
    const ptrdiff_t offsetInsideBlock = pool->ptr - pool->start;

    if (blockSize < 0) {
      /* This condition traps a situation where either more than
       * INT_MAX/2 bytes have already been allocated.  This isn't
       * readily testable, since it is unlikely that an average
       * machine will have that much memory, so we exclude it from the
       * coverage statistics.
       */
      return XML_FALSE; /* LCOV_EXCL_LINE */
    }

    bytesToAllocate = poolBytesToAllocateFor(blockSize);
    if (bytesToAllocate == 0)
      return XML_FALSE;

    temp = REALLOC(pool->parser, pool->blocks, bytesToAllocate);
    if (temp == NULL)
      return XML_FALSE;
    pool->blocks = temp;
    pool->blocks->size = blockSize;
    pool->ptr = pool->blocks->s + offsetInsideBlock;
    pool->start = pool->blocks->s;
    pool->end = pool->start + blockSize;
  } else {
    BLOCK *tem;
    int blockSize = (int)(pool->end - pool->start);
    size_t bytesToAllocate;

    if (blockSize < 0) {
      /* This condition traps a situation where either more than
       * INT_MAX bytes have already been allocated (which is prevented
       * by various pieces of program logic, not least this one, never
       * mind the unlikelihood of actually having that much memory) or
       * the pool control fields have been corrupted (which could
       * conceivably happen in an extremely buggy user handler
       * function).  Either way it isn't readily testable, so we
       * exclude it from the coverage statistics.
       */
      return XML_FALSE; /* LCOV_EXCL_LINE */
    }

    if (blockSize < INIT_BLOCK_SIZE)
      blockSize = INIT_BLOCK_SIZE;
    else {
      /* Detect overflow, avoiding _signed_ overflow undefined behavior */
      if ((int)((unsigned)blockSize * 2U) < 0) {
        return XML_FALSE;
      }
      blockSize *= 2;
    }

    bytesToAllocate = poolBytesToAllocateFor(blockSize);
    if (bytesToAllocate == 0)
      return XML_FALSE;

    tem = MALLOC(pool->parser, bytesToAllocate);
    if (!tem)
      return XML_FALSE;
    tem->size = blockSize;
    tem->next = pool->blocks;
    pool->blocks = tem;
    if (pool->ptr != pool->start)
      memcpy(tem->s, pool->start, (pool->ptr - pool->start) * sizeof(XML_Char));
    pool->ptr = tem->s + (pool->ptr - pool->start);
    pool->start = tem->s;
    pool->end = tem->s + blockSize;
  }
  return XML_TRUE;
}

static int FASTCALL nextScaffoldPart(XML_Parser parser) {
  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
  CONTENT_SCAFFOLD *me;
  int next;

  if (!dtd->scaffIndex) {
    /* Detect and prevent integer overflow.
     * The preprocessor guard addresses the "always false" warning
     * from -Wtype-limits on platforms where
     * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
    if (parser->m_groupSize > SIZE_MAX / sizeof(int)) {
      return -1;
    }
#endif
    dtd->scaffIndex = MALLOC(parser, parser->m_groupSize * sizeof(int));
    if (!dtd->scaffIndex)
      return -1;
    dtd->scaffIndex[0] = 0;
  }

  // Will casting to int be safe further down?
  if (dtd->scaffCount > INT_MAX) {
    return -1;
  }

  if (dtd->scaffCount >= dtd->scaffSize) {
    CONTENT_SCAFFOLD *temp;
    if (dtd->scaffold) {
      /* Detect and prevent integer overflow */
      if (dtd->scaffSize > UINT_MAX / 2u) {
        return -1;
      }
      /* Detect and prevent integer overflow.
       * The preprocessor guard addresses the "always false" warning
       * from -Wtype-limits on platforms where
       * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
      if (dtd->scaffSize > SIZE_MAX / 2u / sizeof(CONTENT_SCAFFOLD)) {
        return -1;
      }
#endif

      temp = REALLOC(parser, dtd->scaffold,
                     dtd->scaffSize * 2 * sizeof(CONTENT_SCAFFOLD));
      if (temp == NULL)
        return -1;
      dtd->scaffSize *= 2;
    } else {
      temp = MALLOC(parser, INIT_SCAFFOLD_ELEMENTS * sizeof(CONTENT_SCAFFOLD));
      if (temp == NULL)
        return -1;
      dtd->scaffSize = INIT_SCAFFOLD_ELEMENTS;
    }
    dtd->scaffold = temp;
  }
  next = (int)dtd->scaffCount++;
  me = &dtd->scaffold[next];
  if (dtd->scaffLevel) {
    CONTENT_SCAFFOLD *parent =
        &dtd->scaffold[dtd->scaffIndex[dtd->scaffLevel - 1]];
    if (parent->lastchild) {
      dtd->scaffold[parent->lastchild].nextsib = next;
    }
    if (!parent->childcnt)
      parent->firstchild = next;
    parent->lastchild = next;
    parent->childcnt++;
  }
  me->firstchild = me->lastchild = me->childcnt = me->nextsib = 0;
  return next;
}

static XML_Content *build_model(XML_Parser parser) {
  /* Function build_model transforms the existing parser->m_dtd->scaffold
   * array of CONTENT_SCAFFOLD tree nodes into a new array of
   * XML_Content tree nodes followed by a gapless list of zero-terminated
   * strings. */
  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
  XML_Content *ret;
  XML_Char *str; /* the current string writing location */

  /* Detect and prevent integer overflow.
   * The preprocessor guard addresses the "always false" warning
   * from -Wtype-limits on platforms where
   * sizeof(unsigned int) < sizeof(size_t), e.g. on x86_64. */
#if UINT_MAX >= SIZE_MAX
  if (dtd->scaffCount > SIZE_MAX / sizeof(XML_Content)) {
    return NULL;
  }
  if (dtd->contentStringLen > SIZE_MAX / sizeof(XML_Char)) {
    return NULL;
  }
#endif
  if (dtd->scaffCount * sizeof(XML_Content) >
      SIZE_MAX - dtd->contentStringLen * sizeof(XML_Char)) {
    return NULL;
  }

  const size_t allocsize = (dtd->scaffCount * sizeof(XML_Content) +
                            (dtd->contentStringLen * sizeof(XML_Char)));

  // NOTE: We are avoiding MALLOC(..) here to so that
  //       applications that are not using XML_FreeContentModel but plain
  //       free(..) or .free_fcn() to free the content model's memory are safe.
  ret = parser->m_mem.malloc_fcn(allocsize);
  if (!ret)
    return NULL;

  /* What follows is an iterative implementation (of what was previously done
   * recursively in a dedicated function called "build_node".  The old recursive
   * build_node could be forced into stack exhaustion from input as small as a
   * few megabyte, and so that was a security issue.  Hence, a function call
   * stack is avoided now by resolving recursion.)
   *
   * The iterative approach works as follows:
   *
   * - We have two writing pointers, both walking up the result array; one does
   *   the work, the other creates "jobs" for its colleague to do, and leads
   *   the way:
   *
   *   - The faster one, pointer jobDest, always leads and writes "what job
   *     to do" by the other, once they reach that place in the
   *     array: leader "jobDest" stores the source node array index (relative
   *     to array dtd->scaffold) in field "numchildren".
   *
   *   - The slower one, pointer dest, looks at the value stored in the
   *     "numchildren" field (which actually holds a source node array index
   *     at that time) and puts the real data from dtd->scaffold in.
   *
   * - Before the loop starts, jobDest writes source array index 0
   *   (where the root node is located) so that dest will have something to do
   *   when it starts operation.
   *
   * - Whenever nodes with children are encountered, jobDest appends
   *   them as new jobs, in order.  As a result, tree node siblings are
   *   adjacent in the resulting array, for example:
   *
   *     [0] root, has two children
   *       [1] first child of 0, has three children
   *         [3] first child of 1, does not have children
   *         [4] second child of 1, does not have children
   *         [5] third child of 1, does not have children
   *       [2] second child of 0, does not have children
   *
   *   Or (the same data) presented in flat array view:
   *
   *     [0] root, has two children
   *
   *     [1] first child of 0, has three children
   *     [2] second child of 0, does not have children
   *
   *     [3] first child of 1, does not have children
   *     [4] second child of 1, does not have children
   *     [5] third child of 1, does not have children
   *
   * - The algorithm repeats until all target array indices have been processed.
   */
  XML_Content *dest = ret; /* tree node writing location, moves upwards */
  XML_Content *const destLimit = &ret[dtd->scaffCount];
  XML_Content *jobDest = ret; /* next free writing location in target array */
  str = (XML_Char *)&ret[dtd->scaffCount];

  /* Add the starting job, the root node (index 0) of the source tree  */
  (jobDest++)->numchildren = 0;

  for (; dest < destLimit; dest++) {
    /* Retrieve source tree array index from job storage */
    const int src_node = (int)dest->numchildren;

    /* Convert item */
    dest->type = dtd->scaffold[src_node].type;
    dest->quant = dtd->scaffold[src_node].quant;
    if (dest->type == XML_CTYPE_NAME) {
      const XML_Char *src;
      dest->name = str;
      src = dtd->scaffold[src_node].name;
      for (;;) {
        *str++ = *src;
        if (!*src)
          break;
        src++;
      }
      dest->numchildren = 0;
      dest->children = NULL;
    } else {
      unsigned int i;
      int cn;
      dest->name = NULL;
      dest->numchildren = dtd->scaffold[src_node].childcnt;
      dest->children = jobDest;

      /* Append scaffold indices of children to array */
      for (i = 0, cn = dtd->scaffold[src_node].firstchild;
           i < dest->numchildren; i++, cn = dtd->scaffold[cn].nextsib)
        (jobDest++)->numchildren = (unsigned int)cn;
    }
  }

  return ret;
}

static ELEMENT_TYPE *getElementType(XML_Parser parser, const ENCODING *enc,
                                    const char *ptr, const char *end) {
  DTD *const dtd = parser->m_dtd; /* save one level of indirection */
  const XML_Char *name = poolStoreString(&dtd->pool, enc, ptr, end);
  ELEMENT_TYPE *ret;

  if (!name)
    return NULL;
  ret = (ELEMENT_TYPE *)lookup(parser, &dtd->elementTypes, name,
                               sizeof(ELEMENT_TYPE));
  if (!ret)
    return NULL;
  if (ret->name != name)
    poolDiscard(&dtd->pool);
  else {
    poolFinish(&dtd->pool);
    if (!setElementTypePrefix(parser, ret))
      return NULL;
  }
  return ret;
}

static XML_Char *copyString(const XML_Char *s, XML_Parser parser) {
  size_t charsRequired = 0;
  XML_Char *result;

  /* First determine how long the string is */
  while (s[charsRequired] != 0) {
    charsRequired++;
  }
  /* Include the terminator */
  charsRequired++;

  /* Now allocate space for the copy */
  result = MALLOC(parser, charsRequired * sizeof(XML_Char));
  if (result == NULL)
    return NULL;
  /* Copy the original into place */
  memcpy(result, s, charsRequired * sizeof(XML_Char));
  return result;
}

#if XML_GE == 1

static float accountingGetCurrentAmplification(XML_Parser rootParser) {
  //                                          1.........1.........12 => 22
  const size_t lenOfShortestInclude = sizeof("<!ENTITY a SYSTEM 'b'>") - 1;
  const XmlBigCount countBytesOutput =
      rootParser->m_accounting.countBytesDirect +
      rootParser->m_accounting.countBytesIndirect;
  const float amplificationFactor =
      rootParser->m_accounting.countBytesDirect
          ? ((float)countBytesOutput /
             (float)(rootParser->m_accounting.countBytesDirect))
          : ((float)(lenOfShortestInclude +
                     rootParser->m_accounting.countBytesIndirect) /
             (float)lenOfShortestInclude);
  assert(!rootParser->m_parentParser);
  return amplificationFactor;
}

static void accountingReportStats(XML_Parser originParser, const char *epilog) {
  const XML_Parser rootParser = getRootParserOf(originParser, NULL);
  assert(!rootParser->m_parentParser);

  if (rootParser->m_accounting.debugLevel == 0u) {
    return;
  }

  const float amplificationFactor =
      accountingGetCurrentAmplification(rootParser);
  fprintf(stderr,
          "expat: Accounting(%p): Direct " EXPAT_FMT_ULL(
              "10") ", indirect " EXPAT_FMT_ULL("10") ", amplification %8.2f%s",
          (void *)rootParser, rootParser->m_accounting.countBytesDirect,
          rootParser->m_accounting.countBytesIndirect,
          (double)amplificationFactor, epilog);
}

static void accountingOnAbort(XML_Parser originParser) {
  accountingReportStats(originParser, " ABORTING\n");
}

static void accountingReportDiff(XML_Parser rootParser,
                                 unsigned int levelsAwayFromRootParser,
                                 const char *before, const char *after,
                                 ptrdiff_t bytesMore, int source_line,
                                 enum XML_Account account) {
  assert(!rootParser->m_parentParser);

  fprintf(stderr,
          " (+" EXPAT_FMT_PTRDIFF_T("6") " bytes %s|%u, xmlparse.c:%d) %*s\"",
          bytesMore, (account == XML_ACCOUNT_DIRECT) ? "DIR" : "EXP",
          levelsAwayFromRootParser, source_line, 10, "");

  const char ellipis[] = "[..]";
  const size_t ellipsisLength = sizeof(ellipis) /* because compile-time */ - 1;
  const unsigned int contextLength = 10;

  /* Note: Performance is of no concern here */
  const char *walker = before;
  if ((rootParser->m_accounting.debugLevel >= 3u) ||
      (after - before) <=
          (ptrdiff_t)(contextLength + ellipsisLength + contextLength)) {
    for (; walker < after; walker++) {
      fprintf(stderr, "%s", unsignedCharToPrintable(walker[0]));
    }
  } else {
    for (; walker < before + contextLength; walker++) {
      fprintf(stderr, "%s", unsignedCharToPrintable(walker[0]));
    }
    fprintf(stderr, ellipis);
    walker = after - contextLength;
    for (; walker < after; walker++) {
      fprintf(stderr, "%s", unsignedCharToPrintable(walker[0]));
    }
  }
  fprintf(stderr, "\"\n");
}

static XML_Bool accountingDiffTolerated(XML_Parser originParser, int tok,
                                        const char *before, const char *after,
                                        int source_line,
                                        enum XML_Account account) {
  /* Note: We need to check the token type *first* to be sure that
   *       we can even access variable <after>, safely.
   *       E.g. for XML_TOK_NONE <after> may hold an invalid pointer. */
  switch (tok) {
  case XML_TOK_INVALID:
  case XML_TOK_PARTIAL:
  case XML_TOK_PARTIAL_CHAR:
  case XML_TOK_NONE:
    return XML_TRUE;
  }

  if (account == XML_ACCOUNT_NONE)
    return XML_TRUE; /* because these bytes have been accounted for, already */

  unsigned int levelsAwayFromRootParser;
  const XML_Parser rootParser =
      getRootParserOf(originParser, &levelsAwayFromRootParser);
  assert(!rootParser->m_parentParser);

  const int isDirect =
      (account == XML_ACCOUNT_DIRECT) && (originParser == rootParser);
  const ptrdiff_t bytesMore = after - before;

  XmlBigCount *const additionTarget =
      isDirect ? &rootParser->m_accounting.countBytesDirect
               : &rootParser->m_accounting.countBytesIndirect;

  /* Detect and avoid integer overflow */
  if (*additionTarget > (XmlBigCount)(-1) - (XmlBigCount)bytesMore)
    return XML_FALSE;
  *additionTarget += bytesMore;

  const XmlBigCount countBytesOutput =
      rootParser->m_accounting.countBytesDirect +
      rootParser->m_accounting.countBytesIndirect;
  const float amplificationFactor =
      accountingGetCurrentAmplification(rootParser);
  const XML_Bool tolerated =
      (countBytesOutput < rootParser->m_accounting.activationThresholdBytes) ||
      (amplificationFactor <=
       rootParser->m_accounting.maximumAmplificationFactor);

  if (rootParser->m_accounting.debugLevel >= 2u) {
    accountingReportStats(rootParser, "");
    accountingReportDiff(rootParser, levelsAwayFromRootParser, before, after,
                         bytesMore, source_line, account);
  }

  return tolerated;
}

unsigned long long testingAccountingGetCountBytesDirect(XML_Parser parser) {
  if (!parser)
    return 0;
  return parser->m_accounting.countBytesDirect;
}

unsigned long long testingAccountingGetCountBytesIndirect(XML_Parser parser) {
  if (!parser)
    return 0;
  return parser->m_accounting.countBytesIndirect;
}

static void entityTrackingReportStats(XML_Parser rootParser, ENTITY *entity,
                                      const char *action, int sourceLine) {
  assert(!rootParser->m_parentParser);
  if (rootParser->m_entity_stats.debugLevel == 0u)
    return;

#if defined(XML_UNICODE)
  const char *const entityName = "[..]";
#else
  const char *const entityName = entity->name;
#endif

  fprintf(stderr,
          "expat: Entities(%p): Count %9u, depth %2u/%2u %*s%s%s; %s length %d "
          "(xmlparse.c:%d)\n",
          (void *)rootParser, rootParser->m_entity_stats.countEverOpened,
          rootParser->m_entity_stats.currentDepth,
          rootParser->m_entity_stats.maximumDepthSeen,
          ((int)rootParser->m_entity_stats.currentDepth - 1) * 2, "",
          entity->is_param ? "%" : "&", entityName, action, entity->textLen,
          sourceLine);
}

static void entityTrackingOnOpen(XML_Parser originParser, ENTITY *entity,
                                 int sourceLine) {
  const XML_Parser rootParser = getRootParserOf(originParser, NULL);
  assert(!rootParser->m_parentParser);

  rootParser->m_entity_stats.countEverOpened++;
  rootParser->m_entity_stats.currentDepth++;
  if (rootParser->m_entity_stats.currentDepth >
      rootParser->m_entity_stats.maximumDepthSeen) {
    rootParser->m_entity_stats.maximumDepthSeen++;
  }

  entityTrackingReportStats(rootParser, entity, "OPEN ", sourceLine);
}

static void entityTrackingOnClose(XML_Parser originParser, ENTITY *entity,
                                  int sourceLine) {
  const XML_Parser rootParser = getRootParserOf(originParser, NULL);
  assert(!rootParser->m_parentParser);

  entityTrackingReportStats(rootParser, entity, "CLOSE", sourceLine);
  rootParser->m_entity_stats.currentDepth--;
}

#endif /* XML_GE == 1 */

static XML_Parser getRootParserOf(XML_Parser parser,
                                  unsigned int *outLevelDiff) {
  XML_Parser rootParser = parser;
  unsigned int stepsTakenUpwards = 0;
  while (rootParser->m_parentParser) {
    rootParser = rootParser->m_parentParser;
    stepsTakenUpwards++;
  }
  assert(!rootParser->m_parentParser);
  if (outLevelDiff != NULL) {
    *outLevelDiff = stepsTakenUpwards;
  }
  return rootParser;
}

#if XML_GE == 1

const char *unsignedCharToPrintable(unsigned char c) {
  switch (c) {
  case 0:
    return "\\0";
  case 1:
    return "\\x1";
  case 2:
    return "\\x2";
  case 3:
    return "\\x3";
  case 4:
    return "\\x4";
  case 5:
    return "\\x5";
  case 6:
    return "\\x6";
  case 7:
    return "\\x7";
  case 8:
    return "\\x8";
  case 9:
    return "\\t";
  case 10:
    return "\\n";
  case 11:
    return "\\xB";
  case 12:
    return "\\xC";
  case 13:
    return "\\r";
  case 14:
    return "\\xE";
  case 15:
    return "\\xF";
  case 16:
    return "\\x10";
  case 17:
    return "\\x11";
  case 18:
    return "\\x12";
  case 19:
    return "\\x13";
  case 20:
    return "\\x14";
  case 21:
    return "\\x15";
  case 22:
    return "\\x16";
  case 23:
    return "\\x17";
  case 24:
    return "\\x18";
  case 25:
    return "\\x19";
  case 26:
    return "\\x1A";
  case 27:
    return "\\x1B";
  case 28:
    return "\\x1C";
  case 29:
    return "\\x1D";
  case 30:
    return "\\x1E";
  case 31:
    return "\\x1F";
  case 32:
    return " ";
  case 33:
    return "!";
  case 34:
    return "\\\"";
  case 35:
    return "#";
  case 36:
    return "$";
  case 37:
    return "%";
  case 38:
    return "&";
  case 39:
    return "'";
  case 40:
    return "(";
  case 41:
    return ")";
  case 42:
    return "*";
  case 43:
    return "+";
  case 44:
    return ",";
  case 45:
    return "-";
  case 46:
    return ".";
  case 47:
    return "/";
  case 48:
    return "0";
  case 49:
    return "1";
  case 50:
    return "2";
  case 51:
    return "3";
  case 52:
    return "4";
  case 53:
    return "5";
  case 54:
    return "6";
  case 55:
    return "7";
  case 56:
    return "8";
  case 57:
    return "9";
  case 58:
    return ":";
  case 59:
    return ";";
  case 60:
    return "<";
  case 61:
    return "=";
  case 62:
    return ">";
  case 63:
    return "?";
  case 64:
    return "@";
  case 65:
    return "A";
  case 66:
    return "B";
  case 67:
    return "C";
  case 68:
    return "D";
  case 69:
    return "E";
  case 70:
    return "F";
  case 71:
    return "G";
  case 72:
    return "H";
  case 73:
    return "I";
  case 74:
    return "J";
  case 75:
    return "K";
  case 76:
    return "L";
  case 77:
    return "M";
  case 78:
    return "N";
  case 79:
    return "O";
  case 80:
    return "P";
  case 81:
    return "Q";
  case 82:
    return "R";
  case 83:
    return "S";
  case 84:
    return "T";
  case 85:
    return "U";
  case 86:
    return "V";
  case 87:
    return "W";
  case 88:
    return "X";
  case 89:
    return "Y";
  case 90:
    return "Z";
  case 91:
    return "[";
  case 92:
    return "\\\\";
  case 93:
    return "]";
  case 94:
    return "^";
  case 95:
    return "_";
  case 96:
    return "`";
  case 97:
    return "a";
  case 98:
    return "b";
  case 99:
    return "c";
  case 100:
    return "d";
  case 101:
    return "e";
  case 102:
    return "f";
  case 103:
    return "g";
  case 104:
    return "h";
  case 105:
    return "i";
  case 106:
    return "j";
  case 107:
    return "k";
  case 108:
    return "l";
  case 109:
    return "m";
  case 110:
    return "n";
  case 111:
    return "o";
  case 112:
    return "p";
  case 113:
    return "q";
  case 114:
    return "r";
  case 115:
    return "s";
  case 116:
    return "t";
  case 117:
    return "u";
  case 118:
    return "v";
  case 119:
    return "w";
  case 120:
    return "x";
  case 121:
    return "y";
  case 122:
    return "z";
  case 123:
    return "{";
  case 124:
    return "|";
  case 125:
    return "}";
  case 126:
    return "~";
  case 127:
    return "\\x7F";
  case 128:
    return "\\x80";
  case 129:
    return "\\x81";
  case 130:
    return "\\x82";
  case 131:
    return "\\x83";
  case 132:
    return "\\x84";
  case 133:
    return "\\x85";
  case 134:
    return "\\x86";
  case 135:
    return "\\x87";
  case 136:
    return "\\x88";
  case 137:
    return "\\x89";
  case 138:
    return "\\x8A";
  case 139:
    return "\\x8B";
  case 140:
    return "\\x8C";
  case 141:
    return "\\x8D";
  case 142:
    return "\\x8E";
  case 143:
    return "\\x8F";
  case 144:
    return "\\x90";
  case 145:
    return "\\x91";
  case 146:
    return "\\x92";
  case 147:
    return "\\x93";
  case 148:
    return "\\x94";
  case 149:
    return "\\x95";
  case 150:
    return "\\x96";
  case 151:
    return "\\x97";
  case 152:
    return "\\x98";
  case 153:
    return "\\x99";
  case 154:
    return "\\x9A";
  case 155:
    return "\\x9B";
  case 156:
    return "\\x9C";
  case 157:
    return "\\x9D";
  case 158:
    return "\\x9E";
  case 159:
    return "\\x9F";
  case 160:
    return "\\xA0";
  case 161:
    return "\\xA1";
  case 162:
    return "\\xA2";
  case 163:
    return "\\xA3";
  case 164:
    return "\\xA4";
  case 165:
    return "\\xA5";
  case 166:
    return "\\xA6";
  case 167:
    return "\\xA7";
  case 168:
    return "\\xA8";
  case 169:
    return "\\xA9";
  case 170:
    return "\\xAA";
  case 171:
    return "\\xAB";
  case 172:
    return "\\xAC";
  case 173:
    return "\\xAD";
  case 174:
    return "\\xAE";
  case 175:
    return "\\xAF";
  case 176:
    return "\\xB0";
  case 177:
    return "\\xB1";
  case 178:
    return "\\xB2";
  case 179:
    return "\\xB3";
  case 180:
    return "\\xB4";
  case 181:
    return "\\xB5";
  case 182:
    return "\\xB6";
  case 183:
    return "\\xB7";
  case 184:
    return "\\xB8";
  case 185:
    return "\\xB9";
  case 186:
    return "\\xBA";
  case 187:
    return "\\xBB";
  case 188:
    return "\\xBC";
  case 189:
    return "\\xBD";
  case 190:
    return "\\xBE";
  case 191:
    return "\\xBF";
  case 192:
    return "\\xC0";
  case 193:
    return "\\xC1";
  case 194:
    return "\\xC2";
  case 195:
    return "\\xC3";
  case 196:
    return "\\xC4";
  case 197:
    return "\\xC5";
  case 198:
    return "\\xC6";
  case 199:
    return "\\xC7";
  case 200:
    return "\\xC8";
  case 201:
    return "\\xC9";
  case 202:
    return "\\xCA";
  case 203:
    return "\\xCB";
  case 204:
    return "\\xCC";
  case 205:
    return "\\xCD";
  case 206:
    return "\\xCE";
  case 207:
    return "\\xCF";
  case 208:
    return "\\xD0";
  case 209:
    return "\\xD1";
  case 210:
    return "\\xD2";
  case 211:
    return "\\xD3";
  case 212:
    return "\\xD4";
  case 213:
    return "\\xD5";
  case 214:
    return "\\xD6";
  case 215:
    return "\\xD7";
  case 216:
    return "\\xD8";
  case 217:
    return "\\xD9";
  case 218:
    return "\\xDA";
  case 219:
    return "\\xDB";
  case 220:
    return "\\xDC";
  case 221:
    return "\\xDD";
  case 222:
    return "\\xDE";
  case 223:
    return "\\xDF";
  case 224:
    return "\\xE0";
  case 225:
    return "\\xE1";
  case 226:
    return "\\xE2";
  case 227:
    return "\\xE3";
  case 228:
    return "\\xE4";
  case 229:
    return "\\xE5";
  case 230:
    return "\\xE6";
  case 231:
    return "\\xE7";
  case 232:
    return "\\xE8";
  case 233:
    return "\\xE9";
  case 234:
    return "\\xEA";
  case 235:
    return "\\xEB";
  case 236:
    return "\\xEC";
  case 237:
    return "\\xED";
  case 238:
    return "\\xEE";
  case 239:
    return "\\xEF";
  case 240:
    return "\\xF0";
  case 241:
    return "\\xF1";
  case 242:
    return "\\xF2";
  case 243:
    return "\\xF3";
  case 244:
    return "\\xF4";
  case 245:
    return "\\xF5";
  case 246:
    return "\\xF6";
  case 247:
    return "\\xF7";
  case 248:
    return "\\xF8";
  case 249:
    return "\\xF9";
  case 250:
    return "\\xFA";
  case 251:
    return "\\xFB";
  case 252:
    return "\\xFC";
  case 253:
    return "\\xFD";
  case 254:
    return "\\xFE";
  case 255:
    return "\\xFF";
  // LCOV_EXCL_START
  default:
    assert(0); /* never gets here */
    return "dead code";
  }
  assert(0); /* never gets here */
  // LCOV_EXCL_STOP
}

#endif /* XML_GE == 1 */

static unsigned long getDebugLevel(const char *variableName,
                                   unsigned long defaultDebugLevel) {
  const char *const valueOrNull = getenv(variableName);
  if (valueOrNull == NULL) {
    return defaultDebugLevel;
  }
  const char *const value = valueOrNull;

  errno = 0;
  char *afterValue = NULL;
  unsigned long debugLevel = strtoul(value, &afterValue, 10);
  if ((errno != 0) || (afterValue == value) || (afterValue[0] != '\0')) {
    errno = 0;
    return defaultDebugLevel;
  }

  return debugLevel;
}
