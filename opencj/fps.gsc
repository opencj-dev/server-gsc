#include openCJ\util;

// TODO: set safe FPS somewhere somehow

onInit()
{
    level.allowHaxStr = "allowhax";
    level.allowMixStr = "allowmix";
    underlyingCmd = openCJ\settings::addSettingBool(level.allowHaxStr, false, "Set whether hax fps is allowed. Usage: !hax [on/off]", ::_onSettingAllowHax);
    openCJ\commands_base::addAlias(underlyingCmd, "hax");
    underlyingCmd = openCJ\settings::addSettingBool(level.allowMixStr, true, "Set whether mix fps is allowed. Usage: !mix [on/off]", ::_onSettingAllowMix);
    openCJ\commands_base::addAlias(underlyingCmd, "mix");
}

onPlayerConnect()
{
    self.allowMix = false;
    self.allowHax = false;
}

_onSettingAllowHax(newVal)
{
    if (newVal)
    {
        self.allowHax = true;
    }
}

_onSettingAllowMix(newVal)
{
    if (newVal)
    {
        self.allowMix = true;
    }
}

onStopDemo()
{
    // TODO: implement after alpha
}

onRunStarted()
{
    // Start by forcing the most basic FPS, and 'upgrade' it when the user's current FPS is not allowed according to the mode
    self forceFPSMode("125");
    // Start with the player's setting. This may be updated based on their current FPS
    self.allowHax = self openCJ\settings::getSetting(level.allowHaxStr);
    self.allowMix = self openCJ\settings::getSetting(level.allowMixStr);

    // Initialize the player's FPS mode
    fps = self _getFPSFromUserInfo();
    if(!isDefined(fps))
    {
        fps = 1000;
        self setFPSMode("hax"); // No FPS available, play it safe
    }
    else
    {
        self setFPSMode(self getNewFPSModeStrByFPS(undefined, fps));
    }

    self.FPS = fps;
}

onRunRestored()
{
    currentFPSMode = self getCurrentFPSMode();
    isHax = (currentFPSMode == "hax");
    isMix = (currentFPSMode == "mix");
    self.allowHax = self openCJ\settings::getSetting(level.allowHaxStr);
    self.allowMix = self openCJ\settings::getSetting(level.allowMixStr);

    if (isHax && !self.allowHax)
    {
        self openCJ\settings::setSetting(level.allowHaxStr, true);
        self.allowHax = true;
    }
    if ((isHax || isMix) && !self.allowMix)
    {
        self openCJ\settings::setSetting(level.allowMixStr, true);
        self.allowMix = true;
    }
}

_getFPSFromUserInfo()
{
    return intOrUndefined(self getUserInfo("com_maxfps"));
}

onFPSChange(newFPS) // Not called with undefined FPS
{
    if (!isDefined(newFPS))
    {
        // FPS not found in user info
        newFPS = 1000; // Will result in hax
    }

    // FPS did not change
    if (isDefined(self.FPS) && (self.FPS == newFPS))
    {
        return;
    }

    // Let other scripts know that the FPS changed. Do this before changing the FPS mode, because that one might call setSafeFPS which will call onFPSChange as well
    openCJ\events\onFPSChanged::main(newFPS);
    self.FPS = newFPS;

    // Update the FPS mode. This may be accepted or prevented based on user settings.
    self setFPSMode(self getNewFPSModeStrByFPS(self getCurrentFPSMode(), newFPS));
}

forceFPSMode(newFPSMode) // For example called when restoring a previous load or when FPS is not present in UserInfo
{
    self _setFPSMode(newFPSMode, true); // force
}

setFPSMode(newFPSMode)
{
    self _setFPSMode(newFPSMode, false); // Don't force
}

_setFPSMode(newFPSMode, forced)
{
    // If player is not ready / no run started, FPS mode will be updated by onRunStarted
    if(!self isPlayerReady() || self openCJ\demos::isPlayingDemo())
    {
        return;
    }

    // No hax for CoD2
    if ((getCodVersion() == 2) && (newFPSMode == "hax"))
    {
        newFPSMode = "mix";
    }

    // FPS mode is forced when for example loading back
    if (!isDefined(forced) || !forced)
    {
        // If there was a previous FPS mode set, then let's determine what the new FPS mode should be
        if (isDefined(self.FPSMode))
        {
            // If FPS mode is hax, no new FPS mode can be set 
            if (!self _shouldFPSModeChange(self.FPSMode, newFPSMode))
            {
                // For example, we don't want to change the FPS mode to 125 if the user is now using 125 FPS but was using hax before
                return;
            }
        }
    }

    // Update this run's allowed FPS settings
    if (newFPSMode == "hax")
    {
        self.allowHax = true;
        self.allowMix = true;
    }
    else if (newFPSMode == "mix")
    {
        // Occurs for example on restoring position that did not allow hax. At that point it depends on user settings whether it is allowed or not
        self.allowHax = self openCJ\settings::getSetting(level.allowHaxStr);
        self.allowMix = true;
    }
    else
    {
        // Occurs for example on restoring position that did not allow hax. At that point it depends on user settings whether it is allowed or not
        self.allowHax = self openCJ\settings::getSetting(level.allowHaxStr);
        self.allowMix = self openCJ\settings::getSetting(level.allowMixStr);
    }

    self.FPSMode = newFPSMode;
}

