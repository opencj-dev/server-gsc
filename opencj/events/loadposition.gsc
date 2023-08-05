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
		giveRPG = self openCJ\settings::getSetting("rpgonload") || openCJ\weapons::isRPG(self getCurrentWeapon());
	}
	else
	{
		giveRPG = false;
		self openCJ\playTime::addTimeUntil(getTime() + (int(self getJumpSlowdownTimer() / 50) * 50)); //todo: make this flag-specific since disabling jump_slowdown should not give this delay, might already work baked-in to the function though
	}

	if(self openCJ\cheating::isCheating() && !openCJ\savePosition::isCheating(save))
	{
		self openCJ\cheating::setCheating(false);
	}
	else if(!self openCJ\cheating::isCheating() && openCJ\savePosition::isCheating(save))
	{
		self openCJ\cheating::setCheating(true);
	}

	self spawn(save.origin, save.angles);

	self openCJ\statistics::setExplosiveJumps(save.explosiveJumps);
	self openCJ\statistics::setExplosiveLaunches(save.explosiveLaunches);
	self openCJ\statistics::setDoubleExplosives(save.doubleExplosives);
	self openCJ\statistics::onLoadPosition();
	self openCJ\checkpoints::setCurrentCheckpointID(save.checkpointID);
	self openCJ\checkpoints::onLoadPosition();
	self openCJ\huds\hudSpeedometer::onLoadPosition();


	//set speed mode vars here
	self openCJ\speedMode::setSpeedModeEver(openCJ\savePosition::hasSpeedModeEver(save));
	self openCJ\speedMode::setSpeedMode(openCJ\savePosition::hasSpeedModeNow(save));
	//set elevate override vars here
	self openCJ\elevate::setEleOverrideEver(openCJ\savePosition::getFlagEleOverrideEver(save));
	self openCJ\elevate::setEleOverrideNow(openCJ\savePosition::getFlagEleOverrideNow(save));
	//set hax/mix vars here
	self openCJ\fps::setUsedHaxFPS(openCJ\savePosition::hasHaxFPS(save));
	if(self openCJ\fps::getCurrentFPS() != save.fps)
	{
		self openCJ\fps::setUsedMixFPS(true);
	}
	else
	{
		self openCJ\fps::setUsedMixFPS(openCJ\savePosition::hasMixFPS(save));
	}

    // Any% and TAS not supported yet

	self openCJ\events\spawnPlayer::setSharedSpawnVars(giveRPG);
	self openCJ\savePosition::printLoadSuccess();
	
	self openCJ\huds\hudFpsHistory::onLoaded();
	return save.saveNum;
}