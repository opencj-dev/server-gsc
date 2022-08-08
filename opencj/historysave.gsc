#include openCJ\util;

saveToDatabase(origin, angles, entTargetName, numOfEnt, RPGJumps, nadeJumps, doubleRPGs, checkpointID, flags)
{
	self endon("disconnect");
	if(self openCJ\playerRuns::isRunFinished())
		return;
	if(!self openCJ\playerRuns::hasRunID())
		return;
	if(self openCJ\cheating::isCheating())
		return;

	runID = self openCJ\playerRuns::getRunID();
	timePlayed = self openCJ\statistics::getTimePlayed();
	saveCount = self openCJ\statistics::getSaveCount();
	loadCount = self openCJ\statistics::getLoadCount();
	RPGShots = self openCJ\statistics::getRPGShots();
	nadeThrows = self openCJ\statistics::getNadeThrows();

	runInstance = self openCJ\playerRuns::getRunInstanceNumber();
	if(!isDefined(entTargetName))
		entTargetName = "NULL";
	else
		entTargetName = "'" + openCJ\mySQL::escapeString(entTargetName) + "'";
	if(!isDefined(numOfEnt))
		numOfEnt = "NULL";
	if(!isDefined(checkpointID))
		checkpointID = "NULL";
	x = int(origin[0]);
	y = int(origin[1]);
	z = int(origin[2]) + 1;
	alpha = int(angles[0]);
	beta = int(angles[1]);
	gamma = int(angles[2]);
	rows = openCJ\mySQL::mysqlAsyncQuery("SELECT savePosition(" + runID + ", " + runInstance + ", " + x + ", " + y + ", " + z + ", " + alpha + ", " + beta + ", " + gamma + ", " + timePlayed + ", " + saveCount + ", " + loadCount + ", " + RPGJumps + ", " + nadeJumps + ", " + doubleRPGs + ", " + RPGShots + ", " + nadeThrows + ", " + checkpointID + ", " + flags + ", " + entTargetName + ", " + numOfEnt + ")");
	if(!isDefined(rows[0][0]))
	{
		//run has been loaded by another instance
		self iPrintLnBold("This run was loaded by another instance of your account. Please reset. All progress will not be saved");
	}
}
