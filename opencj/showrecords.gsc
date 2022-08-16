#include openCJ\util;

onInit()
{
	level.showRecordsHighlightShader = "white";
	precacheShader(level.showRecordsHighlightShader);
}

onCheckpointsChanged()
{
	self thread _getRecords(self openCJ\checkpoints::getCheckpoints(), false);
}

onCheckpointPassed(cp, timems)
{
	cps = [];
	cps[0] = cp;
	self thread _getRecords(cps, 1, timems);
}

onRunFinished(cp)
{
	cps = [];
	cps[0] = cp;
	timems = self openCJ\statistics::getTimePlayed();
	self thread _getRecords(cps, 2, timems);
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
	self.showRecordsHighlight setShader(level.showRecordsHighlightShader, 195, 11);
	self _hideRecords(true);
}

onSpectatorClientChanged(newClient)
{
	if(!isDefined(newClient))
		self _hideRecords(false);
	else
	{
		if(newClient openCJ\playerRuns::isRunFinished())
		{
			timems = newClient openCJ\statistics::getTimePlayed();
			self _updateRecords(newClient, newClient.showRecords_rows, timems, true);
		}
		else
			self _updateRecords(newClient, newClient.showRecords_rows, undefined, true);
	}
}

onPlayerKilled(inflictor, attacker, damage, meansOfDeath, weapon, vDir, hitLoc, psOffsetTime, deathAnimDuration)
{
	self _hideRecords(false);
}

onRunIDCreated()
{
	self.nextUpdate = 0;
	self _hideRecords(false);
	self.showRecords_rows = [];
	self thread _getRecords(self openCJ\checkpoints::getCheckpoints(), 0);
}

onSpawnSpectator()
{
	self _hideRecords(false);
}

onSpawnPlayer()
{
	self.nextUpdate = 0;
}

_hideRecords(force)
{
	if(force || self.showRecords_nameString != "")
		self setClientCvar("openCJ_records_names", "");
	if(force || self.showRecords_timeString != "")
		self setClientCvar("openCJ_records_times", "");
	self.showRecords_nameString = "";
	self.showRecords_timeString = "";
	self.showRecordsHighlight.alpha = 0;
}

_getRecords(checkpoints, persist, timems)
{
	
	self endon("disconnect");

	if(persist != 1)
	{
		self notify("writeRecordsRunning");
		self endon("writeRecordsRunning");
	}

	checkpointString = "(NULL";
	for(i = 0; i < checkpoints.size; i++)
	{
		if(self openCJ\checkpoints::checkpointHasID(checkpoints[i]))
			checkpointString += ", " + self openCJ\checkpoints::getCheckpointID(checkpoints[i]);
	}
	checkpointString += ")";
	printf("call to getrecords for checkpoint " + checkpointString + "\n");
	query = "SELECT c.playerName, b.timePlayed FROM (SELECT timePlayed, runID, playerID FROM (SELECT  @prev := '') init JOIN (SELECT playerID != @prev AS first, @prev := playerID, timePlayed, runID, playerID FROM (SELECT cs.timePlayed, pr.runID, pr.playerID FROM checkpointStatistics cs INNER JOIN playerRuns pr ON pr.runID = cs.runID WHERE cs.cpID IN " + checkpointString + " AND pr.finishcpID IS NOT NULL AND cs.runID != " + self openCJ\playerRuns::getRunID() + ") a ORDER BY playerID, timePlayed ASC) x WHERE first ORDER BY timePlayed ASC LIMIT 10) b INNER JOIN playerInformation c ON c.playerID = b.playerID";

	rows = self openCJ\mySQL::mysqlAsyncQuery(query);

	if(!self openCJ\playerRuns::isRunFinished())
	{
		if(persist == 0)
			self.showRecords_rows = rows;
		else if(persist == 1)
			self.showRecords_persistTime = getTime() + 2000;
		else
			return;
	}
	else if(persist == 2)
		self.showRecords_rows = rows;
	else
		return;

	if(persist)
	{
		specs = self getSpectatorList(true);
		for(i = 0; i < specs.size; i++)
			specs[i] _updateRecords(self, rows, timems, false);
	}
}

_updateRecords(client, rows, overrideTime, force)
{
	if(!force && (!isDefined(overrideTime) && isDefined(client.showRecords_persistTime) && client.showRecords_persistTime > getTime()))
		return;
	if(client.sessionState != "playing")
		return;

	nameString = "";
	timeString = "";

	if(!isDefined(overrideTime))
		timePlayed = client openCJ\statistics::getTimePlayed();
	else
		timePlayed = overrideTime;

	for(i = 0; i < rows.size; i++)
	{
		if(int(rows[i][1]) > timePlayed)
		{
			for(j = rows.size; j > i; j--)
				rows[j] = rows[j - 1];
			break;
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
			timeString += formatTimeString(int(rows[i][1]), true) + "\n";
		else
			timeString += formatTimeString(int(rows[i][1]), false) + "\n";
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
	if(!self openCJ\playerRuns::isRunFinished())
	{
		specs = self getSpectatorList(true);
		for(i = 0; i < specs.size; i++)
			specs[i] _updateRecords(self, self.showRecords_rows, undefined, false);
	}
}