#include openCJ\util;

main(time)
{
    self openCJ\huds\hudFpsHistory::onBounced();
    self openCJ\events\eventHandler::onBounced();
	self iprintln("Bounce flag was reset");
}