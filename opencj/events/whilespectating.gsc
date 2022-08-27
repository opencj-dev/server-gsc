#include openCJ\util;

main()
{
	self endon("disconnect");
	self endon("spawned");

	while(self.sessionState == "spectator")
	{
		self openCJ\playerNames::whileSpectating();
		wait 0.05;
	}
}