_shouldFPSModeChange(currentFPSMode, newFPSMode)
{
    // Goal: given the current FPS mode and the new FPS, determine if the FPS mode should change
    // Example: 125 -> <haxFps>: mode changes to hax
    // Example: <haxFps> -> 125: mode does not change (because user already used hax)

    if (!isDefined(newFPSMode))
    {
        return false;
    }

    // User's settings may prevent this change
    if (self userSettingsPreventFPSMode(currentFPSMode, newFPSMode))
    {
        return false;
    }

    if (isDefined(currentFPSMode))
    {
        // FPS mode is unchanged
        if (newFPSMode == currentFPSMode)
        {
            return false;
        }

        // Now the tricky part. Goal: never "downgrade" the FPS mode.
        switch(currentFPSMode)
        {
            case "43":  return true; // 43 can only be "upgraded"
            case "76":  return ((newFPSMode == "125") || (newFPSMode == "mix") || (newFPSMode == "hax"));
            case "125": return ((newFPSMode == "mix") || (newFPSMode == "hax"));
            case "250": return ((newFPSMode == "333") || (newFPSMode == "mix"));
            case "333": return ((newFPSMode == "mix") || (newFPSMode == "hax"));
            case "mix": return (newFPSMode == "hax"); // Allow only upgrade from mix->hax
            case "hax": return false; // Never downgrade hax
        }
    }

    return false;
}

userSettingsPreventFPSMode(currentFPSMode, newFPSMode)
{
    if (!self openCJ\playerRuns::hasRunID() || self openCJ\playerRuns::isRunPaused() || self openCJ\playerRuns::isRunFinished())
    {
        return false;
    }

    if ((newFPSMode != "mix") && (newFPSMode != "hax"))
    {
        // User settings can (currently) only prevent mix or hax
        return false;
    }

    // If current FPS mode was already hax, then the settings don't matter
    if (currentFPSMode == "hax")
    {
        return false;
    }

    // When current FPS mode is mix and we're not switching to hax, settings don't matter either
    if ((currentFPSMode == "mix") && (newFPSMode != "hax"))
    {
        return false;
    }

    fpsTypeStr = "hax";
    if (newFPSMode == "mix")
    {
        fpsTypeStr = "mix";
    }

    allowThisFPSMode = undefined;
    if (fpsTypeStr == "hax")
    {
        allowThisFPSMode = self.allowHax;
    }
    else
    {
        allowThisFPSMode = self.allowMix;
    }

    if(!allowThisFPSMode)
    {
        // Load back upon hax/mix detection when the user doesn't allow it
        if(self openCJ\savePosition::canLoadError(0) == 0)
        {
            self iprintln("^5Prevented " + fpsTypeStr + " fps based on your settings");
            self setSafeFPS();

            // Force the player back to their load
            self openCJ\events\eventHandler::onLoadPositionRequest(0);

            return true; // Prevented!
        }
        else
        {
            // Allow because we have no other option
            self iprintlnbold("^1Detected " + fpsTypeStr + " fps, but failed to load back. Reset your run to clear!");
        }
    }

    return false; // No prevention
}

setSafeFPS()
{
    // Attempt to force user's FPS to 125 (safe value)
    self setClientCvar("com_maxfps", 125);
    self clearFPSFilter(); // No sampling over this value
    self onFPSChange(125);
}

getCurrentFPS()
{
    if(!isDefined(self.FPS))
    {
        return 1000; // Don't want to divide by zero...
    }

    return self.FPS;
}

getCurrentFPSMode()
{
    if (!isDefined(self.FPSMode))
    {
        // Not initialized yet
        return "125";
    }

    return self.FPSMode;
}

isMixAllowed()
{
    return (self.FPSMode == "hax" || self.FPSMode == "mix");
}

isHaxAllowed()
{
    return (self.FPSMode == "hax");
}

getShortFPS(fps) // For spectator FPS
{
    switch (fps)
    {
        case 125:  return "1";
        case 142:  return "4";
        case 167:  return "6";
        case 200:  return "0";
        case 250:  return "2";
        case 333:  return "3";
        case 500:  return "5";
        case 1000: return "K";
        default:   return "?";
    }
}

getNewFPSModeStrByFPS(currentFPSMode, newFPS)
{
    // Specific to CoD version
    if (getCodVersion() == 2)
    {
        // Handle the mix specific logic before
        if (isDefined(currentFPSMode))
        {
            newFPSStr = "" + newFPS;
            if (currentFPSMode != newFPSStr)
            {
                // This will work even if current FPS mode is mix
                return "mix";
            }
        }

        switch(newFPS)
        {
            case 43:  return "43";
            case 76:  return "76";
            case 125: return "125";
            case 250: return "250";
            case 333: return "333";
            default:  return "mix";
        }
    }
    else
    {
        switch(newFPS)
        {
            case 125: return "125";
            case 250: return "mix";
            case 333: return "mix";
            default:  return "hax";
        }
    }
}


// Converting back and forth between FPSMode server enum:

FPSModeToInt(str)
{
    if (getCodVersion() == 2)
    {
        switch(str)
        {
            case "43":  return 0;
            case "76":  return 1;
            case "125": return 2;
            case "250": return 3;
            case "333": return 4;
            default: // Fallthrough
            return 5; // Mix
        }
    }
    else
    {
        switch(str)
        {
            case "125": return 2;
            case "mix": return 5;
            default: // Fallthrough
            return 6; // Hax
        }
    }
}

FPSModeToString(val)
{
    switch(val) // fps mode enum in server code
    {
        case 0: return "43";
        case 1: return "76";
        case 2: return "125";
        case 3: return "250";
        case 4: return "333";
        case 5: return "mix";
        default: // Fallthrough
        case 6: return "hax";
    }
}