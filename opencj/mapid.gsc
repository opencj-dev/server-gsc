#include openCJ\util;

onInit()
{
    rows = openCJ\mySQL::mysqlSyncQuery("SELECT getMapID('" + openCJ\mySQL::escapeString(getCvar("mapname")) + "')");
    if(isDefined(rows) && isDefined(rows[0]) && isDefined(rows[0][0]))
    {
        level.mapid_mapID = int(rows[0][0]);
    }
}

hasMapID()
{
    return isDefined(level.mapid_mapID);
}

getMapID()
{
    return level.mapid_mapID;
}