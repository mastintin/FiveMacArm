#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

// Types needed by Scintilla
typedef intptr_t sptr_t;
typedef uintptr_t uptr_t;

#import "scilexer.h"
#import <scintilla/ScintillaView.h>
#import <scintilla/scilexer.h>
#import <objc/runtime.h>

static char *s_harbourGlobalList = NULL;
static NSDictionary *s_snippets = nil;


typedef struct {
  char *name;
  char *syntax;
  char *doc;
} HarbourDoc;

static HarbourDoc *s_harbourDocs = NULL;
static int s_harbourDocsCount = 0;

static HarbourDoc *findDoc(const char *name) {
  for (int i = 0; i < s_harbourDocsCount; i++) {
    if (strcasecmp(s_harbourDocs[i].name, name) == 0) {
      return &s_harbourDocs[i];
    }
  }
  return NULL;
}
#undef WM_NOTIFY
#include "fivemac.h"


// === DELEGADO MAESTRO (Estilo HarbourBuilder) ===
@interface MySciDelegate : NSObject <ScintillaNotificationProtocol>
@property (nonatomic, assign) ScintillaView *sv;
@property (nonatomic, assign) void* pHarbourObj;
@end

#define SCIRGB(r, g, b)                                                        \
  (((r) & 0xFF) | (((g) & 0xFF) << 8) | (((b) & 0xFF) << 16))

#ifndef SCI_SETILEXER
#define SCI_SETILEXER 4033
#endif

// Flagship style IDs
#define SCE_FS_DEFAULT 0
#define SCE_FS_COMMENT 1
#define SCE_FS_COMMENTLINE 2
#define SCE_FS_COMMENTDOC 3
#define SCE_FS_KEYWORD 7
#define SCE_FS_KEYWORD2 8
#define SCE_FS_KEYWORD3 9
#define SCE_FS_NUMBER 11
#define SCE_FS_STRING 12
#define SCE_FS_OPERATOR 14
#define SCE_FS_IDENTIFIER 15


// Helpers
static sptr_t SciMsg(ScintillaView *sv, unsigned int msg, uptr_t wParam,
                     sptr_t lParam) {
  return [sv message:msg wParam:wParam lParam:lParam];
}

static sptr_t SciMsg0(ScintillaView *sv, unsigned int msg) {
  return [sv message:msg wParam:0 lParam:0];
}

extern void *CreateLexer(const char *name);

/* -----------------------------------------------------------------------
 * Harbour-aware code folding
 * Sets fold levels for function/procedure/method/class/if/for/while/switch
 * ----------------------------------------------------------------------- */

static int CE_LineStartsWithCI(const char *line, int lineLen,
                               const char *word) {
  int i = 0;
  int wLen = (int)strlen(word);
  /* Skip leading whitespace */
  while (i < lineLen && (line[i] == ' ' || line[i] == '\t'))
    i++;
  if (i + wLen > lineLen)
    return 0;
  if (strncasecmp(line + i, word, wLen) != 0)
    return 0;
  /* Must be followed by non-identifier char */
  if (i + wLen < lineLen) {
    char c = line[i + wLen];
    if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '_' ||
        (c >= '0' && c <= '9'))
      return 0;
  }
  return 1;
}

/* Collect DATA member names from a CLASS definition in the editor.
 * Scans from classLine+1 until ENDCLASS, extracts DATA names into buf.
 * Returns number of chars written. */
static int CE_CollectUserData(ScintillaView *sv, sptr_t classLine, char *buf,
                              int bufSize) {
  int pos = 0;
  sptr_t totalLines = SciMsg0(sv, SCI_GETLINECOUNT);
  for (sptr_t l = classLine + 1; l < totalLines; l++) {
    char line[512];
    sptr_t len = SciMsg(sv, SCI_LINELENGTH, (uptr_t)l, 0);
    if (len <= 0 || len >= (sptr_t)sizeof(line))
      continue;
    SciMsg(sv, SCI_GETLINE, (uptr_t)l, (sptr_t)line);
    line[len] = 0;

    const char *p = line;
    while (*p == ' ' || *p == '\t' || *p == '\r' || *p == '\n')
      p++;
    if (*p == 0)
      continue; /* empty line */

    /* Stop at ENDCLASS */
    if (strncasecmp(p, "ENDCLASS", 8) == 0)
      break;

    /* Match DATA or ACCESS or METHOD */
    BOOL isData = (strncasecmp(p, "DATA ", 5) == 0);
    BOOL isAccess = (strncasecmp(p, "ACCESS ", 7) == 0);
    BOOL isMethod = (strncasecmp(p, "METHOD ", 7) == 0);
    /* debug removed */
    if (!isData && !isAccess && !isMethod)
      continue;

    if (isData)
      p += 5;
    else
      p += 7; /* ACCESS or METHOD */
    while (*p == ' ')
      p++;

    /* Extract member name */
    char name[64];
    int ni = 0;
    while (ni < 63 && (isalnum((unsigned char)p[ni]) || p[ni] == '_')) {
      name[ni] = p[ni];
      ni++;
    }
    name[ni] = 0;
    if (ni == 0)
      continue;

    /* Append to buf (space-separated) */
    if (pos > 0 && pos < bufSize - 1)
      buf[pos++] = ' ';
    int remaining = bufSize - pos - 1;
    if (ni > remaining)
      break;
    memcpy(buf + pos, name, (size_t)ni);
    pos += ni;
  }
  buf[pos] = 0;
  return pos;
}

/* We can't subclass SCIContentView easily (it's internal).
 * Instead, use an NSEvent monitor installed when editor is created. */

/* -----------------------------------------------------------------------
 * Class member autocomplete — triggered when ':' is typed after a variable
 * ----------------------------------------------------------------------- */

typedef struct {
  const char *className;
  const char *members; /* space-separated, sorted alphabetically */
} ClassMembers;


static ClassMembers s_classMembers[] = {
    {"TWindow", "Activate|AddControl|Bottom|Center|Clear|Close|Disable|Enable|End|GetText|Hide|Left|Move|Refresh|Restore|SetColor|SetFocus|SetText|Show|Top|Width"},
    {"TDialog", "Activate|Bottom|Center|Close|End|GetText|Hide|Left|Move|Refresh|SetColor|SetFocus|SetText|Show|Top|Width"},
    {"TSay", "GetText|Refresh|SetColor|SetText"},
    {"TGet", "GetText|Refresh|SetColor|SetFocus|SetText|VarGet|VarPut"},
    {"TButton", "OnClick|SetText|Disable|Enable"},
    {"TCheckBox", "Checked|OnClick|SetText"},
    {"TComboBox", "AddItem|bChange|Select"},
    {"TListBox", "AddItem|bChange|Select"},
    {"TBrowse", "bChange|Refresh|SetArray|SetCol"},
    {"TImage", "LoadImage|Refresh|SetFile"},
    {"THttpClient", "Get|Post"},
    {NULL, NULL}};

/* Find class members by class name (case-insensitive).
 * Combines standard class members with user-defined DATA from the editor.
 * For user classes (e.g. TForm1 INHERIT TForm), includes parent members + user
 * DATA. */
static const char *CE_FindClassMembers(ScintillaView *sv, const char *cls) {
  static char s_combinedMembers[4096];
  const char *standardMembers = NULL;

  /* Direct lookup in standard table */
  for (int i = 0; s_classMembers[i].className; i++)
    if (strcasecmp(cls, s_classMembers[i].className) == 0) {
      standardMembers = s_classMembers[i].members;
      break;
    }

  /* Search editor for CLASS definition to find user DATA and/or parent class */
  char userMembers[2048] = "";
  sptr_t classLine = -1;

  if (sv) {
    sptr_t totalLines = SciMsg0(sv, SCI_GETLINECOUNT);

    /* Find CLASS declaration matching cls or inheriting from cls */
    for (sptr_t l = 0; l < totalLines; l++) {
      char buf[512];
      sptr_t len = SciMsg(sv, SCI_LINELENGTH, (uptr_t)l, 0);
      if (len <= 0 || len >= (sptr_t)sizeof(buf))
        continue;
      SciMsg(sv, SCI_GETLINE, (uptr_t)l, (sptr_t)buf);
      buf[len] = 0;

      const char *cp = buf;
      while (*cp == ' ' || *cp == '\t')
        cp++;
      if (strncasecmp(cp, "CLASS ", 6) != 0)
        continue;
      cp += 6;
      while (*cp == ' ')
        cp++;

      /* Extract class name from line */
      char foundCls[64];
      int fi = 0;
      while (fi < 63 && (isalnum((unsigned char)cp[fi]) || cp[fi] == '_')) {
        foundCls[fi] = cp[fi];
        fi++;
      }
      foundCls[fi] = 0;
      /* debug removed */

      /* Case 1: exact match (CLASS TForm1, cls="TForm1") */
      if (strcasecmp(foundCls, cls) == 0) {
        classLine = l;
        /* Also check for INHERIT/FROM to get parent standard members */
        cp += fi;
        while (*cp == ' ')
          cp++;
        if (strncasecmp(cp, "INHERIT ", 8) == 0)
          cp += 8;
        else if (strncasecmp(cp, "FROM ", 5) == 0)
          cp += 5;
        else
          cp = NULL;
        if (cp) {
          while (*cp == ' ')
            cp++;
          char parent[64];
          int pi = 0;
          while (pi < 63 && (isalnum((unsigned char)cp[pi]) || cp[pi] == '_')) {
            parent[pi] = cp[pi];
            pi++;
          }
          parent[pi] = 0;
          if (!standardMembers) {
            for (int i = 0; s_classMembers[i].className; i++)
              if (strcasecmp(parent, s_classMembers[i].className) == 0) {
                standardMembers = s_classMembers[i].members;
                break;
              }
          }
        }
        break;
      }

      /* Case 2: this class inherits from cls (CLASS TForm1 INHERIT/FROM TForm,
       * cls="TForm") */
      cp += fi;
      while (*cp == ' ')
        cp++;
      if (strncasecmp(cp, "INHERIT ", 8) == 0)
        cp += 8;
      else if (strncasecmp(cp, "FROM ", 5) == 0)
        cp += 5;
      else
        cp = NULL;
      if (cp) {
        while (*cp == ' ')
          cp++;
        char parent[64];
        int pi = 0;
        while (pi < 63 && (isalnum((unsigned char)cp[pi]) || cp[pi] == '_')) {
          parent[pi] = cp[pi];
          pi++;
        }
        parent[pi] = 0;
        /* debug removed */
        if (strcasecmp(parent, cls) == 0) {
          classLine = l;
          break;
        }
      }
    }

    /* debug removed */

    /* Collect user DATA/ACCESS/METHOD from CLASS..ENDCLASS */
    if (classLine >= 0) {
      CE_CollectUserData(sv, classLine, userMembers,
                         (int)sizeof(userMembers));
      /* debug removed */
    }
  }

  /* Combine standard + user members */
  if (standardMembers && userMembers[0]) {
    snprintf(s_combinedMembers, sizeof(s_combinedMembers), "%s %s",
             standardMembers, userMembers);
    return s_combinedMembers;
  }
  if (standardMembers)
    return standardMembers;
  if (userMembers[0]) {
    strncpy(s_combinedMembers, userMembers, sizeof(s_combinedMembers) - 1);
    return s_combinedMembers;
  }

  return NULL;
}

