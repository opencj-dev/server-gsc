#include openCJ\util;

main(time)
{
		if(isDefined(self.rpgTime) && self.rpgTime > time - 500)
		{
			if(time - self.rpgTime == 0)
			{
				self iprintlnSpectators("^6RPG was perfect");
			}
			else
			{
				//early rpg
				self iprintlnSpectators("^1Rpg was early by " + (time - self.rpgTime) + "ms");
			}
		}
		self.bounceTime = time;
    self openCJ\huds\hudFpsHistory::onBounced();
    self openCJ\events\eventHandler::onBounced();
}