// For each player, we remember the FPS they have used this jump.
// When a spectator starts spectating the player, they will see this FPS (history).

#include openCJ\util;

onInit()
{
	openCJ\huds\infiniteHuds::initInfiniteHud("fpshistory");
}

onPlayerConnect()
{
	self.fpshistory = [];
	self.fpsHistoryText = "";
	self.fpsHistoryHudName = "fpshistory";

    //										name         			x  y   alignX   alignY hAlign     vAlign
	self openCJ\huds\base::initInfiniteHUD(self.fpsHistoryHudName,	0, 0, "center", "top", undefined, undefined,
    //  foreground  font		hideInMenu	color				glowColor	glowAlpha	fontScale	archived	alpha
		true,		undefined,	undefined,	(0.8, 0.8, 0.8),	undefined,	undefined,	1.5,		undefined,	0);
}

onSpectatorClientChanged(newClient)
{
	if (!isDefined(newClient) || newClient openCJ\demos::isPlayingDemo())
	{
		// Not spectating anyone anymore
		self _clearFPSHistory();
	}
	else
	{
		self _setFPSHistory(newClient.fpsHistoryText);
		self openCJ\huds\base::enableHUD(self.fpsHistoryHudName);
	}
}

onSpawnSpectator()
{
	self hideAndClearFPSHistory();
}

onSpawnPlayer()
{
	self hideAndClearFPSHistory();
}

hideAndClearFPSHistory()
{
	self openCJ\huds\base::disableHUD(self.fpsHistoryHudName);
	self _clearFPSHistory();
}

// The following functions are for the player performing the jump

onFPSChanged(newFPS)
{
	if(self openCJ\demos::isPlayingDemo())
	{
		return;
	}
	self notify("fpshistory_fpschanged");
	shortFPS = openCJ\fps::getShortFPS(newFPS);

	if (!self isOnGround())
	{
		self _addFPSHistory(shortFPS);
	}

	self.fpshistory["shortfps"] = shortFPS;
}

onBounced()
{
	if(self openCJ\demos::isPlayingDemo())
	{
		return;
	}
	self thread _onBouncedThread();
}

_onBouncedThread()
{
	self endon("disconnect");
	if (self.fpsHistoryText != "")
	{
		self _addFPSHistory("-");
		self endon("fpshistory_fpschanged");
		self endon("fpshistory_clear");
		wait 0.15;
		self _addFPSHistory(openCJ\fps::getShortFPS(self openCJ\fps::getCurrentFPS()));
	}
}

onStartDemo()
{

	self _clearFPSHistory();
}

onLoaded()
{
	if(self openCJ\demos::isPlayingDemo())
	{
		return;
	}
	self _clearFPSHistory();
}

onOnGround(isOnGround)
{
	if(self openCJ\demos::isPlayingDemo())
	{
		return;
	}
	self thread _onOnGroundThread(isOnGround);
}

_onOnGroundThread(isOnGround)
{
	self endon("disconnect");
	self notify("fpshistory_ongroundchange");
	self endon("fpshistory_ongroundchange");
	if (isOnGround)
	{
		wait 2; // Keep specFPS HUD for 2 seconds after landing
		self _clearFPSHistory();
	}
	else
	{
		// No longer onGround, so show the initial FPS
		self _setFPSHistory(openCJ\fps::getShortFPS(self openCJ\fps::getCurrentFPS()));
	}
}

_clearFPSHistory()
{
	self notify("fpshistory_clear");
	self.fpsHistoryText = "";

	spectators = self getSpectatorList(false);
	for (i = 0; i < spectators.size; i++)
	{
		spectators[i].fpsHistoryText = "";
		spectators[i] openCJ\huds\base::disableHUD(self.fpsHistoryHudName);
	}
}

_addFPSHistory(text)
{
	self _setFPSHistory(self.fpsHistoryText + text);
}

_setFPSHistory(text)
{
	if(self openCJ\demos::isPlayingDemo())
	{
		return;
	}

	if (self.fpsHistoryText == text)
	{
		return; // Already set
	}

	self.fpsHistoryText = text;
	if(text.size <= 1)
	{
		return;
	}
	spectators = self getSpectatorList(false);
	for (i = 0; i < spectators.size; i++)
	{
		spectators[i].fpsHistoryHud openCJ\huds\infiniteHuds::setInfiniteHudText(text, spectators[i], false);
		spectators[i] openCJ\huds\base::enableHUD(self.fpsHistoryHudName);
	}

	//self iprintln("Setting fps history to: " + text + " for " + self getEntityNumber());
}

_setDemoFPSHistory(text)
{
	if (self.fpsHistoryText == text)
	{
		return; // Already set
	}

	self.fpsHistoryText = text;
	if(text.size <= 1)
	{
		return;
	}
	self.hud[self.fpsHistoryHudName] openCJ\huds\infiniteHuds::setInfiniteHudText(text, self, false);
	self openCJ\huds\base::enableHUD(self.fpsHistoryHudName);
}

_clearDemoFPSHistory()
{
	self notify("fpshistory_clear");
	self.fpsHistoryText = "";
	self.fpsHistoryText = "";
	self openCJ\huds\base::disableHUD(self.fpsHistoryHudName);
}

onDemoBounce(text)
{
	self thread _onDemoBounceThread(text);
}

_onDemoBounceThread(text)
{
	self endon("disconnect");
	if (self.fpsHistoryText != "")
	{
		self addDemoFPSHistory("-");
		self endon("fpshistory_fpschanged");
		self endon("fpshistory_clear");
		wait 0.15;
		self addDemoFPSHistory(text);
	}
}

onDemoLand()
{
	self thread _onDemoLandThread();
}

_onDemoLandThread()
{
	self endon("disconnect");
	self notify("fpshistory_ongroundchange");
	self endon("fpshistory_ongroundchange");
	wait 2; // Keep specFPS HUD for 2 seconds after landing
	self _clearDemoFPSHistory();
}

onDemoLeaveGround(text)
{
	self notify("fpshistory_ongroundchange");
	clearAndSetDemoFPS(text);
}

clearAndSetDemoFPS(text)
{
	self _clearDemoFPSHistory();
	self _setDemoFPSHistory(text);
}

addDemoFPSHistory(text)
{
	if(self.fpsHistoryText.size > 0 && self.fpsHistoryText[self.fpsHistoryText.size - 1] == text)
	{
		return;
	}
	self _setDemoFPSHistory(self.fpsHistoryText + text);
}
