#include openCJ\util;

onInit()
{
    cmd = openCJ\commands_base::registerCommand("vote", "Vote for something. Usage: !vote <extend|map mp_mapname|yes|no>", ::vote, 1, 2, 0);

    level.vote = undefined; // Will be filled in with spawnStruct
    thread loop();
}

loop()
{
    while (1)
    {
        if (isDefined(level.isAutoExtendQueued) && level.isAutoExtendQueued && !isDefined(level.hasAutoExtended))
        {
            if (!isDefined(level.vote))
            {
                level.isAutoExtendQueued = false;
                level.hasAutoExtended = true;
                _setupVote(undefined, "Vote: extend time (30m)", undefined);
            }
        }
        wait .1;
    }
}

voteSingleArg(arg) // Helper for externally calling vote command
{
    args = [];
    args[0] = arg;
    vote(args);
}

vote(args) //args[0] = map, extend, yes/no
{
    if(!self openCJ\login::isLoggedIn())
    {
        return;
    }

    if(isValidBool(args[0]) && isDefined(level.vote)) // Yes/no
    {
        vote = strToBool(args[0]);

        // Don't allow vote to be cast twice
        if(isDefined(self.vote) && (self.vote == vote))
        {
            return;
        }

        self.vote = vote;
        level _updateVoteCount();
    }
    else
    {
        // Vote cooldown
        canVoteIn = int(self.canVoteAt - (getTime() / 1000) + 0.5);
        if (canVoteIn > 0)
        {
            self iprintln("You can vote in another ^1" + canVoteIn + "^7 seconds");
            return;
        }

        // If an auto extend is queued, don't allow player to vote (edge case)
        if (isDefined(level.isAutoExtendQueued) && level.isAutoExtendQueued)
        {
            return;
        }

        if((args[0] == "map") && isDefined(args[1]))
        {
            self thread _doVoteMap(args[1]); // TODO: check if map exists on disk?
        }
        else if(args[0] == "extend")
        {
            self thread _doVoteExtend();
        }
    }
}

onPlayerLogin()
{
    if(isDefined(level.vote))
    {
        self _setMapVoteImage(level.vote.mapImage);
        self _writeVoteCountString();
        self _writeVoteString();
    }
    else
    {
        self setClientCvar("openCJ_voteTimeString", "");
        self setClientCvar("openCJ_voteHeaderString", "");
        self _setMapVoteImage();
    }

    self _setVoteCooldown();
    self thread menuResponse();
}

_setVoteCooldown()
{
    self.canVoteAt = (getTime() / 1000) + 120; // 2 minute vote lockout at start and after voting
}

menuResponse()
{
    while (1)
    {
        self waittill("menuresponse", menu, response);
        if (response == "cjvoteyes")
        {
            self voteSingleArg("yes");
        }
        else if (response == "cjvoteno")
        {
            self voteSingleArg("no");
        }
    }
}

getMapImage(mapName)
{
    if(isDefined(mapName))
    {
        if (getCodVersion() == 4)
        {
            return "loadscreen_" + mapName;
        }
        switch(mapName)
        {
            case "jm_pier_2": return "jhs_jm_pier_2";
        }
    }
    return "default";
}

onPlayerDisconnect()
{
    level _updateVoteCount();
}

queueAutoExtendVote()
{
    if (!isDefined(level.hasAutoExtended) || !level.hasAutoExtended && !level.isAutoExtendQueued)
    {
        level.isAutoExtendQueued = true;
    }
}

_setMapVoteImage(image)
{
    if(isDefined(image))
    {
        self setClientCvar("openCJ_mapvoteImage", image);
    }
    else
    {
        self setClientCvar("openCJ_mapvoteImage", "");
    }
}

_doVoteMap(mapName)
{
    self endon("disconnect");

    // Only one vote at a time
    if(isDefined(level.vote))
    {
        self iprintln("Another vote is already in progress");
        return;
    }

    // Map needs to be found in db for vote to go through
    map = _findMapByName(mapName, true);
    if(!isDefined(map))
    {
        return;
    }

    // Create the vote object that serves as a hudElem
    _setupVote(map, "Vote: change map\n  " + map, self);
}

_doVoteExtend()
{
    self endon("disconnect");

    // Create the vote object that serves as a hudElem
    _setupVote(undefined, "Vote: extend time (30m)", self);
}

_setupVote(mapName, text, playerEnt)
{
    // Only one vote at a time
    if (isDefined(level.vote))
    {
        if (isDefined(playerEnt))
        {
            playerEnt iprintln("Another vote is already in progress");
        }
        return;
    }

    if (isDefined(playerEnt))
    {
        playerEnt _setVoteCooldown();
    }

    level.vote = spawnStruct();
    level.vote.str = text;
    if (isDefined(mapName))
    {
        level.vote.map = mapName;
    }
    else
    {
        level.vote.extend = true;
    }
    level.vote.mapImage = getMapImage(mapName);
    level.vote.yesCount = 0;
    level.vote.noCount  = 0;
    level.vote.timeLeft = 30; // Seconds

    // Initialize all players' initial votes
    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        players[i].vote = undefined;
    }

    // Let everyone know
    if (isDefined(playerEnt))
    {
        iprintln(playerEnt.name + " ^7started a vote");
        playerEnt.vote = true;
        // Add the player's vote
        level _updateVoteCount();
    }
    else
    {
        iprintln("Automatic extend time vote");
    }

    // Keep monitoring the vote
    if (isDefined(level.vote)) // Could have already passed/failed immediately
    {
        level thread _monitorVote();
    }
}

