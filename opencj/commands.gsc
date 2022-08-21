#include openCJ\util;

onInit()
{
	cmd = openCJ\commands_base::registerCommand("ignore", "Temporarily ignore a specific player until map change. Usage: !ignore <playerName|playerId>", ::_onCommandIgnore, 1, 1, 0);
	openCJ\commands_base::addAlias(cmd, "tignore");
	cmd = openCJ\commands_base::registerCommand("pignore", "Permanently ignore a specific player. Usage: !pignore <playerName|playerId>", ::_onCommandPermIgnore, 1, 1, 0);
	openCJ\commands_base::addAlias(cmd, "pignore");

	cmd = openCJ\commands_base::registerCommand("unignore", "Unignore a player, regardless of whether the ignore was temporary or permanent. Usage: !unignore <playerName|playerId>", ::_onCommandUnIgnore, 1, 1, 0);
	openCJ\commands_base::addAlias(cmd, "tignore");
	
	cmd = openCJ\commands_base::registerCommand("mute", "Temporarily mute a player until map change. Usage: !mute <playerName|playerId>", ::_onCommandMute, 1, 2, 50); // TODO: correct admin level value
	openCJ\commands_base::addAlias(cmd, "tmute");
	cmd = openCJ\commands_base::registerCommand("fmute", "Mute a player for 2h. Usage: !pmute <playerName|playerId>", ::_onCommandPermMute, 1, 1, 70); // TODO: correct admin level
	openCJ\commands_base::addAlias(cmd, "pmute");

	cmd = openCJ\commands_base::registerCommand("kick", "Kick a specific player. Usage: !kick <playerName|playerId> [reason]", ::_onCommandKick, 1, 2, 50); // TODO: correct admin level value
	cmd = openCJ\commands_base::registerCommand("ban", "Ban a specific player. Usage: !ban <playerName|playerId> [reason]", ::_onCommandBan, 1, 2, 70); // TODO: correct admin level value

	cmd = openCJ\commands_base::registerCommand("ip", "Shows you your own ip using getip() function", ::_onCommandShowIP, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "showip");

	cmd = openCJ\commands_base::registerCommand("resetrun", "Resets your current run.", ::_onCommandResetRun, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "reset");
}

_onCommandIgnore(args)
{
	// !ignore <playerName>
	player = findPlayerByArg(args[0]);
	if(!isDefined(player))
	{
		self sendLocalChatMessage("Player " + args[0] + " not found", true);
		return;
	}
	
	if(player == self)
	{
		self sendLocalChatMessage("Cannot ignore self", true);
		return;
	}
	if(self openCJ\chat::isIgnoring(player))
	{
		self sendLocalChatMessage("Already ignoring " + player.name, true);
		return;
	}
	self openCJ\chat::addToIgnoreList(player openCJ\login::getPlayerID());
	self sendLocalChatMessage("Ignoring " + player.name, false);
}

_onCommandPermIgnore(args)
{
	// !pignore <playerName>
	player = findPlayerByArg(args[0]);
	if(!isDefined(player))
	{
		self sendLocalChatMessage("Player " + args[0] + " not found", true);
		return;
	}
	
	if(player == self)
	{
		self sendLocalChatMessage("Cannot ignore self", true);
		return;
	}
	ignoreID = player openCJ\login::getPlayerID();
	if(!self openCJ\chat::isIgnoring(player))
	{
		self openCJ\chat::addToIgnoreList(ignoreID);
	}
	self sendLocalChatMessage("Permanently ignoring " + player.name, false);
	self thread openCJ\mySQL::mysqlAsyncQueryNosave("INSERT IGNORE INTO playerIgnore (playerID, ignoreID) VALUES (" + self openCJ\login::getPlayerID() + ", " + ignoreID + ")");
}

_onCommandUnIgnore(args)
{
	// !pignore <playerName>
	player = findPlayerByArg(args[0]);
	if(!isDefined(player))
	{
		self sendLocalChatMessage("Player " + args[0] + " not found", true);
		return;
	}
	
	if(player == self)
	{
		self sendLocalChatMessage("Cannot unignore self", true);
		return;
	}
	ignoreID = player openCJ\login::getPlayerID();
	if(self openCJ\chat::isIgnoring(player))
	{
		self openCJ\chat::removeFromIgnoreList(ignoreID);
		self sendLocalChatMessage("Unignoring " + player.name, false);
		self thread openCJ\mySQL::mysqlAsyncQueryNosave("DELETE FROM playerIgnore WHERE playerID = " + self openCJ\login::getPlayerID() + " AND ignoreID = " + ignoreID);
	}
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
