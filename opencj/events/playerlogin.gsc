#include openCJ\util;

main()
{
	self iprintlnbold("Login completed");
	printf("login completed\n\n");

	self openCJ\playerRuns::onPlayerLogin();
	self openCJ\commands::onPlayerLogin();
	self openCJ\country::onPlayerLogin();
	self openCJ\menus::onPlayerLogin();
	self openCJ\chat::onPlayerLogin();
	self openCJ\playerNames::onPlayerLogin();
	self openCJ\vote::onPlayerLogin();
}