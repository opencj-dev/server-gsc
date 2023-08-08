#include openCJ\util;

onInit()
{
	if (getCodVersion() == 2)
	{
        underlyingCmd = openCJ\settings::addSettingString("timestring", 1, 20, "Time:", "Set the time string used in the statistics hud\nUsage: !timestring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("savesstring", 1, 20, "Saves:", "Set the saves string used in the statistics hud\nUsage: !savesstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("loadsstring", 1, 20, "Loads:", "Set the loads string used in the statistics hud\nUsage: !loadsstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("jumpsstring", 1, 20, "Jumps:", "Set the jumps string used in the statistics hud\nUsage: !jumpsstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("fpshaxstring", 1, 20, "FPS[H]:", "Set the hax fps string used in the statistics hud\nUsage: !fpshaxstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("fpsmixstring", 1, 20, "FPS[M]:", "Set the mix fps string used in the statistics hud\nUsage: !fpsmixstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("fpspurestring", 1, 20, "FPS:", "Set the pure fps string used in the statistics hud\nUsage: !fpspurestring [newstring]");
		underlyingCmd = openCJ\settings::addSettingString("nadejumpsstring", 1, 20, "Nadejumps:", "Set the nadejumps string used in the statistics hud\nUsage: !nadejumpsstring [newstring]");
		underlyingCmd = openCJ\settings::addSettingString("nadethrowsstring", 1, 20, "Nadethrows:", "Set the nadethrows string used in the statistics hud\nUsage: !nadethrowsstring [newstring]");
	}
	else
	{
		underlyingCmd = openCJ\settings::addSettingString("rpgjumpsstring", 1, 20, "RPG Jumps:", "Set the RPGJumps string used in the statistics hud\nUsage: !rpgjumpsstring [newstring]");
		underlyingCmd = openCJ\settings::addSettingString("rpgshotsstring", 1, 20, "RPG Shots:", "Set the RPGShots string used in the statistics hud\nUsage: !rpgshotsstring [newstring]");
		underlyingCmd = openCJ\settings::addSettingString("doublerpgsstring", 1, 20, "Double RPGs:", "Set the double RPGs string used in the statistics hud\nUsage: !doublerpgsstring [newstring]");
	}
}

onPlayerConnect()
{
	self _hideStatisticsHud(true);
}

onSpawnSpectator()
{
	self _hideStatisticsHud(false);
}

onSpectatorClientChanged(newClient)
{
	if(!isDefined(newClient))
	{
		self _hideStatisticsHud(false);
	}
}

onStartDemo()
{
	specs = self getSpectatorList(true);
	for(i = 0; i < specs.size; i++)
	{
		specs[i] _clearStatisticsHud(false);
	}
}

whileAlive()
{
	// Draw statistics HUD for the player and their spectator(s)
	self _drawHUD();
}

_drawHUD()
{
	// self = owner of statistics

	// TODO: this causes up to 1 second delay before statistics are updated for spectators
	if(!self openCJ\statistics::haveStatisticsChanged())
	{
		return;
	}

	// The following is done for the owner of statistics and everyone spectating them
	playersToUpdateHUDFor = self getSpectatorList(true); // true -> include owner of statistics
	for(i = 0; i < playersToUpdateHUDFor.size; i++)
	{
		// Determine the new HUD string
		newString = playersToUpdateHUDFor[i] _getHUDString(self);

		// Update the HUD
		playersToUpdateHUDFor[i] setClientCvar("openCJ_statistics", newstring);

		// Remember string for change tracking and clearing
		playersToUpdateHUDFor[i].statistics["lastString"] = newString;
	}

	// Statistics should no longer be marked changed now, because we displayed the most recent changed
	self openCJ\statistics::updateStatistics();
}

_hideStatisticsHud(force)
{
	if(force || self.statistics["lastString"] != "")
	{
		self.statistics["lastString"] = "";
		self setClientCvar("openCJ_statistics", "");
	}
}

_clearStatisticsHud(force)
{
	if(force || (self.statistics["lastString"] != ""))
	{
		self.statistics["lastString"] = "";
		self setClientCvar("openCJ_statistics", "");
	}
}

_getStringOrDefault(name)
{
    str = self openCJ\settings::getSetting(name);
    if (!isDefined(str))
    {
        switch (name)
        {
            case "timestring": return "Time:";
            case "savesstring": return "Saves:";
            case "loadsstring": return "Loads:";
            case "jumpsstring": return "Jumps:";
            case "nadejumpsstring": return "Nadejumps:";
            case "nadethrowsstring": return "Nadethrows:";
            case "rpgjumpsstring": return "RPG Jumps:";
            case "rpgshotsstring": return "RPG Shots:";
            case "doublerpgsstring": return "Double RPGs:";
            case "fpshaxstring": return "FPS[H]:";
            case "fpsmixstring": return "FPS[M]:";
            case "fpspurestring": return "FPS:";
        }
    }

    return str;
}

_getHUDString(client)
{
    // Time
    newstring = _getStringOrDefault("timestring") + " " + formatTimeString(client openCJ\playTime::getTimePlayed(), true) + "\n";

    // Loads
    newstring += _getStringOrDefault("loadsstring") + " " + client openCJ\statistics::getLoadCount() + "\n";

    // CoD specific (nade jumps / rpg)
    if (getCodVersion() == 2)
    {
        // Also only show jumps and saves on CoD2 as this is irrelevant for CoD4
        newstring += _getStringOrDefault("savesstring") + " " + client openCJ\statistics::getSaveCount() + "\n";
        newstring += _getStringOrDefault("jumpsstring") + " " + client openCJ\statistics::getJumpCount() + "\n";
        newstring += _getStringOrDefault("nadejumpsstring") + " " + client openCJ\statistics::getExplosiveJumps() + "\n";
        newstring += _getStringOrDefault("nadethrowsstring") + " " + client openCJ\statistics::getExplosiveLaunches() + "\n";
    }
    else
    {
        newstring += _getStringOrDefault("rpgjumpsstring") + " " + client openCJ\statistics::getExplosiveJumps() + "\n";
        // TMI
        //newstring += _getStringOrDefault("rpgshotsstring") + " " + client openCJ\statistics::getExplosiveLaunches() + "\n";
        //newstring += _getStringOrDefault("doublerpgsstring") + " " + client openCJ\statistics::getDoubleExplosives() + "\n";
    }

    // FPS is already covered by runInfo icons

    // Routes & progress
    newstring += client openCJ\statistics::getRouteAndProgress() + "\n";

    return newstring;
}
