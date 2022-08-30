// For each player, we remember the FPS they have used this jump.
// When a spectator starts spectating the player, they will see this FPS (history).

#include openCJ\util;

onInit()
{
	openCJ\infiniteHuds::initInfiniteHud("fpshistory");
}

onPlayerConnect()
{
	self.fpshistory = [];
	self.fpsHistoryText = "";

	self.fpsHistoryHud = self openCJ\infiniteHuds::createInfiniteStringHud("fpshistory");
	self.fpsHistoryHud.alpha = 0;
	self.fpsHistoryHud.foreground = true;
	self.fpsHistoryHud.alignx = "center";
	self.fpsHistoryHud.aligny = "top";
	self.fpsHistoryHud.x = 0;
	self.fpsHistoryHud.y = 0;
	self.fpsHistoryHud.horzalign = "center_safearea";
	self.fpsHistoryHud.vertalign = "center_safearea";
	self.fpsHistoryHud.color = (0.8, 0.8, 0.8);
	self.fpsHistoryHud.fontscale = 1.5;
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
		self.fpsHistoryHud.alpha = 1;
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
	self.fpsHistoryHud.alpha = 0;
	self _clearFPSHistory();
}

_getShortFPS(fps)
{
	switch (fps)
	{
		case 125:
			return "1";
		case 142: 
			return "4";
		case 167:
			return "6";
		case 200:
			return "0";
		case 250:
			return"2";
		case 333:
			return "3";
		case 500:
			return "5";
		case 1000:
			return "K";
		default:
			return "?";
	}
}

// The following functions are for the player performing the jump

onFPSChanged(newFPS)
{
	self notify("fpshistory_fpschanged");
	shortFPS = _getShortFPS(newFPS);

	if (!self isOnGround())
	{
		self _addFPSHistory(shortFPS);
	}

	self.fpshistory["shortfps"] = shortFPS;
}

onBounced() // threaded
{
	if (self.fpsHistoryText != "")
	{
		self _addFPSHistory("-");
		self endon("fpshistory_fpschanged");
		self endon("fpshistory_clear");
		wait 0.15;
		self _addFPSHistory(_getShortFPS(self openCJ\fps::getCurrentFPS()));
	}
}

onStartDemo()
{
	self _clearFPSHistory();
}

onLoaded()
{
	self _clearFPSHistory();
}

onOnGround(isOnGround)
{
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
		self _setFPSHistory(_getShortFPS(self openCJ\fps::getCurrentFPS()));
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
		spectators[i].fpsHistoryHud.alpha = 0;
	}
}

_addFPSHistory(text)
{
	_setFPSHistory(self.fpsHistoryText + text);
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
		spectators[i].fpsHistoryHud openCJ\infiniteHuds::setInfiniteHudText(text, spectators[i], false);
		spectators[i].fpsHistoryHud.alpha = 1;
	}

	//self iprintln("Setting fps history to: " + text + " for " + self getEntityNumber());
}