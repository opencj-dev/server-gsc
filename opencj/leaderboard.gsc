onInit()
{
    // Menu hardcoded values
    level.lbMenu = "opencj_leaderboard";
    level.lbMaxEntriesPerPage = 10;
    level.rtMaxEntriesPerPage = 8; 
    level.lbDvarPrefix = "opencj_ui_lb_";
    level.lbFilterSettingNames = [];
    level.lbFilterSettingNames["ele"] = "lbfilterele";
    level.lbFilterSettingNames["any"] = "lbfilteranypct";
    level.lbFilterSettingNames["tas"] = "lbfiltertas";
    level.lbFilterSettingNames["fps"] = "lbfilterfps";

    precacheMenu(level.lbMenu);
    
    // Hidden settings that are changed purely via menu
    openCJ\settings::addSettingBool(level.lbFilterSettingNames["ele"], false, "Set leaderboard ele filter", ::_onEleFilterSet);
    openCJ\settings::addSettingBool(level.lbFilterSettingNames["any"], false, "Set leaderboard shortcuts filter", ::_onAnyPctFilterSet);
    openCJ\settings::addSettingBool(level.lbFilterSettingNames["tas"], false, "Set leaderboard TAS filter", ::_onTASFilterSet);
	openCJ\settings::addSettingString(level.lbFilterSettingNames["fps"], 3, 8, "mix", "Set leaderboard FPS filter", ::_onFPSFilterChange); // min len 3: 125, mix, hax
}

_onEleFilterSet(newVal)
{
    self.lb["filter"]["ele"] = newVal;
}
_onAnyPctFilterSet(newVal)
{
    self.lb["filter"]["any"] = newVal;
}
_onTASFilterSet(newVal)
{
    self.lb["filter"]["tas"] = newVal;
}
_onFPSFilterChange(newStr)
{
    allowed = false;
    newStr = tolower(newStr);
    switch (newStr)
    {
        case "125": // Fallthrough
        case "mix": // Fallthrough
        case "hax": // Fallthrough
        {
            allowed = true;
        } break;
    }

    if (allowed)
    {
        self.lb["filter"]["fps"] = newStr;
    }

    return allowed; // Other values are not allowed
}

onPlayerConnected()
{
    // Leaderboard
    self.lb = [];
    self.lb["nrEntriesThisPage"] = 0; // How many entries are available for the current page
    self.lb["nrTotalEntries"] = 0;
    self.lb["prevSortBy"] = "time";
    self.lb["sortBy"] = "time";
    self.lb["sort"] = 1; // Ascending
    self.lb["page"] = [];
    self.lb["page"]["cur"] = 1;
    self.lb["page"]["max"] = 1;
    self.lb["filter"] = [];
    self.lb["filter"]["ele"] = self openCJ\settings::getSetting(level.lbFilterSettingNames["ele"]);
    self.lb["filter"]["any"] = self openCJ\settings::getSetting(level.lbFilterSettingNames["any"]);
    self.lb["filter"]["tas"] = self openCJ\settings::getSetting(level.lbFilterSettingNames["tas"]);
    self.lb["filter"]["fps"] = self openCJ\settings::getSetting(level.lbFilterSettingNames["fps"]);

    self.lb["filter"]["route"] = 1; // Select first route by default
    
    //  These are dvars for each run
    self.lb["cols"] = [];
    for (i = 0; i < level.lbMaxEntriesPerPage; i++)
    {
        self.lb["cols"][i] = [];
    }
    
    // Routes
    self.rt = [];
    self.rt["curPage"] = 1;

    // Set route information at the start since it does not differ per player and is constant during the map (other than which page is being viewed)
    level.rtMaxPage = int(level.routeEnders.size / level.rtMaxEntriesPerPage) + 1;
    self setClientCvar(level.lbDvarPrefix + "rtpagemax", level.rtMaxPage);
    self updateRoutes();

    self thread onMenuResponse();
}

