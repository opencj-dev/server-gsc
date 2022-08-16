#include openCJ\util;

onInit()
{
	openCJ\commands::registerCommand("vote", "Vote", ::vote);
}

vote(args) //say !vote map mapname or !vote yes/no
{
	if(!self openCJ\login::isLoggedIn())
		return;
	if(isDefined(args[2]) && args[2] == "map" && isDefined(args[3]))
	{
		self thread _doVoteMap(args[3]);
	}
	else if(isDefined(args[2]) && (args[2] == "yes" || args[2] == "no"))
	{
		vote = (args[2] == "yes");
		if(isDefined(self.voted) && self.voted == vote)
			return;
		self.voted = vote;
		level _updateVoteCount();
	}
}

onPlayerLogin()
{
	if(isDefined(level.vote))
	{
		self _setMapVoteImage(level.vote.mapImage);
		self _writeVoteCounts();
		self _writeVoteString();
	}
	else
	{
		self setClientCvar("openCJ_voteString", "");
		self _setMapVoteImage();
	}
}

getMapImage(map)
{
	if(isDefined(map))
	{
		switch(map)
		{
			case "jm_pier_2":
				return "jhs_jm_pier_2";
		}
	}
	return "white";
}

onPlayerDisconnect()
{
	level _updateVoteCount();
}

_setMapVoteImage(image)
{
	if(isDefined(image))
		self setClientCvar("openCJ_mapvoteImage", image);
	else
		self setClientCvar("openCJ_mapvoteImage", "");
}

_doVoteMap(mapname)
{
	self endon("disconnect");
	map = _findMapByName(mapname, true);
	if(!isDefined(map))
		return;
	if(isDefined(level.vote))
	{
		self iprintln("Another vote is already in progress");
		return;
	}
	level.vote = spawnStruct();
	level.vote.map = map;
	level.vote.mapImage = getMapImage(level.vote.map);
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i].voted = undefined;
	//self.voted = true;
	iprintln(self.name + " ^7 called a vote to change the map to " + map);
	level _updateVoteCount();
	if(isDefined(level.vote))
		level thread _monitorVote();
}

_findMapByName(string, recurse)
{
	self endon("disconnect");
	if(!recurse)
		rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT mapname FROM mapids WHERE mapname LIKE '%" + openCJ\mySQL::escapeString(string) + "%'");
	else
		rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT mapname FROM mapids WHERE mapname = '" + openCJ\mySQL::escapeString(string) + "'");
	if(rows.size == 1)
		return rows[0][0];
	else if(rows.size)
	{
		self iprintln("Multiple matches found: ");
		for(i = 0; i < rows.size; i++)
		{
			self iprintln(rows[i][0]);
		}
	}
	else if(recurse)
		return self _findMapByName(string, false);
	else
		self iprintln("Map not found");
}

_updateVoteCount()
{
	if(!isDefined(level.vote))
		return;
	players = getEntArray("player", "classname");
	yesCount = 0;
	noCount = 0;
	totalCount = 0;
	for(i = 0; i < players.size; i++)
	{
		if(players[i] openCJ\login::isLoggedIn())
		{
			if(isDefined(players[i].voted))
			{
				if(players[i].voted)
					yesCount++;
				else
					noCount++;
			}
			totalCount++;
		}
	}
	if(noCount > int(totalCount / 2))
	{
		//vote failed
		_voteFailed();
	}
	else if(yesCount > int(totalCount / 2))
	{
		//vote success
		_voteSuccess();
	}

	else
	{
		level.vote.voteCounts = "Yes: " + yesCount + "\nNo: " + noCount;
		for(i = 0; i < players.size; i++)
		{
			if(players[i] openCJ\login::isLoggedIn())
				players[i] _writeVoteCounts();
		}
	}
}

_destroyVote()
{
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(players[i] openCJ\login::isLoggedIn())
		{
			players[i] _writeVoteString();
			players[i] _setMapVoteImage();
		}
	}
}

_writeVoteString()
{
	self setClientCvar("openCJ_voteString", level.vote.voteString);
}

_getVoteString(time)
{
	if(isDefined(level.vote.map))
	{
		return "Change map to " + level.vote.map + " (" + time + ")";
	}
	return "";
}

_writeVoteCounts()
{
	self setClientCvar("openCJ_voteCounts", level.vote.voteCounts);
}

_monitorVote()
{
	players = getEntArray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(!players[i] openCJ\login::isLoggedIn())
			continue;
		players[i] _setMapVoteImage(level.vote.mapImage);
		players[i] _writeVoteCounts();
	}
	for(time = 30; time >= 0; time--)
	{
		if(!isDefined(level.vote))
			return;
		level.vote.voteString = _getVoteString(time);
		players = getEntArray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if(players[i] openCJ\login::isLoggedIn())
				players[i] _writeVoteString();
		}
		wait 1;
	}
	if(isDefined(level.vote))
		_voteFailed();
}

_voteFailed()
{
	level.vote.voteString = "";
	iprintln("Vote failed. Not enough players voted yes");
	_destroyVote();
	level.vote = undefined;
}

_voteSuccess()
{
	if(isDefined(level.vote.map))
	{
		iprintln("The vote for " + level.vote.map + " passed");
		thread _changeMap(level.vote.map);
	}
	level.vote.voteString = "";
	_destroyVote();
	level.vote = undefined;
}

_changeMap(map)
{
	wait 5;
	map(map);
}

