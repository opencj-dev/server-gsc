#include openCJ\util;

onPlayerConnect()
{
	self openCJ\events\WASDPressed::disableWASDCallback();
	self.playerRuns_spawnLinker = spawn("script_origin", (0, 0, 0));
}

onPlayerLogin()
{
	self thread _createRunID();
}

hasRunID()
{
	return isDefined(self.playerRuns_runID) && isDefined(self.runInstanceNumber);
}

getRunID()
{
	return self.playerRuns_runID;
}

getRunInstanceNumber()
{
	return self.runInstanceNumber;
}

resetRunID()
{
	if(!self hasRunID())
	{
		self iprintlnbold("Cannot reset run right now");
		return;
	}
	else
	{
		self.playerRuns_runID = undefined;
		self.runInstanceNumber = undefined;
		self thread _createRunID();
	}
}

printRunIDandInstanceNumber()
{
	self iprintln("runid: " + self.playerRuns_runID);
	self iprintln("runinstance: " + self.runInstanceNumber);
}

onRunFinished(cp)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;
	self.playerRuns_runFinished = true;
	if(!self openCJ\playerRuns::hasRunID())
		return;
	if(self openCJ\cheating::isCheating())
		return;
	if(self openCJ\playerRuns::hasRunID() && self openCJ\checkpoints::checkpointHasID(cp))
	{
		runID = self openCJ\playerRuns::getRunID();
		cpID = self openCJ\checkpoints::getCheckpointID(cp);
		rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT runFinished(" + runID + ", " + cpID + ", " + self getRunInstanceNumber() + ")");
		if(!isDefined(rows[0][0]))
			self iPrintLnBold("This run was loaded by another instance of your account. Please reset. All progress will not be saved");
	}
}

isRunFinished()
{
	return (self hasRunID() && self.playerRuns_runFinished);
}

setRunIDAndInstanceNumber(runID, instanceNumber)
{
	self.playerRuns_runID = runID;
	self.runInstanceNumber = instanceNumber;
}

_createRunID()
{
	if(!self openCJ\login::IsLoggedIn())
		return;

	self endon("disconnect");

	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT createRunID(" + self openCJ\login::getPlayerID() + ", " + openCJ\mapID::getMapID() + ")");

	if(!rows.size || !isDefined(rows[0][0]))
	{
		self iprintlnbold("Could not create runID. Please reconnect");
	}
	else
	{
		self.playerRuns_runID = rows[0][0];
		printf("Adding run instance number++\n\n\n");
		rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT createRunInstance(" + self.playerRuns_runID + ")");
		if(rows.size && isDefined(rows[0][0]))
		{
			self.runInstanceNumber = rows[0][0];
			self openCJ\events\runIDCreated::main();
		}
		else
			self iprintlnbold("Could not set run instance number. Please reconnect");
	}
}

hasRunStarted()
{
	return (isDefined(self.playerRuns_runStarted) && self.playerRuns_runStarted);
}

onRunIDCreated()
{
	self.playerRuns_runStarted = false;
	self.playerRuns_runFinished = false;
}

onSpawnPlayer()
{
	if(!self.playerRuns_runStarted)
	{
		printf("linking to spawn\n");
		self.playerRuns_spawnLinker.origin = self.origin;
		self linkTo(self.playerRuns_spawnLinker);
		self openCJ\events\WASDPressed::enableWASDCallback();
	}
	else
		self openCJ\statistics::startTimer();
}

onSpawnSpectator()
{
	self openCJ\events\WASDPressed::disableWASDCallback();
	self openCJ\statistics::pauseTimer();
}

startRun()
{
	self openCJ\events\WASDPressed::disableWASDCallback();
	if(self openCJ\login::isLoggedIn() && self openCJ\playerRuns::hasRunID() && self.sessionState == "playing" && !self.playerRuns_runStarted)
	{
		printf("unlinking from spawn\n");
		self.playerRuns_runStarted = true;
		self unLink();
		self openCJ\statistics::startTimer();
	}
}