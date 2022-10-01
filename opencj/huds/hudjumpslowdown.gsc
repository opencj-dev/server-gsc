#include openCJ\util;

onPlayerConnect()
{
    self.jumpSlowDownHudName = "jumpSlowDownTimer";
    //                        name                      x   y   alignX    alignY    hAlign             vAlign
    self opencj\huds::initHUD(self.jumpSlowDownHudName, 0, -30, "center", "middle", "center_safearea", "center_safearea",
                        //    foreground   font     hideInMenu   color    glowColor  glowAlpha  fontScale  archived alpha
                              undefined, undefined, undefined, undefined, undefined, undefined, 1.5,       true,    0);
	self.hud[self.jumpSlowDownHudName].endTime = getTime();
}

whileAlive()
{
	if(self openCJ\playerRuns::hasJumpSlowdown())
	{
		if(self getJumpSlowdownTimer() > 0)
		{
			self.hud[self.jumpSlowDownHudName].alpha = 1;
			self.hud[self.jumpSlowDownHudName] setValue(int(self getJumpSlowdownTimer() / 100) / 10);
		}
		else if(self.hud[self.jumpSlowDownHudName].alpha != 0)
		{
			self.hud[self.jumpSlowDownHudName] fadeOverTime(0.5);
			self.hud[self.jumpSlowDownHudName].alpha = 0;
		}
	}
	else
    {
		self.hud[self.jumpSlowDownHudName].alpha = 0;
    }
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	self.hud[self.jumpSlowDownHudName].alpha = 0;
}

onSpawnPlayer()
{
	self.hud[self.jumpSlowDownHudName].alpha = 0;
}

onSpawnSpectator()
{
	self.hud[self.jumpSlowDownHudName].alpha = 0;
}

onStartDemo()
{
	self.hud[self.jumpSlowDownHudName].alpha = 0;
}