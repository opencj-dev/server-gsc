main()
{
    self openCJ\FPS::onRunStarted();
    self openCJ\playTime::startTimer();
    self openCJ\statistics::onRunStarted();
    self openCJ\elevate::onRunStarted();
    self openCJ\fps::onRunStarted();
    self openCJ\showRecords::onRunStarted();
    self openCJ\huds\hudRunInfo::onRunStarted();
}