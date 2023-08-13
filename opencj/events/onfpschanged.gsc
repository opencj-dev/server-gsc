main(newFPS)
{
    self openCJ\huds\hudFpsHistory::onFPSChanged(newFPS);
    self openCJ\huds\hudFps::onFPSChanged(newFPS);
}