/* Scan backwards from line to find current CLASS name (e.g., "CLASS TForm1" →
 * "TForm1") */
static const char *CE_FindCurrentClass(ScintillaView *sv, sptr_t fromLine) {
  static char s_curClass[64];
  for (sptr_t l = fromLine; l >= 0; l--) {
    char buf[512];
    sptr_t len = SciMsg(sv, SCI_LINELENGTH, (uptr_t)l, 0);
    if (len <= 0 || len >= (sptr_t)sizeof(buf))
      continue;
    SciMsg(sv, SCI_GETLINE, (uptr_t)l, (sptr_t)buf);
    buf[len] = 0;

    const char *cp = buf;
    while (*cp == ' ' || *cp == '\t')
      cp++;
    if (strncasecmp(cp, "CLASS ", 6) == 0) {
      cp += 6;
      while (*cp == ' ')
        cp++;
      int ci = 0;
      while (ci < 63 && (isalnum((unsigned char)cp[ci]) || cp[ci] == '_')) {
        s_curClass[ci] = cp[ci];
        ci++;
      }
      s_curClass[ci] = 0;
      if (ci > 0)
        return s_curClass;
      break;
    }
  }
  return NULL;
}

/* Scan the editor text backwards from cursor to find variable name before ':'
 * Returns class name if determinable, or NULL */
static const char *CE_GetClassNameFromSource(ScintillaView *sv, sptr_t currentLine) {
  static char currentClass[64];
  for (sptr_t i = currentLine; i >= 0; i--) {
    char lineBuf[256];
    sptr_t start = [sv message:SCI_POSITIONFROMLINE wParam:(uptr_t)i lParam:0];
    sptr_t len = [sv message:SCI_LINELENGTH wParam:(uptr_t)i lParam:0];
    if (len > 0 && len < 255) {
      struct Sci_TextRange tr;
      tr.chrg.cpMin = (Sci_PositionCR)start;
      tr.chrg.cpMax = (Sci_PositionCR)start + len;
      tr.lpstrText = lineBuf;
      [sv message:SCI_GETTEXTRANGE wParam:0 lParam:(sptr_t)&tr];
      lineBuf[len] = 0;

      // Simple scan for "CLASS TSomething"
      char *p = strcasestr(lineBuf, "CLASS ");
      if (p) {
        p += 6;
        while (*p == ' ') p++;
        char *end = p;
        while (*end && *end != ' ' && *end != '\r' && *end != '\n') end++;
        size_t nameLen = (size_t)(end - p);
        if (nameLen > 0 && nameLen < 63) {
          memcpy(currentClass, p, nameLen);
          currentClass[nameLen] = 0;
          return currentClass;
        }
      }
    }
  }
  return NULL;
}

static const char *CE_ResolveVarClass(ScintillaView *sv, sptr_t posAt) {
  static char s_resolvedClass[64];

  /* Get text of the current line to find the variable name before ':' */
  sptr_t line = [sv message:SCI_LINEFROMPOSITION wParam:(uptr_t)posAt lParam:0];
  sptr_t lineStart = [sv message:SCI_POSITIONFROMLINE wParam:(uptr_t)line lParam:0];
  sptr_t lineLen = posAt - lineStart;
  if (lineLen <= 0 || lineLen > 500)
    return NULL;

  char lineBuf[512];
  struct Sci_TextRange tr;
  tr.chrg.cpMin = (Sci_PositionCR)lineStart;
  tr.chrg.cpMax = (Sci_PositionCR)posAt;
  tr.lpstrText = lineBuf;
  SciMsg(sv, SCI_GETTEXTRANGE, 0, (sptr_t)&tr);
  lineBuf[lineLen] = 0;

  /* Walk backwards from end of lineBuf to find variable name */
  int end = (int)lineLen - 1;

  /* Skip trailing ':' if there's a second one (::var case) */
  while (end >= 0 && lineBuf[end] == ':')
    end--;

  /* Find the variable name: alphanumeric + underscore */
  int nameEnd = end;
  while (end >= 0 &&
         (isalnum((unsigned char)lineBuf[end]) || lineBuf[end] == '_'))
    end--;
  int nameStart = end + 1;
  if (nameStart > nameEnd)
    return NULL;

  char varName[128];
  int varLen = nameEnd - nameStart + 1;
  if (varLen <= 0 || varLen >= (int)sizeof(varName))
    return NULL;
  memcpy(varName, &lineBuf[nameStart], (size_t)varLen);
  varName[varLen] = 0;
  // NSLog(@"CE: Resolved varName='%s'", varName);

  /* Detect if the variable had :: prefix (instance variable access) */
  BOOL hasDblColon = (nameStart >= 2 && lineBuf[nameStart - 1] == ':' &&
                      lineBuf[nameStart - 2] == ':');

  /* "Self:" — show members of current CLASS */
  if (strcasecmp(varName, "Self") == 0) {
    const char *cls = CE_FindCurrentClass(sv, line);
    return cls;
  }

  /* For any variable (with or without :: prefix), try to resolve its class.
   * Strategies: 1) DATA comment  2) assignment pattern  3) current class
   * members */

  /* Strategy 1: search DATA declarations with class comment: DATA oName //
   * TClassName */
  {
    sptr_t totalLines = SciMsg0(sv, SCI_GETLINECOUNT);
    for (sptr_t l = 0; l < totalLines; l++) {
      char buf[512];
      sptr_t len = SciMsg(sv, SCI_LINELENGTH, (uptr_t)l, 0);
      if (len <= 0 || len >= (sptr_t)sizeof(buf))
        continue;
      SciMsg(sv, SCI_GETLINE, (uptr_t)l, (sptr_t)buf);
      buf[len] = 0;

      /* Match "DATA varName" */
      const char *dp = buf;
      while (*dp == ' ' || *dp == '\t')
        dp++;
      if (strncasecmp(dp, "DATA ", 5) != 0)
        continue;
      dp += 5;
      while (*dp == ' ')
        dp++;

      if (strncasecmp(dp, varName, (size_t)varLen) != 0)
        continue;
      dp += varLen;
      if (isalnum((unsigned char)*dp) || *dp == '_')
        continue; /* partial match */

      /* Found DATA varName — look for "// TClassName" comment */
      const char *cmt = strstr(dp, "//");
      if (!cmt)
        continue;
      cmt += 2;
      while (*cmt == ' ')
        cmt++;

      if (*cmt == 'T' && isalpha((unsigned char)cmt[1])) {
        int ci = 0;
        while (ci < 63 && (isalnum((unsigned char)cmt[ci]) || cmt[ci] == '_')) {
          s_resolvedClass[ci] = cmt[ci];
          ci++;
        }
        s_resolvedClass[ci] = 0;
        return s_resolvedClass;
      }
    }
  }

  /* Strategy 2: search for "varName := TClassName():New" assignment pattern */
  {
    sptr_t totalLines = SciMsg0(sv, SCI_GETLINECOUNT);
    for (sptr_t l = 0; l < totalLines; l++) {
      char buf[512];
      sptr_t len = SciMsg(sv, SCI_LINELENGTH, (uptr_t)l, 0);
      if (len <= 0 || len >= (sptr_t)sizeof(buf))
        continue;
      SciMsg(sv, SCI_GETLINE, (uptr_t)l, (sptr_t)buf);
      buf[len] = 0;

      const char *vp = strstr(buf, varName);
      if (!vp)
        continue;
      vp += varLen;
      while (*vp == ' ')
        vp++;
      if (*vp != ':' || vp[1] != '=')
        continue;
      vp += 2;
      while (*vp == ' ')
        vp++;

      if (*vp == 'T' && isalpha((unsigned char)vp[1])) {
        int ci = 0;
        while (ci < 63 && (isalnum((unsigned char)vp[ci]) || vp[ci] == '_')) {
          s_resolvedClass[ci] = vp[ci];
          ci++;
        }
        s_resolvedClass[ci] = 0;
        /* Remove trailing "()" if present */
        int slen = (int)strlen(s_resolvedClass);
        if (slen > 2 && s_resolvedClass[slen - 1] == ')' &&
            s_resolvedClass[slen - 2] == '(')
          s_resolvedClass[slen - 2] = 0;
        return s_resolvedClass;
      }
    }
  }

  /* Strategy 3: search for "AS TClassName" pattern in the same file */
  {
    sptr_t totalLines = SciMsg0(sv, SCI_GETLINECOUNT);
    for (sptr_t l = 0; l < totalLines; l++) {
      char buf[512];
      sptr_t len = SciMsg(sv, SCI_LINELENGTH, (uptr_t)l, 0);
      if (len <= 0 || len >= (sptr_t)sizeof(buf))
        continue;
      SciMsg(sv, SCI_GETLINE, (uptr_t)l, (sptr_t)buf);
      buf[len] = 0;

      const char *vp = strstr(buf, varName);
      if (!vp)
        continue;
      vp += varLen;
      while (*vp == ' ')
        vp++;
      
      if (strncasecmp(vp, "AS ", 3) == 0) {
        vp += 3;
        while (*vp == ' ')
          vp++;
        if (*vp == 'T' && isalpha((unsigned char)vp[1])) {
          int ci = 0;
          while (ci < 63 && (isalnum((unsigned char)vp[ci]) || vp[ci] == '_')) {
            s_resolvedClass[ci] = vp[ci];
            ci++;
          }
          s_resolvedClass[ci] = 0;
          return s_resolvedClass;
        }
      }
    }
  }

  /* Strategy 4: if :: prefix and no class found, show current class members
   * (handles ::Width, ::Title, etc. — direct member access on Self) */
  if (hasDblColon) {
    const char *cls = CE_FindCurrentClass(sv, line);
    return cls;
  }

  /* Strategy 4: naming convention — oForm→TForm, oButton→TButton, etc.
   * Handles function parameters and local variables without type info. */
  {
    static struct {
      const char *prefix;
      const char *cls;
    } s_nameMap[] = {{"Wnd", "TWindow"},
                     {"Dialog", "TDialog"},
                     {"Dlg", "TDialog"},
                     {"Say", "TSay"},
                     {"Get", "TGet"},
                     {"Button", "TButton"},
                     {"Btn", "TButton"},
                     {"CheckBox", "TCheckBox"},
                     {"ComboBox", "TComboBox"},
                     {"Cbx", "TComboBox"},
                     {"ListBox", "TListBox"},
                     {"Lbx", "TListBox"},
                     {"Browse", "TBrowse"},
                     {"Brw", "TBrowse"},
                     {"Image", "TImage"},
                     {"Img", "TImage"},
                     {"HttpClient", "THttpClient"},
                     {"Http", "THttpClient"},
                     {NULL, NULL}};

    /* Skip leading 'o' or 'n' or 'c' prefix (Hungarian notation) */
    const char *base = varName;
    if ((base[0] == 'o' || base[0] == 'O') && isupper((unsigned char)base[1]))
      base++;

    for (int i = 0; s_nameMap[i].prefix; i++) {
      int plen = (int)strlen(s_nameMap[i].prefix);
      if (strncasecmp(base, s_nameMap[i].prefix, (size_t)plen) == 0) {
        /* Match if base equals prefix or prefix is followed by a digit/end
         * (oForm, oForm1, oFormMain all match "Form") */
        char next = base[plen];
        if (next == 0 || isdigit((unsigned char)next) ||
            isupper((unsigned char)next) || next == '_') {
          strncpy(s_resolvedClass, s_nameMap[i].cls, 63);
          s_resolvedClass[63] = 0;
          return s_resolvedClass;
        }
      }
    }
  }

  /* Strategy 5: Generic oObject -> TObject (Hungarish) */
  if (strlen(varName) > 1 && varName[0] == 'o' && isupper((unsigned char)varName[1])) {
    snprintf(s_resolvedClass, 64, "T%s", varName + 1);
    return s_resolvedClass;
  }

  /* Strategy 6: Self reference (::) or Self: */
  if (strlen(varName) == 0 || strcasecmp(varName, "Self") == 0) {
    const char *sourceClass = CE_GetClassNameFromSource(sv, [sv message:SCI_LINEFROMPOSITION wParam:(uptr_t)posAt lParam:0]);
    if (sourceClass) {
      strncpy(s_resolvedClass, sourceClass, 63);
      s_resolvedClass[63] = 0;
      return s_resolvedClass;
    }
    return "TWindow"; // Fallback to TWindow if no CLASS keyword found
  }

  return NULL;
}

