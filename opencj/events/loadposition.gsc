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
			giveRPG = self openCJ\settings::setting_get("rpgtweak") && openCJ\savePosition::hasRPG(save);
		else
			giveRPG = false;

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

		//set speed mode vars here
		self openCJ\speedMode::setSpeedModeEver(openCJ\savePosition::hasSpeedModeEver(save));
		self openCJ\speedMode::setSpeedMode(openCJ\savePosition::hasSpeedMode(save));
		//set elevate override vars here
		self openCJ\elevate::setElevateOverrideEver(openCJ\savePosition::hasElevateOverrideEver(save));
		self openCJ\elevate::setElevateOverride(openCJ\savePosition::hasElevateOverride(save));

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