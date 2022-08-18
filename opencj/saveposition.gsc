#include openCJ\util;

onInit()
{
	level.saveFlags = [];
	level.saveFlags["cheating"] = 1;
	level.saveFlags["speedModeNow"] = 2;
	level.saveFlags["speedModeEver"] = 4;
	level.saveFlags["rpg"] = 8;
	level.saveFlags["eleOverrideNow"] = 16;
	level.saveFlags["eleOverrideEver"] = 32;
}

getFlagEleOverrideNow(save)
{
	return (save.flags & level.saveFlags["eleOverrideNow"]) != 0;
}

getFlagEleOverrideEver(save)
{
	return (save.flags & level.saveFlags["eleOverrideEver"]) != 0;
}

isCheating(save)
{
	return (save.flags & level.saveFlags["cheating"]) != 0;
}

hasSpeedModeNow(save)
{
	return (save.flags & level.saveFlags["speedModeNow"]) != 0;
}

hasSpeedModeEver(save)
{
	return (save.flags & level.saveFlags["speedModeEver"]) != 0;
}

hasRPG(save)
{
	return (save.flags & level.saveFlags["rpg"]) != 0;
}

createFlags()
{
	flags = 0;
	if(self openCJ\cheating::isCheating())
	{
		flags |= level.saveFlags["cheating"];
	}
	if(self openCJ\speedMode::hasSpeedMode())
	{
		flags |= level.saveFlags["speedModeNow"];
	}
	if(self openCJ\speedMode::hasSpeedModeEver())
	{
		flags |= level.saveFlags["speedModeEver"];
	}
	if(openCJ\weapons::isRPG(self getCurrentWeapon()))
	{
		flags |= level.saveFlags["rpg"];
	}
	if(openCJ\elevate::hasEleOverrideNow())
	{
		flags |= level.saveFlags["eleOverrideNow"];
	}
	if(openCJ\elevate::hasEleOverrideEver())
	{
		flags |= level.saveFlags["eleOverrideEver"];
	}
	return flags;
}

onRunIDCreated()
{
	self savePosition_initClient();
	self.savePosition_backwardsCount = 0;
}

canSaveError()
{
	if(self.sessionState != "playing")
		return 1;

	if(!self isOnGround())
		return 2;

	groundEntity = self getGroundEntity();

	if(isDefined(groundEntity) && !isDefined(groundEntity.canSaveOn) && false)
		return 3;

	return 0;
}

printCanSaveError(error)
{
	switch(error)
	{
		case 2:
		{
			self iprintln("^1Cannot save in air");
			break;
		}
		case 3:
		{
			self iprintln("^1Cannot save on this object");
			break;
		}
	}
}

printSaveSuccess()
{
	self iprintln("^2Position saved");
}

printLoadSuccess()
{
	self iPrintln("^2Position loaded");
}

onSpawnPlayer()
{
	self.savePosition_backwardsCount = 0;
}

canLoadError(backwardsCount)
{
	if(self.sessionState != "playing")
		return 999;
	if(self openCJ\noclip::hasNoclip())
		return 4;
	error = self savePosition_selectSave(backwardsCount);
	return error;
}

printCanLoadError(error)
{
	switch(error)
	{
		case 1:
		{
			self iprintln("^1Failed loading position");
			break;
		}
		case 2:
		{
			self iprintln("^1Failed loading secondary position");
			break;
		}
		case 4:
		{
			self iprintln("^1Cannot load during noclip");
			break;
		}
	}
}

_findNumOfEnt(ent)
{
	ents = getEntArray(ent.targetName, "targetname");
	for(i = 0; i < ents.size; i++)
	{
		if(ents[i] == ent)
			return i;
	}
	return undefined;
}