static void CE_UpdateHarbourFolding(ScintillaView *sv) {
  sptr_t lineCount = SciMsg0(sv, SCI_GETLINECOUNT);
  int level = SC_FOLDLEVELBASE;

  for (sptr_t i = 0; i < lineCount; i++) {
    sptr_t lineLen = SciMsg(sv, SCI_LINELENGTH, (uptr_t)i, 0);
    int curLevel = level;
    int nextLevel = level;
    int isHeader = 0;

    if (lineLen > 0 && lineLen < 4096) {
      char *buf = (char *)malloc((size_t)lineLen + 1);
      SciMsg(sv, SCI_GETLINE, (uptr_t)i, (sptr_t)buf);
      buf[lineLen] = 0;

      /* Trim trailing CR/LF */
      while (lineLen > 0 &&
             (buf[lineLen - 1] == '\r' || buf[lineLen - 1] == '\n'))
        buf[--lineLen] = 0;

      int ll = (int)lineLen;

      /* Fold openers */
      if (CE_LineStartsWithCI(buf, ll, "function") ||
          CE_LineStartsWithCI(buf, ll, "procedure") ||
          CE_LineStartsWithCI(buf, ll, "method")) {
        isHeader = 1;
        nextLevel = level + 1;
      } else if (CE_LineStartsWithCI(buf, ll, "class") &&
                 !CE_LineStartsWithCI(buf, ll, "endclass")) {
        isHeader = 1;
        nextLevel = level + 1;
      } else if (CE_LineStartsWithCI(buf, ll, "if") &&
                 !CE_LineStartsWithCI(buf, ll, "endif")) {
        isHeader = 1;
        nextLevel = level + 1;
      } else if (CE_LineStartsWithCI(buf, ll, "do")) {
        isHeader = 1;
        nextLevel = level + 1;
      } else if (CE_LineStartsWithCI(buf, ll, "for")) {
        isHeader = 1;
        nextLevel = level + 1;
      } else if (CE_LineStartsWithCI(buf, ll, "switch") &&
                 !CE_LineStartsWithCI(buf, ll, "endswitch")) {
        isHeader = 1;
        nextLevel = level + 1;
      } else if (CE_LineStartsWithCI(buf, ll, "begin")) {
        isHeader = 1;
        nextLevel = level + 1;
      } else if (CE_LineStartsWithCI(buf, ll, "while") &&
                 !CE_LineStartsWithCI(buf, ll, "enddo")) {
        isHeader = 1;
        nextLevel = level + 1;
      } else if (CE_LineStartsWithCI(buf, ll, "#pragma begindump")) {
        isHeader = 1;
        nextLevel = level + 1;
      }

      /* Fold closers */
      else if (CE_LineStartsWithCI(buf, ll, "return") ||
               CE_LineStartsWithCI(buf, ll, "endclass") ||
               CE_LineStartsWithCI(buf, ll, "endif") ||
               CE_LineStartsWithCI(buf, ll, "enddo") ||
               CE_LineStartsWithCI(buf, ll, "next") ||
               CE_LineStartsWithCI(buf, ll, "endswitch") ||
               CE_LineStartsWithCI(buf, ll, "endcase") ||
               CE_LineStartsWithCI(buf, ll, "end") ||
               CE_LineStartsWithCI(buf, ll, "#pragma enddump")) {
        if (level > SC_FOLDLEVELBASE) {
          curLevel = level - 1;
          nextLevel = level - 1;
        }
      }

      free(buf);
    }

    SciMsg(sv, SCI_SETFOLDLEVEL, (uptr_t)i,
           curLevel | (isHeader ? SC_FOLDLEVELHEADERFLAG : 0));
    level = nextLevel;
  }
}

