#include openCJ\util;

hasAnyPct()
{
    if (isDefined(self.anyPct))
    {
        return self.anyPct;
    }
    return false;
}

setAnyPct(value)
{
    self.anyPct = value;
}

onRunCreated()
{
    // New run started, all any% things are not relevant anymore
    self.anyPct = false;
}

onRunRestored()
{
    // Restored run, any% will be set when loading a position with any% enabled
    self.anyPct = false;
}
