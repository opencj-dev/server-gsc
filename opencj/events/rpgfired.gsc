#include openCJ\util;

main(rpg, name, time)
{
    rpg hide();
    rpg showToPlayer(self);
    
    if(self openCJ\weapons::isRPG(name))
    {
				if(isDefined(self.bounceTime) && self.bounceTime > time - 500)
				{
					//late rpg
					self iprintlnSpectators("^3RPG was late by " + (time - self.bounceTime) + "ms");
				}
				self.rpgTime = time;
        self openCJ\weapons::onRPGFired(rpg, name);
        self openCJ\statistics::onRPGFired(rpg, name);
        self  openCJ\events\eventHandler::onRPGFired(rpg, name);
    }
    else
    {
        rpg delete();
    }
}