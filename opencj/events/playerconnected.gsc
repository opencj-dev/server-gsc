#include openCJ\util;

main()
{
	self openCJ\login::onPlayerConnected();
	self openCJ\country::onPlayerConnected();
	self openCJ\events\spawnSpectator::main();
}