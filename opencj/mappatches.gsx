#include openCJ\util;

onInit()
{
    precacheShader("white");
    precacheShader("black");
    level.splitScreen = false;
    maps\mp\gametypes\_hud::init();
    maps\mp\gametypes\_hud_message::init();
}

onPlayerConnect()
{
    self.doingNotify = false;
}