onMenuResponse()
{
    self endon("disconnect");
    level endon("game_ended");

    for(;;)
    {
        self waittill("menuresponse", menu, response);
        button = undefined;
        if (isSubStr(response, "click_"))
        {
            button = getSubStr(response, 6); 
        }
        
        if (response == "open_leaderboard") // Leaderboard was opened
        {
            // Routes were already updated upon connect, only need to update leaderboard
            self updateLeaderBoard();
        }
        else if (isDefined(button)) // A button was clicked
        {
            if ((button == "time") || (button == "rpgs") || (button == "loads") || (button == "date")) // Sorting
            {
                self handleSortChange(button);
            }
            else if (isSubStr(button, "page")) // Route or leaderboard previous/next page
            {
                self handlePageChange(button);
            }
            else if ((button == "ele") || (button == "any") || (button == "tas")) // Filter pressed
            {
                self handleFilterChange(button);
            }
            else if (isSubStr(button, "fps_")) // FPS filter selection pop menu button was clicked
            {
                self handleFilterChange(button);
            }
            else if (isSubStr(button, "route"))
            {
                self handleRouteSelection(button);
            }
        }
    }
}

/// ===================================================== Update functions =====================================================

updateLeaderBoard()
{
    // Gets values and puts them in self vars
    self fetchUpdatedLeaderBoardData();

    // Update all dvars
    self.lb["page"]["max"] = int(self.lb["nrTotalEntries"] / level.lbMaxEntriesPerPage) + 1;

    // Update page text dvars after updating leader board
    self setClientCvar(level.lbDvarPrefix + "lbpagetxt", self.lb["page"]["cur"] + "/" + self.lb["page"]["max"]);
    self setClientCvar(level.lbDvarPrefix + "lbpage", self.lb["page"]["cur"]);
    self setClientCvar(level.lbDvarPrefix + "lbpagemax", self.lb["page"]["max"]);
    
    // Update sorting dvars
    // First, clear prev sorting dvar
    if (self.lb["sortBy"] != self.lb["prevSortBy"])
    {
        self setClientCvar(level.lbDvarPrefix + "sort_" + self.lb["prevSortBy"], 0);
    }
    self setClientCvar(level.lbDvarPrefix + "sort_" + self.lb["sortBy"], self.lb["sort"]);

    // And now the actual leaderboard data
    keys = getArrayKeys(self.lb["cols"][0]); // Although empty when i >= self.lb["nrEntriesThisPage"], can still be used for getArrayKeys
    for (i = 0; i < level.lbMaxEntriesPerPage; i++)
    {
        entryNr = i + 1;
        for (j = 0; j < keys.size; j++)
        {
            key = keys[j];

            // Do we have another item to send?
            dvar = level.lbDvarPrefix + key + entryNr; // The run dvars start at 1

            // We have n=between 0 and max items. Everything after n needs to be cleared because there may be previous results in the DVAR
            if (i < self.lb["nrEntriesThisPage"])
            {
                val = self.lb["cols"][i][key];

                // Special conversion(s) without updating the original
                if (key == "time")
                {
                    val = timeToString(int((val / 1000) + 0.5)); // Round the time
                }
                /*
                else if (key == "date")
                {
                    val = convertDate(val);
                }
                */

                // Send the updated dvar
                self setClientCvar(dvar, val);
            }
            else
            {
                // Send cleared dvar to client
                self setClientCvar(dvar, "");
            }
        }
    }
}

updateRoutes()
{
    // Start by updating the client's selected route visibility based on current page
    absRouteNr = self.lb["filter"]["route"]; // Not normalized
    self updateSelectedRoute(absRouteNr);

    // Then update all the route dvars based on current page
    firstItemNrCurrentPage = getAbsFirstItemNrCurrentPage(self.rt["curPage"], level.rtMaxEntriesPerPage);
    remainingEntries = level.routeEnders.size - firstItemNrCurrentPage + 1; // +1 because we also need to update the first item
    for (i = 0; i < level.rtMaxEntriesPerPage; i++) // We also need to clear the ones that shouldn't be visible (anymore)
    {
        itemNr = (i+1); // Route dvars, like others, start at 1

        dvar = level.lbDvarPrefix + "route" + itemNr;
        if (itemNr <= remainingEntries)
        {
            keys = getArrayKeys(level.routeEnders);
            self setClientCvar(dvar, keys[(firstItemNrCurrentPage-1) + i]); // Starts at [0] not at [1], so -1
        }
        else
        {
            self setClientCvar(dvar, ""); // Don't show background either
        }
    }

    self setClientCvar(level.lbDvarPrefix + "rtpage", self.rt["curPage"]);
}

updateSelectedRoute(absRouteNr)
{
    selectedRouteDvar = level.lbDvarPrefix + "rtselected";
    if (isAbsItemNrOnCurrentPage(absRouteNr, self.rt["curPage"], level.rtMaxEntriesPerPage)) // Currently selected route is visible on current page
    {
        self setClientCvar(selectedRouteDvar, toRelItemNr(absRouteNr, self.rt["curPage"], level.rtMaxEntriesPerPage));
    }
    else // Not visible on current page
    {
        self setClientCvar(selectedRouteDvar, "");
    }
}

