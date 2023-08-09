#include openCJ\util;

onInit()
{
    cmd = openCJ\commands_base::registerCommand("hardtas", "Used to set current run as hard TAS (bot). Usage: !hardtas [on/off]", ::_onCommandHardTAS, 0, 1, 0);

    // TODO: soft TAS
}

_onCommandHardTAS(args)
{
    if (!self openCJ\playerRuns::hasRunID())
    {
        self sendLocalChatMessage("This command can only be used during a run");
        return;
    }

    wasEnabled = self hasHardTAS();
    shouldEnable = false;
    if(!isDefined(args) || (args.size == 0))
    {
        shouldEnable = !wasEnabled;
    }
    else
    {
        if(!isValidBool(args[0]))
        {
            self sendLocalChatMessage("Argument " + args[0] + " is not a bool", true);
            return;
        }
        shouldEnable = strToBool(args[0]);
    }

    if(shouldEnable && !wasEnabled)
    {
        self setHardTAS(true);
        runID = self openCJ\playerRuns::getRunID();
        self sendLocalChatMessage("Your current run (" + runID + ") has now been marked as hard TAS.");
    }

    if (!shouldEnable && wasEnabled)
    {
        self sendLocalChatMessage("You can't disable TAS during a run. Every run starts without hard TAS enabled.");
    }
}

hasHardTAS()
{
    return self.hardTAS;
}

setHardTAS(value)
{
    self.hardTAS = value;
}

onRunIDCreated()
{
    // New run started, all TAS things are not relevant anymore
    self.hardTAS = false;
}

onRunFinished(cp)
{
    // Run is finished, so not in run... allow TAS
    self.hardTAS = false;
}
