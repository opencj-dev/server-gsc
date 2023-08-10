#include openCJ\util;

// Event handlers

onPlayerConnect()
{
	self.playerRuns_spawnLinker = spawn("script_origin", (0, 0, 0));
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

onRunCreated()
{
    self.playerRuns_runStarted = false;
    self.playerRuns_runFinished = false;
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

// Other functions

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

resetRun()
{
    if(self openCJ\demos::isPlayingDemo())
    {
        self sendLocalChatMessage("Cannot reset run during demo playback", true);
        return;
    }
    if(!self hasRunID())
    {
        self sendLocalChatMessage("Not in a run, can't reset", true);
        return;
    }
    else
    {
        // Archive the current run
        runID = self getRunID();
        archiveRun(self, runID);

        // Create a new run
        self.playerRuns_runID = undefined;
        self.runInstanceNumber = undefined;
        self _createRunID();
    }
}

archiveRun(player, runID)
{
    if (isDefined(runID))
    {
        playerIDSqlStr = " ";
        if (isDefined(player))
        {
            playerIDSqlStr += "AND playerID = " + player openCJ\login::getPlayerID() + " ";
        }
        query = "UPDATE playerRuns SET archived = True" + 
                " WHERE runID = " + runID +
                playerIDSqlStr;
        printf("DEBUG: executing archiveRun query:\n" + query + "\n");

        level thread openCJ\mySQL::mysqlAsyncQueryNosave(query);
        if (isDefined(player))
        {
            player iprintln("^5Archived ^7run (" + runID + ")");
        }
    }
}

restoreRun(runID) // Call this function as a thread
{
    if (!self openCJ\mapID::hasMapID())
    {
        self sendLocalChatMessage("Sorry, the current map is not in the database", true);
        return;
    }

    if (!self isPlayerReady(false))
    {
        self sendLocalChatMessage("You're not logged in or settings haven't loaded yet", true);
        return;
    }

    if (self openCJ\demos::isPlayingDemo())
    {
        self sendLocalChatMessage("Can't access runs while watching a demo", true);
        return;
    }

    // Check if this is the player's run
    query = "SELECT runID FROM playerRuns WHERE playerID = " + self openCJ\login::getPlayerID() + " AND runID = " + runID;
    rows = self openCJ\mySQL::mysqlAsyncQuery(query);
    if (!isDefined(rows) || !isDefined(rows[0]) || !isDefined(rows[0][0]))
    {
        self sendLocalChatMessage("Run " + runID + " was not found for your playerID");
        return;
    }

    // First archive the user's current run, since it's typically a newly created run that will remain unused and clutter up the runs menu
    if (self hasRunID())
    {
        currentRunID = self getRunID();
        archiveRun(self, currentRunID);
    }

    self openCJ\historySave::historyLoad(runID); // Sets runID and runInstanceNumber
    if(self openCJ\savePosition::canLoadError(0) == 0)
    {
        self thread openCJ\events\loadPosition::main(0);
    }
    else
    {
        self iprintlnbold("Run has no save. Starting at spawn.");
        self openCJ\checkpoints::setCurrentCheckpointID(level.checkpoints_startCheckpoint.id); // To update checkpoint pointers since player can't load
    }

    self openCJ\events\onRunRestored::main();
    self iprintln("^2Restored run (" + runID + ")"); // TAS users depend on this message, do not modify
}

startRun()
{
    if(self isPlayerReady(false) && self hasRunID() && (self.sessionState == "playing") && !self hasRunStarted())
    {
        self.playerRuns_runStarted = true;
        self unLink();
        self openCJ\events\onRunStarted::main();
        self iprintln("Run started");
    }
}

hasJumpSlowdown()
{
    return getCodVersion() == 2; //placeholder
}

printRunIDandInstanceNumber()
{
	self iprintln("runid: " + self.playerRuns_runID);
	self iprintln("runinstance: " + self.runInstanceNumber);
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

		self iprintln("^5Created ^7new run (" + self.playerRuns_runID + ")");

		rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT createRunInstance(" + self.playerRuns_runID + ")");
		if(rows.size && isDefined(rows[0][0]))
		{
			self.runInstanceNumber = int(rows[0][0]);
			self openCJ\events\onRunCreated::main();
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