#include openCJ\util;

onRunCreated()
{
    self.cheating = false;
}

onRunRestored()
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
            self openCJ\playerRuns::pauseRun();
		    self iPrintLnBold("Run paused. Load back to resume.");
        }
        else
        {
            self iPrintLnBold("Run resumed");
            self openCJ\playerRuns::resumeRun();
        }
        self openCJ\events\onCheatStatusChanged::main(self.cheating);
	}
}