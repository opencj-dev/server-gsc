#include openCJ\util;

_checkpointPassed(cp, tOffset) //tOffset = -50 to 0, offset when cp was actually passed
{
    timePlayed = self openCJ\playTime::getTimePlayed();
    cpID = getCheckpointID(cp);
    if (!isDefined(cpID))
    {
        return;
    }

    // The run may be paused, but at least we want the player to have a run to do anything with the checkpoints
    // Otherwise they are not even shown visually.
	if(self openCJ\playerRuns::hasRunID())
	{
        if (!self openCJ\playerRuns::isRunPaused())
        {
            cpPassedTime = timePlayed + tOffset;
            self openCJ\showRecords::onCheckpointPassed(cp, cpPassedTime);

            runID = self openCJ\playerRuns::getRunID();
            self thread storeCheckpointPassed(runID, cpID, cpPassedTime);
            self thread _notifyCheckpointPassed(runID, cpID, cpPassedTime);
        }
        else
        {
            self iprintln("^5You passed a checkpoint, but your run is paused.");
        }
	}
}

storeCheckpointPassed(runID, cpID, timePlayed)
{
	if(self openCJ\playerRuns::isRunFinished() || !self openCJ\playerRuns::hasRunID() || self openCJ\cheating::isCheating())
	{
		return;
	}

	saveCount = self openCJ\statistics::getSaveCount();
	loadCount = self openCJ\statistics::getLoadCount();
	explosiveJumps = self openCJ\statistics::getExplosiveJumps(); // RPG/nade jump
	explosiveLaunches = self openCJ\statistics::getExplosiveLaunches(); // RPG launch / nade throw
    doubleExplosives = self openCJ\statistics::getDoubleExplosives(); // Double RPGs
    FPSMode = self openCJ\statistics::getFPSMode();
    usedEle = self openCJ\statistics::getUsedEle();
    usedAnyPct = self openCJ\statistics::getUsedAnyPct();
    usedTAS = self openCJ\statistics::getUsedTAS();

    // This is a store procedure in SQL database
    filterStr = "'" + FPSMode + "'" + ", " + usedEle + ", " + usedAnyPct + ", " + usedTAS;
    explosiveStr = explosiveJumps + ", " + explosiveLaunches + ", " + doubleExplosives;
    query = "SELECT checkpointPassed(" + runID + ", " + cpID + ", " + timePlayed + ", " + saveCount + ", " + loadCount + ", " + explosiveStr + ", " + filterStr + ", " + self openCJ\playerRuns::getRunInstanceNumber() + ")";
    printf("Executing checkpointPassed query:\n" + query + "\n");  // Debug

    rows = self openCJ\mySQL::mysqlAsyncQuery(query);
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
    if(rows.size && isDefined(rows[0][0]))
    {
        diff = timePlayed - int(rows[0][0]);
        if(diff > 0)
        {
            self iprintln("You passed a checkpoint ^1+" + formatTimeString(diff, false));
        }
        else if( diff < 0)
        {
            self iprintln("You passed a checkpoint ^2-" + formatTimeString(-1 * diff, false));
        }
        else
        {
            self iprintln("You passed a checkpoint, no difference");
        }
    }
    else
    {
        self iprintln("You passed a checkpoint");
    }
}

