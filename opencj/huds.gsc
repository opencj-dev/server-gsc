#include openCJ\util;

whileAlive()
{
	if(self openCJ\playerRuns::hasJumpSlowdown())
	{
		if(self getJumpSlowdownTimer() > 0)
		{
			self.jumpSlowdownTimerHud.alpha = 1;
			self.jumpSlowdownTimerHud setValue(int(self getJumpSlowdownTimer() / 100) / 10);
		}
		else if(self.jumpSlowdownTimerHud.alpha != 0)
		{
			self.jumpSlowdownTimerHud fadeOverTime(0.5);
			self.jumpSlowdownTimerHud.alpha = 0;
		}
	}
	else
		self.jumpSlowdownTimerHud.alpha = 0;
}

onPlayerConnect()
{
	self.jumpSlowdownTimerHud = newClientHudElem(self);
	self.jumpSlowdownTimerHud.horzAlign = "center_safearea";
	self.jumpSlowdownTimerHud.vertAlign = "center_safearea";
	self.jumpSlowdownTimerHud.alignX = "center";
	self.jumpSlowdownTimerHud.alignY = "middle";
	self.jumpSlowdownTimerHud.x = 0;
	self.jumpSlowdownTimerHud.y = -30;
	self.jumpSlowdownTimerHud.fontscale = 1.5;
	self.jumpSlowdownTimerHud.alpha = 0;
	self.jumpSlowdownTimerHud.archived = true;
	self.jumpSlowdownTimerHud.endTime = getTime();
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	self.jumpSlowdownTimerHud.alpha = 0;
}

onSpawnPlayer()
{
	self.jumpSlowdownTimerHud.alpha = 0;
}

onSpawnSpectator()
{
	self.jumpSlowdownTimerHud.alpha = 0;
}