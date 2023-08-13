#include openCJ\util;

main(nade, name)
{
    nade hide();
    nade showToPlayer(self);

    if(self openCJ\weapons::isGrenade(name) && self isPlayerReady() && !self openCJ\demos::isPlayingDemo())
    {
        self openCJ\weapons::onGrenadeThrow(nade, name);
        self openCJ\huds\hudGrenadeTimers::onGrenadeThrow(nade, name);
        self openCJ\statistics::onGrenadeThrow(nade, name);
    }
    else
        nade delete();
}