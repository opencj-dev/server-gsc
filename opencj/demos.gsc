#include openCJ\util;

onInit()
{
	level.demosBeingLoaded = []; // Not yet ready to play
	level.readyDemos = []; // Loaded to enough frames

	clearAllDemos();
	cmd = openCJ\commands_base::registerCommand("record", "Start recording a demo", ::_onCommandRecord, 0, 0, 0);
	cmd = openCJ\commands_base::registerCommand("playback", "Play back an existing recording", ::_onCommandPlayback, 0, 1, 0);
	openCJ\commands_base::addAlias(cmd, "demo");
}

_onCommandRecord(args)
{
	if(self.recordingDemo)
	{
		self.recordingDemo = false;
		self iprintln("^1Stopped ^7recording");
	}
	else
	{
		runID = self openCJ\playerRuns::getRunID();
		result = createDemo(runID);
		if(result == -1)
		{
			// Demo for this runId already existed, so we should destroy it
			self iprintln("Deleting previous demo from same run..");
			destroyDemo(runID);
			result = createDemo(runID);
			if(result != runID)
			{
				self iprintln("^1Failed to start recording");
				printf("Failed to create new demo for player %s\n", self.name);
				return;
			}
		}
		self.recordingDemoId = runID;
		self.recordingDemo = true;
		self iprintln("^2Started ^7recording");
	}
}

_onCommandPlayback(args)
{
	if(isDefined(args[0]))
	{
		self iprintln("^2Starting ^7playback");
		self.recordingDemo = false;
		self.slowmoCount = 0;
		query = "SELECT x, y, z, a, b, c, isKeyFrame FROM playerRecordings WHERE runID = " + int(args[0]) + " ORDER BY frameNum ASC";
		self thread _doLoadRecordingQuery(query, int(args[0]));
	}
	else
	{
		self iprintln("^1Stopped ^7playback");
		self.playingDemo = false;
		if(isDefined(self.linker))
		{
			self.linker delete();
		}
		self unlink();
	}
}

_doLoadRecordingQuery(query, demoId)
{
	level endon("map_ended");
	self endon("disconnect");

	result = openCJ\mySQL::mysqlAsyncQueryNoRows(query);
	if(!isDefined(result) || (result == 0))
	{
		iprintln("Bad result from demo query");
		return;
	}

	rowcount = mysql_num_rows(result);
	if(rowcount == 0)
	{
		self iprintln("Demo was not found!");
		return;
	}

	// Check if the demo was already previously loaded
	createDemoResult = createDemo(demoId);
	// -1 -> already loaded
	// -2 -> no free spots (if this happens we should just increase it, for now it's 512)
	if(createDemoResult == -1)
	{
		// Already loaded, great. Don't have to let the player wait!
	}
	else if(createDemoResult == -2)
	{
		// Oh no, we ran out of free space.
		printf("Ran out of free demo space... oops\n");
		return;
	}
	else // createDemoResult will be demoId
	{
		self iprintln("Loading demo..");
		thread _loadDemo(demoId, result, rowcount); // TODO: load all demos at map start, or perhaps the map before?
		while (!isDefined(level.readyDemos[demoId]))
		{
			wait .05;
		}
	}

	self iprintln("^2Demo ready to play!");

	self selectPlaybackDemo(demoId);
	self.playingDemo = true;
}

_loadDemo(demoId, result, rowcount)
{
	level endon("map_ended");
	if(isDefined(level.demosBeingLoaded[demoId]) || isDefined(level.readyDemos[demoId]))
	{
		// Already (being) loaded
		return;
	}

	level.demosBeingLoaded[demoId] = 1;

	nrDemoFramesToLoad = 300;
	for(i = 0; i < rowcount; i++)
	{
		row = mysql_fetch_row(result);
		addFrameToDemo(demoId, (int(row[0]), int(row[1]), int(row[2])), (int(row[3]), int(row[4]), int(row[5])), int(row[6]));
		if(i == nrDemoFramesToLoad)
		{
			// Allow player's demo playback to start when we have sufficient frames preloaded, but keep loading
			level.readyDemos[demoId] = 1;
		}
		else if((i > nrDemoFramesToLoad) && ((i % nrDemoFramesToLoad) == 0))
		{
			// Every time we load another batch of frames, chill for a bit.
			wait 0.05;
		}
	}

	// At this point we've loaded all frames
	level.demosBeingLoaded[demoId] = undefined;
    
    mysql_free_result(result);
}

onPlayerConnect()
{
	self.recordingDemo = false;
	self.playingDemo = false;
	self.recordingDemoId = undefined;
}

