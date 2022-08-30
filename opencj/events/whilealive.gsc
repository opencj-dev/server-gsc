#include openCJ\util;

main()
{
	self endon("disconnect");
	self endon("spawned");

	while(self.sessionState == "playing")
	{
		self openCJ\statistics::whileAlive();
		self openCJ\checkpoints::whileAlive();
		self openCJ\showRecords::whileAlive();
		self openCJ\noclip::whileAlive();
		self openCJ\onscreenKeyboard::whileAlive();
		self openCJ\huds::whileAlive();
		self openCJ\playerNames::whileAlive();
		self openCJ\demos::whileAlive();
		self openCJ\playTime::whileAlive();

		self openCJ\platformDetect::whileAlive(); //debug file

		wait 0.05;
	}
}