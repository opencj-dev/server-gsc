#include openCJ\util;

onInit()
{
	openCJ\commands::registerCommand("elevateoverride", "Used to enable/disable elevate override\nUsage: !elevateoverride [on/off]", ::elevateOverride);
}

elevateOverride(args)
{
	value = args[2];
	if(value == "on" || value == "off")
	{
		self setElevateOverride(value == "on");
		self applyElevateOverride();
	}
	else
		self iprintln(level.commands_commands[args[1]].help);
}

onRunIDCreated()
{
	self.elevateOverride = undefined;
	self.elevateOverrideEver = false;
	self setElevateOverride(false);
}

setElevateOverrideEver(value)
{
	self.elevateOverrideEver = value;
}

setElevateOverride(value)
{
	if(isDefined(self.elevateOverride) && value == self.elevateOverride)
		return;
	self.elevateOverride = value;
	if(self.elevateOverride)
		self.elevateOverrideEver = true;
}

applyElevateOverride()
{
	if(self.elevateOverride)
		self allowElevate(true);
	else if(self openCJ\playerRuns::isRunFinished())
		self allowElevate(true);
	else if(isDefined(self openCJ\checkpoints::getCheckpoint()) && openCJ\checkpoints::isElevateAllowed(self openCJ\checkpoints::getCheckpoint()))
		self allowElevate(true);
	else
		self allowElevate(false);
}

onRunFinished(cp)
{
	self applyElevateOverride();
}

onCheckpointsChanged()
{
	self applyElevateOverride();
}

hasElevateOverride()
{
	return self.elevateOverride;
}

hasElevateOverrideEver()
{
	return self.elevateOverrideEver;
}

onElevate()
{
	if(self.elevateOverride || self openCJ\playerRuns::isRunFinished() || (isDefined(self openCJ\checkpoints::getCheckpoint()) && openCJ\checkpoints::isElevateAllowed(self openCJ\checkpoints::getCheckpoint())))
		return;
	else
	{
		if(!isDefined(self.elevateWarning) || self.elevateWarning < getTime() - 2000)
		{
			self.elevateWarning = getTime();
			self iprintlnbold("You are trying to elevate. This is not enabled. Please load back, or use !elevateoverride to enable the elevator");
		}
	}
}