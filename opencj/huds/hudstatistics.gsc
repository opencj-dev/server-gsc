#include openCJ\util;

onInit()
{
    if (getCodVersion() == 2)
    {
        underlyingCmd = openCJ\settings::addSettingString("timestring", 1, 20, "Time:", "Set the time string used in the statistics hud. Usage: !timestring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("savesstring", 1, 20, "Saves:", "Set the saves string used in the statistics hud. Usage: !savesstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("loadsstring", 1, 20, "Loads:", "Set the loads string used in the statistics hud. Usage: !loadsstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("jumpsstring", 1, 20, "Jumps:", "Set the jumps string used in the statistics hud. Usage: !jumpsstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("fpshaxstring", 1, 20, "FPS[H]:", "Set the hax fps string used in the statistics hud. Usage: !fpshaxstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("fpsmixstring", 1, 20, "FPS[M]:", "Set the mix fps string used in the statistics hud. Usage: !fpsmixstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("fpspurestring", 1, 20, "FPS:", "Set the pure fps string used in the statistics hud. Usage: !fpspurestring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("nadejumpsstring", 1, 20, "Nadejumps:", "Set the nadejumps string used in the statistics hud. Usage: !nadejumpsstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("nadethrowsstring", 1, 20, "Nadethrows:", "Set the nadethrows string used in the statistics hud. Usage: !nadethrowsstring [newstring]");
    }
    else
    {
        underlyingCmd = openCJ\settings::addSettingString("rpgjumpsstring", 1, 20, "RPG Jumps:", "Set the RPGJumps string used in the statistics hud. Usage: !rpgjumpsstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("rpgshotsstring", 1, 20, "RPG Shots:", "Set the RPGShots string used in the statistics hud. Usage: !rpgshotsstring [newstring]");
        underlyingCmd = openCJ\settings::addSettingString("doublerpgsstring", 1, 20, "Double RPGs:", "Set the double RPGs string used in the statistics hud. Usage: !doublerpgsstring [newstring]");
    }
}

onPlayerConnected()
{
    self.statisticsHudString = "";
    self _hideStatisticsHud(true);
}

onSpawnSpectator()
{
    self _hideStatisticsHud(false); // Statistics HUD will be shown when spectating a person
}

onSpectatorClientChanged(newClient)
{
    if (!isDefined(newClient))
    {
        self _hideStatisticsHud(false);
    }
    else
    {
        self _updateStatisticsHud(newClient, undefined); // undefined -> let the function determine the update string
    }
}

onStartDemo()
{
    specs = self getSpectatorList(true); // true -> includes the player that is the spectator
    for(i = 0; i < specs.size; i++)
    {
        specs[i] _hideStatisticsHud(false);
    }
}

onRunStopped()
{
    specs = self getSpectatorList(true); // true -> includes the player that is the spectator
    for(i = 0; i < specs.size; i++)
    {
        specs[i] _hideStatisticsHud(false);
    }
}

onRunCreated()
{
    specs = self getSpectatorList(true); // true -> includes the player that is the spectator
    for(i = 0; i < specs.size; i++)
    {
        specs[i] _hideStatisticsHud(false);
    }
}

whileAlive()
{
    // self = owner of statistics

    if (!self openCJ\playerRuns::hasRunID() || !self openCJ\playerRuns::hasRunStarted())
    {
        return;
    }

    if (!self openCJ\statistics::haveStatisticsChanged())
    {
        return;
    }

    self _updateForSpectators(); // Will mark the statistics as no longer changed
}

_updateForSpectators() // Function to avoid getting the string multiple times if it remains the same
{
    newString = self _getStatisticsString();
    specs = self getSpectatorList(true); // true -> includes the player that is the spectator
    for(i = 0; i < specs.size; i++)
    {
        specs[i] _updateStatisticsHud(self, newString);
    }
}

_updateStatisticsHud(playerBeingWatched, newString)
{
    // Only update if the player being watched should have their statistics up
    if (!playerBeingWatched openCJ\playerRuns::hasRunID() || !playerBeingWatched openCJ\playerRuns::hasRunStarted())
    {
        self _hideStatisticsHud(false);
        return;
    }

    // It gets provided when doing an update for all spectators at once. Otherwise it is determined here
    if (!isDefined(newString))
    {
        newString = playerBeingWatched _getStatisticsString();
    }

    self setClientCvar("openCJ_statistics", newString);
    self.statisticsHudString = newString;

    // Statistics should no longer be marked changed now, because we displayed the most recent change
    self openCJ\statistics::setHasUpdatedStatistics();
}

_hideStatisticsHud(force)
{
    if(force || (self.statisticsHudString != ""))
    {
        self.statisticsHudString = "";
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

_getStatisticsString()
{
    // Time
    newstring = _getStringOrDefault("timestring") + " " + formatTimeString(self openCJ\playTime::getTimePlayed(), true) + "\n";

    // Loads
    newstring += _getStringOrDefault("loadsstring") + " " + self openCJ\statistics::getLoadCount() + "\n";

    // CoD specific (nade jumps / rpg)
    if (getCodVersion() == 2)
    {
        // Also only show jumps and saves on CoD2 as this is irrelevant for CoD4
        newstring += _getStringOrDefault("savesstring") + " " + self openCJ\statistics::getSaveCount() + "\n";
        newstring += _getStringOrDefault("jumpsstring") + " " + self openCJ\statistics::getJumpCount() + "\n";
        newstring += _getStringOrDefault("nadejumpsstring") + " " + self openCJ\statistics::getExplosiveJumps() + "\n";
        newstring += _getStringOrDefault("nadethrowsstring") + " " + self openCJ\statistics::getExplosiveLaunches() + "\n";
    }
    else
    {
        newstring += _getStringOrDefault("rpgjumpsstring") + " " + self openCJ\statistics::getExplosiveJumps() + "\n";
        // TMI
        //newstring += _getStringOrDefault("rpgshotsstring") + " " + self openCJ\statistics::getExplosiveLaunches() + "\n";
        //newstring += _getStringOrDefault("doublerpgsstring") + " " + self openCJ\statistics::getDoubleExplosives() + "\n";
    }

    // FPS is already covered by runInfo icons

    // Routes & progress
    newstring += self openCJ\statistics::getRouteAndProgress() + "\n";

    return newstring;
}
