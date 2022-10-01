#include openCJ\util;

onPlayerConnect()
{
	self.grenadeTimers = [];
    self.grenadeTimersHudName = "grenadeTimers";
	y = 40 + (10 * self.grenadeTimers.size);
    //                             name                       x   y   alignX    alignY    hAlign   vAlign
    self opencj\huds\base::initHUD(self.grenadeTimersHudName, 20, y,  "left",   "top",    "left",  "top",
                        //    foreground   font     hideInMenu   color    glowColor  glowAlpha  fontScale  archived alpha
                              undefined, undefined, undefined, undefined, undefined, undefined, 1,         true,    0);
	self.hud[self.grenadeTimersHudName].endTime = getTime();
}

onGrenadeThrow(nade, name)
{
	self thread _showNadeTimer();
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	self removeNadeTimers();
}

onSpawnPlayer()
{
	self removeNadeTimers();
}

_showNadeTimer()
{
	self endon("disconnect");
	self endon("stopNadeTimer");

	self.hud[self.grenadeTimersHudName].nadeTimer.y = 40 + 10 * self.grenadeTimers.size;
	self.hud[self.grenadeTimersHudName].nadeTimer.alpha = 1;
	self.hud[self.grenadeTimersHudName].nadeTimer setTenthsTimer(3.45);

	self.grenadeTimers[self.grenadeTimers.size] = self.hud[self.grenadeTimersHudName].nadeTimer;

	for(t = 0; t < 70; t++)
	{
		if(t < 35)
		{
			self.hud[self.grenadeTimersHudName].nadeTimer.color = (t / 35, 1, 0);
		}
		else
		{
			self.hud[self.grenadeTimersHudName].nadeTimer.color = (1, 1 - ((t - 35) / 35), 0);
		}
		wait 0.05;
	}

	ownNum = self.grenadeTimers.size - 1;
	for(i = 0; i < self.grenadeTimers.size; i++)
	{
		if(self.grenadeTimers[i] != self.hud[self.grenadeTimersHudName].nadeTimer)
		{
			if(self.grenadeTimers[i].y > self.hud[self.grenadeTimersHudName].nadeTimer.y)
			{
				self.grenadeTimers[i].y -= 10;
			}
		}
		else
		{
			ownNum = i;
		}
	}
	self.grenadeTimers[ownNum] = self.grenadeTimers[self.grenadeTimers.size - 1];
	self.grenadeTimers[self.grenadeTimers.size - 1] = undefined;
}

removeNadeTimers()
{
	self notify("stopNadeTimer");
	for(i = 0; i < self.grenadeTimers.size; i++)
	{
		self.grenadeTimers[i] destroy();
	}
	for(i = i - 1; i >= 0; i--)
	{
		self.grenadeTimers[i] = undefined;
	}
}