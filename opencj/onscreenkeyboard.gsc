#include openCJ\util;

onInit()
{
	level.onscreenKeyboardShader["forward"] = "opencj_key_w";
	level.onscreenKeyboardShader["back"] = "opencj_key_s";
	level.onscreenKeyboardShader["right"] = "opencj_key_d";
	level.onscreenKeyboardShader["left"] = "opencj_key_a";
	level.onscreenKeyboardShader["jump"] = "opencj_key_jump";
	precacheShader(level.onscreenKeyboardShader["forward"]);
	precacheShader(level.onscreenKeyboardShader["back"]);
	precacheShader(level.onscreenKeyboardShader["right"]);
	precacheShader(level.onscreenKeyboardShader["left"]);
	precacheShader(level.onscreenKeyboardShader["jump"]);
	if(getCvarInt("codversion") == 4)
	{
		level.onscreenKeyboardShader["sprint"] = "opencj_key_sprint";
		precacheShader(level.onscreenKeyboardShader["sprint"]);
	}
}

whileAlive()
{
	spectators = getSpectatorList(false);
	for(i = 0; i < spectators.size; i++)
		spectators[i] _showKeyboard(self);
}

onSpectatorClientChanged(newClient) //can be undefined for free spec
{
	if(!isDefined(newClient))
		self _hideKeyboard();
}

onSpawnSpectator()
{
	self _hideKeyboard();
}

onSpawnPlayer()
{
	self _hideKeyboard();
}

onPlayerConnect()
{
	self _createKeyboard();
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	spectators = getSpectatorList(false);
	for(i = 0; i < spectators.size; i++)
		spectators[i] _hideKeyboard();
}

_showKeyboard(player)
{
	if(player forwardButtonPressed())
		self.keyboard["forward"].alpha = 1;
	else
		self.keyboard["forward"].alpha = 0.3;

	if(player backButtonPressed())
		self.keyboard["back"].alpha = 1;
	else
		self.keyboard["back"].alpha = 0.3;

	if(player rightButtonPressed())
		self.keyboard["right"].alpha = 1;
	else
		self.keyboard["right"].alpha = 0.3;

	if(player leftButtonPressed())
		self.keyboard["left"].alpha = 1;
	else
		self.keyboard["left"].alpha = 0.3;

	if(player jumpButtonPressed())
		self.keyboard["jump"].alpha = 1;
	else
		self.keyboard["jump"].alpha = 0.3;

	if(isDefined(self.keyboard["sprint"]))
	{
		if(player sprintButtonPressed())
			self.keyboard["sprint"].alpha = 1;
		else
			self.keyboard["sprint"].alpha = 0.3;
	}
}

_createKeyboard()
{
	self.keyboard = [];

	self.keyboard["forward"] = newClientHudElem(self);
	self.keyboard["forward"].horzAlign = "center_safearea";
	self.keyboard["forward"].vertAlign = "center_safearea";
	self.keyboard["forward"].alignX = "center";
	self.keyboard["forward"].alignY = "middle";
	self.keyboard["forward"].x = 0;
	self.keyboard["forward"].y = 105;
	self.keyboard["forward"].alpha = 0;
	self.keyboard["forward"].archived = false;

	self.keyboard["left"] = newClientHudElem(self);
	self.keyboard["left"].horzAlign = "center_safearea";
	self.keyboard["left"].vertAlign = "center_safearea";
	self.keyboard["left"].alignX = "center";
	self.keyboard["left"].alignY = "middle";
	self.keyboard["left"].x = -22;
	self.keyboard["left"].y = 127;
	self.keyboard["left"].alpha = 0;
	self.keyboard["left"].archived = false;

	self.keyboard["right"] = newClientHudElem(self);
	self.keyboard["right"].horzAlign = "center_safearea";
	self.keyboard["right"].vertAlign = "center_safearea";
	self.keyboard["right"].alignX = "center";
	self.keyboard["right"].alignY = "middle";
	self.keyboard["right"].x = 22;
	self.keyboard["right"].y = 127;
	self.keyboard["right"].alpha = 0;
	self.keyboard["right"].archived = false;

	self.keyboard["back"] = newClientHudElem(self);
	self.keyboard["back"].horzAlign = "center_safearea";
	self.keyboard["back"].vertAlign = "center_safearea";
	self.keyboard["back"].alignX = "center";
	self.keyboard["back"].alignY = "middle";
	self.keyboard["back"].x = 0;
	self.keyboard["back"].y = 127;
	self.keyboard["back"].alpha = 0;
	self.keyboard["back"].archived = false;

	self.keyboard["jump"] = newClientHudElem(self);
	self.keyboard["jump"].horzAlign = "center_safearea";
	self.keyboard["jump"].vertAlign = "center_safearea";
	self.keyboard["jump"].alignX = "center";
	self.keyboard["jump"].alignY = "middle";
	self.keyboard["jump"].x = 74;
	self.keyboard["jump"].y = 127;
	self.keyboard["jump"].alpha = 0;
	self.keyboard["jump"].archived = false;

	if(getCvarInt("codversion") == 4)
	{
		self.keyboard["sprint"] = newClientHudElem(self);
		self.keyboard["sprint"].horzAlign = "center_safearea";
		self.keyboard["sprint"].vertAlign = "center_safearea";
		self.keyboard["sprint"].alignX = "center";
		self.keyboard["sprint"].alignY = "middle";
		self.keyboard["sprint"].x = -74;
		self.keyboard["sprint"].y = 127;
		self.keyboard["sprint"].alpha = 0;
		self.keyboard["sprint"].archived = false;
		self.keyboard["sprint"] setShader(level.onscreenKeyboardShader["sprint"], 80, 20);
	}

	self.keyboard["forward"] setShader(level.onscreenKeyboardShader["forward"], 20, 20);
	self.keyboard["left"] setShader(level.onscreenKeyboardShader["left"], 20, 20);
	self.keyboard["back"] setShader(level.onscreenKeyboardShader["back"], 20, 20);
	self.keyboard["right"] setShader(level.onscreenKeyboardShader["right"], 20, 20);
	self.keyboard["jump"] setShader(level.onscreenKeyboardShader["jump"], 80, 20);
}

_hideKeyboard()
{
	printf("hiding keyboard\n");
	self.keyboard["forward"].alpha = 0;
	self.keyboard["back"].alpha = 0;
	self.keyboard["right"].alpha = 0;
	self.keyboard["left"].alpha = 0;
	self.keyboard["jump"].alpha = 0;
	if(isDefined(self.keyboard["sprint"]))
		self.keyboard["sprint"].alpha = 0;
}