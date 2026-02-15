#xcommand MYSQL CONNECT <cDb> [ HOST <cHost> ] [ USER <cUser> ] [ PASSWORD <cPass> ] [ PORT <nPort> ] [ INTO <oDb> ] => ;
    <oDb> := TMySQL():New( <cHost>, <cUser>, <cPass>, <cDb>, <nPort> )

#xcommand MYSQL USE <cTable> [ IN <oDb> ] [ ORDER <cOrder> ] => ;
    <oDb>:TableUse( <cTable> ) [; <oDb>:OrdSetFocus( <cOrder> ) ]

#xcommand MYSQL QUERY <cSql> [ IN <oDb> ] => ;
    <oDb>:Query( <cSql> )

#xcommand MYSQL SELECT <cTable> [ IN <oDb> ] => ;
    <oDb>:TableUse( <cTable> )

#xcommand MYSQL INSERT <cTable> [ IN <oDb> ] HASH <hData> => ;
    <oDb>:Insert( <cTable>, <hData> )

#xcommand MYSQL REPLACE <cField> WITH <uVal> [ IN <oDb> ] => ;
    <oDb>:FieldPutName( <cField>, <uVal> )

#xcommand MYSQL APPEND [ IN <oDb> ] => ;
    <oDb>:DbAppend()

#xcommand MYSQL DELETE [ IN <oDb> ] => ;
    <oDb>:DelRecord()

#xcommand MYSQL CREATE TABLE <cTable> FROM <aStruct> [ IN <oDb> ] => ;
    <oDb>:CreateTable( <(cTable)>, <aStruct> )

#xcommand MYSQL CLOSE [ <oDb> ] => ;
    <oDb>:End(); <oDb>:= nil
