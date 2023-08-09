#include openCJ\util;

main(backwardsCount)
{
	if(!self openCJ\login::isLoggedIn() || !self openCJ\playerRuns::hasRunID())
	{
		return undefined;
	}

    save = self openCJ\savePosition::getSavedPosition(backwardsCount);

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

	// Set FPSMode. If save had non-hax non-mix, then the FPS mode should depend on the user's current FPS instead
    if ((save.FPSMode == "hax") || (save.FPSMode == "mix"))
    {
        self openCJ\fps::forceFPSMode(save.FPSMode);
    }
    else
    {
        self openCJ\fps::forceFPSMode(self openCJ\fps::getNewFPSModeStrByFPS(save.FPSMode, self openCJ\fps::getCurrentFPS()));
    }

    // TODO: implement any%

	self openCJ\events\spawnPlayer::setSharedSpawnVars(giveRPG);
	self openCJ\savePosition::printLoadSuccess();
	
	self openCJ\huds\hudFpsHistory::onLoaded();
	return save.saveNum;
}