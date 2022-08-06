#include openCJ\util;

onPlayerConnect()
{
	self openCJ\events\WASDPressed::disableWASDCallback();
	self.playerRuns_spawnLinker = spawn("script_origin", (0, 0, 0));
}

onPlayerLogin()
{
	self thread _createRunID(false);
}

hasRunID()
{
	return isDefined(self.playerRuns_runID);
}

getRunID()
{
	return self.playerRuns_runID;
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
		self thread _createRunID(true);
	}
}

onRunFinished(cp)
{
	self.playerRuns_runFinished = true;
	if(self openCJ\playerRuns::hasRunID() && self openCJ\checkpoints::checkpointHasID(cp))
	{
		runID = self openCJ\playerRuns::getRunID();
		cpID = self openCJ\checkpoints::getCheckpointID(cp);
		self thread openCJ\mySQL::mysqlAsyncQueryNosave("CALL runFinished(" + runID + ", " + cpID + ")");
	}
}

isRunFinished()
{
	return (self hasRunID() && self.playerRuns_runFinished);
}

_createRunID(spawn)
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
		self openCJ\events\runIDCreated::main(spawn);
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

onWASDPressed()
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