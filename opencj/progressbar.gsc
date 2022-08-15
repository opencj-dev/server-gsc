#include openCJ\util;

onInit()
{
	level.progressBarShader = "white";
	precacheShader(level.progressBarShader);
}

onCheckpointsChanged()
{
	self _updateProgressBar();
}

onSpawnPlayer()
{
	self _updateProgressBar();
}

onSpawnSpectator()
{
	self _hideProgressBar();
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	self _hideProgressBar();
}

onRunFinished(cp)
{
	self _updateProgressBar();
}

onPlayerConnect()
{
	self _createProgressBar();
}

_createProgressBar()
{
	self.progressBar = newClientHudElem(self);
	self.progressBar.horzAlign = "fullscreen";
	self.progressBar.vertAlign = "fullscreen";
	self.progressBar.alignX = "left";
	self.progressBar.alignY = "bottom";
	self.progressBar.x = -20;
	self.progressBar.y = 485;
	self.progressBar.alpha = 0;
	self.progressBar setShader(level.progressBarShader, 20, 8);
	self.progressBar.color = (1, 1, 1);
	self.progressBar.archived = true;
}

_updateProgressBar()
{
	
	
	if(self openCJ\playerRuns::isRunFinished())
	{
		progress = 640 + 20;
		self.progressBar.color = (0.4, 0.8, 0.4);
		self.progressBar.alpha = 0.4;
	}
	else
	{
		self.progressBar.alpha = 0.5;
		self.progressBar.color = (1, 1, 1);
		checkpoint = self openCJ\checkpoints::getCheckpoint();
		if(isDefined(checkpoint))
		{
			passed = openCJ\checkpoints::getPassedCheckpointCount(checkpoint);
			remaining = openCJ\checkpoints::getRemainingCheckpointCount(checkpoint);
			total = passed + remaining;
			if(total == 0)
			{
				progress = 100;
			}
			else
			{
				progress = int((passed / total) * 640) + 20;
			}
		}
		else
		{
			progress = 20;
		}
	}
	printf("progress: " + progress + "\n");
	self.progressBar scaleOverTime(0.25, progress, 8);
}

_hideProgressBar()
{
	self.progressBar.alpha = 0;
}