#include openCJ\util;

onInit()
{
	underlyingCmd = openCJ\settings::addSettingBool("ignorehax", false, "Enable/disable loading on hax fps\nUsage: !ignorehax [on/off]");
	underlyingCmd = openCJ\settings::addSettingBool("ignoremix", true, "Enable/disable loading on mix fps\nUsage: !ignoremix [on/off]");
}

fpsNotInUserinfo()
{
	if(self openCJ\playerRuns::hasRunStarted())
	{
		if(!self hasHaxFPS())
		{
			self iprintlnbold("Error: your com_maxfps is not in your userinfo. Please reconnect. If this error persists, contact an admin");
			self haxFPSDetection();
		}
	}
}

onLoadPosition()
{
	if(isHaxFPS(self getCurrentFPS()))
	{
		if(!self openCJ\savePosition::canLoadError(0))
		{
			printf("trying to load\n");
			self iPrintLnBold("Loaded because hax detected");
			self setClientCvar("com_maxfps", 125);
			//self set_userinfo("com_maxfps", "125");
			self clearfpsfilter();
			self.fps = 125;
			self _fpsChange(125);
			self openCJ\statistics::setLoadCount(self openCJ\statistics::getLoadCount() - 1);
			self thread openCJ\savePosition::loadNormal();
		}
		else
		{
			self openCJ\settings::setSetting("ignorehax", true);
			self setHaxFPS(true);
			self iprintlnbold("Hax fps detected, cannot load back. Ignoring hax fps for this run. Reset your run to undo this");
		}
	}
}

haxFPSDetection()
{
	if(!self openCJ\settings::getSetting("ignorehax"))
	{
		//load back upon hax fps detection
		if(!self openCJ\savePosition::canLoadError(0))
		{
			printf("trying to load\n");
			self iPrintLnBold("Loaded because hax detected");
			self setClientCvar("com_maxfps", 125);
			//self set_userinfo("com_maxfps", "125");
			self clearfpsfilter();
			self.fps = 125;
			self _fpsChange(125);
			self thread openCJ\savePosition::loadNormal();
		}
		else
		{
			self openCJ\settings::setSetting("ignorehax", true);
			self setHaxFPS(true);
			self iprintlnbold("Hax fps detected, cannot load back. Ignoring hax fps for this run. Reset your run to undo this");
		}
	}
	else
	{
		printf("ignorehax is off???\n");
		setHaxFPS(true);
	}
}

mixFPSDetection()
{
	if(!self openCJ\settings::getSetting("ignoremix"))
	{
		//load back upon mix fps detection
		if(!self openCJ\savePosition::canLoadError())
		{
			printf("trying to load\n");
			self iPrintLnBold("Loaded because mix detected");
			self thread openCJ\savePosition::loadNormal();
		}
		else
		{
			self openCJ\settings::setSetting("ignoremix", true);
			self setMixFPS(true);
			self iprintlnbold("Mix fps detected, cannot load back. Ignoring mix fps for this run. Reset your run to undo this");
		}
	}
	else
		setMixFPS(true);
}

setHaxFPS(value)
{
	if(value && !self openCJ\settings::getSetting("ignorehax"))
	{
		self iprintlnbold("Hax fps was enabled on this save. Ignoring hax fps for the rest of this run. Load back to a save without hax fps and disable hax ignoring with !ignorehax");
		self openCJ\settings::setSetting("ignorehax", true);
	}
	self.haxFPS = value;
}

hasHaxFPS()
{
	return self.haxFPS;
}

hasMixFPS()
{
	return self.mixFPS;
}

setMixFPS(value)
{
	if(value && !self openCJ\settings::getSetting("ignoremix"))
	{
		self iprintlnbold("Mix fps was enabled on this save. Ignoring mix fps for the rest of this run. Load back to a save without mix fps and disable mix ignoring with !ignoremix");
		self openCJ\settings::setSetting("ignoremix", true);
	}
	self.mixFPS = value;
}

onFPSChangedUserinfo(newFPS)
{
	if(!isPlayerReady())
	{
		return;
	}

	if(isHaxFPS(newFPS))
	{
		//user is haxxing
		//iprintln("hax from userinfo" + newFPS);
		self haxFPSDetection();
	}
	else if(newFPS != self getCurrentFPS())
	{
		//user is mixing
		self mixFPSDetection();
	}
	self.fps = newFPS;
	self _fpsChange(newFPS);
}

_fpsChange(newFPS)
{
	self openCJ\fpsHistory::onFPSChanged(newFPS);
}

onFPSChangedDetection(newFPS)
{
	if(!isPlayerReady())
	{
		return;
	}
	if(isHaxFPS(newFPS) || ((newFPS > self getCurrentFPS()) && !self hasMixFPS()))
	{
		//user is haxxing
		iprintln("Hax detected: " + newFPS); // TODO: seems we get false positive (76) sometimes
		self haxFPSDetection();
	}
	else if(newFPS != self getCurrentFPS())
	{
		//user is mixing
		self mixFPSDetection();
	}
}

getFPSFromUserInfo()
{
	return intOrUndefined(self getUserInfo("com_maxfps"));
}

onRunIDCreated()
{
	self.haxFPS = false;
	self.mixFPS = false;
	self openCJ\settings::setSetting("ignorehax", false);
	self openCJ\settings::setSetting("ignoremix", true);
	self.FPS = getFPSFromUserInfo();
	if(!isDefined(self getUserInfo("com_maxfps")))
		self fpsNotInUserinfo();
	if(isHaxFPS(self getCurrentFPS()))
	{
		iprintln("hax from onrunid" + self getCurrentFPS());
		self haxFPSDetection();
	}

}

getCurrentFPS()
{
	if(!isDefined(self.FPS))
		return 0;
	return self.FPS;
}

isHaxFPS(fps)
{
	//self iprintln("checking fps " + fps + " for hax");
	switch(fps)
	{
		case 43:
		case 76:
			return getCvarInt("codversion") == 4;
		case 125:
		case 250:
		case 333:
			return false;
		default:
			return true;
	}
}