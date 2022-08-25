#include openCJ\util;

main()
{
	self openCJ\login::onPlayerConnected();
	self openCJ\country::onPlayerConnected();
	self openCJ\infiniteHuds::onPlayerConnected();
	self openCJ\graphics::onPlayerConnected();
	self openCJ\events\spawnSpectator::main();
}