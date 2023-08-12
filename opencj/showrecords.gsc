#include openCJ\util;

onInit()
{
	level.showRecordsHighlightShader = "white";
	precacheShader(level.showRecordsHighlightShader);
}

onPlayerConnect()
{
    self.showRecords_nameString = "";
    self.showRecords_timeString = "";

    self.showRecordsHighlight = newClientHudElem(self);
    self.showRecordsHighlight.horzAlign = "right";
    self.showRecordsHighlight.vertAlign = "top";
    self.showRecordsHighlight.alignX = "left";
    self.showRecordsHighlight.alignY = "bottom";
    self.showRecordsHighlight.x = -202;
    self.showRecordsHighlight.y = 50;
    self.showRecordsHighlight.archived = false;
    self.showRecordsHighlight.sort = -98;
    self.showRecordsHighlight.color = (0.75, 0.75, 0.75);
    self.showRecordsHighlight.hideWhenInMenu = true;
    self.showRecordsHighlight setShader(level.showRecordsHighlightShader, 195, 11);
    self _hideRecords(true);
}

onCheckpointsChanged()
{
	self thread _getRecords(self openCJ\checkpoints::getCurrentChildCheckpoints(), false);
}

onCheckpointPassed(cp, timems)
{
	cps = [];
	cps[0] = cp;
	self thread _getRecords(cps, 1, timems);
}

onStartDemo()
{
    specs = self getSpectatorList(true);
    for(i = 0; i < specs.size; i++)
    {
        specs[i] _hideRecords(true);
    }
}

onRunRestored()
{
    self _runChanged();
}

onRunStarted()
{
    self _runChanged();
}

onRunCreated()
{
    specs = self getSpectatorList(true); // true -> include self as spectator
    for(i = 0; i < specs.size; i++)
    {
        specs[i] _hideRecords(true);
    }
}

onRunStopped()
{
    specs = self getSpectatorList(true); // true -> include self as spectator
    for(i = 0; i < specs.size; i++)
    {
        specs[i] _hideRecords(true);
    }
}

onSpawnSpectator()
{
	self _hideRecords(true);
}

onSpawnPlayer()
{
	self.nextUpdate = 0;
}

onRunFinished(cp)
{
	cps = [];
	cps[0] = cp;
	timems = self openCJ\playTime::getTimePlayed();
	self thread _getRecords(cps, 2, timems);
}

onSpectatorClientChanged(newClient)
{
	if(!isDefined(newClient))
	{
		self _hideRecords(true);
	}
	else
	{
		if(newClient openCJ\demos::isPlayingDemo())
		{
			self _hideRecords(true);
		}
		else if(newClient openCJ\playerRuns::isRunFinished())
		{
			timems = newClient openCJ\playTime::getTimePlayed();
			self _updateRecords(newClient, newClient.showRecords_rows, timems, true);
		}
		else if (newClient openCJ\playerRuns::hasRunID())
		{
			self _updateRecords(newClient, newClient.showRecords_rows, undefined, true);
		}
	}
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	self _hideRecords(false);
}

_runChanged()
{
    self.nextUpdate = 0;
    self _hideRecords(false);
    self.showRecords_rows = [];
    self thread _getRecords(self openCJ\checkpoints::getCurrentChildCheckpoints(), 0);
}

_hideRecords(force)
{
	if(force || self.showRecords_nameString != "")
	{
		self setClientCvar("openCJ_records_names", "");
	}
	if(force || self.showRecords_timeString != "")
	{
		self setClientCvar("openCJ_records_times", "");
	}
	self.showRecords_nameString = "";
	self.showRecords_timeString = "";
	self.showRecordsHighlight.alpha = 0;
}

