#include openCJ\util;

main()
{
    self openCJ\events\eventHandler::onPlayerDisconnect();
    self openCJ\vote::onPlayerDisconnect();
    self openCJ\commands::onPlayerDisconnect();
    self openCJ\menus\endMapVote::onPlayerDisconnect();
    self stopFollowingMe();
    self notify("disconnect");
}