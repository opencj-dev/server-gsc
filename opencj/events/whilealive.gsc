#include openCJ\util;

main()
{
	self endon("disconnect");
	self endon("spawned");

	while(self.sessionState == "playing")
	{
		if(self openCJ\util::isPlayerReady())
		{
			if(self openCJ\demos::isPlayingDemo())
			{
				self openCJ\demos::whilePlayingDemo();
			}
			else
			{
				self openCJ\statistics::whileAlive();
				self openCJ\checkpoints::whileAlive();
				self openCJ\showRecords::whileAlive();
				self openCJ\noclip::whileAlive();
				self openCJ\onscreenKeyboard::whileAlive();
				self openCJ\huds::whileAlive();
				self openCJ\playerNames::whileAlive();
				self openCJ\platformDetect::whileAlive(); //debug file
			}
		}
		wait 0.05;
	}
}