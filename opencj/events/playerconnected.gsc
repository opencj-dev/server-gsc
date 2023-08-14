#include openCJ\util;

main()
{
    self openCJ\login::onPlayerConnected();
    self openCJ\country::onPlayerConnected();
    self openCJ\huds\infiniteHuds::onPlayerConnected();
    self openCJ\graphics::onPlayerConnected();
    self openCJ\menus\endMapVote::onPlayerConnected();
    self openCJ\menus\board_base::onPlayerConnected();
    self openCJ\huds\hudStatistics::onPlayerConnected();

    self openCJ\events\spawnSpectator::main();
}