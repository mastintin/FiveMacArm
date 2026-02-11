// sqlite.ch - SQLite commands for FiveMac
// (c) FiveTech Software 2026

#ifndef _SQLITE_CH
#define _SQLITE_CH

#xcommand SQLITE CONNECT <cDb> [ <lCreate: CREATE> ] [ INTO <oDb> ] => ;
    [ <oDb> := ] If( <.lCreate.>, TSQLite():SqliteCreateDb( <cDb> ), TSQLite():SqliteUse( <cDb> ) )

#xcommand SQLITE USE <cTable> [ IN <oDb> ] [ ORDER <cOrder> ] => ;
    <oDb>:TableUse( <cTable> ) [; <oDb>:OrdSetFocus( <cOrder> ) ]

#xcommand SQLITE APPEND [ IN <oDb> ] => <oDb>:DbAppend()

#xcommand SQLITE REPLACE <cField> WITH <uVal> [ IN <oDb> ] => <oDb>:FieldPutName( <cField>, <uVal> )

#xcommand SQLITE DELETE [ IN <oDb> ] => <oDb>:DelRecord()

#xcommand SQLITE INSERT INTO <cTable> HASH <hData> [ IN <oDb> ] => <oDb>:Insert( <cTable>, <hData> )

#xcommand SQLITE CREATE TABLE <cTable> FIELDS <aFields> [ IN <oDb> ] => <oDb>:CreateTable( <cTable>, <aFields> )

#xcommand SQLITE DROP TABLE <cTable> [ IN <oDb> ] => <oDb>:DelTable( <cTable> )

#xcommand SQLITE CLOSE [ <oDb> ] => <oDb>:End()

#endif
