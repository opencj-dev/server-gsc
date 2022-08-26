#include openCJ\util;

main()
{
	self openCJ\vote::onPlayerDisconnect();
	self openCJ\commands::onPlayerDisconnect();
	self stopFollowingMe();
	self notify("disconnect");
}