onStartDemo()
{
	self.checkpoints_checkpoint = level.checkpoints_startCheckpoint;
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

        // First we obtain all checkpoints for the current map from the database
		checkpoints = [];
		for(i = 0; i < rows.size; i++)
		{
			checkpoint = spawnStruct();
			checkpoint.id = int(rows[i][0]);
			checkpoint.origin = (int(rows[i][1]), int(rows[i][2]), int(rows[i][3]));
			checkpoint.radius = intOrUndefined(rows[i][4]);
			checkpoint.onGround = (int(rows[i][5]) != 0);
			if(!isDefined(rows[i][6]))
			{
				checkpoint.childIDs = [];
			}
			else
			{
				checkpoint.childIDs = strTok(rows[i][6], ",");
			}
			checkpoint.ender = rows[i][7];
			checkpoint.isEleAllowed = int(rows[i][8]);
			checkpoint.endShaderColor = rows[i][9];
			checkpoint.bigBrother = intOrUndefined(rows[i][10]);
			checkpoint.hasParent = false;
			checkpoints[checkpoints.size] = checkpoint;
		}

        // Now fill in all the children for each checkpoint
		for(i = 0; i < checkpoints.size; i++)
		{
			checkpoints[i].childs = [];
			for(j = 0; j < checkpoints[i].childIDs.size; j++)
			{
				found = false;
				for(k = 0; k < checkpoints.size; k++)
				{
					if(k == i)
					{
						continue; // Skip self
					}

                    // Find a checkpoint that is a child of the checkpoint for which we're adding the children
					if(checkpoints[k].id == int(checkpoints[i].childIDs[j]))
					{
						checkpoints[i].childs[checkpoints[i].childs.size] = checkpoints[k];
						checkpoints[i].ender = undefined; // This is not the last checkpoint in a route, so it mustn't have an ender
						checkpoints[k].hasParent = true;
						found = true;
						break;
					}
				}

                // Checkpoint has childIDs, but we could not find any children checkpoints..
				if(!found)
				{
					printf("WARNING: Could not find child " + checkpoints[i].childIDS[j] + " for checkpoint " + checkpoints[i].id + "\n");
				}
			}
			checkpoints[i].childIDs = undefined; // This was a CSV list, no longer need it now that the children are filled in
            checkpoints[i].hasChildren = (checkpoints[i].childs.size > 0);
			checkpoints[i].endCheckpoints = [];
		}

        // Fill in the big brother checkpoints 
		for(i = 0; i < checkpoints.size; i++)
		{
            // Ah, this checkpoint has a big brother, let's find it
			if(isDefined(checkpoints[i].bigBrother))
			{
				for(j = 0; j < checkpoints.size; j++)
				{
                    if (i == j)
                    {
                        continue; // Skip self
                    }

					if(checkpoints[i].bigBrother == checkpoints[j].id)
					{
                        // OK, this checkpoint's id is the big brother we were searching
						checkpoints[i].bigBrother = checkpoints[j];
						break;
					}
				}
			}
		}

        // All checkpoints without parents are deemed to be 'start' checkpoints, so fill them in
		for(i = 0; i < checkpoints.size; i++)
		{
			if(!checkpoints[i].hasParent)
			{
				level.checkpoints_startCheckpoint.childs[level.checkpoints_startCheckpoint.childs.size] = checkpoints[i];
			}
		}
		level.checkpoints_startCheckpoint.checkpointsFromStart = 0;

		level.checkpoints_checkpoints = checkpoints;

        // Now it's time to figure out the route that each checkpoint is part of.
        // Pathfinding algorithm. If a checkpoint ends up at 1 ender, then the route is clear. Otherwise we know the checkpoints' multiple routes.
		enders = getAllEndCheckpoints();
		level.checkpoints_startCheckpoint.endCheckpoints = enders;
		level.checkpoints_startCheckpoint.enderName = _determineEnderName(enders);
		if(enders.size <= 0)
		{
			level.checkpoints_startCheckpoint.checkpointsTillEnd = 0;
		}
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
					{
						openList[j].checkpointsTillEnd = iterationNum;
					}
					parents = getCheckpointParents(openList[j]);
					if(!parents.size)
					{
						if(!isDefined(level.checkpoints_startCheckpoint.checkpointsTillEnd))
						{
							level.checkpoints_startCheckpoint.checkpointsTillEnd = iterationNum + 1;
						}
					}
					for(k = 0; k < parents.size; k++)
					{
						if(isInArray(parents[k], closedList))
						{
							continue;
						}
						if(isInArray(parents[k], openList))
						{
							continue;
						}
						if(isInArray(parents[k], newOpenList))
						{
							continue;
						}
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
				{
					openList[j].checkpointsFromStart = iterationNum;
				}
				for(k = 0; k < openList[j].childs.size; k++)
				{
					if(isInArray(openList[j].childs[k], closedList))
					{
						continue;
					}
					if(isInArray(openList[j].childs[k], openList))
					{
						continue;
					}
					if(isInArray(openList[j].childs[k], newOpenList))
					{
						continue;
					}
					newOpenList[newOpenList.size] = openList[j].childs[k];
				}
				closedList[closedList.size] = openList[j];
			}
			openList = newOpenList;
			iterationNum++;
		}

        // Finally, for each checkpoint we can fill in the route name. Which means we can also note down all the routes in the map and their end checkpoints for leaderboard use.
        // There may be end checkpoints with unnamed routes. We want to fix those first.
        // The following function both fills in route names (unnamed1, unnamed2, ...) for unnamed routes, as well as store all routes it encounters into level.routeEnders
        _parseRoutesAndFixUnnamedRoutes();
	}
}

