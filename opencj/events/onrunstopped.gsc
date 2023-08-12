main()
{
    self openCJ\playTime::pauseTimer();
    self openCJ\statistics::onRunStopped();
    self openCJ\checkpointPointers::onRunStopped();
    self openCJ\huds\hudStatistics::onRunStopped();
    self openCJ\huds\hudRunInfo::onRunStopped();
    self openCJ\huds\hudProgressBar::onRunStopped();
    self openCJ\showRecords::onRunStopped();
}