#include openCJ\util;

onInit()
{
    underlyingCmd = openCJ\settings::addSettingBool("allowele", false, "Used to (dis)allow elevators. Usage: !ele [on/off]", ::_onSettingAllowEle);
    openCJ\commands_base::addAlias(underlyingCmd, "ele");
}

_onSettingAllowEle(shouldEnable)
{
    wasEverEnabled = self hasEleOverrideEver();
    wasEnabled = self hasEleOverrideNow();

    if(shouldEnable && !wasEnabled)
    {
        self setEleOverrideNow(true);
        self updateServerEleOverride();
    }
    else if(!shouldEnable && wasEnabled)
    {
        if (wasEverEnabled)
        {
            self sendLocalChatMessage("Your run allows elevators so load back to before they were enabled or !reset your run", true);
        }
    }
}

onRunCreated()
{
    self.eleOverrideNow = false;
    self.eleOverrideEver = false;
    self.eleBypass = false;
    self updateServerEleOverride();
}

onRunStarted()
{
    self setEleOverrideNow(self openCJ\settings::getSetting("allowele"));
    self.eleBypass = false;
    self updateServerEleOverride();
}

onCheckpointsChanged()
{
    // Checkpoint changed, maybe the next one allows an elevator to be used
    self updateServerEleOverride();
}

setEleOverrideEver(value)
{
    self.eleBypass = false;
    self.eleOverrideEver = value;
}

setEleOverrideNow(value)
{
    // Always disable the ele bypass that may be in use for paused runs
    self.eleBypass = false;

    // If value is already the same, we're done here
    if(isDefined(self.eleOverrideNow) && (value == self.eleOverrideNow))
    {
        return;
    }

    self.eleOverrideNow = value;

    if(self.eleOverrideNow)
    {
        self.eleOverrideEver = true;
    }
}

hasEleOverrideNow()
{
    if (!isDefined(self.eleOverrideNow))
    {
        return false;
    }
    return self.eleOverrideNow;
}

hasEleOverrideEver()
{
    if (!isDefined(self.eleOverrideEver))
    {
        return false;
    }
    return self.eleOverrideEver;
}

updateServerEleOverride() // Send allowElevate status to server code
{
    if(self.eleOverrideNow)
    {
        // Eles are enabled for this save
        self allowElevate(true);
    }
    else if(self openCJ\playerRuns::isRunFinished())
    {
        // Not in a run anymore, so allow elevators
        self allowElevate(true);
    }
    else if(self _isEleAllowedThisCheckpoint())
    {
        // This checkpoint allows elevators to be used to reach it
        self allowElevate(true);
    }
    else
    {
        // Elevators are not allowed
        self allowElevate(false);
    }
}

onElevate()
{
    if (!self openCJ\playerRuns::hasRunID() || self openCJ\playerRuns::isRunPaused() || self openCJ\playerRuns::isRunFinished() || self openCJ\cheating::isCheating())
    {
        if (!isDefined(self.eleBypass) || !self.eleBypass)
        {
            self.eleBypass = true;
            self allowElevate(true);
        }
        // No problem if player is not in a run or has their run paused/finished
        return;
    }
    if(self.eleOverrideNow || self _isEleAllowedThisCheckpoint() || self openCJ\demos::isPlayingDemo())
    {
        // This elevator is allowed
        return;
    }

    self iprintlnbold("Elevator detected, but your run doesn't allow them");
    self iprintlnbold("Load back, or use !ele and save to allow elevators");
}

_isEleAllowedThisCheckpoint()
{
    return (isDefined(self openCJ\checkpoints::getCurrentCheckpoint()) && openCJ\checkpoints::isEleAllowed(self openCJ\checkpoints::getCurrentCheckpoint()));
}