_parseRoutesAndFixUnnamedRoutes()
{
    // Goal: fill in names for unnamed routes, and store all (not only unnamed) routes into level.routeEnders for later leaderboard use

    nextRouteNr = 1;
    level.routeEnders = []; // Will have all 'finish' checkpoint IDs for each route
    for (i = 0; i < level.checkpoints_checkpoints.size; i++)
    {
        checkpoint = level.checkpoints_checkpoints[i];
        if (checkpoint.hasChildren)
        {
            // Not an end checkpoint
            continue;
        }

        // Even if the checkpoint has an ender, bigBrother takes precedence and we'll encounter (or have encountered) that checkpoint.
        if (isDefined(checkpoint.bigBrother))
        {
            // All 'little brother' checkpoints link to the same big brother, but we do a quick check for corruption
            bigBro = checkpoint.bigBrother;
            if (isDefined(bigBro.bigBrother))
            {
                printf("WARNING: big brother is not as big as he thought..\n"); // We'd want to dump the ID, but since it has a big brother we shouldn't..
            }

            continue;
        }

        // Found an end checkpoint. Check if its ender has a name.
        if (isDefined(checkpoint.ender) && (checkpoint.ender.size > 0))
        {
            // Route is named, store this route name if it wasn't already known
            _storeRouteAndEndCheckpoint(checkpoint);
            continue;
        }

        // No route was found. Generate a name.
        checkpoint.ender = "unnamed_" + nextRouteNr;
        nextRouteNr++;

        // Store the (newly filled in) route name
        _storeRouteAndEndCheckpoint(checkpoint);
    }
}

_storeRouteAndEndCheckpoint(checkpoint)
{
    enderName = checkpoint.ender;
    if (!isDefined(level.routeEnders[enderName]))
    {
        level.routeEnders[enderName] = [];
    }

    // And add the end checkpoint for the route.
    level.routeEnders[enderName][level.routeEnders[enderName].size] = checkpoint;
}

getRouteNameForCheckpoint(checkpoint)
{
    if (!isDefined(checkpoint))
    {
        return undefined;
    }

    if (!isDefined(checkpoint.id))
    {
        if(isDefined(checkpoint.bigBrother))
        {
            checkpoint = checkpoint.bigBrother;
        }
        else
        {
            return undefined;
        }
    }

    return _determineEnderName(getEndCheckpoints(checkpoint));
}

_determineEnderName(endCheckpoints) // Argument is the end checkpoint(s) for a specific checkpoint
{
    if (!isDefined(endCheckpoints))
    {
        return undefined;
    }

    // Goal: determine what route a checkpoint is part of
    // This is used for displaying the route on screen, so if the player has not yet selected a route, we want to show nothing (undefined)
    enderName = undefined;
    for(i = 0; i < endCheckpoints.size; i++)
    {
        if(!isDefined(endCheckpoints[i].ender))
        {
            return undefined; // There is (at least) an unnamed ender in here. So we don't know the name of the route for sure.
        }

        // We already had an enderName from one of the other end checkpoints, and now another one
        if (isDefined(enderName))
        {
            return undefined; // Multiple ender names, can't know for sure which route
        }

        enderName = endCheckpoints[i].ender;
    }

    return enderName;
}

getCheckpointShaderColor(checkpoint)
{
	if(!isDefined(checkpoint))
	{
		return undefined;
	}
	ends = getEndCheckpoints(checkpoint);
	endShaderColors = [];
	undefined_endShaderColor = false;
	for(i = 0; i < ends.size; i++)
	{
		if(!isDefined(ends[i].endShaderColor))
		{
			undefined_endShaderColor = true;
		}
		else if(!isInArray(ends[i].endShaderColor, endShaderColors))
		{
			endShaderColors[endShaderColors.size] = ends[i].endShaderColor;
		}
	}
	if(endShaderColors.size != 1 || undefined_endShaderColor)
	{
		return undefined;
	}
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
    if (!isDefined(checkpoint))
    {
        return undefined;
    }

    endCheckpoints = [];
    if (!isDefined(checkpoint.hasChildren) || !checkpoint.hasChildren)
    {
        endCheckpoints[0] = checkpoint;
        return endCheckpoints;
    }
	return checkpoint.endCheckpoints;
}

getAllEndCheckpoints()
{
	enders = [];
	for(i = 0; i < level.checkpoints_checkpoints.size; i++)
	{
		if(level.checkpoints_checkpoints[i].childs.size == 0)
		{
			enders[enders.size] = level.checkpoints_checkpoints[i];
		}
	}
	return enders;
}

