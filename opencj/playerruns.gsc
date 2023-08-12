#include openCJ\util;

// Event handlers

onInit()
{
    // Useful for a variety of purposes such as run label cleaning
    level.basicAllowedCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -_,.<>?/!@#*()[]{}|";
}

onPlayerConnect()
{
	self.playerRuns_spawnLinker = spawn("script_origin", (0, 0, 0));
    self.playerRuns_runPaused = false;
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
    if(!self hasRunID())
    {
        return;
    }
    if(self openCJ\cheating::isCheating())
    {
        return;
    }

    self.playerRuns_runFinished = true;
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

onSpawnPlayer()
{
    if (self hasRunID())
    {
        if(!self hasRunStarted())
        {
            self.playerRuns_spawnLinker.origin = self.origin;
            self linkTo(self.playerRuns_spawnLinker);
        }
        else if (!self isRunPaused())
        {
            self openCJ\playTime::startTimer();
        }
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

pauseRun()
{
    if (self hasRunID())
    {
        self.playerRuns_runPaused = true;
        self openCJ\events\onRunPaused::main();
        self iPrintLnBold("Run paused. Load back to resume.");
    }
}

resumeRun()
{
    if (self hasRunID())
    {
        self.playerRuns_runPaused = false;
        self.playerRuns_runStarted = true;
        self openCJ\playTime::startTimer();
        self openCJ\events\onRunResumed::main();
        self iPrintLnBold("Run resumed");
    }
}

stopRun(shouldReset)
{
    // Resetting a run will stop the current run, create a new run and respawn the player
    // When stopping a run normally (such as saving it), 

    if(self openCJ\demos::isPlayingDemo())
    {
        self sendLocalChatMessage("Cannot stop run during demo playback", true);
        return;
    }

    if (shouldReset)
    {
        self unlink();

        // Archive the current run
        runID = self getRunID();
        archiveRun(self, runID);

        // Create a new run
        self _createRunID();
    }
    else if (self hasRunID())
    {
        self unlink();

        // Player is no longer in a run
        _clearRunVars();

        // Inform other scripts that the current run stopped
        self openCJ\events\onRunStopped::main();
    }
    else
    {
        self sendLocalChatMessage("Not in a run, can't stop", true);
    }
}

saveRun(runLabel)
{
    if (!self openCJ\playerRuns::hasRunID())
    {
        self sendLocalChatMessage("You're not currently in a run", true);
        return;
    }
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

    maxRunLabelSize = 32;
    if (runLabel.size > maxRunLabelSize)
    {
        self sendLocalChatMessage("Run label can be up to 32 characters", true);
        return;
    }

    // Clean the run label, escape it for database and limit it to 32 chars. escapeString might make it slightly larger, so db allows 64.
    cleanedRunLabel = openCJ\mySQL::escapeString(cleanCharacters(runLabel, level.basicAllowedCharacters, maxRunLabelSize));
    mapId = self openCJ\mapID::getMapID();
    runID = self getRunID();
    runInstanceNumber = self getRunInstanceNumber();

    query = "SELECT saveRun(" + runID + ", " + runInstanceNumber + ", " + dbStr(cleanedRunLabel) + ")";
    printf("DEBUG: executing saveRun query:\n" + query + "\n");

    rows = self openCJ\mySQL::mysqlAsyncQuery(query);
    if (isDefined(rows) && isDefined(rows[0]) && isDefined(rows[0][0]) && (int(rows[0][0]) == runID))
    {
        // Successfully saved
        if (cleanedRunLabel != runLabel)
        {
            self sendLocalChatMessage("Run saved successfully, but some characters were replaced");
        }
        else
        {
            self sendLocalChatMessage("Run saved successfully");
        }

        // Stop the run but don't archive and don't start a new run
        stopRun(false);
    }
    else
    {
        self sendLocalChatMessage("Run could not be saved", true);
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

    self unlink();

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

    self.playerRuns_runStarted = true;
    self.playerRuns_runFinished = false;
    self openCJ\events\onRunRestored::main();
    self iprintln("^2Restored run (" + runID + ")"); // TAS users depend on this message, do not modify
    self sendLocalChatMessage("Restored run. Be careful: using !rp again will delete this run!");
}

_clearRunVars()
{
    // Clear run variables
    self.playerRuns_runStarted = false;
    self.playerRuns_runPaused = false;
    self.playerRuns_runID = undefined;
    self.runInstanceNumber = undefined;
}

startRun()
{
    if(self isPlayerReady(false) && self hasRunID() && (self.sessionState == "playing") && !self hasRunStarted())
    {
        self.playerRuns_runStarted = true;
        self.playerRuns_runPaused = false;
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
	return (self hasRunID() && isDefined(self.playerRuns_runFinished) && self.playerRuns_runFinished);
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

    // Clear run variables
    _clearRunVars();
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

isRunPaused()
{
    return self.playerRuns_runPaused;
}