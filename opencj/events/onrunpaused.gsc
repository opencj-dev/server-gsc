// Pausing a run is done upon request of player, for example when using !pauserun, noclip/ufo, speedmode

main()
{
    self openCJ\playTime::pauseTimer();
    self openCJ\huds\hudRunInfo::onRunPaused();
    self openCJ\huds\hudProgressBar::onRunPaused();
}