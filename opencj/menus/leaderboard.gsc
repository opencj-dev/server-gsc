#include openCJ\util;

onInit()
{
    openCJ\menus\board_base::initBoard("lb", "leaderboard", "opencj_leaderboard", ::fetchUpdatedData);
}

// TODO: fetch and process 'your' best finished run as well

fetchUpdatedData()
{
    // In order to obtain run data per route, we first need to check what checkpoint ID(s) match the finish checkpoint(s) for the selected route
    routeIdx = self.currentBoard["filter"]["route"] - 1;

    // Debug information might still be useful for now
    routeName = undefined;
    if (self.currentBoard["routes"].size > routeIdx)
    {
        routeName = self.currentBoard["routes"][routeIdx];
    }
    else
    {
        printf("WARNING: route for idx: " + routeIdx + " is not available. Have:\n");
        for (i = 0; i < self.currentBoard["routes"].size; i++)
        {
            printf("route[" + i + "] = " + self.currentBoard["routes"][i] + "\n"); // Debug
        }
    }

    finishCPIds = getEndCheckpointIdsForRoute(routeName);

    // Based on player's current filter (ele, any %, tas, fps) and sorting (time, rpg, loads, date), asc/desc criteria:
    // - grab up to 10 rows (leaderboard pages show 10)
    // the information we need is stored across multiple tables as follows:
    // - checkPointStatistics has explosiveJumps, loadCount, timePlayed, and all filters (any%, ele, tas, fps)
    // - playerRuns has runID that we can use to match a playerID which in turn gives us the playername
    // - playerRuns has finishTimestamp which we can use as date
    // - playerInformation has playerName
    // the more difficult part of the query is the ROW_NUMBER() with PARTITION and rowNr = 1, which is used to make sure we only obtain one run per playerID
    sortStr = getSortStr(self.currentBoard["sortBy"], self.currentBoard["sort"]);
    query = "SELECT COUNT(*) OVER() AS totalNr, b.playerName, a.timePlayed, a.explosiveJumps, a.loadCount, a.finishTimeStamp, a.FPSMode, a.ele, a.anyPct, a.hardTas FROM (" +
                "SELECT pr.playerID, cs.timePlayed, cs.explosiveJumps, cs.loadCount, pr.finishTimeStamp, cs.FPSMode, cs.ele, cs.anyPct, cs.hardTas, cs.runID, cs.saveCount, (" + 
                    "ROW_NUMBER() OVER (PARTITION BY pr.playerID ORDER BY " + sortStr +
                ")) AS rn " + 
                "FROM checkpointStatistics cs INNER JOIN playerRuns pr ON pr.runID = cs.runID " + 
                "WHERE cs.cpID IN " + finishCPIds +
                " AND pr.finishcpID IS NOT NULL" +
                " AND pr.finishTimeStamp IS NOT NULL" +
                " AND cs.ele <= " + self.currentBoard["filter"]["ele"] +
                " AND cs.anyPct <= " + self.currentBoard["filter"]["any"] +
                " AND cs.hardTAS <= " + self.currentBoard["filter"]["tas"] +
                " AND cs.FPSMode IN " + openCJ\menus\board_base::getFPSModeStr(self.currentBoard["filter"]["fps"]) +
            " ) a INNER JOIN playerInformation b ON a.playerID = b.playerID " +
            "WHERE a.rn = 1 ORDER BY " + sortStr +
            " LIMIT " + self.currentBoard["maxEntriesPerPage"] +
            " OFFSET " + openCJ\menus\board_base::getOffsetFromPage(self.currentBoard["page"]["cur"], self.currentBoard["maxEntriesPerPage"]);

    // Might remain useful for now to print the query
    printf("Leaderboard query:\n" + query + "\n"); // Debug

    // Example output (pretend there are 10 rows instead of 2 though):
    // -----------------------------------------------------------------------------------------------------------------------------|
    // | totalNr | playerName    | timePlayed | explosiveJumps | loadCount | finishTimeStamp     | FPSMode | ele | anyPct | hardTAS |
    // |----------------------------------------------------------------------------------------------------------------------------|
    // | 13      | 3xP' Rextrus  | 416800     | 0              | 38        | 2022-09-04 08:22:12 | all     | 0   | 0      | 0       |
    // |---------|---------------|------------|----------------|-----------|---------------------|---------|-----|--------|---------|
    // | 13      | Styx|Ridgepig | 657000     | 1              | 69        | 2022-09-04 09:53:58 | all     | 0   | 0      | 0       |
    // |---------|---------------|------------|----------------|-----------|---------------------|---------|-----|--------|---------|
    // | ....

    rows = self openCJ\mySQL::mysqlAsyncQuery(query);

    self.currentBoard["cols"] = []; // Hope this clears the previously used memory

    if (isDefined(rows) && (rows.size > 0) && isDefined(rows[0][0]))
    {
        self.currentBoard["nrTotalEntries"] = int(rows[0][0]); // totalNr
        self.currentBoard["nrEntriesThisPage"] = rows.size;
    }
    else
    {
        self.currentBoard["nrTotalEntries"] = 0;
        self.currentBoard["nrEntriesThisPage"] = 0;
    }

    // Now that the data is there, we need to fill in the values into the local variables
    for (i = 0; i < self.currentBoard["maxEntriesPerPage"]; i++)
    {
        if (i < self.currentBoard["nrEntriesThisPage"])
        {
            self.currentBoard["cols"][i]["nr"] = (i + 1);
            self.currentBoard["cols"][i]["name"] = rows[i][1]; // playerName
            self.currentBoard["cols"][i]["time"] = int(rows[i][2]);
            self.currentBoard["cols"][i]["rpgs"] = int(rows[i][3]);
            self.currentBoard["cols"][i]["loads"] = int(rows[i][4]);
            self.currentBoard["cols"][i]["date"] = rows[i][5];
            self.currentBoard["cols"][i]["fps"] = rows[i][6];
            self.currentBoard["cols"][i]["ele"] = xOrEmpty(int(rows[i][7]));
            self.currentBoard["cols"][i]["any"] = xOrEmpty(int(rows[i][8]));
            self.currentBoard["cols"][i]["tas"] = xOrEmpty(int(rows[i][9]));
        }
        else
        {
            self.currentBoard["cols"][i]["nr"] = 0;
            self.currentBoard["cols"][i]["name"] = "";
            self.currentBoard["cols"][i]["time"] = 0;
            self.currentBoard["cols"][i]["rpgs"] = 0;
            self.currentBoard["cols"][i]["loads"] = 0;
            self.currentBoard["cols"][i]["date"] = "";
            self.currentBoard["cols"][i]["fps"] = "";
            self.currentBoard["cols"][i]["ele"] = false;
            self.currentBoard["cols"][i]["any"] = false;
            self.currentBoard["cols"][i]["tas"] = false;
        }
    }
}

getSortStr(col, order)
{
    orderTypeStr = "ASC"; // Default sort by ASC
    if (order == 2)
    {
        orderTypeStr = "DESC";
    }

    // For leaderboard, date means finishDate
    if (col == "date")
    {
        col = "finishDate";
    }

    // First add the sort that the user specified, however we want to add more sorts to nicely sort data even if it has the same main value as the next-in-line run
    orderStr = openCJ\menus\board_base::convertSortCol(col, orderTypeStr);
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("time", orderTypeStr); // It's OK to specify the same sort twice in there, at least no SQL error
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("rpgs", orderTypeStr);
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("loads", orderTypeStr);
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("saves", orderTypeStr);
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("finishDate", orderTypeStr);

    return orderStr;
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
