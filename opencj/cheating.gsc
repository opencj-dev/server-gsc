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
	self.cheating = true;
	self iPrintLnBold("You are cheating");
}

safe()
{
	self.cheating = false;
	self iPrintLnBold("You are safe");
}