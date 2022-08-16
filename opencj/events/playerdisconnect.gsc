#include openCJ\util;

main()
{
	self openCJ\vote::onPlayerDisconnect();
	self stopFollowingMe();
	self player_onDisconnect();
	self notify("disconnect");
}