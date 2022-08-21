#include openCJ\util;

main()
{
	self openCJ\vote::onPlayerDisconnect();
	self stopFollowingMe();
	self notify("disconnect");
}