setSavedPosition()
{
	groundEntity = self getGroundEntity();
	if(isDefined(groundEntity) && isDefined(groundEntity.targetName))
	{
		diff = self.origin - groundEntity.origin;
		x = vectorDot(anglesToForward(groundEntity.angles), diff);
		y = vectorDot(anglesToRight(groundEntity.angles), diff);
		z = vectorDot(anglesToUp(groundEntity.angles), diff);
		origin = (x, y, z);
		angles = self getPlayerAngles() - (0, groundEntity.angles[1], 0);
		entNum = groundEntity getEntityNumber();
		entTargetName = groundEntity.targetName;
		numOfEnt = _findNumOfEnt(groundEntity);
	}
	else
	{
		origin = self.origin;
		angles = self getPlayerAngles();
		entNum = undefined;
		entTargetName = undefined;
		numOfEnt = undefined;
	}
	/*
	if(isDefined(self openCJ\checkpoints::getCurrentCheckpointID()))
		printf("saving with defined id, " + self openCJ\checkpoints::getCurrentCheckpointID() + "\n");
	else
		printf("saving with undef id\n");
	*/
	flags = self createFlags();
	//printf("flags: "  + flags + "\n");
	self thread openCJ\historySave::saveToDatabase(origin, angles, entTargetName, numOfEnt, self openCJ\statistics::getRPGJumps(), self openCJ\statistics::getNadeJumps(), self openCJ\statistics::getDoubleRPGs(), self openCJ\checkpoints::getCurrentCheckpointID(), flags);
	self savePosition_save(origin, angles, entNum, self openCJ\statistics::getRPGJumps(), self openCJ\statistics::getNadeJumps(), self openCJ\statistics::getDoubleRPGs(), self openCJ\checkpoints::getCurrentCheckpointID(), flags);
}

getSavedPosition(backwardsCount)
{
	self savePosition_selectSave(backwardsCount);

	save = spawnStruct();
	save.origin = self savePosition_getOrigin();
	save.angles = self savePosition_getAngles();

	save.RPGJumps = self savePosition_getRPGJumps();
	save.nadeJumps = self savePosition_getNadeJumps();
	save.doubleRPGs = self savePosition_getDoubleRPGs();
	save.checkpointID = self savePosition_getCheckpointID();
	save.flags = self savePosition_getFlags();
	//printf("flags: " + save.flags + "\n");

	/*
	if(isdefined(save.checkpointID))
		printf("cp id defined, " + save.checkpointID + "\n");
	else
		printf("cp id undef\n");
	*/

	groundEntity = self savePosition_getGroundEntity();

	if(isDefined(groundEntity))
	{
		x = vectorScale(anglesToForward(groundEntity.angles), save.origin[0]);
		y = vectorScale(anglesToRight(groundEntity.angles), save.origin[1]);
		z = vectorScale(anglesToUp(groundEntity.angles), save.origin[2]);
		save.origin = groundEntity.origin + x + y + z;
		save.angles = (save.angles[0], save.angles[1] + groundEntity.angles[1], save.angles[2]);
	}

	return save;
}

onPlayerCommand(args)
{
	switch(args[0])
	{
		case "save":
		{
			self saveNormal();
			return true;
		}
		case "load":
		{
			self loadNormal();
			return true;
		}
		case "loadsecondary":
		{
			self loadSecondary();
			return true;
		}
		case "mr":
		{
			if(isDefined(args[3]))
			{
				if(args[3] == "load")
				{
					self loadNormal();
					return true;
				}
				else if(args[3] == "save")
				{
					self saveNormal();
					return true;
				}
				else if(args[3] == "loadsecondary")
				{
					self loadSecondary();
					return true;
				}
			}
		}
	}
	return false;
}

saveNormal()
{
	self.savePosition_backwardsCount = 0;
	self thread _saveNextFrame();
}

loadNormal()
{
	self.savePosition_backwardsCount = 0;
	self thread _loadNextFrame(0);
}

loadSecondary()
{
	self.savePosition_backwardsCount++;
	self loadBackwards(self.savePosition_backwardsCount);
}

loadBackwards(backwardsCount)
{
	self thread _loadNextFrame(backwardsCount);
}

_loadNextFrame(backwardsCount)
{
	self notify("saveLoadPositionCommand");
	self endon("saveLoadPositionCommand");

	waittillframeend;

	if(isDefined(self))
		self openCJ\events\loadPosition::main(backwardsCount);
}

_saveNextFrame()
{
	self notify("saveLoadPositionCommand");
	self endon("saveLoadPositionCommand");

	waittillframeend;

	if(isDefined(self))
		self openCJ\events\savePosition::main();
}