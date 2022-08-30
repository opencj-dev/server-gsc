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
		specs[i] _hideStatisticsHud(false);
	}
}

onPlayerConnect()
{
	self _hideStatisticsHud(true);
	self.isAFK = true;
}

onSpectatorClientChanged(newClient)
{
	if(!isDefined(newClient) || newClient openCJ\demos::isPlayingDemo())
	{
		self _hideStatisticsHud(false);
	}
	else
	{
		self _drawStatisticsHUD(newClient);
	}
}

isAFK()
{
	return self.isAFK;
}

setAFK(value)
{
	self.isAFK = value;
	if(value)
	{
		self openCJ\statistics::pauseTimer();
	}
	else
	{
		self.statistics_AFKTimer = getTime() + 5000;
		self.statistics_AFKOrigin = self.origin;
		if(self openCJ\playerRuns::hasRunStarted())
			self openCJ\statistics::startTimer();
	}
}

whileAlive()
{
	if(self isOnGround())
	{
		self.statistics_lastJump = undefined;
	}

	if(self.statistics_AFKOrigin != self.origin)
	{
		self setAFK(false);
	}
	else if(self.statistics_AFKTimer < getTime())
	{
		self setAFK(true);
	}

	// Draw statistics HUD for ourselves
	self _drawStatisticsHud(self);
	
	specs = self getSpectatorList(false);
	for(i = 0; i < specs.size; i++)
	{
		specs[i] _drawStatisticsHud(self);
	}
}

resetAFKOrigin()
{
	self.statistics_lastJump = undefined;
	self setAFK(false);
}

onRunFinished(cp)
{
	self pauseTimer();
}

onRunIDCreated()
{
	self.statistics_startTime = getTime();
	self.statistics_stopTime = getTime();

	self.statistics_saveCount = 0;
	self.statistics_loadCount = 0;
	self.statistics_nadeJumps = 0;
	self.statistics_nadeThrows = 0;
	self.statistics_jumpCount = 0;
	self.statistics_RPGJumps = 0;
	self.statistics_RPGShots = 0;
	self.statistics_doubleRPGs = 0;

	self.statistics_lastRPG = undefined;
	self.statistics_lastJump = undefined;
	self setAFK(true);
}

addTimeUntil(newtime)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	if(!isDefined(newtime))
		return;

	if(!self openCJ\playerRuns::hasRunStarted())
		return;

	if(!isDefined(self.statistics_addTimeUntil) && newtime > getTime())
	{
		self.statistics_startTime -= newtime - getTime();
		self.statistics_addTimeUntil = newtime;
	}
	else if(isDefined(self.statistics_addTimeUntil) && newtime > self.statistics_addTimeUntil)
	{
		self.statistics_startTime -= newtime - self.statistics_addTimeUntil;
		self.statistics_addTimeUntil = newtime;
	}

	self thread _resetAddTimeUntil();
}

_resetAddTimeUntil()
{
	self endon("disconnect");
	self notify("resetAddTimeUntil");
	self endon("resetAddTimeUntil");
	waittillframeend;
	self.statistics_addTimeUntil = undefined;
}

onSavePosition()
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	self.statistics_saveCount++;
}

onLoadPosition()
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	self.statistics_loadCount++;
}

onPlayerDamage(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	if(self openCJ\weapons::isGrenade(weapon) && !self isOnGround())
	{
		self.statistics_nadeJumps++;
	}
}

onGrenadeThrow(nade, name)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	self.statistics_nadeThrows++;
}

onJump()
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	self.statistics_jumpCount++;
	self.statistics_lastJump = getTime();
}

onRPGFired(rpg, name)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	self.statistics_RPGShots++;

	if(!self isOnGround())
	{
		if(isDefined(self.statistics_lastJump) && isDefined(self.statistics_lastRPG) && self.statistics_lastRPG >= self.statistics_lastJump)
		{
			self.statistics_doubleRPGs++;
			self iprintln("Double rpg detected");
		}
		self.statistics_RPGJumps++;
		self.statistics_lastRPG = getTime();
	}
}

