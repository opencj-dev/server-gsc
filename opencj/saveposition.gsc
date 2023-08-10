#include openCJ\util;

onInit()
{
    level.saveFlagName_cheating = "cheating";
    level.saveFlagName_speedModeNow = "speedModeNow";
    level.saveFlagName_speedModeEver = "speedModeEver";
    level.saveFlagName_hasRPG = "rpg";
    level.saveFlagName_eleOverrideNow = "eleOverrideNow";
    level.saveFlagName_eleOverrideEver = "eleOverrideEver";
    level.saveFlagName_anyPctNow = "anyPctNow";
    level.saveFlagName_anyPctEver = "anyPctEver";
    level.saveFlagName_hardTAS = "hardTAS";

    level.saveFlags = [];

    // Flags are hardcoded in database right now, so do NOT modify existing ones.
    // When adding, do the same in pla
    level.saveFlags[level.saveFlagName_cheating] = 1;
    level.saveFlags[level.saveFlagName_speedModeNow] = 2;
    level.saveFlags[level.saveFlagName_speedModeEver] = 4;
    level.saveFlags[level.saveFlagName_hasRPG] = 8;
    level.saveFlags[level.saveFlagName_eleOverrideNow] = 16;
    level.saveFlags[level.saveFlagName_eleOverrideEver] = 32;
    level.saveFlags[level.saveFlagName_anyPctNow] = 64;
    level.saveFlags[level.saveFlagName_anyPctEver] = 128;
    level.saveFlags[level.saveFlagName_hardTAS] = 256;
}

getFlagEleOverrideNow(save)
{
	return (save.flags & level.saveFlags[level.saveFlagName_eleOverrideNow]) != 0;
}

getFlagEleOverrideEver(save)
{
	return (save.flags & level.saveFlags[level.saveFlagName_eleOverrideEver]) != 0;
}

getUsedAnyPctNow(save)
{
    return (save.flags & level.saveFlags[level.saveFlagName_anyPctNow]) != 0;
}

getUsedAnyPctEver(save)
{
    return (save.flags & level.saveFlags[level.saveFlagName_anyPctEver]) != 0;
}

getUsedHardTAS(save)
{
    return (save.flags & level.saveFlags[level.saveFlagName_hardTAS]) != 0;
}

isCheating(save)
{
	return (save.flags & level.saveFlags[level.saveFlagName_cheating]) != 0;
}

hasSpeedModeNow(save)
{
	return (save.flags & level.saveFlags[level.saveFlagName_speedModeNow]) != 0;
}

hasSpeedModeEver(save)
{
	return (save.flags & level.saveFlags[level.saveFlagName_speedModeEver]) != 0;
}

hasRPG(save)
{
	return (save.flags & level.saveFlags[level.saveFlagName_hasRPG]) != 0;
}

createFlags()
{
	flags = 0;
	if(self openCJ\cheating::isCheating())
	{
		flags |= level.saveFlags[level.saveFlagName_cheating];
	}
	if(self openCJ\speedMode::hasSpeedMode())
	{
		flags |= level.saveFlags[level.saveFlagName_speedModeNow];
	}
	if(self openCJ\speedMode::hasSpeedModeEver())
	{
		flags |= level.saveFlags[level.saveFlagName_speedModeEver];
	}
	if(openCJ\weapons::isRPG(self getCurrentWeapon()))
	{
		flags |= level.saveFlags[level.saveFlagName_hasRPG];
	}
	if(openCJ\elevate::hasEleOverrideNow())
	{
		flags |= level.saveFlags[level.saveFlagName_eleOverrideNow];
	}
	if(openCJ\elevate::hasEleOverrideEver())
	{
		flags |= level.saveFlags[level.saveFlagName_eleOverrideEver];
	}
    if(openCJ\tas::hasHardTAS())
    {
        flags |= level.saveFlags[level.saveFlagName_hardTAS];
    }

    // TODO: implement any %

	return flags;
}

onRunCreated()
{
    self.savedPosition = undefined;
    self savePosition_initClient();
    self resetBackwardsCount();
}

canSaveError()
{
	if(self.sessionState != "playing")
	{
		return 1;
	}

	if(!self isOnGround())
	{
		return 2;
	}

	groundEntity = self getGroundEntity();

	if(isDefined(groundEntity) && !isDefined(groundEntity.canSaveOn) && false)
	{
		return 3;
	}

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
	self resetBackwardsCount();
}

