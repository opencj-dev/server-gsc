#include openCJ\util;

onRunIDCreated()
{
	self.cheating = false;
}

isCheating()
{
	return self.cheating;
}

setCheating(isCheating)
{
    if (self.cheating != isCheating)
    {
		self.cheating = isCheating;
        if (self.cheating)
        {
		    self iPrintLnBold("You are cheating");
        }
        else
        {
            self iPrintLnBold("You are safe");
        }
        self openCJ\events\onCheatStatusChanged::main(self.cheating);
	}
}