isEntryAllowedByFilter(entry)
{
    // Is it the right route?
    routeNr = self.lb["filter"]["route"];
    if ((routeNr != -1) && (routeNr != entry["route"]))
    {
        return false;
    }

    // Ele filter
    if (!self.lb["filter"]["ele"] && (entry["ele"] != "^7")) // We use ^7 as empty value in order to still show the empty cell on leaderboard
    {
        return false;
    }
    
    // Any % filter (shortcuts)
    if (!self.lb["filter"]["any"] && (entry["any"] != "^7"))
    {
        return false;
    }

    // TAS filter (Tool Assisted Speedrun)
    if (!self.lb["filter"]["tas"] && (entry["tas"] != "^7"))
    {
        return false;
    }

    // FPS filter
    fpsEntry = tolower(entry["fps"]);
    fpsFilter = tolower(self.lb["filter"]["fps"]);
    switch (fpsFilter)
    {
        case "125": // Only allow 125
        {
            return (fpsEntry == "125");
        }
        case "mix": // Allow mix (default for CoD4)
        {
            return (fpsEntry != "all");
        }
    }

    // All seems OK! (FPS filter "all" allows all FPS types)
    return true;
}

// ===================================================== Database functions =====================================================

fetchUpdatedLeaderBoardData()
{
    // In order to obtain run data per route, we first need to check what checkpoint ID(s) match the finish checkpoint(s) for the selected route
    routeIdx = self.lb["filter"]["route"] - 1;

    // Debug information might still be useful for now
    keys = getArraykeys(level.routeEnders);
    if (level.routeEnders.size <= routeIdx)
    {
        printf("WARNING: route for idx: " + routeIdx + " is not available. Have:\n");
        keys = getArrayKeys(level.routeEnders);
        for (i = 0; i < keys.size; i++)
        {
            printf("key[" + i + "] = " + keys[i] + "\n"); // Debug
        }
    }

    finishCPIds = getEndCheckpointIdsForRoute(keys[routeIdx]);

    // Based on player's current filter (ele, any %, tas, fps) and sorting (time, rpg, loads, date), asc/desc criteria:
    // - grab up to 10 rows (leaderboard pages show 10)
    // the information we need is stored across multiple tables as follows:
    // - checkPointStatistics has explosiveJumps, loadCount, timePlayed, and all filters (any%, ele, tas, fps)
    // - playerRuns has runID that we can use to match a playerID which in turn gives us the playername
    // - playerRuns has finishTimestamp which we can use as date
    // - playerInformation has playerName
    // the more difficult part of the query is the ROW_NUMBER() with PARTITION and rowNr = 1, which is used to make sure we only obtain one run per playerID
    sortStr = getSortStr(self.lb["sortBy"], self.lb["sort"]);
    query = "SELECT COUNT(*) OVER() AS totalNr, b.playerName, a.timePlayed, a.explosiveJumps, a.loadCount, a.finishTimeStamp, a.FPSMode, a.ele, a.anyPct, a.hardTas FROM (" +
                "SELECT pr.playerID, cs.timePlayed, cs.explosiveJumps, cs.loadCount, pr.finishTimeStamp, cs.FPSMode, cs.ele, cs.anyPct, cs.hardTas, cs.runID, cs.saveCount, (" + 
                    "ROW_NUMBER() OVER (PARTITION BY pr.playerID ORDER BY " + sortStr +
                ")) AS rn " + 
                "FROM checkpointStatistics cs INNER JOIN playerRuns pr ON pr.runID = cs.runID " + 
                "WHERE cs.cpID IN " + finishCPIds +
                " AND pr.finishcpID IS NOT NULL" +
                " AND pr.finishTimeStamp IS NOT NULL" +
                " AND cs.ele <= " + self.lb["filter"]["ele"] +
                " AND cs.anyPct <= " + self.lb["filter"]["any"] +
                " AND cs.hardTAS <= " + self.lb["filter"]["tas"] +
                " AND cs.FPSMode IN " + getFPSModeStr(self.lb["filter"]["fps"]) +
            " ) a INNER JOIN playerInformation b ON a.playerID = b.playerID " +
            "WHERE a.rn = 1 ORDER BY " + sortStr + " LIMIT " + level.lbMaxEntriesPerPage + " OFFSET " + getOffsetFromPage(self.lb["page"]["cur"], level.lbMaxEntriesPerPage);

    // Might remain useful for now to print the query
    printf("Leaderboard query:\n" + query + "\n"); // Debug

    // Example output (pretend there are 10 rows instead of 2 though):
    // ------------------------------------------------------------------------------------------------------------------------
    // | totalNr | playerName    | timePlayed | explosiveJumps | loadCount | finishTimeStamp     | FPSMode | ele | anyPct | hardTAS |
    // |-----------------------------------------------------------------------------------------------------------------------
    // | 13      | 3xP' Rextrus  | 416800     | 0              | 38        | 2022-09-04 08:22:12 | all     | 0   | 0      | 0       |
    // |---------|---------------|------------|----------------|-----------|---------------------|---------|-----|--------|---------|
    // | 13      | Styx|Ridgepig | 657000     | 1              | 69        | 2022-09-04 09:53:58 | all     | 0   | 0      | 0       |
    // |---------|---------------|------------|----------------|-----------|---------------------|---------|-----|--------|---------|
    // | ....

    rows = self openCJ\mySQL::mysqlAsyncQuery(query);

    self.lb["cols"] = []; // Hope this clears the previously used memory

    if (isDefined(rows) && (rows.size > 0) && isDefined(rows[0][0]))
    {
        self.lb["nrTotalEntries"] = int(rows[0][0]); // totalNr
        self.lb["nrEntriesThisPage"] = rows.size;
    }
    else
    {
        self.lb["nrTotalEntries"] = 0;
        self.lb["nrEntriesThisPage"] = 0;
    }

    // TODO: fetch and process 'your' run as well

    // Now that the data is there, we need to fill in the values into the local variables
    for (i = 0; i < level.lbMaxEntriesPerPage; i++)
    {
        if (i < self.lb["nrEntriesThisPage"])
        {
            self.lb["cols"][i]["nr"] = (i + 1);
            self.lb["cols"][i]["name"] = rows[i][1];
            self.lb["cols"][i]["time"] = int(rows[i][2]);
            self.lb["cols"][i]["rpgs"] = int(rows[i][3]);
            self.lb["cols"][i]["loads"] = int(rows[i][4]);
            self.lb["cols"][i]["date"] = rows[i][5];
            self.lb["cols"][i]["fps"] = rows[i][6];
            self.lb["cols"][i]["ele"] = _xOrEmpty(int(rows[i][7]));
            self.lb["cols"][i]["any"] = _xOrEmpty(int(rows[i][8]));
            self.lb["cols"][i]["tas"] = _xOrEmpty(int(rows[i][9]));
        }
        else
        {
            self.lb["cols"][i]["nr"] = 0;
            self.lb["cols"][i]["name"] = "";
            self.lb["cols"][i]["time"] = 0;
            self.lb["cols"][i]["rpgs"] = 0;
            self.lb["cols"][i]["loads"] = 0;
            self.lb["cols"][i]["date"] = "";
            self.lb["cols"][i]["fps"] = "";
            self.lb["cols"][i]["ele"] = false;
            self.lb["cols"][i]["any"] = false;
            self.lb["cols"][i]["tas"] = false;
        }
    }
}

