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
    lowTimeThresholdSeconds = 60.0;
    if (level.remainingTimeSeconds <= 0)
    {
        self _updateTimer(); // Will hide the timer
    }
    else
    {
        self _setTimerColor();
    }
}

_setTimerColor()
{
    lowTimeThresholdSeconds = 60.0;
    if (level.remainingTimeSeconds < lowTimeThresholdSeconds)
    {
        factor = level.remainingTimeSeconds / lowTimeThresholdSeconds;
        self.hudTimeLimit.color = (1.0, factor, factor);
    }
    else
    {
        self.hudTimeLimit.color = (1.0, 1.0, 1.0);
    }
}

onTimeLimitReached()
{
    _updatePlayerTimers();
}

onRemainingTimeChanged()
{
    _updatePlayerTimers();
}

_updateTimer()
{
    // The HUD itself is just a timer counting down the level time, but it has to be synced with the sound effect
    level waittill("second_passed", secondsLeft);

    if (secondsLeft > 0)
    {
        self.hudTimeLimit setTimer(secondsLeft);
        self _setTimerColor();
        self.hudTimeLimit.alpha = 1;
    }
    else
    {
        self.hudTimeLimit.alpha = 0;
    }
}

_updatePlayerTimers()
{
    players = getEntArray("player", "classname");
    for (i = 0; i < players.size; i++)
    {
        players[i] _updateTimer();
    }
}

onStartDemo()
{
    self.hudTimeLimit.alpha = 0;
}

onStopDemo()
{
    self.hudTimeLimit.alpha = 1;
}