#include openCJ\util;

main()
{
    self openCJ\settings::onPlayerConnect();
    self openCJ\statistics::onPlayerConnect(); // Needs to be before hudStatistics
    self openCJ\playerRuns::onPlayerConnect();
    self openCJ\checkpointPointers::onPlayerConnect();
    self openCJ\showRecords::onPlayerConnect();
    self openCJ\country::onPlayerConnect();
    self openCJ\noclip::onPlayerConnect();
    self openCJ\huds\base::onPlayerConnect();
    self openCJ\huds\hudOnScreenKeyboard::onPlayerConnect();
    self openCJ\huds\hudGrenadeTimers::onPlayerConnect();
    self openCJ\huds\hudFps::onPlayerConnect();
    self openCJ\huds\hudFpsHistory::onPlayerConnect();
    self openCJ\huds\hudJumpSlowdown::onPlayerConnect();
    self openCJ\huds\hudSpeedometer::onPlayerConnect();
    self openCJ\huds\hudProgressBar::onPlayerConnect();
    self openCJ\huds\hudSpeedometer::onPlayerConnect();
    self openCJ\huds\hudPosition::onPlayerConnect();
    self openCJ\huds\hudTimeLimit::onPlayerConnect();
    self openCJ\huds\hudRunInfo::onPlayerConnect();
    self openCJ\events\onGroundChanged::onPlayerConnect();
    self openCJ\mapPatches::onPlayerConnect();
    self openCJ\demos::onPlayerConnect();
    self openCJ\playerNames::onPlayerConnect();
    self openCJ\chat::onPlayerConnect();
    self openCJ\playerCollision::onPlayerConnect();
    self openCJ\playTime::onPlayerConnect();
    self openCJ\events\eventHandler::onConnect();
    self openCJ\menus\ingame::onPlayerConnect();
    self openCJ\fps::onPlayerConnect();

    self player_onconnect();

    self thread _dummy();
    self waittill("begin");

    level notify("connected", self);

    self openCJ\events\playerConnected::main();
}

_dummy()
{
    waittillframeend;
    if(isDefined(self))
        level notify("connecting", self);
}