_xOrEmpty(val)
{
    if (val > 0)
    {
        return "X";
    }

    return "^7";
}

getEndCheckpointIdsForRoute(routeName)
{
    if (!isDefined(routeName) || !isDefined(level.routeEnders[routeName]))
    {
        return undefined;
    }

    cpSqlStr = "";
    isFirstCp = true;
    for (i = 0; i < level.routeEnders[routeName].size; i++)
    {
        cpID = openCJ\checkpoints::getCheckpointID(level.routeEnders[routeName][i]);
        if (isDefined(cpID))
        {
            if (!isFirstCp)
            {
                cpSqlStr += ", ";
            }

            cpSqlStr += cpID;
            isFirstCp = false;
        }
    }

    if (cpSqlStr.size <= 0)
    {
        return undefined;
    }

    return "(" + cpSqlStr + ")";
}

dbStr(str)
{
    return "'" + str + "'";
}

getFPSModeStr(fpsFilter)
{
    allowedFpsEntries = "(";
    switch (fpsFilter)
    {
        default:
        {
            printf("WARNING: FPS filter: " + fpsFilter + " invalid\n");
        } // Fallthrough to allow all types of FPS
        case "hax":
        {
            allowedFpsEntries += dbStr("hax") + ", "; // All on leaderboard is called hax
        } // Fallthrough
        case "mix":
        {
            allowedFpsEntries += dbStr("mix") + ", "; // Standard mode on CoD4 is called mix
        } // Fallthrough
        case "125":
        {
            allowedFpsEntries += dbStr("125"); // 125 is called 125
        } break;
    }
    allowedFpsEntries += ")";

    return allowedFpsEntries;
}

