#include openCJ\util;

onInit()
{
	underlyingCmd = openCJ\settings::addSettingString("timestring", 1, 20, "Time:", "Set the time string used in the statistics hud\nUsage: !timestring [newstring]");
	underlyingCmd = openCJ\settings::addSettingString("savesstring", 1, 20, "Saves:", "Set the saves string used in the statistics hud\nUsage: !savesstring [newstring]");
	underlyingCmd = openCJ\settings::addSettingString("loadsstring", 1, 20, "Loads:", "Set the loads string used in the statistics hud\nUsage: !loadsstring [newstring]");
	underlyingCmd = openCJ\settings::addSettingString("jumpsstring", 1, 20, "Jumps:", "Set the jumps string used in the statistics hud\nUsage: !jumpsstring [newstring]");
	underlyingCmd = openCJ\settings::addSettingString("fpshaxstring", 1, 20, "FPS[H]:", "Set the hax fps string used in the statistics hud\nUsage: !fpshaxstring [newstring]");
	underlyingCmd = openCJ\settings::addSettingString("fpsmixstring", 1, 20, "FPS[M]:", "Set the mix fps string used in the statistics hud\nUsage: !fpsmixstring [newstring]");
	underlyingCmd = openCJ\settings::addSettingString("fpspurestring", 1, 20, "FPS:", "Set the pure fps string used in the statistics hud\nUsage: !fpspurestring [newstring]");
	if (getCvarInt("codversion") == 2)
	{
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

onStartDemo()
{
	specs = self getSpectatorList(true);
	for(i = 0; i < specs.size; i++)
	{
		specs[i] _clearStatisticsHud(false);
	}
}

onPlayerConnect()
{
	self.statistics = [];
	self.statistics["curr"] = [];
	self.statistics["prev"] = [];

	self _clearStatisticsHud(true);
}

onSpawnSpectator()
{
	self _clearStatisticsHud(false);
}

onSpectatorClientChanged(newClient)
{
	if(!isDefined(newClient) || newClient openCJ\demos::isPlayingDemo())
	{
		self _clearStatisticsHud(false);
	}
	else
	{
		self _drawStatisticsHUD(newClient);
	}
}

onRunIDCreated()
{
	self.statistics["curr"]["secondsPlayed"] = 0;
	self.statistics["curr"]["saveCount"] = 0;
	self.statistics["curr"]["loadCount"] = 0;
	self.statistics["curr"]["nadeJumps"] = 0;
	self.statistics["curr"]["nadeThrows"] = 0;
	self.statistics["curr"]["jumpCount"] = 0;
	self.statistics["curr"]["RPGJumps"] = 0;
	self.statistics["curr"]["RPGShots"] = 0;
	self.statistics["curr"]["doubleRPGs"] = 0;
	self.statistics["curr"]["lastRPGFiredTime"] = undefined;
	self.statistics["curr"]["lastJumpTime"] = undefined;

	_updateStatistics();
}

whileAlive()
{
	if(self isOnGround())
	{
		self.statistics["curr"]["lastJumpTime"] = undefined;
	}

	self.statistics["curr"]["secondsPlayed"] = self openCJ\playTime::getSecondsPlayed();

	self.statistics["curr"]["fps"] = openCJ\fps::getCurrentFPS();
	if (self openCJ\fps::hasUsedHaxFPS())
	{
		self.statistics["curr"]["fpsMode"] = "hax";
	}
	else if(self openCJ\fps::hasUsedMixFPS())
	{
		self.statistics["curr"]["fpsMode"] = "mix";
	}
	else
	{
		self.statistics["curr"]["fpsMode"] = "125";
	}

	// Draw statistics HUD for ourselves
	self _drawStatisticsHud(self);
	
	// And for our spectator friends
	specs = self getSpectatorList(false);
	for(i = 0; i < specs.size; i++)
	{
		specs[i] _drawStatisticsHud(self);
	}
}

_haveStatisticsChanged()
{
	keys = getArrayKeys(self.statistics["curr"]);
	for(i = 0; i < keys.size; i++)
	{
		if(!isDefined(self.statistics["prev"][keys[i]]) || (self.statistics["curr"][keys[i]] != self.statistics["prev"][keys[i]]))
		{
			return true;
		}
	}
	
	return false;
}

_updateStatistics()
{
	keys = getArrayKeys(self.statistics["curr"]);
	for(i = 0; i < keys.size; i++)
	{
		self.statistics["prev"][keys[i]] = self.statistics["curr"][keys[i]];
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

_drawStatisticsHud(client)
{
	// client -> the owner of the statistics
	// self -> to whom the statistics are being displayed

	if(!client _haveStatisticsChanged())
	{
		return;
	}

	newstring = self openCJ\settings::getSetting("timestring") + " " + formatTimeString(client openCJ\playTime::getTimePlayed(), true) + "\n";
	newstring += self openCJ\settings::getSetting("savesstring") + " " + client.statistics["curr"]["saveCount"] + "\n";
	newstring += self openCJ\settings::getSetting("loadsstring") + " " + client.statistics["curr"]["loadCount"] + "\n";
	if (getCvarInt("codversion") == 2)
	{
		newstring += self openCJ\settings::getSetting("jumpsstring") + " " + client.statistics["curr"]["jumpCount"] + "\n";
		newstring += self openCJ\settings::getSetting("nadejumpsstring") + " " + client.statistics["curr"]["nadeJumps"] + "\n";
		newstring += self openCJ\settings::getSetting("nadethrowsstring") + " " + client.statistics["curr"]["nadeThrows"] + "\n";
	}
	else
	{
		newstring += self openCJ\settings::getSetting("rpgjumpsstring") + " " + client.statistics["curr"]["RPGJumps"] + "\n";
		newstring += self openCJ\settings::getSetting("rpgshotsstring") + " " + client.statistics["curr"]["RPGShots"] + "\n";
		newstring += self openCJ\settings::getSetting("doublerpgsstring") + " " + client.statistics["curr"]["doubleRPGs"] + "\n";
	}
	if(client openCJ\fps::hasUsedHaxFPS())
	{
		newstring += self openCJ\settings::getSetting("fpshaxstring");
	}
	else if(client openCJ\fps::hasUsedMixFPS())
	{
		newstring += self openCJ\settings::getSetting("fpsmixstring");
	}
	else
	{
		newstring += self openCJ\settings::getSetting("fpspurestring");
	}
	newstring += client.statistics["curr"]["fps"] + "\n";
	
	route = openCJ\checkpoints::getEnderName(client openCJ\checkpoints::getCheckpoint());
	if(isDefined(route))
	{
		newstring += "Route: " + route + "\n";
	}

	self setClientCvar("openCJ_statistics", newstring);
	self.statistics["lastString"] = newstring;
	client _updateStatistics();
}

increaseAndGetSaveCount()
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return -1;
	}

	self.statistics["curr"]["saveCount"]++;
	return self.statistics["curr"]["saveCount"];
}

onLoadPosition()
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	self.statistics["curr"]["loadCount"]++;
}

onPlayerDamage(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime)
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	if(self openCJ\weapons::isGrenade(weapon) && !self isOnGround())
	{
		self.statistics["curr"]["nadeJumps"]++;
	}
}

