#include openCJ\util;

main(rpg, name)
{
    rpg hide();
    rpg showToPlayer(self);
    
    if(self openCJ\weapons::isRPG(name))
    {
        self openCJ\weapons::onRPGFired(rpg, name);
        self openCJ\statistics::onRPGFired(rpg, name);
        self  openCJ\events\eventHandler::onRPGFired(rpg, name);
    }
    else
    {
        rpg delete();
    }
}