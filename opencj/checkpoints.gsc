#include openCJ\util;

_checkpointPassed(cp, tOffset) //tOffset = -50 to 0, offset when cp was actually passed
{
	if(self openCJ\playerRuns::hasRunID() && self openCJ\checkpoints::checkpointHasID(cp))
	{
		runID = self openCJ\playerRuns::getRunID();
		cpID = self openCJ\checkpoints::getCheckpointID(cp);
		timePlayed = self openCJ\playTime::getTimePlayed() + tOffset;
		self thread storeCheckpointPassed(runID, cpID, timePlayed);
		self thread _notifyCheckpointPassed(runID, cpID, timePlayed);
	}
}

storeCheckpointPassed(runID, cpID, timePlayed)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;
	if(!self openCJ\playerRuns::hasRunID())
		return;
	if(self openCJ\cheating::isCheating())
		return;

	saveCount = self openCJ\statistics::getSaveCount();
	loadCount = self openCJ\statistics::getLoadCount();
	nadeJumps = self openCJ\statistics::getNadeJumps();
	nadeThrows = self openCJ\statistics::getNadeThrows();
	RPGJumps = self openCJ\statistics::getRPGJumps();
	RPGShots = self openCJ\statistics::getRPGShots();
	doubleRPGs = self openCJ\statistics::getDoubleRPGs();
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT checkpointPassed(" + runID + ", " + cpID + ", " + timePlayed + ", " + saveCount + ", " + loadCount + ", " + nadeJumps + ", " + nadeThrows + ", " + RPGJumps + ", " + RPGShots + ", " + doubleRPGs + ", " + self openCJ\playerRuns::getRunInstanceNumber() + ")");
	if(!isDefined(rows[0][0]))
	{
		self iPrintLnBold("This run was loaded by another instance of your account. Please reset. All progress will not be saved");
		self openCJ\playerRuns::printRunIDandInstanceNumber();
	}
}

_notifyCheckpointPassed(runID, cpID, timePlayed)
{
	self endon("disconnect");
	self notify("checkpointNotify");
	self endon("checkpointNotify");
	rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT MIN(cs.timePlayed) FROM checkpointStatistics cs INNER JOIN playerRuns pr ON pr.runID = cs.runID WHERE cs.cpID = " + cpID + " AND pr.runID != " + runID + " AND pr.finishcpID IS NOT NULL");
	self iprintln("cpid: " + cpID);
	if(rows.size && isDefined(rows[0][0]))
	{
		diff = timePlayed - int(rows[0][0]);
		if(diff > 0)
			self iprintln("You passed a checkpoint ^1+" + formatTimeString(diff, false));
		else if( diff < 0)
			self iprintln("You passed a checkpoint ^2-" + formatTimeString(-1 * diff, false));
		else
			self iprintln("You passed a checkpoint, no difference");
	}
	else
		self iprintln("You passed a checkpoint");
}