@implementation MySciDelegate
- (void)notification:(SCNotification *)notification {
  int scCode = notification->nmhdr.code;

  if (scCode == SCN_UPDATEUI) {
      sptr_t pos = [self.sv message:SCI_GETCURRENTPOS wParam:0 lParam:0];
      sptr_t matchPos = [self.sv message:SCI_BRACEMATCH wParam:(uptr_t)pos lParam:0];
      if (matchPos == -1 && pos > 0) {
          matchPos = [self.sv message:SCI_BRACEMATCH wParam:(uptr_t)pos - 1 lParam:0];
          if (matchPos != -1) pos--;
      }
      [self.sv message:SCI_BRACEHIGHLIGHT wParam:(uptr_t)pos lParam:(sptr_t)matchPos];
  }

  else if (scCode == SCN_MARGINCLICK) {
    if (notification->margin == 2) {
      sptr_t nLine = [self.sv message:SCI_LINEFROMPOSITION wParam:(uptr_t)notification->position lParam:0];
      [self.sv message:SCI_TOGGLEFOLD wParam:(uptr_t)nLine lParam:0];
    }
  }

  else if (scCode == SCN_CHARADDED) {
    if (notification->ch == '\n' || notification->ch == '\r') {
      sptr_t pos = [self.sv message:SCI_GETCURRENTPOS wParam:0 lParam:0];
      sptr_t curLine = [self.sv message:SCI_LINEFROMPOSITION wParam:(uptr_t)pos lParam:0];
      if (curLine > 0) {
        sptr_t prevLine = curLine - 1;
        sptr_t prevIndent = [self.sv message:SCI_GETLINEINDENTATION wParam:(uptr_t)prevLine lParam:0];
        
        // Smart Indent: Check if previous line starts with a block-opener
        char lineText[1024];
        int lineLen = (int)[self.sv message:SCI_GETLINE wParam:(uptr_t)prevLine lParam:(sptr_t)lineText];
        if (lineLen > 1023) lineLen = 1023; // Seguridad
        lineText[lineLen] = '\0';
        
        NSString *nsPrev = [[NSString stringWithUTF8String:lineText] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *lowerPrev = [nsPrev lowercaseString];
        
        if ([lowerPrev hasPrefix:@"if"] || [lowerPrev hasPrefix:@"while"] || 
            [lowerPrev hasPrefix:@"for"] || [lowerPrev hasPrefix:@"case"] ||
            [lowerPrev hasPrefix:@"else"] || [lowerPrev hasPrefix:@"elseif"] ||
            [lowerPrev hasPrefix:@"try"] || [lowerPrev hasPrefix:@"do while"]) {
            sptr_t indentSize = [self.sv message:SCI_GETINDENT wParam:0 lParam:0];
            if (indentSize == 0) indentSize = 3; // Fallback
            prevIndent += indentSize;
        }
        
        [self.sv message:SCI_SETLINEINDENTATION wParam:(uptr_t)curLine lParam:prevIndent];
        sptr_t indentPos = [self.sv message:SCI_GETLINEINDENTPOSITION wParam:(uptr_t)curLine lParam:0];
        [self.sv message:SCI_GOTOPOS wParam:(uptr_t)indentPos lParam:0];
      }
    } else if (notification->ch == ':') {
      sptr_t pos = [self.sv message:SCI_GETCURRENTPOS wParam:0 lParam:0];
      const char *cls = CE_ResolveVarClass(self.sv, pos - 1);
      const char *members = cls ? CE_FindClassMembers(self.sv, cls) : CE_FindClassMembers(self.sv, "TWindow");

      if (members && ![self.sv message:SCI_AUTOCACTIVE wParam:0 lParam:0]) {
          [self.sv message:SCI_AUTOCSETIGNORECASE wParam:1 lParam:0];
          [self.sv message:SCI_AUTOCSETSEPARATOR wParam:'|' lParam:0];
          [self.sv message:SCI_AUTOCSETORDER wParam:1 lParam:0];
          [self.sv message:SCI_AUTOCSHOW wParam:0 lParam:(sptr_t)members];
      }
    } 
    else if (notification->ch == '(') {
      sptr_t pos = [self.sv message:SCI_GETCURRENTPOS wParam:0 lParam:0];
      sptr_t startWord = [self.sv message:SCI_WORDSTARTPOSITION wParam:(uptr_t)pos - 1 lParam:1];
      char name[256];
      int len = pos - 1 - startWord;
      if (len > 0 && len < 255) {
        struct Sci_TextRange tr;
        tr.chrg.cpMin = (Sci_Position)startWord;
        tr.chrg.cpMax = (Sci_Position)pos - 1;
        tr.lpstrText = name;
        [self.sv message:SCI_GETTEXTRANGE wParam:0 lParam:(sptr_t)&tr];
        name[len] = '\0';
        HarbourDoc *doc = findDoc(name);
        if (doc) {
          char tip[4096];
          snprintf(tip, sizeof(tip), "%s\n%s", doc->syntax, doc->doc);
          [self.sv message:SCI_CALLTIPSHOW wParam:pos lParam:(sptr_t)tip];
        }
      }
    } 
    else {
      // Trigger global autocomplete for functions (after 3 characters)
      sptr_t pos = [self.sv message:SCI_GETCURRENTPOS wParam:0 lParam:0];
      sptr_t startWord = [self.sv message:SCI_WORDSTARTPOSITION wParam:(uptr_t)pos lParam:1];
      sptr_t len = pos - startWord;

      if (len >= 3 && s_harbourGlobalList) {
        if (![self.sv message:SCI_AUTOCACTIVE wParam:0 lParam:0]) {
          [self.sv message:SCI_AUTOCSETIGNORECASE wParam:1 lParam:0];
          [self.sv message:SCI_AUTOCSETSEPARATOR wParam:'|' lParam:0];
          [self.sv message:SCI_AUTOCSETORDER wParam:1 lParam:0];
          [self.sv message:SCI_AUTOCSHOW wParam:len lParam:(sptr_t)s_harbourGlobalList];
        }
      }
    }
  }

  else if (scCode == SCN_MODIFIED) {
    if (notification->modificationType & (SC_MOD_INSERTTEXT | SC_MOD_DELETETEXT)) {
        CE_UpdateHarbourFolding(self.sv);
    }
  }
}
@end

/* -----------------------------------------------------------------------
 * Configure Scintilla: lexer, keywords, colours, margins, folding
 * -----------------------------------------------------------------------
 */

// === SCINTILLA 5: Load Lexer via CreateLexer + SCI_SETILEXER ===
void ApplyHarbourLexer(ScintillaView *sv) {
  void *pLexer = CreateLexer("flagship");
  if (pLexer) {
    [sv message:4033 wParam:0 lParam:(sptr_t)pLexer]; // SCI_SETILEXER = 4033
  }
}

void ApplyHarbourKeywords0(ScintillaView *sv) {
  const char *kw1;
  kw1 = "function procedure return local static private public "
        "if else elseif endif do while enddo for next to step in "
        "switch case otherwise endswitch endcase default "
        "class endclass method data access assign inherit inline "
        "nil self super begin end exit loop with sequence recover "
        "try catch finally true false and or not "
        "init announce request external memvar field parameters "
        "break continue optional redefine "
        "FUNCTION PROCEDURE RETURN LOCAL STATIC PRIVATE PUBLIC "
        "IF ELSE ELSEIF ENDIF DO WHILE ENDDO FOR NEXT TO STEP IN "
        "SWITCH CASE OTHERWISE ENDSWITCH ENDCASE DEFAULT "
        "CLASS ENDCLASS METHOD DATA ACCESS ASSIGN INHERIT INLINE "
        "NIL SELF SUPER BEGIN END EXIT LOOP WITH SEQUENCE RECOVER "
        "TRY CATCH FINALLY TRUE FALSE AND OR NOT "
        "INIT ANNOUNCE REQUEST EXTERNAL MEMVAR FIELD PARAMETERS "
        "BREAK CONTINUE OPTIONAL REDEFINE "
        "Function Procedure Return Local Static Private Public "
        "If Else ElseIf EndIf Do While EndDo For Next To Step In "
        "Switch Case Otherwise EndSwitch EndCase Default "
        "Class EndClass Method Data Access Assign Inherit Inline "
        "Nil Self Super Begin End Exit Loop With Sequence Recover "
        "Try Catch Finally True False And Or Not ";
  [sv message:SCI_SETKEYWORDS wParam:0 lParam:(sptr_t)kw1];
}

void ApplyHarbourKeywords1(ScintillaView *sv) {
  const char *kw2 =
      "msginfo msgalert msgyesno msgstop define activate form title "
      "size font sizable appbar toolwindow centered say get button "
      "prompt checkbox combobox groupbox items checked default "
      "cancel of var action on valid when from toolbar separator "
      "tooltip menubar popup menuitem menuseparator palette "
      "request accel bitmap icon browse dialog listbox radiobutton "
      "scrollbar panel image shape bevel treeview listview "
      "progressbar richedit statusbar splitter tabs tab memo "
      "datepicker spinner gauge header report band column printer "
      "preview webview webserver socket websocket httpget httppost "
      "thread mutex semaphore criticalsection atomicop ollama "
      "openai gemini claude deepseek transformer";
  [sv message:SCI_SETKEYWORDS wParam:1 lParam:(sptr_t)kw2];
}

void ApplyLineNumberMargin(ScintillaView *sv, int width) {
  // Line Number Margin Setup
  [sv message:SCI_SETMARGINTYPEN wParam:0 lParam:SC_MARGIN_NUMBER];
  [sv message:SCI_SETMARGINWIDTHN wParam:0 lParam:width];
}

static void CE_ConfigureScintilla(ScintillaView *sv) {
  /* UTF-8 */
  SciMsg(sv, SCI_SETCODEPAGE, SC_CP_UTF8, 0);

  /* Tab width */
  SciMsg(sv, SCI_SETTABWIDTH, 3, 0);

  /* Word characters for autocomplete offset calculations */
  SciMsg(sv, SCI_SETWORDCHARS, 0, (sptr_t)"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_");

  /* Set C/C++ lexer via Lexilla (works for Harbour) */
  void *pLexer = CreateLexer("cpp");
  if (pLexer)
    SciMsg(sv, SCI_SETILEXER, 0, (sptr_t)pLexer);

  /* Default style: Menlo 15pt, light gray on dark */
  SciMsg(sv, SCI_STYLESETFONT, STYLE_DEFAULT, (sptr_t) "Menlo");
  SciMsg(sv, SCI_STYLESETSIZE, STYLE_DEFAULT, 15);
  SciMsg(sv, SCI_STYLESETFORE, STYLE_DEFAULT, SCIRGB(212, 212, 212));
  SciMsg(sv, SCI_STYLESETBACK, STYLE_DEFAULT, SCIRGB(30, 30, 30));
  SciMsg(sv, SCI_STYLECLEARALL, 0, 0);

  /* Line number margin */
  ApplyLineNumberMargin(sv, 48);

  SciMsg(sv, SCI_STYLESETFORE, STYLE_LINENUMBER, SCIRGB(133, 133, 133));
  SciMsg(sv, SCI_STYLESETBACK, STYLE_LINENUMBER, SCIRGB(37, 37, 38));

  /* Folding margin — dark background matching editor */
  SciMsg(sv, SCI_SETMARGINTYPEN, 2, SC_MARGIN_SYMBOL);
  SciMsg(sv, SCI_SETMARGINMASKN, 2, SC_MASK_FOLDERS);
  SciMsg(sv, SCI_SETMARGINWIDTHN, 2, 16);
  SciMsg(sv, SCI_SETMARGINSENSITIVEN, 2, 1);
  SciMsg(sv, SCI_SETFOLDMARGINCOLOUR, 1, SCIRGB(37, 37, 38));
  SciMsg(sv, SCI_SETFOLDMARGINHICOLOUR, 1, SCIRGB(37, 37, 38));
  SciMsg(sv, SCI_SETAUTOMATICFOLD,
         SC_AUTOMATICFOLD_SHOW | SC_AUTOMATICFOLD_CLICK |
             SC_AUTOMATICFOLD_CHANGE,
         0);

  /* Fold markers — box style */
  SciMsg(sv, SCI_MARKERDEFINE, SC_MARKNUM_FOLDER, SC_MARK_BOXPLUS);
  SciMsg(sv, SCI_MARKERDEFINE, SC_MARKNUM_FOLDEROPEN, SC_MARK_BOXMINUS);
  SciMsg(sv, SCI_MARKERDEFINE, SC_MARKNUM_FOLDERSUB, SC_MARK_VLINE);
  SciMsg(sv, SCI_MARKERDEFINE, SC_MARKNUM_FOLDERTAIL, SC_MARK_LCORNER);
  SciMsg(sv, SCI_MARKERDEFINE, SC_MARKNUM_FOLDEREND, SC_MARK_BOXPLUSCONNECTED);
  SciMsg(sv, SCI_MARKERDEFINE, SC_MARKNUM_FOLDEROPENMID,
         SC_MARK_BOXMINUSCONNECTED);
  SciMsg(sv, SCI_MARKERDEFINE, SC_MARKNUM_FOLDERMIDTAIL, SC_MARK_TCORNER);

  for (int m = 25; m <= 31; m++) {
    SciMsg(sv, 2041, m, SCIRGB(160, 160, 160)); /* SCI_MARKERSETFORE */
    SciMsg(sv, 2042, m, SCIRGB(37, 37, 38));    /* SCI_MARKERSETBACK */
  }

  /* Enable folding */
  SciMsg(sv, SCI_SETPROPERTY, (uptr_t) "fold", (sptr_t) "1");
  SciMsg(sv, SCI_SETPROPERTY, (uptr_t) "fold.compact", (sptr_t) "0");
  SciMsg(sv, SCI_SETPROPERTY, (uptr_t) "fold.comment", (sptr_t) "1");
  SciMsg(sv, SCI_SETPROPERTY, (uptr_t) "fold.preprocessor", (sptr_t) "1");

  /* ===== Harbour keyword lists ===== */

  ApplyHarbourKeywords0(sv);
  ApplyHarbourKeywords1(sv);

  /* ===== Syntax highlighting colours ===== */
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_WORD, SCIRGB(86, 156, 214));
  SciMsg(sv, SCI_STYLESETBOLD, SCE_C_WORD, 1);
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_WORD2, SCIRGB(78, 201, 176));

  SciMsg(sv, SCI_STYLESETFORE, SCE_C_COMMENT, SCIRGB(106, 153, 85));
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_COMMENTLINE, SCIRGB(106, 153, 85));
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_COMMENTDOC, SCIRGB(106, 153, 85));
  SciMsg(sv, SCI_STYLESETITALIC, SCE_C_COMMENT, 1);
  SciMsg(sv, SCI_STYLESETITALIC, SCE_C_COMMENTLINE, 1);

  SciMsg(sv, SCI_STYLESETFORE, SCE_C_STRING, SCIRGB(206, 145, 120));
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_CHARACTER, SCIRGB(206, 145, 120));
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_NUMBER, SCIRGB(181, 206, 168));
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_PREPROCESSOR, SCIRGB(197, 134, 192));
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_OPERATOR, SCIRGB(212, 212, 212));
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_IDENTIFIER, SCIRGB(220, 220, 220));
  SciMsg(sv, SCI_STYLESETFORE, SCE_C_GLOBALCLASS, SCIRGB(78, 201, 176));

  /* Caret and selection */
  SciMsg(sv, SCI_SETCARETFORE, SCIRGB(255, 255, 255), 0);
  SciMsg(sv, SCI_SETSELBACK, 1, SCIRGB(38, 79, 120));

  /* Line spacing */
  SciMsg(sv, SCI_SETEXTRAASCENT, 1, 0);
  SciMsg(sv, SCI_SETEXTRADESCENT, 1, 0);

  /* Indentation guides */
  SciMsg(sv, SCI_SETINDENTATIONGUIDES, SC_IV_LOOKBOTH, 0);

  /* Bracket matching style */
  SciMsg(sv, SCI_STYLESETFORE, STYLE_BRACELIGHT, SCIRGB(255, 255, 0));
  SciMsg(sv, SCI_STYLESETBACK, STYLE_BRACELIGHT, SCIRGB(60, 60, 60));
  SciMsg(sv, SCI_STYLESETBOLD, STYLE_BRACELIGHT, 1);
  SciMsg(sv, SCI_STYLESETFORE, STYLE_BRACEBAD, SCIRGB(255, 0, 0));
  SciMsg(sv, SCI_STYLESETBACK, STYLE_BRACEBAD, SCIRGB(60, 30, 30));
  SciMsg(sv, SCI_STYLESETBOLD, STYLE_BRACEBAD, 1);

  /* Error marker: red background for error lines (marker 10) */
  SciMsg(sv, SCI_MARKERDEFINE, 10, SC_MARK_BACKGROUND);
  SciMsg(sv, 2042, 10, SCIRGB(80, 20, 20)); /* SCI_MARKERSETBACK: dark red bg */

  /* Debug execution line marker: yellow background (marker 11) */
  SciMsg(sv, SCI_MARKERDEFINE, 11, SC_MARK_BACKGROUND);
  SciMsg(sv, 2042, 11, SCIRGB(80, 80, 20)); /* SCI_MARKERSETBACK: dark yellow */

  /* Bookmarks: markers 0-9 using circles in margin 1 */
  SciMsg(sv, SCI_SETMARGINTYPEN, 1, SC_MARGIN_SYMBOL);
  SciMsg(sv, SCI_SETMARGINWIDTHN, 1, 16);
  SciMsg(sv, SCI_SETMARGINMASKN, 1, 0x3FF); /* bits 0-9 */
  SciMsg(sv, SCI_SETMARGINSENSITIVEN, 1, 1);
  for (int m = 0; m <= 9; m++) {
    SciMsg(sv, SCI_MARKERDEFINE, m, SC_MARK_SHORTARROW);
    SciMsg(sv, 2041, m, SCIRGB(80, 180, 255)); /* SCI_MARKERSETFORE */
    SciMsg(sv, 2042, m, SCIRGB(40, 40, 50));   /* SCI_MARKERSETBACK */
  }
}

