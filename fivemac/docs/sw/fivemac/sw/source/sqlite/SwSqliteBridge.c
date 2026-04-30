#include <hbapi.h>
#include <hbapiitm.h>
#include <sqlite3.h>

// Handle SQLite database pointers as Generic Pointers via hb_parptr / hb_retptr

HB_FUNC(SQLITE_OPEN) {
  sqlite3 *db;
  const char *cFilename = hb_parc(1);
  int nFlags =
      HB_ISNUM(2) ? hb_parni(2) : (SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE);

  if (sqlite3_open_v2(cFilename, &db, nFlags, NULL) == SQLITE_OK)
    hb_retptr(db);
  else {
    sqlite3_close(db);
    hb_retptr(NULL);
  }
}

HB_FUNC(SQLITE_CLOSE) {
  sqlite3 *db = (sqlite3 *)hb_parptr(1);

  if (db)
    sqlite3_close(db);
}

HB_FUNC(SQLITE_ERRMSG) {
  sqlite3 *db = (sqlite3 *)hb_parptr(1);

  if (db)
    hb_retc(sqlite3_errmsg(db));
  else
    hb_retc("");
}

// Callback for SQLITE_EXEC to store result in an array
static int callback_array(void *ptr, int argc, char **argv, char **azColName) {
  PHB_ITEM pArray = (PHB_ITEM)ptr;
  PHB_ITEM pRow = hb_itemNew(NULL);
  int i;

  hb_arrayNew(pRow, 0);

  for (i = 0; i < argc; i++) {
    PHB_ITEM pVal = hb_itemNew(NULL);
    if (argv[i])
      hb_itemPutC(pVal, argv[i]);
    else
      hb_itemPutC(pVal, ""); // NULL values as empty strings

    hb_arrayAdd(pRow, pVal);
    hb_itemRelease(pVal);
  }

  hb_arrayAdd(pArray, pRow);
  hb_itemRelease(pRow);

  return 0;
}

HB_FUNC(SQLITE_EXEC) {
  sqlite3 *db = (sqlite3 *)hb_parptr(1);
  const char *sql = hb_parc(2);
  char *zErrMsg = 0;
  int rc;

  if (!db) {
    hb_retnl(-1);
    return;
  }

  rc = sqlite3_exec(db, sql, NULL, 0, &zErrMsg);

  if (rc != SQLITE_OK) {
    sqlite3_free(zErrMsg);
    hb_retnl(rc);
  } else {
    hb_retnl(0); // SQLITE_OK
  }
}

// Query returns an array of arrays
HB_FUNC(SQLITE_QUERY) {
  sqlite3 *db = (sqlite3 *)hb_parptr(1);
  const char *sql = hb_parc(2);
  char *zErrMsg = 0;
  PHB_ITEM pArray = hb_itemNew(NULL);
  int rc;

  hb_arrayNew(pArray, 0);

  if (!db) {
    hb_itemRelease(pArray);
    hb_ret();
    return;
  }

  rc = sqlite3_exec(db, sql, callback_array, (void *)pArray, &zErrMsg);

  if (rc != SQLITE_OK) {
    sqlite3_free(zErrMsg);
    hb_itemRelease(pArray);
    hb_ret();
  } else {
    hb_itemReturnRelease(pArray);
  }
}

HB_FUNC(SQLITE_LASTINSERTROWID) {
  sqlite3 *db = (sqlite3 *)hb_parptr(1);
  if (db)
    hb_retnll(sqlite3_last_insert_rowid(db));
  else
    hb_retnll(0);
}

HB_FUNC(SQLITE_COLUMN_NAMES) {
  sqlite3 *db = (sqlite3 *)hb_parptr(1);
  const char *sql = hb_parc(2);
  sqlite3_stmt *stmt;

  if (db && sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
    int i, count = sqlite3_column_count(stmt);
    PHB_ITEM pArray = hb_itemNew(NULL);
    hb_arrayNew(pArray, count);
    for (i = 0; i < count; i++) {
      hb_arraySetC(pArray, i + 1, sqlite3_column_name(stmt, i));
    }
    sqlite3_finalize(stmt);
    hb_itemReturnRelease(pArray);
  } else {
    hb_ret();
  }
}
