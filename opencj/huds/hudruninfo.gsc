#include openCJ\util;

onInit()
{
    level.runInfoShader["fps_any"] = "opencj_icon_fps_any";
    level.runInfoShader["fps_classic125"] = "opencj_icon_fps_classic125";
    level.runInfoShader["fps_standard"] = "opencj_icon_fps_standard";
    level.runInfoShader["ele"] = "opencj_icon_ele";
    level.runInfoShader["anyPct"] = "opencj_icon_anypct";
    level.runInfoShader["hardTAS"] = "opencj_icon_tas";
    level.iconWidth = 16;
    level.iconHeight = 20;
    level.firstIconX = 80;
    level.spaceBetweenIcons = 5;
    precacheShader(level.runInfoShader["fps_any"]);
    precacheShader(level.runInfoShader["fps_classic125"]);
    precacheShader(level.runInfoShader["fps_standard"]);
    precacheShader(level.runInfoShader["ele"]);
    precacheShader(level.runInfoShader["anyPct"]);
    precacheShader(level.runInfoShader["hardTAS"]);
}

onStartDemo()
{
    specs = self getSpectatorList(true); // true -> self as spectator too
    for (i = 0; i < specs.size; i++)
    {
        specs[i] _hideRunIcons();
        specs[i] _hideRunStatus();
    }
}

onRunCreated()
{

}

onRunStarted()
{

}

onRunStopped()
{

}

onRunRestored()
{

}

onRunPaused()
{

}

onRunResumed()
{
    
}

whileAlive()
{
    shouldShowIcons = (self openCJ\playerRuns::hasRunID()) && (self openCJ\playerRuns::hasRunStarted());

    spectators = getSpectatorList(true); // true -> also consider yourself a spectator
    for(i = 0; i < spectators.size; i++)
    {
        // Show run status
        spectators[i] _showRunStatus(self);

        // Check if icons should be shown
        if (shouldShowIcons)
        {
            spectators[i] _showRunIcons(self);
        }
        else
        {
            spectators[i] _hideRunIcons();
        }
    }
}

onSpectatorClientChanged(newClient)
{
    if (isDefined(newClient))
    {
        self _showRunIcons(newClient);
        self _showRunStatus(newClient);
    }
    else
    {
        self _hideRunStatus();
        self _hideRunIcons();
    }
}

onSpawnSpectator()
{
    self _hideRunIcons();
    self _hideRunStatus();
}

onSpawnPlayer()
{
    self _showRunIcons(self);
    self _showRunStatus(self);
}

onPlayerConnect()
{
    self _createRunInfoHud();
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
    spectators = getSpectatorList(false);
    for(i = 0; i < spectators.size; i++)
    {
        spectators[i] _hideRunIcons();
        spectators[i] _hideRunStatus();
    }
}

_showRunStatus(player)
{
    // Run status
    if (player.sessionState == "playing")
    {
        if (!player openCJ\playerRuns::hasRunID())
        {
            self.hudRunInfo["status"] setText("^1Not in a run");
            self.hudRunInfo["status"].alpha = 1;
        }
        else if (player openCJ\playerRuns::isRunPaused())
        {
            self.hudRunInfo["status"] setText("^5Run is paused");
            self.hudRunInfo["status"].alpha = 1;
        }
        else
        {
            self.hudRunInfo["status"].alpha = 0;
        }
    }
    else
    {
        self.hudRunInfo["status"].alpha = 0;
    }
}

_hideRunStatus()
{
    self.hudRunInfo["status"].alpha = 0;
}

_showRunIcons(player)
{
    // FPS
    // TODO: CoD2 specific FPS don't have a shader (yet)..
    FPSMode = player openCJ\fps::getCurrentFPSMode();
    if (FPSMode == "hax")
    {
        self.hudRunInfo["fps"] setShader(level.runInfoShader["fps_any"], level.iconWidth, level.iconHeight);
        self.hudRunInfo["fps"].alpha = 1;
    }
    else if (FPSMode == "mix")
    {
        self.hudRunInfo["fps"] setShader(level.runInfoShader["fps_standard"], level.iconWidth, level.iconHeight);
        self.hudRunInfo["fps"].alpha = 1;
    }
    else //todo: cod2 fpsses
    {
        self.hudRunInfo["fps"] setShader(level.runInfoShader["fps_classic125"], level.iconWidth, level.iconHeight);
        self.hudRunInfo["fps"].alpha = 1;
    }

    iconCount = 1;

    // Ele
    if (player openCJ\elevate::hasEleOverrideEver())
    {
        self.hudRunInfo["ele"].x = level.firstIconX + (level.spaceBetweenIcons + level.iconWidth) * iconCount;
        self.hudRunInfo["ele"].alpha = 1;
        iconCount++;
    }
    else
    {
        self.hudRunInfo["ele"].alpha = 0;
    }

    // Any %
    if (player openCJ\anyPct::hasAnyPct())
    {
        self.hudRunInfo["anyPct"].x = level.firstIconX + (level.spaceBetweenIcons + level.iconWidth) * iconCount;
        self.hudRunInfo["anyPct"].alpha = 1;
        iconCount++;
    }
    else
    {
        self.hudRunInfo["anyPct"].alpha = 0;
    }

    // Hard TAS
    if (player openCJ\tas::hasHardTAS())
    {
        self.hudRunInfo["hardTAS"].x = level.firstIconX + (level.spaceBetweenIcons + level.iconWidth) * iconCount;
        self.hudRunInfo["hardTAS"].alpha = 1;
        iconCount++;
    }
    else
    {
        self.hudRunInfo["hardTAS"].alpha = 0;
    }
}