// === TEMAS Y ESTILOS (GOLD STANDARD) ===

// === Theme Application Functions ===
void ApplyDarkTheme(ScintillaView *sv) {
  /* UTF-8 */
  [sv message:SCI_SETCODEPAGE wParam:SC_CP_UTF8 lParam:0];

  /* Tab width */
  [sv message:SCI_SETTABWIDTH wParam:3 lParam:0];

  /* Default style: Menlo 15pt, light gray on dark */
  [sv message:SCI_STYLESETFONT wParam:STYLE_DEFAULT lParam:(sptr_t) "Menlo"];
  [sv message:SCI_STYLESETSIZE wParam:STYLE_DEFAULT lParam:15];
  [sv message:SCI_STYLESETFORE
       wParam:STYLE_DEFAULT
       lParam:SCIRGB(212, 212, 212)];
  [sv message:SCI_STYLESETBACK wParam:STYLE_DEFAULT lParam:SCIRGB(30, 30, 30)];
  [sv message:SCI_STYLECLEARALL wParam:0 lParam:0];

  /* Line number margin */
  [sv message:SCI_SETMARGINTYPEN wParam:0 lParam:SC_MARGIN_NUMBER];
  [sv message:SCI_SETMARGINWIDTHN wParam:0 lParam:48];
  [sv message:SCI_STYLESETFORE
       wParam:STYLE_LINENUMBER
       lParam:SCIRGB(133, 133, 133)];
  [sv message:SCI_STYLESETBACK
       wParam:STYLE_LINENUMBER
       lParam:SCIRGB(37, 37, 38)];

  /* Folding margin — dark background matching editor */
  [sv message:SCI_SETMARGINTYPEN wParam:2 lParam:SC_MARGIN_SYMBOL];
  [sv message:SCI_SETMARGINMASKN wParam:2 lParam:SC_MASK_FOLDERS];
  [sv message:SCI_SETMARGINWIDTHN wParam:2 lParam:16];
  [sv message:SCI_SETMARGINSENSITIVEN wParam:2 lParam:1];
  [sv message:SCI_SETFOLDMARGINCOLOUR wParam:1 lParam:SCIRGB(37, 37, 38)];
  [sv message:SCI_SETFOLDMARGINHICOLOUR wParam:1 lParam:SCIRGB(37, 37, 38)];
  [sv message:2663                     /* SCI_SETAUTOMATICFOLD */
       wParam:0x0001 | 0x0002 | 0x0004 /* SHOW|CLICK|CHANGE */
       lParam:0];

  /* Fold markers — box style */
  [sv message:SCI_MARKERDEFINE wParam:SC_MARKNUM_FOLDER lParam:SC_MARK_BOXPLUS];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDEROPEN
       lParam:SC_MARK_BOXMINUS];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDERSUB
       lParam:SC_MARK_VLINE];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDERTAIL
       lParam:SC_MARK_LCORNER];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDEREND
       lParam:SC_MARK_BOXPLUSCONNECTED];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDEROPENMID
       lParam:SC_MARK_BOXMINUSCONNECTED];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDERMIDTAIL
       lParam:SC_MARK_TCORNER];

  for (int m = 25; m <= 31; m++) {
    [sv message:2041 /* SCI_MARKERSETFORE */
         wParam:m
         lParam:SCIRGB(160, 160, 160)];
    [sv message:2042 /* SCI_MARKERSETBACK */
         wParam:m
         lParam:SCIRGB(37, 37, 38)];
  }

  /* Enable folding properties */
  [sv message:SCI_SETPROPERTY wParam:(uptr_t) "fold" lParam:(sptr_t) "1"];
  [sv message:SCI_SETPROPERTY
       wParam:(uptr_t) "fold.compact"
       lParam:(sptr_t) "0"];
  [sv message:SCI_SETPROPERTY
       wParam:(uptr_t) "fold.comment"
       lParam:(sptr_t) "1"];
  [sv message:SCI_SETPROPERTY
       wParam:(uptr_t) "fold.preprocessor"
       lParam:(sptr_t) "1"];

  /* ===== Syntax highlighting colours (HarbourBuilder VS Code Dark+) =====
   */
  /* Map HarbourBuilder C styles to our Flagship Lexer IDs */
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD
       lParam:SCIRGB(86, 156, 214)];
  [sv message:SCI_STYLESETBOLD wParam:SCE_FS_KEYWORD lParam:1];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD2
       lParam:SCIRGB(78, 201, 176)];

  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_COMMENT
       lParam:SCIRGB(106, 153, 85)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_COMMENTLINE
       lParam:SCIRGB(106, 153, 85)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_COMMENTDOC
       lParam:SCIRGB(106, 153, 85)];
  [sv message:SCI_STYLESETITALIC wParam:SCE_FS_COMMENT lParam:1];
  [sv message:SCI_STYLESETITALIC wParam:SCE_FS_COMMENTLINE lParam:1];

  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_STRING
       lParam:SCIRGB(206, 145, 120)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_NUMBER
       lParam:SCIRGB(181, 206, 168)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD3
       lParam:SCIRGB(197, 134, 192)]; // Preprocessor style
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_OPERATOR
       lParam:SCIRGB(212, 212, 212)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_IDENTIFIER
       lParam:SCIRGB(220, 220, 220)];

  /* Caret and selection */
  [sv message:SCI_SETCARETFORE wParam:SCIRGB(255, 255, 255) lParam:0];
  [sv message:SCI_SETSELBACK wParam:1 lParam:SCIRGB(38, 79, 120)];

  /* Line spacing - premium feel */
  [sv message:2525 /* SCI_SETEXTRAASCENT */ wParam:4 lParam:0];
  [sv message:2526 /* SCI_SETEXTRADESCENT */ wParam:4 lParam:0];

  /* Indentation guides */
  [sv message:SCI_SETINDENTATIONGUIDES wParam:SC_IV_LOOKBOTH lParam:0];

  /* Bracket matching style */
  [sv message:SCI_STYLESETFORE
       wParam:34 /* STYLE_BRACELIGHT */
       lParam:SCIRGB(255, 255, 0)];
  [sv message:SCI_STYLESETBACK
       wParam:34 /* STYLE_BRACELIGHT */
       lParam:SCIRGB(60, 60, 60)];
  [sv message:SCI_STYLESETBOLD wParam:34 /* STYLE_BRACELIGHT */ lParam:1];
  [sv message:SCI_STYLESETFORE
       wParam:35 /* STYLE_BRACEBAD */
       lParam:SCIRGB(255, 0, 0)];
  [sv message:SCI_STYLESETBACK
       wParam:35 /* STYLE_BRACEBAD */
       lParam:SCIRGB(60, 30, 30)];
  [sv message:SCI_STYLESETBOLD wParam:35 /* STYLE_BRACEBAD */ lParam:1];

  /* Error markers and execution line (HB exact) */
  [sv message:SCI_MARKERDEFINE wParam:10 lParam:SC_MARK_BACKGROUND];
  [sv message:2042 /* SCI_MARKERSETBACK */
       wParam:10
       lParam:SCIRGB(80, 20, 20)];
  [sv message:SCI_MARKERDEFINE wParam:11 lParam:SC_MARK_BACKGROUND];
  [sv message:2042 /* SCI_MARKERSETBACK */
       wParam:11
       lParam:SCIRGB(80, 80, 20)];

  /* Bookmarks (0-9) */
  [sv message:SCI_SETMARGINTYPEN wParam:1 lParam:SC_MARGIN_SYMBOL];
  [sv message:SCI_SETMARGINWIDTHN wParam:1 lParam:16];
  [sv message:SCI_SETMARGINMASKN wParam:1 lParam:0x3FF];
  [sv message:SCI_SETMARGINSENSITIVEN wParam:1 lParam:1];
  for (int m = 0; m <= 9; m++) {
    [sv message:SCI_MARKERDEFINE wParam:m lParam:SC_MARK_SHORTARROW];
    [sv message:2041 /* SCI_MARKERSETFORE */
         wParam:m
         lParam:SCIRGB(80, 180, 255)];
    [sv message:2042 /* SCI_MARKERSETBACK */
         wParam:m
         lParam:SCIRGB(40, 40, 50)];
  }
}

