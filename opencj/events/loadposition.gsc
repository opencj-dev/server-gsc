#include openCJ\util;

main(backwardsCount)
{
	if(!self openCJ\login::isLoggedIn() || !self openCJ\playerRuns::hasRunID())
		return;

	error = self openCJ\savePosition::canLoadError(backwardsCount);
	if(!error)
	{
		save = self openCJ\savePosition::getSavedPosition(backwardsCount);

		if(getCvarInt("codversion") == 4)
		{
			giveRPG = self openCJ\settings::getSetting("rpgonload") || openCJ\weapons::isRPG(self getCurrentWeapon());
		}
		else
		{
			giveRPG = false;
		}

		self openCJ\statistics::addTimeUntil(getTime() + (int(self getJumpSlowdownTimer() / 50) * 50)); //todo: make this flag-specific since disabling jump_slowdown should not give this delay, might already work baked-in to the function though

		if(self openCJ\cheating::isCheating() && !openCJ\savePosition::isCheating(save))
			self openCJ\cheating::safe();
		else if(!self openCJ\cheating::isCheating() && openCJ\savePosition::isCheating(save))
			self openCJ\cheating::cheat();

		self spawn(save.origin, save.angles);

		self openCJ\statistics::setRPGJumps(save.RPGJumps);
		self openCJ\statistics::setNadeJumps(save.nadeJumps);
		self openCJ\statistics::setDoubleRPGs(save.doubleRPGs);
		self openCJ\statistics::onLoadPosition();
		self openCJ\checkpoints::setCurrentCheckpointID(save.checkpointID); //does this also update checkpoint pointers?
		self openCJ\checkpoints::onLoadPosition();
		self openCJ\speedoMeter::onLoadPosition();


		//set speed mode vars here
		self openCJ\speedMode::setSpeedModeEver(openCJ\savePosition::hasSpeedModeEver(save));
		self openCJ\speedMode::setSpeedMode(openCJ\savePosition::hasSpeedModeNow(save));
		//set elevate override vars here
		self openCJ\elevate::setEleOverrideEver(openCJ\savePosition::getFlagEleOverrideEver(save));
		self openCJ\elevate::setEleOverrideNow(openCJ\savePosition::getFlagEleOverrideNow(save));
		//set hax/mix vars here
		self openCJ\fps::setHaxFPS(openCJ\savePosition::hasHaxFPS(save));
		if(self openCJ\fps::getCurrentFPS() != save.fps)
		{
			self openCJ\fps::setMixFPS(true);
		}
		else
		{
			self openCJ\fps::setMixFPS(openCJ\savePosition::hasMixFPS(save));
		}
		self openCJ\fps::onLoadPosition();

		self openCJ\events\spawnPlayer::setSharedSpawnVars(giveRPG);
		self openCJ\savePosition::printLoadSuccess();
		
		self openCJ\FPSHistory::onLoaded();

		return true;
	}
	else
	{
		self openCJ\savePosition::printCanLoadError(error);
		return false;
	}
}