#include <hbapi.h>
#include <hbapiitm.h>
#include <sqlite3.h>

// Handle SQLite database pointers as Generic Pointers
// sqlite3 * db

HB_FUNC(SQLITE_OPEN) {
  sqlite3 *db;
  const char *cFilename = hb_parc(1);

  if (sqlite3_open(cFilename, &db) == SQLITE_OK)
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
    // Store column name and value ?? Usually just value for simple datasets
    // Or simpler: Array of Rows. Each Row is Array of Values.

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
    // Could store zErrMsg somewhere if needed, but easier to use SQLITE_ERRMSG
    // later
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
    // Return empty array or nil? Let's return Nil on error so user can check
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
