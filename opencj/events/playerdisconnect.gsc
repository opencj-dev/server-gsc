#include openCJ\util;

main()
{
	self openCJ\events\eventHandler::onPlayerDisconnect();
	self openCJ\vote::onPlayerDisconnect();
	self openCJ\commands::onPlayerDisconnect();
	self stopFollowingMe();
	self notify("disconnect");
}