onInit()
{
	level.checkpoints_startCheckpoint = spawnStruct();
	level.checkpoints_startCheckpoint.isEleAllowed = false;
	level.checkpoints_startCheckpoint.childs = [];

	level.checkpoints_checkpoints = [];

	if(openCJ\mapid::hasMapID())
	{
		rows = openCJ\mySQL::mysqlSyncQuery("SELECT a.cpID, a.x, a.y, a.z, a.radius, a.onGround, GROUP_CONCAT(b.childCpID), a.ender, a.elevate, a.endShaderColor, c.bigBrotherID FROM checkpoints a LEFT JOIN checkpointConnections b ON a.cpID = b.cpID LEFT JOIN checkpointBrothers c ON a.cpID = c.cpID WHERE a.mapID = " + openCJ\mapid::getMapID() + " GROUP BY a.cpID");

		checkpoints = [];
		for(i = 0; i < rows.size; i++)
		{
			checkpoint = spawnStruct();
			checkpoint.id = int(rows[i][0]);
			checkpoint.origin = (int(rows[i][1]), int(rows[i][2]), int(rows[i][3]));
			checkpoint.radius = intOrUndefined(rows[i][4]);
			checkpoint.onGround = (int(rows[i][5]) != 0);
			if(!isDefined(rows[i][6]))
				checkpoint.childIDs = [];
			else
				checkpoint.childIDs = strTok(rows[i][6], ",");
			checkpoint.ender = rows[i][7];
			checkpoint.isEleAllowed = int(rows[i][8]);
			checkpoint.endShaderColor = rows[i][9];
			checkpoint.bigBrother = intOrUndefined(rows[i][10]);
			//if(isDefined(checkpoint.endShaderColor))
			//	printf("endshadercolor: " + checkpoint.endShaderColor + "\n");
			checkpoint.hasParent = false;
			checkpoints[checkpoints.size] = checkpoint;
		}

		for(i = 0; i < checkpoints.size; i++)
		{
			checkpoints[i].childs = [];
			for(j = 0; j < checkpoints[i].childIDs.size; j++)
			{
				found = false;
				for(k = 0; k < checkpoints.size; k++)
				{
					if(k == i)
						continue;
					if(checkpoints[k].id == int(checkpoints[i].childIDs[j]))
					{
						checkpoints[i].childs[checkpoints[i].childs.size] = checkpoints[k];
						checkpoints[i].ender = undefined; //cannot have enders on mid-route checkpoints
						checkpoints[k].hasParent = true;
						//printf("connecting checkpoint " + checkpoints[i].id + " to child cp " + checkpoints[k].id + "\n");
						found = true;
						break;
					}
				}
				if(!found)
					printf("WARNING: Could not find child " + checkpoints[i].childIDS[j] + " for checkpoint " + checkpoints[i].id + "\n");
			}
			checkpoints[i].childIDs = undefined;
			checkpoints[i].endCheckpoints = [];
		}
		for(i = 0; i < checkpoints.size; i++)
		{
			if(isDefined(checkpoints[i].bigBrother))
			{
				for(j = 0; j < checkpoints.size; j++)
				{
					if(checkpoints[j].id == checkpoints[i].bigBrother && checkpoints[j] != checkpoints[i])
					{
						checkpoints[i].bigBrother = checkpoints[j];
						break;
					}
				}
			}
		}
		for(i = 0; i < checkpoints.size; i++)
		{
			if(!checkpoints[i].hasParent)
				level.checkpoints_startCheckpoint.childs[level.checkpoints_startCheckpoint.childs.size] = checkpoints[i];
		}
		level.checkpoints_startCheckpoint.checkpointsFromStart = 0;

		level.checkpoints_checkpoints = checkpoints;
		enders = getAllEndCheckpoints();
		level.checkpoints_startCheckpoint.endCheckpoints = enders;
		level.checkpoints_startCheckpoint.enderName = _calculateEnderName(enders);
		if(!enders.size)
			level.checkpoints_startCheckpoint.checkpointsTillEnd = 0;

		for(i = 0; i < enders.size; i++)
		{
			openList = [];
			openList[openList.size] = enders[i];
			enders[i].endCheckpoints[enders[i].endCheckpoints.size] = enders[i];
			enders[i].checkpointsTillEnd = 0;
			closedList = enders;
			iterationNum = 0;
			while(openList.size)
			{
				newOpenList = [];
				for(j = 0; j < openList.size; j++)
				{
					if(!isDefined(openList[j].checkpointsTillEnd))
						openList[j].checkpointsTillEnd = iterationNum;
					parents = getCheckpointParents(openList[j]);
					if(!parents.size)
					{
						if(!isDefined(level.checkpoints_startCheckpoint.checkpointsTillEnd))
							level.checkpoints_startCheckpoint.checkpointsTillEnd = iterationNum + 1;
					}
					for(k = 0; k < parents.size; k++)
					{
						if(isInArray(parents[k], closedList))
							continue;
						if(isInArray(parents[k], openList))
							continue;
						if(isInArray(parents[k], newOpenList))
							continue;
						newOpenList[newOpenList.size] = parents[k];
						parents[k].endCheckpoints[parents[k].endCheckpoints.size] = enders[i];
					}
					closedList[closedList.size] = openList[j];
				}
				openList = newOpenList;
				iterationNum++;
			}
		}
		openList = level.checkpoints_startCheckpoint.childs;
		closedList = [];
		iterationNum = 1;
		while(openList.size)
		{
			newOpenList = [];
			for(j = 0; j < openList.size; j++)
			{
				if(!isDefined(openList[j].checkpointsFromStart))
					openList[j].checkpointsFromStart = iterationNum;
				for(k = 0; k < openList[j].childs.size; k++)
				{
					if(isInArray(openList[j].childs[k], closedList))
						continue;
					if(isInArray(openList[j].childs[k], openList))
						continue;
					if(isInArray(openList[j].childs[k], newOpenList))
						continue;
					newOpenList[newOpenList.size] = openList[j].childs[k];
				}
				closedList[closedList.size] = openList[j];
			}
			openList = newOpenList;
			iterationNum++;
		}
		for(i = 0; i < checkpoints.size; i++)
		{
			checkpoints[i].enderName = _calculateEnderName(checkpoints[i].endCheckpoints);
		}
	}
}

