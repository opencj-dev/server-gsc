#include openCJ\util;

main()
{
	self notify("spawned");

	resetTimeout();

	self.sessionState = "spectator";
	self.sessionTeam = "spectator";
	self.spectatorClient = -1;
	self.archiveTime = 0;
	self.pers["team"] = "spectator";

	spawnpoint = self openCJ\spawnpoints::getSpectatorSpawnpoint();
	self spawn(spawnpoint.origin, (0, 0, 0));

	self openCJ\shellShock::resetShellShock();
	self openCJ\healthRegen::onSpawnSpectator();
	self openCJ\playerRuns::onSpawnSpectator();
	self openCJ\showRecords::onSpawnSpectator();
	self openCJ\checkpointPointers::onSpawnSpectator();
	self openCJ\noclip::disableNoclip();
	self openCJ\huds\hudProgressBar::onSpawnSpectator();
	self openCJ\huds\hudOnScreenKeyboard::onSpawnSpectator();
	self openCJ\huds\hudJumpSlowdown::onSpawnSpectator();
	self openCJ\huds\hudSpeedometer::onSpawnSpectator();
	self openCJ\huds\hudFpsHistory::onSpawnSpectator();
	self openCJ\huds\hudStatistics::onSpawnSpectator();
	self openCJ\events\eventHandler::onSpawnSpectator();

	self stopFollowingMe();

	self thread openCJ\events\whileSpectating::main();
}