_getRecords(checkpoints, persist, timems)
{
    self endon("disconnect");
	if (!self openCJ\playerRuns::hasRunID())
    {
        return;
    }

	if(persist != 1)
	{
		self notify("writeRecordsRunning");
		self endon("writeRecordsRunning");
	}

	checkpointString = "(NULL";
	checkpoints = openCJ\checkpoints::filterOutBrothers(checkpoints);
	for(i = 0; i < checkpoints.size; i++)
	{
        cpID = openCJ\checkpoints::getCheckpointID(checkpoints[i]);
        if (isDefined(cpID))
        {
            checkpointString += ", " + cpID;
        }
	}
	checkpointString += ")";

    // TODO after alpha: make configurable so that it's not always based on time but based on player's current run type (defaults to time, but can be low RPG, ...)

    // For the checkpoint that was just passed, grab the player name and time played of up to 10 finished runs ordered by timePlayed (fastest first).
    // The query does this by:
    //  - finding runs by matching runID between playerRuns and checkpointStatistics to get the necessary information
    //  - verifying that the runs are finished by checking finishcpID having a value
    //  - verifying that it is not the current run by comparing runID
    //  - grabbing the player name by matching playerID between playerRuns and playerInformation
    //  - only selecting one best run per player (that's what the @prev is for, it compares it to the previous entry as it's sorted by playerID)

    // TODO: Declaring user variables in expressions like this is deprecated. Should be replaced with updated query, like the one leaderboard is using.

	query = "SELECT c.playerName, b.timePlayed FROM (" +
                "SELECT timePlayed, runID, playerID FROM (SELECT  @prev := '') init JOIN (" + 
                    "SELECT playerID != @prev AS first, @prev := playerID, timePlayed, runID, playerID FROM (" + 
                        "SELECT cs.timePlayed, pr.runID, pr.playerID " +
                        "FROM checkpointStatistics cs INNER JOIN playerRuns pr ON pr.runID = cs.runID " + 
                        "WHERE cs.cpID IN " + checkpointString +
                        " AND pr.finishcpID IS NOT NULL" + 
                        " AND cs.runID != " + self openCJ\playerRuns::getRunID() +
                    ") a " + 
                    "ORDER BY playerID, timePlayed ASC" +
                ") x " +
                "WHERE first ORDER BY timePlayed ASC LIMIT 10" +
            ") b INNER JOIN playerInformation c ON c.playerID = b.playerID";
    
    printf("getRecords query:\n" + query + "\n"); // Debug

	rows = self openCJ\mySQL::mysqlAsyncQuery(query);

	if(!self openCJ\playerRuns::isRunFinished())
	{
		if(persist == 0)
		{
			self.showRecords_rows = rows;
		}
		else if(persist == 1)
		{
			self.showRecords_persistTime = getTime() + 2000;
		}
		else
		{
			return;
		}
	}
	else if(persist == 2)
		self.showRecords_rows = rows;
	else
		return;

	if(persist)
	{
		specs = self getSpectatorList(true);
		for(i = 0; i < specs.size; i++)
		{
			specs[i] _updateRecords(self, rows, timems, false);
		}
	}
}

_updateRecords(client, rows, overrideTime, force)
{
    if(!force && (!isDefined(overrideTime) && isDefined(client.showRecords_persistTime) && client.showRecords_persistTime > getTime()))
    {
        return;
    }
    if(client.sessionState != "playing")
    {
        return;
    }

	nameString = "";
	timeString = "";

	if(!isDefined(overrideTime))
	{
		timePlayed = client openCJ\playTime::getTimePlayed();
	}
	else
	{
		timePlayed = overrideTime;
	}

	i = 0;
	if(isDefined(rows))
	{
		for(; i < rows.size; i++)
		{
			if(int(rows[i][1]) > timePlayed)
			{
				for(j = rows.size; j > i; j--)
				{
					rows[j] = rows[j - 1];
				}
				break;
			}
		}
	}

	ownNum = i;
	rows[i][0] = client.name;
	rows[i][1] = timePlayed;
	self.showRecordsHighlight.y = 50 + 12 * ownNum;
	self.showRecordsHighlight.alpha = 0.75;
			
	for(i = 0; i < rows.size; i++)
	{
		nameString += rows[i][0] + "\n";
		if(ownNum == i && !isDefined(overrideTime))
		{
			timeString += formatTimeString(int(rows[i][1]), true) + "\n";
		}
		else
		{
			timeString += formatTimeString(int(rows[i][1]), false) + "\n";
		}
	}
	if(self.showRecords_nameString != nameString)
	{
		self setClientCvar("openCJ_records_names", nameString);
		self.showRecords_nameString = nameString;
	}
	if(self.showRecords_timeString != timeString)
	{
		self setClientCvar("openCJ_records_times", timeString);
		self.showRecords_timeString = timeString;
	}
}

whileAlive()
{
    if (self openCJ\demos::isPlayingDemo())
    {
        return;
    }
    if (self openCJ\playerRuns::isRunFinished() || !self openCJ\playerRuns::hasRunID() || !self openCJ\playerRuns::hasRunStarted())
    {
        return;
    }
    if (!isDefined(self.showRecords_rows))
    {
        return;
    }

    specs = self getSpectatorList(true);
    for(i = 0; i < specs.size; i++)
    {
        specs[i] _updateRecords(self, self.showRecords_rows, undefined, false);
    }
}