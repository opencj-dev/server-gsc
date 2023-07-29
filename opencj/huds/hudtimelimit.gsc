onPlayerConnect()
{
    if (!isDefined(self.hudTimeLimit))
    {
        self.hudTimeLimit = newClientHudElem(self);
        self.hudTimeLimit.alpha = 0;
        self.hudTimeLimit.foreground = true;
        self.hudTimeLimit.alignx = "center";
        self.hudTimeLimit.aligny = "bottom";
        self.hudTimeLimit.x = 0;
        self.hudTimeLimit.y = -12; // Above progress bar
        self.hudTimeLimit.horzalign = "center";
        self.hudTimeLimit.vertalign = "bottom";
        self.hudTimeLimit.color = (1.0, 1.0, 1.0);
        self.hudTimeLimit.fontscale = 1.4;
        self.hudTimeLimit.archived = false;

        // The HUD itself is just a timer counting down the level time
        self _updateTimer();

        self.hudTimeLimit.alpha = 1;
    }
}

whileAlive()
{
    // If time gets low, make timer more red and play a sound
    lowTimeThreshold = 60.0;
    if (level.remainingTime <= 0)
    {
        self _updateTimer(); // Will hide the timer
    }
    else if (level.remainingTime < lowTimeThreshold)
    {
        factor = float(level.remainingTime / lowTimeThreshold);
        self.hudTimeLimit.color = (1.0, factor, factor);
    }
}

_updateTimer()
{
    // The HUD itself is just a timer counting down the level time
    if (level.remainingTime > 0)
    {
        self.hudTimeLimit setTimer(level.remainingTime);
    }
    else
    {
        self.hudTimeLimit setText("");
    }
}

onRemainingTimeChanged()
{
    self _updateTimer();
}

onStartDemo()
{
    self.hudTimeLimit.alpha = 0;
}

onStopDemo()
{
    self.hudTimeLimit.alpha = 1;
}