void ApplyLightTheme(ScintillaView *sv) {
  // Default Style: Classic
  [sv message:SCI_STYLESETFONT wParam:STYLE_DEFAULT lParam:(sptr_t) "Menlo"];
  [sv message:SCI_STYLESETSIZE wParam:STYLE_DEFAULT lParam:15];
  [sv message:SCI_STYLESETFORE wParam:STYLE_DEFAULT lParam:SCIRGB(0, 0, 0)];
  [sv message:SCI_STYLESETBACK
       wParam:STYLE_DEFAULT
       lParam:SCIRGB(255, 255, 255)];
  [sv message:SCI_STYLECLEARALL wParam:0 lParam:0];

  // Caret and selection
  [sv message:SCI_SETCARETFORE wParam:SCIRGB(0, 0, 0) lParam:0];
  [sv message:SCI_SETSELBACK wParam:1 lParam:SCIRGB(180, 210, 250)];

  // Margins
  [sv message:SCI_STYLESETFORE
       wParam:STYLE_LINENUMBER
       lParam:SCIRGB(120, 120, 120)];
  [sv message:SCI_STYLESETBACK
       wParam:STYLE_LINENUMBER
       lParam:SCIRGB(240, 240, 240)];
  [sv message:SCI_SETFOLDMARGINCOLOUR wParam:1 lParam:SCIRGB(240, 240, 240)];
  [sv message:SCI_SETFOLDMARGINHICOLOUR wParam:1 lParam:SCIRGB(240, 240, 240)];

  for (int m = 25; m <= 31; ++m) {
    [sv message:2041 /* SCI_MARKERSETFORE */
         wParam:m
         lParam:SCIRGB(100, 100, 100)];
    [sv message:2042 /* SCI_MARKERSETBACK */
         wParam:m
         lParam:SCIRGB(240, 240, 240)];
  }

  // Flagship Styles (Light)
  [sv message:SCI_STYLESETFORE wParam:SCE_FS_COMMENT lParam:SCIRGB(0, 128, 0)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_COMMENTLINE
       lParam:SCIRGB(0, 128, 0)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_COMMENTDOC
       lParam:SCIRGB(0, 128, 0)];
  [sv message:SCI_STYLESETFORE wParam:SCE_FS_KEYWORD lParam:SCIRGB(0, 0, 255)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD2
       lParam:SCIRGB(0, 100, 200)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD3
       lParam:SCIRGB(100, 0, 150)];
  [sv message:SCI_STYLESETFORE wParam:SCE_FS_NUMBER lParam:SCIRGB(200, 0, 0)];
  [sv message:SCI_STYLESETFORE wParam:SCE_FS_STRING lParam:SCIRGB(163, 21, 21)];
  [sv message:SCI_STYLESETFORE wParam:SCE_FS_OPERATOR lParam:SCIRGB(0, 0, 0)];
  [sv message:SCI_STYLESETFORE wParam:SCE_FS_IDENTIFIER lParam:SCIRGB(0, 0, 0)];

  // Braces
  [sv message:SCI_STYLESETFORE wParam:34 lParam:SCIRGB(0, 0, 255)];
  [sv message:SCI_STYLESETBACK wParam:34 lParam:SCIRGB(200, 200, 200)];

  [sv message:2525 /* SCI_SETEXTRAASCENT */ wParam:4 lParam:0];
  [sv message:2526 /* SCI_SETEXTRADESCENT */ wParam:4 lParam:0];
}

void ApplyMonokaiTheme(ScintillaView *sv) {
  [sv message:SCI_STYLESETFONT wParam:STYLE_DEFAULT lParam:(sptr_t) "Menlo"];
  [sv message:SCI_STYLESETSIZE wParam:STYLE_DEFAULT lParam:15];
  [sv message:SCI_STYLESETFORE
       wParam:STYLE_DEFAULT
       lParam:SCIRGB(248, 248, 242)];
  [sv message:SCI_STYLESETBACK wParam:STYLE_DEFAULT lParam:SCIRGB(39, 40, 34)];
  [sv message:SCI_STYLECLEARALL wParam:0 lParam:0];

  [sv message:SCI_SETCARETFORE wParam:SCIRGB(248, 248, 242) lParam:0];
  [sv message:SCI_SETSELBACK wParam:1 lParam:SCIRGB(73, 72, 62)];

  [sv message:SCI_STYLESETFORE
       wParam:STYLE_LINENUMBER
       lParam:SCIRGB(144, 145, 139)];
  [sv message:SCI_STYLESETBACK
       wParam:STYLE_LINENUMBER
       lParam:SCIRGB(43, 44, 38)];

  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_COMMENT
       lParam:SCIRGB(117, 113, 94)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_COMMENTLINE
       lParam:SCIRGB(117, 113, 94)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD
       lParam:SCIRGB(249, 38, 114)]; // Pink
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD2
       lParam:SCIRGB(102, 217, 239)]; // Cyan
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD3
       lParam:SCIRGB(174, 129, 255)]; // Purple
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_NUMBER
       lParam:SCIRGB(174, 129, 255)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_STRING
       lParam:SCIRGB(230, 219, 116)]; // Yellow
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_OPERATOR
       lParam:SCIRGB(249, 38, 114)];

  [sv message:2525 /* SCI_SETEXTRAASCENT */ wParam:4 lParam:0];
  [sv message:2526 /* SCI_SETEXTRADESCENT */ wParam:4 lParam:0];
}

void ApplySolarizedDarkTheme(ScintillaView *sv) {
  [sv message:SCI_STYLESETFONT wParam:STYLE_DEFAULT lParam:(sptr_t) "Menlo"];
  [sv message:SCI_STYLESETSIZE wParam:STYLE_DEFAULT lParam:15];
  [sv message:SCI_STYLESETFORE
       wParam:STYLE_DEFAULT
       lParam:SCIRGB(131, 148, 150)];
  [sv message:SCI_STYLESETBACK wParam:STYLE_DEFAULT lParam:SCIRGB(0, 43, 54)];
  [sv message:SCI_STYLECLEARALL wParam:0 lParam:0];

  [sv message:SCI_SETCARETFORE wParam:SCIRGB(131, 148, 150) lParam:0];
  [sv message:SCI_SETSELBACK wParam:1 lParam:SCIRGB(7, 54, 66)];

  [sv message:SCI_STYLESETFORE
       wParam:STYLE_LINENUMBER
       lParam:SCIRGB(88, 110, 117)];
  [sv message:SCI_STYLESETBACK
       wParam:STYLE_LINENUMBER
       lParam:SCIRGB(7, 54, 66)];

  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_COMMENT
       lParam:SCIRGB(88, 110, 117)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD
       lParam:SCIRGB(133, 153, 0)]; // Green
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD2
       lParam:SCIRGB(181, 137, 0)]; // Yellow/Orange
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_KEYWORD3
       lParam:SCIRGB(211, 54, 130)]; // Magenta
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_NUMBER
       lParam:SCIRGB(42, 161, 152)]; // Cyan
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_STRING
       lParam:SCIRGB(42, 161, 152)];
  [sv message:SCI_STYLESETFORE
       wParam:SCE_FS_OPERATOR
       lParam:SCIRGB(131, 148, 150)];

  // Braces
  [sv message:SCI_STYLESETFORE wParam:34 lParam:SCIRGB(38, 139, 210)]; // Solarized Blue
  [sv message:SCI_STYLESETBACK wParam:34 lParam:SCIRGB(7, 54, 66)];    // Base02
  [sv message:SCI_STYLESETBOLD wParam:34 lParam:1];
  [sv message:SCI_STYLESETFORE wParam:35 lParam:SCIRGB(220, 50, 47)];  // Solarized Red

  [sv message:2525 /* SCI_SETEXTRAASCENT */ wParam:4 lParam:0];
  [sv message:2526 /* SCI_SETEXTRADESCENT */ wParam:4 lParam:0];
}

// === BRIDGE ===
#undef WM_NOTIFY
#include "../include/fivemac.h"

@interface ThemeController : NSObject
@property(nonatomic, unsafe_unretained) ScintillaView *sv;
@end
@implementation ThemeController
@end