getEnderName(checkpoint)
{
	return checkpoint.enderName;
}

_calculateEnderName(endCheckpoints)
{
	enders = [];
	hasUndefinedEnders = false;
	for(i = 0; i < endCheckpoints.size; i++)
	{
		if(!isDefined(endCheckpoints[i].ender))
		{
			hasUndefinedEnders = true;
			continue;
		}
		if(!isInArray(endCheckpoints[i].ender, enders))
		{
			enders[enders.size] = endCheckpoints[i].ender;
		}
	}
	if(hasUndefinedEnders)
	{
		if(enders.size == 0)
		{
			return undefined;
		}
		else
		{
			return undefined;
		}
	}
	else
	{
		if(enders.size == 1)
		{
			return enders[0];
		}
		else
		{
			return undefined;
		}
	}
}

getCheckpointShaderColor(checkpoint)
{
	if(!isDefined(checkpoint))
		return undefined;
	ends = getEndCheckpoints(checkpoint);
	endShaderColors = [];
	undefined_endShaderColor = false;
	for(i = 0; i < ends.size; i++)
	{
		if(!isDefined(ends[i].endShaderColor))
			undefined_endShaderColor = true;
		else if(!isInArray(ends[i].endShaderColor, endShaderColors))
			endShaderColors[endShaderColors.size] = ends[i].endShaderColor;
			
	}
	if(endShaderColors.size != 1 || undefined_endShaderColor)
		return undefined;
	return endShaderColors[0];
}

isEleAllowed(checkpoint)
{
	return checkpoint.isEleAllowed;
}

getPassedCheckpointCount(checkpoint)
{
	return checkpoint.checkpointsFromStart;
}

getRemainingCheckpointCount(checkpoint)
{
	return checkpoint.checkpointsTillEnd;
}

getEndCheckpoints(checkpoint)
{
	return checkpoint.endCheckpoints;
}

getAllEndCheckpoints()
{
	enders = [];
	for(i = 0; i < level.checkpoints_checkpoints.size; i++)
	{
		if(level.checkpoints_checkpoints[i].childs.size == 0)
			enders[enders.size] = level.checkpoints_checkpoints[i];
	}
	return enders;
}

getCheckpointParents(checkpoint)
{
	parents = [];
	for(i = 0; i < level.checkpoints_checkpoints.size; i++)
	{
		for(j = 0; j < level.checkpoints_checkpoints[i].childs.size; j++)
		{
			if(level.checkpoints_checkpoints[i].childs[j] == checkpoint)
				parents[parents.size] = level.checkpoints_checkpoints[i];
		}
	}
	return parents;
}

checkpointHasID(cp)
{
	return (isDefined(cp) && isDefined(cp.id));
}

getCheckpointID(cp)
{
	return cp.id;
}

getCurrentCheckpointID()
{
	return self.checkpoints_checkpoint.id;
}

setCurrentCheckpointID(id)
{
	if(self openCJ\playerRuns::isRunFinished())
		return;

	oldcheckpoint = self.checkpoints_checkpoint;
	if(!isDefined(id))
		self.checkpoints_checkpoint = level.checkpoints_startCheckpoint;
	else
	{
		for(i = 0; i < level.checkpoints_checkpoints.size; i++)
		{
			if(level.checkpoints_checkpoints[i].id == id)
			{
				self.checkpoints_checkpoint = level.checkpoints_checkpoints[i];
				break;
			}
		}
	}
	if(self.checkpoints_checkpoint != oldcheckpoint)
		self openCJ\events\checkpointsChanged::main();
}

