#include openCJ\util;

onRunIDCreated()
{
	self.cheating = false;
}

isCheating()
{
	return self.cheating;
}

cheat()
{
	if(!self.cheating)
	{
		self.cheating = true;
		self iPrintLnBold("You are cheating");
	}
}

safe()
{
	if(self.cheating)
	{
		self.cheating = false;
		self iPrintLnBold("You are safe");
	}
}