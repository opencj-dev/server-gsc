#include openCJ\util;

onPlayerConnect()
{
	self.playerRuns_spawnLinker = spawn("script_origin", (0, 0, 0));
}

hasJumpSlowdown()
{
	return getCodVersion() == 2; //placeholder
}

onPlayerLogin()
{
	self thread _createRunID();
}

onStartDemo()
{
	if(!self.playerRuns_runStarted)
	{
		self unlink();
	}
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
	if(self openCJ\demos::isPlayingDemo())
	{
		self iprintlnbold("Cannot reset run during demo playback");
		return;
	}
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
	if(self isRunFinished())
	{
		return;
	}
	self.playerRuns_runFinished = true;
	if(!self hasRunID())
	{
		return;
	}
	if(self openCJ\cheating::isCheating())
	{
		return;
	}

    cpID = openCJ\checkpoints::getCheckpointID(cp);
    if (!isDefined(cpID))
    {
        return;
    }

	if (self hasRunID())
	{
		runID = self getRunID();
		rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT runFinished(" + runID + ", " + cpID + ", " + self getRunInstanceNumber() + ")");
		if(!isDefined(rows[0][0]))
		{
			self iPrintLnBold("This run was loaded by another instance of your account. Please reset. All progress will not be saved");
		}
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
	{
		return;
	}

	self endon("disconnect");

	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT createRunID(" + self openCJ\login::getPlayerID() + ", " + openCJ\mapID::getMapID() + ")");

	if(!rows.size || !isDefined(rows[0][0]))
	{
		self iprintlnbold("Could not create runID. Please reconnect");
	}
	else
	{
		self.playerRuns_runID = int(rows[0][0]);

		self iprintln("Created new run with ID: " + self.playerRuns_runID);

		rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT createRunInstance(" + self.playerRuns_runID + ")");
		if(rows.size && isDefined(rows[0][0]))
		{
			self.runInstanceNumber = int(rows[0][0]);
			self openCJ\events\runIDCreated::main();
		}
		else
		{
			self iprintlnbold("Could not set run instance number. Please reconnect");
		}
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

restoreRun(runID)
{
    self.playerRuns_runStarted = true;
    self.playerRuns_runFinished = false;
    self.playerRuns_runID = runID;

    self openCJ\events\runIDRestored::main();
    self openCJ\historySave::historyLoad(runID);
    if(self openCJ\savePosition::canLoadError(0) == 0)
    {
        self thread openCJ\events\loadPosition::main(0);
    }

    self iprintln("^2Restored ^7run with ID " + runID);
}

onSpawnPlayer()
{
	if(!self.playerRuns_runStarted)
	{
		self.playerRuns_spawnLinker.origin = self.origin;
		self linkTo(self.playerRuns_spawnLinker);
	}
	else
	{
		self openCJ\playTime::startTimer();
	}
}

onSpawnSpectator()
{
	self openCJ\playTime::pauseTimer();
}

startRun()
{
	if(self openCJ\login::isLoggedIn() && self hasRunID() && self.sessionState == "playing" && !self.playerRuns_runStarted)
	{
		self.playerRuns_runStarted = true;
		self unLink();
        self openCJ\events\onRunStarted::main();
	}
}