getCheckpoints()
{
	return self.checkpoints_checkpoint.childs;
}

getCheckpoint()
{
	return self.checkpoints_checkpoint;
}

onRunIDCreated()
{
	self.checkpoints_checkpoint = level.checkpoints_startCheckpoint;
}

onLoadPosition()
{
	self.previousOrigin = self.origin;
	self.previousOnground = true;
}

onSpawnPlayer()
{
	self.previousOrigin = self.origin;
	self.previousOnground = true;
}

filterOutBrothers(checkpoints)
{
	newcheckpoints = [];
	brothers = [];
	for(i = 0; i < checkpoints.size; i++)
	{
		if(isDefined(checkpoints[i].bigBrother))
			brothers[brothers.size] = checkpoints[i];
		else
			newcheckpoints[newcheckpoints.size] = checkpoints[i];
	}
	for(i = 0; i < brothers.size; i++)
	{
		if(!isInArray(brothers[i].bigBrother, newcheckpoints))
			newcheckpoints[newcheckpoints.size] = brothers[i].bigBrother;
	}
	return newcheckpoints;
}

whileAlive()
{
	for(i = 0; i < self.checkpoints_checkpoint.childs.size; i++)
	{
		if(!isDefined(self.checkpoints_checkpoint.childs[i].radius))
			continue;
		if(distanceSquared(self.origin, self.checkpoints_checkpoint.childs[i].origin) < self.checkpoints_checkpoint.childs[i].radius * self.checkpoints_checkpoint.childs[i].radius)
		{
			if(!self.checkpoints_checkpoint.childs[i].onGround || self isOnGround())
			{
				tOffset = 0;
				if(isDefined(self.previousOrigin) && self.previousOrigin != self.origin && distanceSquared(self.previousOrigin, self.origin) < 250 * 250 && (!self.checkpoints_checkpoint.childs[i].onGround || (isDefined(self.previousOnground) && self.previousOnground)))
				{
					checkpointDist = distance(self.origin, self.checkpoints_checkpoint.childs[i].origin);
					previousCheckpointDist = distance(self.previousOrigin, self.checkpoints_checkpoint.childs[i].origin);
					radius = self.checkpoints_checkpoint.childs[i].radius;
					if(checkpointDist < previousCheckpointDist)
					{
						tOffset = int(((radius - checkpointDist)/(previousCheckpointDist - checkpointDist)) * -50);
						//printf("\n prevdist: " + previousCheckpointDist + " dist: " + checkpointDist + " radius: " + radius + " tOffset: " + tOffset + "\n\n");
						if(tOffset > 0)
							tOffset = 0;
						else if(tOffset < -50)
							tOffset = -50;
					}
				}
				//printf("\ntOffset: " + tOffset + "\n\n");
				//self iprintlnbold("You passed checkpoint with ID " + self.checkpoints_checkpoint.childs[i].id);
				cp = self.checkpoints_checkpoint.childs[i];
				self.checkpoints_checkpoint = self.checkpoints_checkpoint.childs[i];
				if(cp.childs.size == 0)
				{
					if(isDefined(cp.bigBrother))
					{
						self openCJ\events\runFinished::main(cp.bigBrother, tOffset);
					}
					else
					{
						self openCJ\events\runFinished::main(cp, tOffset);
					}
				}
				else
				{
					if(isDefined(cp.bigBrother))
					{
						self _checkpointPassed(cp.bigBrother, tOffset);
						self openCJ\showRecords::onCheckpointPassed(cp.bigBrother, self openCJ\playTime::getTimePlayed() + tOffset);
					}
					else
					{
						self _checkpointPassed(cp, tOffset);
						self openCJ\showRecords::onCheckpointPassed(cp, self openCJ\playTime::getTimePlayed() + tOffset);
					}
					self openCJ\events\checkpointsChanged::main();
				}
				break;
			}
		}
	}
	self.previousOrigin = self.origin;
	self.previousOnground = self isOnground();
}