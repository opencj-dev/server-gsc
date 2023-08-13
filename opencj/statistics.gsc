#include openCJ\util;

// Event functions

onInit()
{
    level.statisticsStrings_secondsPlayed = "secondsPlayed";
    level.statisticsStrings_saveCount = "saveCount";
    level.statisticsStrings_loadCount = "loadCount";
    level.statisticsStrings_explosiveLaunches = "explosiveLaunches";
    level.statisticsStrings_explosiveJumps = "explosiveJumps";
    level.statisticsStrings_doubleExplosives = "doubleExplosives";
    level.statisticsStrings_jumpCount = "jumpCount";
    level.statisticsStrings_lastExplosiveFiredTime = "lastExplosiveFiredTime";
    level.statisticsStrings_lastJumpTime = "lastJumpTime";
    level.statisticsStrings_usedEle = "usedEle";
    level.statisticsStrings_usedAnyPct = "usedAnyPct";
    level.statisticsStrings_usedTAS = "usedTAS";
    level.statisticsStrings_route = "route";
    level.statisticsStrings_progress = "progress";
    level.statisticsStrings_FPSMode = "FPSMode";
}

onPlayerConnect()
{
    self.statistics = [];
    clear(); // Initialize the variables
}

onRunCreated()
{
    clear(); // Marks statistics as needing to be updated
}

onRunStopped()
{
    clear(); // Marks statistics as needing to be updated
}

onSpectatorClientChanged(newClient)
{
    self.shouldStatisticsBeUpdated = true;
}

onSpawnPlayer()
{
    self.shouldStatisticsBeUpdated = true;
}

clear()
{
    self.statistics[level.statisticsStrings_secondsPlayed] = 0;
    self.statistics[level.statisticsStrings_saveCount] = 0;
    self.statistics[level.statisticsStrings_loadCount] = 0;
    self.statistics[level.statisticsStrings_explosiveLaunches] = 0;
    self.statistics[level.statisticsStrings_explosiveJumps] = 0;
    self.statistics[level.statisticsStrings_doubleExplosives] = 0;
    self.statistics[level.statisticsStrings_jumpCount] = 0;
    self.statistics[level.statisticsStrings_lastExplosiveFiredTime] = 0;
    self.statistics[level.statisticsStrings_lastJumpTime] = 0;
    self.statistics[level.statisticsStrings_usedEle] = false;
    self.statistics[level.statisticsStrings_usedAnyPct] = false;
    self.statistics[level.statisticsStrings_usedTAS] = false;
    self.statistics[level.statisticsStrings_route] = "";
    self.statistics[level.statisticsStrings_progress] = "";
    self.statistics[level.statisticsStrings_FPSMode] = "";

    self.shouldStatisticsBeUpdated = true;
}

whileAlive()
{
    if(self isOnGround())
    {
        self.statistics[level.statisticsStrings_lastJumpTime] = undefined;
    }

    // Time
    secondsPlayed = self.statistics[level.statisticsStrings_secondsPlayed];
    self.statistics[level.statisticsStrings_secondsPlayed] = self openCJ\playTime::getSecondsPlayed();
    if (self.statistics[level.statisticsStrings_secondsPlayed] != secondsPlayed)
    {
        self.shouldStatisticsBeUpdated = true;
    }

    // FPS
    FPSMode = self.statistics[level.statisticsStrings_FPSMode];
    self.statistics[level.statisticsStrings_FPSMode] = openCJ\fps::getCurrentFPSMode();
    if (self.statistics[level.statisticsStrings_FPSMode] != FPSMode)
    {
        self.shouldStatisticsBeUpdated = true;
    }

    // Ele, any%, TAS
    hasUsedEle = self.statistics[level.statisticsStrings_usedEle];
    hasUsedAnyPct = self.statistics[level.statisticsStrings_usedAnyPct];
    hasUsedHardTAS = self.statistics[level.statisticsStrings_usedTAS];
    self.statistics[level.statisticsStrings_usedEle] = self openCJ\elevate::hasEleOverrideEver();
    self.statistics[level.statisticsStrings_usedAnyPct] = false; // Not implemented yet
    self.statistics[level.statisticsStrings_usedTAS] = false; // Not implemented yet

    if ((self.statistics[level.statisticsStrings_usedEle] != hasUsedEle) || (self.statistics[level.statisticsStrings_usedAnyPct] != hasUsedAnyPct) || (self.statistics[level.statisticsStrings_usedTAS] != hasUsedHardTAS))
    {
        self.shouldStatisticsBeUpdated = true;
    }
}

