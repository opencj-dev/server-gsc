#include openCJ\util;

onInit()
{
	rows = openCJ\mySQL::mysqlSyncQuery("SELECT getMapID('" + openCJ\mySQL::escapeString(getCvar("mapname")) + "')");
	if(rows.size && isDefined(rows[0][0]))
		level.mapid_mapID = rows[0][0];
}

hasMapID()
{
	return isDefined(level.mapid_mapID);
}

getMapID()
{
	return level.mapid_mapID;
}