setTimePlayed(value)
{
	if(isDefined(self.statistics_stopTime))
		self.statistics_startTime = self.statistics_stopTime - value;
	else
		self.statistics_startTime = getTime() - value;
}

getFrameNumber()
{
	return self getTimePlayed() / 50;
}

getTimePlayed()
{
	if(isDefined(self.statistics_stopTime))
		return (self.statistics_stopTime - self.statistics_startTime);
	else
		return (getTime() - self.statistics_startTime);
}

getJumpCount()
{
	return self.statistics_jumpCount;
}

setLoadCount(value)
{
	self.statistics_loadCount = value;
}

getLoadCount()
{
	return self.statistics_loadCount;
}

setSaveCount(value)
{
	self.statistics_saveCount = value;
}

getSaveCount()
{
	return self.statistics_saveCount;
}

setRPGJumps(amount)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	self.statistics_RPGJumps = amount;
}

setNadeJumps(amount)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	self.statistics_nadeJumps = amount;
}

setDoubleRPGs(amount)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	self.statistics_doubleRPGs = amount;
}

getRPGJumps()
{
	return self.statistics_RPGJumps;
}

getRPGShots()
{
	return self.statistics_RPGShots;
}

setRPGShots(value)
{
	self.statistics_RPGShots = value;
}

getNadeJumps()
{
	return self.statistics_nadeJumps;
}

setNadeThrows(value)
{
	self.statistics_nadeThrows = value;
}

getNadeThrows()
{
	return self.statistics_nadeThrows;
}

getDoubleRPGs()
{
	return self.statistics_doubleRPGs;
}

_hideStatisticsHud(force)
{
	if(force || self.statistics_lastStatHudString != "")
	{
		self.statistics_lastStatHudString = "";
		self setClientCvar("openCJ_statistics", "");
	}
}

_drawStatisticsHud(client)
{
	newstring = self openCJ\settings::getSetting("timestring") + " " + formatTimeString(client getTimePlayed(), true) + "\n";

	newstring += self openCJ\settings::getSetting("savesstring") + " " + client getSaveCount() + "\n";
	newstring += self openCJ\settings::getSetting("loadsstring") + " " + client getLoadCount() + "\n";
	if (getCvarInt("codversion") == 2)
	{
		newstring += self openCJ\settings::getSetting("jumpsstring") + " " + client getJumpCount() + "\n";
		newstring += self openCJ\settings::getSetting("nadejumpsstring") + " " + client getNadeJumps() + "\n";
		newstring += self openCJ\settings::getSetting("nadethrowsstring") + " " + client getNadeThrows() + "\n";
	}
	else
	{
		newstring += self openCJ\settings::getSetting("rpgjumpsstring") + " " + client getRPGJumps() + "\n";
		newstring += self openCJ\settings::getSetting("rpgshotsstring") + " " + client getRPGShots() + "\n";
		newstring += self openCJ\settings::getSetting("doublerpgsstring") + " " + client getDoubleRPGs() + "\n";
	}
	if(client openCJ\fps::hasUsedHaxFPS())
		newstring += self openCJ\settings::getSetting("fpshaxstring");
	else if(client openCJ\fps::hasUsedMixFPS())
		newstring += self openCJ\settings::getSetting("fpsmixstring");
	else
		newstring += self openCJ\settings::getSetting("fpspurestring");
	newstring += client openCJ\fps::getCurrentFPS() + "\n";
	
	route = openCJ\checkpoints::getEnderName(client openCJ\checkpoints::getCheckpoint());
	if(isDefined(route))
	{
		newstring += "Route: " + route + "\n";
	}

	if(self.statistics_lastStatHudString != newstring)
	{
		self setClientCvar("openCJ_statistics", newstring);
		self.statistics_lastStatHudString = newstring;
	}
}

onSpawnSpectator()
{
	self _hideStatisticsHud(false);
}

startTimer()
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	if(isDefined(self.statistics_stopTime))
	{
		self.statistics_startTime += getTime() - self.statistics_stopTime;
		self.statistics_stopTime = undefined;
	}
}

pauseTimer()
{
	if(!isDefined(self.statistics_stopTime))
	{
		self.statistics_stopTime = getTime();
	}
}