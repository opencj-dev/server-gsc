#include openCJ\util;

main(time)
{
    self thread openCJ\FPSHistory::onBounced();
	self iprintln("You bounced!");
}