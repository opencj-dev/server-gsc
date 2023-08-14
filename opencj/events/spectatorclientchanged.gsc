#include openCJ\util;

main(newClient)
{
    self openCJ\showRecords::onSpectatorClientChanged(newClient);
    self openCJ\statistics::onSpectatorClientChanged(newClient);
    self openCJ\huds\hudStatistics::onSpectatorClientChanged(newClient);
    self openCJ\huds\hudOnScreenKeyboard::onSpectatorClientChanged(newClient);
    self openCJ\huds\hudFpsHistory::onSpectatorClientChanged(newClient);
    self openCJ\huds\hudFps::onSpectatorClientChanged(newClient);
    self openCJ\huds\hudRunInfo::onSpectatorClientChanged(newClient);
    self openCJ\huds\hudSpeedOMeter::onSpectatorClientChanged(newClient);
}