ScintillaView *SetupScintillaView(NSWindow *window, NSRect rect, void *pHarbourObj) {
  // 1. Restauramos la vista contenedora con sus 50px de margen
  NSView *container = [[NSView alloc] initWithFrame:rect];
  [container setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [[window contentView] addSubview:container];

  // 2. Ponemos el SV dentro con un margen interno adicional de 20px
  NSRect svFrame = NSInsetRect([container bounds], 1, 1);
  ScintillaView *sv = [[ScintillaView alloc] initWithFrame:svFrame];
  [sv setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

  [container addSubview:sv];

  // Create the delegate and bind it
  MySciDelegate *delegate = [[MySciDelegate alloc] init];
  delegate.sv = sv;
  delegate.pHarbourObj = pHarbourObj;
  sv.delegate = delegate;
  
  // Persist the delegate by attaching it to the ScintillaView instance
  objc_setAssociatedObject(sv, "MySciDelegate", delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  // === MONITOR DE EVENTOS PARA SNIPPETS (Tab Expansion) ===
  [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown
                                         handler:^NSEvent *(NSEvent *event) {
    NSView *firstResponder = (NSView *)[[sv window] firstResponder];
    if ([firstResponder isEqual:sv] || [firstResponder isDescendantOf:sv]) {
      if ([event keyCode] == 48) { // 48 = Tab
        sptr_t pos = [sv message:SCI_GETCURRENTPOS wParam:0 lParam:0];
        sptr_t lineStart = [sv message:SCI_POSITIONFROMLINE wParam:[sv message:SCI_LINEFROMPOSITION wParam:pos lParam:0] lParam:0];
        
        if (pos > lineStart) {
          struct Sci_TextRange tr;
          char lineText[1024];
          tr.chrg.cpMin = (Sci_Position)lineStart;
          tr.chrg.cpMax = (Sci_Position)pos;
          tr.lpstrText = lineText;
          [sv message:SCI_GETTEXTRANGE wParam:0 lParam:(sptr_t)&tr];
          lineText[pos - lineStart] = '\0';
          
          NSString *rawLine = [NSString stringWithUTF8String:lineText];
          NSString *nsLine = [rawLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
          
          __block NSString *foundPrefix = nil;
          __block NSString *snippetText = nil;
          
          [s_snippets enumerateKeysAndObjectsUsingBlock:^(NSString *prefix, NSString *text, BOOL *stop) {
              if ([nsLine hasSuffix:prefix]) {
                  foundPrefix = prefix;
                  snippetText = text;
                  *stop = YES;
              }
          }];

          if (snippetText) {
            __block NSString *template = [snippetText copy];
            
            // 1. Detectamos la indentación REAL de la línea original
            NSString *indent = @"";
            NSRange firstNonWhitespace = [rawLine rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
            if (firstNonWhitespace.location != NSNotFound && firstNonWhitespace.location > 0) {
                indent = [rawLine substringToIndex:firstNonWhitespace.location];
            }

            // 2. Aplicamos la indentación a cada nueva línea del snippet
            if ([indent length] > 0) {
                template = [template stringByReplacingOccurrencesOfString:@"\n" 
                                                              withString:[NSString stringWithFormat:@"\n%@", indent]];
            }

            __block NSRange targetRange = NSMakeRange(NSNotFound, 0);
            NSArray *placeholders = @[@"$1", @"$2", @"$0"];
            for (NSString *p in placeholders) {
                NSRange r = [template rangeOfString:p];
                if (r.location != NSNotFound) {
                    targetRange = NSMakeRange(r.location, 0);
                    break;
                }
            }

            for (NSString *p in placeholders) {
                template = [template stringByReplacingOccurrencesOfString:p withString:@""];
            }

            sptr_t start = pos - [foundPrefix length];
            char tip[512];
            snprintf(tip, sizeof(tip), "¡Expandido!: %s", [foundPrefix UTF8String]);
            [sv message:SCI_CALLTIPSHOW wParam:pos lParam:(sptr_t)tip];
            
            [sv message:SCI_DELETERANGE wParam:(uptr_t)start lParam:(sptr_t)(pos - start)];
            [sv message:SCI_INSERTTEXT wParam:(uptr_t)start lParam:(sptr_t)[template UTF8String]];
            
            sptr_t finalPos = (targetRange.location != NSNotFound) ? (start + targetRange.location) : (start + [template length]);
            [sv message:SCI_GOTOPOS wParam:(uptr_t)finalPos lParam:0];
            return nil;
          }
        }
      }
    }
    return event;
  }];

  CE_ConfigureScintilla(sv);

  // 3. Truco para que la línea 1 no salga "pegada" arriba:
  [sv message:2525 /* SCI_SETEXTRAASCENT */ wParam:5 lParam:0];
  [sv message:2526 /* SCI_SETEXTRADESCENT */ wParam:5 lParam:0];

  ApplyHarbourLexer(sv);

  // Folding
  [sv message:SCI_SETPROPERTY wParam:(uptr_t) "fold" lParam:(sptr_t) "1"];
  [sv message:SCI_SETPROPERTY wParam:(uptr_t) "fold.compact" lParam:(sptr_t) "0"];
  [sv message:SCI_SETPROPERTY wParam:(uptr_t) "fold.comment" lParam:(sptr_t) "1"];

  // Line Number Margin Setup
  ApplyLineNumberMargin(sv, 48);

  // Default Function Icon for Autocomplete (?1)
  // We use a static array of pointers because Scintilla XPM parser expects char**
  static const char *func_xpm[] = {
      "16 11 2 1",    "  c None",    ". c #0000FF", "                ",
      "   ..........   ", "  ............  ", "  ............  ",
      "  ............  ", "  ............  ", "  ............  ",
      "  ............  ", "  ............  ", "   ..........   ",
      "                "};
  [sv message:SCI_REGISTERIMAGE wParam:1 lParam:(sptr_t)func_xpm];

  // Folding Margin Setup
  [sv message:SCI_SETMARGINTYPEN wParam:2 lParam:SC_MARGIN_SYMBOL];
  [sv message:SCI_SETMARGINMASKN wParam:2 lParam:SC_MASK_FOLDERS];
  [sv message:SCI_SETMARGINWIDTHN wParam:2 lParam:16];
  [sv message:SCI_SETMARGINSENSITIVEN wParam:2 lParam:1];

  [sv message:SCI_MARKERDEFINE wParam:SC_MARKNUM_FOLDER lParam:SC_MARK_BOXPLUS];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDEROPEN
       lParam:SC_MARK_BOXMINUS];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDERSUB
       lParam:SC_MARK_VLINE];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDERTAIL
       lParam:SC_MARK_LCORNER];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDEREND
       lParam:SC_MARK_BOXPLUSCONNECTED];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDEROPENMID
       lParam:SC_MARK_BOXMINUSCONNECTED];
  [sv message:SCI_MARKERDEFINE
       wParam:SC_MARKNUM_FOLDERMIDTAIL
       lParam:SC_MARK_TCORNER];

  // Brace Highlighting Logic (Common)
  [sv message:SCI_STYLESETBOLD wParam:34 lParam:1];
  [sv message:SCI_STYLESETFORE wParam:35 lParam:SCIRGB(255, 0, 0)];
  [sv message:SCI_STYLESETBACK wParam:35 lParam:SCIRGB(60, 30, 30)];
  [sv message:SCI_STYLESETBOLD wParam:35 lParam:1];

  // Automatic Folding Behavior
  [sv message:2663 /* SCI_SETAUTOMATICFOLD */
       wParam:0x0001 | 0x0002 | 0x0004
       lParam:0];

  // Harbour Keywords

  ApplyHarbourKeywords0(sv);
  ApplyHarbourKeywords1(sv);

  return sv;
}

// ============================================================================
// SCISETGLOBALSNIPPETS - Load snippets dictionary from Harbour
// ============================================================================
HB_FUNC(SCISETGLOBALSNIPPETS) {
  if (HB_ISCHAR(1)) {
    NSString *jsonString = hb_NSSTRING_par(1);
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *rawDict = [NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                          error:&error];
    if (!error && [rawDict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *processed = [NSMutableDictionary dictionary];
        for (NSString *key in rawDict) {
            NSDictionary *entry = rawDict[key];
            if ([entry isKindOfClass:[NSDictionary class]]) {
                NSString *prefix = entry[@"prefix"];
                id body = entry[@"body"];
                if (prefix && [body isKindOfClass:[NSArray class]]) {
                    // Unir líneas del body sin limpiar, para que el expansor vea los $1
                    NSString *fullBody = [body componentsJoinedByString:@"\n"];
                    processed[prefix] = fullBody;
                }
            }
        }
        s_snippets = processed;
    }
  }
}

// ============================================================================
// SCISETTEXT - Set the editor text
// ============================================================================
HB_FUNC(SCISETTEXT) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv && HB_ISCHAR(2))
    [sv setString:hb_NSSTRING_par(2)];
}

// ============================================================================
// SCI_LINEMARGIN - Set the line number margin width
// ============================================================================
HB_FUNC(SCI_LINEMARGIN) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  // Line Number Margin Setup
  [sv message:SCI_SETMARGINTYPEN wParam:0 lParam:SC_MARGIN_NUMBER];
  [sv message:SCI_SETMARGINWIDTHN wParam:0 lParam:(sptr_t)hb_parnll(2)];
}

HB_FUNC(SCISETGLOBALDOCS) {
  const char *raw = hb_parc(1);
  if (!raw)
    return;

  // Free previous list if any
  if (s_harbourDocs) {
    for (int i = 0; i < s_harbourDocsCount; i++) {
      free(s_harbourDocs[i].name);
      free(s_harbourDocs[i].syntax);
      free(s_harbourDocs[i].doc);
    }
    free(s_harbourDocs);
  }

  // Count items (separated by chr(2))
  int count = 0;
  for (const char *p = raw; *p; p++) {
    if (*p == 2)
      count++;
  }

  s_harbourDocsCount = count;
  s_harbourDocs = (HarbourDoc *)malloc(sizeof(HarbourDoc) * count);

  const char *p = raw;
  for (int i = 0; i < count; i++) {
    const char *sep1 = strchr(p, 1);
    const char *sep2 = sep1 ? strchr(sep1 + 1, 1) : NULL;
    const char *sep3 = sep2 ? strchr(sep2 + 1, 2) : NULL;

    if (sep1 && sep2 && sep3) {
      size_t nameLen = (size_t)(sep1 - p);
      size_t syntaxLen = (size_t)(sep2 - sep1 - 1);
      size_t docLen = (size_t)(sep3 - sep2 - 1);

      s_harbourDocs[i].name = (char *)malloc(nameLen + 1);
      memcpy(s_harbourDocs[i].name, p, nameLen);
      s_harbourDocs[i].name[nameLen] = 0;

      s_harbourDocs[i].syntax = (char *)malloc(syntaxLen + 1);
      memcpy(s_harbourDocs[i].syntax, sep1 + 1, syntaxLen);
      s_harbourDocs[i].syntax[syntaxLen] = 0;

      s_harbourDocs[i].doc = (char *)malloc(docLen + 1);
      memcpy(s_harbourDocs[i].doc, sep2 + 1, docLen);
      s_harbourDocs[i].doc[docLen] = 0;

      p = sep3 + 1;
    } else {
      break;
    }
  }
}

// ============================================================================
// SCICREATE - Create a ScintillaView and add it to a window
// ============================================================================
// ============================================================================
// SCISETGLOBALKEYWORDS - Store the full dictionary in C for instant access
// ============================================================================
HB_FUNC(SCISETGLOBALKEYWORDS) {
  if (HB_ISCHAR(1)) {
    if (s_harbourGlobalList)
      free(s_harbourGlobalList);
    s_harbourGlobalList = strdup(hb_parc(1));
  }
}

