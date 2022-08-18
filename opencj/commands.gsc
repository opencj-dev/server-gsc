#include openCJ\util;

onInit()
{
    cmd = openCJ\commands_base::registerCommand("ignore", "Ignore a specific player. Usage: !ignore <playerName|playerId>", ::_onCommandIgnore, 1, 1, 0);
    cmd = openCJ\commands_base::registerCommand("mute", "Mute a specific player. Usage: !mute <playerName|playerId>", ::_onCommandMute, 1, 1, 50); // TODO: correct admin level value
    cmd = openCJ\commands_base::registerCommand("kick", "Kick a specific player. Usage: !kick <playerName|playerId> [reason]", ::_onCommandKick, 1, 2, 50); // TODO: correct admin level value
    cmd = openCJ\commands_base::registerCommand("ban", "Ban a specific player. Usage: !ban <playerName|playerId> [reason]", ::_onCommandBan, 1, 2, 60); // TODO: correct admin level value

	cmd = openCJ\commands_base::registerCommand("ip", "Shows you your own ip using getip() function", ::_onCommandShowIP, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "showip");

	cmd = openCJ\commands_base::registerCommand("resetrun", "Resets your current run.", ::_onCommandResetRun, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "reset");
}

_onCommandIgnore(args)
{
    self sendLocalChatMessage("Not implemented yet", true); // TODO: implement
}

_onCommandMute(args)
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
    self openCJ\playerRuns::resetRunId();
}
