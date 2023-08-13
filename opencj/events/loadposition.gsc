#include openCJ\util;

main(backwardsCount)
{
    if (self.sessionState != "playing")
    {
        return;
    }

    if(!self openCJ\login::isLoggedIn())
    {
        return undefined;
    }

    save = self openCJ\savePosition::getSavedPosition(backwardsCount);
    if (!isDefined(save))
    {
        self iprintln("^1Could not load position");
        return undefined;
    }

    if(getCodVersion() == 4)
    {
        giveRPG = (self openCJ\settings::getSetting("rpgonload") && self openCJ\savePosition::hasRPG(save)) || openCJ\weapons::isRPG(self getCurrentWeapon());
    }
    else
    {
        giveRPG = false;
        self openCJ\playTime::addTimeUntil(getTime() + (int(self getJumpSlowdownTimer() / 50) * 50)); //todo: make this flag-specific since disabling jump_slowdown should not give this delay, might already work baked-in to the function though
    }

    // Cheating
    if(self openCJ\cheating::isCheating() && !openCJ\savePosition::isCheating(save))
    {
        self openCJ\cheating::setCheating(false);
    }
    else if(!self openCJ\cheating::isCheating() && openCJ\savePosition::isCheating(save))
    {
        self openCJ\cheating::setCheating(true);
    }

    // Spawn the player
    self unlink();
    self spawn(save.origin, save.angles);

    self openCJ\statistics::setExplosiveJumps(save.explosiveJumps);
    self openCJ\statistics::setDoubleExplosives(save.doubleExplosives);
    self openCJ\statistics::onLoadPosition();
    self openCJ\checkpoints::setCurrentCheckpointID(save.checkpointID);
    self openCJ\checkpoints::onLoadPosition();
    self openCJ\huds\hudSpeedometer::onLoadPosition();

    // Set speed mode
    self openCJ\speedMode::setSpeedModeEver(openCJ\savePosition::hasSpeedModeEver(save));
    self openCJ\speedMode::setSpeedMode(openCJ\savePosition::hasSpeedModeNow(save));

    // Set elevator
    self openCJ\elevate::setEleOverrideEver(openCJ\savePosition::getFlagEleOverrideEver(save));
    self openCJ\elevate::setEleOverrideNow(openCJ\savePosition::getFlagEleOverrideNow(save));

    // Set hard TAS
    self openCJ\tas::setHardTAS(openCJ\savePosition::getUsedHardTAS(save));

    // Set FPSMode. If save had non-hax non-mix, then the FPS mode should depend on the user's current FPS instead`
    currFPS = self openCJ\fps::getCurrentFPS();
    newFPSMode = self openCJ\fps::getNewFPSModeStrByFPS(save.FPSMode, currFPS);
    // We first force the save FPS mode, and then try to set new FPS mode based on the user's current FPS
    // This is to prevent the user from loading with hax and keeping mix, for example
    // But it will still properly try to load the player back if their settings disallow hax but they had previously used hax during noclip, for example
    self openCJ\fps::forceFPSMode(save.FPSMode);
    self openCJ\fps::setFPSMode(newFPSMode);

    // TODO: implement any%

    self openCJ\events\spawnPlayer::setSharedSpawnVars(giveRPG);
    self openCJ\savePosition::printLoadSuccess();
    
    self openCJ\huds\hudFpsHistory::onLoaded();
    return save.saveNum;
}