getAllCheckpoints()
{
    return level.checkpoints_checkpoints;
}

getCheckpointsForRoute(routeName)
{
    if (!isDefined(level.routeEnders[routeName]))
    {
        return undefined;
    }

    endCheckpointForRoute = undefined;
    for (i = 0; i < level.routeEnders[routeName]; i++)
    {
        if (!isDefined(level.routeEnders[routeName][i].bigBrother))
        {
            // Should only be one final checkpoint
            endCheckpointForRoute = level.routeEnders[routeName][i];
            break;
        }
    }

    if (!isDefined(endCheckpointForRoute))
    {
        printf("ERROR: all ender checkpoints have big brothers or none exist\n");
        return undefined;
    }

    // Get all checkpoint ids in the route from the end checkpoint id
    checkpointIdsInRoute = [];
    currentCheckpoint = endCheckpointForRoute;
    nextIdx = 0;
    for (i = 0; i < level.checkpoints_checkpoints.size; i++) // Using a for loop to prevent infinite loop
    {
        if (isDefined(currentCheckpoint.bigBrother))
        {
            currentCheckpoint = currentCheckpoint.bigBrother;
        }

        // Add this checkpoint as part of the route
        checkpointIdsInRoute[nextIdx] = currentCheckpoint.id;
        nextIdx++;

        // Continue with the parent of the checkpoint. If there is none, we are finished.
        parents = getCheckpointParents(currentCheckpoint);
        if (!isDefined(parents))
        {
            break; // No parents
        }

        if (parents.size > 0) // We're at the point where routes are splitting
        {
            break; // Multiple parents
        }

        currentCheckpoint = parents[0];
    }
}

getCheckpointParents(checkpoint)
{
	parents = [];
	for(i = 0; i < level.checkpoints_checkpoints.size; i++)
	{
		for(j = 0; j < level.checkpoints_checkpoints[i].childs.size; j++)
		{
			if(level.checkpoints_checkpoints[i].childs[j] == checkpoint)
			{
				parents[parents.size] = level.checkpoints_checkpoints[i];
			}
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
    id = undefined;

    // Checkpoint may not have an ID
    if (!isDefined(cp))
    {
        return; // That's a shame
    }

    if (!isDefined(cp.id))
    {
        if (!isDefined(cp.bigBrother))
        {
            return; // Nothing we can do
        }

        brotherCheckpoint = cp.bigBrother;
        for (i = 0; i < level.checkpoints.size; i++)
        {
            if (isDefined(brotherCheckpoint.id))
            {
                id = brotherCheckpoint.id;
                break; // Found it!
            }

            if (!isDefined(brotherCheckpoint.bigBrother))
            {
                break; // No luck
            }

            // Try the next one
            brotherCheckpoint = brotherCheckpoint.bigBrother;
        }
    }
    else
    {
        id = cp.id;
    }

	return id;
}

getCurrentCheckpointID()
{
	return self.checkpoints_checkpoint.id;
}

setCurrentCheckpointID(id)
{
	if(!self isPlayerReady() || self openCJ\playerRuns::isRunFinished())
	{
		return;
	}

	oldcheckpoint = self.checkpoints_checkpoint;
	if(!isDefined(id))
	{
		self.checkpoints_checkpoint = level.checkpoints_startCheckpoint;
	}
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
	{
		self openCJ\events\checkpointsChanged::main();
	}
}

getCurrentChildCheckpoints()
{
	return self.checkpoints_checkpoint.childs;
}

getCurrentCheckpoint()
{
	return self.checkpoints_checkpoint;
}

onRunCreated()
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
		{
			brothers[brothers.size] = checkpoints[i];
		}
		else
		{
			newcheckpoints[newcheckpoints.size] = checkpoints[i];
		}
	}
	for(i = 0; i < brothers.size; i++)
	{
		if(!isInArray(brothers[i].bigBrother, newcheckpoints))
		{
			newcheckpoints[newcheckpoints.size] = brothers[i].bigBrother;
		}
	}
	return newcheckpoints;
}

whileAlive()
{
	for(i = 0; i < self.checkpoints_checkpoint.childs.size; i++)
	{
		if(!isDefined(self.checkpoints_checkpoint.childs[i].radius))
		{
			continue;
		}
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
						if(tOffset > 0)
						{
							tOffset = 0;
						}
						else if(tOffset < -50)
						{
							tOffset = -50;
						}
					}
				}
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
					}
					else
					{
						self _checkpointPassed(cp, tOffset);
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