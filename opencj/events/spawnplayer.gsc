#include openCJ\util;

main()
{
	if(!self openCJ\login::isLoggedIn() || !self openCJ\playerRuns::hasRunID())
		return;

	printf("trying to spawn\n");
	self notify("spawned");

	resetTimeout();

	self.sessionTeam = "allies";
	self.sessionState = "playing";
	self.spectatorClient = -1;
	self.archiveTime = 0;
	self.psOffsetTime = 0;
	self.pers["team"] = "allies";

	error = self openCJ\savePosition::canLoadError(0);
	
	if(!error)
	{
		save = self openCJ\savePosition::getSavedPosition(0);
		self spawn(save.origin, save.angles);

		self openCJ\statistics::setRPGJumps(save.RPGJumps);
		self openCJ\statistics::setNadeJumps(save.nadeJumps);
		self openCJ\statistics::setDoubleRPGs(save.doubleRPGs);
		self openCJ\checkpoints::setCurrentCheckpointID(save.checkpointID);

		self openCJ\statistics::onLoadPosition();
	}
	else
	{
		spawnpoint = self openCJ\spawnpoints::getPlayerSpawnpoint();
		self spawn(spawnpoint.origin, spawnpoint.angles);
		self openCJ\checkpoints::setCurrentCheckpointID(undefined);
	}

	self openCJ\healthRegen::onSpawnPlayer();
	self openCJ\weapons::onSpawnPlayer();
	self openCJ\shellShocK::onSpawnPlayer();
	self openCJ\grenadeTimers::onSpawnPlayer();
	self openCJ\buttonPress::onSpawnPlayer();
	self openCJ\savePosition::onSpawnPlayer();
	self openCJ\playerModels::onSpawnPlayer();
	self openCJ\playerRuns::onSpawnPlayer();
	self openCJ\statistics::onSpawnPlayer();
	self openCJ\showRecords::onSpawnPlayer();
	self openCJ\checkpointPointers::onSpawnPlayer();

	if(getCvarInt("codversion") == 2)
		self setContents(256);
	else
	{
		self setPerk("specialty_fastreload");
		self setPerk("specialty_longersprint");
	}

	self thread openCJ\events\whileAlive::main();

	self thread _dummy();
}

_dummy()
{
	waittillframeend;
	if(isDefined(self))
		self notify("spawned_player");
}