_findMapByName(string, recurse)
{
    self endon("disconnect");
    if(!recurse)
    {
        rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT mapname FROM mapids WHERE mapname LIKE '%" + openCJ\mySQL::escapeString(string) + "%'");
    }
    else
    {
        rows = self openCJ\mySQL::mysqlAsyncQuery("SELECT mapname FROM mapids WHERE mapname = '" + openCJ\mySQL::escapeString(string) + "'");
    }
    if(isDefined(rows) && (rows.size > 0))
    {
        if(rows.size == 1)
        {
            return rows[0][0];
        }
        else if (rows.size > 5)
        {
            self sendLocalChatMessage("Too many matches found (" + rows.size + ")");
        }
        else
        {
            self sendLocalChatMessage("Multiple matches found:");
            chatStr = "";
            for(i = 0; i < rows.size; i++)
            {
                if (i > 0)
                {
                    chatStr += ", ";
                }
                chatStr += rows[i][0];
            }

            self sendLocalChatMessage(chatStr);
        }
    }
    else if(recurse)
    {
        return self _findMapByName(string, false);
    }
    else
    {
        self sendLocalChatMessage("Map not found");
    }
    
    return undefined;
}

_updateVoteCount()
{
    if(!isDefined(level.vote))
    {
        return;
    }

    yesCount = 0;
    noCount = 0;
    totalEligiblePlayers = 0;

    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        if(players[i] openCJ\login::isLoggedIn())
        {
            if(isDefined(players[i].vote))
            {
                if(players[i].vote)
                {
                    yesCount++;
                }
                else
                {
                    noCount++;
                }
            }

            totalEligiblePlayers++;
        }
    }

    level.vote.yesCount = yesCount;
    level.vote.noCount = noCount;

    // Check if votes have passed a ratio to succeed or fail the vote now
    voteThreshold = int(totalEligiblePlayers / 2);
    if(noCount > voteThreshold)
    {
        _voteFailed();
    }
    else if(yesCount > voteThreshold)
    {
        _voteSuccess();
    }
    else
    {
        for(i = 0; i < players.size; i++)
        {
            if(players[i] openCJ\login::isLoggedIn())
            {
                players[i] _writeVoteCountString();
            }
        }
    }
}

_getVoteCountString()
{
    voteYesStr = "Yes: ";
    voteNoStr = "No:   ";

    if(isDefined(self.vote))
    {
        if (self.vote)
        {
            voteYesStr += "^2";
        }
        else
        {
            voteNoStr += "^1";
        }
    }
    voteYesStr += level.vote.yesCount;
    voteNoStr += level.vote.noCount;

    return voteYesStr + "^7\n" + voteNoStr + "^7";
}

_destroyVote()
{
    level.vote = undefined;

    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        players[i] _writeVoteString();
        players[i] _setMapVoteImage();
    }
}

_writeVoteString()
{
    if (isDefined(level.vote))
    {
        timeStr = "" + level.vote.timeLeft;
        if (level.vote.timeLeft < 5)
        {
            timeStr = "^1" + timeStr;
        }
        self setClientCvar("openCJ_voteTimeString", timeStr);
        self setClientCvar("openCJ_voteHeaderString", level.vote.str);
    }
    else
    {
        self setClientCvar("openCJ_voteTimeString", "");
        self setClientCvar("openCJ_voteHeaderString", "");
    }
}

_writeVoteCountString()
{
    self setClientCvar("openCJ_voteCounts", self _getVoteCountString());
}

_monitorVote()
{
    // Update the votes and menu for each player
    players = getEntArray("player", "classname");
    for(i = 0; i < players.size; i++)
    {
        if(!players[i] openCJ\login::isLoggedIn())
        {
            continue;
        }
        players[i] _writeVoteCountString();
    }

    // Start 30 second timer
    for(time = level.vote.timeLeft; time > 0; time--)
    {
        if(!isDefined(level.vote))
        {
            return;
        }

        // Update the vote string for everyone
        level.vote.timeLeft = time;
        players = getEntArray("player", "classname");
        for(i = 0; i < players.size; i++)
        {
            if(players[i] openCJ\login::isLoggedIn())
            {
                players[i] _setMapVoteImage(level.vote.mapImage);
                players[i] _writeVoteString();
            }
        }

        wait 1;
    }

    // If the vote went the full 30 seconds, then it means the vote failed
    if(isDefined(level.vote))
    {
        _voteFailed();
    }
}

_voteFailed()
{
    iprintln("Vote ^1failed^7");
    _destroyVote();
}

_voteSuccess()
{
    if(isDefined(level.vote.map))
    {
        iprintln("Vote ^2passed^7: " + level.vote.map);
        thread _changeMap(level.vote.map);
    }
    else if(isDefined(level.vote.extend))
    {
        iprintln("Vote ^2passed^7: " + "extend time");
        thread _extendTime(30);
    }

    _destroyVote();
}

_changeMap(map)
{
    iprintlnbold("Changing map to " + map + " in 5 seconds..");
    wait 5;
    openCJ\events\eventHandler::onMapChanging();
    setCvar("sv_maprotation", "map " + map);
    exitLevel(false);
}

_extendTime(minutes)
{
    openCJ\timeLimit::addTimeSeconds(minutes * 60);
}