getSortStr(col, order)
{
    orderTypeStr = "ASC"; // Default sort by ASC
    if (order == 2)
    {
        orderTypeStr = "DESC";
    }

    // First add the sort that the user specified, however we want to add more sorts to nicely sort data even if it has the same main value as the next-in-line run
    orderStr = convertSortCol(col, orderTypeStr);
    orderStr += ", " + convertSortCol("time", orderTypeStr); // It's OK to specify the same sort twice in there, at least no SQL error
    orderStr += ", " + convertSortCol("rpgs", orderTypeStr);
    orderStr += ", " + convertSortCol("loads", orderTypeStr);
    orderStr += ", " + convertSortCol("saves", orderTypeStr);
    orderStr += ", " + convertSortCol("date", orderTypeStr);

    return orderStr;
}

convertSortCol(col, orderStr)
{
    str = "";
    switch(col)
    {
        case "time":
        {
            str += "timePlayed"; // checkpointStatistics
        } break;
        case "rpgs":
        {
            str += "explosiveJumps"; // checkpointStatistics
        } break;
        case "loads":
        {
            str += "loadCount"; // checkpointStatistics
        } break;
        case "saves":
        {
            str += "saveCount"; // checkpointStatistics
        } break;
        case "date":
        {
            str += "finishTimeStamp"; // playerRuns
        } break;
        default: // Default to time
        {
            printf("WARNING: Failed to get sort query for: " + str + "\n"); // Might have to be removed eventually due to being player input
            str += "timePlayed";
        } break;
    }

    return str + " " + orderStr;
}

getOffsetFromPage(page, maxEntriesPerPage)
{
    return getAbsFirstItemNrCurrentPage(page, maxEntriesPerPage) - 1;
}

// ===================================================== Functions called upon scriptMenuResponse =====================================================

handleSortChange(button)
{
    if (self.lb["sortBy"] != button) // Will be sorting by something else now
    {
        self.lb["prevSortBy"] = self.lb["sortBy"];
        self.lb["sortBy"] = button;
        self.lb["sort"] = 1; // Ascending by default
    }
    else // Sorting by same thing, so toggle between ascending and descending
    {
        if (self.lb["sort"] == 1)
        {
            self.lb["sort"] = 2;
        }
        else
        {
            self.lb["sort"] = 1;
        }
    }
    
    // Sorting changed, so reset page
    self.lb["page"]["cur"] = 1; // Reset page

    self updateLeaderBoard();
}

handlePageChange(button)
{
    isPrevPage = isSubStr(button, "prev");
    isRoutePage = isSubStr(button, "rt");

    if (isRoutePage)
    {
        if (isPrevPage)
        {
            if (self.rt["curPage"] > 1)
            {
                self.rt["curPage"]--;
            }
        }
        else // Next page
        {
            if (self.rt["curPage"] < level.rtMaxPage)
            {
                self.rt["curPage"]++;
            }
        }

        self updateRoutes();
    }
    else // Leaderboard page
    {
        if (isPrevPage)
        {
            if (self.lb["page"]["cur"] > 1)
            {
                self.lb["page"]["cur"]--;
            }
        }
        else // Next page
        {
            if (self.lb["page"]["cur"] < self.lb["page"]["max"])
            {
                self.lb["page"]["cur"]++;
            }
        }

        self updateLeaderBoard();
    }
}

