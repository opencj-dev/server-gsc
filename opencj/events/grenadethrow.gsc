#include openCJ\util;

main(nade, name)
{
	nade hide();
	nade showToPlayer(self);

	if(self openCJ\weapons::isGrenade(name))
	{
		self openCJ\weapons::onGrenadeThrow(nade, name);
		self openCJ\grenadeTimers::onGrenadeThrow(nade, name);
		self openCJ\statistics::onGrenadeThrow(nade, name);
	}
	else
		nade delete();
}