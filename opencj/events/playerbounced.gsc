#include openCJ\util;

main(time)
{
    self openCJ\FPSHistory::onBounced();
    self openCJ\events\eventHandler::onBounced();
	self iprintln("You bounced!");
}