#include openCJ\util;

onInit()
{
	cmd = openCJ\commands_base::registerCommand("noclip", "Enables/disables noclip. Usage: !noclip [speed]", ::noclip, 0, 1, 0);
	openCJ\commands_base::addAlias(cmd, "ufo"); // It's not the same, but we don't have ufo anyway so..
}

onPlayerConnect()
{
	self.noclip = false;
	self.noclip_speed = 20;
}

onRunIDCreated()
{
    self disableNoclip();
}

onRunIDRestored()
{
    self disableNoclip();
}

noclip(args)
{
	if(self openCJ\demos::isPlayingDemo())
	{
		self sendLocalChatMessage("Cannot enable noclip during demo playback");
		return;
	}
	wasEverEnabled = self hasNoclip();
	wasEnabled = self hasNoclip();
	shouldEnable = false;
	if((args.size == 0) || !isValidInt(args[0]))
	{
		shouldEnable = !wasEnabled;
	}
	else
	{
		speed = int(args[0]);
		if(speed > 100)
		{
			speed = 100;
		}
		else if(speed < 10)
		{
			speed = 10;
		}

		self.noclip_speed = speed;
		shouldEnable = true;
	}

	if (shouldEnable && !wasEnabled)
	{
		self enableNoclip();
		self sendLocalChatMessage("Noclip on");
	}
	else if (!shouldEnable && wasEnabled)
	{
		self disableNoclip();
		self sendLocalChatMessage("Noclip off");
		if (wasEverEnabled)
		{
			self sendLocalChatMessage("History load back until cheating flag is gone, or !reset");
		}
	}
}

hasNoclip()
{
	return self.noclip;
}

disableNoclip()
{
	if(!self hasNoclip())
	{
		return;
	}

	if(isDefined(self.noclip_linkto))
	{
		self.noclip_linkto delete();
	}

	self.noclip = false;
	self unlink();
}

enableNoclip()
{
	if(isDefined(self.noclip_linkto))
	{
		self.noclip_linkto delete();
	}
	if(self hasNoclip())
	{
		return;
	}

	self.noclip = true;
	self openCJ\cheating::setCheating(true);
	self openCJ\playerRuns::startRun();
	self.noclip_linkto = spawn("script_origin", self.origin);
	self.noclip_linkto thread deleteOnEvent("disconnect", self);
	self linkto(self.noclip_linkto);
}

whileAlive()
{
	if(!self hasNoclip())
	{
		return;
	}
	dir = (0, 0, 0);
	if(self rightButtonPressed())
	{
		dir += anglesToRight(self getPlayerAngles());
	}
	if(self leftButtonPressed())
	{
		dir -= anglesToRight(self getPlayerAngles());
	}
	if(self forwardButtonPressed())
	{
		dir += anglesToForward(self getPlayerAngles());
	}
	if(self backButtonPressed())
	{
		dir -= anglesToForward(self getPlayerAngles());
	}
	if(self leanRightButtonPressed())
	{
		dir += anglesToUp(self getPlayerAngles());
	}
	if(self leanLeftButtonPressed())
	{
		dir -= anglesToUp(self getPlayerAngles());
	}
	scale = self.noclip_speed;
	if(self issprinting())
	{
		scale *= 3;
	}
	else
	{
		scale *= (1 + 3 * self playerADS());
	}
	self.noclip_linkto.origin += vectorScale(dir, scale);
}