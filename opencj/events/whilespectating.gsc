#include openCJ\util;

main()
{
    self endon("disconnect");
    self endon("spawned");

    while(self.sessionState == "spectator")
    {
        self openCJ\playerNames::whileSpectating();
        self openCJ\events\eventHandler::whileSpectating();
        self openCJ\huds\hudStatistics::whileSpectating();
        wait 0.05;
    }
}