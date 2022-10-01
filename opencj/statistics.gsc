#include openCJ\util;

// Event functions

onPlayerConnect()
{
	self.statistics = [];
	self.statistics["curr"] = [];
	self.statistics["prev"] = [];
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

	self updateStatistics();
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

// Logic functions

haveStatisticsChanged()
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

updateStatistics()
{
	keys = getArrayKeys(self.statistics["curr"]);
	for(i = 0; i < keys.size; i++)
	{
		self.statistics["prev"][keys[i]] = self.statistics["curr"][keys[i]];
	}
}

// Getters/setters

getFPSMode()
{
	return self.statistics["curr"]["fpsMode"];
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
