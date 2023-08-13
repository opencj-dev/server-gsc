#include openCJ\util;

onInit()
{
	cmd = openCJ\commands_base::registerCommand("kick", "Kick a specific player. Usage: !kick <playerName|playerId> [reason]", ::_onCommandKick, 1, 2, 50); // TODO: correct admin level value
	cmd = openCJ\commands_base::registerCommand("ban", "Ban a specific player. Usage: !ban <playerName|playerId> [reason]", ::_onCommandBan, 1, 2, 70); // TODO: correct admin level value

	cmd = openCJ\commands_base::registerCommand("ip", "Shows you your own ip using getip() function", ::_onCommandShowIP, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "showip");

	cmd = openCJ\commands_base::registerCommand("resetrun", "Resets your current run.", ::_onCommandResetRun, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "reset");

	cmd = openCJ\commands_base::registerCommand("toggletarget", "Toggles a reference target.", ::_onCommandToggleTarget, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "target");

    cmd = openCJ\commands_base::registerCommand("playerid", "View your playerID", ::_onCmdPID, 0, 0, 0);
    openCJ\commands_base::addAlias(cmd, "pid");

    cmd = openCJ\commands_base::registerCommand("saverun", "Save your current run. Usage: !saverun [label]", ::_onCmdSaveRun, 0, 1, 0);
    cmd = openCJ\commands_base::registerCommand("pauserun", "Pause your current run", ::_onCmdPauseRun, 0, 0, 0);
    openCJ\commands_base::addAlias(cmd, "p");
    cmd = openCJ\commands_base::registerCommand("resumerun", "Resume your current run", ::_onCmdResumeRun, 0, 0, 0);
    openCJ\commands_base::addAlias(cmd, "r");

    cmd = openCJ\commands_base::registerCommand("restoreposition", "Restore your last used run", ::_onCmdRestorePosition, 0, 0, 0);
    openCJ\commands_base::addAlias(cmd, "restorerun");
    openCJ\commands_base::addAlias(cmd, "rp");
    openCJ\commands_base::addAlias(cmd, "historyload");

    cmd = openCJ\commands_base::registerCommand("runs", "List your runs or load a specific run. Usage: !runs [runID]", ::_onCmdRuns, 0, 1, 0);
    openCJ\commands_base::addAlias(cmd, "historyloads");

    cmd = openCJ\commands_base::registerCommand("ts", "Teleport to a specific player's save", ::_onCmdTeleSave, 1, 1, 0);
    cmd = openCJ\commands_base::registerCommand("tp", "Teleport to a specific player's position", ::_onCmdTelePos, 1, 1, 0);

    // Useful admin commands for debugging maps
    cmd = openCJ\commands_base::registerCommand("ent", "Teleport to an entity", ::_onCmdEntTele, 1, 2, 90);
    cmd = openCJ\commands_base::registerCommand("setorigin", "Teleport to a position", ::_onCmdSetOrigin, 3, 3, 90);
}

onPlayerDisconnect()
{
    if (isDefined(self.targetRef))
    {
        self.targetRef delete();
    }
}

_onCommandToggleTarget(args)
{
	if (isDefined(self.targetRef)) 
	{
		self.targetRef delete();
		self iPrintLn("^3[Target beta] Removed target");
	} 
	else 
	{
		targetRef = spawn("script_model", self getOrigin());
		targetRef setModel("body_mp_usmc_specops"); // @TODO: change to something simple
		targetRef hide();
		targetRef showToPlayer(self);
		self iPrintLn("^3[Target beta] Added target!");
		self.targetRef = targetRef;
	}
}

_onCommandKick(args)
{
	self sendLocalChatMessage("Not implemented yet", true); // TODO: implement
}

_onCommandBan(args)
{
	self sendLocalChatMessage("Not implemented yet", true); // TODO: implement
}

_onCommandShowIP(args)
{
	self sendLocalChatMessage("Your IP is: " + self getip());
}

_onCmdPID(args)
{
    if (self openCJ\login::isLoggedIn())
    {
        self sendLocalChatMessage("Your playerID is: " + self openCJ\login::getPlayerID());
    }
    else
    {
        self sendLocalChatMessage("^1You are not logged in");
    }
}

_onCommandResetRun(args)
{
	self thread openCJ\playerRuns::stopRun(true);
}

_onCmdSaveRun(args)
{
    runLabel = "";
    if (args.size > 0)
    {
        runLabel = args[0];
    }
    self thread openCJ\playerRuns::saveRun(runLabel);
}

_onCmdPauseRun(args)
{
    if (self openCJ\playerRuns::hasRunID())
    {
        self thread openCJ\cheating::setCheating(true);
    }
    else
    {
        self sendLocalChatMessage("You are not in a run", true);
    }
}

