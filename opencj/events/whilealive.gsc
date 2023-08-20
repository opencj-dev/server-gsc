#include openCJ\util;

main()
{
    self endon("disconnect");
    self endon("spawned");
    self endon("spawned_spectator");

    while(self.sessionState == "playing")
    {
        if(self openCJ\util::isPlayerReady(false))
        {
            if(self openCJ\demos::isPlayingDemo())
            {
                self openCJ\demos::whilePlayingDemo();
            }
            else
            {
                self thread openCJ\checkpoints::whileAlive(); // Has to do a significant loop, so thread this one
                self openCJ\showRecords::whileAlive();
                self openCJ\noclip::whileAlive();
                self openCJ\statistics::whileAlive();
                self openCJ\huds\hudStatistics::whileAlive();
                self openCJ\huds\hudOnScreenKeyboard::whileAlive();
                self openCJ\huds\hudJumpSlowdown::whileAlive();
                self openCJ\huds\hudTimeLimit::whileAlive();
                self openCJ\huds\hudRunInfo::whileAlive();
                self openCJ\huds\hudSpeedometer::whileAlive();
                self openCJ\playerNames::whileAlive();
                self openCJ\playTime::whileAlive();
                self openCJ\huds\hudPosition::whileAlive();

                self openCJ\platformDetect::whileAlive(); //debug file
                self openCJ\events\eventHandler::whileAlive();
            }
        }
        wait 0.05;
    }
}