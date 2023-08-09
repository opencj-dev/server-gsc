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

_onCommandResetRun(args)
{
	self sendLocalChatMessage("Your run has been reset.");
	self openCJ\playerRuns::resetRunId();
}

_onCmdSetOrigin(args)
{
    self setOrigin((int(args[0]), int(args[1]), int(args[2])));
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
                self sendLocalChatMessage("Index of " + args[0] + " only goes to " + (entArray.size - 1));
            }
        }
        else
        {
            self setOrigin(entArray[0].origin);
            self sendLocalChatMessage("Teleported you to entity: " + args[0] + "[" + 0 + "]");
        }
    }
}
