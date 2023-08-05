#include openCJ\util;

main()
{
	self openCJ\login::onPlayerConnected();
	self openCJ\country::onPlayerConnected();
	self openCJ\huds\infiniteHuds::onPlayerConnected();
	self openCJ\graphics::onPlayerConnected();
    self openCJ\endMapVote::onPlayerConnected();
    self openCJ\leaderBoard::onPlayerConnected();

	self openCJ\events\spawnSpectator::main();
}