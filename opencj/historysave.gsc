#include openCJ\util;

onInit()
{
	cmd = openCJ\commands_base::registerCommand("runs", "Display all runs or load a previously saved run from your history\nUsage: !runs [runid]", ::historyLoad, 0, 1, 0);
	openCJ\commands_base::addAlias(cmd, "historyload");
}

historyLoad(args) // TODO: support self-named runs
{
	if (args.size == 0)
	{
		self sendLocalChatMessage("Showing runs list is not implemented yet"); // TODO: support list of existing runs
	}
	else
	{
		if (isValidInt(args[0]))
		{
			runID = int(args[0]);
			if(self openCJ\login::isLoggedIn())
			{
				self thread _historyLoad(runID);
			}
		}
	}
}

_historyLoad(runID)
{
	self endon("disconnect");
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT historyLoad(" + openCJ\mapID::getMapID() + ", " + self openCJ\login::getPlayerID() + ", " + runID + ")");
	if(isDefined(rows[0][0]))
	{
		instanceNumber = int(rows[0][0]);
		saves = self _loadSavesFromDatabase(runID, instanceNumber);
	}
	else
	{
		self iprintlnbold("^1Failed loading history save for run: " + runID);
	}
}

_loadSavesFromDatabase(runID, instanceNumber)
{
	self endon("disconnect");
	rowsRun = self openCJ\mySQL::mysqlAsyncQuery("SELECT timePlayed, saveCount, loadCount, RPGShots, nadeThrows FROM playerRuns WHERE runID = " + runID);
	rowsSaves = self openCJ\mySQL::mysqlAsyncQuery("SELECT x, y, z, alpha, beta, gamma, RPGJumps, nadeJumps, doubleRPGs, checkpointID, flags, entTargetName, numOfEnt FROM playerSaves WHERE runID = " + runID + " ORDER BY saveNumber DESC LIMIT 5");
	self openCJ\playerRuns::setRunIDAndInstanceNumber(runID, instanceNumber);
	self openCJ\events\runIDCreated::main();
	self openCJ\playerRuns::startRun();
	self openCJ\statistics::setTimePlayed(int(rowsRun[0][0]));
	self openCJ\statistics::setSaveCount(int(rowsRun[0][1]));
	self openCJ\statistics::setLoadCount(int(rowsRun[0][2]));
	self openCJ\statistics::setRPGShots(int(rowsRun[0][3]));
	self openCJ\statistics::setNadeThrows(int(rowsRun[0][4]));
	self openCJ\healthRegen::resetHealthRegen();
	self openCJ\shellShock::resetShellShock();
	self openCJ\checkpointPointers::showCheckpointPointers();
	
	for(i = rowsSaves.size - 1; i >= 0; i--)
	{
		
		entNum = _getEntNum(rowsSaves[i][11], intOrUndefined(rowsSaves[i][12]));
		checkpointID = intOrUndefined(rowsSaves[i][9]);
		self savePosition_save((int(rowsSaves[i][0]), int(rowsSaves[i][1]), int(rowsSaves[i][2])), (int(rowsSaves[i][3]), int(rowsSaves[i][4]), int(rowsSaves[i][5])), entNum, int(rowsSaves[i][6]), int(rowsSaves[i][7]), int(rowsSaves[i][8]), checkpointID, int(rowsSaves[i][10]));
	}
	self openCJ\playerRuns::printRunIDandInstanceNumber();
}

_getEntNum(targetName, numOfEnt)
{
	if(!isDefined(targetName))
		return undefined;
	ents = getEntArray(targetName, "targetname");
	if(isDefined(ents) && isDefined(ents[numOfEnt]))
		return ents[numOfEnt] getEntityNumber();
	return undefined;
}

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
