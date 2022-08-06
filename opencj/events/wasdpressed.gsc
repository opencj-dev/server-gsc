#include openCJ\util;

main()
{
	if(self.WASDCallback)
		self openCJ\playerRuns::onWASDPressed();
}

enableWASDCallback()
{
	self.WASDCallback = true;
}

disableWASDCallback()
{
	self.WASDCallback = false;
}