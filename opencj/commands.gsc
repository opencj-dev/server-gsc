#include openCJ\util;

onInit()
{
	cmd = openCJ\commands_base::registerCommand("kick", "Kick a specific player. Usage: !kick <playerName|playerId> [reason]", ::_onCommandKick, 1, 2, 0); // TODO: correct admin level value
	cmd = openCJ\commands_base::registerCommand("ban", "Ban a specific player. Usage: !ban <playerName|playerId> [reason]", ::_onCommandBan, 1, 2, 0); // TODO: correct admin level value

	cmd = openCJ\commands_base::registerCommand("ip", "Shows you your own ip using getip() function", ::_onCommandShowIP, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "showip");

	cmd = openCJ\commands_base::registerCommand("resetrun", "Resets your current run.", ::_onCommandResetRun, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "reset");

	cmd = openCJ\commands_base::registerCommand("toggletarget", "Toggles a reference target.", ::_onCommandToggleTarget, 0, 0, 0);
	openCJ\commands_base::addAlias(cmd, "target");
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

_onCommandResetRun(args)
{
	self sendLocalChatMessage("Your run has been reset.");
	self openCJ\playerRuns::resetRunId();
}