canLoadError(backwardsCount)
{
    error = 0; // No error by default
    if((self.sessionState != "playing") && (self.sessionState != "spectator"))
    {
        error = 999;
    }
    else if(self openCJ\demos::isPlayingDemo())
    {
        error = 998;
    }
    else if(self openCJ\noclip::hasNoclip())
    {
        error = 4;
    }
    else
    {
        error = self savePosition_selectSave(backwardsCount);
    }

    if (error != 0) // Useful for debugging
    {
        //self iprintln("canLoadError: " + error);
    }
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
		{
			return i;
		}
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
	flags = self createFlags();
	FPSModeStr = self openCJ\fps::getCurrentFPSMode();
    FPSModeNum = self openCJ\fps::FPSModeToInt(FPSModeStr);
	saveNum = self openCJ\statistics::increaseAndGetSaveCount();
	self thread openCJ\historySave::saveToDatabase(origin, angles, entTargetName, numOfEnt, self openCJ\statistics::getExplosiveJumps(), self openCJ\statistics::getDoubleExplosives(), self openCJ\checkpoints::getCurrentCheckpointID(), FPSModeStr, flags);
	self savePosition(origin, angles, entNum, self openCJ\statistics::getExplosiveJumps(), self openCJ\statistics::getDoubleExplosives(), self openCJ\checkpoints::getCurrentCheckpointID(), FPSModeNum, flags, saveNum);
	return saveNum;
}

savePosition(org, angles, entNum, explosiveJumps, doubleExplosives, checkpointID, FPSMode, flags, numOfThisSave)
{
    // Local cache will be useful for various purposes
    self.savedPosition = spawnStruct();
    self.savedPosition.origin = org;
    self.savedPosition.angles = angles;
    self.savedPosition.entNum = entNum;
    self.savedPosition.explosiveJumps = explosiveJumps;
    self.savedPosition.doubleExplosives = doubleExplosives;
    self.savedPosition.checkpointID = checkpointID;
    self.savedPosition.FPSMode = FPSMode;
    self.savedPosition.flags = flags;
    self.savedPosition.numOfThisSave = numOfThisSave;

    self savePosition_save(org, angles, entNum, explosiveJumps, doubleExplosives, checkpointID, FPSMode, flags, numOfThisSave);
}

// Doesn't actually select a save, just uses what the player last used.
// Useful for if someone else wants to use this save (teleporting)
getCurrentSave()
{
    return self.savedPosition; // Can be undefined!
}

getSavedPosition(backwardsCount)
{
	error = self savePosition_selectSave(backwardsCount);
    if (error == 0) // No error
    {
        self.savedPosition = spawnStruct();
        self.savedPosition.origin = self savePosition_getOrigin();
        self.savedPosition.angles = self savePosition_getAngles();
        self.savedPosition.explosiveJumps = self savePosition_getExplosiveJumps();
        self.savedPosition.doubleExplosives = self savePosition_getDoubleExplosives();
        self.savedPosition.checkpointID = self savePosition_getCheckpointID();
        self.savedPosition.flags = self savePosition_getFlags();
        self.savedPosition.FPSMode = self openCJ\fps::FPSModeToString(self savePosition_getFPSMode());
        self.savedPosition.saveNum = self savePosition_getSaveNum();

        groundEntity = self savePosition_getGroundEntity();

        if(isDefined(groundEntity))
        {
            x = vectorScale(anglesToForward(groundEntity.angles), self.savedPosition.origin[0]);
            y = vectorScale(anglesToRight(groundEntity.angles), self.savedPosition.origin[1]);
            z = vectorScale(anglesToUp(groundEntity.angles), self.savedPosition.origin[2]);
            self.savedPosition.origin = groundEntity.origin + x + y + z;
            self.savedPosition.angles = (self.savedPosition.angles[0], self.savedPosition.angles[1] + groundEntity.angles[1], self.savedPosition.angles[2]);
        }

        return self.savedPosition;
    }

    return undefined;
}

incrementBackwardsCount(amount)
{
	if(amount == 0)
	{
		return self resetBackwardsCount();
	}
	else
	{
		self.savePosition_backwardsCount += amount;
	}
	return self.savePosition_backwardsCount;
}

resetBackwardsCount()
{
	self.savePosition_backwardsCount = 0;
	return 0;
}

getBackwardsCount()
{
	return self.savePosition_backwardsCount;
}

onPlayerCommand(args)
{
	switch(args[0])
	{
		case "save":
		{
			self openCJ\events\eventHandler::onSavePositionRequest();
			return true;
		}
		case "load":
		{
			self openCJ\events\eventHandler::onLoadPositionRequest(0);
			return true;
		}
		case "loadsecondary":
		{
			self openCJ\events\eventHandler::onLoadPositionRequest(1);
			return true;
		}
		case "mr":
		{
			if(isDefined(args[3]))
			{
				if(args[3] == "load")
				{
					self openCJ\events\eventHandler::onLoadPositionRequest(0);
					return true;
				}
				else if(args[3] == "save")
				{
					self openCJ\events\eventHandler::onSavePositionRequest();
					return true;
				}
				else if(args[3] == "loadsecondary")
				{
					self openCJ\events\eventHandler::onLoadPositionRequest(1);
					return true;
				}
			}
		}
	}
	return false;
}