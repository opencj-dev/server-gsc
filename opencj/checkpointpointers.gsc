#include openCJ\util;

onInit()
{
	level.checkpointShaders = [];
	level.checkpointShaders[0] = "opencj_checkpoint_green";
	level.checkpointShaders[1] = "opencj_checkpoint_red";
	level.checkpointShaders[2] = "opencj_checkpoint_yellow";
	
	
	for(i = 0; i < level.checkpointShaders.size; i++)
		precacheShader(level.checkpointShaders[i]);
}

onPlayerConnect()
{
	self.checkpointPointers_huds = [];
	self.checkpointPointer_objectives = [];
	for(i = 0; i < 16; i++)
		self objective_player_delete(i);
}

onSpawnPlayer()
{
	self showCheckpointPointers();
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
			self.checkpointPointers_huds[self.checkpointPointers_huds.size] = self _createNewCheckpointPointerHud();

		shaderNum = openCJ\checkpoints::getCheckpointShaderNum(checkpoints[i]);
		if(!isDefined(shadernum) || shaderNum < 0 || shaderNum >= level.checkpointShaders.size)
			shaderNum = 0;
		self.checkpointPointers_huds[i] setShader(level.checkpointShaders[shaderNum], 8, 8);
		self.checkpointPointers_huds[i] setwaypoint(true, level.checkpointShaders[shaderNum]);
		
		self.checkpointPointers_huds[i].x = checkpoints[i].origin[0];
		self.checkpointPointers_huds[i].y = checkpoints[i].origin[1];
		self.checkpointPointers_huds[i].z = checkpoints[i].origin[2] + 10;
		self.checkpointPointers_huds[i] thread _doJump(self);

		if(i < 16)
		{
			self.checkpointPointers_objectives[i] = true;
			if(getCvarInt("codversion") == 2)
				self objective_player_add(i, "current", checkpoints[i].origin, level.checkpointShaders[shaderNum]); 
			else
				self objective_player_add(i, "active", checkpoints[i].origin, level.checkpointShaders[shaderNum]); 
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