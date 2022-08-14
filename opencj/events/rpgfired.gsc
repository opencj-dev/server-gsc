#include openCJ\util;

main(rpg, name)
{
	rpg hide();
	rpg showToPlayer(self);
	
	if(self openCJ\weapons::isRPG(name))
	{
		printf("is rpg, calling onrpgfired\n");
		self openCJ\weapons::onRPGFired(rpg, name);
		self openCJ\statistics::onRPGFired(rpg, name);
	}
	else
	{
		printf("is not rpg, deleting\n");
		rpg delete();
	}
}