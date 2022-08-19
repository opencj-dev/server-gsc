#include openCJ\util;

onInit()
{
    cmd = openCJ\commands_base::registerCommand("ignore", "Temporarily ignore a specific player. Usage: !ignore <playerName|playerId> [duration]", ::_onCommandIgnore, 1, 1, 0);
    openCJ\commands_base::addAlias(cmd, "tignore");
    cmd = openCJ\commands_base::registerCommand("pignore", "Permanently ignore a specific player. Usage: !pignore <playerName|playerId>", ::_onCommandPermIgnore, 1, 1, 0);
    openCJ\commands_base::addAlias(cmd, "pignore");
    
    cmd = openCJ\commands_base::registerCommand("mute", "Temporarily mute a player. Usage: !mute <playerName|playerId> [duration]", ::_onCommandMute, 1, 2, 50); // TODO: correct admin level value
    openCJ\commands_base::addAlias(cmd, "tmute");
    cmd = openCJ\commands_base::registerCommand("fmute", "Permanently mute a player. Usage: !pmute <playerName|playerId>", ::_onCommandPermMute, 1, 1, 70); // TODO: correct admin level
    openCJ\commands_base::addAlias(cmd, "pmute");

    cmd = openCJ\commands_base::registerCommand("kick", "Kick a specific player. Usage: !kick <playerName|playerId> [reason]", ::_onCommandKick, 1, 2, 50); // TODO: correct admin level value
    cmd = openCJ\commands_base::registerCommand("ban", "Ban a specific player. Usage: !ban <playerName|playerId> [reason]", ::_onCommandBan, 1, 2, 70); // TODO: correct admin level value

	cmd = openCJ\commands_base::registerCommand("ip", "Shows you your own ip using getip() function", ::_onCommandShowIP, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "showip");

	cmd = openCJ\commands_base::registerCommand("resetrun", "Resets your current run.", ::_onCommandResetRun, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "reset");
}

onPlayerConnect()
{
    self.adminLevel = 0; // Will be updated after login
}

onPlayerLogin()
{
    query = "SELECT adminLevel FROM playerInformation WHERE playerID = " + self openCJ\login::getPlayerID() + " LIMIT 3";
    //printf("executing query: " + query + "\n");

    rows = self openCJ\mySQL::mysqlAsyncQuery(query);
    if(isDefined(rows) && isDefined(rows[0]) && isDefined(rows[0][0]) && isValidInt(rows[0][0]))
    {
        self.adminLevel = int(rows[0][0]);
    }
    else
    {
        printf("Failed to get adminLevel for " + self.name + "\n");
    }
}

_onCommandIgnore(args)
{
    self sendLocalChatMessage("Not implemented yet", true); // TODO: implement
}

_onCommandPermIgnore(args)
{
    self sendLocalChatMessage("Not implemented yet", true); // TODO: implement
}

_onCommandMute(args)
{
    self sendLocalChatMessage("Not implemented yet", true); // TODO: implement
}

_onCommandPermMute(args)
{
    self sendLocalChatMessage("Not implemented yet", true); // TODO: implement
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

_onCommandResetRun(args)
{
    self sendLocalChatMessage("Your run has been reset.");
    self openCJ\playerRuns::resetRunId();
}