handleFilterChange(button)
{
    if ((button == "ele") || (button == "any") || (button == "tas"))
    {
        // Filter: toggle allow ele
        // Filter: toggle allow any % (cuts)
        // Filter: toggle allow TAS (Tool Assisted Speedrun)
        self.lb["filter"][button] = !self.lb["filter"][button];
        self openCJ\settings::setSetting(level.lbFilterSettingNames[button], self.lb["filter"][button]);
        self setClientCvar(level.lbDvarPrefix + button + "_allow", self.lb["filter"][button]);
    }
    else if (isSubStr(button, "fps_"))
    {
        fpsTokens = strTok(button, "_");
        if (fpsTokens.size > 1)
        {
            fpsFilter = toLower(fpsTokens[1]);
            switch(fpsFilter)
            {
                case "125":
                {
                    self.lb["filter"]["fps"] = "125";
                } break;
                case "standard": // Fallthrough
                case "mix":
                {
                    self.lb["filter"]["fps"] = "mix"; // We map it to db names
                } break;
                case "all": // Fallthrough
                case "hax":
                {
                    self.lb["filter"]["fps"] = "hax";
                } break;
                default:
                {
                    printf("WARNING: Unknown FPS filter: " + fpsFilter + "\n");
                }
            }

            self openCJ\settings::setSetting(level.lbFilterSettingNames["fps"], self.lb["filter"]["fps"]);
        }
    }

    // Filtering changed, so reset page
    self.lb["page"]["cur"] = 1;

    self updateLeaderBoard();
}

handleRouteSelection(button)
{
    if (button.size < 6)
    {
        return;
    }

    routeNr = int(getSubStr(button, 5)); // "route"
    if ((routeNr < 1) || (routeNr > level.rtMaxEntriesPerPage))
    {
        return;
    }

    // Add proper offset to selected route, otherwise route will be highlighted on all pages (2 vs (maxEntries + 2))
    self.lb["filter"]["route"] = toAbsItemNrOnCurrentPage(routeNr, self.rt["curPage"], level.rtMaxEntriesPerPage, level.routeEnders.size);
    self updateSelectedRoute(self.lb["filter"]["route"]);

    // Selected route changed, so we need to filter only the runs that are part of that route
    self updateLeaderBoard();
}

// ===================================================== Helper functions =====================================================

toAbsItemNrOnCurrentPage(itemNr, curPage, maxEntriesPerPage, maxEntries)
{
    itemNr += getAbsFirstItemNrCurrentPage(curPage, maxEntriesPerPage) - 1; // -1 because itemNr already starts at one
    if (itemNr > maxEntries)
    {
        itemNr = maxEntries;
    }

    return itemNr;
}

toRelItemNr(absItemNr, curPage, maxEntriesPerPage)
{
    relItemNr = (absItemNr % maxEntriesPerPage);
    if (relItemNr == 0)
    {
        relItemNr = maxEntriesPerPage;
    }
    return relItemNr;
}

isAbsItemNrOnCurrentPage(itemNr, curPage, maxEntriesPerPage)
{
    if (itemNr < 1)
    {
        return false;
    }

    pageFirstItemNr = getAbsFirstItemNrCurrentPage(curPage, maxEntriesPerPage);
    pageLastItemNr = getAbsLastItemNrCurrentPage(curPage, maxEntriesPerPage, level.routeEnders.size);

    if ((itemNr < pageFirstItemNr) || (itemNr > pageLastItemNr))
    {
        return false;
    }

    return true;
}

getAbsFirstItemNrCurrentPage(curPage, maxEntriesPerPage)
{
    pageIdx = (curPage - 1); // Page starts at 1
    firstItemNr = (pageIdx * maxEntriesPerPage) + 1; // + 1 because first item starts at 1

    return firstItemNr;
}

getAbsLastItemNrCurrentPage(curPage, maxEntriesPerPage, maxEntries)
{
    lastItemNrCurrentPage = getAbsFirstItemNrCurrentPage(curPage, maxEntriesPerPage) + maxEntriesPerPage;
    if (lastItemNrCurrentPage > maxEntries)
    {
        lastItemNrCurrentPage = maxEntries;
    }

    return lastItemNrCurrentPage;
}

timeToString(seconds)
{
    hours = int(seconds / 3600);
    seconds -= (hours * 3600);
    if (hours < 10) hours = "0" + hours;
    minutes = int(seconds / 60);
    seconds -= (minutes * 60);
    if (minutes < 10) minutes = "0" + minutes;
    if (seconds < 10) seconds = "0" + seconds;

    return hours + ":" + minutes + ":" + seconds;
}

/* Was used for test data. Might be useful in future if we get the date in days

convertDate(days)
{
    str = "";
    val = 0;
    if (days >= 365)
    {
        val = int(days / 365);
        str += val + " year";
    }
    else if (days >= 31)
    {
        val = int(days / 31);
        str += val + " month";
    }
    else if (days >= 7)
    {
        val = int(days / 7);
        str += val + " week";
    }
    else
    {
        val = int(days);
        str += days + " day";
    }
    
    if (val > 1)
    {
        str += "s";
    }
    
    str += " ago";
    return str;
}
*/
