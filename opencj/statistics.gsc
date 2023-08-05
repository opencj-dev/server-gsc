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
	self.statistics["curr"]["explosiveLaunches"] = 0;
	self.statistics["curr"]["explosiveJumps"] = 0;
    self.statistics["curr"]["doubleExplosives"] = 0;
	self.statistics["curr"]["jumpCount"] = 0;
	self.statistics["curr"]["lastExplosiveFiredTime"] = undefined;
	self.statistics["curr"]["lastJumpTime"] = undefined;
    self.statistics["curr"]["usedEle"] = false;
    self.statistics["curr"]["usedAnyPct"] = false;
    self.statistics["curr"]["usedTAS"] = false;

	self updateStatistics();
}

whileAlive()
{
	if(self isOnGround())
	{
		self.statistics["curr"]["lastJumpTime"] = undefined;
	}

    // Time
	self.statistics["curr"]["secondsPlayed"] = self openCJ\playTime::getSecondsPlayed();

    // FPS
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

    // Ele, any%, TAS
    self.statistics["curr"]["usedEle"] = self openCJ\elevate::hasEleOverrideEver();
    self.statistics["curr"]["usedAnyPct"] = false; // Not implemented yet
    self.statistics["curr"]["usedTAS"] = false; // Not implemented yet
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
		self.statistics["curr"]["explosiveJumps"]++;
	}
}

onGrenadeThrow(nade, name)
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	self.statistics["curr"]["explosiveLaunches"]++;
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
	self.statistics["curr"]["explosiveJumps"]++;

	if(!self isOnGround())
	{
		// Check if a second RPG was fired
		if(isDefined(self.statistics["curr"]["lastJumpTime"]) && isDefined(self.statistics["curr"]["lastExplosiveFiredTime"]) &&
			(self.statistics["curr"]["lastExplosiveFiredTime"] >= self.statistics["curr"]["lastJumpTime"]))
		{
			self.statistics["curr"]["doubleExplosives"]++;
			self iprintln("^1Double rpg detected");
		}

		// We aren't on ground, so this counts as an RPG jump
		self.statistics["curr"]["explosiveJumps"]++;
		self.statistics["curr"]["lastExplosiveFiredTime"] = getTime();
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

setJumpCount(val)
{
    self.statistics["curr"]["jumpCount"] = val;
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

setExplosiveJumps(amount) // RPG jumps, nade jumps
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	self.statistics["curr"]["explosiveJumps"] = amount;
}

getExplosiveJumps()
{
	return self.statistics["curr"]["explosiveJumps"];
}

setExplosiveLaunches(value) // RPG shots, nade throws
{
	self.statistics["curr"]["explosiveLaunches"] = value;
}

getExplosiveLaunches()
{
	return self.statistics["curr"]["explosiveLaunches"];
}

setDoubleExplosives(amount) // Double RPGs
{
	if(self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	self.statistics["curr"]["doubleExplosives"] = amount;
}

getDoubleExplosives()
{
	return self.statistics["curr"]["doubleExplosives"];
}

setFPSMode(mode)
{
    self.statistics["curr"]["fpsMode"] = mode;
}

getFPSMode()
{
	return self.statistics["curr"]["fpsMode"];
}

getUsedEle()
{
    return self.statistics["curr"]["usedEle"];
}

getUsedAnyPct()
{
    return self.statistics["curr"]["usedAnyPct"];
}

getUsedTAS()
{
    return self.statistics["curr"]["usedTAS"];
}