_updateProgress()
{
    currentCheckpoint = self openCJ\checkpoints::getCurrentCheckpoint();
    shouldClear = false;
    if (self openCJ\playerRuns::hasRunStarted() && isDefined(currentCheckpoint))
    {
        route = openCJ\checkpoints::getRouteNameForCheckpoint(currentCheckpoint);
        if(isDefined(route))
        {
            // Route
            self.statistics[level.statisticsStrings_route] = route;

            // Progress
            if (self openCJ\playerRuns::isRunFinished())
            {
                self.statistics[level.statisticsStrings_progress] = "Finished";
            }
            else
            {
                currentCp = self openCJ\checkpoints::getCurrentCheckpoint();
                nrPassedCps = 0;
                nrRemainingCps = undefined;
                if (isDefined(currentCp))
                {
                    nrPassedCps = openCJ\checkpoints::getPassedCheckpointCount(currentCp);
                    nrRemainingCps = openCJ\checkpoints::getRemainingCheckpointCount(currentCp);
                    if (isDefined(nrRemainingCps))
                    {
                        nrTotalCps = nrPassedCps + nrRemainingCps;
                        percentage = int((nrPassedCps / (nrPassedCps + nrRemainingCps)) * 100);
                        self.statistics[level.statisticsStrings_progress] = nrPassedCps + " / " + nrTotalCps + " (" + percentage + "'/.)";
                    }
                    else
                    {
                        self.statistics[level.statisticsStrings_progress] = nrPassedCps + " / ?";
                    }
                }
            }
        }
        else
        {
            shouldClear = true;
        }
    }
    else
    {
        shouldClear = true;
    }

    if (shouldClear)
    {
        self.statistics[level.statisticsStrings_route] = undefined;
        self.statistics[level.statisticsStrings_progress] = undefined;
    }
    self.shouldStatisticsBeUpdated = true;
}

increaseAndGetSaveCount()
{
    if(self openCJ\playerRuns::isRunFinished())
    {
        return -1;
    }

    self.statistics[level.statisticsStrings_saveCount]++;
    self.shouldStatisticsBeUpdated = true;
    return self.statistics[level.statisticsStrings_saveCount];
}

onRunFinished()
{
    self _updateProgress(); // Marks statistics as needing to be updated
}

onRunStarted()
{
    self _updateProgress(); // Marks statistics as needing to be updated
}

onCheckpointsChanged()
{
    self _updateProgress(); // Marks statistics as needing to be updated
}

onLoadPosition()
{
    if(self openCJ\playerRuns::isRunFinished())
    {
        return;
    }

    self.statistics[level.statisticsStrings_loadCount]++;
    self _updateProgress(); // Marks statistics as needing to be updated
}

onPlayerDamage(inflictor, attacker, damage, flags, meansOfDeath, weapon, vPoint, vDir, hitLoc, psOffsetTime)
{
    if(self openCJ\playerRuns::isRunFinished())
    {
        return;
    }

    if(self openCJ\weapons::isGrenade(weapon) && !self isOnGround())
    {
        self.statistics[level.statisticsStrings_explosiveJumps]++;
        self.shouldStatisticsBeUpdated = true;
    }
}

onGrenadeThrow(nade, name)
{
    if(self openCJ\playerRuns::isRunFinished())
    {
        return;
    }

    self.statistics[level.statisticsStrings_explosiveLaunches]++;
    self.shouldStatisticsBeUpdated = true;
}

onJump()
{
    if(self openCJ\playerRuns::isRunFinished())
    {
        return;
    }

    self.statistics[level.statisticsStrings_jumpCount]++;
    self.statistics[level.statisticsStrings_lastJumpTime] = getTime();
    self.shouldStatisticsBeUpdated = true;
}

