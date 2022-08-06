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
		wait 0.05;
	}
}