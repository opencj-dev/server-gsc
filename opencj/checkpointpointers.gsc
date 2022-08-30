#include openCJ\util;

onInit()
{
	level.checkpointShaders = [];
	level.checkpointShaders["blue"] = "opencj_checkpoint_blue";
	level.checkpointShaders["cyan"] = "opencj_checkpoint_cyan";
	level.checkpointShaders["green"] = "opencj_checkpoint_green";
	level.checkpointShaders["orange"] = "opencj_checkpoint_orange";
	level.checkpointShaders["purple"] = "opencj_checkpoint_purple";
	level.checkpointShaders["red"] = "opencj_checkpoint_red";
	level.checkpointShaders["yellow"] = "opencj_checkpoint_yellow";
	level.checkpointShaders["default"] = level.checkpointShaders["blue"];


	level.checkpointShadersObjective = [];
	keys = GetArrayKeys(level.checkpointShaders);
	for (i = 0; i < keys.size; i++)
	{
		level.checkpointShadersObjective[keys[i]] = level.checkpointShaders[keys[i]];
		if (getCvarInt("codversion") == 4)
		{
			level.checkpointShadersObjective[keys[i]] += "_obj";
		}
	}
	
	colors = getArrayKeys(level.checkpointShaders);
	for(i = 0; i < colors.size; i++)
	{
		precacheShader(level.checkpointShaders[colors[i]]);
		precacheShader(level.checkpointShadersObjective[colors[i]]);
	}
}

onPlayerConnect()
{
	self.checkpointPointers_huds = [];
	self.checkpointPointer_objectives = [];
	for(i = 0; i < 16; i++)
		self objective_player_delete(i);
}

onStartDemo()
{
	self _hideCheckpointPointers();
}

onRunIDCreated()
{
	self _hideCheckpointPointers();
}

onSpawnSpectator()
{
	self _hideCheckpointPointers();
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	self _hideCheckpointPointers();
}

onCheckpointsChanged(cp)
{
	self showCheckpointPointers();
}

onRunFinished(cp)
{
	self _hideCheckpointPointers();
}

showCheckpointPointers()
{
	if(self.sessionState != "playing")
		return;

	checkpoints = self openCJ\checkpoints::getCheckpoints();

	for(i = 0; i < checkpoints.size; i++)
	{
		if(i >= self.checkpointPointers_huds.size)
		{
			self.checkpointPointers_huds[self.checkpointPointers_huds.size] = self _createNewCheckpointPointerHud();
		}

		shaderColor = openCJ\checkpoints::getCheckpointShaderColor(checkpoints[i]);
		shader_hud = _getShaderHud(shaderColor);
		shader_objective = _getShaderObjective(shaderColor);

		self.checkpointPointers_huds[i] setShader(shader_hud, 8, 8);
		self.checkpointPointers_huds[i] setWaypoint(true);
		
		self.checkpointPointers_huds[i].x = checkpoints[i].origin[0];
		self.checkpointPointers_huds[i].y = checkpoints[i].origin[1];
		self.checkpointPointers_huds[i].z = checkpoints[i].origin[2] + 10;
		self.checkpointPointers_huds[i] thread _doJump(self);

		if(i < 16)
		{
			self.checkpointPointers_objectives[i] = true;
			if(getCvarInt("codversion") == 2)
			{
				self objective_player_add(i, "current", checkpoints[i].origin, shader_objective); 
			}
			else
			{
				self objective_player_add(i, "active", checkpoints[i].origin, shader_objective); 
			}
		}

	}
	for(i = self.checkpointPointers_huds.size - 1; i >= checkpoints.size; i--)
	{
		self.checkpointPointers_huds[i] notify("stopJump");
		self.checkpointPointers_huds[i] destroy();
		self.checkpointPointers_huds[i] = undefined;
		if(isDefined(self.checkpointPointers_objectives[i]))
		{
			self objective_player_delete(i);
			self.checkpointPointers_objectives[i] = undefined;
		}
	}
}

_getShaderHud(color)
{
	if(isDefined(color) && isDefined(level.checkpointShaders[color]))
	{
		return level.checkpointShaders[color];
	}
	return level.checkpointShaders["default"];
}

_getShaderObjective(color)
{
	if(isDefined(color) && isDefined(level.checkpointShadersObjective[color]))
	{
		return level.checkpointShadersObjective[color];
	}
	return level.checkpointShadersObjective["default"];
}

_doJump(player)
{
	player endon("disconnect");
	self notify("stopJump");
	self endon("stopJump");

	offset[0] = (0, 0, 20) + (self.x, self.y, self.z);
	offset[1] = (0, 0, 15) + (self.x, self.y, self.z);
	offset[2] = (0, 0, 10) + (self.x, self.y, self.z);
	offset[3] = (0, 0, 5) + (self.x, self.y, self.z);
	offset[4] = (0, 0, 0) + (self.x, self.y, self.z);
	offset[5] = (0, 0, 0) + (self.x, self.y, self.z);

	frames = 4;
	while(true)
	{
		for(i = 0; i < offset.size; i++)
		{
			curOffset = offset[i];
			nextOffset = offset[(i + 1) % offset.size];
			diff = nextOffset - curOffset;
			for(j = 0; j < frames; j++)
			{
				self.x = curOffset[0] + diff[0] * (1 / frames) * j;
				self.y = curOffset[1] + diff[1] * (1 / frames) * j;
				self.z = curOffset[2] + diff[2] * (1 / frames) * j;
				wait 0.05;
			}
		}
	}
}


_hideCheckpointPointers()
{
	for(i = self.checkpointPointers_huds.size - 1; i >= 0; i--)
	{
		self.checkpointPointers_huds[i] notify("stopJump");
		self.checkpointPointers_huds[i] destroy();
		self.checkpointPointers_huds[i] = undefined;
		if(isDefined(self.checkpointPointers_objectives[i]))
		{
			self objective_player_delete(i);
			self.checkpointPointers_objectives[i] = undefined;
		}
	}
}

_createNewCheckpointPointerHud()
{
	hud = newClientHudElem(self);
	hud.alpha = 1;
	hud.foreground = true;
	hud.aligny = "top";
	hud.alignx = "center";
	return hud;
}