onRPGFired(rpg, name)
{
    if(self openCJ\playerRuns::isRunFinished())
    {
        return;
    }

    // An RPG was fired
    self.statistics[level.statisticsStrings_explosiveLaunches]++;

    if(!self isOnGround())
    {
        // Check if a second RPG was fired
        if(isDefined(self.statistics[level.statisticsStrings_lastJumpTime]) && isDefined(self.statistics[level.statisticsStrings_lastExplosiveFiredTime]) &&
            (self.statistics[level.statisticsStrings_lastExplosiveFiredTime] >= self.statistics[level.statisticsStrings_lastJumpTime]))
        {
            self.statistics[level.statisticsStrings_doubleExplosives]++;
            self iprintlnbold("^1Double rpg detected");
            self openCJ\cheating::setCheating(true);
        }

        // We aren't on ground, so this counts as an RPG jump
        self.statistics[level.statisticsStrings_explosiveJumps]++;
        self.statistics[level.statisticsStrings_lastExplosiveFiredTime] = getTime();
    }
    self.shouldStatisticsBeUpdated = true;
}

// Logic functions

haveStatisticsChanged()
{
    return self.shouldStatisticsBeUpdated;
}

setHasUpdatedStatistics()
{
    self.shouldStatisticsBeUpdated = false;
}

// Getters/setters

getRouteAndProgress()
{
    str = "";
    if (isDefined(self.statistics[level.statisticsStrings_route]) && (self.statistics[level.statisticsStrings_route] != ""))
    {
        str += "Route: " + self.statistics[level.statisticsStrings_route] + "\n";
        if (isDefined(self.statistics[level.statisticsStrings_progress]))
        {
            str += "Progress: " + self.statistics[level.statisticsStrings_progress];
        }
    }
    return str;
}

setJumpCount(val)
{
    self.statistics[level.statisticsStrings_jumpCount] = val;
    self.shouldStatisticsBeUpdated = true;
}

getJumpCount()
{
    return self.statistics[level.statisticsStrings_jumpCount];
}

setLoadCount(value)
{
    self.statistics[level.statisticsStrings_loadCount] = value;
    self.shouldStatisticsBeUpdated = true;
}

getLoadCount()
{
    return self.statistics[level.statisticsStrings_loadCount];
}

setSaveCount(value)
{
    self.statistics[level.statisticsStrings_saveCount] = value;
    self.shouldStatisticsBeUpdated = true;
}

getSaveCount()
{
    return self.statistics[level.statisticsStrings_saveCount];
}

setExplosiveJumps(amount) // RPG jumps, nade jumps
{
    if(self openCJ\playerRuns::isRunFinished())
    {
        return;
    }

    self.statistics[level.statisticsStrings_explosiveJumps] = amount;
    self.shouldStatisticsBeUpdated = true;
}

getExplosiveJumps()
{
    return self.statistics[level.statisticsStrings_explosiveJumps];
}

setExplosiveLaunches(value) // RPG shots, nade throws
{
    self.statistics[level.statisticsStrings_explosiveLaunches] = value;
    self.shouldStatisticsBeUpdated = true;
}

getExplosiveLaunches()
{
    return self.statistics[level.statisticsStrings_explosiveLaunches];
}

setDoubleExplosives(amount) // Double RPGs
{
    if(self openCJ\playerRuns::isRunFinished())
    {
        return;
    }

    self.statistics[level.statisticsStrings_doubleExplosives] = amount;
    self.shouldStatisticsBeUpdated = true;
}

getDoubleExplosives()
{
    return self.statistics[level.statisticsStrings_doubleExplosives];
}

setFPSMode(mode)
{
    self.statistics[level.statisticsStrings_FPSMode] = mode;
    self.shouldStatisticsBeUpdated = true;
}

getFPSMode()
{
    return self.statistics[level.statisticsStrings_FPSMode];
}

getUsedEle()
{
    return self.statistics[level.statisticsStrings_usedEle];
}

getUsedAnyPct()
{
    return self.statistics[level.statisticsStrings_usedAnyPct];
}

getUsedTAS()
{
    return self.statistics[level.statisticsStrings_usedTAS];
}
