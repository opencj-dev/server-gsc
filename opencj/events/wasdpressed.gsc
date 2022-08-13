#include openCJ\util;

main()
{
	if(self.WASDCallback)
		self openCJ\playerRuns::startRun();
}

enableWASDCallback()
{
	self.WASDCallback = true;
}

disableWASDCallback()
{
	self.WASDCallback = false;
}