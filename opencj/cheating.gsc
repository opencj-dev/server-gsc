#include openCJ\util;

// 'Cheating' in this context can be many things:
// - noclip
// - speedmode
// - teleport
// - a paused run


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
        }
        else
        {
            self openCJ\playerRuns::resumeRun();
        }
    }
}