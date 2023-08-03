onInit()
{
    level.endVote = [];
    level.endVote["menu"] = "opencj_endmapvote";
    level.endVote["nrMaps"] = 9; // Hardcoded in menu
    level.endVote["prefix"] = "opencj_ui_end_";
    level.endVote["winning"] = undefined;

    // Define random maps for the next map vote
    level.endVote["maps"] = [];
    level.endVote["mapImages"] = [];
    level.endVote["votes"] = [];
    level.endVote["status"] = 0; // 0 = idle, 1 = voting, 2 = loading next map
    for (i = 0; i < level.endVote["nrMaps"]; i++)
    {
        // TODO fill in maps
        level.endVote["votes"][i] = 0;
    }

    // Fetch random maps from database for next vote
    query = "SELECT mapname FROM mapids WHERE inRotation = '1' AND mapName != '" + getDvar("mapname") + "' ORDER BY RAND() LIMIT " + level.endVote["nrMaps"];
    rows = opencj\mysql::mysqlAsyncQuery(query);
    if (isDefined(rows) && (rows.size > 0) && isDefined(rows[0][0]))
    {
        for(i = 0; i < rows.size; i++)
        {
            level.endVote["maps"][i] = rows[i][0];
            level.endVote["mapImages"][i] = "loadscreen_" + level.endVote["maps"][i];
        }
    }
    else
    {
        printf("Error: could not get random maps for end map vote...\n");
    }

    precacheMenu(level.endVote["menu"]);

    thread connections();
}

connections()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerConnected();
    }
}

onPlayerConnected()
{
    self.endVote = -1;

    self setClientDvar(level.endVote["prefix"] + "status", level.endVote["status"]); // Actual end map vote status
    self setClientDvar(level.endVote["prefix"] + "voted", ""); // Player hasn't voted

    winning = "";
    if (isDefined(level.endVote["winning"]))
    {
        winning = (level.endVote["winning"] + 1);
    }
     self setClientDvar(level.endVote["prefix"] + "winning", winning); // Which map is currently winning

    for (i = 0; i < level.endVote["nrMaps"]; i++)
    {
        nr = (i + 1); // Dvars for this start at 1
        self setClientDvar(level.endVote["prefix"] + "votes" + nr, level.endVote["votes"][i]);
        self setClientDvar(level.endVote["prefix"] + "mapname" + nr, level.endVote["maps"][i]);
        self setClientDvar(level.endVote["prefix"] + "mapimage" + nr, level.endVote["mapImages"][i]);
    }

    if (level.endVote["status"] > 0)
    {
        self openEndMapVote();
    }

    self thread onMenuResponse();
}

onPlayerDisconnect()
{
    if (!isDefined(self.endVote))
    {
        return;
    }

    vote = self.endVote;
    if (vote != -1)
    {
        removeVote(vote);
    }
}

onTimeLimitReached() // Called multiple times due to map vote
{
    level.endVote["status"]++;

    if (level.endVote["status"] == 1) // Start voting
    {
        level thread opencj\events\onMapEnded::main();
        opencj\timeLimit::muteTimerSound(true); // Mute second beep timer
        opencj\timeLimit::addTimeSeconds(20);
    }
    else if (level.endVote["status"] == 2) // Start loading next map
    {
        opencj\timeLimit::muteTimerSound(false); // Unmute second beep timer
        opencj\timeLimit::addTimeSeconds(3);
    }
    else // >=3
    {
        winnerIdx = level.endVote["winning"];
        if (!isDefined(winnerIdx))
        {
            winnerIdx = randomIntRange(0, level.endVote["nrMaps"]);
        }

        // FIXME: Idk wtf is going on, but calling map() will simply result in SV_MapExists returning false because fs_searchpaths are being weird.
        // Whatever, the following seems to work for now.
        //map(level.endVote["maps"][winnerIdx]);
        setDvar("nextmap", "map " + level.endVote["maps"][winnerIdx]);
        exitLevel();
    }

    // Set the players' dvars and open menu if needed
    players = getEntArray("player", "classname");
    for (i = 0; i < players.size; i++)
    {
        players[i] setClientDvar(level.endVote["prefix"] + "status", level.endVote["status"]);

        if (level.endVote["status"] == 1)
        {
            // End map vote is starting
            players[i] openEndMapVote();
        }
        else if (level.endVote["status"] == 2)
        {
            // Tell players end map vote is over so that they draw "loading map" text instead
            players[i] setClientDvar(level.endVote["prefix"] + "active", "loading");
        }
        else
        {
            players[i] closeMenu();
            players[i] closeInGameMenu();
            players[i].sessionState = "intermission";
        }
    }
}

