#include openCJ\util;

onInit()
{
    openCJ\menus\board_base::initBoard("rn", "runsboard", "opencj_runsboard", ::fetchUpdatedData);
}

handleRestoreRun(str)
{
    // str example: name1 (when clicking on the first run)
    if (str.size > 4)
    {
        nrPressed = int(getSubStr(str, 4));
        if ((nrPressed < 1) || (nrPressed > level.boards["rn"]["maxEntriesPerPage"])) // Sanity check for out of bounds
        {
            return;
        }

        idx = nrPressed -1;
        if (!isDefined(self.currentBoard) || !isDefined(self.currentBoard["cols"]) || !isDefined(self.currentBoard["cols"][idx]))
        {
            return;
        }

        runID = self.currentBoard["cols"][idx]["nr"];
        if (runID < 0) // Initialized to -1 when it doesn't contain a value
        {
            return;
        }

        query = "SELECT * FROM playerRuns WHERE runID = " + runID + " AND playerID = " + openCJ\login::getPlayerID();
        rows = self openCJ\mySQL::mysqlAsyncQuery(query);
        if (isDefined(rows) && isDefined(rows[0]) && isDefined(rows[0][0]))
        {
            // Run is indeed by player, we can safely restore run if he's logged in
            if(self isPlayerReady(false))
            {
                self openCJ\playerRuns::restoreRun(runID);
            }
        }
    }

    self closeMenu();
}

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

    routeCPIds = getNonEndCheckpointIdsForRoute(routeName);
    playerID = self openCJ\login::getPlayerID();

    // TODO: for now the routes filtering is not working until we have a route<->cp mapping table

    // Based on player's current filter (ele, any %, tas, fps) and sorting (time, rpg, loads, date), asc/desc criteria:
    // - grab up to 10 rows (runsboard pages show 10)
    // the information we need is stored across multiple tables as follows:
    // - checkPointStatistics has explosiveJumps, loadCount, timePlayed, and all filters (any%, ele, tas, fps)
    // - playerRuns has runID, mapID
    // - playerRuns has finishTimeStamp which we can use to verify the run isn't finished yet
    // - playerRuns has startTimeStamp which we can use as run date/age
    // - runLabels contains the run labels
    sortStr = getSortStr(self.currentBoard["sortBy"], self.currentBoard["sort"]);
    query = "SELECT COUNT(*) OVER() AS totalNr, a.runID, rl.runLabel, a.timePlayed, a.explosiveJumps, a.loadCount, a.startTimeStamp, a.FPSMode, a.flags " +
                "FROM(" + 
                    "SELECT ROW_NUMBER() OVER (PARTITION BY pr.runID ORDER BY saveNumber DESC) AS rn, pr.playerID, pr.finishcpID, pr.archived, pr.finishTimeStamp, pr.mapID, pr.runID, pr.runLabel, pr.timePlayed, ps.explosiveJumps, pr.loadCount, pr.saveCount, pr.startTimeStamp, ps.FPSMode, ps.flags " + 
                    "FROM playerSaves ps INNER JOIN playerRuns AS pr ON pr.runID = ps.runID " + 
                ") a LEFT JOIN runLabels rl ON a.runID = rl.runID" + 
                " WHERE a.rn = 1" +
                " AND a.playerID = " + playerID + 
                " AND a.finishcpID IS NULL" +
                " AND a.archived = False" +
                " AND a.finishTimeStamp IS NULL" +
                " AND a.mapID = " + openCJ\mapID::getMapID() + 
                self getRunStr() + 
                getFilterStr(self.currentBoard["filter"]["ele"], self.currentBoard["filter"]["any"], self.currentBoard["filter"]["tas"]) +
                " AND a.FPSMode IN " + openCJ\menus\board_base::getFPSModeStr(self.currentBoard["filter"]["fps"]) +
            " ORDER BY " + sortStr +
            " LIMIT " + self.currentBoard["maxEntriesPerPage"] +
            " OFFSET " + openCJ\menus\board_base::getOffsetFromPage(self.currentBoard["page"]["cur"], self.currentBoard["maxEntriesPerPage"]);
    // Example output (pretend there are 10 rows instead of 2 though):
    // ----------------------------------------------------------------------------------------------------------------------|
    // | totalNr | runID   | runLabel      | timePlayed | explosiveJumps | loadCount | startTimeStamp      | FPSMode | flags |
    // |---------------------------------------------------------------------------------------------------------------------|
    // | 13      | 1234    | imbadlol      | 416800     | 0              | 38        | 2022-09-04 08:22:12 | all     | 192   |
    // |---------|---------|---------------|------------|----------------|-----------|---------------------|---------|-------|
    // | 13      | 1446    | norpg run     | 657000     | 1              | 69        | 2022-09-04 09:53:58 | all     | 8     |
    // |---------|---------|---------------|------------|----------------|-----------|---------------------|---------|-------|
    // | ....


    // Might remain useful for now to print the query
    printf("Runsboard query:\n" + query + "\n"); // Debug

    rows = self openCJ\mySQL::mysqlAsyncQuery(query);

    self.currentBoard["cols"] = []; // Hope this clears the previously used memory

    if (isDefined(rows) && isDefined(rows[0]) && isDefined(rows[0][0]))
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
            self.currentBoard["cols"][i]["nr"] = int(rows[i][1]);
            name = rows[i][2];
            if (!isDefined(name) || (name == ""))
            {
                name = "Unnamed run";
            }
            self.currentBoard["cols"][i]["name"] = name; // runLabel
            self.currentBoard["cols"][i]["time"] = int(rows[i][3]);
            self.currentBoard["cols"][i]["rpgs"] = int(rows[i][4]);
            self.currentBoard["cols"][i]["loads"] = int(rows[i][5]);
            self.currentBoard["cols"][i]["date"] = rows[i][6]; // startTimeStamp
            self.currentBoard["cols"][i]["fps"] = rows[i][7];

            eleVal = int(rows[i][8]) & level.saveFlags[level.saveFlagName_eleOverrideEver];
            anyVal = int(rows[i][8]) & level.saveFlags[level.saveFlagName_anyPctEver];
            TASVal = int(rows[i][8]) & level.saveFlags[level.saveFlagName_hardTAS];
            self.currentBoard["cols"][i]["ele"] = xOrEmpty(eleVal);
            self.currentBoard["cols"][i]["any"] = xOrEmpty(anyVal);
            self.currentBoard["cols"][i]["tas"] = xOrEmpty(TASVal);
        }
        else
        {
            self.currentBoard["cols"][i]["nr"] = -1;
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

getNonEndCheckpointIdsForRoute(routeName)
{
    return undefined;

    // TODO: implement route filtering with long queries


    /*
    checkpoints = openCJ\checkpoints::getCheckpointsForRoute(routeName);
    if (!isDefined(checkpoints))
    {
        printf("WARNING: no checkpoints for specific route: " + routeName + ", using all checkpoints\n");
        checkpoints = openCJ\checkpoints::getAllCheckpoints();
    }
    */
}

getRunStr()
{
    str = "";
    if(self openCJ\playerRuns::hasRunID())
    {
        str = " AND a.runID != " + self openCJ\playerRuns::getRunID();
    }

    return str;
}

getFilterStr(ele, any, tas)
{
    eleVal = int(ele) * level.saveFlags[level.saveFlagName_eleOverrideEver];
    anyVal = int(any) * level.saveFlags[level.saveFlagName_anyPctEver];
    tasVal = int(tas) * level.saveFlags[level.saveFlagName_hardTAS];

    flagsBeginStr = " AND (a.flags & ";
    str = flagsBeginStr + level.saveFlags["eleOverrideEver"] + ") <= " + eleVal;
    str += flagsBeginStr + level.saveFlags["anyPctEver"] + ") <= " + anyVal;
    str += flagsBeginStr + level.saveFlags["hardTAS"] + ") <= " + tasVal;

    return str;
}

getSortStr(col, order)
{
    orderTypeStr = "ASC"; // Default sort by ASC
    if (order == 2)
    {
        orderTypeStr = "DESC";
    }

    // For runsboard, date means startDate
    if (col == "date")
    {
        col = "startDate";
    }

    // First add the sort that the user specified, however we want to add more sorts to nicely sort data even if it has the same main value as the next-in-line run
    orderStr = openCJ\menus\board_base::convertSortCol(col, orderTypeStr);
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("time", orderTypeStr); // It's OK to specify the same sort twice in there, at least no SQL error
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("rpgs", orderTypeStr);
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("loads", orderTypeStr);
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("saves", orderTypeStr);
    orderStr += ", " + openCJ\menus\board_base::convertSortCol("startDate", orderTypeStr);

    return orderStr;
}

