#include openCJ\util;

main()
{
	self endon("disconnect");
	self endon("spawned");

	while(self.sessionState == "playing" || (isDefined(self.playing) && self.playing))
	{
		self openCJ\statistics::whileAlive();
		self openCJ\checkpoints::whileAlive();
		self openCJ\showRecords::whileAlive();
		self openCJ\noclip::whileAlive();
		self openCJ\onscreenKeyboard::whileAlive();
		self openCJ\huds::whileAlive();
		wait 0.05;
	}
}