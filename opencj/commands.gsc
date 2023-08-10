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

    cmd = openCJ\commands_base::registerCommand("restoreposition", "Restore your last used run", ::_onCmdRestorePosition, 0, 0, 0);
    openCJ\commands_base::addAlias(cmd, "restorerun");
    openCJ\commands_base::addAlias(cmd, "rp");
    openCJ\commands_base::addAlias(cmd, "historyload");

    cmd = openCJ\commands_base::registerCommand("runs", "List your runs or load a specific run. Usage: !runs [runID]", ::_onCmdRuns, 0, 1, 0);
    openCJ\commands_base::addAlias(cmd, "historyloads");

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
	self thread openCJ\playerRuns::resetRun();
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

_restoreLastRun()
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
    runID = undefined;
    if (self openCJ\playerRuns::hasRunID())
    {
        runID = self openCJ\playerRuns::getRunID();
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
        if (restoredRunID != runID)
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
        if (args.size > 1)
        {
            idx = int(args[1]);
            if (entArray.size > idx)
            {
                self setOrigin(entArray[idx].origin);
                self sendLocalChatMessage("Teleported you to entity: " + args[0] + "[" + idx + "]");
            }
            else
            {
                self sendLocalChatMessage("Index of " + args[0] + " only goes to " + (entArray.size - 1), true);
            }
        }
        else
        {
            self setOrigin(entArray[0].origin);
            self sendLocalChatMessage("Teleported you to entity: " + args[0] + "[" + 0 + "]");
        }
    }
}

_onCmdSetOrigin(args)
{
    self setOrigin((int(args[0]), int(args[1]), int(args[2])));
}
