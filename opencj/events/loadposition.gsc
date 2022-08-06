#include openCJ\util;

main(backwardsCount)
{
	if(!self openCJ\login::isLoggedIn() || !self openCJ\playerRuns::hasRunID())
		return;

	error = self openCJ\savePosition::canLoadError(backwardsCount);
	if(!error)
	{
		save = self openCJ\savePosition::getSavedPosition(backwardsCount);

		if(self openCJ\weapons::isRPG(self getCurrentWeapon()))
			giveRPG = true;
		else
			giveRPG = false;

		self openCJ\statistics::addTimeUntil(getTime() + (int(self getJumpSlowdownTimer() / 50) * 50));

		if(self openCJ\cheating::isCheating() && !openCJ\savePosition::isCheating(save))
			self openCJ\cheating::safe();
		else if(!self openCJ\cheating::isCheating() && openCJ\savePosition::isCheating(save))
			self openCJ\cheating::cheat();

		self spawn(save.origin, save.angles);
		self jumpClearStateExtended();

		self openCJ\statistics::setRPGJumps(save.RPGJumps);
		self openCJ\statistics::setNadeJumps(save.nadeJumps);
		self openCJ\statistics::setDoubleRPGs(save.doubleRPGs);
		self openCJ\checkpoints::setCurrentCheckpointID(save.checkpointID);

		self openCJ\healthRegen::onLoadPosition();
		self openCJ\weapons::onLoadPosition(giveRPG);
		self openCJ\shellShock::onLoadPosition();
		self openCJ\grenadeTimers::onLoadPosition();
		self openCJ\statistics::onLoadPosition();

		self openCJ\playerModels::onLoadPosition();

		if(getCvarInt("codversion") == 2)
			self setContents(256);
		else
		{
			self setPerk("specialty_fastreload");
			self setPerk("specialty_longersprint");
		}

		self openCJ\savePosition::printLoadSuccess();

		return true;
	}
	else
	{
		self openCJ\savePosition::printCanLoadError(error);
		return false;
	}
}