_onCmdResumeRun(args)
{
    failed = true;
    cheatingFlag = level.saveFlags[level.saveFlagName_cheating];
    backwardsCount = self savePosition_selectWithoutFlag(cheatingFlag);
    if (isDefined(backwardsCount)) // If not defined, could not be found
    {
        if (self openCJ\savePosition::canLoadError(backwardsCount) == 0)
        {
            self openCJ\events\eventHandler::onLoadPositionRequest(backwardsCount);
            failed = false;
        }
    }

    if (failed)
    {
        self sendLocalChatMessage("Could not find last safe position. Consider resetting your run.", true);
    }
}

_onCmdRestorePosition(args)
{
    self thread _restoreLastRun();
}

_onCmdRuns(args) // TODO: support self-named runs
{
    if (args.size == 0)
    {
        // TODO: allow viewing runs via chat too
        self sendLocalChatMessage("Use the runs menu to view your runs.");
    }
    else
    {
        if (isValidInt(args[0]))
        {
            runID = int(args[0]);
            self thread openCJ\playerRuns::restoreRun(runID);
        }
    }
}

_restoreLastRun(runID)
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

    mapId = self openCJ\mapID::getMapID();
    runSqlStr = " ";
    if (!isDefined(runID))
    {
        if (self openCJ\playerRuns::hasRunID())
        {
            runID = self openCJ\playerRuns::getRunID();
        }
    }

    if (isDefined(runID))
    {
        runSqlStr += "AND runID != " + runID + " ";
        hasRunID = true;
    }

    query = "SELECT runID FROM playerRuns " + 
            "WHERE playerID = " + self openCJ\login::getPlayerID() +
            " AND finishTimeStamp IS NULL AND mapID = " + mapId +
            runSqlStr +
            " AND archived = False" + 
            " ORDER BY lastUsedTimeStamp DESC, runID DESC LIMIT 1";
    printf("DEBUG: executing restore position query:\n" + query + "\n");

    rows = self openCJ\mySQL::mysqlAsyncQuery(query);
    if (isDefined(rows) && isDefined(rows[0]) && isDefined(rows[0][0]))
    {
        restoredRunID = int(rows[0][0]);
        if (!isDefined(runID) || (restoredRunID != runID))
        {
            self openCJ\playerRuns::restoreRun(restoredRunID);
            self sendLocalChatMessage("Restored your latest run");
        }
    }
    else
    {
        self sendLocalChatMessage("Failed to restore position, please use runs menu instead", true);
    }
}

// Useful commands for debugging maps

_onCmdEntTele(args)
{
    if (isDefined(args) && (args.size >= 1))
    {
        entArray = getEntArray(args[0], "targetname");
        sendError = false;
        if (isDefined(entArray) && (entArray.size > 0))
        {
            idx = 0;
            if (args.size > 1)
            {
                idx = int(args[1]);
            }

            if (entArray.size > idx)
            {
                self setOrigin(entArray[idx].origin);
                self openCJ\cheating::setCheating(true);
                self sendLocalChatMessage("Teleported you to entity: " + args[0] + "[" + idx + "]");
            }
            else
            {
                self sendLocalChatMessage("Index of " + args[0] + " only goes to " + (entArray.size - 1), true);
            }
        }
        else
        {
            self sendLocalChatMessage("Entity not found", true);
        }
    }
}

_onCmdSetOrigin(args)
{
    self setOrigin((int(args[0]), int(args[1]), int(args[2])));
}

_onCmdTeleSave(args)
{
    self _teleportToPlayer(args, true);
}

_onCmdTelePos(args)
{
    self _teleportToPlayer(args, false);
}

_teleportToPlayer(args, teleToSave)
{
    if (args.size == 1)
    {
        player = findPlayerByArg(args[0]);
        if (!isDefined(player))
        {
            self sendLocalChatMessage("Target player could not be found", true);
        }
        else if(player != self)
        {
            shouldTeleToPos = !teleToSave;
            if (teleToSave)
            {
                playerSave = player openCJ\savePosition::getSavedPosition(player openCJ\savePosition::getBackwardsCount());
                if (isDefined(playerSave))
                {
                    self openCJ\cheating::setCheating(true);
                    self sendLocalChatMessage("Teleported you to target player's save");

                    self setOrigin(playerSave.origin);
                    self setPlayerAngles(playerSave.angles);
                }
                else
                {
                    self openCJ\cheating::setCheating(true);
                    self sendLocalChatMessage("Target player save not available, teleporting to position", true);
                    shouldTeleToPos = true;
                }
            }
            
            if (shouldTeleToPos)
            {
                self setOrigin(player getOrigin());
                self setPlayerAngles(player getPlayerAngles());
            }
        }
        else
        {
            self sendLocalChatMessage("You're already at your own location..", true);
        }
    }
}