whileAlive()
{
	if(self.recordingDemo && !self.playingDemo)
	{
		self _storeFrameToDB();
	}
	else if(self.playingDemo)
	{
		// If the linker wasn't created yet or is somehow gone, then restore the link
		if(!isDefined(self.linker))
		{
			self.linker = spawn("script_origin", (0, 0, 0));
			self linkto(self.linker, "", (0, 0, 0), (0, 0, 0));
		}

		if(self leftButtonPressed()) // Reverse
		{
			self skipPlaybackFrames(-2);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self rightButtonPressed()) // Forward
		{
			self skipPlaybackFrames(2);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self leanLeftButtonPressed()) // TODO: key frame instead of 10 frames
		{
			self skipPlaybackFrames(-10);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self leanRightButtonPressed()) // TODO: key frame instead of 10 frames
		{
			self skipPlaybackFrames(10);
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(self meleeButtonPressed()) 
		{
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else if(!self jumpButtonPressed()) // Nothing interesting pressed
		{
			self nextPlaybackFrame();
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();
		}
		else // Jump button: slow motion
		{
			// Grab info of previous frame
			oldOrigin = self readPlaybackFrame_origin();
			oldAngles = self readPlaybackFrame_angles();

			// Grab info of next frame
			self nextPlaybackFrame();
			newOrigin = self readPlaybackFrame_origin();
			newAngles = self readPlaybackFrame_angles();

			// Interpolate. Every 4 
			slowMoCount = 4; // 1 / 4 -> 0.25.
			newOrigin = vectorScale(newOrigin, self.slowmoCount / slowMoCount) + vectorScale(oldOrigin, 1 - (self.slowmoCount / slowMoCount));
			newAngles = vectorScale(newAngles, self.slowmoCount / slowMoCount) + vectorScale(oldAngles, 1 - (self.slowmoCount / slowMoCount));

			// If we reached slowMoCount, it means we are finished with the current frame.
			self.slowmoCount++;
			if(self.slowmoCount == slowMoCount)
			{
				self.slowmoCount = 0;
			}
			else
			{
				self prevPlaybackFrame();
			}
		}

		// Player is linked, so update linker origin and player angles for this frame
		self.linker.origin = newOrigin;
		self setPlayerAngles(newAngles);
	}
}

_storeFrameToDB()
{
	if(!isDefined(self.recordLongQueryID))
	{
		self.recordLongQueryID = self openCJ\mySQL::mysqlAsyncLongQuerySetup();
		self.recordLongQueryFrameCount = 1;
		self.recordLongQueryRemainingChars = 10239;
		query = "SELECT storeDemoFrame(" + self openCJ\playerRuns::getRunID() + ", " + self openCJ\playerRuns::getRunInstanceNumber() + ", " + openCJ\statistics::getFrameNumber() + ", " + self.origin[0] + ", " + self.origin[1] + ", " + self.origin[2] + ", " + self getPlayerAngles()[0] + ", " + self getPlayerAngles()[1] + ", " + self getPlayerAngles()[2] + ", 1)";
	}
	else
	{
		query =  ", storeDemoFrame(" + self openCJ\playerRuns::getRunID() + ", " + self openCJ\playerRuns::getRunInstanceNumber() + ", " + openCJ\statistics::getFrameNumber() + ", " + self.origin[0] + ", " + self.origin[1] + ", " + self.origin[2] + ", " + self getPlayerAngles()[0] + ", " + self getPlayerAngles()[1] + ", " + self getPlayerAngles()[2] + ", 1)";
		self.recordLongQueryFrameCount++;
	}
	//printf("query is: " + query + "\n");
	self openCJ\mySQL::mySQLAsyncLongQueryAppend(self.recordLongQueryID, query);
	self.recordLongQueryRemainingChars -= query.size;
	if(self.recordLongQueryRemainingChars < 250 || self.recordLongQueryFrameCount > 200)
	{
		self thread _executeStoreQuery(self.recordLongQueryID);
		self.recordLongQueryID = undefined;
	}
}

_executeStoreQuery(queryID)
{
	self endon("disconnect");
	rows = self openCJ\mySQL::mysqlAsyncLongQueryExecuteSave(queryID);
	if(isDefined(rows) && rows.size)
	{
		for(i = 0; i < rows[0].size; i++)
		{
			if(rows[0][i] != "0")
				continue;
			else
			{
				self iprintln("Storing failed because this run was loaded by another profile");
				break;
			}
		}
	}
	
}