#include openCJ\util;

main()
{
    self openCJ\saveposition::onRunCreated();
    self openCJ\tas::onRunCreated();
    self openCJ\weapons::onRunCreated();
    self openCJ\statistics::onRunCreated();
    self openCJ\healthRegen::onRunCreated();
    self openCJ\shellShock::onRunCreated();
    self openCJ\checkpoints::onRunCreated();
    self openCJ\showRecords::onRunCreated();
    self openCJ\cheating::onRunCreated();
    self openCJ\checkpointPointers::onRunCreated();
    self openCJ\speedMode::onRunCreated();
    self openCJ\noclip::onRunCreated();
    self openCJ\elevate::onRunCreated();
    self openCJ\fps::onRunCreated();
    self openCJ\playTime::onRunCreated();
    self openCJ\huds\hudRunInfo::onRunCreated();
    self openCJ\huds\hudStatistics::onRunCreated();

    self openCJ\events\spawnPlayer::main();
}