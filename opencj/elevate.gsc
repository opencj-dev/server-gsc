#include openCJ\util;

onInit()
{
	cmd = openCJ\commands_base::registerCommand("ele", "Used to (dis)allow elevators in current run\nUsage: !ele [on/off]", ::_onCommandEleOverride, 0, 1, 0);
	openCJ\commands_base::addAlias(cmd, "eleoverride");
	openCJ\commands_base::addAlias(cmd, "elevateoverride");
}

_onCommandEleOverride(args)
{
	wasEverEnabled = self hasEleOverrideEver();
	wasEnabled = self hasEleOverrideNow();
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
		self setEleOverrideNow(true);
		self _updateServerEleOverride();
		self sendLocalChatMessage("Your run now allows elevators. If you don't want this, load back to before you enabled elevators.");
	}
	else if(!shouldEnable && wasEnabled)
	{
		self setEleOverrideNow(false);
		self _updateServerEleOverride();
		self sendLocalChatMessage("Elevators have been turned off.");
		if (wasEverEnabled)
		{
			self sendLocalChatMessage("However, your run is still marked as elevators allowed due to one of your previous saves.");
			self sendLocalChatMessage("If you don't want this, use !eleload to load back to before elevators were allowed, or !reset to start a new run.");
		}
	}
}

onRunIDCreated()
{
	// New run started, all ele things are not relevant anymore
	self.eleOverrideNow = false;
	self.eleOverrideEver = false;
	self _updateServerEleOverride();
}

onSpawnPlayer()
{
	// If player spawns, server may not correctly know the right allowEle status
	self _updateServerEleOverride();
}

onRunFinished(cp)
{
	// Run is finished, so not in run... allow elevators
	self _updateServerEleOverride();
}

onCheckpointsChanged()
{
	// Checkpoint changed, maybe the next one allows an elevator to be used
	self _updateServerEleOverride();
}

setEleOverrideEver(value)
{
	self.eleOverrideEver = value;
}

setEleOverrideNow(value)
{
	// If value is already the same, we're done here
	if(isDefined(self.eleOverrideNow) && (value == self.eleOverrideNow))
	{
		return;
	}

	self.eleOverrideNow = value;

	if(self.eleOverrideNow)
	{
		self.eleOverrideEver = true;
	}
}

hasEleOverrideNow()
{
	return self.eleOverrideNow;
}

hasEleOverrideEver()
{
	return self.eleOverrideEver;
}

_updateServerEleOverride() // Send allowElevate status to server code
{
	if(self.eleOverrideNow)
	{
		// Eles are enabled for this save
		self allowElevate(true);
	}
	else if(self openCJ\playerRuns::isRunFinished())
	{
		// Not in a run anymore, so allow elevators
		self allowElevate(true);
	}
	else if(self _isEleAllowedThisCheckpoint())
	{
		// This checkpoint allows elevators to be used to reach it
		self allowElevate(true);
	}
	else
	{
		// Elevators are not allowed
		self allowElevate(false);
	}
}

onElevate()
{
	if(self.eleOverrideNow || self openCJ\playerRuns::isRunFinished() || self _isEleAllowedThisCheckpoint())
	{
		// This elevator is allowed
		return;
	}

	self iprintlnbold("Elevator detected, but your run doesn't allow them");
	self iprintlnbold("Load back, or use !ele and save to allow elevators");
}

_isEleAllowedThisCheckpoint()
{
	return (isDefined(self openCJ\checkpoints::getCheckpoint()) && openCJ\checkpoints::isEleAllowed(self openCJ\checkpoints::getCheckpoint()));
}