openEndMapVote()
{
    self closeMenu();
    self closeInGameMenu();

    self openMenu(level.endVote["menu"]);
}

removeVote(mapIdx) // When a player disconnected
{
    level.endVote["votes"][mapIdx]--;
    _updateVotes(mapIdx, -1);
}

onVoteChanged(val)
{
    // Only when end map vote is active and the vote is valid
    if ((val < 1) || (val > level.endVote["nrMaps"]) || (level.endVote["status"] <= 0))
    {
        return;
    }

    newVoteIdx = val - 1; // The array indices are 0-based, but player votes are 1-based

    prevVoteIdx = -1;
    if ((self.endVote != -1) && (level.endVote["votes"][self.endVote] > 0))
    {
        prevVoteIdx = self.endVote;
        level.endVote["votes"][self.endVote]--;
    }

    // Update player's and total map votes
    self.endVote = newVoteIdx;
    level.endVote["votes"][newVoteIdx]++;
    self setClientDvar(level.endVote["prefix"] + "voted", val);

    _updateVotes(prevVoteIdx, newVoteIdx);
}

_updateVotes(prevVoteIdx, newVoteIdx)
{
    if ((prevVoteIdx == -1) && (newVoteIdx == -1))
    {
        return;
    }

    // Calculate current winning map
    winning = undefined;
    winningChanged = false;
    if (isDefined(level.endVote["winning"]))
    {
        winning = level.endVote["winning"];
        for (i = 0; i < level.endVote["maps"].size; i++)
        {
            // If this map now has less than another map
            if (level.endVote["votes"][i] > level.endVote["votes"][winning])
            {
                winning = i;
                winningChanged = true;
            }
        }
    }
    else if (newVoteIdx != -1)
    {
        winning = newVoteIdx;
        winningChanged = true;
    }

    if (winningChanged)
    {
        level.endVote["winning"] = winning;
    }

    players = getEntArray("player", "classname");
    for (i = 0; i < players.size; i++)
    {
        // Remove the player's previous vote if there was one
        if (isDefined(prevVoteIdx) && (prevVoteIdx != -1))
        {
            players[i] setClientDvar(level.endVote["prefix"] + "votes" + (prevVoteIdx + 1), level.endVote["votes"][prevVoteIdx]);
        }

        // Add the player's new vote if there is one
        if (isDefined(newVoteIdx) && (newVoteIdx != -1))
        {
            players[i] setClientDvar(level.endVote["prefix"] + "votes" + (newVoteIdx + 1), level.endVote["votes"][newVoteIdx]);
        }

        // Report if winning map changed
        if (winningChanged)
        {
            players[i] setClientDvar(level.endVote["prefix"] + "winning", (level.endVote["winning"] + 1));
        }
    }
}

onMenuResponse()
{
    self endon("disconnect");

    for(;;)
    {
        self waittill("menuresponse", menu, response);

        button = undefined;
        if (isSubStr(response, "click_"))
        {
            button = getSubStr(response, 6); 
        }
        
        if (isDefined(button)) // A button was clicked
        {
            if (isSubStr(button, "vote") && (button.size > 4))
            {
                val = int(getSubStr(button, 4)); // "vote"
                if (isDefined(val))
                {
                    self onVoteChanged(val);
                }
            }
        }
    }
}
