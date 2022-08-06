#include openCJ\util;

main()
{
	self iprintlnbold("Login completed");
	printf("login completed\n\n");

	self openCJ\playerRuns::onPlayerLogin();
	self openCJ\commands::onPlayerLogin();
	self openCJ\country::onPlayerLogin();
}