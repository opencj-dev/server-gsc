#include openCJ\util;

main()
{
	if(!self openCJ\login::isLoggedIn() || !self openCJ\playerRuns::hasRunID())
		return;

	self notify("spawned");

	resetTimeout();

	self.sessionTeam = "allies";
	self.sessionState = "playing";
	self.spectatorClient = -1;
	self.archiveTime = 0;
	self.psOffsetTime = 0;
	self.pers["team"] = "allies";

	spawnpoint = self openCJ\spawnpoints::getPlayerSpawnpoint();
	self spawn(spawnpoint.origin, spawnpoint.angles);

	self openCJ\savePosition::onSpawnPlayer();
	self openCJ\playerRuns::onSpawnPlayer();

	self setSharedSpawnVars();

	self thread openCJ\events\whileAlive::main();

	self thread _dummy();
}

setSharedSpawnVars(giveRPG)
{
	if(!isDefined(giveRPG))
		giveRPG = false;
	self openCJ\healthRegen::resetHealthRegen();
	self openCJ\weapons::giveWeapons(giveRPG);
	self openCJ\shellShock::resetShellShock();
	self openCJ\grenadeTimers::removeNadeTimers();
	self openCJ\buttonPress::resetButtons();
	
	self openCJ\playerModels::setPlayerModel();
	
	self openCJ\statistics::resetAFKOrigin();
	self openCJ\checkpointPointers::onSpawnPlayer();

	if(getCvarInt("codversion") == 2)
		self setContents(256);
	else
	{
		self setPerk("specialty_fastreload");
		self setPerk("specialty_longersprint");
	}
	self jumpClearStateExtended();
	self openCJ\speedMode::applySpeedMode();
}

_dummy()
{
	waittillframeend;
	if(isDefined(self))
		self notify("spawned_player");
}