_hideRunIcons()
{
    self.hudRunInfo["fps"].alpha = 0;
    self.hudRunInfo["ele"].alpha = 0;
    self.hudRunInfo["anyPct"].alpha = 0;
    self.hudRunInfo["hardTAS"].alpha = 0;
}

_createRunInfoHud()
{
    self.hudRunInfo = [];

    // The following is a HUD in the top of your screen that shows the current run status of the player (Not in a run or Paused. Otherwise nothing is shown)
    self.hudRunInfo["status"] = newClientHudElem(self);
    self.hudRunInfo["status"].horzAlign = "center_safearea";
    self.hudRunInfo["status"].vertAlign = "center_safearea";
    self.hudRunInfo["status"].alignX = "center";
    self.hudRunInfo["status"].alignY = "top";
    self.hudRunInfo["status"].x = 0;
    self.hudRunInfo["status"].y = -150;
    self.hudRunInfo["status"].alpha = 0;
    self.hudRunInfo["status"].archived = false;
    self.hudRunInfo["status"].fontScale = 1.6;
    self.hudRunInfo["status"].hideWhenInMenu = true;

    // The following are icons in bottom left corner
    
    yAboveProgressBar = 467; // Right above progress bar
    self.hudRunInfo["fps"] = newClientHudElem(self);
    self.hudRunInfo["fps"].horzAlign = "fullscreen";
    self.hudRunInfo["fps"].vertAlign = "fullscreen";
    self.hudRunInfo["fps"].alignX = "left";
    self.hudRunInfo["fps"].alignY = "bottom";
    self.hudRunInfo["fps"].x = level.firstIconX;
    self.hudRunInfo["fps"].y = yAboveProgressBar;
    self.hudRunInfo["fps"].alpha = 0;
    self.hudRunInfo["fps"].archived = false;
    self.hudRunInfo["fps"].hideWhenInMenu = true;
    self.hudRunInfo["fps"] setShader(level.runInfoShader["fps_classic125"], level.iconWidth, level.iconHeight);

    self.hudRunInfo["ele"] = newClientHudElem(self);
    self.hudRunInfo["ele"].horzAlign = "fullscreen";
    self.hudRunInfo["ele"].vertAlign = "fullscreen";
    self.hudRunInfo["ele"].alignX = "left";
    self.hudRunInfo["ele"].alignY = "bottom";
    self.hudRunInfo["ele"].x = level.firstIconX + level.spaceBetweenIcons + level.iconWidth;
    self.hudRunInfo["ele"].y = yAboveProgressBar;
    self.hudRunInfo["ele"].alpha = 0;
    self.hudRunInfo["ele"].archived = false;
    self.hudRunInfo["ele"].hideWhenInMenu = true;
    self.hudRunInfo["ele"] setShader(level.runInfoShader["ele"], level.iconWidth, level.iconHeight);

    self.hudRunInfo["anyPct"] = newClientHudElem(self);
    self.hudRunInfo["anyPct"].horzAlign = "fullscreen";
    self.hudRunInfo["anyPct"].vertAlign = "fullscreen";
    self.hudRunInfo["anyPct"].alignX = "left";
    self.hudRunInfo["anyPct"].alignY = "bottom";
    self.hudRunInfo["anyPct"].x = level.firstIconX + (2 * (level.spaceBetweenIcons + level.iconWidth));
    self.hudRunInfo["anyPct"].y = yAboveProgressBar;
    self.hudRunInfo["anyPct"].alpha = 0;
    self.hudRunInfo["anyPct"].archived = false;
    self.hudRunInfo["anyPct"].hideWhenInMenu = true;
    self.hudRunInfo["anyPct"] setShader(level.runInfoShader["anyPct"], level.iconWidth, level.iconHeight);

    self.hudRunInfo["hardTAS"] = newClientHudElem(self);
    self.hudRunInfo["hardTAS"].horzAlign = "fullscreen";
    self.hudRunInfo["hardTAS"].vertAlign = "fullscreen";
    self.hudRunInfo["hardTAS"].alignX = "left";
    self.hudRunInfo["hardTAS"].alignY = "bottom";
    self.hudRunInfo["hardTAS"].x = level.firstIconX + (3 * (level.spaceBetweenIcons + level.iconWidth));
    self.hudRunInfo["hardTAS"].y = yAboveProgressBar;
    self.hudRunInfo["hardTAS"].alpha = 0;
    self.hudRunInfo["hardTAS"].archived = false;
    self.hudRunInfo["hardTAS"].hideWhenInMenu = true;
    self.hudRunInfo["hardTAS"] setShader(level.runInfoShader["hardTAS"], level.iconWidth, level.iconHeight);
}