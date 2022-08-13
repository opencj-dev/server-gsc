#include openCJ\util;

onInit()
{
	openCJ\commands::registerCommand("noclip", "Enables/disables noclip", ::noclip);
}

onPlayerConnect()
{
	self.noclip = false;
}

onRunIDCreated()
{
	self disableNoclip();
}

noclip(args)
{
	if(self hasNoclip())
		self disableNoclip();
	else
		self enableNoclip();
}

hasNoclip()
{
	return self.noclip;
}

disableNoclip()
{
	if(isDefined(self.noclip_linkto))
		self.noclip_linkto delete();
	if(self hasNoclip())
	{
		self.noclip = false;
		self unlink();
	}
}

enableNoclip()
{
	if(isDefined(self.noclip_linkto))
		self.noclip_linkto delete();
	self.noclip = true;
	self openCJ\cheating::cheat();
	self openCJ\playerRuns::startRun();
	self.noclip_linkto = spawn("script_origin", self.origin);
	self.noclip_linkto thread deleteOnEvent("disconnect", self);
	self linkto(self.noclip_linkto);
}

whileAlive()
{
	if(!self hasNoclip())
		return;
	dir = (0, 0, 0);
	if(self rightButtonPressed())
		dir += anglesToRight(self getPlayerAngles());
	if(self leftButtonPressed())
		dir -= anglesToRight(self getPlayerAngles());
	if(self forwardButtonPressed())
		dir += anglesToForward(self getPlayerAngles());
	if(self backButtonPressed())
		dir -= anglesToForward(self getPlayerAngles());
	if(self leanRightButtonPressed())
		dir += anglesToUp(self getPlayerAngles());
	if(self leanLeftButtonPressed())
		dir -= anglesToUp(self getPlayerAngles());
	self.noclip_linkto.origin += vectorScale(dir, 20);
	printf("moving noclip to : " + dir + "\n");
}