onGrenadeThrow(nade, name)
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	self.statistics["curr"]["nadeThrows"]++;
}

onJump()
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	self.statistics["curr"]["jumpCount"]++;
	self.statistics["curr"]["lastJumpTime"] = getTime();
}

onRPGFired(rpg, name)
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	// An RPG was fired
	self.statistics["curr"]["RPGShots"]++;

	if(!self isOnGround())
	{
		// Check if a second RPG was fired
		if(isDefined(self.statistics["curr"]["lastJumpTime"]) && isDefined(self.statistics["curr"]["lastRPGFiredTime"]) &&
			(self.statistics["curr"]["lastRPGFiredTime"] >= self.statistics["curr"]["lastJumpTime"]))
		{
			self.statistics["curr"]["doubleRPGs"]++;
			self iprintln("^1Double rpg detected");
		}

		// We aren't on ground, so this counts as an RPG jump
		self.statistics["curr"]["RPGJumps"]++;
		self.statistics["curr"]["lastRPGFiredTime"] = getTime();
	}
}

getJumpCount()
{
	return self.statistics["curr"]["jumpCount"];
}

setLoadCount(value)
{
	self.statistics["curr"]["loadCount"] = value;
}

getLoadCount()
{
	return self.statistics["curr"]["loadCount"];
}

setSaveCount(value)
{
	self.statistics["curr"]["saveCount"] = value;
}

getSaveCount()
{
	return self.statistics["curr"]["saveCount"];
}

setRPGJumps(amount)
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	self.statistics["curr"]["RPGJumps"] = amount;
}

setNadeJumps(amount)
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	self.statistics["curr"]["nadeJumps"] = amount;
}

setDoubleRPGs(amount)
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	self.statistics["curr"]["doubleRPGs"] = amount;
}

getRPGJumps()
{
	return self.statistics["curr"]["RPGJumps"];
}

getRPGShots()
{
	return self.statistics["curr"]["RPGShots"];
}

setRPGShots(value)
{
	self.statistics["curr"]["RPGShots"] = value;
}

getNadeJumps()
{
	return self.statistics["curr"]["nadeJumps"];
}

setNadeThrows(value)
{
	self.statistics["curr"]["nadeThrows"] = value;
}

getNadeThrows()
{
	return self.statistics["curr"]["nadeThrows"];
}

getDoubleRPGs()
{
	return self.statistics["curr"]["doubleRPGs"];
}
