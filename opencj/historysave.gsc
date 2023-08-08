#include openCJ\util;

onInit()
{
	cmd = openCJ\commands_base::registerCommand("runs", "Display all runs or load a previously saved run from your history\nUsage: !runs [runid]", ::historyLoadCmd, 0, 1, 0);
	openCJ\commands_base::addAlias(cmd, "historyload");
}

historyLoadCmd(args) // TODO: support self-named runs
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
                self thread historyLoad(runID);
            }
        }
    }
}

historyLoad(runID)
{
	self endon("disconnect");
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT historyLoad(" + openCJ\mapID::getMapID() + ", " + self openCJ\login::getPlayerID() + ", " + runID + ")");
	if(isDefined(rows[0][0]))
	{
		instanceNumber = int(rows[0][0]);
        self savePosition_initClient();
	    self openCJ\savePosition::resetBackwardsCount();
		self _loadSavesFromDatabase(runID, instanceNumber);
	}
	else
	{
		self iprintlnbold("^1Failed loading history save for run: " + runID);
	}
}

_loadSavesFromDatabase(runID, instanceNumber)
{
	self endon("disconnect");
    query1 = "SELECT timePlayed, saveCount, loadCount, explosiveLaunches FROM playerRuns WHERE runID = " + runID;
    printf("DEBUG: executing historyLoad query1:\n" + query1 + "\n");
    rowsRun = self openCJ\mySQL::mysqlAsyncQuery(query1);

    query2 = "SELECT x, y, z, alpha, beta, gamma, explosiveJumps, doubleExplosives, checkpointID, FPSMode, flags, entTargetName, numOfEnt FROM playerSaves WHERE runID = " + runID + " ORDER BY saveNumber DESC LIMIT 50";
    printf("DEBUG: executing historyLoad query2:\n" + query2 + "\n");
    rowsSaves = self openCJ\mySQL::mysqlAsyncQuery(query2);

	self openCJ\playerRuns::setRunIDAndInstanceNumber(runID, instanceNumber);
	self openCJ\playerRuns::startRun();
	self openCJ\playtime::setTimePlayed(int(rowsRun[0][0]));
	self openCJ\statistics::setSaveCount(int(rowsRun[0][1]));
	self openCJ\statistics::setLoadCount(int(rowsRun[0][2]));
	self openCJ\statistics::setExplosiveLaunches(int(rowsRun[0][3])); // TODO: tbh should not be overall count, but instead bound per save

	self openCJ\healthRegen::resetHealthRegen();
	self openCJ\shellShock::resetShellShock();
	self openCJ\checkpointPointers::showCheckpointPointers();

	//add flags and fps
	for(i = rowsSaves.size - 1; i >= 0; i--)
	{
        numOfThisSave = int(rowsRun[0][1]) - i;
        org = (int(rowsSaves[i][0]), int(rowsSaves[i][1]), int(rowsSaves[i][2]));
        angles = (int(rowsSaves[i][3]), int(rowsSaves[i][4]), int(rowsSaves[i][5]));
        explosiveJumps = int(rowsSaves[i][6]);
        doubleExplosives = int(rowsSaves[i][7]);
		checkpointID = intOrUndefined(rowsSaves[i][8]);
        fpsMode = openCJ\fps::FPSModeToInt(rowsSaves[i][9]);
        flags = int(rowsSaves[i][10]);
        entNum = _getEntNum(rowsSaves[i][11], intOrUndefined(rowsSaves[i][12]));
        printf("DEBUG: saving position " + i + " with rpgjumps: " + explosiveJumps + "\n");
		self savePosition_save(org, angles, entNum, explosiveJumps, doubleExplosives, checkpointID, FPSMode, flags, numOfThisSave);
	}

	self openCJ\playerRuns::printRunIDandInstanceNumber();
}

_getEntNum(targetName, numOfEnt)
{
	if(!isDefined(targetName))
	{
		return undefined;
	}
	ents = getEntArray(targetName, "targetname");
	if(isDefined(ents) && isDefined(ents[numOfEnt]))
	{
		return ents[numOfEnt] getEntityNumber();
	}
	return undefined;
}

saveToDatabase(origin, angles, entTargetName, numOfEnt, explosiveJumps, doubleExplosives, checkpointID, FPSMode, flags)
{
	self endon("disconnect");

    if(self openCJ\demos::isPlayingDemo())
    {
        return;
    }
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}
	if(!self openCJ\playerRuns::hasRunID())
	{
		return;
	}
	if(self openCJ\cheating::isCheating())
	{
		return;
	}

	runID = self openCJ\playerRuns::getRunID();
	timePlayed = self openCJ\playTime::getTimePlayed();
	saveCount = self openCJ\statistics::getSaveCount();
	loadCount = self openCJ\statistics::getLoadCount();
	explosiveLaunches = self openCJ\statistics::getExplosiveLaunches();

	runInstance = self openCJ\playerRuns::getRunInstanceNumber();
	if(!isDefined(entTargetName))
	{
		entTargetName = "NULL";
	}
	else
	{
		entTargetName = "'" + openCJ\mySQL::escapeString(entTargetName) + "'";
	}
	if(!isDefined(numOfEnt))
	{
		numOfEnt = "NULL";
	}
	if(!isDefined(checkpointID))
	{
		checkpointID = "NULL";
	}
	x = int(origin[0]);
	y = int(origin[1]);
	z = int(origin[2]) + 1;
	alpha = int(angles[0]);
	beta = int(angles[1]);
	gamma = int(angles[2]);
    FPSMode = "'" + FPSMode + "'";

    query = "SELECT savePosition(" + runID + ", " + runInstance + ", " + x + ", " + y + ", " + z + ", " + alpha + ", " + beta + ", " + gamma + ", " + timePlayed + ", " + saveCount + ", " + loadCount + ", " + explosiveLaunches + ", " + explosiveJumps + ", " + doubleExplosives + ", " + checkpointID + ", " + FPSMode + ", " + flags + ", " + entTargetName + ", " + numOfEnt + ")";
	printf("savePosition query:\n" + query + "\n"); // Debug
    
    rows = openCJ\mySQL::mysqlAsyncQuery(query);
	if(!isDefined(rows[0][0]))
	{
		//run has been loaded by another instance
		self iPrintLnBold("This run was loaded by another instance of your account. Please reset. All progress will not be saved");
	}
}
