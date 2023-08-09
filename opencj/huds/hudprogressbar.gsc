#include openCJ\util;

onInit()
{
	level.progressBarShader = "progress_bar_fill";
    level.progressBarHeight = 10;
    level.progressBarMinWidth = 1; // Lower than this and it will default to its normal size
    level.progressBarOffsetX = 0;
    level.progressBarOffsetY = 482; // Needs a +2 otherwise there is a gap under it, for whatever reason
    level.progressBarMaxValue = (640 - level.progressBarOffsetX);
    level.progressBarScaleDuration = 0.25;
	precacheShader(level.progressBarShader);
}

onCheckpointsChanged()
{
	self _updateProgressBar();
}

onStartDemo()
{
	self _hideProgressBar();
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

onCheatStatusChanged(isCheating)
{
	self _updateProgressBar();
}

_createProgressBar()
{
	self.progressBar = newClientHudElem(self);
	self.progressBar.horzAlign = "fullscreen";
	self.progressBar.vertAlign = "fullscreen";
	self.progressBar.alignX = "left";
	self.progressBar.alignY = "bottom";
	self.progressBar.x = level.progressBarOffsetX;
    self.progressBar.y = level.progressBarOffsetY;
    if (getCodVersion() == 2)
    {
        self.progressBar.y += 5;
    }
	self.progressBar.alpha = 0;
	self.progressBar.color = (1, 1, 1);
	self.progressBar.archived = true;
    self.progressBar.hideWhenInMenu = true;
    self.progressBar.shader = level.progressBarShader;
    self.prevProgress = 0;
    self.prevRunFinished = false;
}

_updateProgressBar()
{
    if(self openCJ\cheating::isCheating())
    {
        progress = level.progressBarMaxValue; // At this point it's more important showing the player that their run is marked as cheated
        self.progressBar setShader(level.progressBarShader, level.progressBarMaxValue, level.progressBarHeight);
        self.progressBar.color = (0.8, 0.3, 0.3); // Cheating -> make it redish
        self.progressBar.alpha = 0.4; // Red is quite intense, mellow it down a bit
        self _showProgressBar();
    }
	else if(self openCJ\playerRuns::isRunFinished())
	{
		self.progressBar.color = (0.4, 0.8, 0.4); // Finished -> make it greenish
		self.progressBar.alpha = 0.4; // Green is quite intense, mellow it down a bit

        progress = level.progressBarMaxValue; // Progress bar should now be full
        self _showProgressBar();
        if (!self.prevRunFinished) // Wasn't finished last check
        {
            self.progressBar setShader(level.progressBarShader, self.prevProgress, level.progressBarHeight);
            self.progressBar scaleOverTime(level.progressBarScaleDuration, progress, level.progressBarHeight);
            self.prevRunFinished = true;
        }
        else // Was already finished
        {
            self.progressBar setShader(level.progressBarShader, progress, level.progressBarHeight);
        }
	}
	else // Hasn't finished the current route
	{
		self.progressBar.color = (1, 1, 1);
        self.progressBar.alpha = 0.6;
		checkpoint = self openCJ\checkpoints::getCurrentCheckpoint();
		if(isDefined(checkpoint))
		{
			passed = openCJ\checkpoints::getPassedCheckpointCount(checkpoint);
			remaining = openCJ\checkpoints::getRemainingCheckpointCount(checkpoint);
			total = passed + remaining;
			if((total == 0) || (passed == 0))
			{
				progress = 0;
                self _hideProgressBar();
			}
            else
            {
                progress = int((passed / total) * level.progressBarMaxValue);
                if (self.prevProgress == 0)
                {
                    // Otherwise the first update of progress bar will go from its normal size to smaller
                    self.progressBar setShader(level.progressBarShader, level.progressBarMinWidth, level.progressBarHeight);
                }
                else
                {
                    self.progressBar setShader(level.progressBarShader, self.prevProgress, level.progressBarHeight);
                }
                self _showProgressBar();
                self.progressBar scaleOverTime(level.progressBarScaleDuration, progress, level.progressBarHeight);
			}
		}
		else // Hasn't passed the first checkpoint yet
		{
			progress = 0;
            self _hideProgressBar();
		}
	}
    self.prevProgress = progress;
}

_hideProgressBar()
{
	self.progressBar.alpha = 0;
}

_showProgressBar()
{
	self.progressBar.alpha = 0.6;
}
