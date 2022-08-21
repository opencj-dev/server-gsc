#include openCJ\util;

main()
{
	self thread openCJ\settings::onPlayerLogin(); // Executes queries
	self openCJ\playerRuns::onPlayerLogin();
	self openCJ\country::onPlayerLogin();
	self openCJ\menus::onPlayerLogin();
	self openCJ\chat::onPlayerLogin();
	self openCJ\playerNames::onPlayerLogin();
	self openCJ\vote::onPlayerLogin();
}