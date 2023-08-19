#include openCJ\util;

main(atLastSavedPosition)
{
    if(!self openCJ\login::isLoggedIn())
    {
        return;
    }

    self openCJ\noclip::disableNoclip();

    self notify("spawned");

    resetTimeout();
    self.sessionTeam = "allies";
    self.sessionState = "playing";
    self.spectatorClient = -1;
    self.archiveTime = 0;
    self.psOffsetTime = 0;
    self.pers["team"] = "allies";
    spawnpoint = self openCJ\spawnpoints::getPlayerSpawnpoint();
    self unlink();
    self spawn(spawnpoint.origin, spawnpoint.angles);

    self openCJ\savePosition::onSpawnPlayer();
    self openCJ\playerRuns::onSpawnPlayer();
    self openCJ\checkpoints::onSpawnPlayer();
    self openCJ\showRecords::onSpawnPlayer();
    self openCJ\huds\hudOnScreenKeyboard::onSpawnPlayer();
    self openCJ\huds\hudJumpSlowdown::onSpawnPlayer();
    self openCJ\huds\hudProgressBar::onSpawnPlayer();
    self openCJ\huds\hudSpeedometer::onSpawnPlayer();
    self openCJ\huds\hudGrenadeTimers::onSpawnPlayer();
    self openCJ\huds\hudFpsHistory::onSpawnPlayer();
    self openCJ\huds\hudFps::onSpawnPlayer();
    self openCJ\huds\hudPosition::onSpawnPlayer();
    self openCJ\huds\hudRunInfo::onSpawnPlayer();
    self openCJ\events\eventHandler::onSpawnPlayer();
    self openCJ\statistics::onSpawnPlayer();
    self openCJ\huds\hudStatistics::onSpawnPlayer();

    self setSharedSpawnVars(false, true);
    self thread openCJ\events\whileAlive::main();
    self thread _dummy();

    // Set player at last saved position if requested
    if (isDefined(atLastSavedPosition) && atLastSavedPosition)
    {
        self openCJ\events\eventHandler::onLoadPositionRequest(0);
    }
}

setSharedSpawnVars(giveRPG, isSpawn)
{
    self openCJ\healthRegen::resetHealthRegen();
    self openCJ\weapons::giveWeapons(giveRPG, isSpawn);
    self openCJ\weapons::setWeaponSpread();
    self openCJ\shellShock::resetShellShock();
    self openCJ\huds\hudGrenadeTimers::removeNadeTimers();
    self openCJ\buttonPress::resetButtons();

    self openCJ\playerModels::setPlayerModel();

    self openCJ\playtime::setAFK(false);
    self openCJ\checkpointPointers::showCheckpointPointers();

    if(getCodVersion() == 2)
        self setContents(256);
    else
    {
        self setperk("specialty_fastreload");
        self setPerk("specialty_longersprint");
    }
    self jumpClearStateExtended();
    self openCJ\speedMode::applySpeedMode();
    self openCJ\elevate::updateServerEleOverride();
    self openCJ\huds\hudFpsHistory::hideAndClearFPSHistory();
}

_dummy()
{
    waittillframeend;
    if(isDefined(self))
        self notify("spawned_player");
}

setDemoSpawnVars(giveRPG)
{
    self openCJ\weapons::giveWeapons(giveRPG);
    self openCJ\shellShock::resetShellShock();

    self openCJ\playerModels::setPlayerModel();

    if(getCodVersion() == 2)
        self setContents(256);
    else
    {
        self setperk("specialty_fastreload");
        self setPerk("specialty_longersprint");
    }
    self jumpClearStateExtended();
}