HB_FUNC(SCICREATE) {
  NSWindow *window = (NSWindow *)hb_parnll(5);
  NSRect rect;
  rect.origin.y = hb_parnl(1);
  rect.origin.x = hb_parnl(2);
  rect.size.height = hb_parnl(3);
  rect.size.width = hb_parnl(4);

  PHB_ITEM pSelf = (hb_pcount() >= 6) ? hb_itemNew(hb_itemParam(6)) : NULL;
  ScintillaView *sv = SetupScintillaView(window, rect, pSelf);
  
  // Store the Harbour object pointer for event callbacks (wrapped in NSValue to avoid crash)
  if (pSelf) {
     NSValue *val = [NSValue valueWithPointer:pSelf];
     objc_setAssociatedObject(sv, "pHarbourObj", val, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  
  hb_retnll((HB_LONGLONG)sv);
}

// ============================================================================
// SCINTILLA_SET_THEME - Set the editor theme
// ============================================================================
HB_FUNC(SCINTILLA_SET_THEME) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  int nTheme = hb_parni(2);
  if (sv) {
    switch (nTheme) {
    case 1:
      ApplyDarkTheme(sv);
      break;
    case 2:
      ApplyLightTheme(sv);
      break;
    case 3:
      ApplyMonokaiTheme(sv);
      break;
    case 4:
      ApplySolarizedDarkTheme(sv);
      break;
    }
  }
}

// ============================================================================
// SCISETLEXER - Load a lexer by name using Scintilla 5 CreateLexer +
// SCI_SETILEXER e.g. SCISETLEXER( hWnd, "flagship" )
// ============================================================================

HB_FUNC(SCISETLEXER) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv && HB_ISCHAR(2)) {
    void *pLexer = CreateLexer(hb_parc(2));
    if (pLexer) {
      [sv message:4033 wParam:0 lParam:(sptr_t)pLexer]; // SCI_SETILEXER = 4033
      hb_retl(YES);
    } else {
      hb_retl(NO);
    }
  }
}

// ============================================================================
// SCISEND - Universal message sender (the ONLY tunnel needed)
// ============================================================================
HB_FUNC(SCISEND) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  unsigned int msg = (unsigned int)hb_parni(2);

  if (sv) {
    uptr_t wParam = 0;
    sptr_t lParam = 0;

    if (HB_ISCHAR(3))
      wParam = (uptr_t)hb_parc(3);
    else if (HB_ISNUM(3))
      wParam = (uptr_t)hb_parnll(3);

    if (HB_ISCHAR(4))
      lParam = (sptr_t)hb_parc(4);
    else if (HB_ISNUM(4))
      lParam = (sptr_t)hb_parnll(4);

    hb_retnll((HB_LONGLONG)[sv message:msg wParam:wParam lParam:lParam]);
  } else
    hb_retnll(0);
}

// ============================================================================
// SCIGETTEXT - Get the editor text
// ============================================================================
HB_FUNC(SCIGETTEXT) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv) {
    sptr_t len = [sv message:SCI_GETLENGTH wParam:0 lParam:0];
    char *buffer = (char *)hb_xgrab((HB_SIZE)len + 1);
    [sv message:SCI_GETTEXT wParam:(uptr_t)len + 1 lParam:(sptr_t)buffer];
    hb_retclen(buffer, (HB_SIZE)len);
    hb_xfree(buffer);
  } else
    hb_retc("");
}

/////////////////////////////////
///////////////////////////////////
//////////////////////////////////

// ============================================================================
// SCISETFONT - Set font name, size, bold, italic
// ============================================================================
HB_FUNC(SCISETFONT) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv)
    [sv setFontName:hb_NSSTRING_par(2)
               size:hb_parni(3)
               bold:hb_parl(4)
             italic:hb_parl(5)];
}

// ============================================================================
// SCIGETLINE - Get text of a specific line (1-based from Harbour)
// ============================================================================
HB_FUNC(SCIGETLINE) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv) {
    uptr_t line = (uptr_t)hb_parni(2) - 1; // Harbour is 1-based
    sptr_t len = [sv message:SCI_LINELENGTH wParam:line lParam:0];
    if (len > 0) {
      char *buffer = (char *)hb_xgrab((HB_SIZE)len + 1);
      [sv message:SCI_GETLINE wParam:line lParam:(sptr_t)buffer];
      hb_retclen(buffer, (HB_SIZE)len);
      hb_xfree(buffer);
    } else
      hb_retc("");
  } else
    hb_retc("");
}

// ============================================================================
// SCIGETVALUE - Get a single numeric property (no params)
// ============================================================================
HB_FUNC(SCIGETVALUE) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv)
    hb_retnll(
        (HB_LONGLONG)[sv message:(unsigned int)hb_parni(2) wParam:0 lParam:0]);
  else
    hb_retnll(0);
}

// ============================================================================
// SCIGETONEPROP - Alias for SCIGETVALUE (backward compat)
// ============================================================================
HB_FUNC(SCIGETONEPROP) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv)
    hb_retnll(
        (HB_LONGLONG)[sv message:(unsigned int)hb_parni(2) wParam:0 lParam:0]);
  else
    hb_retnll(0);
}

// ============================================================================
// SCIGETPROP - Get a property with wParam and optional lParam
// ============================================================================
HB_FUNC(SCIGETPROP) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv) {
    uptr_t wParam = (uptr_t)hb_parnll(3);
    sptr_t lParam = HB_ISCHAR(4) ? (sptr_t)hb_parc(4) : (sptr_t)hb_parnll(4);
    hb_retnll((HB_LONGLONG)[sv message:(unsigned int)hb_parni(2)
                                wParam:wParam
                                lParam:lParam]);
  } else
    hb_retnll(0);
}

// ============================================================================
// SCIGETSELTEXT - Get selected text
// ============================================================================
HB_FUNC(SCIGETSELTEXT) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv) {
    sptr_t len = [sv message:SCI_GETSELTEXT wParam:0 lParam:0];
    if (len > 0) {
      char *buffer = (char *)hb_xgrab((HB_SIZE)len + 1);
      [sv message:SCI_GETSELTEXT wParam:0 lParam:(sptr_t)buffer];
      hb_retclen(buffer, (HB_SIZE)len);
      hb_xfree(buffer);
    } else
      hb_retc("");
  } else
    hb_retc("");
}

// ============================================================================
// SCIGETKEYWORDS - Set keywords for a keyword set (SCI_SETKEYWORDS)
// ============================================================================
HB_FUNC(SCIGETKEYWORDS) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv && HB_ISCHAR(2)) {
    NSString *str = hb_NSSTRING_par(2);
    hb_retnll((HB_LONGLONG)[sv message:SCI_SETKEYWORDS
                                wParam:(uptr_t)hb_parnl(3)
                                lParam:(sptr_t)[str UTF8String]]);
  } else
    hb_retnll(0);
}

// ============================================================================
// SCIGETTEXTRANGE - Get text between two positions
// ============================================================================
HB_FUNC(SCIGETTEXTRANGE) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv) {
    sptr_t cpMin = hb_parni(2);
    sptr_t cpMax = hb_parni(3);
    int len = (int)(cpMax - cpMin);
    if (len > 0) {
      char *buffer = (char *)hb_xgrab(len + 1);
      buffer[len] = 0;
      // Use SCI_GETTEXT approach: set selection, get selected text
      [sv message:SCI_SETSEL wParam:(uptr_t)cpMin lParam:cpMax];
      [sv message:SCI_GETSELTEXT wParam:0 lParam:(sptr_t)buffer];
      hb_retc(buffer);
      hb_xfree(buffer);
    } else
      hb_retc("");
  } else
    hb_retc("");
}

// ============================================================================
// SCIREGIMAGE / SCIREGIMAGEFROMFILE
// ============================================================================
HB_FUNC(SCIREGIMAGE) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv)
    [sv message:SCI_REGISTERIMAGE
         wParam:(uptr_t)hb_parni(2)
         lParam:(sptr_t)hb_parc(3)];
}

HB_FUNC(SCIREGIMAGEFROMFILE) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv) {
    NSString *content = [NSString stringWithContentsOfFile:hb_NSSTRING_par(3)
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    if (content)
      [sv message:SCI_REGISTERIMAGE
           wParam:(uptr_t)hb_parni(2)
           lParam:(sptr_t)[content UTF8String]];
  }
}

// ============================================================================
// SCISETLEXERPROP - Set lexer property (fold, fold.compact, etc.)
// ============================================================================
HB_FUNC(SCISETLEXERPROP) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv)
    [sv setLexerProperty:hb_NSSTRING_par(2) value:hb_NSSTRING_par(3)];
}

// ============================================================================
// SCISEARCHFORWARD / SCISEARCHBACKWARD
// ============================================================================
HB_FUNC(SCISEARCHFORWARD) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv) {
    NSString *searchText = hb_NSSTRING_par(2);
    BOOL found = [sv findAndHighlightText:searchText
                                matchCase:NO
                                wholeWord:NO
                                 scrollTo:YES
                                     wrap:YES
                                backwards:NO];
    hb_retl(found);
  } else
    hb_retl(FALSE);
}

HB_FUNC(SCISEARCHBACKWARD) {
  ScintillaView *sv = (ScintillaView *)hb_parnll(1);
  if (sv) {
    NSString *searchText = hb_NSSTRING_par(2);
    BOOL found = [sv findAndHighlightText:searchText
                                matchCase:NO
                                wholeWord:NO
                                 scrollTo:YES
                                     wrap:YES
                                backwards:YES];
    hb_retl(found);
  } else
    hb_retl(FALSE);
}

// ============================================================================
// Notification Helpers (Restored from legacy)
// ============================================================================

HB_FUNC(SCNCODE) {
  SCNotification *notification = (SCNotification *)hb_parnll(1);
  hb_retnll(notification->nmhdr.code);
}

HB_FUNC(SCNCH) {
  SCNotification *notification = (SCNotification *)hb_parnll(1);
  hb_retnll(notification->ch);
}

HB_FUNC(SCNMARGIN) {
  SCNotification *notification = (SCNotification *)hb_parnll(1);
  hb_retnll(notification->margin);
}

HB_FUNC(SCNPOS) {
  SCNotification *notification = (SCNotification *)hb_parnll(1);
  hb_retnll(notification->position);
}

HB_FUNC(SCIGETNOTIFYTEXT) {
  SCNotification *notification = (SCNotification *)hb_parnll(1);
  if (notification && notification->text)
    hb_retc((char *)notification->text);
  else
    hb_retc("");
}
