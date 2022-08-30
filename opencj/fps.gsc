#include openCJ\util;

onInit()
{
	underlyingCmd = openCJ\settings::addSettingBool("allowhax", false, "Set whether hax fps is allowed in current run\nUsage: !hax [on/off]");
	openCJ\commands_base::addAlias(underlyingCmd, "hax");
	underlyingCmd = openCJ\settings::addSettingBool("allowmix", true, "Set whether mix fps is allowed in current run\nUsage: !mix [on/off]");
	openCJ\commands_base::addAlias(underlyingCmd, "mix");
}

onFPSNotInUserInfo()
{
	if(self openCJ\playerRuns::hasRunStarted())
	{
		if(!self hasUsedHaxFPS())
		{
			self iprintlnbold("Error: your com_maxfps is not in your userinfo, please reconnect");
			self onHaxFPSDetected();
		}
	}
}

setSafeFPS()
{
	// Attempt to force user's FPS to 125 (safe value)
	self setClientCvar("com_maxfps", 125);
	self clearFPSFilter();
	self.lastFPS = 125;
	self _fpsChange(125);
}

onHaxFPSDetected()
{
	if(self hasUsedHaxFPS())
	{
		return;
	}

	if(!self openCJ\settings::getSetting("allowhax"))
	{
		//load back upon hax fps detection
		if(!self openCJ\savePosition::canLoadError(0))
		{
			self iprintln("^5Hax FPS detected");
			self setSafeFPS();

			// Force the player back to their load
			self thread openCJ\savePosition::loadNormal();
		}
		else
		{
			self openCJ\settings::setSetting("allowhax", true);
			self setUsedHaxFPS(true);
			self iprintlnbold("Hax fps detected, but cannot load back. Reset your run to clear hax");
		}
	}
	else
	{
		setUsedHaxFPS(true);
	}
}

onMixFPSDetected()
{
	if(self hasUsedMixFPS())
	{
		return;
	}

	if(!self openCJ\settings::getSetting("allowmix"))
	{
		//load back upon mix fps detection
		if(!self openCJ\savePosition::canLoadError(0))
		{
			self iprintln("^3Mix FPS detected");
			self thread openCJ\savePosition::loadNormal();
		}
		else
		{
			self openCJ\settings::setSetting("allowmix", true);
			self setUsedMixFPS(true);
			self iprintlnbold("Mix fps detected, but cannot load back. Reset your run to clear mix");
		}
	}
	else
	{
		setUsedMixFPS(true);
	}
}

setUsedHaxFPS(hasUsed)
{
	if(hasUsed && !self openCJ\settings::getSetting("allowhax"))
	{
		self iprintlnbold("Hax fps was enabled on this save");
		self iprintlnbold("To reset, load back to a save without hax and !hax off");
		self openCJ\settings::setSetting("allowhax", true);
	}
	self.hasUsedHaxFPS = hasUsed;
}

setUsedMixFPS(hasUsed)
{
	if(hasUsed && !self openCJ\settings::getSetting("allowmix"))
	{
		self iprintlnbold("Mix fps was enabled on this save");
		self iprintlnbold("To reset, load back to a save without mix and !mix off");
		self openCJ\settings::setSetting("allowmix", true);
	}
	self.hasUsedMixFPS = hasUsed;
}

hasUsedHaxFPS()
{
	return self.hasUsedHaxFPS;
}

hasUsedMixFPS()
{
	return self.hasUsedMixFPS;
}

_fpsChange(newFPS)
{
	self openCJ\fpsHistory::onFPSChanged(newFPS);
}

onRunStarted()
{
	self.lastFPS = getFPSFromUserInfo();
	if(!isDefined(self.lastFPS))
	{
		self onFPSNotInUserInfo();
	}
	if(isHaxFPS(self getCurrentFPS()))
	{
		self onHaxFPSDetected();
	}
}

onDetectedFPSChange(newFPS)
{
	if(isDefined(self.lastFPS) && self.lastFPS == newFPS)
	{
		return;
	}
	if(isPlayerReady() && self openCJ\playerRuns::hasRunStarted())
	{
		if(isHaxFPS(newFPS))
		{
			self onHaxFPSDetected();
		}
		else if(newFPS > 125)
		{
			self onMixFPSDetected();
		}
		self _fpsChange(newFPS);
	}
	self.lastFPS = newFPS;
}

onUserInfoFPSChange(newFPS)
{
	onDetectedFPSChange(newFPS);
}

getFPSFromUserInfo()
{
	return intOrUndefined(self getUserInfo("com_maxfps"));
}

onRunIDCreated()
{
	self.hasUsedHaxFPS = false;
	self.hasUsedMixFPS = false;
	self openCJ\settings::setSetting("allowhax", false); //todo: get these from database
	self openCJ\settings::setSetting("allowmix", true);
	self.lastFPS = getFPSFromUserInfo();
}

getCurrentFPS()
{
	if(!isDefined(self.lastFPS))
	{
		return 0;
	}
	return self.lastFPS;
}

isHaxFPS(fps)
{
	switch(fps)
	{
		case 43:
			return (getCvarInt("codversion") == 4);
		case 76:
		case 125:
		case 250:
		case 333:
			return false;
		default:
			return true;
	}
}